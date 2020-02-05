import nimgl/opengl
import paranim/gl, paranim/gl/entities2d
import examples_common

var entity: TwoDEntity

proc init*(game: var Game) =
  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  entity = compile(game, initTwoDEntity(f2d))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, 800, 600)

  var e = entity
  e.project(800f, 600f)
  e.translate(game.x, game.y)
  e.color([1f, 0f, 0.5f, 1f])

  render(game, e)

