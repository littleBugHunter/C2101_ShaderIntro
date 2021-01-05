Shader "Unlit/ToonLighting_NM"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION; // in position was vertex, but prof. changed
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; // how to deal with texture (inspector texture)
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ (VertexData vertexData)
            {
                VertexToFragment output; // in c# = new Constructor - but here constructor is not existing
                output.vertex = UnityObjectToClipPos(vertexData.position); // but this not competible with VR !
                output.uv = vertexData.uv;
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return output;
            }
            // GPU IS DOING THINS WITH DATA
            fixed4 FrsgmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex,vertexToFragment.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
