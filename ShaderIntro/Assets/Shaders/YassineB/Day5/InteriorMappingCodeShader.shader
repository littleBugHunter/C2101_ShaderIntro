Shader "Unlit/InteriorMappingCodeShader"
{
    Properties
    {
        _CubeMap("Cubemap", CUBE) = "" {}
        _Depth("Room Depth", Range(0,1)) = 1
    }

    CGINCLUDE
    
    #include "UnityCG.cginc"
    
    //Vertex data
    struct VertexData
    {
        float4 vertex : POSITION;
    };

    //Fragment data
    struct VertexToFragment
    {
        float4 vertexPos : SV_POSITION;
        float3 viewDir : TEXCOORD1;
    };

    ENDCG

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex Vertexshader
            #pragma fragment Fragmentshader

            samplerCUBE _CubeMap;
            //Tiling and Offset
            float4 _CubeMap_ST;

            float _Depth;

            float3 _fracturedView;

            float3 Fracture(VertexToFragment vertexTofragment)
            {
                return float3((float2(round(frac(vertexTofragment.vertexPos.x)), round(frac(vertexTofragment.vertexPos.y))) * 2) - (float2(1,1)), 1);
            }

            float3 ViewDirection(VertexData v)
            {
                //Transfer the object to world view
                float4x4 modelMatrix = unity_ObjectToWorld;
                //View Direction 
                return (mul(modelMatrix, v.vertex).xyz - _WorldSpaceCameraPos);
            }

            float3 CubeMapping(VertexToFragment vertToFrag, VertexData v) 
            {
                float3 absoluteDir = (abs(ViewDirection(v).x / _Depth), abs(ViewDirection(v).y / _Depth), abs(ViewDirection(v).z / _Depth));
                float3 mulFracDir = (mul(absoluteDir.x, Fracture(vertToFrag).x), mul(absoluteDir.y, Fracture(vertToFrag).y), mul(absoluteDir.z, Fracture(vertToFrag).z));
                float3 subtractedFracDir = (absoluteDir - mulFracDir);

                float minSubFracDirXY = min(subtractedFracDir.x, subtractedFracDir.y);
                float minSubFracDirZ = min(minSubFracDirXY, subtractedFracDir.z);

                float3 mulMinSubFracView = mul(ViewDirection(v), minSubFracDirZ);

                float3 addedminSubViewFrac = (mulMinSubFracView.x + Fracture(vertToFrag).x, mulMinSubFracView.y + Fracture(vertToFrag).y, mulMinSubFracView.z + Fracture(vertToFrag).z);

                return float3(mul(addedminSubViewFrac.x, -1), mul(addedminSubViewFrac.y, -1), addedminSubViewFrac.z);
            }

            VertexToFragment Vertexshader (VertexData v)
            {
                VertexToFragment output;

                output.viewDir = ViewDirection(v);
                output.vertexPos = UnityObjectToClipPos(v.vertex);

                //Call cubemapping here...
                _fracturedView = CubeMapping(output, v);

                return output;
            }

            float4 Fragmentshader(VertexToFragment vertexTofragment) : SV_Target
            {
                //Project the map based on view direction
                //vertexTofragment.viewDir = normalize(vertexTofragment.viewDir);

                float4 col = texCUBE(_CubeMap, _fracturedView);

                return col;
            }

            ENDCG
        }
    }
}
