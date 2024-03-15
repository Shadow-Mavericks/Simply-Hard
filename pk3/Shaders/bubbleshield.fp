uniform float timer;

vec4 Process(vec4 color)
{
	vec2 baseTex = gl_TexCoord[0].st;
	
	// Warp
	vec2 offset = vec2(0,0);
	const float pi = 3.14159265358979323846;
	offset.y = sin(pi * 2.0 * (baseTex.x + timer * 0.25)) * 0.1;
	offset.x = sin(pi * 2.0 * (baseTex.y + timer * 0.25)) * 0.1;
	baseTex += offset;

	// Scroll
	baseTex.y += timer * 0.5;

	vec4 finalTexel = getTexel(baseTex);

	return finalTexel * color;
}