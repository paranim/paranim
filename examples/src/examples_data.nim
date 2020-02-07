const f2d* = [
  # left column
  0f, 0f,
  30f, 0f,
  0f, 150f,
  0f, 150f,
  30f, 0f,
  30f, 150f,
  # top rung
  30f, 0f,
  100f, 0f,
  30f, 30f,
  30f, 30f,
  100f, 0f,
  100f, 30f,
  # middle rung
  30f, 60f,
  67f, 60f,
  30f, 90f,
  30f, 90f,
  67f, 60f,
  67f, 90f,
]

const f3d* = [
   # left column front
   0f,   0f,  0f,
   0f, 150f,  0f,
   30f,   0f,  0f,
   0f, 150f,  0f,
   30f, 150f,  0f,
   30f,   0f,  0f,

   # top rung front
   30f,   0f,  0f,
   30f,  30f,  0f,
   100f,   0f,  0f,
   30f,  30f,  0f,
   100f,  30f,  0f,
   100f,   0f,  0f,

   # middle rung front
   30f,  60f,  0f,
   30f,  90f,  0f,
   67f,  60f,  0f,
   30f,  90f,  0f,
   67f,  90f,  0f,
   67f,  60f,  0f,

   # left column back
     0f,   0f,  30f,
    30f,   0f,  30f,
     0f, 150f,  30f,
     0f, 150f,  30f,
    30f,   0f,  30f,
    30f, 150f,  30f,

   # top rung back
    30f,   0f,  30f,
   100f,   0f,  30f,
    30f,  30f,  30f,
    30f,  30f,  30f,
   100f,   0f,  30f,
   100f,  30f,  30f,

   # middle rung back
    30f,  60f,  30f,
    67f,  60f,  30f,
    30f,  90f,  30f,
    30f,  90f,  30f,
    67f,  60f,  30f,
    67f,  90f,  30f,

   # top
     0f,   0f,   0f,
   100f,   0f,   0f,
   100f,   0f,  30f,
     0f,   0f,   0f,
   100f,   0f,  30f,
     0f,   0f,  30f,

   # top rung right
   100f,   0f,   0f,
   100f,  30f,   0f,
   100f,  30f,  30f,
   100f,   0f,   0f,
   100f,  30f,  30f,
   100f,   0f,  30f,

   # under top rung
   30f,   30f,   0f,
   30f,   30f,  30f,
   100f,  30f,  30f,
   30f,   30f,   0f,
   100f,  30f,  30f,
   100f,  30f,   0f,

   # between top rung and middle
   30f,   30f,   0f,
   30f,   60f,  30f,
   30f,   30f,  30f,
   30f,   30f,   0f,
   30f,   60f,   0f,
   30f,   60f,  30f,

   # top of middle rung
   30f,   60f,   0f,
   67f,   60f,  30f,
   30f,   60f,  30f,
   30f,   60f,   0f,
   67f,   60f,   0f,
   67f,   60f,  30f,

   # right of middle rung
   67f,   60f,   0f,
   67f,   90f,  30f,
   67f,   60f,  30f,
   67f,   60f,   0f,
   67f,   90f,   0f,
   67f,   90f,  30f,

   # bottom of middle rung.
   30f,   90f,   0f,
   30f,   90f,  30f,
   67f,   90f,  30f,
   30f,   90f,   0f,
   67f,   90f,  30f,
   67f,   90f,   0f,

   # right of bottom
   30f,   90f,   0f,
   30f,  150f,  30f,
   30f,   90f,  30f,
   30f,   90f,   0f,
   30f,  150f,   0f,
   30f,  150f,  30f,

   # bottom
   0f,   150f,   0f,
   0f,   150f,  30f,
   30f,  150f,  30f,
   0f,   150f,   0f,
   30f,  150f,  30f,
   30f,  150f,   0f,

   # left side
   0f,   0f,   0f,
   0f,   0f,  30f,
   0f, 150f,  30f,
   0f,   0f,   0f,
   0f, 150f,  30f,
   0f, 150f,   0f,
]

