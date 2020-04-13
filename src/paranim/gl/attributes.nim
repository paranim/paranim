import nimgl/opengl
from utils import nil

const maxDivisor* = 1

type
  ArrayBuffer*[T] = object
    disable*: bool
    buffer*: GLuint
    data*: ref seq[T]
    size*: GLint
    iter*: int
    normalize*: bool
    stride*: int
    offset*: int
    divisor*: range[0..maxDivisor]
  IndexBuffer*[T] = object
    disable*: bool
    buffer*: GLuint
    data*: ref seq[T]
  TextureBuffer*[T] = object
    disable*: bool
    buffer*: GLuint
    data*: ref seq[T]
    textureNum*: GLuint
    internalFmt*: GLenum
  # aliases
  Attribute*[T] = ArrayBuffer[T]
  Indexes*[T] = IndexBuffer[T]

proc setArrayBuffer*[T](program: GLuint, attribName: string, attr: ArrayBuffer[T]): GLsizei =
  const kind = utils.getTypeEnum(T)
  let totalSize = attr.size * attr.iter
  result = GLsizei(attr.data[].len / totalSize)
  var attribLocation = GLuint(glGetAttribLocation(program, cstring(attribName)))
  var previousBuffer: GLint
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, previousBuffer.addr)
  glBindBuffer(GL_ARRAY_BUFFER, attr.buffer)
  glBufferData(GL_ARRAY_BUFFER, GLint(T.sizeof * attr.data[].len), attr.data[0].unsafeAddr, GL_STATIC_DRAW)
  for i in 0 ..< attr.iter:
    let loc = attribLocation + GLuint(i)
    glEnableVertexAttribArray(loc)
    when T is GLFloat:
      glVertexAttribPointer(loc, attr.size, kind, attr.normalize, GLsizei(T.sizeof * totalSize), cast[pointer](T.sizeof * i * attr.size))
    else:
      glVertexAttribIPointer(loc, attr.size, kind, GLsizei(T.sizeof * totalSize), cast[pointer](T.sizeof * i * attr.size))
    glVertexAttribDivisor(loc, GLuint(attr.divisor))
  glBindBuffer(GL_ARRAY_BUFFER, GLuint(previousBuffer))

proc setIndexBuffer*[T](indexes: IndexBuffer[T]): GLsizei =
  result = GLsizei(indexes.data[].len)
  var previousBuffer: GLint
  glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, previousBuffer.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexes.buffer)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLint(T.sizeof * indexes.data[].len), indexes.data[0].unsafeAddr, GL_STATIC_DRAW)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GLuint(previousBuffer))

proc setTextureBuffer*[T](texture: var TextureBuffer[T]): GLsizei =
  result = GLsizei(texture.data[].len)
  var previousBuffer: GLint
  glGetIntegerv(GL_TEXTURE_BUFFER_BINDING, previousBuffer.addr)

  glBindBuffer(GL_TEXTURE_BUFFER, texture.buffer)
  glBufferData(GL_TEXTURE_BUFFER, GLint(T.sizeof * texture.data[].len), texture.data[0].addr, GL_STATIC_DRAW)

  glGenTextures(1, addr(texture.textureNum))
  glBindTexture(GL_TEXTURE_BUFFER, texture.textureNum)
  glTexBuffer(GL_TEXTURE_BUFFER, texture.internalFmt, texture.buffer)

  glBindBuffer(GL_TEXTURE_BUFFER, GLuint(previousBuffer))

