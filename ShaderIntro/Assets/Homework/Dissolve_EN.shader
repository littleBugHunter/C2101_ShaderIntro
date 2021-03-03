Shader "Unlit/DissolveEN"
{
    Properties
    {
        _MainTexture ("MainTexture", 2D) = "white" {}
        _MainColor ("MainColor", Color) = (1,1,1,1)
        _DissolveAmount ("DissolveAmount", Range(0, 1)) = 0.2
        _DissolveOutline ("DissolveOutline", Range(0, 1)) = 0.4
        _DissolveTexture ("DissolveTexture", 2D) = "white" {}
        _DissolveMainColor ("DissolveMainColor", Color) = (1,1,1,1)
        _DissolveSecondaryColor ("DissolveSecondaryColor", Color) = (1,1,1,1)
        _DissolveOffsetMin ("DissolveOffsetMin", Float) = 0.2
        _DissolveOffsetMax ("DissolveOffsetMax", Float) = 1.8
        _DissolveBlurMin ("DissolveOffsetMin", Float) = 0.4
        _DissolveBlurMax ("DissolveOffsetMax", Float) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader_

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
                float3 normal   : NORMAL;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTexture;
            float4 _MainColor;
            float _DissolveAmount;
            float _DissolveOutline;
            sampler2D _DissolveTexture;
            float4 _DissolveMainColor;
            float4 _DissolveSecondaryColor;
            float _DissolveOffsetMin;
            float _DissolveOffsetMax;
            float _DissolveBlurMin;
            float _DissolveBlurMax;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment vertexToFragment;
                vertexToFragment.position = UnityObjectToClipPos(vertexData.position);
                vertexToFragment.normal = vertexData.normal;
                vertexToFragment.uv = vertexData.uv;
                return vertexToFragment;
            }

            float InvLerp_(float from, float to, float value) {
                return (value - from) / (to - from);
            }

            float Remap_(float origFrom, float origTo, float targetFrom, float targetTo, float value){
                float rel = InvLerp_(origFrom, origTo, value);
                return lerp(targetFrom, targetTo, rel);
            }
            
            float4 FragmentShader_ (VertexToFragment vertexToFragment) : SV_Target
            {
                // Main Texture and Color
                float4 color = tex2D(_MainTexture, vertexToFragment.uv) * _MainColor;

                // Dissolve Alpha
                float alphaValue = Remap_(0, 1, _DissolveOffsetMin, _DissolveOffsetMax, _DissolveAmount);
                alphaValue = 1 - alphaValue;
                float alpha = tex2D(_DissolveTexture, vertexToFragment.uv).x + alphaValue;
                alpha = Remap_(0, 1, _DissolveBlurMin, _DissolveBlurMax, alpha);
                alpha = saturate(alpha);

                // Dissolve Outline
                float outline = step(alpha, _DissolveOutline);
                outline = 1 - outline;

                // Outline Main Color
                float outlineColVal1 = alpha - outline;
                outlineColVal1 = saturate(outlineColVal1);
                float4 outlineColor1 = _DissolveMainColor * outlineColVal1;

                // Outline Secondary Color
                float outlineColVal2 = outline - alpha;
                outlineColVal2 = saturate(outlineColVal2);
                float4 outlineColor2 = _DissolveSecondaryColor * outlineColVal2;

                // Outline Color
                float4 outlineColor = outlineColor1 + outlineColor2;

                // Apply Alpha and Color
                color = color + outlineColor;
                color.a = alpha;
                
                return color;
                
            }
            ENDCG
        }
    }
}
