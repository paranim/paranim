import nimgl/opengl
import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes
import paranim/math as pmath
import examples_common, examples_data
from bitops import bitor
from std/math import nil
import glm
import stb_image/read as stbi

const rawImage = staticRead("assets/f-texture.png")

var entity: ThreeDTextureEntity
var rx = degToRad(190f)
var ry = degToRad(40f)

proc initThreeDTextureEntity(posData: openArray[GLfloat], imgData: openArray[GLubyte], width: int, height: int): UncompiledThreeDTextureEntity =
  result.vertexSource = threeDTextureVertexShader
  result.fragmentSource = threeDTextureFragmentShader
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

