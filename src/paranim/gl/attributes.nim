import nimgl/opengl
from utils import nil

const maxDivisor* = 1

type
  Buffer*[T] = object of RootObj
    disable*: bool
    buffer*: GLuint
    data*: ref seq[T]
  IndexBuffer*[T] = object of Buffer[T]
  Indexes*[T] = IndexBuffer[T] # backwards compatibility
  TextureBuffer*[T] = object of Buffer[T]
    unit*: GLint
    textureNum*: GLuint
    internalFmt*: GLenum
  Attribute*[T] = object of Buffer[T]
    size*: GLint
    iter*: int
    normalize*: bool
    divisor*: range[0..maxDivisor]

proc setAttribute*[T](program: GLuint, attribName: string, attr: Attribute[T]): GLsizei =
  let totalSize = attr.size * attr.iter
  result = GLsizei(attr.data[].len / totalSize)
  var previousBuffer: GLint
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, previousBuffer.addr)
  glBindBuffer(GL_ARRAY_BUFFER, attr.buffer)
  glBufferData(GL_ARRAY_BUFFER, GLint(T.sizeof * attr.data[].len), attr.data[0].addr, GL_STATIC_DRAW)
  const kind = utils.getTypeEnum(T)
  var attribLocation = GLuint(glGetAttribLocation(program, cstring(attribName)))
  for i in 0 ..< attr.iter:
    let loc = attribLocation + GLuint(i)
    glEnableVertexAttribArray(loc)
    when T is GLFloat:
      glVertexAttribPointer(loc, attr.size, kind, attr.normalize, GLsizei(T.sizeof * totalSize), cast[pointer](T.sizeof * i * attr.size))
    else:
      glVertexAttribIPointer(loc, attr.size, kind, GLsizei(T.sizeof * totalSize), cast[pointer](T.sizeof * i * attr.size))
    glVertexAttribDivisor(loc, GLuint(attr.divisor))
  glBindBuffer(GL_ARRAY_BUFFER, GLuint(previousBuffer))

proc setIndexBuffer*[T](buf: IndexBuffer[T]): GLsizei =
  result = GLsizei(buf.data[].len)
  var previousBuffer: GLint
  glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, previousBuffer.addr)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, buf.buffer)
  glBufferData(GL_ELEMENT_ARRAY_BUFFER, GLint(T.sizeof * buf.data[].len), buf.data[0].addr, GL_STATIC_DRAW)
  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, GLuint(previousBuffer))

proc setTextureBuffer*[T](buf: var TextureBuffer[T]): GLsizei =
  result = GLsizei(buf.data[].len)
  var previousBuffer: GLint
  glGetIntegerv(GL_TEXTURE_BUFFER_BINDING, previousBuffer.addr)
  glBindBuffer(GL_TEXTURE_BUFFER, buf.buffer)
  glBufferData(GL_TEXTURE_BUFFER, GLint(T.sizeof * buf.data[].len), buf.data[0].addr, GL_STATIC_DRAW)
  glBindBuffer(GL_TEXTURE_BUFFER, GLuint(previousBuffer))

  var previousTexture: GLint
  glGetIntegerv(GL_TEXTURE_BINDING_BUFFER, previousTexture.addr)
  glGenTextures(1, addr(buf.textureNum))
  glBindTexture(GL_TEXTURE_BUFFER, buf.textureNum)
  glTexBuffer(GL_TEXTURE_BUFFER, buf.internalFmt, buf.buffer)
  glBindTexture(GL_TEXTURE_BUFFER, GLuint(previousTexture))

