precision highp float;

varying vec2 fragUV;

uniform sampler2D diffuseMap;
uniform float life; // max: 1, min: 0
uniform float hue;

#define Max(a, b) (a > b ? a : b)
#define Min(a, b) (a < b ? a : b)

float hue2rgb(float p, float q, float t) {
    if(t < 0.0) t += 1.0;
    if(t > 1.0) t -= 1.0;
    if(t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if(t < 1.0/2.0) return q;
    if(t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

vec3 hslToRgb(float h, float s, float l){
    float r, g, b;
    if(s == 0.0){
        r = g = b = l; // achromatic
    }else{
        float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
        float p = 2.0 * l - q;
        r = hue2rgb(p, q, h + 1.0/3.0);
        g = hue2rgb(p, q, h);
        b = hue2rgb(p, q, h - 1.0/3.0);
    }

    return vec3(r, g, b);
}

vec3 rgbToHsl(float r, float g, float b) {
    float max = Max(r, Max(g, b));
    float min = Min(r, Min(g, b));
    float h, s, l = (max + min) / 2.0;

    if(max == min){
        h = s = 0.0; // achromatic
    }else{
        float d = max - min;
        s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
        if (max == r) h = (g - b) / d + (g < b ? 6.0 : 0.0);
        if (max == g) h = (b - r) / d + 2.0;
        if (max == b) h = (r - g) / d + 4.0;
        h /= 6.0;
    }

    return vec3(h, s, l);
}

void main(void) {
    float v = (fragUV.y > 0.05 && fragUV.y < 0.95) ? 0.5 : fragUV.y;
    vec4 materialColor = texture2D(diffuseMap, vec2(fragUV.x, v));
    vec3 hsl = rgbToHsl(materialColor.x, materialColor.y, materialColor.z);
    hsl.x = hue;
    vec3 rgb = hslToRgb(hsl.x, hsl.y, hsl.z);
    gl_FragColor = vec4(rgb, materialColor.a * life);
}
