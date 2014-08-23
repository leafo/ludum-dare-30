
class World
  gravity: Vec2d 0, 500

  new: (map) =>
    @map = TileMap.from_tiled "maps.dev", {
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
