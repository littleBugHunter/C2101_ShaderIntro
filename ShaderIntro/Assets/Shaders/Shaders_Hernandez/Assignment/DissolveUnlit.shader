Shader "Unlit/DissolveUnlit"
{
    Properties {
    //visible inside unity
    _Color("Color", Color) = (1,1,1,0)
    _OutlineColor("OutlineColor", Color) = (1,1,1,0)
    _MyTexture ("MyTexture", 2D) = "black" {}
       // _MainTex ("Texture", 2D) = "white" {}
       
    _Treshold("Treshold", Range(0, 1) ) = 0.32
       
    }
    SubShader { //contains our Vertex and Fragment shader
        Tags { 
        
        "RenderType"="Opaque" 
        "Queue" = "Transparent" 
        
        }
        //Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off //two sided
        //ZWrite Off
        ZTest LEqual
        Blend One One //Blend types
     

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           

            #include "UnityCG.cginc" 
            #include "UnityLightingCommon.cginc"
            #include "AutoLight.cginc" 

            //Actual Mesh Data, like vertex positions, vertex normals etc, UVs, tangents, vertex colors
            //what data do you want from the mesh?
            struct VertexInput {
                float4 vertex : POSITION;               
                float4 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct VertexOutput {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : NORMAL;
                float3 worldPos : TEXCOORD2;
            };

            //--Variables--
            
            sampler2D _MyTexture;
            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            float4 _Color;
            float4 _OutlineColor;
          

           //Actual Vertex Shader
            VertexOutput vert ( VertexInput v) {
                
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                o.clipSpacePos = UnityObjectToClipPos( v.vertex );
                return o;
            }


            
            //Support Functions
            
            float inverseLerp(float v, float min, float max){ //support function
                return (v - min) / (max - min);
            }
            
            float remap(float v, float min, float max, float outMin, float outMax) {
            float t = inverseLerp(v, min, max);
            return lerp(outMin, outMax, t);
            }
            
            float clipSupport( float alph, float tresh){
            
            if(alph < tresh)
            {
                discard;
            }
            
            }

            
            //Actual Fragment Shader
            float4 frag ( VertexOutput o) : SV_Target {
            
                float2 uv = o.uv0;
                float3 normal = normalize(o.normal); //interpolated
                
                
                
                float3 noiseTexture = tex2D( _MyTexture, o.uv0 ).x; //.xyz for colors
                
                float _Smoothness = 0.08;
                float _Treshold = 0.32;
                float waveSize = 23;
                float waveSpeed = 3;
                
                float outlineThickness = 0.02f; //is actually a offset
                
          
                
                float shape = noiseTexture;
                //float shape = o.uv0.y;
                
                float waveAmplitude = (sin( shape * waveSize + _Time.y * waveSpeed ) + 1 ) * 0.5; //remapping sine
                //waveAmplitude *= Exampletexture; //stoppt flicker am rand
                
               float4 sharpenedResult = inverseLerp(noiseTexture, _Treshold - _Smoothness, _Smoothness + _Smoothness );//Smoothness+Smoothness?
               sharpenedResult = saturate(sharpenedResult);//it clamps between 0,1
                
                //dissolve outlines
                float3 outlineBase = waveAmplitude + outlineThickness;
                float3 outlines = step(noiseTexture, outlineBase) * _OutlineColor;
                
                
                //colors
                float3 effectColor = lerp(_Color, _OutlineColor, sharpenedResult);
                float4 effectGradient = lerp(_Color, _OutlineColor, o.uv0.y);
                float3 flickeringDissolve = lerp(_Color, _OutlineColor, waveAmplitude);
                
                
                
                
                
                
                float clipAlph = (sin(_Time.y) * 10 * shape);
                float waveAlph = (waveAmplitude * 2) + clipAlph;
                
                
               
                
                if(waveAlph < _Treshold)
            {
                discard;
            }
                
                //return waveAlph;
                return (waveAlph + 2 * float4(outlines, 0)) - _Color ;
         
                
               
                
                
                
                
                
            }
            ENDCG
        }
    }
}
