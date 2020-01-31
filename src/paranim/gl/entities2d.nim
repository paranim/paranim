import paranim/gl, paranim/gl/utils, paranim/primitives2d
import nimgl/opengl
import glm

type
  TwoDEntityUniForms = tuple[u_matrix: tuple[update: bool, data: Mat3x3[GLfloat]], u_color: tuple[update: bool, data: Vec4[GLfloat]]]
  TwoDEntityAttributes = tuple[a_position: Attribute[GLfloat]]
  TwoDEntity* = object of Entity[TwoDEntityUniForms, TwoDEntityAttributes]
  UncompiledTwoDEntityUniForms = tuple[u_matrix: Mat3x3[GLfloat], u_color: Vec4[GLfloat]]
  UncompiledTwoDEntity* = object of UncompiledEntity[TwoDEntity, UncompiledTwoDEntityUniForms, TwoDEntityAttributes]
  ImageEntityUniForms = tuple[u_matrix: tuple[update: bool, data: Mat3x3[GLfloat]], u_texture_matrix: tuple[update: bool, data: Mat3x3[GLfloat]]]
  ImageEntityAttributes = tuple[a_position: Attribute[GLfloat]]
  ImageEntity* = object of Entity[ImageEntityUniForms, ImageEntityAttributes]
  UncompiledImageEntityUniForms = tuple[u_matrix: Mat3x3[GLfloat], u_texture_matrix: Mat3x3[GLfloat], u_image: Texture[GLubyte]]
  UncompiledImageEntity* = object of UncompiledEntity[ImageEntity, UncompiledImageEntityUniForms, ImageEntityAttributes]

proc identityMatrix(): Mat3x3[GLfloat] =
  mat3x3(
    vec3(1f, 0f, 0f),
    vec3(0f, 1f, 0f),
    vec3(0f, 0f, 1f)
  )

proc projectionMatrix(width: GLfloat, height: GLfloat): Mat3x3[GLfloat] =
  mat3x3(
    vec3(2f / width, 0f, -1f),
    vec3(0f, -2f / height, 1f),
    vec3(0f, 0f, 1f)
  )

proc translationMatrix(x: GLfloat, y: GLfloat): Mat3x3[GLfloat] =
  mat3x3(
    vec3(1f, 0f, x),
    vec3(0f, 1f, y),
    vec3(0f, 0f, 1f)
  )

proc scalingMatrix(x: GLfloat, y: GLfloat): Mat3x3[GLfloat] =
  mat3x3(
    vec3(x, 0f, 0f),
    vec3(0f, y, 0f),
    vec3(0f, 0f, 1f)
  )

proc project*(entity: var UncompiledTwoDEntity, width: GLfloat, height: GLfloat) =
  entity.uniforms.u_matrix = projectionMatrix(width, height) * entity.uniforms.u_matrix

proc project*(entity: var UncompiledImageEntity, width: GLfloat, height: GLfloat) =
  entity.uniforms.u_matrix = projectionMatrix(width, height) * entity.uniforms.u_matrix

proc project*(entity: var TwoDEntity, width: GLfloat, height: GLfloat) =
  entity.uniforms.u_matrix.update = true
  entity.uniforms.u_matrix.data = projectionMatrix(width, height) * entity.uniforms.u_matrix.data

proc project*(entity: var ImageEntity, width: GLfloat, height: GLfloat) =
  entity.uniforms.u_matrix.update = true
  entity.uniforms.u_matrix.data = projectionMatrix(width, height) * entity.uniforms.u_matrix.data

proc translate*(entity: var UncompiledTwoDEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix = translationMatrix(x, y) * entity.uniforms.u_matrix

proc translate*(entity: var UncompiledImageEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix = translationMatrix(x, y) * entity.uniforms.u_matrix

proc translate*(entity: var TwoDEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix.update = true
  entity.uniforms.u_matrix.data = translationMatrix(x, y) * entity.uniforms.u_matrix.data

proc translate*(entity: var ImageEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix.update = true
  entity.uniforms.u_matrix.data = translationMatrix(x, y) * entity.uniforms.u_matrix.data

proc scale*(entity: var UncompiledTwoDEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix = scalingMatrix(x, y) * entity.uniforms.u_matrix

proc scale*(entity: var UncompiledImageEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix = scalingMatrix(x, y) * entity.uniforms.u_matrix

proc scale*(entity: var TwoDEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix.update = true
  entity.uniforms.u_matrix.data = scalingMatrix(x, y) * entity.uniforms.u_matrix.data

proc scale*(entity: var ImageEntity, x: GLfloat, y: GLfloat) =
  entity.uniforms.u_matrix.update = true
  entity.uniforms.u_matrix.data = scalingMatrix(x, y) * entity.uniforms.u_matrix.data

proc color*(entity: var UncompiledTwoDEntity, rgba: array[4, GLfloat]) =
  entity.uniforms.u_color = vec4(rgba[0], rgba[1], rgba[2], rgba[3])

proc color*(entity: var TwoDEntity, rgba: array[4, GLfloat]) =
  entity.uniforms.u_color.update = true
  entity.uniforms.u_color.data = vec4(rgba[0], rgba[1], rgba[2], rgba[3])

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

proc init2DEntity*(game: RootGame, data: seq[GLfloat]): UncompiledTwoDEntity =
  result.vertexSource = twoDVertexShader
  result.fragmentSource = twoDFragmentShader
  result.attributes = (a_position: Attribute[GLfloat](data: data, size: 2, iter: 1))
  result.uniforms = (
    u_matrix: identityMatrix(),
    u_color: vec4(0f, 0f, 0f, 0f)
  )

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

proc initImageEntity*(game: RootGame, data: seq[GLubyte], width: int, height: int): UncompiledImageEntity =
  result.vertexSource = imageVertexShader
  result.fragmentSource = imageFragmentShader
  result.attributes = (a_position: Attribute[GLfloat](data: rect, size: 2, iter: 1))
  result.uniforms = (
    u_matrix: identityMatrix(),
    u_texture_matrix: identityMatrix(),
    u_image: Texture[GLubyte](
      data: data,
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
  )
