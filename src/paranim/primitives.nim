from std/math import nil

proc rectangle*[T](): array[12, T] =
  [0.T, 0.T,
   1.T, 0.T,
   0.T, 1.T,
   0.T, 1.T,
   1.T, 0.T,
   1.T, 1.T]

# Low level 3D shape data, adapted from:
# https://github.com/greggman/twgl.js/blob/master/src/primitives.js

type Shape[T, IndexT] = tuple[positions: seq[T], normals: seq[T], texcoords: seq[T], indexes: seq[IndexT]]

proc plane*[T, IndexT](
    width: T,
    depth: T,
    subdivisionsWidth: int,
    subdivisionsDepth: int
  ): Shape[T, IndexT] =
  for z in 0 .. subdivisionsDepth:
    for x in 0 .. subdivisionsWidth:
      let
        u = x / subdivisionsWidth
        v = z / subdivisionsDepth
      result.positions.add(T(width * u - width * 0.5))
      result.positions.add(0.T)
      result.positions.add(T(depth * v - depth * 0.5))
      result.normals.add([0.T, 1.T, 0.T])
      result.texcoords.add([u.T, v.T])

  let numVertsAcross = subdivisionsWidth + 1
  for z in 0 ..< subdivisionsDepth:
    for x in 0 ..< subdivisionsWidth:
      # triangle 1
      result.indexes.add(IndexT((z + 0) * numVertsAcross + x))
      result.indexes.add(IndexT((z + 1) * numVertsAcross + x))
      result.indexes.add(IndexT((z + 0) * numVertsAcross + x + 1))
      # triangle 2
      result.indexes.add(IndexT((z + 1) * numVertsAcross + x))
      result.indexes.add(IndexT((z + 1) * numVertsAcross + x + 1))
      result.indexes.add(IndexT((z + 0) * numVertsAcross + x + 1))

proc sphere*[T, IndexT](
    radius: T,
    subdivisionsAxis: int,
    subdivisionsHeight: int,
    startLatitude: float = 0,
    endLatitude: float = math.PI,
    startLongitude: float = 0,
    endLongitude: float = 2 * math.PI
  ): Shape[T, IndexT] =
  let
    latRange = endLatitude.T - startLatitude.T
    longRange = endLongitude.T - startLongitude.T

  for y in 0 .. subdivisionsHeight:
    for x in 0 .. subdivisionsAxis:
      let
        u = x / subdivisionsAxis
        v = y / subdivisionsHeight
        theta = (longRange * u) + startLongitude
        phi = (latRange * v) + startLatitude
        sinTheta = math.sin(theta)
        cosTheta = math.cos(theta)
        sinPhi = math.sin(phi)
        cosPhi = math.cos(phi)
        ux = cosTheta * sinPhi
        uy = cosPhi
        uz = sinTheta * sinPhi
      result.positions.add([T(radius * ux), T(radius * uy), T(radius * uz)])
      result.normals.add([ux.T, uy.T, uz.T])
      result.texcoords.add([T(1 - u), v.T])

  let numVertsAround = subdivisionsAxis + 1
  for x in 0 ..< subdivisionsAxis:
    for y in 0 ..< subdivisionsHeight:
      # triangle 1
      result.indexes.add(IndexT((y + 0) * numVertsAround + x))
      result.indexes.add(IndexT((y + 0) * numVertsAround + x + 1))
      result.indexes.add(IndexT((y + 1) * numVertsAround + x))
      # triangle 2
      result.indexes.add(IndexT((y + 1) * numVertsAround + x))
      result.indexes.add(IndexT((y + 0) * numVertsAround + x + 1))
      result.indexes.add(IndexT((y + 1) * numVertsAround + x + 1))

const cubeFaceIndices = [
  [3, 7, 5, 1], # right
  [6, 2, 0, 4], # left
  [6, 7, 3, 2], # ?
  [0, 1, 5, 4], # ?
  [7, 6, 4, 5], # front
  [2, 3, 1, 0], # back
]

proc cube*[T, IndexT](size: T): Shape[T, IndexT] =
  let
    k = size / 2
    cornerVertices = [
      [-k, -k, -k],
      [+k, -k, -k],
      [-k, +k, -k],
      [+k, +k, -k],
      [-k, -k, +k],
      [+k, -k, +k],
      [-k, +k, +k],
      [+k, +k, +k],
    ]
    faceNormals = [
      [+1, +0, +0],
      [-1, +0, +0],
      [+0, +1, +0],
      [+0, -1, +0],
      [+0, +0, +1],
      [+0, +0, -1],
    ]
    uvCoords = [
      [1, 0],
      [0, 0],
      [0, 1],
      [1, 1],
    ]
  for f in 0 ..< cubeFaceIndices.len:
    let faceIndices = cubeFaceIndices[f]
    for v in 0 ..< 4:
      let
        position = cornerVertices[faceIndices[v]]
        normal = faceNormals[f]
        uv = uvCoords[v]
      result.positions.add([position[0].T, position[1].T, position[2].T])
      result.normals.add([normal[0].T, normal[1].T, normal[2].T])
      result.texcoords.add([uv[0].T, uv[1].T])
    let offset = 4 * f
    result.indexes.add([IndexT(offset + 0), IndexT(offset + 1), IndexT(offset + 2)])
    result.indexes.add([IndexT(offset + 0), IndexT(offset + 2), IndexT(offset + 3)])
