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

local function qs_Draw(A,gc,AA,showWireframe,matProj,depth)
    local n = #A
    local gcw, gch = gc.width,gc.height

    if n == 0 then return depth-1, 0 end
    if n == 1 then
        local face = A[1]
         
        face:updateProjPoints(matProj, gcw, gch)
        face:drawPixels(gc,AA,showWireframe)

        return depth, 1
    end
    

    --optimization. choose a pivot that bisects the least amount of polygons...
    --just brute force it for now

    local best_i = 0
    local best_hit = 999999999
    --ok this is too much work. so we randomize right?
    local best_hit_list = {}
    
    local test_count = 3
    --TODO: CHOOSE BEST PIVOT SMARTLY
    local i = 1
    local m = min(test_count, n)

    while i <= m and best_hit > 0 do
        local i_rnd = math.random(n)

        if i <= test_count then
            i_rnd = i
        end

        local s = A[i_rnd]
        local collission_count = 0
        local hit_list = {}

        hit_list[i_rnd] = 2
        local j = 1

        while j <= n and collission_count < best_hit do
            --exit early if collission count goes over the best.
            if j ~= i_rnd then
                local p = A[j]
                if s.min.z <= p.max.z and s.max.z >= p.min.z then
                    local p_test = s:planeTest(p)
                    
                    if  p_test == 0 then
                        collission_count = collission_count + 1
                    end

                    if p_test == 2 then
                        hit_list[j] = s.max.z < p.max.z and -1 or 1
                    else
                        hit_list[j] = p_test
                    end

                else
                    hit_list[j] = s.max.z < p.max.z and -1 or 1
                end
            end
            j = j + 1
        end

        if collission_count < best_hit then
            best_i = i_rnd
            best_hit = collission_count
            best_hit_list = hit_list
        end
        
        i = i + 1
    end


    local s = A[best_i]

    local behind, infront = {}, {}

    for j=1, n do
        local hit = best_hit_list[j]
        local p = A[j]
        --assert((best_i ~= j and hit ~= 2) or (best_i == j and hit == 2),tostring(best_i).."-"..tostring(j).."-"..tostring(hit))

        if hit == -1 then
            table.insert(behind, p)
        elseif hit == 1 then
            table.insert(infront, p)
        elseif hit == 0 then
            local p_front, p_behind = p:splitAlong(s)
            p_behind.normal = p.normal
            p_behind.pixels = p.pixels

            table.insert(behind,p_behind)

            p_front.normal = p.normal
            p_front.pixels = p.pixels

            table.insert(infront,p_front)
        end
    end
    --assert(#behind + #infront + 1 >= n,tostring(#behind).."-"..tostring(#infront).."-"..tostring(n))
    
    local depth_1, count_1 = qs_Draw(behind,gc,AA,showWireframe,matProj, depth + 1)

    s:updateProjPoints(matProj, gcw, gch)
    s:drawPixels(gc,AA,showWireframe)

   local depth_2, count_2 = qs_Draw(infront,gc,AA,showWireframe,matProj, depth + 1)

   return depth_1 > depth_2 and depth_1 or depth_2, count_1 + count_2 + 1
end


function MCModel:draw(texture, camera, gc, light_dir, AA,showWireframe)
    --initialize rotmatrices
    local matProj = Mat4x4.proj(30, gc.height / gc.width, 0.1, 1000)
    
    local fFovRad = 1 / math.tan(30 * 0.5 / 180.0 * 3.14159)
    local aspectRatio = gc.height/gc.width

    local rot = Mat4x4.rot(camera.rot.x,camera.rot.y,camera.rot.z)
    local trans = Mat4x4.trans(camera.pos.x, camera.pos.y, math.exp(camera.pos.z))
    local matView = Mat4x4.matMul(rot, trans)
    
    local faceBuffer = {}
    
    local gcw, gch = gc.width, gc.height
    
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
                local pixelMeshes = cube.pixelMeshes[i]

                if pixelMeshes.n == 0 then --there are no pixels, quit it.
                    goto continue_a
                end

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

                    projTri:shrinkBounds(uvMin,uvMax,uvImage)
                    projTri:updateBounds()

                    local zero = Vec3(0,0,0)
                  
                    --these numbers came to me in a dream. but generally this code crops XYZ to camera space
                    projTri = projTri:splitAlong_one(zero,Vec3(-0.9626*aspectRatio,0,-0.2708))

                    if projTri then
                       projTri = projTri:splitAlong_one(zero,Vec3(0.9626*aspectRatio,0,-0.2708))
                    end

                    if projTri then
                       projTri = projTri:splitAlong_one(zero,Vec3(0,-0.9626,-0.2708))
                    end

                    if projTri then
                       projTri = projTri:splitAlong_one(zero,Vec3(0,0.9626,-0.2708))
                    end

                    if projTri then
                        projTri = projTri:splitAlong_one(Vec3(0,0,0.1),Vec3(0,0,-1))
                    end
                    

                    if projTri then
                        
                        
                        local light = (dp + 1)/4 + 0.5
                        projTri.normal = normal
                        projTri.isOpaque = cube.isBackfaceCulling
                        
                        projTri:computePixels(pixelMeshes, light, gcw, gch, matProj)
                        table.insert(faceBuffer,projTri)
                    end
                  
                end
                ::continue_a::
            end
            
            ::continue::
        end
        ::continue_b::
    end

    --table.stable_sort(faceBuffer,function(a,b) return a.max.z < b.max.z end) --reduce amount of work possibly?

    --painters algo sorting https://education.siggraph.org/static/HyperGraph/scanline/visibility/painter.htm
    -- https://notthefuture.com/how2code/3d-lighting/
    -- https://web.archive.org/web/20070828042233/http://www.devmaster.net/articles/bsp-trees/


    
    local n = #faceBuffer

    gc.antialias = AA
    gc.strokeWidth = 0

    math.randomseed(camera.rot.z,camera.rot.y) --stable partitioning when viewing from the same angle.

    local a, b = qs_Draw(faceBuffer,gc,AA,showWireframe,matProj,1)
    
    
    return a, b, n
end

function MCModel:updateTexture(texture)
    for key, part in pairs(self) do
        for _, cube in pairs(part.mesh) do
            cube:updatePixelMesh(texture)
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