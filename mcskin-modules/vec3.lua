Vec3 = {}
Vec3.__index = Vec3

setmetatable(Vec3, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Vec3.new(x,y,z)
  local inst <const> = {}
  setmetatable(inst, Vec3)

  inst.x = x or 0.0
  inst.y = y or 0.0
  inst.z = z or 0.0
  inst.w = 1.0

  return inst
end

function Vec3:__add(b)
    return Vec3.add(self, b)
end

function Vec3:__sub(b)
    return Vec3.sub(self, b)
end



function Vec3.add(v1,v2)
  return Vec3(v1.x+v2.x, v1.y+v2.y, v1.z+v2.z)
end

function Vec3.sub(v1,v2)
  return Vec3(v1.x-v2.x,v1.y-v2.y,v1.z-v2.z)
end

function Vec3.mult(v,k)
  return Vec3(v.x*k, v.y*k, v.z*k)
end

function Vec3.div(v,k)
  return Vec3(v.x/k, v.y/k, v.z/k)
end

function Vec3.dot(v1,v2)
  return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z 
end

function Vec3.hadamard(v1,v2)
  return Vec3(v1.x*v2.x, v1.y*v2.y, v1.z*v2.z) 
end

function Vec3.len(v)
  return math.sqrt(Vec3.dot(v,v))
end

function Vec3.norm(v)
  local l = Vec3.len(v)
  return Vec3.div(v,l)
end

function Vec3.cross(v1,v2)
  return Vec3(v1.y * v2.z - v1.z * v2.y, 
              v1.z * v2.x - v1.x * v2.z, 
              v1.x * v2.y - v1.y * v2.x
        )
end 

function Vec3.applyMat4x4(i,m)
    local res = Vec3()
    res.x = i.x * m.m11 + i.y * m.m21 + i.z * m.m31 + i.w * m.m41
    res.y = i.x * m.m12 + i.y * m.m22 + i.z * m.m32 + i.w * m.m42
    res.z = i.x * m.m13 + i.y * m.m23 + i.z * m.m33 + i.w * m.m43
    res.w = i.x * m.m14 + i.y * m.m24 + i.z * m.m34 + i.w * m.m44

    return res
end

function Vec3:__tostring()
    return Vec3.toJson(self)
end

function Vec3:copy()
  return Vec3(self.x,self.y,self.z)
end

function Vec3.toJson(v)
    return string.format(
        "{\"x\":%.4f,\"y\":%.4f,\"z\":%.4f,\"w\":%.4f}",
        v.x, v.y, v.z, v.w)
end

return Vec3