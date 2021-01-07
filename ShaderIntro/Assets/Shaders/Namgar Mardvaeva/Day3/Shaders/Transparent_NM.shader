Shader "ShaderCourse/Transparent_NM"
{
    //UI of the Shader
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("A Color", Color) = (1,1,1,1)
        _Value("A Value", Float) = 1
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" "Queue" = "Transparent" } // change the queue from opaque row to transparent (2.00), frame debug 
            LOD 100
            ZWrite Off // first, main step
            Blend /*srcColor*/DstColor /*+DistColor*/Zero

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
                    float normal : NORMAL;
                    float2 uv     : TEXCOORD0;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;

                VertexToFragment VertexShader_(VertexData vertexData)
                {
                    VertexToFragment output;
                    output.position = UnityObjectToClipPos(vertexData.position);
                    output.normal = vertexData.normal;
                    output.uv = vertexData.uv;
                    return output;
                }

                // GPU IS DOING THINGS WITH THE DATA

                float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
                {
                    // sample the texture
                    float4 texCol = tex2D(_MainTex, vertexToFragment.uv);
                    return texCol; // casting, basically
                }
                ENDCG
            }
        }
}
