shader_type canvas_item;

uniform float fade_start: hint_range(0.0, 1.0) = 0.5; // Where the fade starts (0 = top, 1 = bottom)
uniform float fade_end: hint_range(0.0, 1.0) = 1.0;   // Where the fade ends (0 = top, 1 = bottom)
uniform float smoothness: hint_range(0.0, 1.0) = 0.1; // Controls the smoothness of the transition

void fragment() {
    // Get the UV coordinates (0 to 1, where y=0 is top, y=1 is bottom)
    vec2 uv = UV;
    
    // Sample the texture color
    vec4 color = texture(TEXTURE, uv);
    
    // Calculate the alpha using smoothstep
    // uv.y goes from 0 (top) to 1 (bottom)
    float alpha = 1.0 - smoothstep(fade_start, fade_end, uv.y);
    
    // Apply the alpha to the color
    COLOR = vec4(color.rgb, color.a * alpha);
}