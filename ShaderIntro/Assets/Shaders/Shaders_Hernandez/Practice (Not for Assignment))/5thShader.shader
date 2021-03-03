Shader "Unlit/5thShader"
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

            
            //Actual Fragment Shader
            float4 frag ( VertexOutput o) : SV_Target {
                
                
                
                float2 uv = o.uv0;
                float3 normal = normalize(o.normal); //interpolated
                
                
                //Lighting
                
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb; 
                
                // Direct diffuse Light
                float lightFalloff = max(0, dot(lightDir, normal)); //-1 to 1  
                lightFalloff = step(0.1, lightFalloff);
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
                specularFalloff = step(0.1, specularFalloff);
                
                float3 directSpecular = specularFalloff * lightColor;
 
                //Composite
                float3 diffuseLight =  ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular;
                
                return float4 ( finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
