Shader "Unlit/Nebula_Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("A Color", Color) = (1,1,1,1)
        _Value("A Value", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent" }
        LOD 100
        ZWrite Off
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader


            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_(VertexData vertexData)
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
                return output;
            }

            float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                return col;
            }
            ENDCG
        }
    }
}
