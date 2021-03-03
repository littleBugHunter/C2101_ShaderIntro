
Shader "ShaderCourse/Outline"
{
    //UI of the Shader
    Properties
    {
        _OutlineSize ("Outline Size", Float) = 0.1
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"}
        
        Cull Front
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex VertexShader_
            #pragma fragment FragmentShader

            #include "UnityCG.cginc"

            struct VertexData
            {
                float4 position : POSITION;
                float3 normal   : NORMAL;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
            };
            
            float4 _OutlineColor;
            float  _OutlineSize;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                // Push the Vertices in the normal direction
                float3 worldNormal = normalize(mul(UNITY_MATRIX_M, vertexData.normal));
                float3 pushDirection = worldNormal * _OutlineSize;
                float4 worldPosition = mul(UNITY_MATRIX_M, vertexData.position);
                worldPosition.xyz += pushDirection;
                output.position = mul(UNITY_MATRIX_VP, worldPosition);
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