const f3dColors* = [
   # left column front
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   
     # top rung front
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   
     # middle rung front
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   200f,  70f, 120f,
   
     # left column back
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   
     # top rung back
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   
     # middle rung back
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   80f, 70f, 200f,
   
     # top
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   70f, 200f, 210f,
   
     # top rung right
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   200f, 200f, 70f,
   
     # under top rung
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   210f, 100f, 70f,
   
     # between top rung and middle
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   210f, 160f, 70f,
   
     # top of middle rung
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   70f, 180f, 210f,
   
     # right of middle rung
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   100f, 70f, 210f,
   
     # bottom of middle rung.
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   76f, 210f, 100f,
   
     # right of bottom
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   140f, 210f, 80f,
   
     # bottom
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   90f, 130f, 110f,
   
     # left side
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
   160f, 160f, 220f,
]

const fTexcoords* = [
   # left column front
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   # top rung front
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   # middle rung front
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   # left column back
   0f, 0f,
   1f, 0f,
   0f, 1f,
   0f, 1f,
   1f, 0f,
   1f, 1f,

   # top rung back
   0f, 0f,
   1f, 0f,
   0f, 1f,
   0f, 1f,
   1f, 0f,
   1f, 1f,

   # middle rung back
   0f, 0f,
   1f, 0f,
   0f, 1f,
   0f, 1f,
   1f, 0f,
   1f, 1f,

   # top
   0f, 0f,
   1f, 0f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   0f, 1f,

   # top rung right
   0f, 0f,
   1f, 0f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   0f, 1f,

   # under top rung
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,

   # between top rung and middle
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # top of middle rung
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # right of middle rung
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # bottom of middle rung.
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,

   # right of bottom
   0f, 0f,
   1f, 1f,
   0f, 1f,
   0f, 0f,
   1f, 0f,
   1f, 1f,

   # bottom
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,

   # left side
   0f, 0f,
   0f, 1f,
   1f, 1f,
   0f, 0f,
   1f, 1f,
   1f, 0f,
]

const cube* = [
   -0.5f, -0.5f,  -0.5f,
   -0.5f,  0.5f,  -0.5f,
    0.5f, -0.5f,  -0.5f,
   -0.5f,  0.5f,  -0.5f,
    0.5f,  0.5f,  -0.5f,
    0.5f, -0.5f,  -0.5f,
 
   -0.5f, -0.5f,   0.5f,
    0.5f, -0.5f,   0.5f,
   -0.5f,  0.5f,   0.5f,
   -0.5f,  0.5f,   0.5f,
    0.5f, -0.5f,   0.5f,
    0.5f,  0.5f,   0.5f,
 
   -0.5f,   0.5f, -0.5f,
   -0.5f,   0.5f,  0.5f,
    0.5f,   0.5f, -0.5f,
   -0.5f,   0.5f,  0.5f,
    0.5f,   0.5f,  0.5f,
    0.5f,   0.5f, -0.5f,
 
   -0.5f,  -0.5f, -0.5f,
    0.5f,  -0.5f, -0.5f,
   -0.5f,  -0.5f,  0.5f,
   -0.5f,  -0.5f,  0.5f,
    0.5f,  -0.5f, -0.5f,
    0.5f,  -0.5f,  0.5f,
 
   -0.5f,  -0.5f, -0.5f,
   -0.5f,  -0.5f,  0.5f,
   -0.5f,   0.5f, -0.5f,
   -0.5f,  -0.5f,  0.5f,
   -0.5f,   0.5f,  0.5f,
   -0.5f,   0.5f, -0.5f,
 
    0.5f,  -0.5f, -0.5f,
    0.5f,   0.5f, -0.5f,
    0.5f,  -0.5f,  0.5f,
    0.5f,  -0.5f,  0.5f,
    0.5f,   0.5f, -0.5f,
    0.5f,   0.5f,  0.5f,
]

const cubeTexcoords* = [
   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   0f, 0f,
   0f, 1f,
   1f, 0f,
   1f, 0f,
   0f, 1f,
   1f, 1f,

   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   0f, 0f,
   0f, 1f,
   1f, 0f,
   1f, 0f,
   0f, 1f,
   1f, 1f,

   0f, 0f,
   0f, 1f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
   1f, 0f,

   0f, 0f,
   0f, 1f,
   1f, 0f,
   1f, 0f,
   0f, 1f,
   1f, 1f,
]
