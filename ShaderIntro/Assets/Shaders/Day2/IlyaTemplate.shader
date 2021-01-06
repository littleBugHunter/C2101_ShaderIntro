
Shader "ShaderCourse/IlyaTemplate"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
					_BrightColor("A _BrightColor", Color) = (1,1,1,1)
					_DarkColor("A _DarkColor", Color) = (1,1,1,1)
					_LightThreshhold("A _LightThreshhold", Float) = 1
								_SunDirection("A Sundirection", Vector) = (1,1,1,1)


    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
				float3 normal  : NORMAL;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _BrightColor;
			float4 _DarkColor;
			float3 _SunDirection;
			float _LightThreshhold;
            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
				output.normal = vertexData.normal;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
			float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
			{

				float4 col;
				// sample the texture
			float dotProd;
				dotProd = dot(_SunDirection,vertexToFragment.normal);
			if (dotProd < _LightThreshhold) {
				col = _BrightColor;
			}
			else {

				col = _DarkColor;
			}

                 col =col* tex2D(_MainTex, vertexToFragment.uv);
                return col;
            }
            ENDCG
        }
    }
}
