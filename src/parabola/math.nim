import glm

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
