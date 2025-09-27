dofile("./lib3D.lua")
dofile("./vec3.lua")
dofile("./tex2.lua")
dofile("./mat4x4.lua")
dofile("./part.lua")
dofile("./sort.lua")

MCModel = {}
MCModel.__index = MCModel

function MCModel.new()
    local inst <const> = {}
    setmetatable(inst, MCModel)

    --define model here
    inst["head"] = Part{pos = Vec3(0,-6,0)}
        :Cube{
            id   = "head",  
            pos  = Vec3(0,-4,0),
            uv   = Tex2(0,0), 
            size = Vec3(8,8,8)}
        :Cube{
            id   = "hat",  
            pos  = Vec3(0,-4,0),
            uv   = Tex2(32,0), 
            size = Vec3(8,8,8),
            inflate = 0.5,
            isBackfaceCulling = false}

    inst["body"] = Part{pos = Vec3(0,-6,0)}
        :Cube{
            id = "body",
            pos  = Vec3(0,6,0),
            uv = Tex2(16,16),
            size = Vec3(8,12,4)
        }
        :Cube{
            id   = "jacket",  
            pos  = Vec3(0,6,0),
            uv   = Tex2(16,32), 
            size = Vec3(8,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}

    inst["arm_r"] = Part{pos = Vec3(-5,-4,0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-1,4,0),
            uv = Tex2(40,16),
            size = Vec3(4,12,4)
        }
        :Cube{
            id   = "sleeve_r", 
            pos  = Vec3(-1,4,0),
            uv   = Tex2(40,32), 
            size = Vec3(4,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}
    inst["arm_r_slim"] = Part{pos = Vec3(-5,-4,0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-.5,4,0),
            uv = Tex2(40,16),
            size = Vec3(3,12,4)
        }
        :Cube{
            id   = "sleeve_r", 
            pos  = Vec3(-.5,4,0),
            uv   = Tex2(40,32), 
            size = Vec3(3,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}

    inst["arm_l"] = Part{pos = Vec3(5,-4,0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(1,4,0),
            uv = Tex2(32,48),
            size = Vec3(4,12,4)}
        :Cube{
            id   = "sleeve_l", 
            pos  = Vec3(1,4,0),
            uv   = Tex2(48,48), 
            size = Vec3(4,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}

    inst["arm_l_slim"] = Part{pos = Vec3(5,-4,0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(.5,4,0),
            uv = Tex2(32,48),
            size = Vec3(3,12,4)}
        :Cube{
            id   = "sleeve_l", 
            pos  = Vec3(.5,4,0),
            uv   = Tex2(48,48), 
            size = Vec3(3,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}

    inst["leg_r"] = Part{pos = Vec3(-2,6,0)}
        :Cube{
            id = "leg_r",
            pos  = Vec3(0,6,0),
            uv = Tex2(0,16),
            size = Vec3(4,12,4)
        }
        :Cube{
            id   = "pants_r", 
            pos  = Vec3(0,6,0),
            uv   = Tex2(0,32), 
            size = Vec3(4,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}

    inst["leg_l"] = Part{pos = Vec3(2,6,0)}
        :Cube{
            id = "leg_l",
            pos  = Vec3(0,6,0),
            uv = Tex2(16,48),
            size = Vec3(4,12,4)
        }
        :Cube{
            id   = "pants_l", 
            pos  = Vec3(0,6,0),
            uv   = Tex2(0,48), 
            size = Vec3(4,12,4),
            inflate = 0.25,
            isBackfaceCulling = false}
    
    inst.isSlim = false
    return inst
end

function MCModel:slim_model()
    self["arm_r"].isVisible = false
    self["arm_r_slim"].isVisible = true

    self["arm_l"].isVisible = false
    self["arm_l_slim"].isVisible = true
    
    self.isSlim = true
end

function MCModel:classic_model()
    self["arm_r"].isVisible = true
    self["arm_r_slim"].isVisible = false

    self["arm_l"].isVisible = true
    self["arm_l_slim"].isVisible = false

    self.isSlim = false
end

function MCModel:auto_model(texture)
    local c = Color(texture:getPixel(55,31))

    if c.alpha > 0 then
        self:classic_model()
    else
        self:slim_model()
    end
end

function MCModel:cube_visibility(cube_name, isVisible)
    for key, part in pairs(self) do
        if type(part) == "table" then
            for name, cube in pairs(part.mesh) do
                if name == cube_name then
                    cube.isVisible = isVisible
                end
            end
        end
    end
end

function MCModel:get_cube(cube_name)
    for key, part in pairs(self) do
        if type(part) == "table" then
            if part.isVisible then
                for name, cube in pairs(part.mesh) do
                    if name == cube_name then
                        return cube
                    end
                end
            end
        end
    end

    return nil
end

function MCModel:reset_pose()
    for key, part in pairs(self) do
        if type(part) == "table" then
        part:reset()
        end
    end
end


function MCModel:draw(texture, camera, gc)
    --drawModel(gc, texture, camera)
    gc.strokeWidth = 1
    --initialize rotmatrices
    local matProj = Mat4x4.proj(30, gc.height / gc.width, 0.1, 1000)

    local rot = Mat4x4.rot(camera.rot.x,camera.rot.y,camera.rot.z)
    local trans = Mat4x4.trans(camera.pos.x, camera.pos.y, math.exp(camera.pos.z))
    local matView = Mat4x4.matMul(rot, trans)

    local faceBuffer = {}
    for key, part in pairs(self) do
        if type(part) ~= "table" then goto continue_b end
        if not part.isVisible then goto continue_b end

        local worldRot = Mat4x4.rot(part.rot.x,part.rot.y,part.rot.z)
        local worldPos = Mat4x4.trans(part.pos.x,part.pos.y,part.pos.z)
        local worldView = Mat4x4.matMul(worldRot, worldPos)
        
        --project to world
        for _,cube in pairs(part.mesh) do

            if not cube.isVisible then goto continue end
            
            local pointBuffer = {}
            local proj_pointBuffer = {}

            for i=1, 8 do
                local projPoint = cube.points[i]

                --move to world pos
                projPoint = Vec3.applyMat4x4(projPoint, worldView)

                --move respect to camera
                projPoint = Vec3.applyMat4x4(projPoint, matView)

                --projection
                proj_pointBuffer[i] = Vec3.applyMat4x4(projPoint, matProj)

                --push to point buffer
                pointBuffer[i] = projPoint
                
            end

            --faces
            for i=1, 6 do
                face = cube.faces[i]
                uv = cube.uv[i]

                local line1 = pointBuffer[face[2]] - pointBuffer[face[1]]
                local line2 = pointBuffer[face[4]] - pointBuffer[face[1]]

                local normal = Vec3.norm(Vec3.cross(line1,line2))

                if (not cube.isBackfaceCulling) or ( Vec3.dot(normal, pointBuffer[face[1]]) < 0) then
                    -- local dp = -normal.z

                    -- if not cube.isBackfaceCulling then
                    --     dp = math.abs(dp)
                    -- end

                    local projTri = triangle()
        
                    projTri.p[1] = pointBuffer[face[1]]
                    projTri.p[2] = pointBuffer[face[2]]
                    projTri.p[3] = pointBuffer[face[3]]
                    projTri.p[4] = pointBuffer[face[4]]
                        
                    if clip(Vec3(0,0,0.1), Vec3(0,0,1), projTri) then

                        projTri.c = 1--(dp + 1)/2

                        projTri.t[1] = uv[1]
                        projTri.t[2] = uv[2]
                        projTri.t[3] = uv[3]
                        projTri.t[4] = uv[4]

                        projTri.p[1] = proj_pointBuffer[face[1]]
                        projTri.p[2] = proj_pointBuffer[face[2]]
                        projTri.p[3] = proj_pointBuffer[face[3]]
                        projTri.p[4] = proj_pointBuffer[face[4]]


                        splitQuad(faceBuffer,projTri, texture,gc)
                    end
                end
            end
            
            ::continue::
        end

        ::continue_b::
    end

    table.stable_sort(faceBuffer,function(a,b) return a.sortby > b.sortby end)

    for i = 1, #faceBuffer do
        local x = faceBuffer[i]
        drawQuad(gc, x) 
    end

    --DEBUG DRAW PIVOTS
    -- gc.color = Color{r = 0,g = 255,b = 255, a = 255}
    -- gc:beginPath()
    -- for key, part in pairs(self) do
    --     local pivot = part.pos

    --     pivot = mat_MulVec3D(pivot, matView)
    --     pivot = mat_MulVec3D(pivot, matProj)

    --     local x1 = (pivot.x/pivot.w + 1) / 2 * gc.width
    --     local y1 = (pivot.y/pivot.w + 1) / 2 * gc.height
        
    --     local r = 5
    --     gc:oval(x1-r/2,y1-r/2,r,r)
        
    -- end

    -- gc:closePath()
    -- gc:fill()
end

function MCModel:__tostring()
    return MCModel.toJson(self)
end

function MCModel.toJson(model)
    local json = "{"

    for key, part in pairs(model) do
        json = json .. "{\"" ..key.."\":\n"..part:toJson().."\n},\n"
    end

    json = json .. "}"

    return json
end

return MCModel