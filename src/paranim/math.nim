import glm
from std/math import nil

proc identity*[T: Mat3x3 | Mat4x4](): T =
  when T is Mat3x3:
    mat3x3(
      vec3(1f, 0f, 0f),
      vec3(0f, 1f, 0f),
      vec3(0f, 0f, 1f)
    )
  elif T is Mat4x4:
    mat4x4(
      vec4(1f, 0f, 0f, 0f),
      vec4(0f, 1f, 0f, 0f),
      vec4(0f, 0f, 1f, 0f),
      vec4(0f, 0f, 0f, 1f)
    )

# 2D

proc projection*[T](width: T, height: T): Mat3x3[T] =
  mat3x3(
    vec3(2f / width, 0f, -1f),
    vec3(0f, -2f / height, 1f),
    vec3(0f, 0f, 1f)
  )

proc translation*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3(1f, 0f, x),
    vec3(0f, 1f, y),
    vec3(0f, 0f, 1f)
  )

proc scaling*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3(x, 0f, 0f),
    vec3(0f, y, 0f),
    vec3(0f, 0f, 1f)
  )

proc rotation*[T](angle: T): Mat3x3[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat3x3(
    vec3(c, s, 0f),
    vec3(-s, c, 0f),
    vec3(0f, 0f, 1f)
  )

# 3D

proc ortho*[T](left: T, right: T, bottom: T, top: T, near: T, far: T): Mat4x4[T] =
  let
    width = right - left
    height = top - bottom
    depth = near - far
  mat4x4(
    vec4(2f / width, 0f, 0f, (left + right) / (left - right)),
    vec4(0f, 2f / height, 0f, (bottom + top) / (bottom - top)),
    vec4(0f, 0f, 2f / depth, (near + far) / (near - far)),
    vec4(0f, 0f, 0f, 1f)
  )

proc translation*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4(1f, 0f, 0f, x),
    vec4(0f, 1f, 0f, y),
    vec4(0f, 0f, 1f, z),
    vec4(0f, 0f, 0f, 1f)
  )

proc scaling*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4(x, 0f, 0f, 0f),
    vec4(0f, y, 0f, 0f),
    vec4(0f, 0f, z, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc rotationX*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4(1f, 0f, 0f, 0f),
    vec4(0f, c, -s, 0f),
    vec4(0f, s, c, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc rotationY*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4(c, 0f, s, 0f),
    vec4(0f, 1f, 0f, 0f),
    vec4(-s, 0f, c, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc rotationZ*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4(c, -s, 0f, 0f),
    vec4(s, c, 0f, 0f),
    vec4(0f, 0f, 1f, 0f),
    vec4(0f, 0f, 0f, 1f)
  )
