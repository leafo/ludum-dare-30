
{graphics: g} = love

import BloodEmitter, GibEmitter from require "particles"

frame_rate = 0.08

class Enemy extends Entity
  is_enemy: true
  w: 10
  h: 15
  hp: 1
  alpha: 255
  strafing: false

  new: (x,y) =>
    super x,y

    @vel = Vec2d 0,0
    @facing = "left"
    @impulses = ImpulseSet!
    @effects = EffectList!

    @seqs = DrawList!
    if @ai = @make_ai!
      @seqs\add @ai

    @make_sprite!

  make_sprite: => error "override me"
  make_ai: => error "override me"

  get_floor: =>
    @world.map\get_floor_range @x + @w / 2, @y + @h + 0.1

  close_to_player: (rx=250,ry=rx)=>
    range = Box 0,0,rx,ry
    range\move_center @center!
    range\touches_box @world.player

  update: (dt, @world) =>
    @effects\update dt
    @anim\update dt
    @seqs\update dt
    @vel += @world.gravity * dt

    -- air resistance
    if @vel[1] != 0
      @vel[1] = dampen @vel[1], dt * 200

    vx, vy = unpack @vel
    ix, iy = @impulses\sum!

    vx += ix
    vy += iy

    unless @strafing
      if vx > 0
        @facing = "right"
      if vx < 0
        @facing = "left"

    @set_state vx, vy

    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cy
      if @vel[2] > 0
        @on_ground = true
      @vel[2] = 0
    else
      @on_ground = false

    if cx and @impulses.move
      @impulses.move[1] = -@impulses.move[1]

    true

  set_state: =>

  draw: =>
    if DEBUG
      COLOR\pusha 80
      super!
      COLOR\pop!

    COLOR\pusha @alpha
    @effects\before!
    @anim\draw @x, @y
    @effects\after!
    COLOR\pop!

  die: =>
    @dying = @seqs\add Sequence ->
      @impulses.move = nil
      @seqs\remove @ai
      @seqs\remove @taking_hit
      tween @, 0.5, alpha: 1
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

    @impulses.move = false
    @vel[1] = 0

    @hp -= 1
    if @hp <= 0
      return @die!

    hit_power = 150

    @taking_hit = @seqs\add Sequence ->

      vx, vy = unpack (Vec2d(@center!) - Vec2d(thing\center!))\normalized! * hit_power

      @vel[1] = vx
      @vel[2] = vy - 150

      wait 0.5
      @taking_hit = nil

  mover_fn: (floor) =>
    (dt) ->
      return "cancel" if @attacking or @shooting
      if not floor\on_floor(@) and @impulses.move
        @impulses.move[1] = -@impulses.move[1]


class Lilguy extends Enemy
  hp: 2

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

      probs = {
        move: 2
        attack: 1
        wait: 1
      }

      probs.attack *= 3 if @close_to_player!

      switch pick_dist probs
        when "attack"
          await @attack, @
        when "move"
          speed = rand 20, 40
          dir = pick_dist [1]: 1, [-1]: 1
          dur = rand 0.8, 1.5

          if floor = @get_floor!
            @impulses.move = Vec2d speed * dir
            during dur, @mover_fn floor
            @impulses.move = nil

      wait rand 0.2, 0.8
      again!

  set_state: (vx, vy) =>
    return if @dying or @attacking

    motion = if @taking_hit
      "stun"
    elseif vx != 0
      "walk"
    else
      "stand"

    @anim\set_state "#{motion}_#{@facing}"

  attack: (callback) =>
    return if @attacking

    @attacking = @seqs\add Sequence ->
      directional = if @close_to_player 180, 80
        @facing = @world.player\left_of(@) and "left" or "right"
        true

      @anim\set_state "stand_#{@facing}"
      @effects\add ShakeEffect 0.2
      wait 0.3

      @impulses.move = nil
      state_name = "attack_#{@facing}"
      @anim\set_state state_name

      wait frame_rate * 2

      if directional
        power = rand 150, 200
        @vel[2] = -100
        @vel[1] = @facing == "left" and -power or power
      else
        @vel[2] = -200

      wait frame_rate * 3
      @attacking = false

      callback and callback!

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


class Bullet extends Box
  is_enemy: true
  is_bullet: true

  lazy sprite: -> Spriter "images/gunguybullet.png"

  w: 5
  h: 5
  time: 0

  new: (x,y, @vel) =>
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
      @time += dt
      dx, dy = unpack dt * @vel
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
    if DEBUG
      COLOR\pusha 100
      super!
      COLOR\pop!

    g.push!
    scale = 3 / math.min 3, 1 + @time * 4
    g.translate 0, scale * math.sin @time * 20
    @anim\draw @x, @y
    g.pop!


class ShoveEffect extends Effect
  duration: 0.2

  new: (@dir, ...) =>
    super ...

  before: =>
    g.push!
    p = @p!
    power = 5
    power = -power if @dir == "right"

    p = ad_curve p, 0, 0.1, 0.1, 1
    g.translate power*p, 0

  after: =>
    g.pop!

