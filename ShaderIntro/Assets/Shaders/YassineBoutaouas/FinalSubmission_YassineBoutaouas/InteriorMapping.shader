Shader "Custom/InteriorMapping"
{
    Properties
    {
        _CubeMap("CubeMap", CUBE) = "" {}
        _CubeMap1("CubeMap 1", CUBE) = "" {}
        _CubeMap2("CubeMap 2", CUBE) = "" {}
        _CubeMap3("CubeMap 3", CUBE) = "" {}

        _Depth("Room Depth", Range(0.01, 1)) = 1

        [ShowAsVector2] _Tiling("Tiling", Vector) = (1, 1, 0, 0) //Note: ShowasVector2 not working

        _RandomizationValue("Randomization", Int) = 2
        _Offset("Offset", Float) = 0
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    //Vertex Data
    struct VertexData 
    {
        float4 vertex : POSITION;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;

        float2 uvCubeMap : TEXCOORD0;
    };

    //Vertex to fragment
    struct VertexToFragment 
    {
        float4 pos : POSITION;

        float3 viewDirTangent : TEXCOORD1;
        float2 uvCubeMap : TEXCOORD0;
    };

    ENDCG

        SubShader
    {
        Tags { "RenderType" = "Opaque" }

        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex Vertexshader
            #pragma fragment Fragmentshader

            samplerCUBE _CubeMap;
            samplerCUBE _CubeMap1;
            samplerCUBE _CubeMap2;
            samplerCUBE _CubeMap3;

            float _Depth;
            float4 _Tiling;
            int _RandomizationValue;
            float _Offset;

            float4 RandomRoom(samplerCUBE cubemap1, samplerCUBE cubemap2, samplerCUBE cubemap3, samplerCUBE cubemap4, float3 projection, float2 uv)
            {
                float4 output;

                float2 roundedUV = float2(round((uv.x * 2) + _Offset), round((uv.y * 2) + _Offset));

                float randomno = frac(sin(dot(roundedUV, float2(12.9898, 78.233))) * 43758.5453);
                float randomno2 = frac(sin(dot(roundedUV, float2(78.233, 12.9898))) * 43758.5453 * _RandomizationValue);

                float totalLerp = round(lerp(0, 1, randomno));
                float totalLerp2 = round(lerp(0, 1, randomno2));

                float4 col1 = texCUBE(cubemap1, projection);
                float4 col2 = texCUBE(cubemap2, projection);
                float4 col3 = texCUBE(cubemap3, projection);
                float4 col4 = texCUBE(cubemap4, projection);

                float4 lerpedCol1 = lerp(col1, col2, totalLerp);
                float4 lerpedCol2 = lerp(col3, col4, totalLerp);

                float4 lerpedCol3 = lerp(lerpedCol1, lerpedCol2, totalLerp2);

                output = lerpedCol3;

                return output;
            }

            float3 FracturedView(VertexToFragment vertexTofragment)
            {
                float2 fracturedUV = frac(_Tiling * vertexTofragment.uvCubeMap);
                float3 pos = float3(fracturedUV * 2 - 1, 1);

                float3 view = (1.0 / vertexTofragment.viewDirTangent) / _Depth;
                float3 absDirView = abs(view) - pos * view;
                float minSubFracDir = min(min(absDirView.x, absDirView.y), absDirView.z);
                pos += minSubFracDir * vertexTofragment.viewDirTangent;

                return pos;
            }

            VertexToFragment Vertexshader(VertexData v)
            {
                VertexToFragment output;
                output.pos = UnityObjectToClipPos(v.vertex);
                output.uvCubeMap = v.uvCubeMap;

                //Tangent space conversion
                float4 objCam = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDir = v.vertex.xyz - objCam.xyz;
                float tangentSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangentSign;

                output.viewDirTangent = float3(dot(viewDir, v.tangent.xyz), dot(viewDir, bitangent), dot(viewDir, v.normal));

                return output;
            }

            float4 Fragmentshader(VertexToFragment vertexTofragment) : SV_Target
            {
                float4 col = RandomRoom(_CubeMap, _CubeMap1, _CubeMap2, _CubeMap3, FracturedView(vertexTofragment), (_Tiling / 2) * vertexTofragment.uvCubeMap);

                return col;
            }
            ENDCG
        }

    }
    FallBack "Diffuse"
}
