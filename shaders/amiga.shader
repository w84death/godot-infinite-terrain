shader_type spatial;

/* AMIGAAAAAAA! */
uniform float s = .2;
uniform float tf = .1;
uniform bool animate = true;


void fragment() {
	vec3 c = vec3(1.0);
	float hs = s*.5;
    float t = animate ? TIME : 0.0;
	vec2 pos = mod(UV.xy + vec2(t * 0.25, 0.0), vec2(s));
	if ( (pos.x>hs && pos.y>hs) || (pos.x<hs && pos.y<hs)) { 
		c = vec3(1.0,.0,.0); 
	} else {
		c = vec3(1.0);
	}
	
	ALBEDO = c;
	METALLIC = 0.3;
	SPECULAR = 0.3;
	ROUGHNESS = 0.8;
    RIM = 0.4;
    RIM_TINT = 0.6;
}