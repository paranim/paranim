import nimgl/opengl
import paranim/gl, paranim/gl/entities
import stb_image/read as stbi
import examples_common

const image = staticRead("assets/aintgottaexplainshit.jpg")

var entity: ImageEntity
var width, height: int

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  var channels: int
  var data = stbi.loadFromMemory(cast[seq[uint8]](image), width, height, channels, stbi.RGBA)
  var uncompiledImage = initImageEntity(data, width, height)
  entity = compile(game, uncompiledImage)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  var e = entity
  e.project(float(game.frameWidth), float(game.frameHeight))
  e.translate(0f, 0f)
  e.scale(float(width), float(height))
  render(game, e)

