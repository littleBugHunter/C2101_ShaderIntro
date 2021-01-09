
Shader "ShaderCourse/Fire_MV"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

		_MaskTex("Mask Texture", 2D) = "white" {}
		_NoiseTex("TNoise Texture", 2D) = "white" {}
		_NoiseFactor("Noise Factor", Float) = 1


	    _WindDirection("Wind direction", Vector) = (0,0,0)
		_WindSpeed("Wind Speed", Float) = 0
		_WindThreshold("Wind Threshold", Range(0, 1)) = 0.5
	
        _ScrollSpeed ("Scroll Speed", Float) = 1
		_Threshold("Threshold", Range(0, 1)) = 0.5
		_Smoothness("Smooth", Range(0, 2)) = 1


		_ColorBottomThreshold("Color Bottom Threshold", Range(0, 1)) = 0.3
		_ColorTopThreshold("Color Top Threshold", Range(0, 1)) = 0.7
		_ColorBottom("Color on Bottom", Color) = (1,1,1,1)
		_Color ("Color", Color) = (1,1,1,1)
		_ColorTop("Color on Top", Color) = (1,1,1,1)

    }
    SubShader
    {
		Pass
		{
			Tags { "RenderType" = "Opaque"}
			LOD 100
			
			//Blend /*SrcColor * */ One /* + DstColor * */ One
			 // Additive Blending

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

			sampler2D _MaskTex;
			sampler2D _NoiseTex;
			float _NoiseFactor;

			float4 _WindDirection;
			float _WindSpeed;
			float _WindThreshold;

			float _ScrollSpeed;
			float _Threshold;
			float _Smoothness;

			float _ColorBottomThreshold;
			float _ColorTopThreshold;
			float4 _ColorBottom;
			float4 _Color;
			float4 _ColorTop;



			// GPU IS DOING THINGS WITH THE DATA

			float inverseLerp(float v, float min, float max)
			{
				return (v - min) / (max - min);
			}

			float remap(float v, float min, float max, float outMin, float outMax)
			{
				float t = inverseLerp(v, min, max);
				return lerp(outMin, outMax, t);
			}

			VertexToFragment VertexShader_(VertexData vertexData)
			{
				VertexToFragment output;

				//float windFactor = inverseLerp(vertexData.uv.y, _WindThreshold - _Smoothness, _WindThreshold + _Smoothness);
				float windFactor = saturate(remap(vertexData.uv.y, _WindThreshold, 1, 0, 1));
				windFactor = windFactor * windFactor;


				float4 normWDir = _WindDirection;
				if (length(_WindDirection) != 0)
				{
					normWDir = normalize(_WindDirection);
				}

				float4 pos = UnityObjectToClipPos(vertexData.position + (normWDir * _WindSpeed * windFactor));
				//pos += _WindDirection * _WindSpeed * windFactor;

				output.position = pos;
				output.uv = vertexData.uv;
				return output;
			}

			float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
			{
				float2 uv = vertexToFragment.uv;
				float2 scrolledUv = vertexToFragment.uv;

				scrolledUv.y += _Time.x * -1 * _ScrollSpeed;

				float4 maskCol = tex2D(_MaskTex, uv);
				float4 noiseCol = tex2D(_NoiseTex, scrolledUv);

				// sample the texture
				noiseCol = noiseCol * _NoiseFactor;
				float combinedCol = maskCol.x * noiseCol.x;

				float sharpenedResult = inverseLerp(combinedCol, _Threshold - _Smoothness, _Threshold + _Smoothness);

				sharpenedResult = saturate(sharpenedResult); //clamps result between 0 and 1

				float t = saturate(remap(uv.y, 0, _ColorBottomThreshold, 0, 1));
				float4 col = lerp(_ColorBottom, _Color, t);

				t = saturate(remap(uv.y, _ColorBottomThreshold, _ColorTopThreshold, 0, 1));

				col = lerp(col, _Color, t);

				t = saturate(remap(uv.y, _ColorTopThreshold, 1, 0, 1));
				col = lerp(col, _ColorTop, t);


				return sharpenedResult * col;
			}
				//float4 _ColorBottom;
				//float4 _Color;
				//float4 _ColorTop;
				ENDCG
			}
		

        Pass
        {
			Tags { "RenderType" = "Opaque"  "Queue" = "Transparent" }
			LOD 100
			ZWrite Off
			//Blend /*SrcColor * */ One /* + DstColor * */ One
			Blend One One // Additive Blending

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

			sampler2D _MaskTex;
			sampler2D _NoiseTex;
			float _NoiseFactor;

			float4 _WindDirection;
			float _WindSpeed;
			float _WindThreshold;

			float _ScrollSpeed;
			float _Threshold;
			float _Smoothness;

			float _ColorBottomThreshold;
			float _ColorTopThreshold;
			float4 _ColorBottom;
			float4 _Color;
			float4 _ColorTop;

            
            
            // GPU IS DOING THINGS WITH THE DATA
            
			float inverseLerp(float v, float min, float max)
			{
				return (v - min) / (max - min);
			}

			float remap(float v, float min, float max, float outMin, float outMax)
			{
				float t = inverseLerp(v, min, max);
				return lerp(outMin, outMax, t);
			}

			VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
				
				//float windFactor = inverseLerp(vertexData.uv.y, _WindThreshold - _Smoothness, _WindThreshold + _Smoothness);
				float windFactor = saturate(remap(vertexData.uv.y, _WindThreshold, 1, 0, 1));
				windFactor = windFactor * windFactor;


				float4 normWDir = _WindDirection;
				if (length(_WindDirection) != 0)
				{
					normWDir = normalize(_WindDirection);
				}
				
				float4 pos = UnityObjectToClipPos(vertexData.position + (normWDir * _WindSpeed * windFactor));
				//pos += _WindDirection * _WindSpeed * windFactor;
				
                output.position = pos;
                output.uv = vertexData.uv;
                return output;
            }

            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
				float2 uv = vertexToFragment.uv;
				float2 scrolledUv = vertexToFragment.uv;
				
				scrolledUv.y += _Time.x * -1 * _ScrollSpeed;

				float4 maskCol = tex2D(_MaskTex, uv);
				float4 noiseCol = tex2D(_NoiseTex, scrolledUv);

                // sample the texture
				noiseCol = noiseCol * _NoiseFactor;
                float combinedCol = maskCol.x * noiseCol.x;

				float sharpenedResult = inverseLerp(combinedCol, _Threshold - _Smoothness, _Threshold + _Smoothness);

				sharpenedResult = saturate(sharpenedResult); //clamps result between 0 and 1

				float t = saturate(remap(uv.y, 0, _ColorBottomThreshold, 0, 1));
				float4 col = lerp(_ColorBottom, _Color, t);

				t = saturate(remap(uv.y, _ColorBottomThreshold, _ColorTopThreshold, 0, 1));
				
				col = lerp(col, _Color, t);

				t = saturate(remap(uv.y, _ColorTopThreshold, 1, 0, 1));
				col = lerp(col, _ColorTop, t);
				
				
				return sharpenedResult * col;
            }
			//float4 _ColorBottom;
			//float4 _Color;
			//float4 _ColorTop;
            ENDCG
        }
    }
}
