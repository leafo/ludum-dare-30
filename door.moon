{graphics: g} = love

class Door extends Entity
  w: 18
  h: 70
  is_door: true
  filled: 0

  lazy sprite: => Spriter "images/door.png"

  new: (x,y) =>
    super x,y

    with @sprite
      @anim = StateAnim "default", {
        default: \seq {
          "0,0,33,73"
          ox: 7
          oy: 10
        }
        filled: \seq {
          "48,0,33,73"
          ox: 7
          oy: 10
        }
      }

  update: (dt, @world) =>
    @anim\update dt

    @vel += @world.gravity * dt

    vx, vy = unpack @vel
    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cy
      if @vel[2] > 0
        @vel[1] = 0
        if not @on_ground
          @callback and @callback!
          @on_ground = true

      @vel[2] = 0

    true

  after_filled: =>
    @filled = 1
    @anim\set_state "filled"

  fill_dimensions: =>
    w = 7
    h = 50
    x = @x + 13 - 7
    y = @y + 13 - 10
    x,y,w,h * @filled

  draw: =>
    g.push!
    g.translate 0, 5 * math.sin love.timer.getTime! * 2

    COLOR\push 240, 0, 0
    g.rectangle "fill", @fill_dimensions!
    COLOR\pop!

    @anim\draw @x, @y

    g.pop!

{
  :Door
}

