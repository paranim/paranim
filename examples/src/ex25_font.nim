import nimgl/opengl
import paranim/gl, paranim/gl/entities
import paratext, paratext/gl/text
import stb_image/read as stbi
import examples_common

const ttf = staticRead("assets/Roboto-Regular.ttf")

let font = initFont(ttf = ttf, fontHeight = 64, firstChar = 32, bitmapWidth = 512, bitmapHeight = 512, charCount = 2048)

var entity: TextEntity

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  var uncompiledEntity = initTextEntity(font)
  uncompiledEntity.project(float(game.frameWidth), float(game.frameHeight))
  uncompiledEntity.translate(0f, 0f)
  uncompiledEntity.scale(float(font.bitmap.width), float(font.bitmap.height))
  entity = compile(game, uncompiledEntity)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  render(game, entity)

