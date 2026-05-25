local max, min, abs = math.max,math.min,math.abs

local Face = dofile("face.lua")
local Vec3 = dofile("vec3.lua")
local Vec2 = dofile("vec2.lua")
local Part = dofile("part.lua")
local Mat4x4 = dofile("mat4x4.lua")

MCModel = {}
MCModel.__index = MCModel

local color_samples = {}
local pixel_coord_x = {}
local pixel_coord_y = {}
local pixel_coord_z = {}



function MCModel.new()
    local inst <const> = {}
    setmetatable(inst, MCModel)
    return inst
end

function MCModel:cube_visibility(cube_name, isVisible)
    for key, part in pairs(self) do
        for name, cube in pairs(part.mesh) do
            if name == cube_name then
                cube.isVisible = isVisible
            end
        end
    end
end

function MCModel:part_visibility(part_name, isVisible)
    for key, part in pairs(self) do
        if key == part_name then
            part.isVisible = isVisible
        end
    end
end

function MCModel:get_cube(cube_name)
    for key, part in pairs(self) do
        if part.isVisible then
            for name, cube in pairs(part.mesh) do
                if name == cube_name then
                    return cube
                end
            end
        end
    end

    return nil
end

function MCModel:reset_pose()
    for key, part in pairs(self) do
        part:reset()
        part.isVisible = true
    end
end

local function faceSort(A,lo,hi)
    local hi = hi
    local lo = lo

    if lo >= hi or lo < 1 then
        return 0
    end

    local s = A[hi]
    local start_hi = hi
    --s.c = Color{r=255,g=128,b=128}

    local i = lo
    local j = lo
    while j <= hi - 1 do
        local isSBehind = false
        local p = A[j]

        if s.min.z <= p.max.z and s.max.z >= p.min.z then--step 1, test for z overlap.
            local p_test = s:planeTest(p)
            local s_test = p:planeTest(s)

            if p_test == 0 then 
                --split P
                local p_behind, p_front = p:splitAlong(s)
                assert(p_behind and p_front)

                if p_front then
                    p_front.normal = p.normal
                    p_front.c = p.c
                    p_front.toProj = p.toProj

                    A[j] = p_front
                    isSBehind = true
                end

                if p_behind then --add a new thing to the front, to be sorted.
                    p_behind.normal = p.normal
                    p_behind.c = p.c
                    p_behind.toProj = p.toProj
                    
                    table.insert(A,hi,p_behind)
                    hi = hi + 1
                end
                
            elseif p_test == -1 or s_test == 1 then
                isSBehind = true
            else
                isSBehind = s.max.z < p.max.z
            end
        else
            isSBehind = s.max.z < p.max.z
        end

        if isSBehind then
            local temp = A[i]
            A[i] = A[j]
            A[j] = temp

            i = i + 1
        end
        j = j + 1
    end
    --swap A[i] with A[hi]
    local temp = A[i]
    A[i] = A[hi]
    A[hi] = temp

    local delta = faceSort(A,lo,i-1)
    hi = hi + delta
    i = i + delta

    delta = faceSort(A,i+1,hi)
    hi = hi + delta

    return hi - start_hi

end
dofile("sort.lua")

