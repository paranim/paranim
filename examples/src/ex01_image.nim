import nimgl/opengl
import paranim/gl, paranim/gl/entities2d
import stb_image/read as stbi
import examples_common

const image = staticRead("assets/aintgottaexplainshit.jpg")

var entity: ImageEntity
var width, height: int

proc init*(game: var Game) =
  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  var
    channels: int
    data: seq[uint8]
  data = stbi.loadFromMemory(cast[seq[uint8]](image), width, height, channels, stbi.RGBA)
  var uncompiledImage = initImageEntity(data, width, height)
  uncompiledImage.project(float(game.windowWidth), float(game.windowHeight))
  uncompiledImage.translate(0f, 0f)
  uncompiledImage.scale(float(width), float(height))
  entity = compile(game, uncompiledImage)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.windowWidth), GLsizei(game.windowHeight))

  render(game, entity)

