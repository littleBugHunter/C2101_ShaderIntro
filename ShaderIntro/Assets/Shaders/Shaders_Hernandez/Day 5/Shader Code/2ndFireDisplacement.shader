Shader "Unlit/2ndFireDisplacement"
{
    //UI of the Shader
    Properties
    {
        
        _DirectionInner ("Inner Color Direction", Vector) = (0,1,0,0)
        
        _Color ("A Color", Color) = (1,1,1,1)
        _Darkcolor ("Dark Color", Color) = (0,0,0,0)
        
        _ScrollSpeed ("Scroll Speed", Range(0, 1)) = 0.5
        _Value ("A Value", Float) = 1
        
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Smoothness ("_Smoothness", Range(0,0.2)) = 0.1
        
        _MovementStrength ("Movement Strength", Range(0,0.2)) = 0.1
        _OffsetStrength ("Offset Strength", Range(0,3)) = 1
        
       
        
      
        
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent" } //render queue
        LOD 100
        Blend One One //blendmode

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION;
                float3 normal   : NORMAL; //for working with normals
                float2 uv       : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal   : NORMAL; // for working with normals
                
            };

            //variables
            
            sampler2D _MainTex;
            
            sampler2D _MaskTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            
            float _Smoothness;
            float _Treshold;
            float _ScrollSpeed;
            
            float3 _DirectionInner;
            
            float4 _Color;
            float3 _Darkcolor;
            float3 _Brightcolor;
            
            float _MovementStrength;
            float _OffsetStrength;
            float3 horizon = (1,0,0);
           


            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;

                float3 normal = normalize(vertexData.normal);
                float Dot = dot(normal, horizon);
                float movementFactor;
                
                if(Dot >= 0){
                
                movementFactor = 1;
               
                } 
                else{
                 movementFactor = 0;
                }
               
                
                //float movement = (sin(vertexData.uv.y - _Time.y * _ScrollSpeed)) * _MovementStrength;
                float waveMovement = sin( _Time.y * _ScrollSpeed + vertexData.position.y * _OffsetStrength) * _MovementStrength;
                
                vertexData.position.x += waveMovement * movementFactor;
                
                
                output.position = UnityObjectToClipPos(vertexData.position);
                output.normal = vertexData.normal; //for dot product stuff
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
                
                //inner gradient
                float3 normal = normalize(vertexToFragment.normal);
                _DirectionInner = normalize(_DirectionInner);
                float dotProduct = dot(normal, _DirectionInner );
                
                float3 colorOfLight = float3(0,0,0);
                colorOfLight =  (_Darkcolor * dotProduct) + (1 - dotProduct) * _Brightcolor;
                
                //make things move
                
                float2 uv = vertexToFragment.uv;
                float2 scrolledUv = vertexToFragment.uv;
                scrolledUv.y += _Time.y * -1 * _ScrollSpeed;
                
               // sample the texture
               
               float4 maskCol = tex2D(_MaskTex, uv);
               float4 noiseCol = tex2D(_NoiseTex, scrolledUv);
               
               float4 combined = maskCol.x * noiseCol.x;
               float4 sharpenedResult = inverseLerp(combined, _Treshold - _Smoothness, _Smoothness + _Smoothness );//Smoothness+Smoothness?
               sharpenedResult = saturate(sharpenedResult)+ float4 (colorOfLight, 1);//it clamps between 0,1
               
               return sharpenedResult * _Color + float4 (colorOfLight, 1); //+ float4 (colorOfLight, 1)
               
               
                //fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                
            }
            ENDCG
        }
    }
}

