Tex2 = {}
Tex2.__index = Tex2

setmetatable(Tex2, {
  __call = function(cls,...)
    return cls.new(...)
  end
})

function Tex2.new(u,v)
  local inst <const> = {}
  setmetatable(inst, Tex2)

  inst.u = u or 0.0
  inst.v = v or 0.0
  inst.w = 1.0

  return inst
end

function Tex2:__tostring()
    return Tex2.toJson(self)
end

function Tex2.toJson(t)
    return string.format(
        "{\"u\":%.4f,\"v\":%.4f,\"w\":%.4f}",
        t.u, t.v, t.w)
end

return Tex2