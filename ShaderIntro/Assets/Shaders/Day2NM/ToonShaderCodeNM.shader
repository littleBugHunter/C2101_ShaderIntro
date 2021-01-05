Shader "Myshaders/ToonShaderCodeNM"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_Color ("A Color", Color) = (1,1,1,1)
        //_Value ("A Value", Float) = 1
        _Sundirection("SunDirection",Vector) = (0,1,0,0)
        _LightThreshold("Threshold",Float) = 1
        _Colorlight("ColorLight",color) = (1,1,1,1)
        _ColorDark("ColorDark",color) = (0,0,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float3 normal   : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _Sundirection;
            float _LightThreshold;

            float3 _Colorlight;
            float3 _ColorDark;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.normal = mul(UNITY_MATRIX_M,vertexData.normal);
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {

                float3 normal = normalize(vertexToFragment.normal);
                _Sundirection = normalize(_Sundirection);
                float dotProduct = dot(normal,_Sundirection);

                float3 lightColor;

                if(dotProduct > _LightThreshold)
                {
                    lightColor = _Colorlight;
				}else{
                    lightColor = _ColorDark;
				}

               float3 texColor = tex2D(_MainTex,vertexToFragment.uv);
               float3 col = texColor * lightColor;
               return float4 (col, 1);
            }
            ENDCG
        }
    }
}
