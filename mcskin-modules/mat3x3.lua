if not Vec2 then
  local Vec2 = dofile('vec2.lua')
end

Mat3x3 = {}
Mat3x3.__index = Mat3x3

local sin, cos  = math.sin, math.cos

setmetatable(Mat3x3, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Mat3x3.new()
  local inst <const> = {}
  setmetatable(inst, Mat3x3)

  inst.m11 = 0.0
  inst.m12 = 0.0
  inst.m13 = 0.0
  
  inst.m21 = 0.0
  inst.m22 = 0.0
  inst.m23 = 0.0

  inst.m31 = 0.0
  inst.m32 = 0.0
  inst.m33 = 0.0
  return inst
end

function Mat3x3.identity()
    local res = Mat3x3()

    res.m11 = 1.0
    res.m22 = 1.0
    res.m33 = 1.0

    return res
end


function Mat3x3.UVtoBary(src_a,src_b,src_c,dst_a,dst_b,dst_c)
  local m = Mat3x3()
  local bary_c = (src_c.x-src_a.x)*(src_b.y-src_a.y) - (src_b.x-src_a.x)*(src_c.y-src_a.y)
  local bary_0 = (src_a-src_c):flip():div(bary_c)
  local bary_1 = (src_b-src_a):flip():div(bary_c)
  
  m.m11 = bary_0.x
  m.m21 = bary_0.y
  m.m31 = -Vec2.dot(bary_0,src_a)

  m.m12 = bary_1.x
  m.m22 = bary_1.y
  m.m32 = -Vec2.dot(bary_1,src_a)

  m.m33 = 1.0

  return m
end

function Mat3x3.BarytoWorld(src_a,src_b,src_c,dst_a,dst_b,dst_c)
  local m = Mat3x3()

  m.m11 = (dst_b.x-dst_a.x)
  m.m21 = (dst_c.x-dst_a.x)
  m.m31 = dst_a.x

  m.m12 = (dst_b.y-dst_a.y)
  m.m22 = (dst_c.y-dst_a.y)
  m.m32 = dst_a.y

  m.m13 = (dst_b.w-dst_a.w)
  m.m23 = (dst_c.w-dst_a.w)
  m.m33 = dst_a.w

  return m
end

function Mat3x3.UVtoWorld(src_a,src_b,src_c,dst_a,dst_b,dst_c)
  local toBary = Mat3x3.UVtoBary(src_a,src_b,src_c,dst_a,dst_b,dst_c)
  local toWorld = Mat3x3.BarytoWorld(src_a,src_b,src_c,dst_a,dst_b,dst_c)

  return Mat3x3.matMul(toBary,toWorld)
end


function Mat3x3.matMul(m1,m2)
  local res = Mat3x3()

  res.m11 = m1.m11 * m2.m11 + m1.m12 * m2.m21 + m1.m13 * m2.m31
  res.m21 = m1.m21 * m2.m11 + m1.m22 * m2.m21 + m1.m23 * m2.m31
  res.m31 = m1.m31 * m2.m11 + m1.m32 * m2.m21 + m1.m33 * m2.m31

  res.m12 = m1.m11 * m2.m12 + m1.m12 * m2.m22 + m1.m13 * m2.m32
  res.m22 = m1.m21 * m2.m12 + m1.m22 * m2.m22 + m1.m23 * m2.m32
  res.m32 = m1.m31 * m2.m12 + m1.m32 * m2.m22 + m1.m33 * m2.m32

  res.m13 = m1.m11 * m2.m13 + m1.m12 * m2.m23 + m1.m13 * m2.m33
  res.m23 = m1.m21 * m2.m13 + m1.m22 * m2.m23 + m1.m23 * m2.m33
  res.m33 = m1.m31 * m2.m13 + m1.m32 * m2.m23 + m1.m33 * m2.m33
  
  return res
end

function Mat3x3:__tostring()
    return Mat3x3.toJson(self)
end

function Mat3x3.toJson(m)
    return string.format(
        "{\"m11\":%.4f,\"m12\":%.4f,\"m13\":%.4f,\n\"m21\":%.4f,\"m22\":%.4f,\"m23\":%.4f,\n\"m31\":%.4f,\"m32\":%.4f,\"m33\":%.4f}",
        m.m11,m.m12,m.m13,
        m.m21,m.m22,m.m23,
        m.m31,m.m32,m.m33
        )
end


return Mat3x3