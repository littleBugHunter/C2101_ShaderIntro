
Shader "ShaderCourse/DisplacementCode"
{
    //UI of the Shader
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}

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
            
            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                float3 worldNormal = mul(UNITY_MATRIX_M, vertexData.normal);

                float isFacingUp = dot(worldNormal, float3(0, 1, 0));
                isFacingUp = saturate(isFacingUp);

                float3 displacementDirection = vertexData.normal;
                float4 displacementFactor = tex2Dlod(_MainTex, float4(vertexData.uv,0,0));
                displacementDirection *= displacementFactor * isFacingUp;

                float4 displacedPosition = vertexData.position;
                displacedPosition.xyz += displacementDirection;

                float4 objectSpaceDisplacedPos = mul(unity_WorldToObject, displacedPosition);

                output.position = mul(UNITY_MATRIX_VP, displacedPosition);
                output.normal = mul(UNITY_MATRIX_M, vertexData.normal); //Multiply with Model Matrix to put normals in world space
                output.uv = vertexData.uv;

                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                //clip(alpha-Threshhold); discard = return null; -> lots of optimizations are turned off

                float3 normal = normalize(vertexToFragment.normal);
                
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                return col;
            }
            ENDCG
        }
    }
}
