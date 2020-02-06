from paranim/math as pmath import nil
import nimgl/opengl
import glm

type
  Uniform*[T] = object
    enable*: bool
    data*: T
  TextureOpts* = object
    mipLevel*: GLint
    internalFmt*: GLenum
    width*: GLsizei
    height*: GLsizei
    border*: GLint
    srcFmt*: GLenum
  Texture*[T] = object
    data*: ref seq[T]
    opts*: TextureOpts
    params*: seq[(GLenum, GLenum)]
    pixelStoreParams*: seq[(GLenum, GLint)]
    mipmapParams*: seq[GLenum]
    unit*: GLint

# 2D

proc project*(uni: var UniForm, width: GLfloat, height: GLfloat) =
  uni.enable = true
  uni.data = pmath.projection(width, height) * uni.data

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat) =
  uni.enable = true
  uni.data = pmath.translation(x, y) * uni.data

proc scale*(uni: var UniForm, x: GLfloat, y: GLfloat) =
  uni.enable = true
  uni.data = pmath.scaling(x, y) * uni.data

proc rotate*(uni: var UniForm, angle: GLFloat) =
  uni.enable = true
  uni.data = pmath.rotation(angle) * uni.data

proc color*(uni: var UniForm, rgba: array[4, GLfloat]) =
  uni.enable = true
  uni.data = vec4(rgba[0], rgba[1], rgba[2], rgba[3])

# 3D

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

