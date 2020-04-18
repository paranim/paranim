import nimgl/opengl
import paranim/gl/attributes, paranim/gl/uniforms
from paranim/gl/utils import nil
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
  IndexedEntity*[UniT, AttrT] = object of ArrayEntity[UniT, AttrT]
  InstancedIndexedEntity*[UniT, AttrT] = object of ArrayEntity[UniT, AttrT]
    instanceCount*: GLsizei

proc createTexture[T](game: var RootGame, uniLoc: GLint, texture: Texture[T]): tuple[unit: GLint, textureNum: GLuint] =
  let unit = game.texCount
  game.texCount += 1
  var textureNum: GLuint
  glGenTextures(1, textureNum.addr)
  glActiveTexture(GLenum(GL_TEXTURE0.ord + unit))
  glBindTexture(GL_TEXTURE_2D, textureNum)
  for (paramName, paramVal) in texture.params:
    glTexParameteri(GL_TEXTURE_2D, paramName, GLint(paramVal))
  for (paramName, paramVal) in texture.pixelStoreParams:
    glPixelStorei(paramName, paramVal)
  const srcType = utils.getTypeEnum(T)
  glTexImage2D(
    GL_TEXTURE_2D,
    texture.opts.mipLevel,
    GLint(texture.opts.internalFmt),
    texture.opts.width,
    texture.opts.height,
    texture.opts.border,
    texture.opts.srcFmt,
    srcType,
    if texture.data == nil: nil else: texture.data[0].unsafeAddr
  )
  for paramVal in texture.mipmapParams:
    glGenerateMipmap(paramVal)
  (unit: GLint(unit), textureNum: textureNum)

proc getUniformLocation(program: GLuint, uniName: string): GLint =
  result = glGetUniformLocation(program, uniName)
  if result == -1:
    raise newException(Exception, "Uniform not found: " & uniName)

proc callUniform[CompiledT, UniT, AttrT, TexT](game: var RootGame, entity: UncompiledEntity[CompiledT, UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Texture[TexT]]) =
  let loc = getUniformLocation(program, uniName)
  let (unit, _) = createTexture(game, loc, uni.data)
  uni.data.unit = unit
  uni.data.data = nil # we don't need to hold on to the texture anymore
  glUniform1i(loc, uni.data.unit)
  uni.disable = true

proc callUniform[UniT, AttrT, TexT](game: RootGame, entity: CompiledEntity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Texture[TexT]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1i(loc, uni.data.unit)
  uni.disable = true

proc callUniform[GameT, CompiledT, UniT, AttrT, TexT](game: var GameT, entity: UncompiledEntity[CompiledT, UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[RenderToTexture[TexT, GameT]]) =
  let loc = getUniformLocation(program, uniName)
  let (unit, textureNum) = createTexture(game, loc, uni.data)
  uni.data.unit = unit
  glUniform1i(loc, uni.data.unit)
  # create framebuffer
  if uni.data.data != nil:
    raise newException(Exception, "The data for RenderToTexture must be nil")
  var
    fb: GLuint
    prevFb: GLuint
  glGenFramebuffers(1, fb.addr)
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, cast[ptr GLint](prevFb.addr))
  glBindFramebuffer(GL_FRAMEBUFFER, fb)
  glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureNum, 0)
  glBindFramebuffer(GL_FRAMEBUFFER, prevFb)
  uni.data.framebuffer = fb

