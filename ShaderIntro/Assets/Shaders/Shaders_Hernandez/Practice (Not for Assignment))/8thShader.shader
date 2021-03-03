Shader "Unlit/8thShader"
{
    Properties {
    //visible inside unity
    _Color("Color", Color) = (1,1,1,0)
    _WaterShallow ("_WaterShallow", Color) = (1,1,1,1)
    _WaterDeep ("_WaterDeep", Color) = (1,1,1,1)
    _WaveColor ("_WaveColor", Color) = (1,1,1,1)
    
    _Gloss("Gloss", Range(1, 500) ) = 1
    _MyTexture ("MyTexture", 2D) = "black" {}
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
            
            sampler2D _MyTexture;
            
            float4 _Color;
            float _Gloss;
            uniform float3 _MousePos;
            
            float3 _WaterShallow;
            float3 _WaterDeep;
            float3 _WaveColor;

           
           //Actual Vertex Shader
            VertexOutput vert ( VertexInput v) {
                
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.worldPos = mul( unity_ObjectToWorld, v.vertex );
                o.clipSpacePos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            
            float Posterize( float steps, float value ){
                return floor( value * steps ) / steps;
            }
            
            
            //Actual Fragment Shader
            float4 frag ( VertexOutput o) : SV_Target {
                
                float3 Exampletexture = tex2D( _MyTexture, o.uv0 ).x; //.xyz for colors
                
                float waveSize = 23;
                float waveSpeed = 3;
                
                float shape = Exampletexture;
                //float shape = o.uv0.y;
                
                float waveAmplitude = (sin( shape * waveSize + _Time.y * waveSpeed ) + 1 ) * 0.5;
                waveAmplitude *= Exampletexture;
                
               
               float3 waterColor = lerp( _WaterDeep, _WaterShallow, Exampletexture );
               float3 waterWithWaves = lerp( waterColor, _WaveColor, waveAmplitude );
                
                return float4(waterWithWaves, 0 );

                //(sin( shape * waveSize + _Time.y * waveSpeed ) + 1 ) * 0.5;    moving stripes
                //(sin( shape / waveSize ) + 1 ) * 0.5;                 remapped sine + stripes 
                
                //Exampletexture + _Time.y
                // sin( o.uv0.y * 16 );
                 // sin( shape * waveSize );
                
                
   
                float dist = distance( _MousePos, o.worldPos );
                
                float glow = saturate(1 - dist);
                
                float2 uv = o.uv0;
                float3 normal = normalize(o.normal); //interpolated
                
                
                //Lighting
                
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb; 
                
                // Direct diffuse Light
                float lightFalloff = max(0, dot(lightDir, normal)); //-1 to 1  
                lightFalloff = Posterize(3, lightFalloff);
                float3 directDiffuseLight = lightColor * lightFalloff;
                
                //Ambient Light
                float3 ambientLight = float3(0.1, 0.1, 0.1);
                
                //Direct Specular Light
                float3 camPos = _WorldSpaceCameraPos;
                float3 fragToCam = camPos - o.worldPos;
                float3 viewDir = normalize(fragToCam);
                
                float3 viewReflect = reflect( -viewDir, normal);
                
                float specularFalloff = max( 0, dot( viewReflect, lightDir ) );
                
                
                //Modify Gloss
                specularFalloff = pow( specularFalloff, _Gloss );
                specularFalloff = Posterize(8, specularFalloff);
                
                float3 directSpecular = specularFalloff * lightColor;
 
                //Composite
                float3 diffuseLight =  ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular + glow;
                
                
                
                //float4(Exampletexture,0);
                //float4( finalSurfaceColor, 0);
                //frac(_Time.y);
            }
            ENDCG
        }
    }
}
