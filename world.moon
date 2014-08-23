
class PlatformMap extends TileMap
  -- takes the 1 indexed idx
  is_wall_tile: (idx) =>
    solid = @layers[@solid_layer]
    return false unless solid[idx]

    open_left, open_right, is_wall = false, false, false

    -- there are two kinds of walls, left and right
    if idx % @width != 1 -- check to the left
      unless solid[idx - 1]
        is_wall = true
        open_left = true

    if idx % @width != 0 -- check to the right
      unless solid[idx + 1]
        is_wall = true
        open_right = true

    is_wall, open_left, open_right

  pt_to_idx: (x,y) =>
    col = floor x / @cell_size
    row = floor y / @cell_size
    col + @width * row + 1 -- 1 indexed

  -- gets the bottom most tile for a wall, used to uniquely identify walls
  get_wall_root: (x, y) =>
    idx = @pt_to_idx x, y
    solid = @layers[@solid_layer]

    root = nil
    while @is_wall_tile idx
      root = solid[idx]
      idx += @width
      break if idx > @count

    root

class World
  gravity: Vec2d 0, 500

  new: (@game) =>
    @map = PlatformMap\from_tiled "maps.dev", {
      object: (o) ->
        switch o.name
          when "spawn"
            @spawn_x = o.x
            @spawn_y = o.y
    }

    @map_box = @map\to_box!

  collides: (thing) =>
    return true unless @map_box\contains_box thing
    @map\collides thing

  collides_pt: (x,y) =>
    return true unless @map_box\touches_pt x,y
    @map\collides_pt x,y

  draw: (viewport) =>
    @map\draw viewport

{ :World }
