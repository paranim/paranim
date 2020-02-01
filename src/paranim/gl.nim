import nimgl/opengl
import paranim/gl/utils
import algorithm
import glm

type
  RootGame* = object of RootObj
    texCount*: Natural
  Entity*[UniT, AttrT] = object of RootObj
    uniforms*: UniT
    attributes*: AttrT
  UncompiledEntity*[CompiledT, UniT, AttrT] = object of Entity[UniT, AttrT]
    vertexSource*: string
    fragmentSource*: string
  CompiledEntity*[UniT, AttrT] = object of Entity[UniT, AttrT]
    program*: GLuint
    vao*: GLuint
  ArrayEntity*[UniT, AttrT] = object of CompiledEntity[UniT, AttrT]
    drawCount*: GLsizei
  InstancedEntity*[UniT, AttrT] = object of ArrayEntity[UniT, AttrT]
    instanceCount*: GLsizei

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
    when T is GLubyte:
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

proc callUniform[CompiledT, UniT, AttrT](game: var RootGame, entity: UncompiledEntity[CompiledT, UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Texture[GLubyte]]) =
  let loc = glGetUniformLocation(program, uniName)
  uni.data.unit = createTexture(game, loc, uni.data)

proc callUniform[UniT, AttrT](game: RootGame, entity: CompiledEntity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Texture[GLubyte]]) =
  let loc = glGetUniformLocation(program, uniName)
  glUniform1i(loc, uni.data.unit)

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[GLfloat]) =
  let loc = glGetUniformLocation(program, uniName)
  glUniform1f(loc, uni.data)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[GLint]) =
  let loc = glGetUniformLocation(program, uniName)
  glUniform1i(loc, uni.data)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[GLuint]) =
  let loc = glGetUniformLocation(program, uniName)
  glUniform1ui(loc, uni.data)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec2[GLfloat]]) =
  let loc = glGetUniformLocation(program, uniName)
  var data = uni.data
  glUniform2fv(loc, 1, data.caddr)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec3[GLfloat]]) =
  let loc = glGetUniformLocation(program, uniName)
  var data = uni.data
  glUniform3fv(loc, 1, data.caddr)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec4[GLfloat]]) =
  let loc = glGetUniformLocation(program, uniName)
  var data = uni.data
  glUniform4fv(loc, 1, data.caddr)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Mat2x2[GLfloat]]) =
  let loc = glGetUniformLocation(program, uniName)
  var data = uni.data.transpose()
  glUniformMatrix2fv(loc, 1, false, data.caddr)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Mat3x3[GLfloat]]) =
  let loc = glGetUniformLocation(program, uniName)
  var data = uni.data.transpose()
  glUniformMatrix3fv(loc, 1, false, data.caddr)
  uni.enable = false

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Mat4x4[GLfloat]]) =
  let loc = glGetUniformLocation(program, uniName)
  var data = uni.data.transpose()
  glUniformMatrix4fv(loc, 1, false, data.caddr)
  uni.enable = false

proc initBuffer(attr: var Attribute) =
  var buf: GLuint
  glGenBuffers(1, buf.addr)
  attr.buffer = buf

proc setBuffer[UniT, AttrT](game: RootGame, entity: ArrayEntity[UniT, AttrT], drawCounts: var array[maxDivisor+1, int], attrName: string, attr: Attribute) =
  let
    divisor = attr.divisor
    drawCount = setArrayBuffer(entity.program, attrName, attr)
  if drawCounts[divisor] >= 0 and drawCounts[divisor] != drawCount:
    raise newException(Exception, "The data in the " & attrName & " attribute has an inconsistent size")
  drawCounts[divisor] = drawCount

proc setBuffers[UniT, AttrT](game: RootGame, entity: var ArrayEntity[UniT, AttrT]) =
  var drawCounts: array[maxDivisor+1, int]
  drawCounts.fill(-1)
  for attrName, attr in entity.attributes.fieldPairs:
    if attr.enable:
      setBuffer(game, entity, drawCounts, attrName, attr)
      attr.enable = false
  if drawCounts[0] >= 0:
    entity.drawCount = GLsizei(drawCounts[0])

proc setBuffers[UniT, AttrT](game: RootGame, entity: var InstancedEntity[UniT, AttrT]) =
  var drawCounts: array[maxDivisor+1, int]
  drawCounts.fill(-1)
  for attrName, attr in entity.attributes.fieldPairs:
    if attr.enable:
      setBuffer(game, entity, drawCounts, attrName, attr)
      attr.enable = false
  if drawCounts[0] >= 0:
    entity.drawCount = GLsizei(drawCounts[0])
  if drawCounts[1] >= 0:
    entity.instanceCount = GLsizei(drawCounts[1])

proc compile*[CompiledT, UniT, AttrT](game: var RootGame, uncompiledEntity: UncompiledEntity[CompiledT, UniT, AttrT]): CompiledT =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  result.program = createProgram(uncompiledEntity.vertexSource, uncompiledEntity.fragmentSource)
  glUseProgram(result.program)
  glGenVertexArrays(1, result.vao.addr)
  glBindVertexArray(result.vao)
  result.attributes = uncompiledEntity.attributes
  result.uniforms = uncompiledEntity.uniforms
  for attr in result.attributes.fields:
    initBuffer(attr)
  setBuffers(game, result)
  for name, uni in result.uniforms.fieldPairs:
    if uni.enable:
      callUniform(game, uncompiledEntity, result.program, name, uni)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)

proc render*[UniT, AttrT](game: RootGame, entity: var ArrayEntity[UniT, AttrT]) =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  glUseProgram(entity.program)
  glBindVertexArray(entity.vao)
  for name, uni in entity.uniforms.fieldPairs:
    if uni.enable:
      callUniform(game, entity, entity.program, name, uni)
  glDrawArrays(GL_TRIANGLES, 0, entity.drawCount)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)

proc render*[UniT, AttrT](game: RootGame, entity: var InstancedEntity[UniT, AttrT]) =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  glUseProgram(entity.program)
  glBindVertexArray(entity.vao)
  for name, uni in entity.uniforms.fieldPairs:
    if uni.enable:
      callUniform(game, entity, entity.program, name, uni)
  glDrawArraysInstanced(GL_TRIANGLES, 0, entity.drawCount, entity.instanceCount)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)
