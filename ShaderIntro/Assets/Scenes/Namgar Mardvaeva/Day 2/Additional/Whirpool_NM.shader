Shader "Unlit/Whirpool_NM"
{
    /*Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed", Float) = 2
        _Time("Time", Vector) = (0,1,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                // whirpool


            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // Whirpool
            float _Speed;
            float2 _Time;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag(v2f vertexToFragment) : SV_Target
            {
                vertexToFragment.uv -= float2(0.5, 0.5); // why? coordinate axis from cartesian system?
                float2 uv = vertexToFragment.uv;
                // Polar UV
                float2 polarUv = vertexToFragment.uv;
                float angle = atan2(polarUv.y, polarUv.x);
                uv = float2(length(polarUv), (angle / M_2PI));
                // Interpolation btw two systems
                float time = saturate(sin(_Time.y));
                uv = lerp(vertexToFragment.uv, uv, time);
                // Spiral - periodical function (sin) and give it sum of length and angle
                // Offset to polar coordinates (for movement)
                float offset = _Time.x * _Speed; // if speed will be negative, it will be in another direction
                uv += float2(offset, offset);

                // UV output (выводим UV координаты на плоскость)
                return float4(uv, 0, 1);
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                //return col;
            }
            ENDCG
        }
    }*/
}
