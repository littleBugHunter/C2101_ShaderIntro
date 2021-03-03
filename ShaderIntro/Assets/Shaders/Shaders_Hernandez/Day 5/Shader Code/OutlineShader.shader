Shader "Unlit/OutlineShader"

{
    //UI of the Shader
    Properties
    {
        
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _OutlineSize ("Outline Size", Float) = 0.1
    }
    SubShader
    {
        Cull Front
    
        Tags { "RenderType"="Opaque" }
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
                float2 uv       : TEXCOORD0;
            };

            struct VertexToFragment
            {
                float4 position : SV_POSITION;
                float2 uv     : TEXCOORD0;
            };

            float _OutlineSize;
            float4 _OutlineColor;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                float3 pushDirection = vertexData.normal * _OutlineSize;
                vertexData.position.xyz += pushDirection;
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
