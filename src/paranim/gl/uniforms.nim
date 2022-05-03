import paranim/math
import paranim/opengl
import paranim/glm

type
  Uniform*[T] = object
    disable*: bool
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
    textureNum*: GLuint
  RenderToTexture*[T, GameT] = object of Texture[T]
    framebuffer*: GLuint
    render*: proc (game: GameT)

# 2D

proc project*(uni: var Uniform, width: GLfloat, height: GLfloat) =
  uni.disable = false
  uni.data.project(width, height)

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat) =
  uni.disable = false
  uni.data.translate(x, y)

proc scale*(uni: var Uniform, x: GLfloat, y: GLfloat) =
  uni.disable = false
  uni.data.scale(x, y)

proc rotate*(uni: var Uniform, angle: GLFloat) =
  uni.disable = false
  uni.data.rotate(angle)

proc invert*(uni: var Uniform, camera: Mat3x3[GLfloat]) =
  uni.disable = false
  uni.data.invert(camera)

proc color*(uni: var Uniform, rgba: Vec4[GLfloat]) =
  uni.disable = false
  uni.data = rgba

proc crop*(uni: var Uniform, x: GLfloat, y: GLfloat, width: GLfloat, height: GLfloat, texWidth: GLfloat, texHeight: GLfloat) =
  uni.disable = false
  uni.data = translateMat(x / texWidth, y / texHeight) * uni.data
  uni.data = scaleMat(width / texWidth, height / texHeight) * uni.data

# 3D

proc project*(uni: var Uniform, left: GLfloat, right: GLfloat, bottom: GLfloat, top: GLfloat, near: GLfloat, far: GLfloat) =
  uni.disable = false
  uni.data.project(left, right, bottom, top, near, far)

proc project*(uni: var Uniform, fieldOfView: GLfloat, aspect: GLfloat, near: GLfloat, far: GLfloat) =
  uni.disable = false
  uni.data.project(fieldOfView, aspect, near, far)

proc translate*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.disable = false
  uni.data.translate(x, y, z)

proc scale*(uni: var Uniform, x: GLfloat, y: GLfloat, z: GLfloat) =
  uni.disable = false
  uni.data.scale(x, y, z)

proc rotateX*(uni: var Uniform, angle: GLFloat) =
  uni.disable = false
  uni.data.rotateX(angle)

proc rotateY*(uni: var Uniform, angle: GLFloat) =
  uni.disable = false
  uni.data.rotateY(angle)

proc rotateZ*(uni: var Uniform, angle: GLFloat) =
  uni.disable = false
  uni.data.rotateZ(angle)

proc invert*(uni: var Uniform, camera: Mat4x4[GLfloat]) =
  uni.disable = false
  uni.data.invert(camera)

