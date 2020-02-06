import nimgl/glfw
import examples_common
from ex01_image import nil
from ex02_rand_rects import nil
from ex03_translation import nil
from ex04_rotation import nil
from ex05_scaling import nil
from ex06_rotation_multiple import nil
from ex07_translation_3d import nil
from ex08_rotation_3d import nil
from ex09_scaling_3d import nil
from ex10_perspective_3d import nil

const examples = [
  (init: ex01_image.init, tick: ex01_image.tick),
  (init: ex02_rand_rects.init, tick: ex02_rand_rects.tick),
  (init: ex03_translation.init, tick: ex03_translation.tick),
  (init: ex04_rotation.init, tick: ex04_rotation.tick),
  (init: ex05_scaling.init, tick: ex05_scaling.tick),
  (init: ex06_rotation_multiple.init, tick: ex06_rotation_multiple.tick),
  (init: ex07_translation_3d.init, tick: ex07_translation_3d.tick),
  (init: ex08_rotation_3d.init, tick: ex08_rotation_3d.tick),
  (init: ex09_scaling_3d.init, tick: ex09_scaling_3d.tick),
  (init: ex10_perspective_3d.init, tick: ex10_perspective_3d.tick),
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

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32,
                 action: int32, mods: int32): void {.cdecl.} =
  if action == GLFW_PRESS:
    if key == GLFWKey.Escape:
      window.setWindowShouldClose(true)
    elif key == GLFWKey.Left:
      updateExample(-1)
    elif key == GLFWKey.Right:
      updateExample(1)

proc mousePositionCallback(window: GLFWWindow, xpos: float64, ypos: float64): void {.cdecl.} =
  game.mouseX = xpos
  game.mouseY = ypos

proc resizeFrameCallback(window: GLFWWindow, width: int32, height: int32): void {.cdecl.} =
  game.frameWidth = width
  game.frameHeight = height

proc resizeWindowCallback(window: GLFWWindow, width: int32, height: int32): void {.cdecl.} =
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

  discard w.setKeyCallback(keyCallback)
  discard w.setCursorPosCallback(mousePositionCallback)
  discard w.setFramebufferSizeCallback(resizeFrameCallback)
  discard w.setWindowSizeCallback(resizeWindowCallback)

  var width, height: int32
  w.getFramebufferSize(width.addr, height.addr)
  w.resizeFrameCallback(width, height)

  w.getWindowSize(width.addr, height.addr)
  w.resizeWindowCallback(width, height)

  examples[currentExample].init(game)

  while not w.windowShouldClose:
    examples[currentExample].tick(game)
    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()
