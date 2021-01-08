Shader "Unlit/Fire with Displacement"
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
                float4 Color    : COLOR;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

            sampler2D _MainTex;
            
            sampler2D _MaskTex;
            sampler2D _NoiseTex;
            sampler2D _DisplacementMap;
            
            float4 _MainTex_ST;
            
            float _Smoothness;
            float _Treshold;
            float _ScrollSpeed;
            float4 _Color;
            
            float _DisplacementAmount;
            //float4 _Time; //to get time values
            
           
 /* M-odel,       Transformation of Model
                   V-iew,        Everything but the camera is actually moving
                   P-rojection,  Every Frame
                
                */

            VertexToFragment VertexShader_ ( VertexData vertexData )
            { 
                VertexToFragment output;
                float3 worldNormal = mul(UNITY_MATRIX_M, vertexData.normal);
                float4 worldPosition = mul(UNITY_MATRIX_M, vertexData.position); //using worldspace
                
                
                float isFacingUp = dot(worldNormal, float3(0, 1, 0));
                isFacingUp = saturate(isFacingUp); // clamp between 0 and 1
                float3 displacementDirection = worldNormal; //vertexData.normal?
                
                float2 movingUVs = vertexData.uv;
                movingUVs.y += _Time.y * _ScrollSpeed;
                //worldPosition.xyz += float(0,1,0); //to fix double speed movement
                
                float4 displacementFactor = tex2Dlod(_MainTex, float4(movingUVs, 0, 0));
                displacementDirection *= displacementFactor * isFacingUp;
                
                float4 displacedPosition = worldPosition; //vertexData.position?
                displacedPosition.xyz += displacementDirection;
                
                output.position = mul(UNITY_MATRIX_VP, displacedPosition);
                output.uv = vertexData.uv; //*look above for meaning of MVP
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
                
                float2 uv = vertexToFragment.uv; //put uv into variable
                
                //Displacement
                float2 timeOffset = float2(0, _Time.x); //for time: normally use x pls
                float4 displacementCol = tex2D(_DisplacementMap, uv + timeOffset);
                float2 displacementDirection = displacementCol.xy + _DisplacementAmount;
                
               float2 displacedUv = uv + displacementDirection;
               
               
                float2 scrolledUv = vertexToFragment.uv; //movingUVs
                scrolledUv.y += _Time.y * -1 * _ScrollSpeed;// scrolledUv (origin)
                
               float4 maskCol = tex2D(_MaskTex, uv);
               float4 noiseCol = tex2D(_NoiseTex, scrolledUv);
               
               float4 combined = maskCol.x * noiseCol.x;
               float4 sharpenedResult = inverseLerp(combined, _Treshold - _Smoothness, _Smoothness + _Smoothness );//Smoothness+Smoothness?
               sharpenedResult = saturate(sharpenedResult);//it clamps between 0,1
               
               return sharpenedResult * _Color;
               
                
            }
            ENDCG
        }
    }
}

