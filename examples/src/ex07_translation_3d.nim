import nimgl/opengl
import paranim/gl, paranim/gl/entities3d
import examples_common
from bitops import bitor

var entity: ThreeDEntity

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

  var e = entity
  e.project(0f, float(game.frameWidth), float(game.frameHeight), 0f, 400f, -400f)
  e.translate(game.mouseX, game.mouseY, 0f)
  e.rotate(degToRad(40f), XAxis)
  e.rotate(degToRad(25f), YAxis)
  e.rotate(degToRad(325f), ZAxis)

  render(game, e)

