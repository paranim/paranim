import nimgl/glfw
import examples_common
from ex01_image import nil
from ex02_rand_rects import nil
from ex03_translation import nil
from ex04_rotation import nil

const examples = [
  (init: ex01_image.init, tick: ex01_image.tick),
  (init: ex02_rand_rects.init, tick: ex02_rand_rects.tick),
  (init: ex03_translation.init, tick: ex03_translation.tick),
  (init: ex04_rotation.init, tick: ex04_rotation.tick),
]

var game = Game()
var currentExample = 0

proc updateExample(direction: int) =
  var newExample = currentExample + direction
  if newExample < 0:
    newExample = examples.len - 1
  elif newExample == examples.len:
    newExample = 0
  examples[newExample].init(game)
  currentExample = newExample

proc keyProc(window: GLFWWindow, key: int32, scancode: int32,
             action: int32, mods: int32): void {.cdecl.} =
  if action == GLFWPress:
    if key == GLFWKey.ESCAPE:
      window.setWindowShouldClose(true)
    elif key == GLFWKey.Left:
      updateExample(-1)
    elif key == GLFWKey.Right:
      updateExample(1)

proc mousePositionProc(window: GLFWWindow, xpos: float64, ypos: float64): void {.cdecl.} =
  game.mouseX = xpos
  game.mouseY = ypos

proc resizeFrameProc(window: GLFWWindow, width: int32, height: int32): void {.cdecl.} =
  game.frameWidth = width
  game.frameHeight = height

proc resizeWindowProc(window: GLFWWindow, width: int32, height: int32): void {.cdecl.} =
  game.windowWidth = width
  game.windowHeight = height

when isMainModule:
  assert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "Paranim Examples - Press the left and right arrow keys!")
  if w == nil:
    quit(-1)

  w.makeContextCurrent()
  glfwSwapInterval(1)

  discard w.setKeyCallback(keyProc)
  discard w.setCursorPosCallback(mousePositionProc)
  discard w.setFramebufferSizeCallback(resizeFrameProc)
  discard w.setWindowSizeCallback(resizeWindowProc)

  var width, height: int32
  w.getFramebufferSize(width.addr, height.addr)
  w.resizeFrameProc(width, height)

  w.getWindowSize(width.addr, height.addr)
  w.resizeWindowProc(width, height)

  examples[currentExample].init(game)

  while not w.windowShouldClose:
    examples[currentExample].tick(game)
    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()
