// Lava shader by Striker
uniform float timer;

vec4 getTexelWrapped(vec2 coord)
{
	return texture2DGrad(tex, fract(coord), dFdx(coord), dFdy(coord));
}

float map(float value, float min1, float max1, float min2, float max2)
{
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec4 Process(vec4 color)
{
	const float pi = 3.14159265358979323846;
	float gray;

	vec2 u = gl_TexCoord[0].st;
	vec2 u_base = u;
	
	vec4 baseColor = vec4(0.0, 0.0, 0.25, 1.0);
	vec4 peakColor = vec4(0.5, 0.125, 0.4, 1.0);

	vec2 offset = vec2(0,0);

	float siny = sin(pi * 2.0 * (u.y * 2.2 + timer * 1.75)) * 0.003;
	offset.y = siny + sin(pi * 2.0 * (u.x * 0.75 + timer * 1.75)) * 0.003;
	offset.x = siny + sin(pi * 2.0 * (u.x * 1.1 + timer * 1.45)) * 0.002;
	u = u_base + offset;

	vec4 f = getTexelWrapped(u);
	gray = (f.r * 0.3 + f.g * 0.56 + f.b * 0.14);

	f.r = map(sin(gray*8.0 + timer), -1.0, 1.0, 0.0, 1.0);
	vec4 newColor1 = mix(baseColor, peakColor, pow(f.r*1.125, 8.0));

	siny = sin(pi * 2.0 * (u.y * 2.2 + timer * 1.75)) * 0.003;
	offset.y = siny + sin(pi * 2.0 * (u.x * 0.75 + timer * 1.75)) * 0.003;
	offset.x = siny + sin(pi * 2.0 * (u.x * 1.1 + timer * 1.45)) * 0.002;
	u = -u_base + offset;

	f = getTexelWrapped(-u);
	gray = (f.r * 0.3 + f.g * 0.56 + f.b * 0.14);
	
	f.r = map(-sin(gray*8.0 + timer), -1.0, 1.0, 0.0, 1.0);
	vec4 newColor2 = mix(baseColor, peakColor, pow(f.r*1.125, 8.0));

	return newColor1 + newColor2;
}