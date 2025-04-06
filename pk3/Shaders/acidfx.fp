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

#define PI 3.141592653589793
vec2 iResolution = vec2(640.0, 360.0);

float hash21(vec2 p)
{
	uvec2 q = uvec2(ivec2(p)) * uvec2(1597334673U, 3812015801U);
	uint n = (q.x ^ q.y) * 1597334673U;
	return float(n) / float(0xffffffffU);
}

vec3 hash13(float p) {
   vec3 p3 = fract(vec3(p) * vec3(.1031,.11369,.13787));
   p3 += dot(p3, p3.yzx + 19.19);
   return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

vec2 wigglyDrops(vec2 st, float time, float size)
{
    vec2 wigglyDropAspect = vec2(2., 1.);
    vec2 uv = st * size * wigglyDropAspect;
    uv.x *= iResolution.x / iResolution.y;
    uv.y += time * .23;

    vec2 gridUv = fract(uv) - .5; // rectangular grid
    vec2 id = floor(uv);
    
    float h = hash21(id);
    time += h * 2. * PI;
    float w = st.y * 10.;
    float dx = (h - .5) * .8;
    dx += (.3 - abs(dx)) * pow(sin(w), 2.) * sin(2. * w) *
        pow(cos(w), 3.) * 1.05; // wiggle
    float dy = -sin(time + sin(time + sin(time) * .5)) * .45; // slow down drop before continuing falling
    dy -= (gridUv.x - dx) * (gridUv.x - dx);
    
    vec2 dropUv = (gridUv - vec2(dx, dy)) / wigglyDropAspect;
    float drop = smoothstep(.06, .0, length(dropUv));
    
    vec2 trailUv = (gridUv - vec2(dx, time * .23)) / wigglyDropAspect;
    trailUv.y = (fract((trailUv.y) * 8.) - .5) / 8.;
    float trailDrop = smoothstep(.03, .0, length(trailUv));
    trailDrop *= smoothstep(-.05, .05, dropUv.y) * smoothstep(.4, dy, gridUv.y) *
        	(1.-step(.4, gridUv.y));
    
    float fogTrail = smoothstep(-.05, .05, dropUv.y) * smoothstep(.4, dy, gridUv.y) *
			smoothstep(.05, .01, abs(dropUv.x)) * (1.-step(.4, gridUv.y));
    
    return vec2(drop + trailDrop, fogTrail);
}

vec2 getDrops(vec2 st, float time)
{
    vec2 largeDrops = wigglyDrops(st, time * 2., 1.6);
    vec2 mediumDrops = wigglyDrops(st + 2.65, (time + 1296.675) * 1.4, 2.5);
    vec2 smallDrops = wigglyDrops(st - 1.67, time - 896.431, 3.6);
    //float rain = rainDrops(st, time, 20.);
    
    vec2 drops;
    drops.y = max(largeDrops.y, max(mediumDrops.y, smallDrops.y));
    drops.x = smoothstep(.4, 2., (1. - drops.y) * largeDrops.x +
                          mediumDrops.x + smallDrops.x); // drops kinda blend together

    return drops;
}

vec4 blendOver(vec4 a, vec4 b) {
    float newAlpha = mix(b.w, 1.0, a.w);
    vec3 newColor = mix(b.w * b.xyz, a.xyz, a.w);
    float divideFactor = (newAlpha > 0.001 ? (1.0 / newAlpha) : 1.0);
    return vec4(divideFactor * newColor, newAlpha);
}

vec4 Process(vec4 color)
{	
	vec2 fragCoord = gl_TexCoord[0].st;
    vec2 st = fragCoord;// / iResolution.xy;
	
    float time = mod(timer + 100., 7200.);
    
    vec2 drops = getDrops(st, time);
    vec2 offset = drops.xy;
    float lod = (1. - drops.y) * 4.8;
    
    // This is kinda expensive, would love to use a cheaper method here.
    vec2 dropsX = getDrops(st + vec2(.001, 0.), time);
    vec2 dropsY = getDrops(st + vec2(0., .001), time);
    vec3 normal = vec3(dropsX.x - drops.x, dropsY.x - drops.x, 0.);
    normal.z = sqrt(1. - normal.x * normal.x - normal.y * normal.y);
    normal = normalize(normal);
    
	vec4 col = texture2DLod(tex, st+normal.xy * 3., lod).rgba;
    vec4 col2 = col;//color;
    
    //col2 += (drops.y > 0. ? vec4(-.1, .5, -.15, 1.0)*drops.y : vec4(0.0))/2.0; // acidic trails
    
    
	col *= vec4(.8, 1.0, .7, 1.0); // slight green-ish tint
    col *= (drops.x > 0. ? vec4(.2, 1.0, .1, 1.0) * (1.-drops.x) : vec4(.2, 1.0, .1, 1.0) * (drops.x)); // acid colored drops
	
	col2 *= vec4(.0, 1.0, .0, 0.5);// : vec4(-.1, .5, -.15, 0.0)); // acidic trails
	col2.a *= drops.y;
	
	col.a *= color.a;
	col2.a *= color.a;
    
    //col = mix(col, col*smoothstep(.8, .35, length(st - .5)), .6); // vignette
	
	return blendOver(col, col2);
}