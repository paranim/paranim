import paranim/gl, paranim/gl/uniforms, paranim/gl/attributes
from paranim/math as pmath import nil
from paranim/primitives import nil
import nimgl/opengl
import glm

type
  TwoDEntityUniForms = tuple[u_matrix: Uniform[Mat3x3[GLfloat]], u_color: Uniform[Vec4[GLfloat]]]
  TwoDEntityAttributes = tuple[a_position: Attribute[GLfloat]]
  TwoDEntity* = object of ArrayEntity[TwoDEntityUniForms, TwoDEntityAttributes]
  UncompiledTwoDEntity* = object of UncompiledEntity[TwoDEntity, TwoDEntityUniForms, TwoDEntityAttributes]
  InstancedTwoDEntityUniForms = tuple[u_matrix: Uniform[Mat3x3[GLfloat]]]
  InstancedTwoDEntityAttributes = tuple[a_position: Attribute[GLfloat], a_color: Attribute[GLfloat], a_matrix: Attribute[GLfloat]]
  InstancedTwoDEntity* = object of InstancedEntity[InstancedTwoDEntityUniForms, InstancedTwoDEntityAttributes]
  UncompiledInstancedTwoDEntity* = object of UncompiledEntity[InstancedTwoDEntity, InstancedTwoDEntityUniForms, InstancedTwoDEntityAttributes]
  ImageEntityUniForms = tuple[u_matrix: Uniform[Mat3x3[GLfloat]], u_texture_matrix: Uniform[Mat3x3[GLfloat]], u_image: Uniform[Texture[GLubyte]]]
  ImageEntityAttributes = tuple[a_position: Attribute[GLfloat]]
  ImageEntity* = object of ArrayEntity[ImageEntityUniForms, ImageEntityAttributes]
  UncompiledImageEntity* = object of UncompiledEntity[ImageEntity, ImageEntityUniForms, ImageEntityAttributes]

proc project*[UniT, AttrT](entity: var Entity[UniT, AttrT], width: GLfloat, height: GLfloat) =
  entity.uniforms.u_matrix.project(width, height)

proc translate*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix.translate(x, y)

proc scale*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix.scale(x, y)

proc rotate*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotate(angle)

proc color*[UniT, AttrT](entity: var Entity[UniT, AttrT], rgba: array[4, GLfloat]) =
  entity.uniforms.u_color.color(rgba)

const twoDVertexShader =
  """
  #version 410
  uniform mat3 u_matrix;
  in vec2 a_position;
  void main()
  {
    gl_Position = vec4((u_matrix * vec3(a_position, 1)).xy, 0, 1);
  }
  """

const twoDFragmentShader =
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

proc initTwoDEntity*(data: openArray[GLfloat]): UncompiledTwoDEntity =
  result.vertexSource = twoDVertexShader
  result.fragmentSource = twoDFragmentShader
  var position = Attribute[GLfloat](enable: true, size: 2, iter: 1)
  new(position.data)
  position.data[].add(data)
  result.attributes = (a_position: position)
  result.uniforms = (
    u_matrix: Uniform[Mat3x3[GLfloat]](enable: true, data: pmath.identity3x3[GLfloat]()),
    u_color: Uniform[Vec4[GLfloat]](enable: true, data: vec4(0f, 0f, 0f, 1f))
  )

const instancedTwoDVertexShader =
  """
  #version 410
  uniform mat3 u_matrix;
  in vec2 a_position;
  in mat3 a_matrix;
  in vec4 a_color;
  out vec4 v_color;
  void main()
  {
    v_color = a_color;
    gl_Position = vec4((u_matrix * a_matrix * vec3(a_position, 1)).xy, 0, 1);
  }
  """

const instancedTwoDFragmentShader =
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

proc initInstancedEntity*(entity: UncompiledTwoDEntity): UncompiledInstancedTwoDEntity =
  result.vertexSource = instancedTwoDVertexShader
  result.fragmentSource = instancedTwoDFragmentShader
  result.uniforms.u_matrix = entity.uniforms.u_matrix
  result.attributes.a_matrix = Attribute[GLfloat](divisor: 1, size: 3, iter: 3)
  new(result.attributes.a_matrix.data)
  result.attributes.a_color = Attribute[GLfloat](divisor: 1, size: 4, iter: 1)
  new(result.attributes.a_color.data)
  deepCopy(result.attributes.a_position, entity.attributes.a_position)

proc addInstanceAttr[T](attr: var Attribute[T], uni: Uniform[Mat3x3[T]]) =
  for r in 0 .. 2:
    for c in 0 .. 2:
      attr.data[].add(uni.data.row(r)[c])
  attr.enable = true

proc addInstanceAttr[T](attr: var Attribute[T], uni: Uniform[Vec4[T]]) =
  for x in 0 .. 3:
    attr.data[].add(uni.data[x])
  attr.enable = true

proc add*(instancedEntity: var UncompiledInstancedTwoDEntity, entity: UncompiledTwoDEntity) =
  addInstanceAttr(instancedEntity.attributes.a_matrix, entity.uniforms.u_matrix)
  addInstanceAttr(instancedEntity.attributes.a_color, entity.uniforms.u_color)

const imageVertexShader =
  """
  #version 410
  uniform mat3 u_matrix;
  uniform mat3 u_texture_matrix;
  in vec2 a_position;
  out vec2 v_tex_coord;
  void main()
  {
    gl_Position = vec4((u_matrix * vec3(a_position, 1)).xy, 0, 1);
    v_tex_coord = (u_texture_matrix * vec3(a_position, 1)).xy;
  }
  """

const imageFragmentShader =
  """
  #version 410
  precision mediump float;
  uniform sampler2D u_image;
  in vec2 v_tex_coord;
  out vec4 o_color;
  void main()
  {
    o_color = texture(u_image, v_tex_coord);
  }
  """

proc initImageEntity*(data: openArray[GLubyte], width: int, height: int): UncompiledImageEntity =
  result.vertexSource = imageVertexShader
  result.fragmentSource = imageFragmentShader
  # create attribute
  var position = Attribute[GLfloat](enable: true, size: 2, iter: 1)
  new(position.data)
  position.data[].add(primitives.rect)
  # create texture
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
    ]
  )
  new(image.data)
  image.data[].add(data)
  # set attributes and uniforms
  result.attributes = (a_position: position)
  result.uniforms = (
    u_matrix: Uniform[Mat3x3[GLfloat]](enable: true, data: pmath.identity3x3[GLfloat]()),
    u_texture_matrix: Uniform[Mat3x3[GLfloat]](enable: true, data: pmath.identity3x3[GLfloat]()),
    u_image: Uniform[Texture[GLubyte]](
      enable: true,
      data: image
    )
  )
