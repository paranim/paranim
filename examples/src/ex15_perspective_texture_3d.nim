import nimgl/opengl
import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes
import paranim/math as pmath
import examples_common
from bitops import bitor
from std/math import nil
import glm
import stb_image/read as stbi

const rawImage = staticRead("assets/f-texture.png")

type
  ThreeDTextureEntityUniForms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]], u_texture: Uniform[Texture[GLubyte]]]
  ThreeDTextureEntityAttributes = tuple[a_position: Attribute[GLfloat], a_texcoord: Attribute[GLfloat]]
  ThreeDTextureEntity = object of ArrayEntity[ThreeDTextureEntityUniForms, ThreeDTextureEntityAttributes]
  UncompiledThreeDTextureEntity = object of UncompiledEntity[ThreeDTextureEntity, ThreeDTextureEntityUniForms, ThreeDTextureEntityAttributes]

var entity: ThreeDTextureEntity
const tx = 100f
const ty = 100f
var rx = degToRad(190f)
var ry = degToRad(40f)

const fTexcoords = [
   # left column front
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   # top rung front
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   # middle rung front
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   # left column back
   0f, 0f,
   1f, 0f,
   0f, 1f,
   0f, 1f,
   1f, 0f,
   1f, 1f,

   # top rung back
   0f, 0f,
   1f, 0f,
   0f, 1f,
   0f, 1f,
   1f, 0f,
   1f, 1f,

   # middle rung back
   0f, 0f,
   1f, 0f,
   0f, 1f,
   0f, 1f,
   1f, 0f,
   1f, 1f,

   # top
   0f, 0f,
   1f, 0f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   0f, 1f,

   # top rung right
   0f, 0f,
   1f, 0f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   0f, 1f,

   # under top rung
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,

   # between top rung and middle
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # top of middle rung
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # right of middle rung
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # bottom of middle rung.
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,

   # right of bottom
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # bottom
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,

   # left side
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,
]

const vertexShader =
  """
  #version 410
  uniform mat4 u_matrix;
  in vec4 a_position;
  in vec2 a_texcoord;
  out vec2 v_texcoord;
  void main()
  {
    gl_Position = u_matrix * a_position;
    v_texcoord = a_texcoord;
  }
  """

const fragmentShader =
  """
  #version 410
  precision mediump float;
  uniform sampler2D u_texture;
  in vec2 v_texcoord;
  out vec4 outColor;
  void main()
  {
    outColor = texture(u_texture, v_texcoord);
  }
  """

proc initThreeDTextureEntity(posData: openArray[GLfloat], imgData: openArray[GLubyte], width: int, height: int): UncompiledThreeDTextureEntity =
  result.vertexSource = vertexShader
  result.fragmentSource = fragmentShader
  # position
  var position = Attribute[GLfloat](enable: true, size: 3, iter: 1)
  new(position.data)
  position.data[].add(posData)
  # texcoord
  var texcoord = Attribute[GLfloat](enable: true, size: 2, iter: 1, normalize: true)
  new(texcoord.data)
  texcoord.data[].add(fTexcoords)
  # image
  var image = Texture[GLubyte](
    opts: TextureOpts(
      mipLevel: 0,
      internalFmt: GL_RGBA,
      width: GLsizei(width),
      height: GLsizei(height),
      border: 0,
      srcFmt: GL_RGBA
    ),
    params: @[
      (GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE),
      (GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE),
      (GL_TEXTURE_MIN_FILTER, GL_NEAREST),
      (GL_TEXTURE_MAG_FILTER, GL_NEAREST)
    ],
    mipmapParams: @[GL_TEXTURE_2D]
  )
  new(image.data)
  image.data[].add(imgData)
  # set attrs and unis
  result.attributes = (a_position: position, a_texcoord: texcoord)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](enable: true, data: mat4f(1)),
    u_texture: Uniform[Texture[GLubyte]](enable: true, data: image)
  )

proc init*(game: var Game) =
  assert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glEnable(GL_DEPTH_TEST)

  var
    width, height, channels: int
    data: seq[uint8]
  data = stbi.loadFromMemory(cast[seq[uint8]](rawImage), width, height, channels, stbi.RGBA)

  entity = compile(game, initThreeDTextureEntity(transformData(f3d), data, width, height))

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))

  var camera = mat4f(1)
  camera.translate(0f, 0f, 200f)
  camera.lookAt(vec3(0f, 0f, 0f), vec3(0f, 1f, 0f))

  var e = entity
  e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
  e.invert(camera)
  e.rotateX(rx)
  e.rotateY(ry)
  render(game, e)

  rx += 1.2f * game.deltaTime
  ry += 0.7f * game.deltaTime

