import nimgl/opengl
import strutils, tables

type
  Attribute*[T] = object
    data*: seq[T]
    size*: GLint
    iter*: int
    normalize*: bool
    stride*: int
    offset*: int
    divisor*: int

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

proc setArrayBuffer*[T](program: GLuint, buffer: GLuint, attribName: string, attr: Attribute[T]): GLsizei =
  let kind =
    when T is cfloat:
      EGL_FLOAT
    else:
      raise newException(Exception, "Invalid attribute type")
  result = GLsizei(attr.data.len / attr.size)
  var attribLocation = GLuint(glGetAttribLocation(program, cstring(attribName)))
  var previousBuffer: GLint
  glGetIntegerv(GL_ARRAY_BUFFER_BINDING, previousBuffer.addr)
  glBindBuffer(GL_ARRAY_BUFFER, buffer)
  glBufferData(GL_ARRAY_BUFFER, cint(T.sizeof * attr.data.len), attr.data[0].unsafeAddr, GL_STATIC_DRAW)
  glEnableVertexAttribArray(attribLocation)
  glVertexAttribPointer(attribLocation, attr.size, kind, false, GLsizei(T.sizeof * attr.size), nil)
  glBindBuffer(GL_ARRAY_BUFFER, GLuint(previousBuffer))

proc getGlslTypes*(source: string, keyword: string): Table[string, string] =
  for line in source.splitLines:
    let tokens = line.splitWhitespace
    if tokens.len < 3:
      continue
    elif tokens[0] == keyword:
      result[tokens[2].strip(chars = {';'})] = tokens[1]