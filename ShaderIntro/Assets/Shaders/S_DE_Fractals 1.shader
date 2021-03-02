// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/S_DE_Fractals"
{
    Properties
    {
		_LightDir("Light Direction", Vector) = (1,1,1)
        _Steps ("Raymarching Steps", float) = 20
		_MaxDis("Raymarching Max Distance", float) = 1
		_MinDis("Raymarching Min Distance", float) = 0.1
		_Speed("Speed", float) = 0.01
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
            // make fog work
            #pragma multi_compile_fog
			#pragma target 3.0
            #include "UnityCG.cginc"

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
			};

			float _Steps;
			float _MinDis;
			float _MaxDis;
			float3 _LightDir;
			float _Speed;
			float _Power;

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
				//return length(pos) - 1;
				float3 z = pos;
				float dr = 2.0;
				float r = 1.0;
				int iterations = 10;
				float bailout = 2.0;
				float power = (sin(_Speed * _Time) + 2) * 4 - 2;
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

			ray RayCast(float3 pos, float3 dir) {
				float curDis = 0;
				for (int x = 0; x < _Steps; x++) {
					float dis = DE(pos + curDis * dir);
					curDis += dis;
					if (dis < _MinDis) break;
				}
				ray r;
				r.stepCount = x;
				r.gradient = 1 - float(x) / float(_Steps);
				r.distance = curDis;
				r.surfacePos = pos + curDis * dir;
				return r;
			}

			float3 normal(float3 pos) {
				return normalize(float3(
					DE(float3(pos.x + _MinDis, pos.y, pos.z)) - DE(float3(pos.x - _MinDis, pos.y, pos.z)),
					DE(float3(pos.x, pos.y + _MinDis, pos.z)) - DE(float3(pos.x, pos.y - _MinDis, pos.z)),
					DE(float3(pos.x, pos.y, pos.z + _MinDis)) - DE(float3(pos.x, pos.y, pos.z - _MinDis))
				));
			}

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = (0,0,0,0);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
				float3 cameraDirection = normalize(i.pixelPos - _WorldSpaceCameraPos);
				ray r = RayCast(i.pixelPos, cameraDirection);

				//col.xyz = saturate(dot(_LightDir, normal(r.surfacePos)))/2;
				col.a = ceil(r.gradient - _MinDis);
				col.xyz = r.gradient;
                return col;
            }
            ENDCG
        }
    }
}
