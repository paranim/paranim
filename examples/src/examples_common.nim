import paranim/gl, paranim/gl/utils
from paranim/gl/entities3d import nil
import nimgl/opengl
import glm
from sequtils import map
from math import nil

type
  Game* = object of RootGame
    frameWidth*: int
    frameHeight*: int
    windowWidth*: int
    windowHeight*: int
    mouseX*: float
    mouseY*: float

# 2D

const f2d* = [
  # left column
  0f, 0f,
  30f, 0f,
  0f, 150f,
  0f, 150f,
  30f, 0f,
  30f, 150f,
  # top rung
  30f, 0f,
  100f, 0f,
  30f, 30f,
  30f, 30f,
  100f, 0f,
  100f, 30f,
  # middle rung
  30f, 60f,
  67f, 60f,
  30f, 90f,
  30f, 90f,
  67f, 60f,
  67f, 90f,
]

# 3D

type
  ThreeDEntityUniForms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]]]
  ThreeDEntityAttributes = tuple[a_position: Attribute[GLfloat], a_color: Attribute[GLfloat]]
  ThreeDEntity* = object of ArrayEntity[ThreeDEntityUniForms, ThreeDEntityAttributes]
  UncompiledThreeDEntity = object of UncompiledEntity[ThreeDEntity, ThreeDEntityUniForms, ThreeDEntityAttributes]

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
    u_matrix: Uniform[Mat4x4[GLfloat]](enable: true, data: entities3d.identityMatrix())
  )

proc degToRad*(degrees: GLfloat): GLfloat =
  (degrees * math.PI) / 180f

const f3d* = [
   # left column front
   0f,   0f,  0f,
   0f, 150f,  0f,
   30f,   0f,  0f,
   0f, 150f,  0f,
   30f, 150f,  0f,
   30f,   0f,  0f,

   # top rung front
   30f,   0f,  0f,
   30f,  30f,  0f,
   100f,   0f,  0f,
   30f,  30f,  0f,
   100f,  30f,  0f,
   100f,   0f,  0f,

   # middle rung front
   30f,  60f,  0f,
   30f,  90f,  0f,
   67f,  60f,  0f,
   30f,  90f,  0f,
   67f,  90f,  0f,
   67f,  60f,  0f,

   # left column back
     0f,   0f,  30f,
    30f,   0f,  30f,
     0f, 150f,  30f,
     0f, 150f,  30f,
    30f,   0f,  30f,
    30f, 150f,  30f,

   # top rung back
    30f,   0f,  30f,
   100f,   0f,  30f,
    30f,  30f,  30f,
    30f,  30f,  30f,
   100f,   0f,  30f,
   100f,  30f,  30f,

   # middle rung back
    30f,  60f,  30f,
    67f,  60f,  30f,
    30f,  90f,  30f,
    30f,  90f,  30f,
    67f,  60f,  30f,
    67f,  90f,  30f,

   # top
     0f,   0f,   0f,
   100f,   0f,   0f,
   100f,   0f,  30f,
     0f,   0f,   0f,
   100f,   0f,  30f,
     0f,   0f,  30f,

   # top rung right
   100f,   0f,   0f,
   100f,  30f,   0f,
   100f,  30f,  30f,
   100f,   0f,   0f,
   100f,  30f,  30f,
   100f,   0f,  30f,

   # under top rung
   30f,   30f,   0f,
   30f,   30f,  30f,
   100f,  30f,  30f,
   30f,   30f,   0f,
   100f,  30f,  30f,
   100f,  30f,   0f,

   # between top rung and middle
   30f,   30f,   0f,
   30f,   60f,  30f,
   30f,   30f,  30f,
   30f,   30f,   0f,
   30f,   60f,   0f,
   30f,   60f,  30f,

   # top of middle rung
   30f,   60f,   0f,
   67f,   60f,  30f,
   30f,   60f,  30f,
   30f,   60f,   0f,
   67f,   60f,   0f,
   67f,   60f,  30f,

   # right of middle rung
   67f,   60f,   0f,
   67f,   90f,  30f,
   67f,   60f,  30f,
   67f,   60f,   0f,
   67f,   90f,   0f,
   67f,   90f,  30f,

   # bottom of middle rung.
   30f,   90f,   0f,
   30f,   90f,  30f,
   67f,   90f,  30f,
   30f,   90f,   0f,
   67f,   90f,  30f,
   67f,   90f,   0f,

   # right of bottom
   30f,   90f,   0f,
   30f,  150f,  30f,
   30f,   90f,  30f,
   30f,   90f,   0f,
   30f,  150f,   0f,
   30f,  150f,  30f,

   # bottom
   0f,   150f,   0f,
   0f,   150f,  30f,
   30f,  150f,  30f,
   0f,   150f,   0f,
   30f,  150f,  30f,
   30f,  150f,   0f,

   # left side
   0f,   0f,   0f,
   0f,   0f,  30f,
   0f, 150f,  30f,
   0f,   0f,   0f,
   0f, 150f,  30f,
   0f, 150f,   0f,
]

const f3dColors* = [
   # left column front
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   
     # top rung front
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   
     # middle rung front
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   
     # left column back
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   
     # top rung back
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   
     # middle rung back
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   
     # top
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   
     # top rung right
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   
     # under top rung
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   
     # between top rung and middle
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   
     # top of middle rung
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   
     # right of middle rung
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   
     # bottom of middle rung.
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   
     # right of bottom
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   
     # bottom
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   
     # left side
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
]
