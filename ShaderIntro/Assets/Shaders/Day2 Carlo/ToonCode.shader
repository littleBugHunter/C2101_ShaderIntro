
Shader "ShaderCourse/ToonCode"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_SunDirection ("Sun Direction", Vector) = (1, 1, 1, 0)
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
		_DarkColor ("Dark Color", Color) = (0, 0, 0, 0)
		_DarkestColor ("darkestColor", Color) = (0, 0, 0, 0)
        _Treshold ("Treshold", Float) = 1
		_StepTreshold("Step Treshold", Float) = 1
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
				float3 normal : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
			float3 _SunDirection;
			float4 _LightColor;
			float4 _DarkColor;
			float4 _DarkestColor;
			float _Treshold;
			float _StepTreshold;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
				output.normal = mul(unity_ObjectToWorld, vertexData.normal);
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
				float3 normal = normalize(vertexToFragment.normal);
				float3 sunNormal = normalize(_SunDirection);
				float normalDot = dot(normal, sunNormal);

				float4 col = tex2D(_MainTex, vertexToFragment.uv);

				if (normalDot > _Treshold) 
				{
					col *= _LightColor;
				}
				else 
				{
					if (normalDot > _StepTreshold)
					{
						col *= _DarkColor;
					}
					else 
					{
						col *= _DarkestColor;
					}
				}

                return col;
            }
            ENDCG
        }
    }
}