import paranim/opengl
import paranim/gl, paranim/gl/uniforms
import paranim/math as pmath
import examples_common, examples_data
from bitops import bitor
from std/math import nil
import paranim/glm

var entity: ThreeDEntity
const tx = 0f
const ty = 0f
const radius = 200f
const numFs = 5

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glEnable(GL_DEPTH_TEST)

  entity = compile(game, initThreeDEntity(transformData(f3d), f3dColors))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  let
    x = game.mouseX - tx
    cx = x - (float(game.frameWidth) / 2)
    cr = degToRad((cx / float(game.frameWidth)) * 360f)

  var camera = mat4f(1)
  camera.rotateY(cr)
  camera.translate(0f, 0f, radius * 1.5f)

  for i in 0 ..< numFs:
    let
      angle = (float(i) * math.PI * 2f) / float(numFs)
      x = math.cos(angle) * radius
      z = math.sin(angle) * radius
    var e = entity
    e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
    e.invert(camera)
    e.translate(x, 0f, z)
    render(game, e)

