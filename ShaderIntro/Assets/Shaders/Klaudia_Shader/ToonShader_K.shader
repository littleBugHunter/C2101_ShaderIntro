
Shader "ShaderCourse/ToonShader_K"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        //_Color("A Color", Color) = (1,1,1,1)
       // _Value("A Value", Float) = 1
        _SunDirection("Sun Direction", Vector) = (0,1,0,0) //make sure these have the same name everywhere
        _LightThreshold ("Light Threshold", Float) = 0
        _BrightColor("BrightColor", Color) = (1,1,1,1)
        _DarkColor("DarkColor", Color) = (0,0,0,1)
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
                float2 uv       : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3 _SunDirection;
            float1 _LightThreshold;

            float3 _BrightColor;
            float3 _DarkColor;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.normal = mul(UNITY_MATRIX_M, vertexData.normal); //multiply with model matrix to put normals in world space
                output.uv = vertexData.uv;
                
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                float3 normal = normalize(vertexToFragment.normal);
                _SunDirection = normalize(_SunDirection);
                float dotProduct = dot(normal, _SunDirection);
                
                float3 lightColor;
                if (dotProduct > _LightThreshold) {
                    //true
                    lightColor = _BrightColor;
                }
                else {
                    //false
                    lightColor = _DarkColor;
                }
                // sample the texture
                float3 texColor = tex2D(_MainTex, vertexToFragment.uv);
                float3 col = texColor * lightColor;
                return float4(col, 1);
            }
            ENDCG
        }
    }
}
