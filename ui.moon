{graphics: g} = love

-- text at the pixel scale over the whole screen, outside any scene viewport
draw_overlay = (lines) ->
  scale = GAME_CONFIG.scale
  g.push!
  g.origin!
  g.scale scale
  w, h = g.getWidth! / scale, g.getHeight! / scale
  COLOR\push 0, 0, 0, 180
  g.rectangle "fill", 0, 0, w, h
  COLOR\pop!

  line_h = 18
  font = g.getFont!
  box_w = math.max unpack [font\getWidth line for line in *lines]
  box_h = #lines * line_h
  y = math.floor h / 2 - box_h / 2

  COLOR\push 0, 0, 0
  g.rectangle "fill", math.floor(w / 2 - box_w / 2) - 6, y - 6, box_w + 12, box_h + 12
  COLOR\pop!

  for line in *lines
    g.printf line, 0, y, w, "center"
    y += line_h

  g.pop!

{ :draw_overlay }
