
Shader "ShaderCourse/Template"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
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
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData ) // << Object Space
            {
                VertexToFragment output;
                float3 worldNormal = mul(UNITY_MATRIX_M, vertexData.normal);
                float4 worldPosition = mul(UNITY_MATRIX_M, vertexData.position);
                
                float isFacingUp = dot(worldNormal, float3(0,1,0));
                isFacingUp = saturate(isFacingUp); // clamp between 0 and 1
                float3 displacementDirection = worldNormal;
                float4 displacementFactor = tex2Dlod(_MainTex, float4(vertexData.uv, 0, 0));
                displacementDirection *= displacementFactor * isFacingUp;
                
                float4 displacedPosition = worldPosition;
                displacedPosition.xyz += displacementDirection;
                
                output.position = mul(UNITY_MATRIX_VP, displacedPosition);
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                return col;
            }
            ENDCG
        }
    }
}
