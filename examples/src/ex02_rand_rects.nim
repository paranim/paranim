import nimgl/opengl
import paranim/gl, paranim/gl/entities2d, paranim/primitives2d
import random

randomize()

var entity: InstancedTwoDEntity

proc init*(game: var RootGame) =
  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  let baseEntity = initTwoDEntity(rect)
  var uncompiledEntity = initInstancedEntity(baseEntity)

  for _ in 0 ..< 50:
    var e = baseEntity
    e.project(800f, 600f)
    e.translate(cfloat(rand(800)), cfloat(rand(600)))
    e.scale(cfloat(rand(300)), cfloat(rand(300)))
    e.color([cfloat(rand(1.0)), cfloat(rand(1.0)), cfloat(rand(1.0)), 1f])
    uncompiledEntity.add(e)

  entity = compile(game, uncompiledEntity)

proc tick*(game: RootGame) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, 800, 600)
  render(game, entity)

