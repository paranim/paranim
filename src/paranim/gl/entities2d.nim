import paranim/gl, paranim/gl/utils, paranim/primitives2d
import nimgl/opengl
import glm
import tables

type
  ImageEntityUniForms = tuple[u_texture_matrix: Mat3x3[cfloat], u_image: Texture[uint8]]
  ImageEntityAttributes = tuple[a_position: Attribute[cfloat]]
  ImageEntity* = object of Entity[ImageEntityUniForms, ImageEntityAttributes]
  UncompiledImageEntity* = object of UncompiledEntity[ImageEntity, ImageEntityUniForms, ImageEntityAttributes]

proc identityMatrix*(): Mat3x3[cfloat] =
  mat3x3(
    vec3(1f, 0f, 0f),
    vec3(0f, 1f, 0f),
    vec3(0f, 0f, 1f)
  )

proc projectionMatrix*(width: cfloat, height: cfloat): Mat3x3[cfloat] =
  mat3x3(
    vec3(2f / width, 0f, -1f),
    vec3(0f, -2f / height, 1f),
    vec3(0f, 0f, 1f)
  )

proc translationMatrix*(x: cfloat, y: cfloat): Mat3x3[cfloat] =
  mat3x3(
    vec3(1f, 0f, x),
    vec3(0f, 1f, y),
    vec3(0f, 0f, 1f)
  )

proc scalingMatrix*(x: cfloat, y: cfloat): Mat3x3[cfloat] =
  mat3x3(
    vec3(x, 0f, 0f),
    vec3(0f, y, 0f),
    vec3(0f, 0f, 1f)
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

proc initImageEntity*(game: RootGame, data: seq[uint8], width: int, height: int): UncompiledImageEntity =
  result.vertexSource = imageVertexShader
  result.fragmentSource = imageFragmentShader
  result.attributes = (a_position: Attribute[cfloat](data: rect, size: 2, iter: 1))
  let texMatrix = identityMatrix()
  let image = Texture[uint8](
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
  result.uniforms = (u_texture_matrix: texMatrix, u_image: image)