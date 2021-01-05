Shader "Unlit/ToonShader_Code_LI"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HighlightColor("Highlight Color", Color) = (1, 0, 0, 1)
        _LightColor("Light Color", Color) = (1, 0, 0, 1)
        _DarkColor("Dark Color", Color) = (1, 0, 0, 1)

        _TextureScale("Texture Scale", float) = 0
        _Threshold("Threshold", float) = 0
        _HightlightThreshold("HighlightThreshold", float) = 0

        _SunDirection("Sun Direction", Vector) = (0,1,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata //VertexData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f //VertexToFragment
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _TextureScale;

            v2f vert (appdata v) //VertexShader
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _TextureScale;
                o.normal = mul(UNITY_MATRIX_M, v.normal);
                //float3 normalizedSun = dot(normalize(_SunDirection), normalize(v.normal));

                return o;
            }

            //GPU MAAAAAGIIIIC

            float3 _SunDirection;
            //float _TextureScale;
            float _Threshold;
            float _HightlightThreshold;

            float3 _HighlightColor;
            float3 _LightColor;
            float3 _DarkColor;


            float4 frag (v2f i) : SV_Target //FragmentShader
            {
                float3 normal = normalize(i.normal);
                float3 sun = normalize(_SunDirection);
                float dotProduct = dot(normal, sun);

                float3 lightColor;
                if (dotProduct > _Threshold)
                {
                    lightColor = _LightColor;
                }
                else
                {
                    lightColor = _DarkColor;
                }

                if (dotProduct > _HightlightThreshold)
                {
                    lightColor = _HighlightColor;
                }

                // sample the texture
                float3 texColor = tex2D(_MainTex, i.uv);
                
                float3 col = lightColor * texColor;

                return float4(col, 1);
            }
            ENDCG
        }
    }
}
