import unittest

import nimgl/glfw
import nimgl/opengl
import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes, paranim/gl/entities
from paranim/primitives import nil
from paranim/math as pmath import nil
import glm

proc init() =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let w: GLFWWindow = glfwCreateWindow(800, 600, "NimGL")
  if w == nil:
    quit(-1)

  w.makeContextCurrent()

  doAssert glInit()

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
  dataArr.add(primitives.rectangle[GLfloat]())
  var position = Attribute[GLfloat](size: 2, iter: 1)
  new(position.data)
  position.data[] = dataArr
  let uncompiledEntity = UncompiledTestEntity(
    vertexSource: vertexShader,
    fragmentSource: fragmentShader,
    attributes: (a_position: position),
    uniforms: (
      u_float: Uniform[GLfloat](),
      u_int: Uniform[GLint](),
      u_uint: Uniform[GLuint](),
      u_vec2: Uniform[Vec2[GLfloat]](),
      u_vec3: Uniform[Vec3[GLfloat]](),
      u_vec4: Uniform[Vec4[GLfloat]](),
      u_mat2: Uniform[Mat2x2[GLfloat]](),
      u_mat3: Uniform[Mat3x3[GLfloat]](),
      u_mat4: Uniform[Mat4x4[GLfloat]](),
      u_color: Uniform[Vec4[GLfloat]]()
    )
  )
  discard compile(game, uncompiledEntity)

test "get and set values in an instanced two d entity":
  let baseEntity = initTwoDEntity(primitives.rectangle[GLfloat]())
  var uncompiledEntity = initInstancedEntity(baseEntity)

  # add and then get instances

  for i in 0 .. 4:
    let
      width = 1000f * GLfloat(i+1)
      height = 500f * GLfloat(i+1)
      color = vec4(0f, 0f, 0f, 1f / GLfloat(i))

    var e = baseEntity
    e.project(width, height)
    e.color(color)
    uncompiledEntity.add(e)

    let expectedMat = mat3x3[GLfloat](
      vec3[GLfloat](2f / width, 0f, -1f),
      vec3[GLfloat](0f, -2f / height, 1f),
      vec3[GLfloat](0f, 0f, 1f)
    )

    check uncompiledEntity[i].uniforms.u_color.data == color
    check uncompiledEntity[i].uniforms.u_matrix.data == expectedMat

  # replace an existing instance

  var entity = compile(game, uncompiledEntity)

  let
    width = 10f
    height = 50f
    color = vec4(0.5f, 0f, 0f, 1f)

  var e = baseEntity
  e.project(width, height)
  e.color(color)
  entity[3] = e

  let expectedMat = mat3x3[GLfloat](
    vec3[GLfloat](2f / width, 0f, -1f),
    vec3[GLfloat](0f, -2f / height, 1f),
    vec3[GLfloat](0f, 0f, 1f)
  )

  check entity[3].uniforms.u_color.data == color
  check entity[3].uniforms.u_matrix.data == expectedMat

test "get and set values in an instanced image entity":
  let imageWidth = 3
  let imageHeight = 2
  let pattern = [GLubyte(128), GLubyte(64), GLubyte(128), GLubyte(0), GLubyte(192), GLubyte(0)]
  let baseEntity = initImageEntity(pattern, imageWidth, imageHeight)
  var uncompiledEntity = initInstancedEntity(baseEntity)

  # add and then get instances

  for i in 0 .. 4:
    let
      width = 1000f * GLfloat(i+1)
      height = 500f * GLfloat(i+1)
      cropX, cropY = 10f * GLfloat(i+1)
      cropWidth, cropHeight = 50f * GLfloat(i+1)

    var e = baseEntity
    e.project(width, height)
    e.crop(cropX, cropY, cropWidth, cropHeight)
    uncompiledEntity.add(e)

    let expectedMat = mat3x3[GLfloat](
      vec3[GLfloat](2f / width, 0f, -1f),
      vec3[GLfloat](0f, -2f / height, 1f),
      vec3[GLfloat](0f, 0f, 1f)
    )

    var expectedTextureMat = mat3f(1)
    expectedTextureMat = pmath.translateMat(cropX / GLfloat(imageWidth), cropY / GLfloat(imageHeight)) * expectedTextureMat
    expectedTextureMat = pmath.scaleMat(cropWidth / GLfloat(imageWidth), cropHeight / GLfloat(imageHeight)) * expectedTextureMat

    check uncompiledEntity[i].uniforms.u_matrix.data == expectedMat
    check uncompiledEntity[i].uniforms.u_texture_matrix.data == expectedTextureMat

  # replace an existing instance

  var entity = compile(game, uncompiledEntity)

  let
    width = 100f
    height = 50f
    cropX, cropY = 10f
    cropWidth, cropHeight = 5f

  var e = baseEntity
  e.project(width, height)
  e.crop(cropX, cropY, cropWidth, cropHeight)
  entity[3] = e

  let expectedMat = mat3x3[GLfloat](
    vec3[GLfloat](2f / width, 0f, -1f),
    vec3[GLfloat](0f, -2f / height, 1f),
    vec3[GLfloat](0f, 0f, 1f)
  )

  var expectedTextureMat = mat3f(1)
  expectedTextureMat = pmath.translateMat(cropX / GLfloat(imageWidth), cropY / GLfloat(imageHeight)) * expectedTextureMat
  expectedTextureMat = pmath.scaleMat(cropWidth / GLfloat(imageWidth), cropHeight / GLfloat(imageHeight)) * expectedTextureMat

  check entity[3].uniforms.u_matrix.data == expectedMat
  check entity[3].uniforms.u_texture_matrix.data == expectedTextureMat

