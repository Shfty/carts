--input
--collection of input wrappers
-------------------------------
--enable devkit input
poke(0x5f2d,1)

require("input/controller")
require("input/keyboard")
require("input/mouse")
