shader_type canvas_item;

// Godot 4.3+ fix — باید این خط اضافه شود تا SCREEN_TEXTURE کار کند
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// شدت بلور
uniform float radius = 6.0;

void fragment() {
    vec2 texel = TEXTURE_PIXEL_SIZE;
    vec4 sum = vec4(0.0);

    // نمونه‌گیری 3x3 ساده برای بلور نرم
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(float(x), float(y)) * texel * radius;
            sum += texture(SCREEN_TEXTURE, SCREEN_UV + offset);
        }
    }

    COLOR = sum / 9.0;
}
