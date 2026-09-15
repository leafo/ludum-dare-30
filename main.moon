require "lovekit.all"

-- if pcall(-> require"inotify")
--   require "lovekit.reloader"

{graphics: g} = love

import TitleScreen, GameOverScreen, StageComplete from require "screens"
import Game from require "game"
import draw_overlay from require "ui"

controls = require "controls"
import open_window from require "lovekit.window"

export DEBUG = false
export CONTROLLER, SHOW_FPS, MUSIC_OFF

toggle_music = ->
  MUSIC_OFF = not MUSIC_OFF
  if MUSIC_OFF
    AUDIO.music\stop! if AUDIO.music
  else
    -- pick the music back up if the current level already started it
    game = DISPATCHER\top!
    if game.world and game.world.seen_enemy
      game.world\start_audio!

-- labels can be functions for ones that show state
menu_actions = {
  {"menu_quit", "a: quit", -> love.event.push "quit"}
  {"menu_fps", "x: toggle fps", -> SHOW_FPS = not SHOW_FPS}
  {"menu_music", (-> if MUSIC_OFF then "b: music off" else "b: music on"), toggle_music}
}

menu_labels = ->
  [(if type(label) == "function" then label! else label) for {_, label} in *menu_actions]

load_font = (img, chars)->
  with g.newImageFont img, chars
    \setFilter "nearest", "nearest"

TITLE = "wallrun dot love"

love.load = (args) ->
  open_window {
    title: TITLE
    env: "WALLRUN_WINDOW"
    :args
    design_w: GAME_CONFIG.viewport_width * GAME_CONFIG.scale
    design_h: GAME_CONFIG.viewport_height * GAME_CONFIG.scale
  }

  -- whole scale that covers the screen: 2 at 840x544 and 640x480, 3 at 1024x768
  GAME_CONFIG.scale = pixel_scale_for GAME_CONFIG.viewport_width, GAME_CONFIG.viewport_height, cover: true

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

  export new_title = -> TitleScreen Game!, new_multiplayer_game
  export DISPATCHER = Dispatcher new_title!

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
      draw_overlay menu_labels!

