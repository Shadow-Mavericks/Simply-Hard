// Waterfall shader by Striker
uniform float timer;

vec4 getTexelWrapped(vec2 coord)
{	
	return texture2DGrad(tex, fract(coord), dFdx(coord), dFdy(coord));
}

vec4 Process(vec4 color)
{
	vec2 baseCoord = gl_TexCoord[0].st;
	vec2 flipCoord = gl_TexCoord[0].st;
	flipCoord.s *= -1;
	
	// Scroll
	baseCoord.y -= timer * 0.50;
	flipCoord.y -= timer * 1.00;
	
	// Get result
	vec4 baseTexel = getTexelWrapped(baseCoord);
	vec4 flipTexel = getTexelWrapped(flipCoord);
	
	// Darken layers.
	baseTexel.rgb *= 0.5;
	flipTexel.rgb *= 0.5;
	
	vec4 finalTexel = baseTexel+flipTexel;
	finalTexel.a = baseTexel.a;
	
	return finalTexel * color;
}