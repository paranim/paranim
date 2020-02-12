import nimgl/glfw
import examples_common
from ex01_image import nil
from ex02_rect import nil
from ex03_rand_rects import nil
from ex04_translation import nil
from ex05_rotation import nil
from ex06_scaling import nil
from ex07_rotation_multiple import nil
from ex08_translation_3d import nil
from ex09_rotation_3d import nil
from ex10_scaling_3d import nil
from ex11_perspective_3d import nil
from ex12_perspective_camera_3d import nil
from ex13_perspective_camera_target_3d import nil
from ex14_perspective_animation_3d import nil
from ex15_perspective_texture_3d import nil
from ex16_perspective_texture_data_3d import nil
from ex17_perspective_texture_meta_3d import nil
from ex18_balls_3d import nil
from ex19_planes_3d import nil
from ex20_cubes_3d import nil

const examples = [
  (init: ex01_image.init, tick: ex01_image.tick, name: "ex01_image"),
  (init: ex02_rect.init, tick: ex02_rect.tick, name: "ex02_rect"),
  (init: ex03_rand_rects.init, tick: ex03_rand_rects.tick, name: "ex03_rand_rects"),
  (init: ex04_translation.init, tick: ex04_translation.tick, name: "ex04_translation"),
  (init: ex05_rotation.init, tick: ex05_rotation.tick, name: "ex05_rotation"),
  (init: ex06_scaling.init, tick: ex06_scaling.tick, name: "ex06_scaling"),
  (init: ex07_rotation_multiple.init, tick: ex07_rotation_multiple.tick, name: "ex07_rotation_multiple"),
  (init: ex08_translation_3d.init, tick: ex08_translation_3d.tick, name: "ex08_translation_3d"),
  (init: ex09_rotation_3d.init, tick: ex09_rotation_3d.tick, name: "ex09_rotation_3d"),
  (init: ex10_scaling_3d.init, tick: ex10_scaling_3d.tick, name: "ex10_scaling_3d"),
  (init: ex11_perspective_3d.init, tick: ex11_perspective_3d.tick, name: "ex11_perspective_3d"),
  (init: ex12_perspective_camera_3d.init, tick: ex12_perspective_camera_3d.tick, name: "ex12_perspective_camera_3d"),
  (init: ex13_perspective_camera_target_3d.init, tick: ex13_perspective_camera_target_3d.tick, name: "ex13_perspective_camera_target_3d"),
  (init: ex14_perspective_animation_3d.init, tick: ex14_perspective_animation_3d.tick, name: "ex14_perspective_animation_3d"),
  (init: ex15_perspective_texture_3d.init, tick: ex15_perspective_texture_3d.tick, name: "ex15_perspective_texture_3d"),
  (init: ex16_perspective_texture_data_3d.init, tick: ex16_perspective_texture_data_3d.tick, name: "ex16_perspective_texture_data_3d"),
  (init: ex17_perspective_texture_meta_3d.init, tick: ex17_perspective_texture_meta_3d.tick, name: "ex17_perspective_texture_meta_3d"),
  (init: ex18_balls_3d.init, tick: ex18_balls_3d.tick, name: "ex18_balls_3d"),
  (init: ex19_planes_3d.init, tick: ex19_planes_3d.tick, name: "ex19_planes_3d"),
  (init: ex20_cubes_3d.init, tick: ex20_cubes_3d.tick, name: "ex20_cubes_3d"),
]

var game = Game()
var currentExample = 0

proc updateExample(window: GLFWWindow, direction: int) =
  var newExample = currentExample + direction
  if newExample < 0:
    newExample = examples.len - 1
  elif newExample == examples.len:
    newExample = 0
  examples[newExample].init(game)
  currentExample = newExample
  window.setWindowTitle(examples[currentExample].name)

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32,
                 action: int32, mods: int32): void {.cdecl.} =
  if action == GLFW_PRESS:
    if key == GLFWKey.Escape:
      window.setWindowShouldClose(true)
    elif key == GLFWKey.Left:
      updateExample(window, -1)
    elif key == GLFWKey.Right:
      updateExample(window, 1)

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
  doAssert glfwInit()

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
    let ts = glfwGetTime()
    game.deltaTime = ts - game.totalTime
    game.totalTime = ts
    examples[currentExample].tick(game)
    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()
