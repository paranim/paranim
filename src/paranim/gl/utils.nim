import nimgl/opengl
import strutils, tables

const maxDivisor* = 1

type
  TextureOpts* = object
    mipLevel*: GLint
    internalFmt*: GLenum
    width*: GLsizei
    height*: GLsizei
    border*: GLint
    srcFmt*: GLenum
  Texture*[T] = object
    data*: ref seq[T]
    opts*: TextureOpts
    params*: seq[(GLenum, GLenum)]
    pixelStoreParams*: seq[(GLenum, GLint)]
    mipmapParams*: seq[GLenum]
    unit*: GLint
  Uniform*[T] = object
    enable*: bool
    data*: T
  Attribute*[T] = object
    enable*: bool
    buffer*: GLuint
    data*: ref seq[T]
    size*: GLint
    iter*: int
    normalize*: bool
    stride*: int
    offset*: int
    divisor*: range[0..maxDivisor]

proc toString(str: seq[char]): string =
  result = newStringOfCap(len(str))
  for ch in str:
    add(result, ch)

proc checkShaderStatus(shader: GLuint) =
  var params: GLint
  glGetShaderiv(shader, GL_COMPILE_STATUS, params.addr);
  if params != GL_TRUE.ord:
    var
      length: GLsizei
      message = newSeq[char](1024)
    glGetShaderInfoLog(shader, 1024, length.addr, message[0].addr)
    raise newException(Exception, toString(message))

proc createShader(shaderType: GLenum, source: string) : GLuint =
  result = glCreateShader(shaderType)
  var sourceC = cstring(source)
  glShaderSource(result, 1'i32, sourceC.addr, nil)
  glCompileShader(result)
  checkShaderStatus(result)

proc checkProgramStatus(program: GLuint) =
  var params: GLint
  glGetProgramiv(program, GL_LINK_STATUS, params.addr);
  if params != GL_TRUE.ord:
    var
      length: GLsizei
      message = newSeq[char](1024)
    glGetProgramInfoLog(program, 1024, length.addr, message[0].addr)
    raise newException(Exception, toString(message))

proc createProgram*(vSource: string, fSource: string) : GLuint =
  var vShader = createShader(GL_VERTEX_SHADER, vSource)
  var fShader = createShader(GL_FRAGMENT_SHADER, fSource)
  result = glCreateProgram()
  glAttachShader(result, vShader)
  glAttachShader(result, fShader)
  glLinkProgram(result)
  checkProgramStatus(result)

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