function MCModel:draw(texture, camera, gc, light_dir, AA,showWireframe)
    gc.strokeWidth = 1
    --initialize rotmatrices
    local matProj = Mat4x4.proj(30, gc.height / gc.width, 0.1, 1000)
    
    local fFovRad = 1 / math.tan(30 * 0.5 / 180.0 * 3.14159)
    local aspectRatio = gc.height/gc.width

    local rot = Mat4x4.rot(camera.rot.x,camera.rot.y,camera.rot.z)
    local trans = Mat4x4.trans(camera.pos.x, camera.pos.y, math.exp(camera.pos.z))
    local matView = Mat4x4.matMul(rot, trans)
    
    local faceBuffer = {}

    for key, part in pairs(self) do
        if not part.isVisible then goto continue_b end

        local worldRot = Mat4x4.rot(part.rot.x, part.rot.y, part.rot.z)
        local worldPos = Mat4x4.trans(part.pos.x, part.pos.y, part.pos.z)
        local worldView = Mat4x4.matMul(worldRot, worldPos)
        
        --project to world
        for _, cube in pairs(part.mesh) do
            
            if not cube.isVisible then goto continue end
            
            local pointBuffer = {}

            for i=1, 8 do
                local projPoint = cube.points[i]

                --move to world pos
                projPoint = Vec3.applyMat4x4(projPoint, worldView)

                --move respect to camera
                projPoint = Vec3.applyMat4x4(projPoint, matView)

                --push to point buffer
                pointBuffer[i] = projPoint
                
            end

            --faces
            for i=1, 6 do
                local face = cube.faces[i]
                local uv = cube.uv[i]

                --if there are no pixels in UV, skip this face.
                local uvMin=Vec2.min4(uv[1],uv[2],uv[3],uv[4])
                local uvMax=Vec2.max4(uv[1],uv[2],uv[3],uv[4])-uvMin

                local uvImage = Image(texture, Rectangle(uvMin.x,uvMin.y,uvMax.x,uvMax.y))
                if uvImage and uvImage:isEmpty() then
                    goto continue_a
                end

                local line1 = pointBuffer[face[2]] - pointBuffer[face[1]]
                local line2 = pointBuffer[face[4]] - pointBuffer[face[1]]

                local normal = Vec3.norm(Vec3.cross(line1,line2))
                local isFacingCamera = Vec3.dot(normal, pointBuffer[face[1]]) < 0 -- normal.z < 0 --
                if (not cube.isBackfaceCulling) or isFacingCamera then
                    local dp = 1
                    
                    if light_dir == "Front" then
                        dp = -normal.z
                    elseif light_dir == "Top" then
                        dp = -normal.y
                    end
                    
                    
                    local projTri = Face()
        
                    projTri.p[1] = pointBuffer[face[1]]
                    projTri.p[2] = pointBuffer[face[2]]
                    projTri.p[3] = pointBuffer[face[3]]
                    projTri.p[4] = pointBuffer[face[4]]
                    projTri.t[1] = uv[1]
                    projTri.t[2] = uv[2]
                    projTri.t[3] = uv[3]
                    projTri.t[4] = uv[4]
                    
                    local backside_showing = (not cube.isBackfaceCulling) and normal.z >= 0
                    if backside_showing then
                        dp = math.abs(dp)
                        projTri:flipSide()
                        normal = normal:mult(-1)
                    end

                    projTri:updateUVtoWorld(matProj)
                    projTri:shrinkBounds(uvMin,uvMax,uvImage)
                    projTri:updateBounds()
                  
                    --these numbers came to me in a dream. but generally this code crops XYZ to camera space
                    projTri = projTri:splitAlong_one(Vec3(0,0,0),Vec3(-0.9626*aspectRatio,0,-0.2708))

                    if projTri then 
                       projTri = projTri:splitAlong_one(Vec3(0,0,0),Vec3(0.9626*aspectRatio,0,-0.2708))
                    end

                    if projTri then 
                       projTri = projTri:splitAlong_one(Vec3(0,0,0),Vec3(0,-0.9626,-0.2708))
                    end

                    if projTri then 
                       projTri = projTri:splitAlong_one(Vec3(0,0,0),Vec3(0,0.9626,-0.2708))
                    end

                    if projTri then 
                        projTri = projTri:splitAlong_one(Vec3(0,0,0.1),Vec3(0,0,-1))
                    end
                    

                    if projTri then
                        
                        
                        local light = (dp + 1)/4 + 0.5
                        projTri.c = light
                        projTri.normal = normal

                        table.insert(faceBuffer,projTri)
                    end
                  
                end
                ::continue_a::
            end
            
            ::continue::
        end
        ::continue_b::
    end

    table.stable_sort(faceBuffer,function(a,b) return a.max.z > b.max.z end) --reduce amount of work

    --painters algo sorting https://education.siggraph.org/static/HyperGraph/scanline/visibility/painter.htm
    -- https://notthefuture.com/how2code/3d-lighting/
    -- https://web.archive.org/web/20070828042233/http://www.devmaster.net/articles/bsp-trees/

    local n = #faceBuffer
    -- local face_id = n + 1
    -- n = n + faceSort(faceBuffer,1,n)
    
    gc.antialias = AA
    gc.strokeWidth = 0

    for i = 1, n do
        local face = faceBuffer[i]
        
        for j=1,#face.p do
            face.p[j] = Vec3.applyMat4x4(face.p[j], matProj)
        end
        

        if face then
            face:draw(texture,gc,AA,showWireframe)
        end
    end

end

function MCModel:updateUV(uvScaleMultiplier)
	for key, part in pairs(self) do
        for _, cube in pairs(part.mesh) do
            cube:setUV(uvScaleMultiplier)
        end
	end
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