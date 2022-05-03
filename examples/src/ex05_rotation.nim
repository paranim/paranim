import paranim/opengl
import paranim/gl, paranim/gl/entities
import examples_common, examples_data
from math import nil
from paranim/glm import vec4

var entity: TwoDEntity
const tx = 100f
const ty = 100f

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  entity = compile(game, initTwoDEntity(f2d))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  let
    x = game.mouseX - tx
    y = game.mouseY - ty
    rx = x / float(game.frameWidth)
    ry = y / float(game.frameHeight)
    r = math.arctan2(rx, ry)

  var e = entity
  e.project(float(game.frameWidth), float(game.frameHeight))
  e.translate(tx, ty)
  e.rotate(r)
  e.translate(-50f, -75f)
  e.color(vec4(1f, 0f, 0.5f, 1f))

  render(game, e)

