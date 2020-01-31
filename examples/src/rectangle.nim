import nimgl/opengl
import paranim/gl, paranim/gl/entities2d, paranim/primitives2d

type
  Game* = object of RootGame

var entity: TwoDEntity

proc init*(game: var Game) =
  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  var uncompiledEntity = init2DEntity(game, rect)

  uncompiledEntity.project(800f, 600f)
  uncompiledEntity.translate(50f, 50f)
  uncompiledEntity.scale(50f, 50f)
  uncompiledEntity.color([1f, 0f, 0f, 1f])

  entity = compile(game, uncompiledEntity)

proc tick*(game: Game) =
  glClearColor(173/255, 216/255, 230/255, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, 800, 600)
  render(game, entity)

