shader_type spatial;

uniform vec2 HEIGHTMAP_SIZE = vec2(1024.0, 1024.0);
uniform float HEIGHT_FACTOR = 128.0;
uniform float MOUNTAINS_FACTOR = 24.;
uniform float RANDOM_UV_FACTOR = 4.;
uniform float GRASS_UV_FACTOR = 4.;
uniform float WAVE_SCALE = 0.05;
uniform float WAVE_SPEED_FACTOR = 4.0;

uniform float SCROLL_SPEED = 0.1;

varying float color_height;
uniform sampler2D heightmap;
uniform sampler2D noisemap;
uniform float white_line = 0.8;
uniform float green_line = 0.5;
uniform float ground_line = 0.38;
uniform float blue_line = 0.4;
uniform int OCTAVES = 6;

float get_height(vec2 pos, float t) {
	pos -= .5 * HEIGHTMAP_SIZE;
	pos /= HEIGHTMAP_SIZE;
    //pos.y -= t;
	return texture(heightmap, pos).r;
}


float random (in vec2 st) {
    return fract(sin(dot(st.xy,vec2(12.9898,78.233)))*43758.5453123);
}

// Based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm (vec2 st) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(st);
        st *= 2.;
        amplitude *= .5;
    }
    return value;
}
void vertex() {
	float h = get_height(VERTEX.xz, TIME * SCROLL_SPEED);
	color_height = h;
	
	float shore_line = step(blue_line, color_height);
	float mountains_line = smoothstep(green_line, white_line, color_height);
	float rand = texture(noisemap, VERTEX.xz * 8.).x * MOUNTAINS_FACTOR;
	float waves = blue_line + fbm(VERTEX.xz * .2  + TIME * WAVE_SPEED_FACTOR) * WAVE_SCALE - 0.01;

    h = mix(waves, h, shore_line);
	
	h = h * HEIGHT_FACTOR;
	float fh = mix(h, h + rand, mountains_line);
	VERTEX.y = fh;
    
    /*TANGENT = normalize( vec3(0.0, get_height(VERTEX.xz + vec2(0.0, 0.2)) - get_height(VERTEX.xz + vec2(0.0, -0.2)), 0.4));
    BINORMAL = normalize( vec3(0.4, get_height(VERTEX.xz + vec2(0.2, 0.0)) - get_height(VERTEX.xz + vec2(-0.2, 0.0)), 0.0));
    NORMAL = cross(TANGENT, BINORMAL);*/
}

void fragment() {
	float ran = texture(noisemap, UV * RANDOM_UV_FACTOR).x;
	float ran2 = texture(noisemap, UV * GRASS_UV_FACTOR * 32.).x;
	vec3 alb = vec3(color_height);
	
	// sand (yellow) vs grass (green)
	float y_line = step(ground_line + ran * .15, color_height);
	alb.r = mix(.6 + ran *.3, 	(.4 - ran * .1) * ran2, 	y_line);
	alb.g = mix(.4 + ran *.2, 	(.5 - ran * .2) * ran2, 	y_line);
	alb.b = mix(.3 + ran *.2, 	(0.1) * ran2, 				y_line);
	
	// rest vs white top
	float g_line = step(green_line + ran * .3, color_height);
	alb.r = mix(alb.r, 1., g_line);
	alb.g = mix(alb.g, 1., g_line);
	alb.b = mix(alb.b, 1., g_line);
	
	// water (blue) vs rest
	float b_line = step(blue_line, color_height);
	alb.r = mix(.2 + ran * .05, 	alb.r, b_line);
	alb.g = mix(.2 + ran * .15, 	alb.g, b_line);
	alb.b = mix(.2, 				alb.b, b_line);
	//alb = mix(vec3(clamp(alb + color_height, 0., 0.4)), 	alb, b_line);

	TRANSMISSION = mix(vec3(0.), vec3(.3, .3, 1.), g_line);
    TRANSMISSION = mix(TRANSMISSION, vec3(.1, .5, .8), b_line);
	TRANSMISSION += mix(vec3(.9, .9, .8), TRANSMISSION, g_line);
	
	SPECULAR = mix(.8, .5, b_line);
	ROUGHNESS = mix(.2, 0.8, b_line);
	METALLIC = mix(0.4, 0.2, b_line);

	ALBEDO = alb;
}