
class Enemy extends Entity
  is_enemy: true
  lazy sprite: -> Spriter "images/lilguy.png"

  new: (x,y) =>
    super x,y

    @velocity = Vec2d 0,0
    @facing = "left"

  update: (dt, @world) =>
    @velocity += @world.gravity * dt

    vx, vy = unpack @velocity
    cx, cy = @fit_move vx * dt, vy * dt, @world

    if cy
      if @velocity[2] > 0
        @on_ground = true
      @velocity[2] = 0
    else
      @on_ground = false

    true

{
  :Enemy
}
