import nimgl/opengl
import paranim/gl, paranim/gl/[attributes, uniforms]
import paranim/math as pmath
import examples_common
from bitops import bitor
from std/math import nil
import glm

# based on https://github.com/progschj/OpenGL-Examples/blob/master/06instancing2_buffer_texture.cpp

const vertexShader =
  """
  #version 330
  uniform mat4 u_matrix; // the projection matrix uniform
  uniform samplerBuffer offset_texture; // the buffer_texture sampler
  layout(location = 0) in vec4 vposition;
  layout(location = 1) in vec4 vcolor;
  out vec4 fcolor;
  void main() {
     // access the buffer texture with the InstanceID (tbo[InstanceID])
     vec4 offset = texelFetch(offset_texture, gl_InstanceID);
     fcolor = vcolor;
     gl_Position = u_matrix*(vposition + offset);
  }
  """

const fragmentShader =
  """
  #version 330
  in vec4 fcolor;
  layout(location = 0) out vec4 FragColor;
  void main() {
     FragColor = fcolor;
  }
  """

const vertexData = [
  #  X     Y     Z           R     G     B
  # face 0:
     1.0f, 1.0f, 1.0f,       1.0f, 0.0f, 0.0f, # vertex 0
    -1.0f, 1.0f, 1.0f,       1.0f, 0.0f, 0.0f, # vertex 1
     1.0f,-1.0f, 1.0f,       1.0f, 0.0f, 0.0f, # vertex 2
    -1.0f,-1.0f, 1.0f,       1.0f, 0.0f, 0.0f, # vertex 3

  # face 1:
     1.0f, 1.0f, 1.0f,       0.0f, 1.0f, 0.0f, # vertex 0
     1.0f,-1.0f, 1.0f,       0.0f, 1.0f, 0.0f, # vertex 1
     1.0f, 1.0f,-1.0f,       0.0f, 1.0f, 0.0f, # vertex 2
     1.0f,-1.0f,-1.0f,       0.0f, 1.0f, 0.0f, # vertex 3

  # face 2:
     1.0f, 1.0f, 1.0f,       0.0f, 0.0f, 1.0f, # vertex 0
     1.0f, 1.0f,-1.0f,       0.0f, 0.0f, 1.0f, # vertex 1
    -1.0f, 1.0f, 1.0f,       0.0f, 0.0f, 1.0f, # vertex 2
    -1.0f, 1.0f,-1.0f,       0.0f, 0.0f, 1.0f, # vertex 3
    
  # face 3:
     1.0f, 1.0f,-1.0f,       1.0f, 1.0f, 0.0f, # vertex 0
     1.0f,-1.0f,-1.0f,       1.0f, 1.0f, 0.0f, # vertex 1
    -1.0f, 1.0f,-1.0f,       1.0f, 1.0f, 0.0f, # vertex 2
    -1.0f,-1.0f,-1.0f,       1.0f, 1.0f, 0.0f, # vertex 3

  # face 4:
    -1.0f, 1.0f, 1.0f,       0.0f, 1.0f, 1.0f, # vertex 0
    -1.0f, 1.0f,-1.0f,       0.0f, 1.0f, 1.0f, # vertex 1
    -1.0f,-1.0f, 1.0f,       0.0f, 1.0f, 1.0f, # vertex 2
    -1.0f,-1.0f,-1.0f,       0.0f, 1.0f, 1.0f, # vertex 3

  # face 5:
     1.0f,-1.0f, 1.0f,       1.0f, 0.0f, 1.0f, # vertex 0
    -1.0f,-1.0f, 1.0f,       1.0f, 0.0f, 1.0f, # vertex 1
     1.0f,-1.0f,-1.0f,       1.0f, 0.0f, 1.0f, # vertex 2
    -1.0f,-1.0f,-1.0f,       1.0f, 0.0f, 1.0f, # vertex 3
  ] # 6 faces with 4 vertices with 6 components (floats)

