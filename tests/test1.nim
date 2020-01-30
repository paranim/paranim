import unittest

import paranim/gl/entities2d
import glm

test "identity matrix":
  let projMat = projectionMatrix(800f, 600f)
  check identityMatrix() * projMat == projMat
