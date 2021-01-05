//Shader "Unlit/SimpleToonTwo"

Shader "ShaderCourse/SimpleToonTwo"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
        _SunDirection ("Sun Direction", Vector) = (0,1,0,0)
        _LightTreshold ("Light Treshold", Float) = 0 
        _Brightcolor ("Bright Color", Color) = (1,1,1,1)
        _Darkcolor ("Dark Color", Color) = (0,0,0,0)
    } 
    SubShader
    {
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
                float3 normal   : NORMAL; 
                float2 uv       : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float3  _SunDirection;
            float _LightTreshold;
            float3 _Brightcolor;
            float3 _Darkcolor;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.normal = vertexData.normal; 
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                float3 normal = normalize(vertexToFragment.normal);
                _SunDirection = normalize(_SunDirection);
                float dotProduct = dot(normal, _SunDirection ); //float or float3?
                
                float3 colorOfLight = (0,0,0);
                if(dotProduct > _LightTreshold){
                    colorOfLight = _Brightcolor;
                } else{
                    colorOfLight = _Darkcolor;
                }
                
                 
                 float3 texColor = tex2D(_MainTex, vertexToFragment.uv);
                 float3 col = texColor * colorOfLight;
                 return float4(col, 1);
                 // sample the texture
                //fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                //return col;
            }
            ENDCG
        }
    }
}
