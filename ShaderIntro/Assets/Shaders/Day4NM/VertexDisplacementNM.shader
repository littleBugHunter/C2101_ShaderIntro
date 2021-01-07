
Shader "ShaderCourse/VertexDisplacementNM"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
        _Distortion ("disortion ammount", Float) = 1
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
            float _Distortion;

            VertexToFragment VertexShader_ ( VertexData vertexData )///<<<< object space
            {

                VertexToFragment output;
                float3 WorldNormal = mul(UNITY_MATRIX_M,vertexData.normal);
                float4 WorldPosition = mul(UNITY_MATRIX_M,vertexData.position);

                float isFacingUp = dot(WorldNormal, float3(0,1,0)); // worldspace facing up
                float3 displacementDirection = vertexData.normal; 

                float3 displacementFactor = tex2Dlod(_MainTex,float4(vertexData.uv ,0,0));
                displacementFactor.xyz *= _Distortion;
                displacementDirection *= displacementFactor;
                float4 displacedPosition = vertexData.position;
                displacedPosition.xyz *= displacementDirection;
                //float4 worldSpacePosition = mul(UNITY_MATRIX_M, vertexData.position);
               // worldSpacePosition.xyz += float3(0,1,0); // transforms in worldspace
                output.position = UnityObjectToClipPos(displacedPosition);
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