const indexData = [
      # face 0:
      0,1,2,      # first triangle
      2,1,3,      # second triangle
      # face 1:
      4,5,6,      # first triangle
      6,5,7,      # second triangle
      # face 2:
      8,9,10,     # first triangle
      10,9,11,    # second triangle
      # face 3:
      12,13,14,   # first triangle
      14,13,15,   # second triangle
      # face 4:
      16,17,18,   # first triangle
      18,17,19,   # second triangle
      # face 5:
      20,21,22,   # first triangle
      22,21,23,   # second triangle
  ]

const translationData = [
     2.0f, 2.0f, 2.0f, 0.0f,  # cube 0
     2.0f, 2.0f,-2.0f, 0.0f,  # cube 1
     2.0f,-2.0f, 2.0f, 0.0f,  # cube 2
     2.0f,-2.0f,-2.0f, 0.0f,  # cube 3
    -2.0f, 2.0f, 2.0f, 0.0f,  # cube 4
    -2.0f, 2.0f,-2.0f, 0.0f,  # cube 5
    -2.0f,-2.0f, 2.0f, 0.0f,  # cube 6
    -2.0f,-2.0f,-2.0f, 0.0f,  # cube 7
  ]

type
  ThreeDTextureBufferEntityUniforms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]], offset_texture: Uniform[GLint]]
  ThreeDTextureBufferEntityAttributes = tuple[vposition: Attribute[GLfloat], indexes: IndexBuffer[GLuint], texture: TextureBuffer[GLfloat]]
  ThreeDTextureBufferEntity = object of InstancedIndexedEntity[ThreeDTextureBufferEntityUniforms, ThreeDTextureBufferEntityAttributes]
  UncompiledThreeDTextureBufferEntity = object of UncompiledEntity[ThreeDTextureBufferEntity, ThreeDTextureBufferEntityUniforms, ThreeDTextureBufferEntityAttributes]

proc initThreeDTextureBufferEntity(game: var Game, posData: openArray[GLfloat], idxData: openArray[int], textureData: openArray[GLfloat]): UncompiledThreeDTextureBufferEntity =
  result.vertexSource = vertexShader
  result.fragmentSource = fragmentShader
  # position
  var position = Attribute[GLfloat](size: 3, iter: 2)
  new(position.data)
  position.data[].add(posData)
  # indexes
  var indexes = IndexBuffer[GLuint]()
  new(indexes.data)
  for idx in idxData:
    indexes.data[].add(idx.GLuint)
  # texture
  var texture = TextureBuffer[GLfloat](internalFmt: GL_RGBA32F)
  new(texture.data)
  texture.data[].add(textureData)
  # set attrs and unis
  result.attributes = (vposition: position, indexes: indexes, texture: texture)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](data: mat4f(1)),
    offset_texture: Uniform[GLint](data: game.texCount.ord.GLint)
  )
  game.texCount += 1

var entity: ThreeDTextureBufferEntity
var rx = degToRad(190f)
var ry = degToRad(40f)

proc init*(game: var Game) =
  doAssert glInit()

  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glEnable(GL_CULL_FACE)
  glEnable(GL_DEPTH_TEST)

  entity = compile(game, initThreeDTextureBufferEntity(game, vertexData, indexData, translationData))
  entity.instanceCount = GLint(translationData.len / 4)

proc tick*(game: Game) =
  glClearColor(1f, 1f, 1f, 1f)
  glClear(GLbitfield(bitor(GL_COLOR_BUFFER_BIT.ord, GL_DEPTH_BUFFER_BIT.ord)))
  glViewport(0, 0, GLsizei(game.frameWidth), GLsizei(game.frameHeight))

  glActiveTexture(GLenum(GL_TEXTURE0.ord + entity.uniforms.offset_texture.data))

  var camera = mat4f(1)
  camera.translate(0f, 0f, -10f)
  camera.lookAt(vec3(0f, 0f, 0f), vec3(0f, 1f, 0f))

  var e = entity
  e.project(degToRad(60f), float(game.frameWidth) / float(game.frameHeight), 1f, 2000f)
  e.invert(camera)
  e.rotateX(rx)
  e.rotateY(ry)
  render(game, e)

  rx += 1.2f * game.deltaTime
  ry += 0.7f * game.deltaTime

