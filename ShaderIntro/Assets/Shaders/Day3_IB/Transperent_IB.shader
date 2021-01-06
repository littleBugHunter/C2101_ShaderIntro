Shader "Unlit/Transperent_IB"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("A Color", Color) = (1,1,1,1)
        _Value ("A Value", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Transparent" }	 //Changing the 
        LOD 100
		ZWrite OFF 						//needed for transparent shaders //makes objets transparent hase something to do how Unity/graphi cards sees objects (Bob Ross Painter Method)
		Blend One One					//Blend mode you want look up on unity scripting API DEpending on combination it changes how unity persives the shader 

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

            sampler2D _MainTex;
            float4 _MainTex_ST;

            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv);
                return col;
            }
            ENDCG
        }
    }
}