proc callUniform[GameT, UniT, AttrT, Text](game: GameT, entity: CompiledEntity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[RenderToTexture[TexT, GameT]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1i(loc, uni.data.unit)
  var
    prevFb: GLuint
    prevViewport: array[4, GLint]
  glGetIntegerv(GL_FRAMEBUFFER_BINDING, cast[ptr GLint](prevFb.addr))
  glGetIntegerv(GL_VIEWPORT, cast[ptr GLint](prevViewport.addr))
  glBindFramebuffer(GL_FRAMEBUFFER, uni.data.framebuffer)
  uni.data.render(game)
  glBindFramebuffer(GL_FRAMEBUFFER, prevFb)
  glViewport(prevViewport[0], prevViewport[1], prevViewport[2], prevViewport[3])

# uniform arrays

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[seq[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1fv(loc, uni.data.len.GLsizei, uni.data[0].addr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[seq[Vec2[GLfloat]]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform2fv(loc, uni.data.len.GLsizei, cast[ptr GLfloat](uni.data[0].addr))
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[seq[Vec3[GLfloat]]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform3fv(loc, uni.data.len.GLsizei, cast[ptr GLfloat](uni.data[0].addr))
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[seq[Vec4[GLfloat]]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform4fv(loc, uni.data.len.GLsizei, cast[ptr GLfloat](uni.data[0].addr))
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[seq[GLint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1iv(loc, uni.data.len.GLsizei, uni.data[0].addr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[seq[GLuint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1uiv(loc, uni.data.len.GLsizei, uni.data[0].addr)
  uni.disable = true

# uniform scalars

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[GLfloat]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1f(loc, uni.data)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[GLint]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1i(loc, uni.data)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[GLuint]) =
  let loc = getUniformLocation(program, uniName)
  glUniform1ui(loc, uni.data)
  uni.disable = true

# uniform vecs

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec2[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform2fv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec3[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform3fv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec4[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform4fv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec2[GLint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform2iv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec3[GLint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform3iv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec4[GLint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform4iv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec2[GLuint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform2uiv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec3[GLuint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform3uiv(loc, 1, uni.data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Vec4[GLuint]]) =
  let loc = getUniformLocation(program, uniName)
  glUniform4uiv(loc, 1, uni.data.caddr)
  uni.disable = true

# uniform matrixes

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Mat2x2[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  var data = uni.data.transpose()
  glUniformMatrix2fv(loc, 1, false, data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Mat3x3[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  var data = uni.data.transpose()
  glUniformMatrix3fv(loc, 1, false, data.caddr)
  uni.disable = true

proc callUniform[UniT, AttrT](game: RootGame, entity: Entity[UniT, AttrT], program: GLuint, uniName: string, uni: var UniForm[Mat4x4[GLfloat]]) =
  let loc = getUniformLocation(program, uniName)
  var data = uni.data.transpose()
  glUniformMatrix4fv(loc, 1, false, data.caddr)
  uni.disable = true

proc initBuffer(): GLuint =
  glGenBuffers(1, result.addr)

type
  Counts = tuple[drawCounts: array[maxDivisor+1, int], indexBufferCount: int, textureBufferCount: int]
  DivisorAndDrawCount = tuple[divisor: int, drawCount: int]

proc setAttribute[UniT, AttrT](entity: var CompiledEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var Attribute): DivisorAndDrawCount =
  let
    divisor = attr.divisor
    drawCount = setAttribute(entity.program, attrName, attr)
  if counts.drawCounts[divisor] >= 0 and counts.drawCounts[divisor] != drawCount:
    raise newException(Exception, "The data in the " & attrName & " attribute has an inconsistent size")
  counts.drawCounts[divisor] = drawCount
  (divisor, drawCount.int)

proc setIndexBuffer[UniT, AttrT](entity: var ArrayEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var IndexBuffer) =
  if counts.indexBufferCount > 0:
    raise newException(Exception, "Can't set " & attrName & " because there may only be one attribute of the type IndexBuffer")
  counts.indexBufferCount = 1
  entity.drawCount = setIndexBuffer(attr)
  attr.disable = true

proc setBuffer[UniT, AttrT](entity: var ArrayEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var Attribute) =
  let (divisor, drawCount) = setAttribute(entity, counts, attrName, attr)
  if divisor == 0:
    entity.drawCount = GLsizei(drawCount)
  attr.disable = true

proc setBuffer[UniT, AttrT](entity: var InstancedEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var Attribute) =
  let (divisor, drawCount) = setAttribute(entity, counts, attrName, attr)
  if divisor == 0:
    entity.drawCount = GLsizei(drawCount)
  elif divisor == 1:
    entity.instanceCount = GLsizei(drawCount)
  attr.disable = true

proc setBuffer[UniT, AttrT](entity: var ArrayEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var TextureBuffer) =
  if counts.textureBufferCount > 0:
    raise newException(Exception, "Can't set " & attrName & " because there may only be one attribute of the type TextureBuffer")
  counts.textureBufferCount = 1
  discard setTextureBuffer(attr)
  attr.disable = true

proc setBuffer[UniT, AttrT](entity: var IndexedEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var IndexBuffer) =
  setIndexBuffer(entity, counts, attrName, attr)

proc setBuffer[UniT, AttrT](entity: var InstancedIndexedEntity[UniT, AttrT], counts: var Counts, attrName: string, attr: var IndexBuffer) =
  setIndexBuffer(entity, counts, attrName, attr)

template setBuffers(entity: var untyped) =
  var counts: Counts
  counts.drawCounts.fill(-1)
  for attrName, attr in entity.attributes.fieldPairs:
    if not attr.disable:
      setBuffer(entity, counts, attrName, attr)

proc compile*[GameT, CompiledT, UniT, AttrT](game: var GameT, uncompiledEntity: UncompiledEntity[CompiledT, UniT, AttrT]): CompiledT =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  result.program = utils.createProgram(uncompiledEntity.vertexSource, uncompiledEntity.fragmentSource)
  glUseProgram(result.program)
  glGenVertexArrays(1, result.vao.addr)
  glBindVertexArray(result.vao)
  result.attributes = uncompiledEntity.attributes
  result.uniforms = uncompiledEntity.uniforms
  for attr in result.attributes.fields:
    attr.buffer = initBuffer()
  setBuffers(result)
  for name, uni in result.uniforms.fieldPairs:
    if not uni.disable:
      callUniform(game, uncompiledEntity, result.program, name, uni)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)

proc render*[GameT, UniT, AttrT](game: GameT, entity: var ArrayEntity[UniT, AttrT]) =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  glUseProgram(entity.program)
  glBindVertexArray(entity.vao)
  setBuffers(entity)
  for name, uni in entity.uniforms.fieldPairs:
    if not uni.disable:
      callUniform(game, entity, entity.program, name, uni)
  for attr in entity.attributes.fields:
    when attr is TextureBuffer[auto]:
      glActiveTexture(GLenum(GL_TEXTURE0.ord + attr.unit))
      glBindTexture(GL_TEXTURE_BUFFER, attr.textureNum)
  glDrawArrays(GL_TRIANGLES, 0, entity.drawCount)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)

proc render*[GameT, UniT, AttrT](game: GameT, entity: var InstancedEntity[UniT, AttrT]) =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  glUseProgram(entity.program)
  glBindVertexArray(entity.vao)
  setBuffers(entity)
  for name, uni in entity.uniforms.fieldPairs:
    if not uni.disable:
      callUniform(game, entity, entity.program, name, uni)
  for attr in entity.attributes.fields:
    when attr is TextureBuffer[auto]:
      glActiveTexture(GLenum(GL_TEXTURE0.ord + attr.unit))
      glBindTexture(GL_TEXTURE_BUFFER, attr.textureNum)
  glDrawArraysInstanced(GL_TRIANGLES, 0, entity.drawCount, entity.instanceCount)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)

proc drawElements[UniT, AttrT, IndexT](entity: IndexedEntity[UniT, AttrT], indexes: IndexBuffer[IndexT]) =
  const kind = utils.getTypeEnum(IndexT)
  glDrawElements(GL_TRIANGLES, entity.drawCount, kind, indexes.data[0].unsafeAddr)

proc render*[GameT, UniT, AttrT](game: GameT, entity: var IndexedEntity[UniT, AttrT]) =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  glUseProgram(entity.program)
  glBindVertexArray(entity.vao)
  setBuffers(entity)
  for name, uni in entity.uniforms.fieldPairs:
    if not uni.disable:
      callUniform(game, entity, entity.program, name, uni)
  for attr in entity.attributes.fields:
    when attr is TextureBuffer[auto]:
      glActiveTexture(GLenum(GL_TEXTURE0.ord + attr.unit))
      glBindTexture(GL_TEXTURE_BUFFER, attr.textureNum)
  for attr in entity.attributes.fields:
    when attr is IndexBuffer[auto]:
      drawElements(entity, attr)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)

proc drawElements[UniT, AttrT, IndexT](entity: InstancedIndexedEntity[UniT, AttrT], indexes: IndexBuffer[IndexT]) =
  const kind = utils.getTypeEnum(IndexT)
  glDrawElementsInstanced(GL_TRIANGLES, entity.drawCount, kind, indexes.data[0].unsafeAddr, entity.instanceCount)

proc render*[GameT, UniT, AttrT](game: GameT, entity: var InstancedIndexedEntity[UniT, AttrT]) =
  var
    previousProgram: GLuint
    previousVao: GLuint
  glGetIntegerv(GL_CURRENT_PROGRAM, cast[ptr GLint](previousProgram.addr))
  glGetIntegerv(GL_VERTEX_ARRAY_BINDING, cast[ptr GLint](previousVao.addr))
  glUseProgram(entity.program)
  glBindVertexArray(entity.vao)
  setBuffers(entity)
  for name, uni in entity.uniforms.fieldPairs:
    if not uni.disable:
      callUniform(game, entity, entity.program, name, uni)
  for attr in entity.attributes.fields:
    when attr is TextureBuffer[auto]:
      glActiveTexture(GLenum(GL_TEXTURE0.ord + attr.unit))
      glBindTexture(GL_TEXTURE_BUFFER, attr.textureNum)
  for attr in entity.attributes.fields:
    when attr is IndexBuffer[auto]:
      drawElements(entity, attr)
  glUseProgram(previousProgram)
  glBindVertexArray(previousVao)
