
Shader "Fire /Shader Course"
{
    //UI of the Shader
    Properties
    {
        _MaskTex ("BaseMap", 2D) = "white" {}
        _NoiseTex("Noise", 2D) = "white" {}
        _ScrollSpeed("Scoll speed", Float) = 1
        _ClippingThreshhold("Threshhold", Range(0,1)) = 0.5
        _Smoothness("Range", Range(0,1)) = 0.1
        _Color("Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        LOD 100
        ZWrite Off
        Blend One One

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

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
                fixed4 diff : COLOR0;
            };

            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
                return output;
            }

            float InverseLerp(float v, float min, float max) {
                return (v - min) / (max - min);
            }
            
            float Remap(float v, float min, float max, float outMin, float outMax) 
            {
                float t = InverseLerp(v, min, max);
                return lerp(outMin, outMax, t);
            }

            // GPU IS DOING THINGS WITH THE DATA
            sampler2D _MaskTex;
            sampler2D _NoiseTex;
            float _ScrollSpeed;
            float _Smoothness;
            float _ClippingThreshhold;
            float4 _Color;
            
            float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
            {
                float2 uv = vertexToFragment.uv;
                float2 scrolledUV = vertexToFragment.uv;
                scrolledUV.y += _Time.y * _ScrollSpeed * -1;

                float4 maskCol = tex2D(_MaskTex, scrolledUV);
                float4 noiseCol = tex2D(_NoiseTex, scrolledUV);

                float4 combined = maskCol.x * noiseCol.x;

                float sharpenedValue = InverseLerp(combined, _ClippingThreshhold - _Smoothness, _ClippingThreshhold + _Smoothness);

                sharpenedValue = saturate(sharpenedValue);

                return sharpenedValue * _Color;
            }
            ENDCG
        }
    }
}
