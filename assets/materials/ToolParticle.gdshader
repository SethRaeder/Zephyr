shader_type canvas_item;

uniform sampler2D noise_1: repeat_enable;
uniform sampler2D noise_2: repeat_enable;
uniform sampler2D color_mask: repeat_enable;
uniform sampler2D color_mask2: repeat_enable;
uniform vec2 color_motion = vec2(1.0,0.0);
uniform vec2 color_motion2 = vec2(0.0,1.0);
uniform vec2 motion = vec2(1.0,0.0);
uniform vec2 motion_2 = vec2(0.0,1.0);
uniform float speed = 0.08;
uniform float scale = 1.0;

void fragment() {
	vec4 col = texture(color_mask,SCREEN_UV * scale + (color_motion * TIME * speed));
	vec4 col2 = texture(color_mask2,SCREEN_UV * scale + (color_motion2 * TIME * speed));
	
	vec4 a = texture(noise_1,SCREEN_UV * scale + (motion * TIME * speed)); 
	vec4 b = texture(noise_2,SCREEN_UV * scale + (motion_2 * TIME * speed));
	float alpha = length(mix(a,b,0.5).rgb);
	
	float distance_from_center = sqrt(pow((0.5-UV.x),2) + pow((0.5-UV.y),2));
	COLOR.a = COLOR.a * mix(alpha,-1.4,distance_from_center);
	COLOR.rgb = COLOR.rgb * mix(col.rgb,col2.rgb,0.5);
}
