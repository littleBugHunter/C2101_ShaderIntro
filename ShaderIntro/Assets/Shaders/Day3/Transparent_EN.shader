Shader "Unlit/TransparentEN"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Value ("Value", Float) = 1
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "Queue"="Transparent" 
        }
        LOD 100
        ZWrite Off
        Blend One One

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment vertexToFragment;
                vertexToFragment.position = UnityObjectToClipPos(vertexData.position);
                vertexToFragment.normal = vertexData.normal;
                vertexToFragment.uv = vertexData.uv;
                return vertexToFragment;
            }
            
            float4 FragmentShader_ (VertexToFragment vertexToFragment) : SV_Target
            {
                float4 color = tex2D(_MainTex, vertexToFragment.uv);
                return color;
            }
            ENDCG
        }
    }
}
