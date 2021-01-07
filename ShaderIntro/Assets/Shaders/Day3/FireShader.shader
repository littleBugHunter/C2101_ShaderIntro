
Shader "ShaderCourse/FireShader"
{
    //UI of the Shader
    Properties
    {
		[Toggle] _Billboard("Billboard", float) = 0
        _MaskTex ("Mask Texture", 2D) = "white" {}
		_NoiseTex("Noise Texture", 2D) = "white" {}
		_NoiseScale("Noise Scale", float) = 1
		_FlameScale("Flame Scale", Vector) = (1,1,0,0)
		_ScrollSpeed("Speed", float) = 1
		_Threshold("Threshold", Range(0,1)) = 0.5
		_Smoothness("Smoothness", Range(0,0.1)) = 0.05
		_Color("Color", Color) = (1,1,1,1)
		_WindDir("Wind", Vector) = (1,1,1,1)
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
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
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

			sampler2D _MaskTex;
			sampler2D _NoiseTex;
			float _NoiseScale;
			float2 _FlameScale;
			float _ScrollSpeed;
			float _Threshold;
			float _Smoothness;
			float4 _Color;
			float _Billboard;
			float4 _WindDir;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                
				if (_Billboard)
				{
					//copied from stack overflow, but I read the explaination and tried my best to understand it lol
					output.position = mul(UNITY_MATRIX_P, mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
					+ float4(vertexData.position.x, vertexData.position.y, 0.0, 0.0) * float4(_FlameScale.x, _FlameScale.y, 1.0, 1.0));
				}
				else 
				{
					output.position = UnityObjectToClipPos(vertexData.position);
				}

				//doesn't really work as intended yet
				if(output.position.y < 0)
					output.position += _WindDir;

                output.uv = vertexData.uv;
                return output;
            }
            
			float inverseLerp(float v, float min, float max) {
				return (v - min) / (max - min);
			}

			float remap(float v, float min, float max, float outMin, float outMax) {
				float t = inverseLerp(v, min, max);
				return lerp(outMin, outMax, t);
			}
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
				float2 uv = vertexToFragment.uv;
				float2 scrolledUv = vertexToFragment.uv;
				scrolledUv.y += _Time.y * _ScrollSpeed * -1;

                // sample the texture
                float4 maskCol = tex2D(_MaskTex, uv);
				float4 noiseCol = tex2D(_NoiseTex, scrolledUv * _NoiseScale);

				float combined = maskCol.x * noiseCol.x;

				float sharpenedResult = inverseLerp(combined, _Threshold - _Smoothness, _Threshold + _Smoothness);
				sharpenedResult = saturate(sharpenedResult);

				return sharpenedResult * _Color;
            }
            ENDCG
        }
    }
}
