﻿Shader "Unlit/GeoGrass"
{
		Properties {
			[Header(Material)] [Space]
			_Walls("Walls__Up_Down_Left_Right", Vector) = (0, 0, 1, 0)
			_Corners("Corners_TL_TR_BR_BL", Vector) = (0, 0, 0, 0)
			
			_CornerMult("CornerAdjustmentMult", Float) = 2
			
	        _GroundTex("GroundTex", 2D) = "white" {}
	        _GroundNormalTex("GroundNormalTex", 2D) = "bump" {}
			_GroundTiling("GroundTextureTiling", Float) = 0.2

	        _GrassTex("GrassTex", 2D) = "white" {}
	        _GrassNormalTex("GrassNormalTex", 2D) = "bump" {}
			_GrassTiling("GrassTextureTiling", Float) = 0.34
			
			_GrassStrength("GrassStrength", Float) = 4
			_BlendNoiseScale("TexBlendNoiseScale", Float) = 0.21
			_BlendNoiseMin("TexBlendNoiseMin", Float) = 0.2
			
			_Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5


			[Space(12)]
			[Header(Grass)]
			[Space]
						
			_Color("Colour", Color) = (1,1,1,1)
			_Color2("Colour2", Color) = (1,1,1,1)
			_Falloff("Falloff", Float) = 1
			_Width("Width", Float) = 1
			_RandomWidth("Random Width", Float) = 1
			_Height("Height", Float) = 1
			_RandomHeight("Random Height", Float) = 1
			_WindStrength("Wind Strength", Float) = 0.1
			[Space]
			_TessellationUniform("Tessellation Uniform", Range(1, 64)) = 1
			
			// Blending state
	        [HideInInspector] _Surface("__surface", Float) = 0.0
	        [HideInInspector] _Blend("__blend", Float) = 0.0
	        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
	        [HideInInspector] _SrcBlend("__src", Float) = 1.0
	        [HideInInspector] _DstBlend("__dst", Float) = 0.0
	        [HideInInspector] _ZWrite("__zw", Float) = 1.0
	        [HideInInspector] _Cull("__cull", Float) = 2.0
			
	        // Editmode props
			[HideInInspector] _QueueOffset("Queue offset", Float) = 0.0
		}

		SubShader {
			Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
			LOD 300

			//Ground
	        Pass
	        {
	            // "Lightmode" tag must be "UniversalForward" or not be defined in order for
	            // to render objects.
	            Name "StandardLit"
	            Tags{"LightMode" = "UniversalForward"}

	            Blend[_SrcBlend][_DstBlend]
	            ZWrite[_ZWrite]
	            Cull[_Cull]

	            HLSLPROGRAM
	            // Required to compile gles 2.0 with standard SRP library
	            // All shaders must be compiled with HLSLcc and currently only gles is not using HLSLcc by default
	            #pragma prefer_hlslcc gles
	            #pragma exclude_renderers d3d11_9x
	            #pragma target 2.0

	            // -------------------------------------
	            // Material Keywords
	            // unused shader_feature variants are stripped from build automatically
	            #pragma shader_feature _NORMALMAP


	            //HERE!!! 
	            //Remove this line if no normal maps are used
	            #define _NORMALMAP 1

	            
	            #pragma shader_feature _ALPHATEST_ON
	            #pragma shader_feature _ALPHAPREMULTIPLY_ON
	            #pragma shader_feature _EMISSION
	            #pragma shader_feature _METALLICSPECGLOSSMAP
	            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
	            #pragma shader_feature _OCCLUSIONMAP

	            #pragma shader_feature _SPECULARHIGHLIGHTS_OFF
	            #pragma shader_feature _GLOSSYREFLECTIONS_OFF
	            #pragma shader_feature _SPECULAR_SETUP
	            #pragma shader_feature _RECEIVE_SHADOWS_OFF

	            // -------------------------------------
	            // Universal Render Pipeline keywords
	            // When doing custom shaders you most often want to copy and past these #pragmas
	            // These multi_compile variants are stripped from the build depending on:
	            // 1) Settings in the LWRP Asset assigned in the GraphicsSettings at build time
	            // e.g If you disable AdditionalLights in the asset then all _ADDITIONA_LIGHTS variants
	            // will be stripped from build
	            // 2) Invalid combinations are stripped. e.g variants with _MAIN_LIGHT_SHADOWS_CASCADE
	            // but not _MAIN_LIGHT_SHADOWS are invalid and therefore stripped.
	            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
	            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
	            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
	            #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
	            #pragma multi_compile _ _SHADOWS_SOFT
	            #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE

	            // -------------------------------------
	            // Unity defined keywords
	            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
	            #pragma multi_compile _ LIGHTMAP_ON
	            #pragma multi_compile_fog

	            //--------------------------------------
	            // GPU Instancing
	            #pragma multi_compile_instancing

	            #pragma vertex LitPassVertex
	            #pragma fragment LitPassFragment

	            // Including the following two function is enought for shading with Universal Pipeline. Everything is included in them.
	            // Core.hlsl will include SRP shader library, all constant buffers not related to materials (perobject, percamera, perframe).
	            // It also includes matrix/space conversion functions and fog.
	            // Lighting.hlsl will include the light functions/data to abstract light constants. You should use GetMainLight and GetLight functions
	            // that initialize Light struct. Lighting.hlsl also include GI, Light BDRF functions. It also includes Shadows.

	            // Required by all Universal Render Pipeline shaders.
	            // It will include Unity built-in shader variables (except the lighting variables)
	            // (https://docs.unity3d.com/Manual/SL-UnityShaderVariables.html
	            // It will also include many utilitary functions. 
	            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

	            // Include this if you are doing a lit shader. This includes lighting shader variables,
	            // lighting and shadow functions
	            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

	            // Material shader variables are not defined in SRP or LWRP shader library.
	            // This means _BaseColor, _BaseMap, _BaseMap_ST, and all variables in the Properties section of a shader
	            // must be defined by the shader itself. If you define all those properties in CBUFFER named
	            // UnityPerMaterial, SRP can cache the material properties between frames and reduce significantly the cost
	            // of each drawcall.
	            // In this case, for sinmplicity LitInput.hlsl is included. This contains the CBUFFER for the material
	            // properties defined above. As one can see this is not part of the ShaderLibrary, it specific to the
	            // LWRP Lit shader.
	            #include "Extensions/LitInput.hlsl"

	            struct Attributes
	            {
	                float4 positionOS   : POSITION;
	                float3 normalOS     : NORMAL;
	                float4 tangentOS    : TANGENT;
	                float2 uv           : TEXCOORD0;
	                float2 uvLM         : TEXCOORD1;
	                UNITY_VERTEX_INPUT_INSTANCE_ID
	            };

	            struct Varyings
	            {
	                float2 uv                       : TEXCOORD0;
	                float2 uvLM                     : TEXCOORD1;
	                float4 positionWSAndFogFactor   : TEXCOORD2; // xyz: positionWS, w: vertex fog factor
	                half3  normalWS                 : TEXCOORD3;

	#if _NORMALMAP
	                half3 tangentWS                 : TEXCOORD4;
	                half3 bitangentWS               : TEXCOORD5;
	#endif

	#ifdef _MAIN_LIGHT_SHADOWS
	                float4 shadowCoord              : TEXCOORD6; // compute shadow coord per-vertex for the main light
	#endif
	                float4 positionCS               : SV_POSITION;
	                float2 uvWS						: TEXCOORD7;
	            };

	            Varyings LitPassVertex(Attributes input)
	            {
	                Varyings output;

	                // VertexPositionInputs contains position in multiple spaces (world, view, homogeneous clip space)
	                // Our compiler will strip all unused references (say you don't use view space).
	                // Therefore there is more flexibility at no additional cost with this struct.
	                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

	                // Similar to VertexPositionInputs, VertexNormalInputs will contain normal, tangent and bitangent
	                // in world space. If not used it will be stripped.
	                VertexNormalInputs vertexNormalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

	                // Computes fog factor per-vertex.
	                float fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

	                // TRANSFORM_TEX is the same as the old shader library.
	                output.uv = TRANSFORM_TEX(input.uv, _GroundTex);
	                output.uvLM = input.uvLM.xy * unity_LightmapST.xy + unity_LightmapST.zw;
	            	output.uvWS = mul(unity_ObjectToWorld, input.positionOS).xz;

	                output.positionWSAndFogFactor = float4(vertexInput.positionWS, fogFactor);
	                output.normalWS = vertexNormalInput.normalWS;

	                // Here comes the flexibility of the input structs.
	                // In the variants that don't have normal map defined
	                // tangentWS and bitangentWS will not be referenced and
	                // GetVertexNormalInputs is only converting normal
	                // from object to world space
	#ifdef _NORMALMAP
	                output.tangentWS = vertexNormalInput.tangentWS;
	                output.bitangentWS = vertexNormalInput.bitangentWS;
	#endif

	#ifdef _MAIN_LIGHT_SHADOWS
	                // shadow coord for the main light is computed in vertex.
	                // If cascades are enabled, LWRP will resolve shadows in screen space
	                // and this coord will be the uv coord of the screen space shadow texture.
	                // Otherwise LWRP will resolve shadows in light space (no depth pre-pass and shadow collect pass)
	                // In this case shadowCoord will be the position in light space.
	                output.shadowCoord = GetShadowCoord(vertexInput);
	#endif
	                // We just use the homogeneous clip position from the vertex input
	                output.positionCS = vertexInput.positionCS;
	                return output;
	            }

	            half4 LitPassFragment(Varyings input) : SV_Target
	            {
	                // Surface data contains albedo, metallic, specular, smoothness, occlusion, emission and alpha
	                // InitializeStandarLitSurfaceData initializes based on the rules for standard shader.
	                // You can write your own function to initialize the surface data of your shader.

	            	//return BlendMap(input.uv);
	                SurfaceData surfaceData;
	                InitializeStandardLitSurfaceData(input.uv, input.uvWS, surfaceData);


	#if _NORMALMAP
	                half3 normalWS = TransformTangentToWorld(surfaceData.normalTS,half3x3(input.tangentWS, input.bitangentWS, input.normalWS));
	#else
	                half3 normalWS = input.normalWS;
	#endif
	                normalWS = normalize(normalWS);
	            	
	#ifdef LIGHTMAP_ON
	                // Normal is required in case Directional lightmaps are baked
	                half3 bakedGI = SampleLightmap(input.uvLM, normalWS);
	#else
	                // Samples SH fully per-pixel. SampleSHVertex and SampleSHPixel functions
	                // are also defined in case you want to sample some terms per-vertex.
	                half3 bakedGI = SampleSH(normalWS);
	#endif

	                float3 positionWS = input.positionWSAndFogFactor.xyz;
	                half3 viewDirectionWS = SafeNormalize(GetCameraPositionWS() - positionWS);

	                // BRDFData holds energy conserving diffuse and specular material reflections and its roughness.
	                // It's easy to plugin your own shading fuction. You just need replace LightingPhysicallyBased function
	                // below with your own.
	                BRDFData brdfData;
	                InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

	                // Light struct is provide by LWRP to abstract light shader variables.
	                // It contains light direction, color, distanceAttenuation and shadowAttenuation.
	                // LWRP take different shading approaches depending on light and platform.
	                // You should never reference light shader variables in your shader, instead use the GetLight
	                // funcitons to fill this Light struct.
	#ifdef _MAIN_LIGHT_SHADOWS
	                // Main light is the brightest directional light.
	                // It is shaded outside the light loop and it has a specific set of variables and shading path
	                // so we can be as fast as possible in the case when there's only a single directional light
	                // You can pass optionally a shadowCoord (computed per-vertex). If so, shadowAttenuation will be
	                // computed.
	                Light mainLight = GetMainLight(input.shadowCoord);
	#else
	                Light mainLight = GetMainLight();
	#endif

	                // Mix diffuse GI with environment reflections.
	                half3 color = GlobalIllumination(brdfData, bakedGI, surfaceData.occlusion, normalWS, viewDirectionWS);

	                // LightingPhysicallyBased computes direct light contribution.
	                color += LightingPhysicallyBased(brdfData, mainLight, normalWS, viewDirectionWS);

	                // Additional lights loop
	#ifdef _ADDITIONAL_LIGHTS

	                // Returns the amount of lights affecting the object being renderer.
	                // These lights are culled per-object in the forward renderer
	                int additionalLightsCount = GetAdditionalLightsCount();
	                for (int i = 0; i < additionalLightsCount; ++i)
	                {
	                    // Similar to GetMainLight, but it takes a for-loop index. This figures out the
	                    // per-object light index and samples the light buffer accordingly to initialized the
	                    // Light struct. If _ADDITIONAL_LIGHT_SHADOWS is defined it will also compute shadows.
	                    Light light = GetAdditionalLight(i, positionWS);

	                    // Same functions used to shade the main light.
	                    color += LightingPhysicallyBased(brdfData, light, normalWS, viewDirectionWS);
	                }
	#endif

	                float fogFactor = input.positionWSAndFogFactor.w;

	                // Mix the pixel color with fogColor. You can optionaly use MixFogColor to override the fogColor
	                // with a custom one.
	                color = MixFog(color, fogFactor);
	                return half4(color, surfaceData.alpha);
	            }
	            ENDHLSL
	        }
			
			//Grass
			Pass 
			{
				Name "GrassPass"
				//Tags {"LightMode" = "UniversalForward"}

				HLSLPROGRAM
				// Required to compile gles 2.0 with standard srp library
				#pragma prefer_hlslcc gles
				#pragma exclude_renderers d3d11_9x gles
				#pragma target 4.5

				#pragma require geometry

				#pragma vertex vert
				#pragma geometry geom
				#pragma fragment frag
				#pragma hull hull
				#pragma domain domain

				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				#pragma multi_compile _ _SHADOWS_SOFT

				// Defines

				#define BLADE_SEGMENTS 1

				// Includes

				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				#include "Extensions/GrassStructs.hlsl"
				#include "Extensions/CustomTessellation.hlsl"
				#include "Extensions/grass.hlsl"

				// Fragment

				float4 frag(GeometryOutput input) : SV_Target {
					//#if SHADOWS_SCREEN
						float4 clipPos = TransformWorldToHClip(input.positionWS);
						float4 shadowCoord = ComputeScreenPos(clipPos);
					//return shadowCoord;
					//#else
						//float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
					//#endif

					Light mainLight = GetMainLight(shadowCoord);
					
					if (mainLight.shadowAttenuation < 0.5)
					{
						return lerp(_Color, _Color2, input.uv.y) * (mainLight.shadowAttenuation+0.5);    // ORIGINAL /W SHADOW
				    }

					return lerp(_Color, _Color2, input.uv.y) * mainLight.shadowAttenuation;    // ORIGINAL /W SHADOW
				}

				ENDHLSL
			}

			// Used for rendering shadowmaps
			UsePass "Universal Render Pipeline/Lit/ShadowCaster"

	        // Used for depth prepass
	        // If shadows cascade are enabled we need to perform a depth prepass. 
	        // We also need to use a depth prepass in some cases camera require depth texture
	        // (e.g, MSAA is enabled and we can't resolve with Texture2DMS
			UsePass "Universal Render Pipeline/Lit/DepthOnly"

			// Used for Baking GI. This pass is stripped from build.
			UsePass "Universal Render Pipeline/Lit/Meta"
    }
}