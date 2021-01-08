Shader "Unlit/Outline_COde"
{
	//UI of the Shader
	Properties
	{
		//_MainTex("Texture", 2D) = "white" {}
		_OutlineColor("An OutlineColor", Color) = (0,0,0,1)
		_OutlineSize ("An OutlineSize", Float) = 0.1
	}
		SubShader
		{
			Tags { "RenderType" = "Opaque" }
			LOD 100

			Pass
			{
				Cull Front
				ZTest Always
				ZWrite Off
				
				CGPROGRAM
				#pragma vertex VertexShader_
				#pragma fragment FragmentShader

				#include "UnityCG.cginc"

				struct VertexData
				{
					float4 position : POSITION;
					float3 normal   : NORMAL;
					//float2 uv       : TEXCOORD0;
				};

				struct VertexToFragment
				{
					float4 position : SV_POSITION;
					//float2 uv     : TEXCOORD0;
				};

					float4 _OutlineColor;
					float  _OutlineSize;

				VertexToFragment VertexShader_(VertexData vertexData)
				{
					VertexToFragment output;
					float3 pushDirection = vertexData.normal * _OutlineSize;
					vertexData.position.xyz += pushDirection;
					output.position = UnityObjectToClipPos(vertexData.position);
					//output.uv = vertexData.uv;
					return output;
				}

				// GPU IS DOING THINGS WITH THE DATA

				float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
				{
					// sample the texture
					//fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
					return _OutlineColor;
				}
				ENDCG
			}
		}
}