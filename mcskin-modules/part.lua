dofile("./vec3.lua")
dofile("./tex2.lua")
dofile("./cube.lua")

Part = {}
Part.__index = Part

setmetatable(Part, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Part.new(params)
  local inst <const> = {}
  setmetatable(inst, Part)

  inst.mesh = {}
  inst.pos = params.pos or Vec3()
  inst.pos = inst.pos:div(8)
  inst.isVisible = true
  if params.isVisible ~= nil then
    inst.isVisible = params.isVisible
  end
  
  inst.rot = params.rot or Vec3()

  inst.pos_default = inst.pos:copy()
  inst.rot_default = inst.rot:copy()
  return inst
end

function Part:reset()
  self.pos = self.pos_default:copy()
  self.rot = self.rot_default:copy()
end

function Part:Cube(params)
    local id = params.id
    self.mesh[id] = Cube(params)
    return self
end

function Part:__tostring()
    return "test" --Part.toJson(self)
end

function Part.toJson(p)
    local r = "{\"pos\": " .. p.pos:toJson() .. ",\n"

    r = r .. "{\"rot\": " .. p.rot:toJson() .. ",\n"
    r = r .. "{\"mesh\": {" 

    for k,v in pairs(p.mesh) do
      r = r .. "\"" .. k .. "\","
    end
    
    r = r .. "},}"
    return r
end

return Part