import unittest

import parabola/math
import glm

test "identity matrix":
  let projMat = projectionMatrix(800f, 600f)
  check identityMatrix() * projMat == projMat
