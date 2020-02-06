import paranim/gl/utils
from paranim/math as pmath import nil
import nimgl/opengl
import glm

proc project*(uni: var Uniform, left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  uni.enable = true
  uni.data = pmath.ortho(left, right, bottom, top, near, far) * uni.data

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.enable = true
  uni.data = pmath.translation(x, y, z) * uni.data

proc scale*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.enable = true
  uni.data = pmath.scaling(x, y, z) * uni.data

proc rotateX*(uni: var Uniform, angle: GLFloat) =
  uni.enable = true
  uni.data = pmath.rotationX(angle) * uni.data

proc rotateY*(uni: var UniForm, angle: GLFloat) =
  uni.enable = true
  uni.data = pmath.rotationY(angle) * uni.data

proc rotateZ*(uni: var Uniform, angle: GLFloat) =
  uni.enable = true
  uni.data = pmath.rotationZ(angle) * uni.data

