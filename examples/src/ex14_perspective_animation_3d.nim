import nimgl/opengl
import paranim/gl, paranim/gl/uniforms
import paranim/math as pmath
import examples_common, examples_data
from bitops import bitor
from std/math import nil
import glm

var entity: ThreeDEntity
const rx = degToRad(190f)
var ry = degToRad(40f)
const rz = degToRad(320f)

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
  e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
  e.translate(0f, 0f, -360f)
  e.rotateX(rx)
  e.rotateY(ry)
  e.rotateZ(rz)
  render(game, e)

  ry += 1.2f * game.deltaTime

