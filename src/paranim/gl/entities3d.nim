import paranim/gl/utils
import nimgl/opengl
import glm
from math import nil

proc identity*(): Mat4x4[GLfloat] =
  mat4x4(
    vec4(1f, 0f, 0f, 0f),
    vec4(0f, 1f, 0f, 0f),
    vec4(0f, 0f, 1f, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc ortho*(left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat): Mat4x4[GLfloat] =
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

proc translation*(x: GLfloat, y: GLfloat, z: GLfloat): Mat4x4[GLfloat] =
  mat4x4(
    vec4(1f, 0f, 0f, x),
    vec4(0f, 1f, 0f, y),
    vec4(0f, 0f, 1f, z),
    vec4(0f, 0f, 0f, 1f)
  )

proc scaling*(x: GLfloat, y: GLfloat, z: GLfloat): Mat4x4[GLfloat] =
  mat4x4(
    vec4(x, 0f, 0f, 0f),
    vec4(0f, y, 0f, 0f),
    vec4(0f, 0f, z, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc rotationX*(angle: GLfloat): Mat4x4[GLfloat] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4(1f, 0f, 0f, 0f),
    vec4(0f, c, -s, 0f),
    vec4(0f, s, c, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc rotationY*(angle: GLfloat): Mat4x4[GLfloat] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4(c, 0f, s, 0f),
    vec4(0f, 1f, 0f, 0f),
    vec4(-s, 0f, c, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc rotationZ*(angle: GLfloat): Mat4x4[GLfloat] =
  let c = math.cos(angle)
  let s = math.sin(angle)
  mat4x4(
    vec4(c, -s, 0f, 0f),
    vec4(s, c, 0f, 0f),
    vec4(0f, 0f, 1f, 0f),
    vec4(0f, 0f, 0f, 1f)
  )

proc project*[T](entity: var T, left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  entity.uniforms.u_matrix.enable = true
  entity.uniforms.u_matrix.data = ortho(left, right, bottom, top, near, far) * entity.uniforms.u_matrix.data

proc translate*[T](entity: var T, x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.enable = true
  entity.uniforms.u_matrix.data = translation(x, y, z) * entity.uniforms.u_matrix.data

proc scale*[T](entity: var T, x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.enable = true
  entity.uniforms.u_matrix.data = scaling(x, y, z) * entity.uniforms.u_matrix.data

proc rotateX*[T](entity: var T, angle: GLFloat) =
  entity.uniforms.u_matrix.enable = true
  entity.uniforms.u_matrix.data = rotationX(angle) * entity.uniforms.u_matrix.data

proc rotateY*[T](entity: var T, angle: GLFloat) =
  entity.uniforms.u_matrix.enable = true
  entity.uniforms.u_matrix.data = rotationY(angle) * entity.uniforms.u_matrix.data

proc rotateZ*[T](entity: var T, angle: GLFloat) =
  entity.uniforms.u_matrix.enable = true
  entity.uniforms.u_matrix.data = rotationZ(angle) * entity.uniforms.u_matrix.data

