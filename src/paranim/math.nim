import paranim/glm
from std/math import nil

# 2D

proc projectMat*[T](width: T, height: T): Mat3x3[T] =
  mat3x3(
    vec3[T](2.T / width, 0.T, -1.T),
    vec3[T](0.T, -2.T / height, 1.T),
    vec3[T](0.T, 0.T, 1.T)
  )

proc project*[T](matrix: var Mat3x3[T], width: T, height: T) =
  matrix = projectMat(width, height) * matrix

proc translateMat*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](1.T, 0.T, x),
    vec3[T](0.T, 1.T, y),
    vec3[T](0.T, 0.T, 1.T)
  )

proc translate*[T](matrix: var Mat3x3[T], x: T, y: T) =
  matrix = translateMat(x, y) * matrix

proc scaleMat*[T](x: T, y: T): Mat3x3[T] =
  mat3x3(
    vec3[T](x, 0.T, 0.T),
    vec3[T](0.T, y, 0.T),
    vec3[T](0.T, 0.T, 1.T)
  )

proc scale*[T](matrix: var Mat3x3[T], x: T, y: T) =
  matrix = scaleMat(x, y) * matrix

proc rotateMat*[T](angle: T): Mat3x3[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat3x3(
    vec3[T](c, s, 0.T),
    vec3[T](-s, c, 0.T),
    vec3[T](0.T, 0.T, 1.T)
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
    vec4[T](2.T / width, 0.T, 0.T, (left + right) / (left - right)),
    vec4[T](0.T, 2.T / height, 0.T, (bottom + top) / (bottom - top)),
    vec4[T](0.T, 0.T, 2.T / depth, (near + far) / (near - far)),
    vec4[T](0.T, 0.T, 0.T, 1.T)
  )

proc project*[T](matrix: var Mat4x4[T], left: T, right: T, bottom: T, top: T, near: T, far: T) =
  matrix = projectOrthoMat(left, right, bottom, top, near, far) * matrix

proc projectPerspectiveMat*[T](fieldOfView: T, aspect: T, near: T, far: T): Mat4x4[T] =
  let
    f = math.tan((math.PI * T(0.5)) - (fieldOfView * T(0.5)))
    rangeInv = 1 / (near - far)
  mat4x4(
    vec4[T](f / aspect, 0.T, 0.T, 0.T),
    vec4[T](0.T, f, 0.T, 0.T),
    vec4[T](0.T, 0.T, (near + far) * rangeInv, near * far * rangeInv * 2),
    vec4[T](0.T, 0.T, -1.T, 0.T)
  )

proc project*[T](matrix: var Mat4x4[T], fieldOfView: T, aspect: T, near: T, far: T) =
  matrix = projectPerspectiveMat(fieldOfView, aspect, near, far) * matrix

proc translateMat*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](1.T, 0.T, 0.T, x),
    vec4[T](0.T, 1.T, 0.T, y),
    vec4[T](0.T, 0.T, 1.T, z),
    vec4[T](0.T, 0.T, 0.T, 1.T)
  )

proc translate*[T](matrix: var Mat4x4[T], x: T, y: T, z: T) =
  matrix = translateMat(x, y, z) * matrix

proc scaleMat*[T](x: T, y: T, z: T): Mat4x4[T] =
  mat4x4(
    vec4[T](x, 0.T, 0.T, 0.T),
    vec4[T](0.T, y, 0.T, 0.T),
    vec4[T](0.T, 0.T, z, 0.T),
    vec4[T](0.T, 0.T, 0.T, 1.T)
  )

proc scale*[T](matrix: var Mat4x4[T], x: T, y: T, z: T) =
  matrix = scaleMat(x, y, z) * matrix

proc rotateXMat*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](1.T, 0.T, 0.T, 0.T),
    vec4[T](0.T, c, -s, 0.T),
    vec4[T](0.T, s, c, 0.T),
    vec4[T](0.T, 0.T, 0.T, 1.T)
  )

proc rotateX*[T](matrix: var Mat4x4[T], angle: T) =
  matrix = rotateXMat(angle) * matrix

proc rotateYMat*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, 0.T, s, 0.T),
    vec4[T](0.T, 1.T, 0.T, 0.T),
    vec4[T](-s, 0.T, c, 0.T),
    vec4[T](0.T, 0.T, 0.T, 1.T)
  )

proc rotateY*[T](matrix: var Mat4x4[T], angle: T) =
  matrix = rotateYMat(angle) * matrix

proc rotateZMat*[T](angle: T): Mat4x4[T] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4[T](c, -s, 0.T, 0.T),
    vec4[T](s, c, 0.T, 0.T),
    vec4[T](0.T, 0.T, 1.T, 0.T),
    vec4[T](0.T, 0.T, 0.T, 1.T)
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
    vec4[T](0.T, 0.T, 0.T, 1.T)
  )

proc lookAt*[T](matrix: var Mat4x4[T], target: Vec3[T], up: Vec3[T]) =
  let cameraPos = vec3(matrix[0][3], matrix[1][3], matrix[2][3])
  matrix = lookAtMat(cameraPos, target, up)

proc invert*[T](matrix: var Mat4x4[T], camera: Mat4x4[T]) =
  matrix = camera.inverse() * matrix
