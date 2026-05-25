dofile("face.lua")

local max, min, abs = math.max,math.min,math.abs

local function clip(plane_p, plane_n, in_tri)
  local plane_n = Vec3.norm(plane_n)
  local dist = function(p)
    local n = Vec3.norm(p)
    return (plane_n.x * p.x + plane_n.y * p.y + plane_n.z * p.z - Vec3.dot(plane_n, plane_p))
  end
  
  -- Create two temporary storage arrays to classify points either side of plane
	-- If distance sign is positive, point lies on "inside" of plane
	-- Get signed distance of each point in triangle to plane
  local d0 = dist(in_tri.p[1])
  local d1 = dist(in_tri.p[2])
  local d2 = dist(in_tri.p[3])
  local d3 = dist(in_tri.p[4])

  return (d0 >= 0 and d1 >= 0 and d2 >= 0 and d3 >= 0)
end

dofile("vec3.lua")
dofile("tex2.lua")
dofile("mat4x4.lua")
dofile("part.lua")
dofile("sort.lua")

MCModel = {}
MCModel.__index = MCModel

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


function MCModel:draw(texture, camera, gc, light_dir, AA,showWireframe)
    gc.strokeWidth = 1
    --initialize rotmatrices
    local matProj = Mat4x4.proj(30, gc.height / gc.width, 0.1, 1000)

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
                local face = cube.faces[i]
                local uv = cube.uv[i]

                local line1 = pointBuffer[face[2]] - pointBuffer[face[1]]
                local line2 = pointBuffer[face[4]] - pointBuffer[face[1]]

                local normal = Vec3.norm(Vec3.cross(line1,line2))
                local isFacingCamera = normal.z < 0 --Vec3.dot(normal, pointBuffer[face[1]]) < 0
                if (not cube.isBackfaceCulling) or isFacingCamera then
                    local dp = 1
                    
                    if light_dir == "Front" then
                        dp = -normal.z
                    elseif light_dir == "Top" then
                        dp = -normal.y
                    end
                    
                    local backside_showing = (not cube.isBackfaceCulling) and (normal.z > 0)
                    if backside_showing then
                        dp = math.abs(dp)
                    end

                    local projTri = Face()
        
                    projTri.p[1] = pointBuffer[face[1]]
                    projTri.p[2] = pointBuffer[face[2]]
                    projTri.p[3] = pointBuffer[face[4]]
                    projTri.p[4] = pointBuffer[face[3]]
                        
                    if clip(Vec3(0,0,0.1), Vec3(0,0,1), projTri) then

                        local light = (dp + 1)/2
                        projTri.c = Color{gray=light*255, alpha=255}
                        projTri.normal = normal:copy()

                        projTri.t[1] = uv[1]
                        projTri.t[2] = uv[2]
                        projTri.t[3] = uv[4]
                        projTri.t[4] = uv[3]

                        projTri.p[1] = pointBuffer[face[1]]
                        projTri.p[2] = pointBuffer[face[2]]
                        projTri.p[3] = pointBuffer[face[4]]
                        projTri.p[4] = pointBuffer[face[3]]

                        projTri:updateBounds()
                        projTri.cube_id = cube_id
                        

                        projTri.face_id = face_id
                        table.insert(faceBuffer,projTri)
                    end
                end
            end
            
            ::continue::
        end
        ::continue_b::
    end

    --table.stable_sort(faceBuffer,function(a,b) return a.max.z < b.max.z end)

    --painters algo sorting https://education.siggraph.org/static/HyperGraph/scanline/visibility/painter.htm
    -- https://notthefuture.com/how2code/3d-lighting/
    -- https://web.archive.org/web/20070828042233/http://www.devmaster.net/articles/bsp-trees/

    local n = #faceBuffer
    local swap = {}

    for i=1, n do
        faceBuffer[i].face_id = i
        swap[i] = {}
    end

    local face_id = n + 1
    
    local i = 2
    while i <= n do
       local s = faceBuffer[i]
       
        for j=1, n do
            
            local p = faceBuffer[j]
            --test -1: swap buffer

            --test 0: simple overlap, else test trivially
            if s.min.z <= p.max.z and s.max.z >= p.min.z then    
                local s_test = p:planeTest(s)
                local p_test = s:planeTest(p)
                
                --s and p intersect.
                if s_test == p_test and s_test == 0 then 
                    local s_behind, s_front = s:splitAlong(p)
                    p.c = Color{r=255,g=100,b=100,a=255}

                    assert(s_behind and s_front)
                    
                    --this guy goes behind !! 
                    s_behind.cube_id = s.cube_id
                    s_behind.normal = s.normal
                    s_behind.c = s.c
                    s_behind.face_id = s.face_id      

                    s_behind.c = Color{r=100,g=255,b=100,a=255}
                    faceBuffer[i] = s_behind
                    --Move new i behind j
                    for k = i, j+1, -1 do
                        local temp      = faceBuffer[k]
                        faceBuffer[k]   = faceBuffer[k-1]
                        faceBuffer[k-1] = temp
                    end

                    --sfront
                    s_front.normal = s.normal                                   
                    s_front.cube_id = s.cube_id
                    s_front.c = s.c          
                    s_front.face_id = face_id 
                    face_id = face_id + 1
                    
                    s_front.c = Color{r=100,g=100,b=255,a=255}
                    faceBuffer[n + 1] = s_front
                    n = n + 1 

                    goto sort_continue
                end

                if s_test == -1 or p_test == 1 then
                    --move s is behind p, or p is infront of s
                    for k = i, j+1, -1 do
                        local temp      = faceBuffer[k]
                        faceBuffer[k]   = faceBuffer[k-1]
                        faceBuffer[k-1] = temp
                    end

                    goto sort_continue
                end

                --otherwise it means p should still be behind s... right?
                if s.max.z > p.max.z then --trivial
                --move s behind p
                    for k = i, j+1, -1 do
                        local temp      = faceBuffer[k]
                        faceBuffer[k]   = faceBuffer[k-1]
                        faceBuffer[k-1] = temp
                    end

                    goto sort_continue
                end
                
            elseif s.max.z > p.max.z then --trivial
                --move s behind p
                for k = i, j+1, -1 do
                    local temp      = faceBuffer[k]
                    faceBuffer[k]   = faceBuffer[k-1]
                    faceBuffer[k-1] = temp
                end

                goto sort_continue
            end
       end

       ::sort_continue::
       i = i + 1
    end


    for i = 1, n do
        -- local norm = faceBuffer[i].normal
        -- faceBuffer[i].c = Color{r=(norm.x+1)*128,g=(norm.y-1)*128,b=(norm.z-1)*128}
        faceBuffer[i]:draw(gc,AA,showWireframe)
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