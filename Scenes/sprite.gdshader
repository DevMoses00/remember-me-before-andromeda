shader_type canvas_item;

uniform float blur_size = 1.0;

void fragment() {
    vec2 texel = blur_size * TEXTURE_PIXEL_SIZE;
    vec4 sum = vec4(0.0);

    sum += texture(TEXTURE, UV + texel * vec2(-1.0, -1.0));
    sum += texture(TEXTURE, UV + texel * vec2( 0.0, -1.0));
    sum += texture(TEXTURE, UV + texel * vec2( 1.0, -1.0));

    sum += texture(TEXTURE, UV + texel * vec2(-1.0,  0.0));
    sum += texture(TEXTURE, UV + texel * vec2( 0.0,  0.0));
    sum += texture(TEXTURE, UV + texel * vec2( 1.0,  0.0));

    sum += texture(TEXTURE, UV + texel * vec2(-1.0,  1.0));
    sum += texture(TEXTURE, UV + texel * vec2( 0.0,  1.0));
    sum += texture(TEXTURE, UV + texel * vec2( 1.0,  1.0));

    COLOR = sum / 9.0;
}
