
{graphics: g} = love

show_properties = (t) ->
  require("moon").p { k,v for k,v in pairs t when type(v) != "table" }

-- on_ground: is on ground
-- wall_running: is wall running
-- can_wall_jump: allowed to wall jump, set to true when jump key released
class Player extends Entity
  speed: 100
  on_ground: false
  movement_locked: false
  dampen_movement: 1

  new: (x,y) =>
    super x, y
    @seqs = DrawList!

    @velocity = Vec2d 0,0
    @facing = "left"

  draw: (...) =>
    if @wall_running
      COLOR\push 100,255,100

    super ...

    if @wall_running
      COLOR\pop!

    -- draw a nose
    COLOR\push 255,128,128
    if @facing == "left"
      g.rectangle "fill", @x, @y, 10, 10
    else
      g.rectangle "fill", @x + @w/2 , @y, 10, 10

    COLOR\pop!

  update: (dt, @world) =>
    @seqs\update dt, @world

    if @wall_running
      @update_for_wall_run dt
    else
      @update_for_gravity dt

    true

  update_for_wall_run: (dt) =>
    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    if CONTROLLER\is_down @wall_run_up_key
      @velocity[2] = -math.abs(dx) * @speed
    else
      if @velocity[2] < 0
        @velocity[2] = 0

      @velocity += @world.gravity * dt

    if not @can_wall_jump
      @can_wall_jump = not CONTROLLER\is_down "jump"

    if @can_wall_jump and CONTROLLER\is_down "jump"
      @jump @world

    cx, cy = @fit_move @velocity[1] * dt, @velocity[2] * dt, @world

    moving_away = if @wall_run_up_key == "left"
      dx > 0
    else
      dx < 0

    -- stop if moving away, not against wall anymore or moving opposite direction
    if not @against_wall(@world) or cy or moving_away
      @seqs\remove @wall_running
      @end_wall_run!

  update_for_gravity: (dt) =>
    dx, dy = unpack CONTROLLER\movement_vector! * dt * @speed

    if dx != 0
      @facing = if dx < 0 then "left" else "right"

    if CONTROLLER\is_down "jump"
      @jump @world

    @velocity += @world.gravity * dt
    -- air resistance
    if @velocity[1] != 0
      air_rate = 1
      if dx != 0 and not (dx < 0 and @velocity[1] < 0)
        air_rate *= 3

      @velocity[1] = dampen @velocity[1], dt * 200

    vx, vy = unpack @velocity
    vx += dx * @speed * @dampen_movement

    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cx
      @wall_run!

    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      if math.floor(@velocity[2] * dt) != 0
        @on_ground = false

  against_wall: (world) =>
    ep = 0.1
    cy = @y + @h * 4 / 5 -- around the feet?

    cx = switch @wall_run_up_key
      when "left"
        @x - ep
      when "right"
        @x + @w + ep

    world\collides_pt cx, cy

  wall_run: =>
    return if @wall_running

    -- cancel the jump
    if @jumping
      @seqs\remove @jumping
      @jumping = false

    @wall_running = @seqs\add Sequence ->
      @wall_run_up_key = @facing
      wait 0.5
      @end_wall_run!

  end_wall_run: =>
    @wall_running = false
    @velocity[2] = math.max 0, @velocity[2]

  jump: (world) =>
    return if @jumping
    return unless @on_ground or @wall_running

    @jumping = @seqs\add Sequence ->
      vx, vy = if @wall_running
        print "side jumping"
        @end_wall_run!
        @slow_movement_for 0.3

        if @wall_run_up_key == "left"
          100, -200
        else
          -100, -200
      else
        0, -200

      @can_wall_jump = false

      @velocity[1] = vx
      @velocity[2] = vy

      wait 0.1
      @jumping = false

  slow_movement_for: (duration) =>
    if @_dampen_seq
      @seqs\remove @_dampen_seq

    @_dampen_seq = @seqs\add Sequence ->
      @dampen_movement = 0
      tween @, duration, dampen_movement: 1

  looking_at: (viewport) =>
    cx, cy = @center!
    if @facing == "left"
      cx - 20, cy
    else
      cx + 20, cy


{ :Player }
