Shader "Unlit/ToonEN"
{
    Properties
    {
        _LightDirection ("LightDirection", vector) = (0, 0.8, 0, 0)
        _Threshold ("Threshold", float) = 0
        _LightColor ("LightColor", color) = (1, 1, 1, 1)
        _ShadowColor ("ShadowColor", color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader_

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            float3 _LightDirection;
            float _Threshold;
            float4 _LightColor;
            float4 _ShadowColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_(VertexData vertexData)
            {
                VertexToFragment vertexToFragment;
                vertexToFragment.position = UnityObjectToClipPos(vertexData.position);
                vertexToFragment.normal = vertexData.normal;
                vertexToFragment.uv = vertexData.uv;
                return vertexToFragment;
            }

            fixed4 FragmentShader_(VertexToFragment vertexToFragment) : SV_Target
            {
                float4 color;
                
                float3 normalNormal = normalize(vertexToFragment.normal);
                float3 normalLightDir = normalize(_LightDirection);
                float dotProduct = dot(normalNormal, normalLightDir);

                if (dotProduct > _Threshold)
                {
                    color = _LightColor;
                }
                else
                {
                    color = _ShadowColor;
                }

                color = color * tex2D(_MainTex, vertexToFragment.uv);

                return color;
            }
            ENDCG
        }
    }
}