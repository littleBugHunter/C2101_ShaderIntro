Shader "Unlit/ToonLightingCode_Yassine"
{
    Properties
    {
        _MainTex("BaseMap", 2D) = "white" {}
        
        [HDR]
        _AmbientColor("AmbientColor", Color) = (0.5,0.5,0.5,1)

        _ShadowSmoothing("Shadow Smoothing", Float) = 0.01

        [HDR]
        _SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
        _GlossSharpness("Gloss", Float) = 32

        _LightSmoothing("Light Smoothing", Float) = 0.005

        [HDR]
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimLightStrength("Rim Light Strength", Range(0, 1)) = 0.7

        _RimThreshhold("Rim Threshhold", Range(0, 1)) = 0.1

        //Outline Support
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth("Outline Width", Range(0.01, 10)) = 0.01
    }

    CGINCLUDE
    #include "UnityCG.cginc"
    #include "Lighting.cginc"
    #include "AutoLight.cginc"
    
    struct VertexData
    {
        float4 position : POSITION; //Vertexposition
        float3 normal : NORMAL; //VertexNormal
        float2 uv : TEXCOORD0; //UVCoordinate
    };

    struct VertexToFragment
    {
        float2 uv : TEXCOORD0;
        float3 worldNormal : NORMAL;
        float4 vertex : SV_POSITION;
        float3 viewDirection : TEXCOORD1; //View Direction

        float4 color : COLOR; //Color
    };

    ENDCG

    SubShader
    {
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"

        LOD 100

        //Render Outline first
        Pass
        {
            Cull Front
        
            CGPROGRAM
            #pragma vertex Vertexshader
            #pragma fragment FragmentShader    
        
            float _OutlineWidth;
            float4 _OutlineColor;
        
            float4 FragmentShader(VertexToFragment vertexToFragment) : COLOR
            {
                return _OutlineColor;
            }
        
            VertexToFragment Vertexshader(VertexData vertexData)
            {
                float3 dir = normalize(vertexData.normal) * _OutlineWidth;
                
                vertexData.position.xyz += dir;
                
                VertexToFragment output;
                
                output.vertex = UnityObjectToClipPos(vertexData.position);
                
                //VertexToFragment output;
                //float3 worldNormal = normalize(mul(UNITY_MATRIX_M, vertexData.normal));
                //float3 dir = worldNormal * _OutlineWidth;
                //float4 worldSpacePos = mul(UNITY_MATRIX_M, vertexData.position);
                //vertexData.position.xyz += dir;
                //output.vertex = mul(UNITY_MATRIX_VP, worldSpacePos);

                return output;
            }
        
            ENDCG
        }

        //Rest of Object
        Pass
        {
            Tags
            {
                "RenderType" = "Opaque"
                "LightMode" = "UniversalForward"
                "PassFlags" = "OnlyDirectional"
            }

            ZWrite On

            CGPROGRAM
            #pragma vertex Vertexshader
            #pragma fragment FragmentShader

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            sampler2D _MainTex;
            
            float4 _AmbientColor;
            float _ShadowSmoothing;
            float _LightSmoothing;

            float _GlossSharpness;
            float4 _SpecularColor;

            float4 _RimColor;
            float _RimLightStrength;
            float _RimThreshhold;

            VertexToFragment Vertexshader (VertexData vertexData)
            {
                VertexToFragment output;
                output.vertex = UnityObjectToClipPos(vertexData.position);
                output.worldNormal = UnityObjectToWorldNormal(vertexData.normal);
                output.uv = vertexData.uv;

                //View direction
                output.viewDirection = WorldSpaceViewDir(vertexData.position);

                return output;
            }

            float4 FragmentShader(VertexToFragment vertexToFragment) : SV_Target
            {
                //Convert the normal into world normal, and calculate the dot product of that
                float3 normal = normalize(vertexToFragment.worldNormal);

                float DotProductLightAndNormal = dot(_WorldSpaceLightPos0, normal);

                //Include casted shadows
                float shadow = SHADOW_ATTENUATION(vertexToFragment);

                //smoothstep to smooth the edges
                float lightIntensity = smoothstep(0, _ShadowSmoothing, DotProductLightAndNormal * shadow);

                //Lightintensity * color of it
                float4 light = lightIntensity * _LightColor0;

                //Add highlight
                float3 viewDir = normalize(vertexToFragment.viewDirection);

                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float DotProductHalfVectorAndNormal = dot(normal, halfVector);

                //Specular intensity smoothing
                float specularIntensity = pow(DotProductHalfVectorAndNormal * lightIntensity, _GlossSharpness * _GlossSharpness);
                
                float smoothedSpecularIntensity = smoothstep(_LightSmoothing, _ShadowSmoothing, specularIntensity);
                float4 specular = smoothedSpecularIntensity * _SpecularColor;

                // sample the texture
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv);

                //Setting up Rim lighting
                float4 DotProductRimLight = 1 - dot(viewDir, normal);
                
                //Limit rim light to only light side
                float rimIntensity = DotProductRimLight * pow(DotProductLightAndNormal, _RimThreshhold);

                rimIntensity = smoothstep(_RimLightStrength - _ShadowSmoothing, _RimLightStrength + _ShadowSmoothing, rimIntensity);
                
                float4 rimLight = rimIntensity * _RimColor;

                return col * (light + specular + rimLight + _AmbientColor);
            }

            ENDCG
        }
    }
}
