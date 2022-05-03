import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes
import paranim/opengl
import paranim/glm
from sequtils import map
from std/math import nil
import paranim/math as pmath
from strutils import format

const version =
  when defined(emscripten):
    "300 es"
  else:
    "330"

type
  Game* = object of RootGame
    deltaTime*: float
    totalTime*: float
    frameWidth*: int32
    frameHeight*: int32
    mouseX*: float
    mouseY*: float

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
  result = @data
  var matrix = mat4f(1)
  pmath.rotateX(matrix, math.PI)
  pmath.translate(matrix, -50f, -75f, -15f)
  for i in 0 ..< int(data.len / 3):
    let ii = i * 3
    let vec = transformVec(matrix, vec4(result[ii], result[ii+1], result[ii+2], 1f))
    result[ii] = vec[0]
    result[ii+1] = vec[1]
    result[ii+2] = vec[2]

# basic 3D entity

const threeDVertexShader =
  """
  #version $1
  uniform mat4 u_matrix;
  in vec4 a_position;
  in vec4 a_color;
  out vec4 v_color;
  void main()
  {
    gl_Position = u_matrix * a_position;
    v_color = a_color;
  }
  """.format(version)

const threeDFragmentShader =
  """
  #version $1
  precision mediump float;
  in vec4 v_color;
  out vec4 o_color;
  void main()
  {
    o_color = v_color;
  }
  """.format(version)

type
  ThreeDEntityUniforms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]]]
  ThreeDEntityAttributes = tuple[a_position: Attribute[GLfloat], a_color: Attribute[GLfloat]]
  ThreeDEntity* = object of ArrayEntity[ThreeDEntityUniforms, ThreeDEntityAttributes]
  UncompiledThreeDEntity = object of UncompiledEntity[ThreeDEntity, ThreeDEntityUniforms, ThreeDEntityAttributes]

proc initThreeDEntity*(data: openArray[GLfloat], colorData: openArray[GLfloat]): UncompiledThreeDEntity =
  result.vertexSource = threeDVertexShader
  result.fragmentSource = threeDFragmentShader
  var position = Attribute[GLfloat](size: 3, iter: 1)
  new(position.data)
  position.data[] = @data
  var color = Attribute[GLfloat](size: 3, iter: 1)
  let colorDataNormalized = colorData.map proc (n: GLfloat): GLfloat = n / 255f
  new(color.data)
  color.data[] = colorDataNormalized
  result.attributes = (a_position: position, a_color: color)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](data: mat4f(1))
  )

# textured 3D entity

const threeDTextureVertexShader* =
  """
  #version $1
  uniform mat4 u_matrix;
  in vec4 a_position;
  in vec2 a_texcoord;
  out vec2 v_texcoord;
  void main()
  {
    gl_Position = u_matrix * a_position;
    v_texcoord = a_texcoord;
  }
  """.format(version)

const threeDTextureFragmentShader* =
  """
  #version $1
  precision mediump float;
  uniform sampler2D u_texture;
  in vec2 v_texcoord;
  out vec4 outColor;
  void main()
  {
    outColor = texture(u_texture, v_texcoord);
  }
  """.format(version)

type
  ThreeDTextureEntityUniforms = tuple[u_matrix: Uniform[Mat4x4[GLfloat]], u_texture: Uniform[Texture[GLubyte]]]
  ThreeDTextureEntityAttributes = tuple[a_position: Attribute[GLfloat], a_texcoord: Attribute[GLfloat]]
  ThreeDTextureEntity* = object of ArrayEntity[ThreeDTextureEntityUniforms, ThreeDTextureEntityAttributes]
  UncompiledThreeDTextureEntity = object of UncompiledEntity[ThreeDTextureEntity, ThreeDTextureEntityUniforms, ThreeDTextureEntityAttributes]

