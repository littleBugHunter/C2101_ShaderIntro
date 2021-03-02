Shader "Unlit/Clouds"
{
	Properties
	{
		_Color("Cloud Color", Color) = (1,1,1,1)
		_ColorStrength("Cloud Color Strength", Range(0,1)) = 0.1
		_Detail("Cloud Detail", Range(1,8)) = 8
		_Whirl("Cloud Whirl", Range(0,2)) = 0.5
		_NoiseScale("Cloud Scale", float) = 1
		_Multiplier("Cloud Density", float) = 5
		_Exponent("Cloud Density Exponent", float) = 5
		_Speed("Cloud Speed", Range(0,1)) = 0.5
		_Direction("Cloud Direction", Vector) = (1,1,1)

		_StepSize("RayMarching Step Size", float) = 0.1
		_Steps("RayMarching Step Count", Int) = 20
	}
		SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent"}
		LOD 100
		Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
			#pragma target 3.0
			#include "AutoLight.cginc"


            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertexPos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertexPos : SV_POSITION;
				float4 pixelPos : TEXCOORD2;
            };

			float _StepSize;
			float _NoiseScale;
			float _Coverage;
			float _Multiplier;
			float _Exponent;
			int _Steps;
			int _Detail;
			float _Speed;
			float _Whirl;
			float3 _Direction;
			fixed4 _Color;

			float _ColorStrength;

			//Simplex Noise implementation, found online
			float hash(float n) { return frac(sin(n)*43758.5453); }
			float noise(float3 x)
			{
				float3 p = floor(x);
				float3 f = frac(x);

				f = f * f*(3.0 - 2.0*f);
				float n = p.x + p.y*57.0 + 113.0*p.z;

				return lerp(lerp(lerp(hash(n + 0.0), hash(n + 1.0), f.x),
					lerp(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
					lerp(lerp(hash(n + 113.0), hash(n + 114.0), f.x),
						lerp(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertexPos = UnityObjectToClipPos(v.vertexPos);
				o.uv = v.uv;
				o.pixelPos = mul(unity_ObjectToWorld, v.vertexPos);
                UNITY_TRANSFER_FOG(o,o.vertexPos);
                return o;
            }

			float getCloud(float3 pos, int detail) {
				float noiseV = 0;
				for (int x = 0; x < detail; x+=2) 
					noiseV += (noise(pos * pow(2, x) + normalize(_Direction) * _Time * _NoiseScale * (x + 1) * _Speed) * pow(1 - (float(x) / float(detail)),4)) * 0.8;
				return noiseV;
			}

            fixed4 frag (v2f i) : SV_Target
            {
				float _Opacity = _Color.a;
				fixed4 col = _Color * float4(1,1,1,0);
                //UNITY_APPLY_FOG(i.fogCoord, col);
				float3 cameraDirection = normalize(i.pixelPos - _WorldSpaceCameraPos) / _Steps;
				i.pixelPos += float4(0, noise(i.pixelPos*0.01) * _Whirl * 100, 0, 0);
				for (int x = 0; x < _Steps; x++) {
					float alphaToAdd = getCloud(_NoiseScale * 0.03 * (i.pixelPos + (cameraDirection * x * _StepSize)), _Detail);
					float colorToAdd = (1-_ColorStrength) / _Steps * alphaToAdd;
					col -= float4(colorToAdd, colorToAdd, colorToAdd, -alphaToAdd * (_Opacity / _Steps));
				}
				col.a = saturate(pow(saturate(col.a), _Exponent) * _Multiplier);
				col.a *= 1-distance(i.uv, float2(0.5, 0.5))*2;
				col = saturate(col);
				
                return col;
            }
            ENDCG
        }
    }
}
