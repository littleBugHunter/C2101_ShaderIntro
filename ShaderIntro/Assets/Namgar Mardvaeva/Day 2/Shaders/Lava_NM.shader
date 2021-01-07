Shader "ShaderCourse/Lava_NM"
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
            Tags { "RenderType" = "Opaque" }
            LOD 100

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
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;

                VertexToFragment VertexShader_(VertexData vertexData)
                {
                    VertexToFragment output;
                    output.position = UnityObjectToClipPos(vertexData.position);
                    output.uv = vertexData.uv;
                    return output;
                }

                // GPU IS DOING THINGS WITH THE DATA
                sample2D _DisplacementMap;
                float _DisplacementAmount;
                float4 _Time;

                float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
                {
                    float2 uv = vertexToFragment.uv;
                    float2 timeOffset = float2(0, _Time.x);
                    float4 displacementCol = text2D(_DisplacementMap, uv);
                    float2 displacementDirection = displacementCol.xy * _DisplacementAmount;

                    float2 displacedUv = uv + displacementDirection;
                    // sample the texture
                    fixed4 col = tex2D(_MainTex, displacedUv);
                    return col;
                }
                ENDCG
            }
        }
}