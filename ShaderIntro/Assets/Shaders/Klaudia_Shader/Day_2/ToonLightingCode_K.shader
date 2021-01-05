Shader "Unlit/ToonLightingCode"
{
    //UI of the Shader
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100 //shader quality, complex shaders

        Pass //place for actual code
        {
            CGPROGRAM
            #pragma vertex vert //name for vertexshader
            #pragma fragment frag //name for fragmentshader
            // make fog work
            //#pragma multi_compile_fog <- not using fog rn

            #include "UnityCG.cginc" //including utility function to communicate with unity

            struct appdata //structs are similar to classes, they cannot have functions, they only hold values and variables, user for passing data from 
            //one point to another, sends information to "v2f vert (appdata v)" further down
            {
                //     name     type
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f //"VertexToFragment" 
            {
                float2 uv : TEXCOORD0;
               // UNITY_FOG_COORDS(1)   <- dedicated to fog, not useful rn 
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex; //texture including configurations like wrapping, type etc.
            float4 _MainTex_ST;

            v2f vert (appdata v) //"VertexToFragment" VertexShader 
            {
                v2f o; //o = "output"
                o.vertex = UnityObjectToClipPos(v.vertex); //mvp matrix? "v" = vertexdata
                o.uv = /*TRANSFORM_TEX(v.uv, _MainTex);*/ v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            //GPU is doing things with the data
            //fixed4 is equal to float 4
            fixed4 frag (v2f i) : SV_Target //fragmentshader, i = input
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                /*UNITY_APPLY_FOG(i.fogCoord, col);*/
                return col;
            }
            ENDCG
        }
    }
}
