Shader "ShaderCourse/OutlineShader_LP"

{
    //UI of the Shader
    Properties
    {
        _OutlineSize ("Outline Size", float) = 0.1
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" } // {"RenderType"="Opaque" "Queue"="Geometry+100"} // To adjust its renderqueue by default
        LOD 100

        Pass
        {
            Cull Front
            ZTest Always // Greater / Equal / LEqual / Always 
                            // Always render the outline even if something is in front of it --> set renderqueue higher than possible obstacles displayed in front of it. 
                            // Set outlined object's Material RQueue even higher.
            
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
            };
            
            float4 _OutlineColor;
            float _OutlineSize;

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