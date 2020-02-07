import nimgl/opengl
import paranim/gl
import examples_common, examples_data
from bitops import bitor

var entity: ThreeDEntity
const tx = 0f
const ty = 0f

proc init*(game: var Game) =
  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glEnable(GL_DEPTH_TEST)

  entity = compile(game, initThreeDEntity(f3d, f3dColors))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  let
    widthRatio = float(game.frameWidth) / float(game.windowWidth)
    heightRatio = float(game.frameHeight) / float(game.windowHeight)
    x = game.mouseX * widthRatio - tx
    y = game.mouseY * heightRatio - ty
    cx = x - (float(game.frameWidth) / 2)
    cy = (float(game.frameHeight) / 2) - y

  var e = entity
  e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
  e.translate(cx, cy, -150f)
  e.rotateX(degToRad(180f))
  e.rotateY(0f)
  e.rotateZ(0f)

  render(game, e)

