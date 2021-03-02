
///////////////////////////////////////////////////
////////////////grass_struct.hlsl ////////////////
///////////////////////////////////////////////////

struct Attributes {
	float4 positionOS   : POSITION;
	float3 normal		: NORMAL;
	float4 tangent		: TANGENT;
	float2 texcoord     : TEXCOORD0;
	float2 uv			: TEXCOORD1;
	float2 uvWS			: TEXCOORD2;
};

struct Varyings {
	float4 positionOS   : SV_POSITION;
	float3 positionWS	: TEXCOORD1;
	float3 normal		: NORMAL;
	float4 tangent		: TANGENT;
	float2 uv			: TEXCOORD2;
	float2 uvWS			: TEXCOORD3;
};

struct GeometryOutput {
	float4 positionCS	: SV_POSITION;
	float3 positionWS	: TEXCOORD1;
	float2 uv			: TEXCOORD0;
};
