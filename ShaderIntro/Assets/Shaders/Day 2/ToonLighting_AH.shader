
Shader "ShaderCourse/ToonLighting_AH"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BrightColor ("Bright Color", Color) = (0.5,0.5,0.5,0.5)
        _DarkColor ("Dark Color", Color) = (0,0,0,1)
        _HighlightColor ("Highlight Color", Color) = (0,0,0,1)
        _SunDirection ("Sun Direction", Vector) = (0,1,0,0)
        _LightThreshold ("Ligth Threhsold", Float) = 0.5
        _HighlightThreshold ("Highligth Threhsold", Float) = 0.2
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
                float4 position      : POSITION;
                float3 normal        : NORMAL;
                float2 uv            : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position      : SV_POSITION;
                float3 normal        : NORMAL;
                float2 uv            : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _SunDirection;
            float _LightThreshold;
            float _HighlightThreshold;
            float3 _BrightColor;
            float3 _DarkColor;
            float3 _HighlightColor;
            
            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                vertexData.normal = mul(UNITY_MATRIX_M,vertexData.normal);
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.normal = vertexData.normal;
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                float3 normal = normalize(vertexToFragment.normal);
                _SunDirection = normalize(_SunDirection);
                float dotProdcut = dot(normal,_SunDirection);

                
                
                float3 lightColor;
                if(dotProdcut > _HighlightThreshold)
                {
                    lightColor = _HighlightColor;
                }
                else
                {
                    lightColor = _BrightColor;
                }
         

                if(dotProdcut < _LightThreshold)
                {
                    lightColor = _DarkColor; 
                }

                // sample the texture
                float3 texColor = tex2D(_MainTex, vertexToFragment.uv);
                float3 col = texColor*lightColor;
                return float4(col,1);
            }
            ENDCG
        }
    }
}
