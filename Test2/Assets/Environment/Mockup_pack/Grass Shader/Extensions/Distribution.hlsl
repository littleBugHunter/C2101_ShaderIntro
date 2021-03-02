//Noise
float2 unity_gradientNoise_dir(float2 p)
{
    p = p % 289;
    float x = (34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

float unity_gradientNoise(float2 p)
{
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(unity_gradientNoise_dir(ip), fp);
    float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
}

float BlendMap(float2 uv, float2 uvWS)
{
    half u = uv.r - 0.5;
    half v = uv.g - 0.5;
    half4 sides = half4(max(u * -1, 0), max(u, 0), max(v * -1, 0), max(v, 0));
    half4 corners = half4(sides.r * sides.b, sides.g * sides.b, sides.g * sides.a, sides.r * sides.a) * _CornerMult * _Corners;
    half4 walls = half4(sides.b, sides.a, sides.r, sides.g) * _Walls;
    half output = min(walls.r + walls.g + walls.b + walls.a + corners.r + corners.g + corners.b + corners. a, 1) * _GrassStrength;

    half noise = unity_gradientNoise(uvWS * _BlendNoiseScale) + 0.5 + _BlendNoiseMin;
    
    return saturate(output * noise);
}