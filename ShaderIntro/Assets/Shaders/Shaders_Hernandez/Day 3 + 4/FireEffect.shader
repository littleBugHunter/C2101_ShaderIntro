
Shader "ShaderCourse/FireEffect"
{
    //UI of the Shader
    Properties
    {
        
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
        
        _MaskTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Texture", 2D) = "white" {}
        _ScrollSpeed("Scroll Speed" , Float) = 1
        _Smoothness ("_Smoothness", Range(0,0.2)) = 0.1
        _Treshold ("Treshold", Range(0,1)) = 0.5
        
      
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent" }
        LOD 100
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
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            
            sampler2D _MaskTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float _Smoothness;
            float _Treshold;
            float _ScrollSpeed;
            float4 _Color;
            
           


            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                
                
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float inverseLerp(float v, float min, float max){ //support function
                return (v - min) / (max - min);
            }
            
            
            float remap(float v, float min, float max, float outMin, float outMax) {
            float t = inverseLerp(v, min, max);
            return lerp(outMin, outMax, t);
            }
            
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
 
                
                float2 uv = vertexToFragment.uv;
                float2 scrolledUv = vertexToFragment.uv;
                scrolledUv.y += _Time.y * -1 * _ScrollSpeed;
                
               // sample the texture
               
               float4 maskCol = tex2D(_MaskTex, uv);
               float4 noiseCol = tex2D(_NoiseTex, scrolledUv);
               
               float4 combined = maskCol.x * noiseCol.x;
               float4 sharpenedResult = inverseLerp(combined, _Treshold - _Smoothness, _Smoothness + _Smoothness );//Smoothness+Smoothness?
               sharpenedResult = saturate(sharpenedResult);//it clamps between 0,1
               
               return sharpenedResult * _Color;
               
               
                //fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                
            }
            ENDCG
        }
    }
}

