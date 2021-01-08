Shader "ShaderCourse/UVMappingCode_NM"
{
    //UI of the Shader
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("A Color", Color) = (1,1,1,1)
        _Value("A Value", Float) = 1
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            Pass
            {
                CGPROGRAM
                #pragma vertex VertexShader_
                #pragma fragment FragmentShader

                #include "UnityCG.cginc"

                struct VertexData
                {
            // You could put as much data as you want 
                float4 position : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_(VertexData vertexData)
            {
                // Day 4 - Vertex Shader
                VertexToFragment output;
                float4 worldSpacePosition = mul(UNITY_MATRIX_M, vertexData.positon);
                worldSpacePosition.xyz += float3(0, 1, 0);
                output.position = mul(UNITY_MATRIX_VP, vertexData.position);

                output.uv = vertexData.uv;
                return output;
            }

            // GPU IS DOING THINGS WITH THE DATA

            float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
            {

            }
            ENDCG
        }
        }
}
