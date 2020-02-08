import nimgl/opengl
import paranim/gl, paranim/gl/entities
from paranim/primitives import nil
import random
import examples_common
from glm import vec4

randomize()

var entity: InstancedTwoDEntity

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  let baseEntity = initTwoDEntity(primitives.rect)
  var uncompiledEntity = initInstancedEntity(baseEntity)

  for _ in 0 ..< 50:
    var e = baseEntity
    e.project(float(game.frameWidth), float(game.frameHeight))
    e.translate(cfloat(rand(game.frameWidth)), cfloat(rand(game.frameHeight)))
    e.scale(cfloat(rand(300)), cfloat(rand(300)))
    e.color(vec4(cfloat(rand(1.0)), cfloat(rand(1.0)), cfloat(rand(1.0)), 1f))
    uncompiledEntity.add(e)

  entity = compile(game, uncompiledEntity)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))
  render(game, entity)

