
Shader "ShaderCourse/Outline"
{
    //UI of the Shader
    Properties
    {
        _OutlineSize ("Outline Size", Float)  =  0.1                                                                                     
        _OutlineColor ("Outline Color", Color) = (0,59,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Front //Front= romove all facece facing me //Back would be Normal
            //ZTest Always //in depht testing instead of chiking if somthing in front/behind just always show
            //Zwrite OFF 
            
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
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                //push verticeec to normal direction
               float3 pushDirection = vertexData.normal * _OutlineSize;
              // float4 worldSpacePosition = mul(UNITY_MATRIX_M, vertexData.position); //only when wanna use world space

                vertexData.position.xyz += pushDirection; //xyz because fector 3 to 4 but we only care for xyz
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
