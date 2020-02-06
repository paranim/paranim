import paranim/gl, paranim/gl/utils
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

proc project*(uni: var Uniform, left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  uni.enable = true
  uni.data = ortho(left, right, bottom, top, near, far) * uni.data

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.enable = true
  uni.data = translation(x, y, z) * uni.data

proc scale*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.enable = true
  uni.data = scaling(x, y, z) * uni.data

proc rotateX*(uni: var Uniform, angle: GLFloat) =
  uni.enable = true
  uni.data = rotationX(angle) * uni.data

proc rotateY*(uni: var UniForm, angle: GLFloat) =
  uni.enable = true
  uni.data = rotationY(angle) * uni.data

proc rotateZ*(uni: var Uniform, angle: GLFloat) =
  uni.enable = true
  uni.data = rotationZ(angle) * uni.data

proc project*[UniT, AttrT](entity: var Entity[UniT, AttrT], left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  entity.uniforms.u_matrix.project(left, right, bottom, top, near, far)

proc translate*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.translate(x, y, z)

proc scale*[UniT, AttrT](entity: var Entity[UniT, AttrT], x: GLfloat, y: GLfloat, z: GLfloat) =
  entity.uniforms.u_matrix.scale(x, y, z)

proc rotateX*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateX(angle)

proc rotateY*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateY(angle)

proc rotateZ*[UniT, AttrT](entity: var Entity[UniT, AttrT], angle: GLFloat) =
  entity.uniforms.u_matrix.rotateZ(angle)

