shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back;

uniform sampler2D TEXTURE : hint_default_white; // Base texture
uniform vec4 glow_color : source_color = vec4(0.0, 1.0, 1.0, 1.0); // Cyan glow
uniform float glow_intensity : hint_range(0.0, 5.0) = 0.0; // Default off for +6 or lower
uniform float wave_speed : hint_range(0.1, 5.0) = 1.5;
uniform float wave_scale : hint_range(0.1, 5.0) = 2.0;
uniform float min_glow_level : hint_range(0.0, 10.0) = 7.0; // Glow starts at +7

void fragment() {
    // Fetch base texture color
    vec4 tex_color = texture(TEXTURE, UV);

    // Liquid ripple effect across the item (wavy distortion)
    float wave = sin(UV.x * wave_scale + TIME * wave_speed) * 0.5 + 0.5;

    // Apply wave distortion to UV for liquid-like movement on the texture
    vec2 distorted_uv = UV + vec2(sin(UV.y * wave_scale + TIME * wave_speed) * 0.05, wave * 0.1);
    vec4 distorted_tex_color = texture(TEXTURE, distorted_uv);

    // Fresnel effect for stronger glow on edges (optional, you can tweak or remove this)
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);

    // Glow strength based on item level and wave movement
    float glow_strength = max(0.0, glow_intensity * wave * fresnel);

    // Final glow color (additive blending)
    vec4 glow = glow_color * glow_strength * distorted_tex_color.a;

    // Apply color and emission
    ALBEDO = distorted_tex_color.rgb + glow.rgb; // Base texture with glow
    ALPHA = distorted_tex_color.a; // Maintain transparency
    EMISSION = glow.rgb; // Makes the item glow with liquid-like effect
}
