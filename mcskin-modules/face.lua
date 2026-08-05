if not Vec2 then
  local Vec2 = dofile("vec2.lua")
end
if not Vec3 then
  local Vec3 = dofile("vec3.lua")
end
if not Mat3x3 then
    local Mat3x3 = dofile("mat3x3.lua")
end

Face = {}
Face.__index = Face

setmetatable(Face, {
  __call = function(cls, ...)
    return cls.new(...)
  end
})

function Face.new(p, t)
  local inst <const> = {}
  setmetatable(inst, Face)

  inst.t = t or {}
  inst.p = p or {}
  inst.normal = Vec3()
  inst.max = Vec3()
  inst.min = Vec3()

  return inst
end

function Face.updateBounds(self)
  local p_max = self.p[1]:copy()
  local p_min = self.p[1]:copy()

  local n = #self.p

  for i = 2, n do
    p_max = Vec3.max(p_max, self.p[i])
    p_min = Vec3.min(p_min, self.p[i])
  end

  self.min = p_min
  self.max = p_max
end
local abs = function(x) return x > 0 and x or -x end

function Face.planeTest(self, face)
  local inside, outside, on = 0, 0, 0
  local n = #face.p

  local p_no = self.normal
  local p_co = self.p[1]

  for k = 1, n do
    local collide = Vec3.dot((face.p[k] - p_co), p_no)
    if abs(collide) < 1e-15 then
      on = on + 1
    elseif collide >= 0 then
      outside = outside + 1
    else
      inside = inside + 1
    end
  end

  if on == n then
    return 2
  end

  if outside + on == n then
    return 1
  end

  if inside + on == n then
    return -1
  end

  return 0
end

local function lerp(a, b, t)
  return a + t * (b - a)
end

local function inv_lerp(x, a, b)
  if (b - a) ~= 0 then
    return (x - a) / (b - a)
  end

  return 0
end

--https://stackoverflow.com/questions/5666222/3d-line-plane-intersection
local function insect_line_plane(p0, p1, p_co, p_no, t0, t1)
  local u = Vec3.sub(p1, p0)

  
  u = p0 + Vec3.mult(u, -Vec3.dot(p_no, Vec3.sub(p0, p_co)) / Vec3.dot(p_no, u))

  local u_dot = Vec3.dot(p_no, u)
  local t = inv_lerp(u_dot, Vec3.dot(p_no, p0), Vec3.dot(p_no, p1))

  u.w = lerp(p0.w, p1.w, t)

  return u, Vec2.lerp(t0, t1, t)
end

function Face.splitAlong(self, face)
  local face_behind = Face.new()
  local face_front = Face.new()

  local p_co = face.p[1]
  local p_no = face.normal

  local n = #self.p

  local f_count, b_count = 1, 1

  local p0 = self.p[1]
  local t0 = self.t[1]

  for i = 1, n do
    local p1 = self.p[i % n + 1]
    local t1 = self.t[i % n + 1]

    local p_intersect, t_intersect = insect_line_plane(p0, p1, p_co, p_no, t0, t1)

    if Vec3.dot(p_no, p1 - p_co) <= 0 then
      if Vec3.dot(p_no, p0 - p_co) > 0 then
        face_front.p[f_count] = p_intersect
        face_front.t[f_count] = t_intersect
        f_count = f_count + 1
      end

      face_front.p[f_count] = p1
      face_front.t[f_count] = t1
      f_count = f_count + 1
    elseif Vec3.dot(p_no, p0 - p_co) <= 0 then
      face_front.p[f_count] = p_intersect
      face_front.t[f_count] = t_intersect
      f_count = f_count + 1
    end

    if Vec3.dot(p_no, p1 - p_co) >= 0 then
      if Vec3.dot(p_no, p0 - p_co) < 0 then
        face_behind.p[b_count] = p_intersect
        face_behind.t[b_count] = t_intersect
        b_count = b_count + 1
      end

      face_behind.p[b_count] = p1
      face_behind.t[b_count] = t1
      b_count = b_count + 1
    elseif Vec3.dot(p_no, p0 - p_co) >= 0 then
      face_behind.p[b_count] = p_intersect
      face_behind.t[b_count] = t_intersect
      b_count = b_count + 1
    end

    p0 = p1
    t0 = t1
  end

  face_front:updateBounds()
  face_behind:updateBounds()
  return face_behind, face_front
end

