
Shader "ShaderCourse/CodeExamples"
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


            VertexToFragment VertexShader_ ( VertexData vertexData /// <<< Object Space )
            {
                VertexToFragment output;
                float4 worldSpacePosition = mul(UNITY_MATRIX_M, vertexData.position);
                worldSpacePosition.xyz += float3(0,1,0);
                output.position = mul(UNITY_MATRIX_VP, worldSpacePosition);
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            sampler2D _MainTex;
            sampler2D _DisplacementMap;
            float _DisplacementAmount;
            float4 _Time; //just declare a _Time variable of type float4 to get the time values
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                float2 uv = vertexToFragment.uv; //put uv into a variable
                // Time is a vector, usually you want to use x
                float2 timeOffset = float2(0, _Time.x); 
                float4 displacementCol = tex2D(_DisplacementMap, uv + timeOffset);
                float2 displacementDirection = displacementCol.xy * _DisplacementAmount;
                
                float2 displacedUv = uv + displacementDirection;
                
                
                // use displaced Uvs for displacement mapping
                fixed4 col = tex2D(_MainTex, displacedUv); 
                return col;
            }
            ENDCG
        }
    }
}
