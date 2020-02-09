import glm
from std/math import nil

# 2D

proc projectMat*[T](width: T, height: T): Mat3x3[T] =
  mat3x3(
    vec3[T](T(2) / width, T(0), -T(1)),
    vec3[T](T(0), -T(2) / height, T(1)),
    vec3[T](T(0), T(0), T(1))
  )

proc project*[T](matrix: var Mat3x3[T], width: T, height: T) =
  matrix = projectMat(width, height) * matrix

proc translateMat*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](T(1), T(0), x),
    vec3[T](T(0), T(1), y),
    vec3[T](T(0), T(0), T(1))
  )

proc translate*[T](matrix: var Mat3x3[T], x: T, y: T) =
  matrix = translateMat(x, y) * matrix

proc scaleMat*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](x, T(0), T(0)),
    vec3[T](T(0), y, T(0)),
    vec3[T](T(0), T(0), T(1))
  )

proc scale*[T](matrix: var Mat3x3[T], x: T, y: T) =
  matrix = scaleMat(x, y) * matrix

proc rotateMat*[T](angle: T): Mat3x3[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat3x3(
    vec3[T](c, s, T(0)),
    vec3[T](-s, c, T(0)),
    vec3[T](T(0), T(0), T(1))
  )

proc rotate*[T](matrix: var Mat3x3[T], angle: T) =
  matrix = rotateMat(angle) * matrix

proc invert*[T](matrix: var Mat3x3[T], camera: Mat3x3[T]) =
  matrix = camera.inverse() * matrix

# 3D

proc projectOrthoMat*[T](left: T, right: T, bottom: T, top: T, near: T, far: T): Mat4x4[T] =
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

proc project*[T](matrix: var Mat4x4[T], left: T, right: T, bottom: T, top: T, near: T, far: T) =
  matrix = projectOrthoMat(left, right, bottom, top, near, far) * matrix

proc projectPerspectiveMat*[T](fieldOfView: T, aspect: T, near: T, far: T): Mat4x4[T] =
  let
    f = math.tan((math.PI * T(0.5)) - (fieldOfView * T(0.5)))
    rangeInv = 1 / (near - far)
  mat4x4(
    vec4[T](f / aspect, T(0), T(0), T(0)),
    vec4[T](T(0), f, T(0), T(0)),
    vec4[T](T(0), T(0), (near + far) * rangeInv, near * far * rangeInv * 2),
    vec4[T](T(0), T(0), -T(1), T(0))
  )

proc project*[T](matrix: var Mat4x4[T], fieldOfView: T, aspect: T, near: T, far: T) =
  matrix = projectPerspectiveMat(fieldOfView, aspect, near, far) * matrix

proc translateMat*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](T(1), T(0), T(0), x),
    vec4[T](T(0), T(1), T(0), y),
    vec4[T](T(0), T(0), T(1), z),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc translate*[T](matrix: var Mat4x4[T], x: T, y: T, z: T) =
  matrix = translateMat(x, y, z) * matrix

proc scaleMat*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](x, T(0), T(0), T(0)),
    vec4[T](T(0), y, T(0), T(0)),
    vec4[T](T(0), T(0), z, T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc scale*[T](matrix: var Mat4x4[T], x: T, y: T, z: T) =
  matrix = scaleMat(x, y, z) * matrix

proc rotateXMat*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](T(1), T(0), T(0), T(0)),
    vec4[T](T(0), c, -s, T(0)),
    vec4[T](T(0), s, c, T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc rotateX*[T](matrix: var Mat4x4[T], angle: T) =
  matrix = rotateXMat(angle) * matrix

proc rotateYMat*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, T(0), s, T(0)),
    vec4[T](T(0), T(1), T(0), T(0)),
    vec4[T](-s, T(0), c, T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc rotateY*[T](matrix: var Mat4x4[T], angle: T) =
  matrix = rotateYMat(angle) * matrix

proc rotateZMat*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, -s, T(0), T(0)),
    vec4[T](s, c, T(0), T(0)),
    vec4[T](T(0), T(0), T(1), T(0)),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc rotateZ*[T](matrix: var Mat4x4[T], angle: T) =
  matrix = rotateZMat(angle) * matrix

proc lookAtMat*[T](cameraPos: Vec3[T], target: Vec3[T], up: Vec3[T]): Mat4x4[T] =
  let
    zAxis = normalize(cameraPos - target)
    xAxis = normalize(cross(up, zAxis))
    yAxis = normalize(cross(zAxis, xAxis))
  mat4x4(
    vec4[T](xAxis[0], yAxis[0], zAxis[0], cameraPos[0]),
    vec4[T](xAxis[1], yAxis[1], zAxis[1], cameraPos[1]),
    vec4[T](xAxis[2], yAxis[2], zAxis[2], cameraPos[2]),
    vec4[T](T(0), T(0), T(0), T(1))
  )

proc lookAt*[T](matrix: var Mat4x4[T], target: Vec3[T], up: Vec3[T]) =
  let cameraPos = vec3(matrix[0][3], matrix[1][3], matrix[2][3])
  matrix = lookAtMat(cameraPos, target, up)

proc invert*[T](matrix: var Mat4x4[T], camera: Mat4x4[T]) =
  matrix = camera.inverse() * matrix
