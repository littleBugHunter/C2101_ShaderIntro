Shader "Unlit/FireExperiment"

{
    //UI of the Shader
    Properties
    {
        
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
        
        _MaskTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Texture", 2D) = "white" {}
        _ScrollSpeed ("Scroll Speed" , Float) = 1
        _Smoothness ("Smoothness", Range(0,0.2)) = 0.1
        _Treshold ("Treshold", Range(0,1)) = 0.5
        
        //_InsideDirection ("Direction Inside", Vector) = (0,1,0)
        //_InsideColor("Inside Color", Color) = (0,0,1,0)
        //_Crispness ("_Crispness", Range(0,5)) = 2
        
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
            };

            sampler2D _MainTex;
            
            sampler2D _MaskTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float _Smoothness;
            float _Treshold;
            float _ScrollSpeed;
            float4 _Color;
            
            float3  _InsideDirection;
            float4 _InsideColor;
            float _Crispness;
            
            

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                //output.normal = vertexData.normal; //may cause trouble
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
                
                /* //only delete this
                
                float3 normal = normalize(vertexToFragment.normal);
                _InsideDirection = normalize(_InsideDirection);
                float dotProduct = dot(normal, _InsideDirection);
                float inverseDotProduct = dotProduct * (-1);
                //if dotProduct == 0, insideColorResult == InsideColor
               
                _InsideColor = _InsideColor + inverseDotProduct;
                /*
                for(int i, i= (-1), 1, , i+ 0.1){
                _InsideColor - (0.1, 0.1, 0.1, 0.1)
                } 
                */          
                
                float2 uv = vertexToFragment.uv;
                float2 scrolledUv = vertexToFragment.uv;
                scrolledUv.y += _Time.y * -1 * _ScrollSpeed;
                
               // sample the texture
               
               float4 maskCol = tex2D(_MaskTex, uv);
               float4 noiseCol = tex2D(_NoiseTex, scrolledUv);
               
               float4 combined = maskCol.x * noiseCol.x;
               float4 sharpenedResult = inverseLerp(combined, _Treshold - _Smoothness, _Treshold + _Smoothness);//Smoothness+Smoothness?
               sharpenedResult = saturate(sharpenedResult);//it clamps between 0,1
               
               return sharpenedResult * _Color; // + _InsideColor
               
               
              
                
            }
            ENDCG
        }
    }
}