proc initThreeDTextureEntity*(posData: openArray[GLfloat], texcoordData: openArray[GLfloat], image: Texture[GLubyte]): UncompiledThreeDTextureEntity =
  result.vertexSource = threeDTextureVertexShader
  result.fragmentSource = threeDTextureFragmentShader
  # position
  var position = Attribute[GLfloat](size: 3, iter: 1)
  new(position.data)
  position.data[] = @posData
  # texcoord
  var texcoord = Attribute[GLfloat](size: 2, iter: 1, normalize: true)
  new(texcoord.data)
  texcoord.data[] = @texcoordData
  # set attrs and unis
  result.attributes = (a_position: position, a_texcoord: texcoord)
  result.uniforms = (
    u_matrix: Uniform[Mat4x4[GLfloat]](data: mat4f(1)),
    u_texture: Uniform[Texture[GLubyte]](data: image)
  )

# indexed 3D entity

const indexedThreeDVertexShader =
  """
  #version $1
  uniform mat4 u_worldViewProjection;
  uniform vec3 u_lightWorldPos;
  uniform mat4 u_world;
  uniform mat4 u_viewInverse;
  uniform mat4 u_worldInverseTranspose;
  in vec4 a_position;
  in vec3 a_normal;
  in vec2 a_texcoord;
  out vec4 v_position;
  out vec2 v_texcoord;
  out vec3 v_normal;
  out vec3 v_surfaceToLight;
  out vec3 v_surfaceToView;
  void main()
  {
    v_texcoord = a_texcoord;
    v_position = (u_worldViewProjection * a_position);
    v_normal = ((u_worldInverseTranspose * (vec4(a_normal, 0))).xyz);
    v_surfaceToLight = (u_lightWorldPos - ((u_world * a_position).xyz));
    v_surfaceToView = ((u_viewInverse[3] - (u_world * a_position)).xyz);
    gl_Position = v_position;
  }
  """.format(version)

const indexedThreeDFragmentShader =
  """
  #version $1
  precision mediump float;
  uniform vec4 u_lightColor;
  uniform vec4 u_color;
  uniform vec4 u_specular;
  uniform float u_shininess;
  uniform float u_specularFactor;
  in vec4 v_position;
  in vec2 v_texcoord;
  in vec3 v_normal;
  in vec3 v_surfaceToLight;
  in vec3 v_surfaceToView;
  out vec4 outColor;
  vec4 lit(float l, float h, float m)
  {
    return vec4(1.0, (abs(l)), ((l > 0.0) ? (pow((max(0.0, h)), m)) : 0.0), 1.0);
  }
  void main()
  {
    vec3 a_normal = (normalize(v_normal));
    vec3 surfaceToLight = (normalize(v_surfaceToLight));
    vec3 surfaceToView = (normalize(v_surfaceToView));
    vec3 halfVector = (normalize((surfaceToLight + surfaceToView)));
    vec4 litR = (lit((dot(a_normal, surfaceToLight)), (dot(a_normal, halfVector)), u_shininess));
    outColor = (vec4(((u_lightColor * (((litR.y) * u_color) + (u_specular * (litR.z) * u_specularFactor))).rgb), 1));
  }
  """.format(version)

type
  IndexedThreeDEntityUniforms = object
    u_worldViewProjection: Uniform[Mat4x4[GLfloat]]
    u_lightWorldPos: Uniform[Vec3[GLfloat]]
    u_world: Uniform[Mat4x4[GLfloat]]
    u_viewInverse: Uniform[Mat4x4[GLfloat]]
    u_worldInverseTranspose: Uniform[Mat4x4[GLfloat]]
    u_lightColor: Uniform[Vec4[GLfloat]]
    u_color: Uniform[Vec4[GLfloat]]
    u_specular: Uniform[Vec4[GLfloat]]
    u_shininess: Uniform[GLfloat]
    u_specularFactor: Uniform[GLfloat]
  IndexedThreeDEntityAttributes = object
    a_position: Attribute[GLfloat]
    a_normal: Attribute[GLfloat]
    a_texcoord: Attribute[GLfloat]
    indexes: IndexBuffer[GLushort]
  IndexedThreeDEntity* = object of IndexedEntity[IndexedThreeDEntityUniforms, IndexedThreeDEntityAttributes]
  UncompiledIndexedThreeDEntity = object of UncompiledEntity[IndexedThreeDEntity, IndexedThreeDEntityUniforms, IndexedThreeDEntityAttributes]

