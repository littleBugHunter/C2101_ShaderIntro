
Shader "ShaderCourse/3D_EffectNew"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		TexScrollY("TexScrollUpSpeed", Float) = .1


		[HDR]_Color0("BaseColor", Color) = (1,1,1,1)
		[HDR]_Color1("EffectColor1", Color) = (1,0,1,1)
		[HDR]_Color2("EffectColor2", Color) = (0,0,1,1)
		
		LightDir("LightDir", Vector) = (0,-1,0,0)
		Light("useLight", Float) = 0
		minLight("minLight", Float) = 0
		LightPower("LightPower",Float)=1
		LightSteps("LightSteps",Float) = 1

			


		UseDouplicates("UseDouplicates", Float) = 0
		_EffectOffset("EffectOffset", Vector) = (0,0,0,0)
		DouplicatesShiftSpeed("DouplicatesShiftSpeed", Float) = .1
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
			float TexScrollY;
			VertexToGeometry VertexShader_ ( VertexData vertexData )
            {
				VertexToGeometry output;
                output.position = vertexData.position;
				output.uv = TRANSFORM_TEX(vertexData.uv+float2(0, TexScrollY*_Time.y), _MainTex);
				output.normal = vertexData.normal;
			
                return output;
            }
            
			float4 _EffectOffset;
			float4 _Color0;
			float4 _Color1;
			float4 _Color2;
			float4 LightDir;
			float DouplicatesShiftSpeed;
			float UseDouplicates;
			[maxvertexcount(27)]
			void Geometry(triangle VertexToGeometry input[3], inout TriangleStream<GeometryToFragment> tristream) {
				
				GeometryToFragment output;
				float LightValue = 1;

			
				output.color = _Color0;


				output.position = UnityObjectToClipPos(input[0].position);
				output.uv = input[0].uv;
				output.normal = input[0].normal;
				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(input[0].normal)));
				output.color.w = LightValue;

				tristream.Append(output);
				output.position = UnityObjectToClipPos(input[1].position);
				output.uv = input[1].uv;
				output.normal = input[1].normal;
				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(input[1].normal)));
				output.color.w = LightValue;
				tristream.Append(output);

				output.position = UnityObjectToClipPos(input[2].position);
				output.uv = input[2].uv ;
				output.normal = input[2].normal;
				LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(input[2].normal)));
				output.color.w = LightValue;
				tristream.Append(output);
				tristream.RestartStrip();


				if (UseDouplicates == 1) {

				
				output.color = _Color1;
				float3 VPos = (0, 0, 0);
				float sinTime = (DouplicatesShiftSpeed == 0 ? 1 : sin(_Time.y * DouplicatesShiftSpeed));
				for (int copies = -1; copies <= 1; copies+=2) {
					
					
					float4 newOffset = float4(copies*sinTime, copies * sinTime, 1, 1) * _EffectOffset;
					output.color = (copies ==-1 ? _Color1: _Color2);
				for (int i = 0; i < 3; i++) {

					LightValue = dot(normalize(LightDir), normalize(UnityObjectToWorldNormal(input[i].normal)));
					output.color.w = LightValue;
					VPos = UnityObjectToViewPos(input[i].position.xyz);
					
					VPos = VPos + newOffset.xyz;
					output.position = mul(UNITY_MATRIX_P, float4(VPos, 1));
					output.uv = input[i].uv;
					output.normal = input[i].normal;
					tristream.Append(output);

				}
				tristream.RestartStrip();
				}
				}


			}


		
            // GPU IS DOING THINGS WITH THE DATA
			float Light;
			float minLight;
			float LightPower;
			float LightSteps;

			float4 FragmentShader(GeometryToFragment geometryToFragment) : SV_Target
			{
				// sample the texture	
				fixed4 col = tex2D(_MainTex, geometryToFragment.uv);
			
				 col = col* float4(geometryToFragment.color.xyz,1);
				 if (Light >= 1) {

					float brightn = floor(geometryToFragment.color.w / (1.0f / LightSteps))* (1.0f / LightSteps);
					
					brightn = pow(brightn*Light, LightPower);
					brightn = clamp(brightn,0,1);
					
					col = lerp(col* minLight, col*Light, brightn);
				 }
				 else {
					 
				 }

                return col;
            }
            ENDCG
        }
    }
}
