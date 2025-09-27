dofile("vec3.lua")
dofile("tex2.lua")


Cube = {}
Cube.__index = Cube

setmetatable(Cube, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Cube.new(params)
  local inst <const> = {}
  setmetatable(inst, Cube)

  inst.isVisible = true
  if params.isVisible ~= nil then
    inst.isVisible = params.isVisible
  end

  inst.isBackfaceCulling = true

  if params.isBackfaceCulling ~= nil then
    inst.isBackfaceCulling = params.isBackfaceCulling
  end
  
  --default cube faces
  inst.points = {
    Vec3(-1, 1,-1),
    Vec3( 1, 1,-1),
    Vec3(-1,-1,-1),
    Vec3( 1,-1,-1),
    Vec3(-1, 1, 1),
    Vec3( 1, 1, 1),
    Vec3(-1,-1, 1),
    Vec3( 1,-1, 1),
  }

  inst.faces = {
    {1,2,3,4},  --FRONT
    {2,6,4,8},  --LEFT
    {6,5,8,7},  --BACK
    {5,1,7,3},  --RIGHT
    {5,6,1,2},  --BOTTOM
    {8,7,4,3}   --TOP
  }

  local size = params.size or Vec3(1,1,1)
  local pos = params.pos or Vec3()

  local uv = params.uv or Tex2()
  local inflate = params.inflate or 0

  local u = uv.u
  local v = uv.v
  local wt = size.x
  local ht = size.y
  local dt = size.z

  inst.uv = {
    {Tex2(u+dt,v+ht+dt), Tex2(u+wt+dt,v+ht+dt), Tex2(u+dt,v+dt),Tex2(u+wt+dt,v+dt)}, --FRONT
    {Tex2(u+dt+wt,v+ht+dt), Tex2(u+dt+dt+wt,v+ht+dt), Tex2(u+dt+wt,v+dt), Tex2(u+dt+dt+wt,v+dt)}, --LEFT
    {Tex2(u+dt+dt+wt,v+ht+dt), Tex2(u+wt+dt+dt+wt,v+ht+dt), Tex2(u+dt+dt+wt,v+dt), Tex2(u+wt+dt+dt+wt,v+dt)}, --BACK
    {Tex2(u,v+ht+dt), Tex2(u+dt,v+ht+dt), Tex2(u,v+dt), Tex2(u+dt,v+dt)}, --RIGHT
    {Tex2(u+dt+wt,v), Tex2(u+dt+wt+wt,v), Tex2(u+dt+wt,v+dt), Tex2(u+wt+dt+wt,v+dt)}, --BOTTOM
    {Tex2(u+wt+dt,v), Tex2(u+dt,v), Tex2(u+wt+dt,v+dt), Tex2(u+dt,v+dt)} --TOP
  }

  pos = pos:div(8)

  inflate = inflate * 2
  
  size = (size+Vec3(inflate,inflate,inflate)):div(16)
  
  -- multiply by size
  for i=1, 8 do
    inst.points[i] = Vec3.hadamard(inst.points[i], size) + pos
  end

  -- then offset by position 

  -- local pos = params.pos or Vec3()
  -- local size = params.size or Vec3()
  -- local uv = params.uv or Tex2()
  -- local inflate = params.inflate or 0
  -- local showBackface = params.showBackface or false
  -- local isVisible = params.isVisible or true

  return inst
end


return Cube