class Gunguy extends Enemy
  lazy sprite: -> Spriter "images/gunguy.png"
  strafing: true

  make_sprite: =>
    @facing = "right"
    with @sprite
      @anim = StateAnim "stand_#{@facing}", {
        stand_left: \seq {
          "4,14,23,20"

          -- "4,77,23,20" -- :O shoot?
          -- "38,77,23,20"
          ox: 6
          oy: 3
        }, 0.2

        stand_right: \seq {
          "4,14,23,20"

          ox: 6
          oy: 3

          flip_x: true
        }

        walk_left: \seq {
          "4,14,23,20"
          "38,14,23,20"
          ox: 6
          oy: 3
          rate: 0.2
        }

        walk_right: \seq {
          "4,14,23,20"
          "38,14,23,20"
          ox: 6
          oy: 3
          rate: 0.2
          flip_x: true
        }

        -- strafes
        walk_right_back: \seq {
          "4,46,23,20"
          "35,46,23,20"
          flip_x: true
        }, 0.2

        walk_left_back: \seq {
          "4,46,23,20"
          "35,46,23,20"
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

        shoot_left: \seq {
          "4,78,23,20"
          "38,78,23,20"
          rate: 0.1
          once: true
          ox: 6
          oy: 3
        }

        shoot_right: \seq {
          "4,78,23,20"
          "38,78,23,20"

          ox: 6
          oy: 3

          rate: 0.1
          flip_x: true
          once: true
        }
      }

  die: =>
    @world.seqs\add Sequence ->
      cx, cy = @center!
      y = @y + @h

      for i=1,4
        @world.particles\add GibEmitter @world, cx , y
        y -= 9
        wait 0.02

    super!

  nozzle_pt: =>
    if @facing == "left"
      @x - 3, @y + 3
    else
      @x + @w + 4, @y + 3

  -- shoot the facing direction
  shoot: (callback) =>
    return if @shooting

    import GunSmokeEmitter from require "particles"

    x,y = @nozzle_pt!
    @world.particles\add GunSmokeEmitter @world, x, y

    vx = if @facing == "left"
      -130
    else
      130

    @shooting = @seqs\add Sequence ->
      wait 0.1
      @effects\add ShoveEffect @facing
      @world.entities\add Bullet x,y, Vec2d vx, 0
      wait 0.3
      @shooting = false
      callback and callback!

  set_state: =>
    motion = if @shooting
      "shoot"
    elseif @impulses.move
      "walk"
    else
      "stand"

    @anim\set_state "#{motion}_#{@facing}"

  player_in_sight: =>
    w = @world.viewport.w

    box = if @facing == "left"
      Box @x - w, @y, w, @h
    else
      Box @x, @y, w, @h

    box\touches_box @world.player

  make_ai: =>
    Sequence ->
      if @close_to_player @world.viewport.w, @world.viewport.h
        target = @world.player\left_of(@) and "left" or "right"
        if target != "facing" and chance 0.8
          @facing = target

      in_sight = false
      during 3.0, ->
        if @player_in_sight!
          in_sight = true
          "cancel"

      if in_sight and chance 0.6
        await @shoot, @
        wait rand 0.5, 1.0
      elseif floor = @get_floor!
        speed = rand 20, 50
        dir = pick_dist [1]: 1, [-1]: 1
        dur = rand 0.8, 1.5

        if floor = @get_floor!
          @impulses.move = Vec2d speed * dir
          during dur, @mover_fn floor
          @impulses.move = nil
      else
        wait 1.0 -- nothing to do

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

  die: =>
    cx, cy = @center!
    y = @y + @h

    for i=1,10
      @world.particles\add GibEmitter @world, cx , y
      y -= 10

    @world.viewport\shake 0.2

    @dying = @seqs\add Sequence ->
      tween @, 0.5, alpha: 1
      @alive = false

class Fanguy extends Enemy
  w: 14
  h: 10

  lazy sprite: -> Spriter "images/fanguy.png", 16, 16

  make_ai: =>

  make_sprite: =>
    with @sprite
      @anim = StateAnim "shoot", {
        stand: \seq { 0, ox: 1, oy: 6 }
        shoot: \seq { 1,2,3,4, rate: 0.2, ox: 1, oy: 6 }
      }

  nozzle_pt: =>
    @x + @w / 2, @y

  shoot: =>
    @shoot_fan!

  shoot_fan: (callback) =>
    @seqs\add Sequence ->
      angles = [deg for deg=-150, -30, 15]
      if fn = pick_dist { [shuffle]: 1, [reverse]: 2, [false]: 2 }
        fn angles

      for deg in *angles
        dir = Vec2d.from_angle(deg) * 200
        x, y = @nozzle_pt!
        @world.entities\add Bullet x,y, dir
        wait 0.1

  shoot_circle: (callback) =>

{
  :Enemy
  :Gunguy
  :Lilguy
  :Towerguy
  :Fanguy
}
