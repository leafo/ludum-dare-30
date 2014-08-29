
{graphics: g, :timer} = love

class RedGlow extends FullScreenShader
  send: =>
    -- @shader\send "time", timer.getTime!
    @shader\send "px", 1/@viewport.w
    @shader\send "py", 1/@viewport.h
    -- @shader\send "height", @viewport.h

  shader: -> [[
    extern number px;
    extern number py;
    // extern number time;

    // http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
    vec3 rgb2hsv(vec3 c) {
      vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
      vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
      vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

      float d = q.x - min(q.w, q.y);
      float e = 1.0e-10;
      return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
    }

    vec3 hsv2rgb(vec3 c) {
      vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
      vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
      return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    }

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      vec3 blur_color = vec3(240.0/255,0,0);
      vec4 c = Texel(texture, texture_coords);

      int range = 3;
      int step = 2;

      for (int fy=-range; fy <= range; fy+=step) {
        for (int fx=-range; fx <= range; fx+=step) {
          if (fx == 0 && fy == 0) continue;

          vec4 target_c = Texel(texture, texture_coords + vec2(fx * px, fy * py));

          if (target_c.rgb == blur_color) {
            c = vec4(mix(c.rgb, vec3(1,0.4,0.4), 0.1), 1);
          }
        }
      }

      return c;
    }
  ]]
    

class ColorShader
  new: (@source_color, @dest_color) =>
    @shader = g.newShader @shader!

  shader: -> [[
    extern vec3 source_color;
    extern vec3 dest_color;

    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      vec4 c = Texel(texture, texture_coords);

      if (c.rgb == source_color) {
        c = vec4(dest_color, 1);
      }

      return c * color;
    }
  ]]

  send: =>
    @shader\send "source_color", @source_color
    @shader\send "dest_color", @dest_color

  render: (fn) =>
    g.setShader @shader
    @send!
    fn!
    g.setShader!


{ :RedGlow, :ColorShader  }
