import nimgl/opengl
import paranim/gl, paranim/gl/uniforms
import examples_common
from bitops import bitor
from paranim/primitives import nil
import random
from math import nil
import glm

randomize()

var entity: IndexedThreeDEntity
var objects: seq[IndexedThreeDObject]

for _ in 0 ..< 50:
  objects.add((
    tz: GLfloat(rand(150.0)),
    rx: GLfloat(rand(2 * math.PI)),
    ry: GLfloat(rand(math.PI)),
    matUniforms: (
      u_color: Uniform[Vec4[GLfloat]](data: vec4[GLfloat](rand(1.0), rand(1.0), rand(1.0), 1.0)),
      u_specular: Uniform[Vec4[GLfloat]](data: vec4[GLfloat](1.0, 1.0, 1.0, 1.0)),
      u_shininess: Uniform[GLfloat](data: rand(500.0)),
      u_specularFactor: Uniform[GLfloat](data: rand(1.0))
    )
  ))

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glEnable(GL_DEPTH_TEST)

  let shape = primitives.crescent[GLfloat, GLushort](verticalRadius = 20, outerRadius = 20, innerRadius = 15, thickness = 10, subdivisionsDown = 30)
  let uncompiledEntity = initIndexedThreeDEntity(shape.positions, shape.normals, shape.texcoords, shape.indexes)
  entity = compile(game, uncompiledEntity)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  var e = entity
  renderIndexedEntity(game, e, objects)

