
{graphics: g} = love

import BloodEmitter from require "particles"

class Enemy extends Entity
  is_enemy: true
  w: 10
  h: 15
  hp: 1

  new: (x,y) =>
    super x,y

    @velocity = Vec2d 0,0
    @facing = "left"
    @impulses = ImpulseSet!

    @seqs = DrawList!
    if ai = @make_ai!
      @seqs\add ai

    @make_sprite!

  make_sprite: => error "override me"
  make_ai: => error "override me"

  get_floor: =>
    @world.map\get_floor_range @x + @w / 2, @y + @h + 0.1

  update: (dt, @world) =>
    @anim\update dt
    @seqs\update dt
    @velocity += @world.gravity * dt

    -- air resistance
    if @velocity[1] != 0
      @velocity[1] = dampen @velocity[1], dt * 200

    vx, vy = unpack @velocity
    ix, iy = @impulses\sum!

    vx += ix
    vy += iy

    if vx > 0
      @facing = "right"

    if vx < 0
      @facing = "left"

    motion = if @taking_hit
      "stun"
    elseif vx != 0
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

      if @anim.states.die_left
        wait @anim\state_duration "die_left"
      else
        wait 0.5

      @alive = false

  center: =>
    if @damage_box
      @damage_box!\center!
    else
      super!

  take_hit: (world, thing, attack_box) =>
    return if @taking_hit or @dying

    if @damage_box
      -- play clink
      return unless @damage_box!\touches_box attack_box

    world.particles\add with BloodEmitter world, 0,0, thing\left_of @
      \attach (emitter) ->
        emitter.x, emitter.y = @center!

    @hp -= 1
    if @hp <= 0
      return @die!

    hit_power = 150

    @taking_hit = @seqs\add Sequence ->
      @impulses.move = false
      vx, vy = unpack (Vec2d(@center!) - Vec2d(thing\center!))\normalized! * hit_power

      @velocity[1] = vx
      @velocity[2] = vy - 150

      wait 0.5
      @taking_hit = nil

class Lilguy extends Enemy
  hp: 10

  lazy sprite: -> Spriter "images/lilguy.png"

  make_sprite: =>
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

        stun_left: \seq {
          "3,96,15,17"
          ox: 2
          oy: 1
        }

        stun_right: \seq {
          "3,96,15,17"
          flip_x: true
          ox: 3
          oy: 1
        }

        walk_left: \seq {
          "2,32,15,17"
          "18,32,15,17"
          "34,32,15,17"
          "50,32,15,17"
          "66,32,15,17"
          ox: 2
          oy: 1
        }, 0.08

        walk_right: \seq {
          "2,32,15,17"
          "18,32,15,17"
          "34,32,15,17"
          "50,32,15,17"
          "66,32,15,17"

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

          speed = rand 20, 40
          dir = pick_dist [1]: 1, [-1]: 1
          dur = rand 0.8, 1.5

          dist = speed * dir * dur

          if floor = @get_floor!
            if dist < 0 and @x + dist < floor.x
              dir = -dir

            if dist > 0 and @x + @w + dist > floor.x + floor.w
              dir = -dir

          @impulses.move = Vec2d speed * dir
          wait dur
          @impulses.move = nil

      wait rand 0.8, 1.2
      again!


class Bullet extends Box
  is_enemy: true
  is_bullet: true

  lazy sprite: -> Spriter "images/gunguybullet.png"

  w: 5
  h: 5

  new: (x,y, @velocity) =>
    half = math.floor @w/2
    super x - half, y - half

    with @sprite
      @anim = StateAnim "shooting", {
        shooting: \seq {
          "0,0,13,13"
          ox: 4
          oy: 4
        }

        exploding: \seq {
          "16,0,13,13"
          "32,0,13,13"
          "48,0,13,13"
          "64,0,13,13"
          "80,0,13,13"

          ox: 4
          oy: 4

        }, 0.05
      }

  update: (dt, @world) =>
    @anim\update dt
    unless @dying
      dx, dy = unpack dt * @velocity
      @move dx, dy

      if @world\collides @
        @explode!

    if @death_time
      return false if @death_time <= 0
      @death_time -= dt

    true

  take_hit: (world, thing) =>
    return if @dying
    @explode!

  explode: =>
    @dying = true
    @death_time = @anim\state_duration "exploding"
    @anim\set_state "exploding"

  draw: =>
    -- if DEBUG
    --   COLOR\pusha 100
    --   super!
    --   COLOR\pop!

    @anim\draw @x, @y

class Gunguy extends Enemy
  lazy sprite: -> Spriter "images/gunguy.png"

  make_sprite: =>
    with @sprite
      @anim = StateAnim "stand_left", {
        stand_left: \seq {
          "4,14,23,20"

          -- "4,77,23,20" -- :O shoot?
          -- "38,77,23,20"
          ox: 6
          oy: 3
        }, 0.2

        walk_left: \seq {
          "4,14,23,20"
          "38,13,23,20"
        }, 0.2

        walk_left_back: \seq {
          "4,46,23,20"
          "35,46,23,20"
        }, 0.2

        stand_right: \seq {
          "4,14,23,20"

          ox: 6
          oy: 3

          flip_x: true
        }

        walk_right: \seq {
          "4,14,23,20"
          "38,13,23,20"
          flip_x: true
        }, 0.2

        walk_right_back: \seq {
          "4,46,23,20"
          "35,46,23,20"
          flip_x: true
        }, 0.2

        -- these are the same
        stun_left: \seq {
          "7,109,23,20"
          ox: 4
          oy: 3
        }

        stun_right: \seq {
          "7,109,23,20"
          ox: 9
          oy: 3
          flip_x: true
        }
      }

  die: =>
    @world.particles\add BloodEmitter @world, @center!
    @alive = false

  nozzle_pt: =>
    if @facing == "left"
      @x - 3, @y + 3
    else
      @x + @w + 4, @y + 3

  shoot: (dir) =>
    x,y = @nozzle_pt!
    vx = if @facing == "left"
      -100
    else
      100

    @world.entities\add Bullet x,y, Vec2d vx, 0

  make_ai: =>
    Sequence ->
      @shoot!

      wait 1
      again!

class Towerguy extends Enemy
  lazy sprite: -> Spriter "images/tower.png"
  w: 16
  h: 89

  damage_box: =>
    Box @x + 3, @y, 10, 10

  make_sprite: =>
    with @sprite
      @anim = StateAnim "idle", {
        idle: \seq {
          "8,7,30,89"
          ox: 8
        }

        stun: \seq {
          "56,7,30,89"
          ox: 8
        }

      }

  make_ai: =>

{
  :Enemy
  :Gunguy
  :Lilguy
  :Towerguy
}
