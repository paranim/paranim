import nimgl/opengl
import paranim/gl/utils
import tables
import glm

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
  Texture*[T] = object
    data*: seq[T]
    opts*: TextureOpts
    params*: seq[(GLenum, GLenum)]
  UncompiledEntity*[CompiledT, UniT, AttrT] = object of RootObj
    vertexSource*: string
    fragmentSource*: string
    uniforms*: UniT
    attributes*: AttrT
  Uniform = object
    kind: string
    location: GLint
  Entity*[UniT, AttrT] = object of RootObj
    drawCount*: GLsizei
    program*: GLuint
    attributeBuffers*: Table[string, GLuint]
    uniforms*: UniT
    attributes*: AttrT

proc createTexture[T](game: var RootGame, uniLoc: GLint, texture: Texture[T]): GLint =
  game.texCount += 1
  let unit = game.texCount - 1
  var textureNum: GLuint
  glGenTextures(1, textureNum.addr)
  glActiveTexture(GLenum(GL_TEXTURE0.ord + unit))
  glBindTexture(GL_TEXTURE_2D, textureNum)
  for (paramName, paramVal) in texture.params:
    glTexParameteri(GL_TEXTURE_2D, paramName, GLint(paramVal))
  # TODO: alignment
  let srcType =
    when T is uint8:
      GL_UNSIGNED_BYTE
    else:
      raise newException(Exception, "Invalid texture type")
  glTexImage2D(
    GL_TEXTURE_2D,
    texture.opts.mipLevel,
    GLint(texture.opts.internalFmt),
    texture.opts.width,
    texture.opts.height,
    texture.opts.border,
    texture.opts.srcFmt,
    srcType,
    texture.data[0].unsafeAddr
  )
  # TODO: mipmap
  GLint(unit)

proc callUniform[UniT, AttrT](game: var RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Texture) =
  let loc = glGetUniformLocation(entity.program, uniName)
  let unit = createTexture(game, loc, uniData)
  glUniform1i(loc, unit)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: GLfloat) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData
  glUniform1f(loc, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: GLint) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData
  glUniform1i(loc, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: GLuint) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData
  glUniform1ui(loc, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Vec2[GLfloat]) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData
  glUniform2fv(loc, 1, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Vec3[GLfloat]) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData
  glUniform3fv(loc, 1, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Vec4[GLfloat]) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData
  glUniform4fv(loc, 1, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Mat2x2[GLfloat]) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData.transpose()
  glUniformMatrix2fv(loc, 1, false, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Mat3x3[GLfloat]) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData.transpose()
  glUniformMatrix3fv(loc, 1, false, data.caddr)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], uniName: string, uniData: Mat4x4[GLfloat]) =
  let loc = glGetUniformLocation(entity.program, uniName)
  var data = uniData.transpose()
  glUniformMatrix4fv(loc, 1, false, data.caddr)

proc setBuffer(game: RootGame, entity: Entity, divisorToDrawCount: var Table[int, GLsizei], attrName: string, attr: Attribute) =
  let
    buffer = entity.attributeBuffers[attrName]
    divisor = attr.divisor
    drawCount = setArrayBuffer(entity.program, buffer, attrName, attr)
  if divisorToDrawCount.hasKey(divisor) and divisorToDrawCount[divisor] != drawCount:
    raise newException(Exception, "The data in the " & attrName & " attribute has an inconsistent size")
  divisorToDrawCount[divisor] = drawCount

proc setBuffers[UniT, AttrT](game: RootGame, uncompiledEntity: UncompiledEntity, entity: var Entity[UniT, AttrT]) =
  var divisorToDrawCount: Table[int, GLsizei]
  for attrName, attr in uncompiledEntity.attributes.fieldPairs:
    setBuffer(game, entity, divisorToDrawCount, attrName, attr)
  if divisorToDrawCount.hasKey(0):
    entity.drawCount = divisorToDrawCount[0]

proc compile*[CompiledT, UniT, AttrT](game: var RootGame, uncompiledEntity: UncompiledEntity[CompiledT, UniT, AttrT]): CompiledT =
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
  for attrName, _ in uncompiledEntity.attributes.fieldPairs:
    var buf: GLuint
    glGenBuffers(1, buf.addr)
    result.attributeBuffers[attrName] = buf
  setBuffers(game, uncompiledEntity, result)
  for name, data in uncompiledEntity.uniforms.fieldPairs:
    callUniform(game, result, name, data)
