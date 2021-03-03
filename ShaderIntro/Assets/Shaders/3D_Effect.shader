
Shader "ShaderCourse/3D_Effect"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color0("BaseColor", Color) = (1,1,1,1)
		[HDR]_Color1("EffectColor1", Color) = (1,0,1,1)
		[HDR]_Color2("EffectColor2", Color) = (0,0,1,1)
		_EffectOffset("EffectOffset", Vector) = (0,0,0,0)
		LightDir("LightDir", Vector) = (0,-1,0,0)
		Light("useLight", Float) = 0
		
		 BlendMode("BlendModeForOvelap", Float) = 0
					


		_ScrollSpeed("ScrollSpeed", Float) = .1
    }
    SubShader
    {
		Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
		ZWrite Off
			
		Blend One One



		LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader
			#pragma geometry Geometry
            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };

			struct VertexToGeometry
			{
			float4 position : SV_POSITION;
			float3 normal	:NORMAL;
			float2 uv     : TEXCOORD0;
			};
            struct GeometryToFragment
            {
                float4 position : SV_POSITION;
                float2 uv     : TEXCOORD0;
				float4 color : COLOR0;
				float3 normal	:NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			VertexToGeometry VertexShader_ ( VertexData vertexData )
            {
				VertexToGeometry output;
                output.position = vertexData.position;
                output.uv = TRANSFORM_TEX(vertexData.uv, _MainTex);
				output.normal = vertexData.normal;
			
                return output;
            }
            
			float4 _EffectOffset;
			float4 _Color0;
			float4 _Color1;
			float4 _Color2;
			float4 LightDir;
			[maxvertexcount(27)]
			void Geometry(triangle VertexToGeometry input[3], inout TriangleStream<GeometryToFragment> tristream) {
				// The actual "normal" geometry
				GeometryToFragment output;
				/*output.color = _Color0;
				output.position = UnityObjectToClipPos(input[0].position);
				output.uv = input[0].uv;
				output.normal = input[0].normal;
				tristream.Append(output);
				output.position = UnityObjectToClipPos(input[1].position);
				output.uv = input[1].uv;
				output.normal = input[1].normal;
				tristream.Append(output);
				output.position = UnityObjectToClipPos(input[2].position);
				output.uv = input[2].uv;
				output.normal = input[2].normal;
				tristream.Append(output);
				tristream.RestartStrip();


				// The positively offset geometry
				//float4 pos = (0, 0, 0, 0);
				
				output.color = _Color1;

				pos = input[0].position +_EffectOffset;
				output.position = UnityObjectToClipPos(pos);
				output.uv = input[0].uv;
				output.normal = input[0].normal;
				tristream.Append(output);

				pos = input[1].position +_EffectOffset;
				output.position = UnityObjectToClipPos(pos);
				output.uv = input[1].uv;
				output.normal = input[1].normal;
				tristream.Append(output);

				pos = input[2].position +_EffectOffset;
				output.position = UnityObjectToClipPos(pos);
				output.uv = input[2].uv;
				output.normal = input[2].normal;
				tristream.Append(output);
				tristream.RestartStrip();

				// The negative offset geometry
				output.color = _Color2;
				float4 otherOffset = (-.5* _EffectOffset.x, 1* _EffectOffset.y, -1* _EffectOffset.z, _EffectOffset.w);
				pos = input[0].position -_EffectOffset;
				pos.y += 2 * _EffectOffset.y;
				output.position = UnityObjectToClipPos(pos);
				output.uv = input[0].uv;
				output.normal = input[0].normal;
				tristream.Append(output);

				pos = input[1].position - _EffectOffset;
				pos.y += 2 * _EffectOffset.y;
				output.position = UnityObjectToClipPos(pos);
				output.uv = input[1].uv;
				output.normal = input[1].normal;
				tristream.Append(output);

				pos = input[2].position - _EffectOffset;
				pos.y += 2 * _EffectOffset.y;
				output.position = UnityObjectToClipPos(pos);
				output.uv = input[2].uv;
				output.normal = input[2].normal;
				tristream.Append(output);

				tristream.RestartStrip();
				*/

			
				
			
				output.color = _Color1;
				float3 VPos = (0, 0, 0);


				float LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(input[0].normal)));
				output.color.w = LightValue;
				VPos = UnityObjectToViewPos(input[0].position.xyz);
				VPos = VPos + _EffectOffset.xyz;
				output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
				output.uv = input[0].uv;
				output.normal = input[0].normal;
				tristream.Append(output);

				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(input[1].normal)));
				output.color.w = LightValue;
				VPos = UnityObjectToViewPos(input[1].position.xyz);
				VPos = VPos + _EffectOffset.xyz;
				output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
				output.uv = input[1].uv;
				output.normal = input[1].normal;
				tristream.Append(output);

				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(normalize(input[2].normal))));
				output.color.w = LightValue;
				VPos = UnityObjectToViewPos(input[2].position.xyz);
				VPos = VPos + _EffectOffset.xyz;
				output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
				output.uv = input[2].uv;
				output.normal = input[2].normal;
				tristream.Append(output);
				tristream.RestartStrip();




				output.color = _Color2;
				float4 newOffset = float4(-1, -1, 1, 1)* _EffectOffset;
			
				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(normalize(input[0].normal))));
				output.color.w = LightValue;

				VPos = UnityObjectToViewPos(input[0].position.xyz);
				VPos = VPos + newOffset.xyz;
				output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
				output.uv = input[0].uv;
				output.normal = input[0].normal;
				tristream.Append(output);
				
				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(normalize(input[1].normal))));
				output.color.w = LightValue;
				VPos = UnityObjectToViewPos(input[1].position.xyz);
				VPos = VPos + newOffset.xyz;
				output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
				output.uv = input[0].uv;
				output.normal = input[1].normal;
				tristream.Append(output);
				
				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(normalize(input[2].normal))));
				output.color.w = LightValue;
				VPos = UnityObjectToViewPos(input[2].position.xyz);
				VPos = VPos + newOffset.xyz;
				output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
				output.uv = input[0].uv;
				output.normal = input[2].normal;
				tristream.Append(output);
				tristream.RestartStrip();


			}


			float _ScrollSpeed;
            // GPU IS DOING THINGS WITH THE DATA
			float Light;
			float4 FragmentShader(GeometryToFragment geometryToFragment) : SV_Target
			{
				// sample the texture
				
			geometryToFragment.uv += float2(0, _ScrollSpeed) * _Time.x;
			fixed4 col = tex2D(_MainTex, geometryToFragment.uv);
			
				 col = col* float4(geometryToFragment.color.xyz,0);
				 col = (Light == 1 ? col * geometryToFragment.color.w : col);
				
                return col;
            }
            ENDCG
        }
    }
}
