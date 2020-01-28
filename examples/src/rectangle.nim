import nimgl/[glfw, opengl]
import glm
import paranim/gl/utils, paranim/gl/entities2d, paranim/primitives2d

proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if key == GLFWKey.ESCAPE and action == GLFWPress:
    window.setWindowShouldClose(true)

const twoDVertexShader =
  """
  #version 410
  uniform mat3 u_matrix;
  in vec2 a_position;
  void main()
  {
    gl_Position = vec4((u_matrix * vec3(a_position, 1)).xy, 0, 1);
  }
  """

const twoDFragmentShader =
  """
  #version 410
  precision mediump float;
  uniform vec4 u_color;
  out vec4 o_color;
  void main()
  {
    o_color = u_color;
  }
  """

proc main() =
  assert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  if w == nil:
    quit(-1)

  discard w.setKeyCallback(keyProc)
  w.makeContextCurrent()

  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)

  let program = createProgram(twoDVertexShader, twoDFragmentShader)
  glUseProgram(program)
  var vao: GLuint
  glGenVertexArrays(1, vao.addr)
  glBindVertexArray(vao)

  var positionBuf: GLuint
  glGenBuffers(1, positionBuf.addr)
  let drawCount = setArrayBuffer(program, positionBuf, "a_position", Attribute(data: rect, size: 2))

  let matrixUni = glGetUniformLocation(program, "u_matrix")
  var matrix = (
     scalingMatrix(50f, 50f) *
     translationMatrix(50f, 50f) *
     projectionMatrix(800f, 600f) *
     identityMatrix()
  ).transpose()
  glUniformMatrix3fv(matrixUni, 1, false, matrix.caddr)

  let colorUni = glGetUniformLocation(program, "u_color")
  var color = vec4(1f, 0f, 0f, 1)
  glUniform4fv(colorUni, 1, color.caddr)

  while not w.windowShouldClose:
    glClearColor(173/255, 216/255, 230/255, 1f)
    glClear(GL_COLOR_BUFFER_BIT)
    glViewport(0, 0, 800, 600)

    glDrawArrays(GL_TRIANGLES, 0, drawCount)

    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()

main()
