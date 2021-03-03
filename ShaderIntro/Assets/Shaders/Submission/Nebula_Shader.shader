Shader "Unlit/Nebula_Shader" {

    Properties{
        // Variablen in Unity
        _Cube("Reflection Map", Cube) = "" {}
        _FresnelColor("Fresnel Color", Color) = (1,1,1,1)
        _FresnelPower("Fresnel Power", Float) = 5
        _RotationAxis("Rotation Axis", Vector) = (1,1,1)
        _RotationSpeed("Rotation Speed", Float) = 1
    }
        SubShader{
           Pass {
              CGPROGRAM
              #pragma vertex VertexShader_  
              #pragma fragment FragmentShader
              #include "UnityCG.cginc"

              uniform samplerCUBE _Cube;

              struct VertexData {
                 float4 vertex      : POSITION;
                 float3 normal      : NORMAL;
                 float2 uv          : TEXCOORD0;
              };
              struct VertexToFragment {
                 float4 pos : SV_POSITION;
                 float3 normalDir : TEXCOORD0;
                 float3 viewDir : TEXCOORD1;
                 float fresnel : TEXCOORD2;
              };

              float _FresnelPower;
              float4 _FresnelColor;
              float3 _RotationAxis;
              float _RotationSpeed;

              VertexToFragment VertexShader_(VertexData vData)
              {
                 VertexToFragment output;

                 // Cubemap Variablen
                 float4x4 modelMatrix = unity_ObjectToWorld;
                 float4x4 modelMatrixInverse = unity_WorldToObject;

                 float3 viewDirection = normalize(WorldSpaceViewDir(vData.vertex));

                 // Cubemap für Worldspace
                 output.viewDir = mul(modelMatrix, vData.vertex).xyz - _WorldSpaceCameraPos;
                 output.normalDir = normalize(mul(float4(vData.normal, 0.0), modelMatrixInverse).xyz);

                 output.pos = UnityObjectToClipPos(vData.vertex);

                 // Rotation der Cubemap 
                 float Rotation = _RotationSpeed * _Time.x;
                 float s = sin(Rotation);
                 float c = cos(Rotation);
                 float one_minus_c = 1.0 - c;
                 
                 float3 Axis = normalize(_RotationAxis);
                 
                 // Rotations Math
                 float3x3 rot_mat =
                 { one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
                     one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
                     one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
                 };
                 output.viewDir = mul(rot_mat, viewDirection);

                 // Fresnel Effekt auf der Waffe
                 output.fresnel = pow((1.0 - saturate(dot(normalize(vData.normal), normalize(viewDirection)))), _FresnelPower);

                 return output;
              }

              float4 FragmentShader(VertexToFragment fData) : COLOR
              {
                 // Cubemap Reflection
                 float3 reflectedDir = reflect(fData.viewDir, normalize(fData.normalDir));
                 
                 // Zwischenspeichern für Lerp
                 float4 buffer = texCUBE(_Cube, reflectedDir);

                 // Anwenden des Fresnel Effekts durch Lerp
                 return lerp(buffer, _FresnelColor, fData.fresnel);
              }

              ENDCG
           }
    }
}