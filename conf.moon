export GAME_CONFIG = {
  -- design size of the pixel viewport, scale is chosen from the screen in main
  viewport_width: 420
  viewport_height: 272

  -- pixel scale, replaced at startup by the scale that fits the screen
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
  t.version = "11.5"
  t.identity = "wallrun"
  -- the window is opened in love.load once the display size is known
  t.window = nil

  t.title = "wallrun dot love"
  t.author = "leafo + i.i"
