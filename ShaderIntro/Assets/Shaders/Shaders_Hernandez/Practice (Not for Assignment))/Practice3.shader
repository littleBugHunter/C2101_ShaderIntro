Shader "Unlit/Practice3"
{
    Properties {
    
    _Color("Color", Color) = (1,1,1,0)
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
            };

            //--Variables--
            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            float4 _Color;

           
           //Actual Vertex Shader
            VertexOutput vert ( VertexInput v) {
                
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.clipSpacePos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            
            //Actual Fragment Shader
            float4 frag ( VertexOutput o) : SV_Target {
                
                //return _Color;
                
                float2 uv = o.uv0;
                
                
                //Lighting
                
                // Direct Light
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb; 
                float lightFalloff = max(0, dot(lightDir, o.normal)); //-1 to 1  
                float3 directDiffuseLight = lightColor * lightFalloff;
                
                //Ambient Light
                float3 ambientLight = float3(0.1, 0.1, 0.1);
                
                
                //Composite Light
                float3 diffuseLight =  ambientLight + directDiffuseLight;
                float3 finalSurfaceColor = diffuseLight * _Color.rgb;
                
                return float4 ( finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
