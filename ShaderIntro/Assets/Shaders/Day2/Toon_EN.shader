Shader "Unlit/ToonEN" {
    Properties {
        _Threshold ("Threshold", float) = 0
        _LightColor ("LightColor", color) = (1, 1, 1, 1)
        _ShadowColor ("ShadowColor", color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader {
        Tags {
            "RenderType"="Opaque"
        }
        LOD 100

        Pass {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader

            #include "UnityCG.cginc"

            struct vertex_data {
                float4 position : POSITION;
                float4 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };

            struct vertex_to_fragment {
                float2 uv       : TEXCOORD0;
                float4 vertex   : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 main_tex_st;

            vertex_to_fragment vertex_shader(vertex_data vertex_data) {
                vertex_to_fragment output;
                output.vertex = UnityObjectToClipPos(vertex_data.position); // mul(UNITY_MATRIX_MVP, vertex_data.position)
                output.uv = vertex_data.uv;
                return output;
            }

            fixed4 fragment_shader(vertex_to_fragment vertex_to_fragment) : SV_Target {
                fixed4 color = tex2D(_MainTex, vertex_to_fragment.uv);
                return color;
            }
            ENDCG
        }
    }
}