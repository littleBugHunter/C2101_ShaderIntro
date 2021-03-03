
Shader "ShaderCourse/Test01"
{
	//UI of the Shader
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_GlyphTex("Glyphs", 2D) = "white" {}
		_GlyphSizeX("Glyph Size Width", Int) = 8
		_GlyphSizeY("Glyph Size Height", Int) = 16
		_SymbolCount("Symbol Rows Count", Int) = 128
		_Test("test", float) = 0
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque"}
			LOD 100

			// i wanted to use a GrapPass to get a texture of what is behind my shader so I could use the grabbed texture to mask it with the symbols
			// for some reason it throws an Error: Shader properties can't be added to this global property sheet. Trying to add _BackgroundTexture_HDR (type 1 count 1) UnityEngine.GUIUtility:ProcessEvent(Int32, IntPtr)
			//GrabPass
			//{
				//"_BackgroundTexture"
			//}

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
					float2 uv : TEXCOORD0;
					float4 screenPosition : TEXCOORD1;
					//float4 grabPos : TEXCOORD2;
				};

				float inverseLerp(float v, float min, float max)
				{
					return (v - min) / (max - min);
				}

				float remap(float v, float min, float max, float outMin, float outMax)
				{
					float t = inverseLerp(v, min, max);
					return lerp(outMin, outMax, t);
				}

				sampler2D _MainTex;
				//sampler2D _BackgroundTexture;
				sampler2D _GlyphTex;
				float _GlyphSizeX;
				float _GlyphSizeY;
				float _SymbolCount;
				float _Test;

				VertexToFragment VertexShader_(VertexData vertexData)
				{
					VertexToFragment output;
					output.position = UnityObjectToClipPos(vertexData.position);
					output.uv = vertexData.uv;
					output.screenPosition = ComputeScreenPos(output.position);

					//output.grabPos = ComputeGrabScreenPos(output.position);

					return output;
				}

				// GPU IS DOING THINGS WITH THE DATA

				float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
				{
					//Pixelate:
					float2 gridPixels = float2(_ScreenParams.x / _GlyphSizeX, _ScreenParams.y / _GlyphSizeY);
					float2 gridScreenPos = gridPixels * vertexToFragment.screenPosition;
					float2 gridFraction = frac(gridScreenPos);

					float2 pixelation = floor(gridScreenPos);
					pixelation /= gridPixels;


					//half4 bgcolor = tex2Dproj(_BackgroundTexture, vertexToFragment.grabPos);
					//float4 mainTextPixelated = tex2D(bgcolor, pixelation);

					float4 mainTextPixelated = tex2D(_MainTex, pixelation);
					

					//GreyScale
					float greyscales = (mainTextPixelated.x + mainTextPixelated.y + mainTextPixelated.z) / 3;

					// Horizontal displacement
					float2 glyphRange = float2(0, _SymbolCount -1);

					float greyscaleMappedToGRange = remap(greyscales, 0, 1, glyphRange.x, glyphRange.y);
					greyscaleMappedToGRange = floor(greyscaleMappedToGRange);
					greyscaleMappedToGRange = remap(greyscaleMappedToGRange, glyphRange.x, glyphRange.y, 0, 1);
					if (_Test != 0) {
						greyscaleMappedToGRange = _Test;
					}
					float greyscaleStep = greyscaleMappedToGRange * remap(_GlyphSizeX / _SymbolCount, 0, 1, glyphRange.x, glyphRange.y);

					//Grid cell UVs:
					gridFraction.x = (gridFraction.x / _SymbolCount) + greyscaleStep;
					

					float4 col = tex2D(_GlyphTex, gridFraction);
					col.a = 1;
					return col;
				}
				ENDCG
			}
		}
}
