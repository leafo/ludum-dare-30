export GAME_CONFIG = {
  -- design size of the pixel viewport, scale is chosen from the screen in main
  viewport_width: 420
  viewport_height: 272

  -- pixel scale, replaced at startup by the scale that fits the screen
  scale: 2

  keys: {
    confirm: { "x", "space" }
    cancel: "c"

    attack: { "c", "return" }
    jump: { "x", "space" }

    up: "up"
    down: "down"
    left: "left"
    right: "right"

    pause: "p"
  }

  -- player two on the keyboard for the hidden versus mode
  keys2: {
    confirm: "g"
    cancel: "h"

    attack: "h"
    jump: "g"

    up: "w"
    down: "s"
    left: "a"
    right: "d"
  }

  -- gamepad button names
  gamepad: {
    confirm: { "a", "x" }
    cancel: { "b", "y" }

    attack: { "b", "y" }
    jump: { "a", "x" }

    pause: "start"

    -- holding select opens the menu, the face buttons pick an action
    menu: "back"
    menu_quit: "a"
    menu_fps: "x"
    menu_music: "b"
  }
}

love.conf = (t) ->
  t.version = "11.5"
  t.identity = "wallrun"
  -- the window is opened in love.load once the display size is known
  t.window = nil

  t.title = "wallrun dot love"
  t.author = "leafo + i.i"
