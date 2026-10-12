// one directional gaussian blur pass, run it horizontal then vertical
#define RADIUS 8                 // taps each side, has to be a constant

uniform vec2  direction;         // uv step per tap, {1/w, 0} or {0, 1/h}
uniform float sigma;             // blur softness in taps, also haha sigma
uniform float threshold;         // bright pass, only used on the first pass (0 = off)
uniform float gain;              // glow strength, only used on the last pass

vec4 effect(vec4 colour, Image tex, vec2 tc, vec2 sc)
{
    vec3 sum = vec3(0.0);
    float wsum = 0.0;
    
    for (int i = -RADIUS; i <= RADIUS; i++)
    {
        float f = float(i);
        float w = exp(-(f * f) / (2.0 * sigma * sigma));
        vec3 c = Texel(tex, tc + direction * f).rgb;
        c = max(c - vec3(threshold), vec3(0.0));
        sum += c * w;
        wsum += w;
    }
    
    return vec4(sum / wsum * gain, 1.0);
}
