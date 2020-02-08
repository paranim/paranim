import nimgl/opengl

const maxDivisor* = 1

type
  Attribute*[T] = object
    disable*: bool
    buffer*: GLuint
    data*: ref seq[T]
    size*: GLint
    iter*: int
    normalize*: bool
    stride*: int
    offset*: int
    divisor*: range[0..maxDivisor]

proc setArrayBuffer*[T](program: GLuint, attribName: string, attr: Attribute[T]): GLsizei =
  let kind =
    when T is GLfloat:
      EGL_FLOAT
    else:
      raise newException(Exception, "Invalid attribute type")
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
    glVertexAttribPointer(loc, attr.size, kind, attr.normalize, GLsizei(T.sizeof * totalSize), cast[pointer](T.sizeof * i * attr.size))
    glVertexAttribDivisor(loc, GLuint(attr.divisor))
  glBindBuffer(GL_ARRAY_BUFFER, GLuint(previousBuffer))

