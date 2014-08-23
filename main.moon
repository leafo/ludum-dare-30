
lovekit = require "lovekit.init"

{graphics: g} = love

love.load = ->
  love.draw = ->
    g.print "hello world", 10, 10

