Shader "Unlit/UnlitPractice"
{
    Properties {
       // _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader { //contains our Vertex and Fragment shader
        Tags { "RenderType"="Opaque" }
     

        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           

            #include "UnityCG.cginc" 

            //Actual Mesh Data, like vertex positions, vertex normals etc, UVs, tangents, vertex colors
            //what data do you want from the mesh?
            struct VertexInput {
                float4 vertex : POSITION;
                //float4 colors : COLOR;
                float4 normal : NORMAL;
                //float4 tangent : TANGENT;
                float2 uv0 : TEXCOORD0;
                //float2 uv1 : TEXCOORD1;
            };

            struct VertexOutput {
                float4 clipSpacePos : SV_POSITION;
                float2 uv0 : TEXCOORD0;
                float3 normal : NORMAL;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;

           
           //Actual Vertex Shader
            VertexOutput vert ( VertexInput v) {
                
                VertexOutput o;
                o.uv0 = v.uv0;
                o.normal = v.normal;
                o.clipSpacePos = UnityObjectToClipPos( v.vertex );
                return o;
            }

            float4 frag ( VertexOutput o) : SV_Target {
                
                float2 uv = o.uv0;
                
                float3 lightDir = normalize( float3(1, 1, 1) );
                float lightFalloff = dot(lightDir, o.normal); //-1 to 1
                
                float3 lightCol = float3(0.5, 0.4, 0.9);
                
                
                //one way to remap: float3 normal = o.normal * 0.5 + 0.5; //0 to 1
                
                //for uv colors: return float4( uv.x, 0, 0 );
                //for uv x-coordinates: return float4( uv.xxx, 0 );
                //for uv y-coordinates: return float4( uv.yyy, 0 );
                // to display normals: return float4( normal, 0 );
                return float4( lightCol * lightFalloff, 0 );
            }
            ENDCG
        }
    }
}
