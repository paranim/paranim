import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes
import nimgl/opengl
import glm
from sequtils import map
from std/math import nil
from paranim/math as pmath import nil

type
  Game* = object of RootGame
    deltaTime*: float
    totalTime*: float
    frameWidth*: int
    frameHeight*: int
    windowWidth*: int
    windowHeight*: int
    mouseX*: float
    mouseY*: float

type
  ThreeDEntityUniForms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]]]
  ThreeDEntityAttributes = tuple[a_position: Attribute[GLfloat], a_color: Attribute[GLfloat]]
  ThreeDEntity* = object of ArrayEntity[ThreeDEntityUniForms, ThreeDEntityAttributes]
  UncompiledThreeDEntity = object of UncompiledEntity[ThreeDEntity, ThreeDEntityUniForms, ThreeDEntityAttributes]

proc project*[UniT, AttrT](entity: var Entity[UniT, AttrT], left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  entity.uniforms.u_matrix.project(left, right, bottom, top, near, far)

proc project*[UniT, AttrT](entity: var Entity[UniT, AttrT], fieldOfView: GLfloat, aspect: GLfloat, near: GLfloat, far: GLfloat) =
  entity.uniforms.u_matrix.project(fieldOfView, aspect, near, far)

proc translate*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.translate(x, y, z)

proc scale*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.scale(x, y, z)

proc rotateX*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateX(angle)

proc rotateY*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateY(angle)

proc rotateZ*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateZ(angle)

proc invert*[UniT, AttrT](entity: var Entity[UniT, AttrT], cam: Mat4x4[GLfloat]) =
  entity.uniforms.u_matrix.invert(cam)

const threeDVertexShader =
  """
  #version 410
  uniform mat4 u_matrix;
  in vec4 a_position;
  in vec4 a_color;
  out vec4 v_color;
  void main()
  {
    gl_Position = u_matrix * a_position;
    v_color = a_color;
  }
  """

const threeDFragmentShader =
  """
  #version 410
  precision mediump float;
  in vec4 v_color;
  out vec4 o_color;
  void main()
  {
    o_color = v_color;
  }
  """

proc initThreeDEntity*(data: openArray[GLfloat], colorData: openArray[GLfloat]): UncompiledThreeDEntity =
  result.vertexSource = threeDVertexShader
  result.fragmentSource = threeDFragmentShader
  var position = Attribute[GLfloat](enable: true, size: 3, iter: 1)
  new(position.data)
  position.data[].add(data)
  var color = Attribute[GLfloat](enable: true, size: 3, iter: 1)
  new(color.data)
  let colorDataNormalized = colorData.map proc (n: GLfloat): GLfloat = n / 255f
  color.data[].add(colorDataNormalized)
  result.attributes = (a_position: position, a_color: color)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](enable: true, data: mat4f(1))
  )

proc degToRad*(degrees: GLfloat): GLfloat =
  (degrees * math.PI) / 180f

proc transformVec(matrix: Mat4x4[GLfloat], vec: Vec4[GLfloat]): Vec4[GLfloat] =
  for i in 0 .. 3:
    result[i] = 0f
    for j in 0 .. 3:
      result[i] = result[i] + (vec[j] * matrix[i][j])

# Transform the F data for some of the 3D examples.
# From webgl2fundamentals.org it explains:
#
# Center the F around the origin and Flip it around. We do this because
# we're in 3D now with and +Y is up where as before when we started with 2D
# we had +Y as down.
proc transformData*(data: openArray[GLfloat]): seq[GLfloat] =
  result.add(data)
  var matrix = mat4f(1)
  pmath.rotateX(matrix, math.PI)
  pmath.translate(matrix, -50f, -75f, -15f)
  for i in 0 ..< int(data.len / 3):
    let ii = i * 3
    let vec = transformVec(matrix, vec4(result[ii], result[ii+1], result[ii+2], 1f))
    result[ii] = vec[0]
    result[ii+1] = vec[1]
    result[ii+2] = vec[2]
