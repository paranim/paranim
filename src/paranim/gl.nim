import nimgl/opengl
import paranim/gl/utils

type
  Game* = object
    texCount*: Natural

proc createTexture*(game: var Game, uniLoc: GLint, data: seq[uint8], opts: Opts, params: seq[(GLenum, GLenum)]): GLint =
  game.texCount += 1
  let unit = game.texCount - 1
  var texture: GLuint
  glGenTextures(1, texture.addr)
  glActiveTexture(GLenum(GL_TEXTURE0.ord + unit))
  glBindTexture(GL_TEXTURE_2D, texture)
  for (paramName, paramVal) in params:
    glTexParameteri(GL_TEXTURE_2D, paramName, GLint(paramVal))
  # TODO: alignment
  glTexImage2D(GL_TEXTURE_2D, opts.mipLevel, GLint(opts.internalFmt), opts.width, opts.height, opts.border, opts.srcFmt, opts.srcType, data[0].unsafeAddr)
  # TODO: mipmap
  GLint(unit)

