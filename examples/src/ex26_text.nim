import nimgl/opengl
import paranim/gl, paranim/gl/entities
import paratext, paratext/gl/text
import stb_image/read as stbi
import examples_common
from glm import vec4

const ttf = staticRead("assets/Roboto-Regular.ttf")

var
  count: int
  font: Font
  baseEntity: UncompiledTextEntity
  helloEntity: InstancedTextEntity
  colorEntity: InstancedTextEntity
  countEntity: InstancedTextEntity

proc add(instancedEntity: var InstancedTextEntity, entity: UncompiledTextEntity, font: Font, text: string) =
  var
    x = 0f
    i = 0
  for ch in text:
    let
      charIndex = int(ch) - font.firstChar
      bakedChar = font.chars[charIndex]
    var e = entity
    e.crop(bakedChar, x, font.baseline)
    if i == instancedEntity.instanceCount:
      instancedEntity.add(e)
    else:
      instancedEntity[i] = e
    x += bakedChar.xadvance
    i += 1

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  font = initFont(ttf = ttf, fontHeight = 64, firstChar = 32, bitmapWidth = 512, bitmapHeight = 512, charCount = 2048)
  baseEntity = initTextEntity(font)

  let
    uncompiledEntity = initInstancedEntity(baseEntity)
    compiledEntity = compile(game, uncompiledEntity)

  # we can create separate text entities by doing a deepCopy
  # on the compiled text entity.
  # this ensures that they don't share attribute data.

  helloEntity = deepCopy(compiledEntity)
  helloEntity.add(baseEntity, font, "Hello, world!")

  colorEntity = deepCopy(compiledEntity)
  colorEntity.add(baseEntity, font, "Colors")

  const colors = [
    vec4(1f, 0f, 0f, 1f),
    vec4(0f, 1f, 0f, 1f),
    vec4(0f, 0f, 1f, 1f),
  ]
  for i in 0 ..< colorEntity.instanceCount:
    var e = colorEntity[i]
    e.color(colors[i mod colors.len])
    colorEntity[i] = e

  countEntity = deepCopy(compiledEntity)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GL_COLOR_BUFFER_BIT)
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  var e1 = helloEntity
  e1.project(float(game.frameWidth), float(game.frameHeight))
  e1.translate(0f, 0f)
  render(game, e1)

  var e2 = colorEntity
  e2.project(float(game.frameWidth), float(game.frameHeight))
  e2.translate(0f, 100f)
  render(game, e2)

  countEntity.add(baseEntity, font, "Frame count: " & $count)
  count += 1

  var e3 = countEntity
  e3.project(float(game.frameWidth), float(game.frameHeight))
  e3.translate(0f, 200f)
  render(game, e3)

