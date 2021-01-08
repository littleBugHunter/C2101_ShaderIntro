// From PN
Shader "ShaderCourse/DispMap"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("A Color", Color) = (1,1,1,1)
        _Value("A Value", Float) = 1
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
                float normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                // First ver for texture
                /*VertexToFragment output;
                float3 worldNormal = mul(UNITY_MATRIX_M, vertexData.normal);//being applied only in world space
                float4 worldPosition = mul(UNITY_MATRIX_M, vertexData.normal);

                float isFacingUp = dot(worldNormal, float3(0, 1, 0));
                isFacingUp = saturate(isFacingUp); // clamp btw 0 and 1
                float3 displacementDirection = worldNormal;
                float4 displacementFactor = tex2Dlod(_MainTex, float4(vertexData.uv, 0, 0));
                displacementDirection *= displacementFactor;

                float4 displacedPosition = worldPosition;
                displacedPosition.xyz += displacementDirection.xyz; // instead of x, y, z separately 

                // to reduce twice
                //objectSpaceDisplacedPosition = mul(unity_WorldToObject, displacedPosition);


                // But changing this is cleaner, also, saves computing power
                output.position = mul(UNITY_MATRIX_VP, objectSpaceDisplacedPosition);//UnityObjectToClipPos(vertexData.position);
                //output.normal = vertexData.normal;
                output.uv = vertexData.uv;
                return output; */

                // Second ver for sm more 
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
            {

            }
            ENDCG
        }
    }
}