function Face.splitAlong_one(self, p_co, p_no)
  local face_front = Face.new()

  local n = #self.p

  local f_count = 1

  local p0 = self.p[1]
  local t0 = self.t[1]

  for i = 1, n do
    local p1 = self.p[i % n + 1]
    local t1 = self.t[i % n + 1]

    local p_intersect, t_intersect = insect_line_plane(p0, p1, p_co, p_no, t0, t1)

    if Vec3.dot(p_no, p1 - p_co) <= 0 then
      if Vec3.dot(p_no, p0 - p_co) > 0 then
        face_front.p[f_count] = p_intersect
        face_front.t[f_count] = t_intersect
        f_count = f_count + 1
      end

      face_front.p[f_count] = p1
      face_front.t[f_count] = t1
      f_count = f_count + 1
    elseif Vec3.dot(p_no, p0 - p_co) <= 0 then
      face_front.p[f_count] = p_intersect
      face_front.t[f_count] = t_intersect
      f_count = f_count + 1
    end

    p0 = p1
    t0 = t1
  end

  if #face_front.p <= 2 then
    return nil
  end

  face_front:updateBounds()
  face_front.normal = self.normal

  return face_front
end

function Face:flipSide()
  local temp_points, temp_uvs = {}, {}
  local n = #self.p

  for i = 1, n do
    temp_points[i] = self.p[i]
    temp_uvs[i] = self.t[i]
  end

  for i = 1, n do
    self.p[i] = temp_points[n - i + 1]
    self.t[i] = temp_uvs[n - i + 1]
  end
end

function Face.isInside(p, s)
  if  p.ps_min.x >= s.ps_min.x and
      p.ps_max.x <= s.ps_max.x and
      p.ps_min.y >= s.ps_min.y and
      p.ps_max.y <= s.ps_max.y then
      
      --check if all points of p are inside the lines of s
      local sn, pn = #s.ps, #p.ps

      for i=1, sn do
        for j=1, pn do
          if Vec2.dot(p.ps[j] - s.ps[i], s.ps_normals[i]) > 0 then
            return false
          end
        end
      end

      return true

  end
  return false
end



function Face.computePixels(self, pixelMeshes, light, gcw, gch,  matProj)

  local n = #self.p
  if n < 3 then return end

  local src_a, src_b, src_c = self.t[1], self.t[2], self.t[3]

  local dst_a = Vec3.applyMat4x4(self.p[1], matProj)
  local dst_b = Vec3.applyMat4x4(self.p[2], matProj)
  local dst_c = Vec3.applyMat4x4(self.p[3], matProj)
  local toProj = Mat3x3.UVtoWorld(src_a, src_b, src_c, dst_a, dst_b, dst_c)

  

  local meshCount = pixelMeshes.n
  local pixels = {}

  self.isOpaque = pixelMeshes.isOpaque
  
  for i=1, meshCount do
    local c = Color(pixelMeshes.c[i])
    c.value = c.value * light
    local x, y = pixelMeshes.x[i],pixelMeshes.y[i]
    local w, h = pixelMeshes.w[i],pixelMeshes.h[i]

    local p1 = Vec2(x, y):applyMat3x3(toProj):applyW(gcw, gch)
    local p2 = Vec2(x+w, y):applyMat3x3(toProj):applyW(gcw, gch)
    local p3 = Vec2(x+w, y+h):applyMat3x3(toProj):applyW(gcw, gch)
    local p4 = Vec2(x, y+h):applyMat3x3(toProj):applyW(gcw, gch)


    table.insert(pixels,{c, p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y,x,y,w,h})

  end

  self.pixels = pixels

end



function Face.drawPixels(self,gc, AA, wireframeMode,matProj,w,h)
  
  local p = self.p
  local p_n = #p

  for i=1, p_n do
    p[i] = p[i]:applyMat4x4(matProj):applyW(w,h)
  end

  local t = self.t

  local min_u, min_v = t[1].x, t[1].y
  local max_u, max_v = t[1].x, t[1].y

  for i = 2, p_n do
    local t_n = t[i]
    if t_n.x < min_u then min_u = t_n.x end
    if t_n.y < min_v then min_v = t_n.y end
    if t_n.x > max_u then max_u = t_n.x end
    if t_n.y > max_v then max_v = t_n.y end
  end
  min_u = min_u // 1 --floor min
  min_v = min_v // 1 

  max_u = -((-max_u) // 1)--ceil max
  max_v = -((-max_v) // 1)

  local pixels = self.pixels
  local n = #pixels

  gc:save()
  --clip polygon
  gc:beginPath()
  local p1 = p[1]
  gc:moveTo(p1.x,p1.y)
  for i = 2, p_n do
    local px = p[i]
    gc:lineTo(px.x,px.y)
  end
  gc:closePath()
  gc:clip()

  
  for i=1, n do
    local px = pixels[i]

    local uv_x, uv_y, uv_w, uv_h = px[10],px[11],px[12],px[13]
    local in_poly = min_u <= uv_x+uv_w and max_u >= uv_x and min_v <= uv_y+uv_h and max_v >= uv_y

    if in_poly then      
      gc.color = px[1]
      gc:beginPath()
      gc:moveTo(px[2],px[3])
      gc:lineTo(px[4],px[5])
      gc:lineTo(px[6],px[7])
      gc:lineTo(px[8],px[9])
      gc:closePath()

      if not wireframeMode then
        gc:fill()
      end

      if wireframeMode or AA then
        gc:stroke()
      end
    end

  end
  gc:restore()

end

return Face
