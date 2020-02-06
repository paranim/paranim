import glm
from std/math import nil

# 2D

proc identity3x3*[T](): Mat3x3[T] =
  mat3x3(
    vec3[T](T(1), T(0), T(0)),
    vec3[T](T(0), T(1), T(0)),
    vec3[T](T(0), T(0), T(1))
  )

proc projection*[T](width: T, height: T): Mat3x3[T] =
  mat3x3(
    vec3[T](T(2) / width, T(0), -T(1)),
    vec3[T](T(0), -T(2) / height, T(1)),
    vec3[T](T(0), T(0), T(1))
  )

proc translation*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](T(1), T(0), x),
    vec3[T](T(0), T(1), y),
    vec3[T](T(0), T(0), T(1))
  )

proc scaling*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](x, T(0), T(0)),
    vec3[T](T(0), y, T(0)),
    vec3[T](T(0), T(0), T(1))
  )

proc rotation*[T](angle: T): Mat3x3[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat3x3(
    vec3[T](c, s, T(0)),
    vec3[T](-s, c, T(0)),
    vec3[T](T(0), T(0), T(1))
  )

# 3D

proc identity4x4*[T](): Mat4x4[T] =
  mat4x4(
    vec4[T](T(1), T(0), T(0), T(0)),
    vec4[T](T(0), T(1), T(0), T(0)),
    vec4[T](T(0), T(0), T(1), T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc ortho*[T](left: T, right: T, bottom: T, top: T, near: T, far: T): Mat4x4[T] =
  let
    width = right - left
    height = top - bottom
    depth = near - far
  mat4x4(
    vec4[T](T(2) / width, T(0), T(0), (left + right) / (left - right)),
    vec4[T](T(0), T(2) / height, T(0), (bottom + top) / (bottom - top)),
    vec4[T](T(0), T(0), T(2) / depth, (near + far) / (near - far)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc perspective*[T](fieldOfView: T, aspect: T, near: T, far: T): Mat4x4[T] =
  let
    f = math.tan((math.PI * T(0.5)) - (fieldOfView * T(0.5)))
    rangeInv = 1 / (near - far)
  mat4x4(
    vec4[T](f / aspect, T(0), T(0), T(0)),
    vec4[T](T(0), f, T(0), T(0)),
    vec4[T](T(0), T(0), (near + far) * rangeInv, near * far * rangeInv * 2),
    vec4[T](T(0), T(0), -T(1), T(0))
  )

proc translation*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](T(1), T(0), T(0), x),
    vec4[T](T(0), T(1), T(0), y),
    vec4[T](T(0), T(0), T(1), z),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc scaling*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](x, T(0), T(0), T(0)),
    vec4[T](T(0), y, T(0), T(0)),
    vec4[T](T(0), T(0), z, T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc rotationX*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](T(1), T(0), T(0), T(0)),
    vec4[T](T(0), c, -s, T(0)),
    vec4[T](T(0), s, c, T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc rotationY*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, T(0), s, T(0)),
    vec4[T](T(0), T(1), T(0), T(0)),
    vec4[T](-s, T(0), c, T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc rotationZ*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, -s, T(0), T(0)),
    vec4[T](s, c, T(0), T(0)),
    vec4[T](T(0), T(0), T(1), T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )
