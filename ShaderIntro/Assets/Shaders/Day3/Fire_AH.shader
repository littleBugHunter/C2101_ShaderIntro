Shader "ShaderCourse/TransparentAH"
{
    //UI of the Shader
    Properties
    {
        _FireCoreColor ("Fire Core Color", Color) = (1,0,0,1)
        _FireMainColor ("Fire Main Color", Color) = (1,1,0,0.5)
        _NoiseTex("Noise", 2D) = "white" {}
        _MaskTex("Shape Mask", 2D) = "white" {}
        _ScrollSpeed("Flame Speed", Float) = 1    
        _Threshold("Threshold", Range(0,1)) = 0
        _Smoothness("Smoothness",Range(0,0.2))=0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend One One

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

            float4 _FireCoreColor;
            float4 _FireMainColor;
            sampler2D _NoiseTex;
            sampler2D _MaskTex;
            float _ScrollSpeed;
            float _Threshold;
            float _Smoothness;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
               // output.normal=mul(UNITY_MATRIX_M,vertexData.normal);
                return output;
            }
            float inverseLerp(float v, float min, float max)
                        {
                            return (v - min)/(max-min);
                        }
            
            // GPU IS DOING THINGS WITH THE DATA
            float remap(float v, float min, float max, float outMin, float outMax)
            {
                float t = inverseLerp(v,min,max);
                return lerp(outMin,outMax,t);
            }

            
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                float4 r; //Return Value
                float2 uv= vertexToFragment.uv;
                float2 scrolledUv = uv;
                scrolledUv.y = uv.y + _Time.y/20 * -1 * _ScrollSpeed;
                // sample the texture
                float4 maskCol= tex2D(_MaskTex, uv);
                float4 noiseCol = tex2D(_NoiseTex,scrolledUv);
                float combined = maskCol.x * noiseCol.x;
                float sharpenedCombined = inverseLerp(combined,_Threshold-_Smoothness,_Threshold);
                sharpenedCombined = saturate(sharpenedCombined);
                r = sharpenedCombined*_FireMainColor;

                return r;
               }
            ENDCG
        }
    }
}
