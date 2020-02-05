import paranim/gl

type
  Game* = object of RootGame
    frameWidth*: int
    frameHeight*: int
    windowWidth*: int
    windowHeight*: int
    mouseX*: float
    mouseY*: float

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
