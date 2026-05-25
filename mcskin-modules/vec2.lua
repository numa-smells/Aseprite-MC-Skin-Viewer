Vec2 = {}
Vec2.__index = Vec2

setmetatable(Vec2, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Vec2.new(x,y,w)
  local inst <const> = {}
  setmetatable(inst, Vec2)

  inst.x = x or 0.0
  inst.y = y or 0.0
  inst.w = w or 1.0

  return inst
end

function Vec2.normalVector(a,b)
  return Vec2(a.y-b.y,b.x-a.x)
end

function Vec2.lerp(a,b,t)
  return Vec2(a.x+t*(b.x-a.x),a.y + t * (b.y - a.y))
end

function Vec2:__add(b)
    return Vec2.add(self, b)
end

function Vec2:__sub(b)
    return Vec2.sub(self, b)
end

function Vec2.add(v1,v2)
  return Vec2(v1.x+v2.x, v1.y+v2.y)
end

function Vec2.sub(v1,v2)
  assert(v1, v1)

  return Vec2(v1.x-v2.x,v1.y-v2.y)
end

function Vec2.mult(v,k)
  return Vec2(v.x*k, v.y*k)
end

function Vec2.div(v,k)
  return Vec2(v.x/k, v.y/k)
end

function Vec2.dot(v1,v2)
  return v1.x*v2.x + v1.y*v2.y
end

function Vec2.hadamard(v1,v2)
  return Vec2(v1.x*v2.x, v1.y*v2.y) 
end

function Vec2.min(v1,v2)
  return Vec2(v1.x < v2.x and v1.x or v2.x, v1.y < v2.y and v1.y or v2.y)
end
function Vec2.max(v1,v2)
  return Vec2(v1.x < v2.x and v2.x or v1.x, v1.y < v2.y and v2.y or v1.y)
end

function Vec2.inBox(v1,bmin,bmax)
  return v1.x >= bmin.x and v1.x <= bmax.x and
         v1.y >= bmin.y and v1.y <= bmax.y 
end
local sqrt = math.sqrt
function Vec2.len(v)
  return sqrt(Vec2.dot(v,v))
end

function Vec2.norm(v)
  return Vec2.div(v,v:len())
end

local function abs(x)
  return x > 0 and x or -x
end

local epsilon = 1e-12

function Vec2.isEqual(v1,v2)
  return abs(v1.x - v2.x) < epsilon and abs(v1.y - v2.y) < epsilon
end

function Vec2:flip()
  return Vec2(self.y,-self.x)
end

function Vec2:copy()
  return Vec2(self.x,self.y,self.w)
end
function Vec2:applyW(width, height)
  local w = self.w
  return Vec2((self.x / self.w + 1) * width / 2, (self.y / self.w + 1) * height / 2)
end

function Vec2.applyMat3x3(i,m)
    local res = Vec2()
    res.x = i.x * m.m11 + i.y * m.m21 + i.w * m.m31
    res.y = i.x * m.m12 + i.y * m.m22 + i.w * m.m32
    res.w = i.x * m.m13 + i.y * m.m23 + i.w * m.m33

    return res
end


function Vec2:__tostring()
    return Vec2.toJson(self)
end

function Vec2.toJson(t)
    return string.format(
        "{\"x\":%.4f,\"y\":%.4f,\"w\":%.4f}",
        t.x, t.y, t.w)
end

return Vec2