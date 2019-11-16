export GAME_CONFIG = {
  scale: 2
  keys: {
    confirm: { "x", "space", joystick: 1 }
    cancel: { "c", joystick: 2 }

    attack: { "c", "return", joystick: 2 }
    jump: { "x", "space", joystick: 1 }

    up: "up"
    down: "down"
    left: "left"
    right: "right"
  }

  joystick_binding: {
    confirm: { joystick: 1 }
    cancel: { joystick: 2 }

    attack: { joystick: 2 }
    jump: { joystick: 1 }
  }
}

love.conf = (t) ->
  t.window.width = 420 * GAME_CONFIG.scale
  t.window.height = 272 * GAME_CONFIG.scale

  t.title = "wallrun dot love"
  t.author = "leafo + i.i"
