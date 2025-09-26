Mat4x4 = {}
Mat4x4.__index = Mat4x4

local sin, cos  = math.sin, math.cos

setmetatable(Mat4x4, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Mat4x4.new()
  local inst <const> = {}
  setmetatable(inst, Mat4x4)

  inst.m11 = 0.0
  inst.m12 = 0.0
  inst.m13 = 0.0
  inst.m14 = 0.0
  
  inst.m21 = 0.0
  inst.m22 = 0.0
  inst.m23 = 0.0
  inst.m24 = 0.0

  inst.m31 = 0.0
  inst.m32 = 0.0
  inst.m33 = 0.0
  inst.m34 = 0.0

  inst.m41 = 0.0
  inst.m42 = 0.0
  inst.m43 = 0.0
  inst.m44 = 0.0
  return inst
end

function Mat4x4.identity()
    local res = Mat4x4()

    res.m11 = 1.0
    res.m22 = 1.0
    res.m33 = 1.0
    res.m44 = 1.0

    return res
end


function Mat4x4.rot(a,b,y)
    local sina,sinb,siny,cosa,cosb,cosy = sin(a),sin(b),sin(y),cos(a),cos(b),cos(y)
    local res = Mat4x4()

    res.m11 = cosa*cosb
    res.m12 = cosa*sinb*siny-sina*cosy
    res.m13 = cosa*sinb*cosy+sina*siny

    res.m21 = sina*cosb
    res.m22 = sina*sinb*siny+cosa*cosy
    res.m23 = sina*sinb*cosy-cosa*siny

    res.m31 = -sinb
    res.m32 = cosb*siny
    res.m33 = cosb*cosy

    res.m44 = 1

    return res
end

function Mat4x4.trans(x,y,z)
  local res = Mat4x4.identity()
  res.m41 = x
  res.m42 = y
  res.m43 = z
  return res
end

function Mat4x4.proj(fFovDegrees, fAspectRatio, fNear, fFar)
  local fFovRad = 1 / math.tan(fFovDegrees * 0.5 / 180.0 * 3.14159)
  
  local res = Mat4x4()

  res.m11 = fAspectRatio * fFovRad
  res.m22 = fFovRad
  res.m33 = fFar / (fFar - fNear)
  res.m43 = (-fFar * fNear) / (fFar - fNear)
  res.m34 = 1
  res.m44 = 0

  return res
end

function Mat4x4.matMul(m1,m2)
  local res = Mat4x4()

  res.m11 = m1.m11 * m2.m11 + m1.m12 * m2.m21 + m1.m13 * m2.m31 + m1.m14 * m2.m41
  res.m21 = m1.m21 * m2.m11 + m1.m22 * m2.m21 + m1.m23 * m2.m31 + m1.m24 * m2.m41
  res.m31 = m1.m31 * m2.m11 + m1.m32 * m2.m21 + m1.m33 * m2.m31 + m1.m34 * m2.m41
  res.m41 = m1.m41 * m2.m11 + m1.m42 * m2.m21 + m1.m43 * m2.m31 + m1.m44 * m2.m41

  res.m12 = m1.m11 * m2.m12 + m1.m12 * m2.m22 + m1.m13 * m2.m32 + m1.m14 * m2.m42
  res.m22 = m1.m21 * m2.m12 + m1.m22 * m2.m22 + m1.m23 * m2.m32 + m1.m24 * m2.m42
  res.m32 = m1.m31 * m2.m12 + m1.m32 * m2.m22 + m1.m33 * m2.m32 + m1.m34 * m2.m42
  res.m42 = m1.m41 * m2.m12 + m1.m42 * m2.m22 + m1.m43 * m2.m32 + m1.m44 * m2.m42

  res.m13 = m1.m11 * m2.m13 + m1.m12 * m2.m23 + m1.m13 * m2.m33 + m1.m14 * m2.m43
  res.m23 = m1.m21 * m2.m13 + m1.m22 * m2.m23 + m1.m23 * m2.m33 + m1.m24 * m2.m43
  res.m33 = m1.m31 * m2.m13 + m1.m32 * m2.m23 + m1.m33 * m2.m33 + m1.m34 * m2.m43
  res.m43 = m1.m41 * m2.m13 + m1.m42 * m2.m23 + m1.m43 * m2.m33 + m1.m44 * m2.m43

  res.m14 = m1.m11 * m2.m14 + m1.m12 * m2.m24 + m1.m13 * m2.m34 + m1.m14 * m2.m44
  res.m24 = m1.m21 * m2.m14 + m1.m22 * m2.m24 + m1.m23 * m2.m34 + m1.m24 * m2.m44
  res.m34 = m1.m31 * m2.m14 + m1.m32 * m2.m24 + m1.m33 * m2.m34 + m1.m34 * m2.m44
  res.m44 = m1.m41 * m2.m14 + m1.m42 * m2.m24 + m1.m43 * m2.m34 + m1.m44 * m2.m44
  
  return res
end

function Mat4x4:__tostring()
    return Mat4x4.toJson(self)
end

function Mat4x4.toJson(m)
    return string.format(
        "{\"m11\":%.4f,\"m12\":%.4f,\"m13\":%.4f,\"m14\":%.4f,\n\"m21\":%.4f,\"m22\":%.4f,\"m23\":%.4f,\"m24\":%.4f,\n\"m31\":%.4f,\"m32\":%.4f,\"m33\":%.4f,\"m34\":%.4f,\n\"m41\":%.4f,\"m42\":%.4f,\"m43\":%.4f,\"m44\":%.4f}",
        m.m11,m.m12,m.m13,m.m14,
        m.m21,m.m22,m.m23,m.m24,
        m.m31,m.m32,m.m33,m.m34,
        m.m41,m.m42,m.m43,m.m44)
end


return Mat4x4