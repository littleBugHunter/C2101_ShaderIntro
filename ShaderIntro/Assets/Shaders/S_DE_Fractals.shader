//This shader was an experiment using fractals and raymarching.
//I just wanted to create some awesome shapes.

Shader "Unlit/S_DE_Fractals"
{
    Properties
    {
		_LightDir("Light Direction", Vector) = (1,1,1)
        _Steps ("Raymarching Steps", float) = 20
		_MaxDis("Raymarching Max Distance", float) = 1
		_MinDis("Raymarching Min Distance", float) = 0.1
		_Power("Power", Range(0,10)) = 2
		_Color("Surface Color", Color) = (0.5,0,0,1)
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
            #pragma multi_compile_fog
			#pragma target 3.0
            #include "UnityCG.cginc"

			//Variables
			float _Steps;
			float _MinDis;
			float _MaxDis;
			float3 _LightDir;
			float _Speed;
			float _Power;
			float _Outline;
			float4 _OutlineColor;
			float4 _Color;

			//Structs for inputs and rays
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
				float4 pixelPos : TEXCOORD2;
            };

			struct ray {
				int stepCount;
				float gradient;
				float distance;
				float3 surfacePos;
				float closestRay;
			};

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.pixelPos = mul(unity_ObjectToWorld, v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

			float DE(float3 pos) {
				//Distance for a sphere
				//return length(pos) - 1;

				//Mandelbuld function found online
				float3 z = pos;
				float dr = 2.0;
				float r = 1.0;
				int iterations = 10;
				float bailout = 2.0;
				float power = _Power;
				for (int i = 0; i < iterations; i++) {
					r = length(z);
					if (r > bailout) break;
					float theta = acos(z.z / r);
					float phi = atan(z.y* z.x);
					dr = pow(r, power - 1)*power*dr + 1;

					float zr = pow(r, power);
					theta = theta * power;
					phi = phi * power;

					z = zr * float3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
					z += pos;
				}
				return 0.5*log(r)*r / dr;
			}

			//Raycast using distance approximation
			//This part is completely self-made
			ray RayCast(float3 pos, float3 dir) {
				ray r;
				r.closestRay = 1000;
				for (int x = 0; x < _Steps; x++) {
					float dis = DE(pos + r.distance * dir);
					r.distance += dis;
					if (r.closestRay > dis) r.closestRay = dis;
					if (dis < _MinDis) break;
				}
				r.stepCount = x;
				r.gradient = 1 - float(x) / float(_Steps);
				r.surfacePos = pos + r.distance * dir;
				return r;
			}

			//Normal function found online
			float3 normal(float3 pos) {
				return normalize(float3(
					DE(float3(pos.x + _MinDis, pos.y, pos.z)) - DE(float3(pos.x - _MinDis, pos.y, pos.z)),
					DE(float3(pos.x, pos.y + _MinDis, pos.z)) - DE(float3(pos.x, pos.y - _MinDis, pos.z)),
					DE(float3(pos.x, pos.y, pos.z + _MinDis)) - DE(float3(pos.x, pos.y, pos.z - _MinDis))
				));
			}

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = (0,0,0,0);
                UNITY_APPLY_FOG(i.fogCoord, col);

				//Calculate Ray
				float3 cameraDirection = normalize(i.pixelPos - _WorldSpaceCameraPos);
				ray r = RayCast(i.pixelPos, cameraDirection);
				float surfaceAlpha = saturate(1 - r.closestRay *_Outline);

				//Generate color and alpha
				col.a = saturate(ceil(r.gradient - _MinDis));
				col.xyz = r.gradient * _Color.xyz;
                return col;
            }
            ENDCG
        }
    }
}
