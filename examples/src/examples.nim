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
when not defined(emscripten):
  from ex18_perspective_texture_buffer_3d import nil
from ex19_spheres_3d import nil
from ex20_planes_3d import nil
from ex21_cubes_3d import nil
from ex22_cylinders_3d import nil
from ex23_crescents_3d import nil
from ex24_toruses_3d import nil
from ex25_discs_3d import nil
from ex26_font import nil
from ex27_text import nil

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
  when not defined(emscripten):
    (init: ex18_perspective_texture_buffer_3d.init, tick: ex18_perspective_texture_buffer_3d.tick, name: "ex18_perspective_texture_buffer_3d")
  else:
    (init: nil, tick: nil, name: "skip")
  ,
  (init: ex19_spheres_3d.init, tick: ex19_spheres_3d.tick, name: "ex19_spheres_3d"),
  (init: ex20_planes_3d.init, tick: ex20_planes_3d.tick, name: "ex20_planes_3d"),
  (init: ex21_cubes_3d.init, tick: ex21_cubes_3d.tick, name: "ex21_cubes_3d"),
  (init: ex22_cylinders_3d.init, tick: ex22_cylinders_3d.tick, name: "ex22_cylinders_3d"),
  (init: ex23_crescents_3d.init, tick: ex23_crescents_3d.tick, name: "ex23_crescents_3d"),
  (init: ex24_toruses_3d.init, tick: ex24_toruses_3d.tick, name: "ex24_toruses_3d"),
  (init: ex25_discs_3d.init, tick: ex25_discs_3d.tick, name: "ex25_discs_3d"),
  (init: ex26_font.init, tick: ex26_font.tick, name: "ex26_font"),
  (init: ex27_text.init, tick: ex27_text.tick, name: "ex27_text"),
]

var game = Game()
var currentExample = 0

proc updateExample(window: GLFWWindow, direction: int) =
  var newExample = currentExample + direction
  if newExample < 0:
    newExample = examples.len - 1
  elif newExample == examples.len:
    newExample = 0
  if examples[newExample].init == nil: # skip examples with nil procs (not compatible with emscripten)
    newExample += direction
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

when defined(emscripten):
  proc emscripten_set_main_loop(f: proc() {.cdecl.}, a: cint, b: bool) {.importc.}

var window: GLFWWindow

proc mainLoop() {.cdecl.} =
  let ts = glfwGetTime()
  game.deltaTime = ts - game.totalTime
  game.totalTime = ts
  when defined(emscripten):
    try:
      examples[currentExample].tick(game)
    except Exception as ex:
      echo ex.msg
  else:
    examples[currentExample].tick(game)
  when defined(paravim):
    if not focusOnGame:
      discard paravim.tick(game)
  window.swapBuffers()
  glfwPollEvents()

when isMainModule:
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  window = glfwCreateWindow(800, 600, "Paranim Examples - Press the left and right arrow keys!")
  if window == nil:
    quit(-1)

  when defined(emscripten):
    window.setWindowTitle("Press the left and right arrow keys!")

  window.makeContextCurrent()
  glfwSwapInterval(1)

  discard window.setKeyCallback(keyCallback)
  discard window.setCursorPosCallback(mousePositionCallback)
  discard window.setFramebufferSizeCallback(resizeFrameCallback)

  var width, height: int32
  window.getFramebufferSize(width.addr, height.addr)
  window.resizeFrameCallback(width, height)

  examples[currentExample].init(game)

  when defined(emscripten):
    emscripten_set_main_loop(mainLoop, 0, true)
  else:
    while not window.windowShouldClose:
      mainLoop()

  window.destroyWindow()
  glfwTerminate()
