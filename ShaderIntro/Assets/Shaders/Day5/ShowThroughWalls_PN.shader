// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "ShaderCourse/Show Through Walls"
{
    //UI of the Shader
    Properties
    {
        _OutlineSize ("Outline Size", Float) = 0.1
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent+100" }
        LOD 100

        Pass
        {
            ZTest Greater //  Inverted Z Test  
            ZWrite Off
            
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

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                // Push the Vertices in the normal direction
                output.position = UnityObjectToClipPos(vertexData.position);
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
