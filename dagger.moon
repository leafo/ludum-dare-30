
class Dagger extends Entity
  lazy sprite: -> Spriter "images/dagger2.png", 10, 10
  w: 2
  h: 8

  ox: 4
  oy: 1

  on_ground: false

  new: (x,y, vel, @callback) =>
    super x, y
    @anim = @sprite\seq { 0,1,2,3,4,5,6 }, 0.05
    @stopped = @sprite\seq { 7 }
    @vel = vel

  update: (dt, @world) =>
    @anim\update dt

    @vel += @world.gravity * dt

    -- air resistance
    if @vel[1] != 0
      @vel[1] = dampen @vel[1], dt * 20

    vx, vy = unpack @vel
    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cy
      if @vel[2] > 0
        @vel[1] = 0
        if not @on_ground
          @callback and @callback!
          @on_ground = true

      @vel[2] = 0
    if cx
      @vel[1] = -@vel[1] / 1.5

    true

  draw: =>
    if @on_ground
      @stopped\draw @x - @ox, @y - @oy
    else
      @anim\draw @x - @ox, @y - @oy

{
  :Dagger
}
