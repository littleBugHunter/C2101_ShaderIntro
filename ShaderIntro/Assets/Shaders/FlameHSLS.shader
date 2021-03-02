Shader "Flame Test using Code"
{
	Properties
	{
		C_OuterColor("Outer Color", Color) = (1,0,0,0)
		V2_OuterPosition("Outer Position", Vector) = (0.5, 0.21, 0, 0)
		V2_OuterRadius("Outer Radius", Float) = 0.25
		C_InnerColor("Inner Color", Color) = (1, 0.3945, 0, 0)
		V2_InnerPosition("Inner Position", Vector) = (0.5, 0.29, 0, 0)
		V2_InnerRadius("Inner Radius", Float) = 0.15
		C_SmallColor("Small Color", Color) = (0.78, 0.78, 0.78)
		V2_SmallPosition("Small Position", Vector) = (0.5, 0.16, 0, 0)
		V2_SmallRadius("Small Radius", Float) = 0.1
	}
	SubShader
	{
		Tags
		{
			"RenderType"="Transparent"
			"Queue"="Transparent+0"
		}

		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		ZTest LEqual
		ZWrite Off

		Pass
		{	
			CGPROGRAM
			#pragma fragment FragmentShader
			#pragma vertex VertShader

			#include "UnityCG.cginc"

			float4 C_OuterColor;
			float2 V2_OuterPosition;
			float V2_OuterRadius;
			float4 C_InnerColor;
			float2 V2_InnerPosition;
			float V2_InnerRadius;
			float4 C_SmallColor;
			float2 V2_SmallPosition;
			float V2_SmallRadius;

			struct VertexToFragment
			{
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			float2 NoiseDir(float2 p)
			{
				// Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
				p = p % 289;
				float x = (34 * p.x + 1) * p.x % 289 + p.y;
				x = (34 * x + 1) * x % 289;
				x = frac(x / 41) * 2 - 1;
				return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
			}

			void Noise(float2 UV, float Scale, out float Out)
			{
				float2 p = UV * Scale;
				float2 ip = floor(p);
				float2 fp = frac(p);
				float d00 = dot(NoiseDir(ip), fp);
				float d01 = dot(NoiseDir(ip + float2(0, 1)), fp - float2(0, 1));
				float d10 = dot(NoiseDir(ip + float2(1, 0)), fp - float2(1, 0));
				float d11 = dot(NoiseDir(ip + float2(1, 1)), fp - float2(1, 1));
				fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
				Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
			}

			void FlameSub(float SphereRadius, float2 SpherePosition, VertexToFragment IN, out float Albedo, out float Alpha)
			{
				float offsetStrength = saturate(IN.uv[1] - 0.03) * 0.5;
				float2 noiseUV = float2(IN.uv[0], IN.uv[1] + _Time.x * -5);
				float noiseOffset;
				Noise(noiseUV, 11.32, noiseOffset);
				noiseOffset = noiseOffset * offsetStrength;
				float distanceToCenter = 1 - distance(float2(IN.uv[0], IN.uv[1] - noiseOffset), SpherePosition);
				Albedo = ceil(distanceToCenter - (1 - SphereRadius));
				
				float floorAlpha = saturate(IN.uv[1] * Albedo * 20);
				float heightAlpha = saturate((1 - IN.uv[1]) * 2);
				Alpha = heightAlpha;
			}

			struct SurfaceDescription
			{
				float3 Color;
				float Alpha;
			};

			struct VertexData {
				float4 position : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			VertexToFragment VertShader(VertexData vertexData) 
			{
				VertexToFragment output;
				output.position = UnityObjectToClipPos(vertexData.position);
				output.uv = vertexData.uv;
				return output;
			}

			float4 FragmentShader(VertexToFragment IN) : SV_Target
			{
				float4 surface;

				float Alpha;

				float SmallColor;
				FlameSub(V2_SmallRadius, V2_SmallPosition, IN, SmallColor, Alpha);
				float4 SmallFlameAlbedo = C_SmallColor * SmallColor;

				float InnerColor;
				FlameSub(V2_InnerRadius, V2_InnerPosition, IN, InnerColor, Alpha);
				float4 InnerFlameAlbedo = C_InnerColor * InnerColor;

				float OuterColor;
				FlameSub(V2_OuterRadius, V2_OuterPosition, IN, OuterColor, Alpha);
				float4 OuterFlameAlbedo = C_OuterColor * OuterColor;

				surface = lerp(lerp(OuterFlameAlbedo, InnerFlameAlbedo, InnerColor), SmallFlameAlbedo, SmallColor);
				surface = surface * float4(1, 1, 1, Alpha);
				return surface;
			}

			ENDCG
		}
	}
}