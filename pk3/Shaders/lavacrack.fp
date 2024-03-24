// Lava crack shader by Striker
uniform float timer;

vec4 getTexelNoMip(vec2 coord)
{
	return texture2DLod(tex, coord, 0.0);
}

float map(float value, float min1, float max1, float min2, float max2)
{
	return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

vec4 Process(vec4 color)
{
	vec2 coord = gl_TexCoord[0].st;

	// Sample first half of texture and repeat it.
	coord.x = mod(coord.x, 0.3333333333333333);
	coord.x += 0.0833333333333333;
	
	// Sample second half of texture.
	vec2 coord2 = coord;
	coord2.x += 0.5;
	
	// Get result
	vec4 baseTexel = getTexelNoMip(coord);
	vec4 brightTexel = mix(vec4(0.0, 0.0, 0.0, 0.0), getTexelNoMip(coord2), map(sin(timer*2.0), -1.0, 1.0, 0.0, 1.0));
	
	vec4 finalTexel = (baseTexel*color)+brightTexel;
	finalTexel.a = baseTexel.a;
	
	return finalTexel;
}