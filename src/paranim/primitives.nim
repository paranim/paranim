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
