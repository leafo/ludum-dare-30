
import insert from table

export love = { graphics: {} }
lovekit = require "lovekit.init"

defines = [k for k in pairs lovekit]

for k in pairs lovekit.Sequence.default_scope
  insert defines, k

insert defines, "love"
insert defines, "CONTROLLER"
insert defines, "DISPATCHER"
insert defines, "GAME_CONFIG"
insert defines, "AUDIO"

{
  whitelist_globals: {
    ".": defines
  }
}
