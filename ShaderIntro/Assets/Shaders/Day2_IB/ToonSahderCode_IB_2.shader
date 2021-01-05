Shader "Unlit/ToonSahderCode_IB_2"
{
    //UI of the Shader
    Properties
    {
        _MainTex 	("Texture", 2D) 	  = "white" {}
        _Color 		("A Color", Color)	  = (1,1,1,1)
        _Value 		("A Value", Float) 	  = 1
	_SunDirection	("Sun Direction",Vector)  =(0,1,0,0)
	_LightTreshhold	("LightTreshhold", Float) = 0
	_BrightColor 	("A Bright Color", Color) = (1,1,1,1)
	_DarkColor 	("A Dark Color", Color)   = (0,0,0,1)

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
		float3 normal 	: NORMAL;	//add in both fragment and vertex
                float2 uv     : TEXCOORD0;
            };

	//Variablen

            	sampler2D _MainTex;
            	float4 	_MainTex_ST;
		float3 	_SunDirection;
		float 	_LightTreshhold;
		float3 	_BrightColor;
		float3 	_DarkColor;


            VertexToFragment VertexShader_ ( VertexData vertexData )
            {
                VertexToFragment output;
                output.position = UnityObjectToClipPos(vertexData.position);
                output.uv = vertexData.uv;
		output.normal = vertexData.normal;
                return output;
            }
            
            // GPU IS DOING THINGS WITH THE DATA
            
            float4 FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                float3 normal = normalize(vertexToFragment.normal);
		_SunDirection = normalize(_SunDirection);
		float dotProduct = dot(normal,_SunDirection);
		
	
	
		float3 lightColor;
		if(dotProduct > _LightTreshhold){
			//true
			lightColor = _BrightColor;			
		}else{
			//false
			lightColor = _DarkColor;		
		}
		
		// sample the texture
                float3 texColor = tex2D(_MainTex, vertexToFragment.uv);
		float3 col = texColor * lightColor;
                return float4(col, 1); //first 3 will be col last one is alpha
            }
            ENDCG
        }
    }
}
