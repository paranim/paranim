import nimgl/opengl
import paranim/gl, paranim/gl/entities
from paranim/primitives import nil
import examples_common
from glm import vec4

var entity: TwoDEntity

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  var uncompiledEntity = initTwoDEntity(primitives.rectangle[GLfloat]())
  uncompiledEntity.project(float(game.frameWidth), float(game.frameHeight))
  uncompiledEntity.translate(50f, 50f)
  uncompiledEntity.scale(100f, 100f)
  uncompiledEntity.color(vec4(1f, 0f, 0f, 1f))
  entity = compile(game, uncompiledEntity)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))
  render(game, entity)

