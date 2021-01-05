﻿Shader "Unlit/ToonLightingCode_IB" //Shader Name and where to find it
{
    Properties //what shows up in inpsector //UI of shader
    {
        _MainTex ("Texture", 2D) = "white" {} 		//("NameOF Category, 2d(=you have a 2d texture)
	_MainTex ("A Color", Color) = (1,0,0,1) 	//you can put stuff behind the name, when use Color you need to use rgb
	_MainTex ("A Value ", Range(0,1)) = 0		//create a slider //float would create float, int would get Int
	_MainTex ("A Vector", Vector) = (0,0,0,0)	//create vector you can do mor look online

    }

    SubShader 		//when you have shader that behave similary (not in beginner course) used for fallbac solutions(when player hase shit graphisc card so he hase a less awsome version(crossplaform game or sclae well for multipel computers .o.
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass 	//not sure what this does
        {
            CGPROGRAM 				//CG = Meta Languag on top of Meta Language //Basically pic coding language for shadrs GSL (other language)
            #pragma vertex VertexShader_			//pragam send to complier basiclay setting names to variables //should be vertexSahder btut this is  a key word
            #pragma fragment FragmentShader
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"		//

            struct VertexData			//Struct = kinda like a class (!!can not have funktions only values !!)
            {
                float4 vertex 	: POSITION;
		float3 normal 	: NORMAL;
                float2 uv 	: TEXCOORD0;
            };


            struct VertexToFragment
            {
                float2 uv 	: TEXCOORD0; 
                float4 vertex 	: SV_POSITION;
            }; //Semicolon at end of stetment


	    
            sampler2D _MainTex; //dealing with texture stuff
            float4 _MainTex_ST;



            VertexToFragment VertexShader_ (VertexData vertexData)
            {
                VertexToFragment output;

		//output.vertex = mul(UNITY_MATRIX_MVP, vertexData-position);     //unity does not like this line           
		output.vertex = UnityObjectToClipPos(vertexData.vertex);
 

                // output.uv = TRANSFORM_TEX(vertexData.uv, _MainTex); 
		//uised internantl funktions so we do it our self
		output.uv = vertexData.uv;

                UNITY_TRANSFER_FOG(o,o.vertex);

                return output;
            };


//graphis card does stuff 

            float FragmentShader (VertexToFragment vertexToFragment) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, vertexToFragment.uv); //sampel texture apply to right point

                // apply fog //we dont want fog its confusing
                //UNITY_APPLY_FOG(vertexToFragment.fogCoord, col);

                return col;
            };

            ENDCG
        }
    }
}
