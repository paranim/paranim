import nimgl/opengl
import paranim/gl/utils
import tables

type
  RootGame* = object of RootObj
    texCount*: Natural
  TextureOpts* = object
    mipLevel*: GLint
    internalFmt*: GLenum
    width*: GLsizei
    height*: GLsizei
    border*: GLint
    srcFmt*: GLenum
    srcType*: GLenum
  Texture* = object
    data*: seq[uint8]
    opts*: TextureOpts
    params*: seq[(GLenum, GLenum)]
  UncompiledEntity*[T] = object of RootObj
    vertexSource*: string
    fragmentSource*: string
    textureUniforms*: Table[string, Texture]
    uniforms*: Table[string, seq[cfloat]]
    attributes*: Table[string, Attribute]
  Entity* = object of RootObj
    drawCount*: GLsizei
    program*: GLuint
    attributeBuffers*: Table[string, GLuint]

proc createTexture*(game: var RootGame, uniLoc: GLint, texture: Texture): GLint =
  game.texCount += 1
  let unit = game.texCount - 1
  var textureNum: GLuint
  glGenTextures(1, textureNum.addr)
  glActiveTexture(GLenum(GL_TEXTURE0.ord + unit))
  glBindTexture(GL_TEXTURE_2D, textureNum)
  for (paramName, paramVal) in texture.params:
    glTexParameteri(GL_TEXTURE_2D, paramName, GLint(paramVal))
  # TODO: alignment
  glTexImage2D(
    GL_TEXTURE_2D,
    texture.opts.mipLevel,
    GLint(texture.opts.internalFmt),
    texture.opts.width,
    texture.opts.height,
    texture.opts.border,
    texture.opts.srcFmt,
    texture.opts.srcType,
    texture.data[0].unsafeAddr
  )
  # TODO: mipmap
  GLint(unit)

proc setBuffer(game: RootGame, entity: Entity, program: GLuint, divisorToDrawCount: var Table[int, GLsizei], attrName: string, attr: Attribute) =
  let
    buffer = entity.attributeBuffers[attrName]
    divisor = attr.divisor
    drawCount = setArrayBuffer(program, buffer, attrName, attr)
  if divisorToDrawCount.hasKey(divisor) and divisorToDrawCount[divisor] != drawCount:
    raise newException(Exception, "The data in the " & attrName & " attribute has an inconsistent size")
  divisorToDrawCount[divisor] = drawCount

proc setBuffers(game: RootGame, uncompiledEntity: UncompiledEntity, entity: var Entity, program: GLuint) =
  var divisorToDrawCount: Table[int, GLsizei]
  for (attrName, attr) in uncompiledEntity.attributes.pairs:
    setBuffer(game, entity, program, divisorToDrawCount, attrName, attr)
  if divisorToDrawCount.hasKey(0):
    entity.drawCount = divisorToDrawCount[0]

proc compile*[T](game: RootGame, uncompiledEntity: UncompiledEntity[T]): T =
  var
    previousProgram: GLint
    previousVao: GLint
  glGetIntegerv(GL_CURRENT_PROGRAM, previousProgram.addr)
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, previousVao.addr)
  result.program = createProgram(uncompiledEntity.vertexSource, uncompiledEntity.fragmentSource)
  glUseProgram(result.program)
  var vao: GLuint
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)
  for attrName in uncompiledEntity.attributes.keys:
    var buf: GLuint
    glGenBuffers(1, buf.addr)
    result.attributeBuffers[attrName] = buf
  setBuffers(game, uncompiledEntity, result, result.program)
