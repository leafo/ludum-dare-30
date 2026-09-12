{:joystick} = love

-- all joysticks with a gamepad mapping, keyboards and other HID devices
-- show up as joysticks too and raw buttons on them cause phantom input
find_pads = ->
  [j for j in *joystick.getJoysticks! when j\isGamepad!]

-- controller for the nth mapped gamepad, keyboard only if there isn't one
make_controller = (pad_idx=1, keys=GAME_CONFIG.keys) ->
  pad = find_pads![pad_idx]
  controller = Controller keys, pad

  if pad
    controller\add_mapping {name, {joystick: btns} for name, btns in pairs GAME_CONFIG.gamepad}

  controller

-- rebind the global controller in place on hot-plug, the player and any
-- other object holding a reference keeps working
refresh_controller = ->
  for k, v in pairs make_controller!
    CONTROLLER[k] = v

has_pad = -> CONTROLLER.joystick != nil

-- button names for on screen prompts
prompts = {
  confirm: -> if has_pad! then "a" else "space"
  jump: -> if has_pad! then "a" else "x"
  attack: -> if has_pad! then "b" else "c"
  pause: -> if has_pad! then "start" else "p"
}

-- holding select shows a menu where the face buttons run actions
menu_open = -> CONTROLLER\is_down "menu"

{ :make_controller, :refresh_controller, :has_pad, :prompts, :menu_open }
