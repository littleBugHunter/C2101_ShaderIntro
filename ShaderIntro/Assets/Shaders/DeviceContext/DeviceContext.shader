Shader "Unlit/DeviceContext"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", color) = (1,1,1,1)
        
        [KeywordEnum(Unlit, Lambert)] _Lighting ("Lighting Model", Float) = 0
        [Header(Culling)]
        [Enum(UnityEngine.Rendering.CullMode)] __CullMode("Cull Mode", Int)  = 0
        [Header(Z Testing)]
        [Enum(UnityEngine.Rendering.CompareFunction)] __ZTest("Z Test", Int) = 4
        [Toggle()] __ZWrite("Z Write", Float) = 1
        __ZOffsetFactor("Z Offset Factor", Float) = 0
        __ZOffsetUnits("Z Offset Units", Float) = 0
        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendMode)] __SrcBlend("Src Color", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] __DstBlend("Dst Color", Int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] __SrcABlend("Src Alpha", Int) = 1
        [Enum(UnityEngine.Rendering.BlendMode)] __DstABlend("Dst Alpha", Int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] __BlendOp("Operation Color", Int) = 0
        [Enum(UnityEngine.Rendering.BlendOp)] __BlendOpA("Operation Alpha", Int) = 0
        [Header(Stencil)]
        __StencilRef ("Reference", Int) = 0
        __StencilReadMask ("Read Mask", Int) = 255
        __StencilWriteMask ("Write Mask", Int) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)] __StencilComp("Comparison Function", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] __StencilPassOp("Pass Operation", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] __StencilFailOp("Fail Operation", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] __StencilZFailOp("Z Fail Operation", Int) = 0
        
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        
        Cull [__CullMode]
        ZTest [__ZTest]
        ZWrite [__ZWrite]
        Offset [__ZOffsetFactor], [__ZOffsetUnits]
        Blend [__SrcBlend] [__DstBlend], [__SrcABlend] [__DstABlend]
        BlendOp [__BlendOp], [__BlendOpA]
        
        Stencil {
            Ref [__StencilRef]
            ReadMask [__StencilReadMask]
            WriteMask [__StencilWriteMask]
            Comp [__StencilComp]
            Pass [__StencilPassOp]
            Fail [__StencilFailOp]
            ZFail [__StencilZFailOp]
        }

        Pass
        {
            Name "StandardLit"
            Tags{"LightMode" = "UniversalForward"}
            CGPROGRAM
            #pragma multi_compile _LIGHTING_UNLIT _LIGHTING_LAMBERT
            
            #if _LIGHTING_UNLIT
                #define fragment_shader frag_unlit
            #elif _LIGHTING_LAMBERT
                #define fragment_shader frag_lambert
            #endif
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D main_tex;
            float4 _MainTex_ST;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal   = mul(UNITY_MATRIX_M, v.normal);
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag_unlit (v2f i) 
            {
                // sample the texture
                fixed4 col = tex2D(main_tex, i.uv) * _Color;
                return col;
            }
            
            fixed4 frag_lambert (v2f i) 
            {
                // sample the texture
                fixed4 col = tex2D(main_tex, i.uv) * _Color;
                float4 lightDir = _WorldSpaceLightPos0;
                if(lightDir.w > 0.5) {
                    lightDir.xyz = normalize(i.worldPos - lightDir.xyz); 
                }
                float ndl = saturate(dot(lightDir.xyz, i.normal));
                col.rgb *= ndl;
                return col;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = fragment_shader(i);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
