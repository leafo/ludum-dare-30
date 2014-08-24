
class Enemy extends Entity
  is_enemy: true
  w: 10
  h: 15

  lazy sprite: -> Spriter "images/lilguy.png"

  new: (x,y) =>
    super x,y

    @velocity = Vec2d 0,0
    @facing = "left"
    @impulses = ImpulseSet!

    @seqs = DrawList!
    @seqs\add @make_ai!

    with @sprite
      @anim = StateAnim "stand_#{@facing}", {
        stand_left: \seq {
          "3,0,15,17"
          ox: 2
          oy: 1
        }

        stand_right: \seq {
          "3,0,15,17"
          flip_x: true
          ox: 3
          oy: 1
        }

        walk_left: \seq {
          "2,32,15,17"
          "18,32,15,17"
          "34,32,15,17"
          "50,32,15,17"
          ox: 2
          oy: 1
        }, 0.08

        walk_right: \seq {
          "2,32,15,17"
          "18,32,15,17"
          "34,32,15,17"
          "50,32,15,17"
          flip_x: true
          ox: 2
          oy: 1
        }, 0.08

        attack_left: \seq {
          "2,16,14,16"
          "18,16,14,16"
          "32,16,14,16"
          "32,16,14,16"
          "50,16,14,16"
          oy: 1
          ox: 3
        }, 0.08

        attack_right: \seq {
          "2,16,14,16"
          "18,16,14,16"
          "32,16,14,16"
          "32,16,14,16"
          "50,16,14,16"
          oy: 1
          flip_x: true
        }, 0.08

        die_left: \seq {
          "7,70,40,26"
          "55,70,40,26"
          "103,70,40,26"
          "151,70,40,26"
          "199,70,40,26"
          "247,70,40,26"
          "295,70,40,26"
          "343,70,40,26"
          "391,70,40,26"
          "439,70,40,26"

          ox: 15
          oy: 11
        }, 0.08

        die_right: \seq {
          "7,70,40,26"
          "55,70,40,26"
          "103,70,40,26"
          "151,70,40,26"
          "199,70,40,26"
          "247,70,40,26"
          "295,70,40,26"
          "343,70,40,26"
          "391,70,40,26"
          "439,70,40,26"

          ox: 15
          oy: 11
          flip_x: true
        }, 0.08
      }

  make_ai: =>
    Sequence ->
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
    @anim\update dt
    @seqs\update dt
    @velocity += @world.gravity * dt

    vx, vy = unpack @velocity
    ix, iy = @impulses\sum!

    vx += ix
    vy += iy

    if vx > 0
      @facing = "right"

    if vx < 0
      @facing = "left"

    motion = if vx != 0
      "walk"
    else
      "stand"

    unless @dying
      @anim\set_state "#{motion}_#{@facing}"

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

  draw: =>
    if DEBUG
      COLOR\pusha 80
      super!
      COLOR\pop!

    @anim\draw @x, @y

  die: =>
    @anim\set_state "die_#{@facing}"
    @dying = @seqs\add Sequence ->
      @impulses.move = nil
      @seqs\remove @ai
      @seqs\remove @taking_hit

      wait @anim\state_duration "die_left"
      @alive = false

  take_hit: (world, thing) =>
    return if @taking_hit or @dying
    @taking_hit = @seqs\add Sequence ->
      @die!
      wait 1.0
      @taking_hit = nil

{
  :Enemy
}
