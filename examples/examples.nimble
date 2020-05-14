# Package

version       = "0.1.0"
author        = "oakes"
description   = "Paranim examples"
license       = "Public Domain"
srcDir        = "src"
bin           = @["examples"]

task dev, "Run dev version":
  exec "nimble run examples"


# Dependencies

requires "nim >= 1.0.4"
requires "paranim >= 0.6.0"
requires "paratext >= 0.5.0"
requires "stb_image >= 2.5"
