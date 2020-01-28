import nimgl/opengl
import paranim/gl/utils
import tables

type
  Game* = object
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
  Entity* = object of RootObj
    isCompiled*: bool
    vertexSource*: string
    fragmentSource*: string
    textureUniforms*: Table[string, Texture]
    uniforms*: Table[string, seq[cfloat]]
    attributes*: Table[string, Attribute]

proc createTexture*(game: var Game, uniLoc: GLint, texture: Texture): GLint =
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

