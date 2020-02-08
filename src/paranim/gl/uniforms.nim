import paranim/math
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
  Texture*[T] = object of RootObj
    data*: ref seq[T]
    opts*: TextureOpts
    params*: seq[(GLenum, GLenum)]
    pixelStoreParams*: seq[(GLenum, GLint)]
    mipmapParams*: seq[GLenum]
    unit*: GLint
  RenderToTexture*[T, GameT] = object of Texture[T]
    framebuffer*: GLuint
    render*: proc (game: GameT)

# 2D

proc project*(uni: var UniForm, width: GLfloat, height: GLfloat) =
  uni.enable = true
  uni.data.project(width, height)

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat) =
  uni.enable = true
  uni.data.translate(x, y)

proc scale*(uni: var UniForm, x: GLfloat, y: GLfloat) =
  uni.enable = true
  uni.data.scale(x, y)

proc rotate*(uni: var UniForm, angle: GLFloat) =
  uni.enable = true
  uni.data.rotate(angle)

proc color*(uni: var UniForm, rgba: Vec4[GLfloat]) =
  uni.enable = true
  uni.data = rgba

# 3D

proc project*(uni: var Uniform, left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  uni.enable = true
  uni.data.project(left, right, bottom, top, near, far)

proc project*(uni: var Uniform, fieldOfView: GLfloat, aspect: GLfloat, near: GLfloat, far: GLfloat) =
  uni.enable = true
  uni.data.project(fieldOfView, aspect, near, far)

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.enable = true
  uni.data.translate(x, y, z)

proc scale*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.enable = true
  uni.data.scale(x, y, z)

proc rotateX*(uni: var Uniform, angle: GLFloat) =
  uni.enable = true
  uni.data.rotateX(angle)

proc rotateY*(uni: var UniForm, angle: GLFloat) =
  uni.enable = true
  uni.data.rotateY(angle)

proc rotateZ*(uni: var Uniform, angle: GLFloat) =
  uni.enable = true
  uni.data.rotateZ(angle)

proc invert*(uni: var Uniform, camera: Mat4x4[GLfloat]) =
  uni.enable = true
  uni.data.invert(camera)

