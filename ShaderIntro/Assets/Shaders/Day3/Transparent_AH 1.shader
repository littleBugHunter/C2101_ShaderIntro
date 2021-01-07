Shader "ShaderCourse/TransparentAH"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FireCoreColor ("Fire Core Color", Color) = (1,0,0,1)
        _FireMainColor ("Fire Main Color", Color) = (1,1,0,0.5)
        _Value ("A Value", Float) = 1
        _Direction ("Light Direction oder so", Vector) = (0,1,0,0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend One OneMinusSrcAlpha

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
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL ;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _FireCoreColor;
            float4 _FireMainColor;
            float3 _Direction;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
                output.normal=mul(UNITY_MATRIX_M,vertexData.normal);
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv)*_FireCoreColor;
                col.a = dot(vertexToFragment.normal,_Direction);
                return col;
            }
            ENDCG
        }
    }
}