proc initIndexedThreeDEntity*(positions: seq[GLfloat], normals: seq[GLfloat], texcoords: seq[GLfloat], indexes: seq[GLushort]): UncompiledIndexedThreeDEntity =
  result.vertexSource = indexedThreeDVertexShader
  result.fragmentSource = indexedThreeDFragmentShader
  # position
  var p = Attribute[GLfloat](size: 3, iter: 1)
  new(p.data)
  p.data[] = positions
  # normal
  var n = Attribute[GLfloat](size: 3, iter: 1)
  new(n.data)
  n.data[] = normals
  # texcoord
  var t = Attribute[GLfloat](size: 2, iter: 1)
  new(t.data)
  t.data[] = texcoords
  # indexes
  var i = IndexBuffer[GLushort]()
  new(i.data)
  i.data[] = indexes
  # set attrs
  result.attributes = IndexedThreeDEntityAttributes(
    a_position: p,
    a_normal: n,
    a_texcoord: t,
    indexes: i
  )

type
  IndexedThreeDObject* = tuple[
    tz: GLfloat,
    rx: GLfloat,
    ry: GLfloat,
    matUniforms: tuple[
      u_color: Uniform[Vec4[GLfloat]],
      u_specular: Uniform[Vec4[GLfloat]],
      u_shininess: Uniform[GLfloat],
      u_specularFactor: Uniform[GLfloat]
    ]
  ]

proc renderIndexedEntity*(game: Game, entity: var IndexedThreeDEntity, objects: seq[IndexedThreeDObject]) =
  let
    projectionMatrix = pmath.projectPerspectiveMat(degToRad(60f), game.frameWidth / game.frameHeight, 1f, 2000f)
    cameraMatrix = pmath.lookAtMat(vec3(0f, 0f, 100f), vec3(0f, 0f, 0f), vec3(0f, 1f, 0f))
    viewMatrix = cameraMatrix.inverse()
    viewProjectionMatrix = viewMatrix * projectionMatrix
  entity.uniforms.u_lightWorldPos = Uniform[Vec3[GLfloat]](data: vec3(-50f, 30f, 100f))
  entity.uniforms.u_viewInverse = Uniform[Mat4x4[GLfloat]](data: cameraMatrix)
  entity.uniforms.u_lightColor = Uniform[Vec4[GLfloat]](data: vec4(1f, 1f, 1f, 1f))
  for (tz, rx, ry, matUniforms) in objects:
    var worldMatrix = mat4f(1)
    worldMatrix.rotateX(rx * game.totalTime)
    worldMatrix.rotateY(ry * game.totalTime)
    worldMatrix.translate(0f, 0f, tz)
    entity.uniforms.u_world = Uniform[Mat4x4[GLfloat]](data: worldMatrix)
    entity.uniforms.u_worldViewProjection = Uniform[Mat4x4[GLfloat]](data: worldMatrix * viewProjectionMatrix)
    entity.uniforms.u_worldInverseTranspose = Uniform[Mat4x4[GLfloat]](data: worldMatrix.inverse().transpose())
    entity.uniforms.u_color = matUniforms.u_color
    entity.uniforms.u_specular = matUniforms.u_specular
    entity.uniforms.u_shininess = matUniforms.u_shininess
    entity.uniforms.u_specularFactor = matUniforms.u_specularFactor
    render(game, entity)
