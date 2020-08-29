import nimgl/opengl

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
  glDeleteShader(vShader)
  glDeleteShader(fShader)
  checkProgramStatus(result)

proc getTypeEnum*(T: typedesc): GLenum =
  when T is GLfloat:
    EGL_FLOAT
  elif T is GLint:
    EGL_INT
  elif T is GLuint:
    GL_UNSIGNED_INT
  elif T is GLshort:
    EGL_SHORT
  elif T is GLushort:
    GL_UNSIGNED_SHORT
  elif T is GLbyte:
    EGL_BYTE
  elif T is GLubyte:
    GL_UNSIGNED_BYTE
  else:
    raise newException(Exception, "Unknown type")
