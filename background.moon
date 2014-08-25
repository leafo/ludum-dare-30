
{graphics: g} = love

-- paralax background thinger
class Background
  new: =>
    @viewport = Viewport scale: GAME_CONFIG.scale

    @static = imgfy "images/bg1.png"

    @clouds = with imgfy "images/bg_clouds2.png"
      \set_wrap "repeat", "clamp"

    @clouds2 = with imgfy "images/bg_clouds.png"
      \set_wrap "repeat", "clamp"

    @mountains = with imgfy "images/bg_mountains.png"
      \set_wrap "repeat", "clamp"

    @sun = with imgfy "images/bg_sun.png"
      \set_wrap "repeat", "repeat"


  update: (dt) =>

  draw: (world_viewport) =>
    @viewport\apply!
    @draw_fit @static

    @draw_paralax @sun, world_viewport.x / 16
    @draw_paralax @mountains, world_viewport.x / 4
    @draw_paralax @clouds, world_viewport.x / 3
    @draw_paralax @clouds2, world_viewport.x / 3.2

    @viewport\pop!

  draw_paralax: (img, t) =>
    w = img\width!
    h = img\height!

    q = g.newQuad t % w, 0, @viewport.w, @viewport.h, w, h
    img\draw q, 0,0

  draw_fit: (img) =>
    w = img\width!
    h = img\height!

    scalex = @viewport.w / w
    scaley = @viewport.h / h

    scale = math.max scalex, scaley

    img\draw 0, 0, 0, scale, scale

{ :Background }


