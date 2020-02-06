import glm
from std/math import nil

# 2D

proc identity3x3*[T](): Mat3x3[T] =
  mat3x3(
    vec3[T](1f, 0f, 0f),
    vec3[T](0f, 1f, 0f),
    vec3[T](0f, 0f, 1f)
  )

proc projection*[T](width: T, height: T): Mat3x3[T] =
  mat3x3(
    vec3[T](2f / width, 0f, -1f),
    vec3[T](0f, -2f / height, 1f),
    vec3[T](0f, 0f, 1f)
  )

proc translation*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](1f, 0f, x),
    vec3[T](0f, 1f, y),
    vec3[T](0f, 0f, 1f)
  )

proc scaling*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](x, 0f, 0f),
    vec3[T](0f, y, 0f),
    vec3[T](0f, 0f, 1f)
  )

proc rotation*[T](angle: T): Mat3x3[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat3x3(
    vec3[T](c, s, 0f),
    vec3[T](-s, c, 0f),
    vec3[T](0f, 0f, 1f)
  )

# 3D

proc identity4x4*[T](): Mat4x4[T] =
  mat4x4(
    vec4[T](1f, 0f, 0f, 0f),
    vec4[T](0f, 1f, 0f, 0f),
    vec4[T](0f, 0f, 1f, 0f),
    vec4[T](0f, 0f, 0f, 1f)
  )

proc ortho*[T](left: T, right: T, bottom: T, top: T, near: T, far: T): Mat4x4[T] =
  let
    width = right - left
    height = top - bottom
    depth = near - far
  mat4x4(
    vec4[T](2f / width, 0f, 0f, (left + right) / (left - right)),
    vec4[T](0f, 2f / height, 0f, (bottom + top) / (bottom - top)),
    vec4[T](0f, 0f, 2f / depth, (near + far) / (near - far)),
    vec4[T](0f, 0f, 0f, 1f)
  )

proc perspective*[T](fieldOfView: T, aspect: T, near: T, far: T): Mat4x4[T] =
  let
    f = math.tan((math.PI * 0.5f) - (fieldOfView * 0.5f))
    rangeInv = 1 / (near - far)
  mat4x4(
    vec4[T](f / aspect, 0f, 0f, 0f),
    vec4[T](0f, f, 0f, 0f),
    vec4[T](0f, 0f, (near + far) * rangeInv, near * far * rangeInv * 2),
    vec4[T](0f, 0f, -1f, 0f)
  )

proc translation*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](1f, 0f, 0f, x),
    vec4[T](0f, 1f, 0f, y),
    vec4[T](0f, 0f, 1f, z),
    vec4[T](0f, 0f, 0f, 1f)
  )

proc scaling*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](x, 0f, 0f, 0f),
    vec4[T](0f, y, 0f, 0f),
    vec4[T](0f, 0f, z, 0f),
    vec4[T](0f, 0f, 0f, 1f)
  )

proc rotationX*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](1f, 0f, 0f, 0f),
    vec4[T](0f, c, -s, 0f),
    vec4[T](0f, s, c, 0f),
    vec4[T](0f, 0f, 0f, 1f)
  )

proc rotationY*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, 0f, s, 0f),
    vec4[T](0f, 1f, 0f, 0f),
    vec4[T](-s, 0f, c, 0f),
    vec4[T](0f, 0f, 0f, 1f)
  )

proc rotationZ*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, -s, 0f, 0f),
    vec4[T](s, c, 0f, 0f),
    vec4[T](0f, 0f, 1f, 0f),
    vec4[T](0f, 0f, 0f, 1f)
  )
