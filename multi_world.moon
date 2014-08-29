
-- a world for multiple players

import World from require "world"

class MultiWorld extends World
  spawn_idx: 1

  new: (game) =>
    @players = {}
    @spawns = {}
    super game, "maps.arena"

  add_player: (player) =>
    table.insert @players, player
    spawn = assert @spawns[@spawn_idx]
    @spawn_idx = (@spawn_idx % #@spawns) + 1

    player.x, player.y = unpack spawn
    @entities\add player

  add_spawn: (sx,sy) =>
    table.insert @spawns, Vec2d sx, sy

  looking_at: (...) =>
    return 0, 0 unless next @players

    sum_x, sum_y = 0, 0
    for p in *@players
      x,y = p\looking_at ...
      sum_x += x
      sum_y += y

    count = #@players
    sum_x / count, sum_y / count

{ :MultiWorld }
