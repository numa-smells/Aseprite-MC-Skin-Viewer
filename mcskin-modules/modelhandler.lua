dofile("mcmodel.lua")

--define all the models you want to use here.

--classic 4-wide arms
local classic = MCModel.new()
    classic["head"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id   = "head",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(0, 0), 
            size = Vec3(8, 8, 8)
        }
        :Cube{
            id   = "hat",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(32, 0), 
            size = Vec3(8, 8, 8),
            inflate = 0.5,
            isBackfaceCulling = false
        }

    classic["body"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id = "body",
            pos  = Vec3(0,6,0),
            uv = Tex2(16, 16),
            size = Vec3(8,12,4)
        }
        :Cube{
            id   = "jacket",  
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(16, 32), 
            size = Vec3(8, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    classic["arm_r"] = Part{pos = Vec3(-5, -4, 0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-1, 4, 0),
            uv = Tex2(40, 16),
            size = Vec3(4, 12, 4)
        }
        :Cube{
            id   = "sleeve_r", 
            pos  = Vec3(-1, 4, 0),
            uv   = Tex2(40, 32), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    classic["arm_l"] = Part{pos = Vec3(5, -4, 0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(1, 4, 0),
            uv = Tex2(32, 48),
            size = Vec3(4, 12, 4)
        }
        :Cube{
            id   = "sleeve_l", 
            pos  = Vec3(1, 4, 0),
            uv   = Tex2(48, 48), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    classic["leg_r"] = Part{pos = Vec3(-2, 6, 0)}
        :Cube{
            id = "leg_r",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(0, 16),
            size = Vec3(4, 12, 4)
        }
        :Cube{
            id   = "pants_r", 
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(0, 32), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    classic["leg_l"] = Part{pos = Vec3(2, 6, 0)}
        :Cube{
            id = "leg_l",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(16, 48),
            size = Vec3(4, 12, 4)
        }
        :Cube{
            id   = "pants_l", 
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(0, 48), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

--slim 3px wide arms
local slim = MCModel.new()
    slim["head"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id   = "head",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(0, 0), 
            size = Vec3(8, 8, 8)
        }
        :Cube{
            id   = "hat",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(32, 0), 
            size = Vec3(8, 8, 8),
            inflate = 0.5,
            isBackfaceCulling = false
        }

    slim["body"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id = "body",
            pos  = Vec3(0,6,0),
            uv = Tex2(16, 16),
            size = Vec3(8,12,4)
        }
        :Cube{
            id   = "jacket",  
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(16, 32), 
            size = Vec3(8, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    slim["arm_r"] = Part{pos = Vec3(-5, -4, 0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-.5, 4, 0),
            uv = Tex2(40, 16),
            size = Vec3(3, 12, 4)
        }
        :Cube{
            id   = "sleeve_r", 
            pos  = Vec3(-.5, 4, 0),
            uv   = Tex2(40, 32), 
            size = Vec3(3, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    slim["arm_l"] = Part{pos = Vec3(5, -4, 0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(.5, 4, 0),
            uv = Tex2(32, 48),
            size = Vec3(3, 12, 4)
        }
        :Cube{
            id   = "sleeve_l", 
            pos  = Vec3(.5, 4, 0),
            uv   = Tex2(48, 48), 
            size = Vec3(3, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    slim["leg_r"] = Part{pos = Vec3(-2, 6, 0)}
        :Cube{
            id = "leg_r",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(0, 16),
            size = Vec3(4, 12, 4)
        }
        :Cube{
            id   = "pants_r", 
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(0, 32), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

    slim["leg_l"] = Part{pos = Vec3(2, 6, 0)}
        :Cube{
            id = "leg_l",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(16, 48),
            size = Vec3(4, 12, 4)
        }
        :Cube{
            id   = "pants_l", 
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(0, 48), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false
        }

--classic-pre1.8 4-wide arms
local old = MCModel.new()
    old["head"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id   = "head",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(0, 0), 
            size = Vec3(8, 8, 8)
        }
        :Cube{
            id   = "hat",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(32, 0), 
            size = Vec3(8, 8, 8),
            inflate = 0.5,
            isBackfaceCulling = false
        }

    old["body"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id = "body",
            pos  = Vec3(0,6,0),
            uv = Tex2(16, 16),
            size = Vec3(8,12,4)
        }

    old["arm_r"] = Part{pos = Vec3(-5, -4, 0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-1, 4, 0),
            uv = Tex2(40, 16),
            size = Vec3(4, 12, 4)
        }

    old["arm_l"] = Part{pos = Vec3(5, -4, 0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(1, 4, 0),
            uv = Tex2(40, 16),
            size = Vec3(4, 12, 4),
            isMirrored = true
        }

    old["leg_r"] = Part{pos = Vec3(-2, 6, 0)}
        :Cube{
            id = "leg_r",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(0, 16),
            size = Vec3(4, 12, 4)
        }
    old["leg_l"] = Part{pos = Vec3(2, 6, 0)}
        :Cube{
            id = "leg_l",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(0, 16),
            size = Vec3(4, 12, 4),
            isMirrored = true
        }

--then have a class that handles these guys.
MCModelHandler = {}
MCModelHandler.__index = MCModelHandler

function MCModelHandler.new()
    local inst <const> = {}
    setmetatable(inst, MCModelHandler)
    inst.model = {}
    inst.model["Classic"] = classic
    inst.model["Slim"] = slim
    inst.model["Pre-1.8"] = old

    inst.current = classic
    inst.current_key = "Classic"
    inst.scale = 1

    return inst
end

function MCModelHandler:auto_model(texture)
    local check_old = Image(texture,Rectangle(0,32*self.scale,64*self.scale,32*self.scale))
    if check_old == nil or check_old:isEmpty() then
        self:set_model("Pre-1.8")
    elseif Color(texture:getPixel(55*self.scale,31*self.scale)).alpha == 0 then
        self:set_model("Slim")
    else
        self:set_model("Classic")
    end
end

function MCModelHandler:set_model(string)
    if self.model[string] ~= nil then
        self.current = self.model[string]
        self.current_key = string
    else
        self.current = self.model["Classic"] --use classic as fallback
        self.current_key = "Classic"
    end
end

function MCModelHandler:get_model_list()
    local keyset = {"Auto"}
    local n = 1
    for k, v in pairs(self.model) do
        n = n + 1
        keyset[n] = k
    end
    return keyset
end

function MCModelHandler:setScale(uvScaleMultiplier)
    for k, v in pairs(self.model) do
        v:updateUV(uvScaleMultiplier)
    end
    self.scale = uvScaleMultiplier
end


return MCModelHandler