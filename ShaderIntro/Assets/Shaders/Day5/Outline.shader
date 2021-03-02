
Shader "ShaderCourse/Trans"
{
    //UI of the Shader
    Properties
    {
        _OutlineSize("SIze",Float)=0.1
        _OutlineColor("Color",Color)=(0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Front
            
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
            float _OutlineSize;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                float3 displaceDir = vertexData.normal * _OutlineSize;
                vertexData.position.xyz += displaceDir;
                output.position = UnityObjectToClipPos(vertexData.position);
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
