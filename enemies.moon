
class Enemy extends Entity
  is_enemy: true
  lazy sprite: -> Spriter "images/lilguy.png"

  new: (x,y) =>
    super x,y

    @velocity = Vec2d 0,0
    @facing = "left"
    @impulses = ImpulseSet!

    @ai = Sequence ->
      while not @on_ground
        wait 0.2

      switch pick_dist {move: 2, wait: 1}
        when "move"
          floor = @get_floor!

          speed = rand 20, 40
          dir = pick_dist [1]: 1, [-1]: 1
          dur = rand 0.8, 1.5

          dist = speed * dir * dur

          if dist < 0 and @x + dist < floor.x
            dir = -dir

          if dist > 0 and @x + @w + dist > floor.x + floor.w
            dir = -dir

          @impulses.move = Vec2d speed * dir
          wait dur
          @impulses.move = nil

      wait rand 0.8, 1.2
      again!

  get_floor: =>
    @world.map\get_floor_range @x + @w / 2, @y + @h + 0.1

  update: (dt, @world) =>
    @ai\update dt
    @velocity += @world.gravity * dt

    vx, vy = unpack @velocity
    ix, iy = @impulses\sum!

    vx += ix
    vy += iy

    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      @on_ground = false

    if cx and @impulses.move
      @impulses.move[1] = -@impulses.move[1]

    true

{
  :Enemy
}
