import unittest

import nimgl/glfw
import nimgl/opengl
import paranim/gl, paranim/gl/utils
from paranim/primitives2d import nil
import glm

proc init() =
  assert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  if w == nil:
    quit(-1)

  w.makeContextCurrent()

  assert glInit()

init()

var game = RootGame()

const vertexShader =
  """
  #version 410
  uniform float u_float;
  uniform int u_int;
  uniform uint u_uint;
  uniform vec2 u_vec2;
  uniform vec3 u_vec3;
  uniform vec4 u_vec4;
  uniform mat2 u_mat2;
  uniform mat3 u_mat3;
  uniform mat4 u_mat4;
  in vec2 a_position;
  void main()
  {
    float temp_float = u_float;
    int temp_int = u_int;
    uint temp_uint = u_uint;
    vec2 temp_vec2 = u_vec2;
    vec3 temp_vec3 = u_vec3;
    vec4 temp_vec4 = u_vec4;
    mat2 temp_mat2 = u_mat2;
    mat4 temp_mat4 = u_mat4;
    gl_Position = vec4((u_mat3 * vec3(a_position, 1)).xy, 0, 1);
  }
  """

const fragmentShader =
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

type
  TestUniForms = tuple[
    u_float: Uniform[GLfloat],
    u_int: Uniform[GLint],
    u_uint: Uniform[GLuint],
    u_vec2: Uniform[Vec2[GLfloat]],
    u_vec3: Uniform[Vec3[GLfloat]],
    u_vec4: Uniform[Vec4[GLfloat]],
    u_mat2: Uniform[Mat2x2[GLfloat]],
    u_mat3: Uniform[Mat3x3[GLfloat]],
    u_mat4: Uniform[Mat4x4[GLfloat]],
    u_color: Uniform[Vec4[GLfloat]]
  ]
  TestAttributes = tuple[a_position: Attribute[GLfloat]]
  TestEntity = object of ArrayEntity[TestUniForms, TestAttributes]
  UncompiledTestEntity = object of UncompiledEntity[TestEntity, TestUniForms, TestAttributes]

test "all uniform types":
  var dataArr: seq[GLfloat] = @[]
  dataArr.add(primitives2d.rect)
  let uncompiledEntity = UncompiledTestEntity(
    vertexSource: vertexShader,
    fragmentSource: fragmentShader,
    attributes: (a_position: Attribute[GLfloat](enable: true, data: dataArr, size: 2, iter: 1)),
    uniforms: (
      u_float: Uniform[GLfloat](enable: true),
      u_int: Uniform[GLint](enable: true),
      u_uint: Uniform[GLuint](enable: true),
      u_vec2: Uniform[Vec2[GLfloat]](enable: true),
      u_vec3: Uniform[Vec3[GLfloat]](enable: true),
      u_vec4: Uniform[Vec4[GLfloat]](enable: true),
      u_mat2: Uniform[Mat2x2[GLfloat]](enable: true),
      u_mat3: Uniform[Mat3x3[GLfloat]](enable: true),
      u_mat4: Uniform[Mat4x4[GLfloat]](enable: true),
      u_color: Uniform[Vec4[GLfloat]](enable: true)
    )
  )
  discard compile(game, uncompiledEntity)
