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

requires "nim >= 1.2.6"
requires "paranim >= 0.11.0"
requires "paratext >= 0.10.0"
requires "stb_image >= 2.5"
