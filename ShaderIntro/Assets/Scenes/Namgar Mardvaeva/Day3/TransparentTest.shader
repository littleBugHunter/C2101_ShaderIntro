Shader "ShaderCourse/TransparentTest"
{
    //UI of the Shader
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("A Color", Color) = (1,1,1,1)
        _Value("A Value", Float) = 1
        _SunDirection("Sun Direction", Vector) = (0, 1, 0, 0)
        _LightThreshold("Light Threshold", Float) = 0
        _BrightColor("Bright Color", Color) = (1,1,1, 1)
        _DarkColor("Dark Color", Color) = (0,0,0, 1)
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
                float3 _SunDirection;
                float _LightThreshold;

                // Colors declaration
                float3 _BrightColor;
                float3 _DarkColor;

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
                    float3 normal = normalize(vertexToFragment.normal);
                    _SunDirection = normalize(_SunDirection);
                    float dotProduct = dot(normal, _SunDirection);
                    //return dotProduct;

                    float3 lightColor;
                    // Comparison
                    if (dotProduct > _LightThreshold) {
                        lightColor = _BrightColor;
                    }
                    else {
                        lightColor = _DarkColor;
                    }

                    // sample the texture
                    float3 texCol = tex2D(_MainTex, vertexToFragment.uv);
                    float3 col = texCol * lightColor;
                    return float4(col, 1); // casting, basically
                }
                ENDCG
            }
        }
}
