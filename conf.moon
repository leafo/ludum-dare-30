export GAME_CONFIG = {
  scale: 3
  keys: {
    confirm: { "x", " " }
    cancel: "c"

    attack: { "x", " " }

    up: "up"
    down: "down"
    left: "left"
    right: "right"
  }
}

love.conf = (t) ->
  t.window.width = 300 * GAME_CONFIG.scale
  t.window.height = 200 * GAME_CONFIG.scale
  t.title = "the game"
  t.author = "leafo + co"
