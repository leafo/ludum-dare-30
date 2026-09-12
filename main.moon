require "lovekit.all"

-- if pcall(-> require"inotify")
--   require "lovekit.reloader"

{graphics: g} = love

import TitleScreen, GameOverScreen, StageComplete from require "screens"
import Game from require "game"
import draw_overlay from require "ui"

controls = require "controls"

export DEBUG = false
export CONTROLLER, SHOW_FPS

menu_actions = {
  {"menu_quit", "a: quit", -> love.event.push "quit"}
  {"menu_fps", "x: toggle fps", -> SHOW_FPS = not SHOW_FPS}
}

load_font = (img, chars)->
  with g.newImageFont img, chars
    \setFilter "nearest", "nearest"

TITLE = "wallrun dot love"

-- windowed at the design size, fullscreen on displays too small for it
-- (the RG35XX is 640x480)
-- `love . --window 640x480` or WALLRUN_WINDOW=640x480 forces a windowed size for testing
open_window = (args={}) ->
  size = os.getenv "WALLRUN_WINDOW"
  for i, arg in ipairs args
    size = args[i + 1] if arg == "--window"

  design_w = GAME_CONFIG.viewport_width * GAME_CONFIG.scale
  design_h = GAME_CONFIG.viewport_height * GAME_CONFIG.scale

  if size
    w, h = size\match "^(%d+)x(%d+)$"
    error "bad --window size, expected WxH: #{size}" unless w
    love.window.setMode tonumber(w), tonumber(h)
  else
    dw, dh = love.window.getDesktopDimensions!
    if dw < design_w or dh < design_h
      love.window.setMode 0, 0, fullscreen: true, fullscreentype: "desktop"
      love.mouse.setVisible false
    else
      love.window.setMode design_w, design_h

  love.window.setTitle TITLE

  -- integer pixel scale closest to the design width: 2 at 840 wide, 2 at 640
  GAME_CONFIG.scale = math.max 1, math.floor g.getWidth! / GAME_CONFIG.viewport_width + 0.5

love.load = (args) ->
  open_window args

  fonts = {
    default: load_font "images/font1.png", [[ ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~!"#$%&'()*+,-./0123456789:;<=>?]]
    number_font: load_font "images/number_font.png", [[0123456789:]]
  }

  g.setFont fonts.default
  -- matches the edge color of the full screen art so letterbox margins blend
  g.setBackgroundColor 26/255, 20/255, 20/255

  export AUDIO = Audio "sounds"
  AUDIO\preload {
    "step"
    "grab"
    "land"
    "hurt_enemy"
    "jump"
    "enemy_die"
    "energy_appear"
    "player_die"
    "player_attack"
    "level_complete"
    "level_fail"
    "clink"
    "confirm"
    "no_hurt"
    "door_ready"
  }

  export FONTS = fonts
  CONTROLLER = controls.make_controller!

  import Player from require "player"

  -- hidden two player versus mode, reached by a button combo on the title
  -- screen. player two is the second gamepad or wasd on the keyboard
  new_multiplayer_game = ->
    import MultiWorld from require "multi_world"
    Game MultiWorld, =>
      export CONTROLLER_2 = controls.make_controller 2, GAME_CONFIG.keys2
      p2 = Player CONTROLLER_2, 0,0
      p2\set_color 60,60,240
      @world\add_player p2

  export DISPATCHER = Dispatcher TitleScreen Game!, new_multiplayer_game

  DISPATCHER.default_transition = FadeTransition
  DISPATCHER\bind love

  love.joystickadded = controls.refresh_controller
  love.joystickremoved = controls.refresh_controller

  -- the menu pauses everything underneath while select is held
  dispatch_update = love.update
  love.update = (dt) ->
    if controls.menu_open!
      for {name, _, fn} in *menu_actions
        fn! if CONTROLLER\downed name
      return

    dispatch_update dt

  dispatch_draw = love.draw
  love.draw = ->
    dispatch_draw!

    if SHOW_FPS
      g.push!
      g.origin!
      g.scale GAME_CONFIG.scale
      g.print tostring(love.timer.getFPS!), 2, 2
      g.pop!

    if controls.menu_open!
      draw_overlay [label for {_, label} in *menu_actions]

