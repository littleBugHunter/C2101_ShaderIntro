Shader "Unlit/ToonShader"
{
    Properties
    {
		_MainTex("Texture", 2D) = "white" {}
		_SunDirection("Sun Direction", Vector) = (0,1,0,0)
		_LightThreshold("Light Threshold", Float) = 0
		_BrightColor("Bright Color", Color) = (1, 1, 1)
		_DarkColor("Dark Color", Color) = (0, 0, 0)
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
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f //Vertex to fragment
            {
                float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float _SunDirection;
			float _LightThreshold;

			float3 _BrightColor;
			float3 _DarkColor;
				//for each vertex
            v2f vert (appdata v) //Vertex shader
            {
                v2f o;//output
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = mul(UNITY_MATRIX_M, v.normal);
				o.uv = v.uv;
                return o;
            }
			//GPU IS DOING THINGS WITH THE DATA
				//for each pixel
            fixed4 frag (v2f i) : SV_Target //fixed4 = float4
            {
				float3 normal = normalize(v2f.normal);
				_SunDirection = normalize(_SunDirection);
				float dotProduct = dot(normal, _SunDirection);

				float finalColor
				if (dotProduct > _LightThreshold) {
					finalColor = _BrightColor;
				}
				else {
					finalColor = _DarkColor;
				}
                float3 texColor = tex2D(_MainTex, i.uv);
				float3 col = texColor * finalColor;
                return float4 (col, 1);
            }
            ENDCG
        }
    }
}
