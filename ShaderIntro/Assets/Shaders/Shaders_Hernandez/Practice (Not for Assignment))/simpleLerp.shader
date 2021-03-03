Shader "Unlit/simpleLerp"
{
    Properties {
    //visible inside unity
    _Color("Color", Color) = (1,1,1,0)
    _Gloss("Gloss", Range(1, 500) ) = 1
       // _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader { //contains our Vertex and Fragment shader
        Tags { "RenderType"="Opaque" }
     

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
            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            float4 _Color;
            float _Gloss;

           
           //Actual Vertex Shader
            VertexOutput vert ( VertexInput v) {
                
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                o.clipSpacePos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            
            float3 MyLerp( float3 a, float3 b, float t ){
            
            return t * b + (1.0 - t)*a;
            }
            
            float3 MyInvLerp( float3 a, float3 b, float value ){
            
            return (value - a)/(b-a);
            }
            
            
            float Posterize( float steps, float value ){
                return floor( value * steps ) / steps;
            }
            
            
            //Actual Fragment Shader
            float4 frag ( VertexOutput o) : SV_Target {
       
                float2 uv = o.uv0;
                
                float3 colorA = float3(0.1, 0.8, 1);
                float3 colorB = float3(1, 0.1, 0.8);
                float t = uv.y;
                
                t = Posterize(16, t);
                //t = round( t * 8 ) / 8;
                
                //float t = MyInvLerp( 0.25, 0.75, uv.y );
                //float t = smoothstep( 0.25, 0.75, uv.y );  
                
                float3 blend = MyLerp(colorA, colorB, t); // äquivalent zu lerp(a,b,t)
                


                
                return float4(blend,0);//return float4 ( finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
