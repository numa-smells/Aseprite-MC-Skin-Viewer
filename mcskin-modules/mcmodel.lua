--dofile("lib3D.lua")
local max, min, abs = math.max,math.min,math.abs

local function triangle(p, t)

  return {
    t = t or {Tex2(),Tex2(),Tex2(),Tex2()},
    p = p or {Vec3(),Vec3(),Vec3(),Vec3()},
    c = 0
  }
end

local function Vec2(x,y)
    return {x = x or 0, y = y or 0}
end

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

local function naive_rectclip(w,h,t)
  for i=1, 4 do
    local p = t[i]
    if p.x >=0 and p.x < w and p.y >= 0 and p.y < h then
      return true
    end
  end

  return false
end

local color_samples = {}
local pixel_coord_x = {}
local pixel_coord_y = {}
local pixel_coord_z = {}
--biggest face is on the torso 12 * 8, TODO: scale relative to multiplier

--this is the most expensive function since it runs for every pixel
local function splitQuad(buffer,tri,texture, gc, backside_showing)
    local ax, ay, aw, az = tri.p[1].x, tri.p[1].y, tri.p[1].w , tri.p[1].z
    local bx, by, bw, bz = tri.p[2].x, tri.p[2].y, tri.p[2].w , tri.p[2].z
    local cx, cy, cw, cz = tri.p[3].x, tri.p[3].y, tri.p[3].w , tri.p[3].z
    local dx, dy, dw, dz = tri.p[4].x, tri.p[4].y, tri.p[4].w , tri.p[4].z

    local au, av = tri.t[1].u, tri.t[1].v
    local bu, bv = tri.t[2].u, tri.t[2].v
    local cu, cv = tri.t[3].u, tri.t[3].v
    local du, dv = tri.t[4].u, tri.t[4].v

    local wd = (abs(max(au,bu,cu,du) - min(au,bu,cu,du)) // 1)
    local hd = (abs(max(av,bv,cv,dv) - min(av,bv,cv,dv)) // 1)

    local gcw2 = gc.width / 2
    local gch2 = gc.height / 2
    
    --color pass
    local start_au = au 
    local start_av = av - .5

    local delta_au = (bu-au)/wd
    local delta_av = (bv-av)/wd
    
    local start_cu = cu
    local start_cv = cv - .5

    local delta_cu = (du-cu)/wd
    local delta_cv = (dv-cv)/wd

    for i=0, wd-1 do
        local delta_bu = (start_cu-start_au)/hd
        local delta_bv = (start_cv-start_av)/hd
        
        local start_bu = start_au 
        local start_bv = start_av 

        for j=0, hd-1 do
            if backside_showing and i > 0 and i < wd-1 and j > 0 and j < hd - 1 then
                color_samples[1+j+i*hd] = nil
            else
                local c = Color(texture:getPixel(start_bu,start_bv))
                
                if c.alpha > 0 then
                    color_samples[1+j+i*hd] = c
                else
                    color_samples[1+j+i*hd] = nil
                end 
            end

            start_bu = start_bu + delta_bu
            start_bv = start_bv + delta_bv
        end

        start_au = start_au + delta_au
        start_av = start_av + delta_av

        start_cu = start_cu + delta_cu
        start_cv = start_cv + delta_cv
    end


    --pixel coords pass
    local ax_start = ax * gcw2
    local ay_start = ay * gch2 
    local az_start = az
    local aw_start = aw

    local delta_ax = (bx-ax)/wd * gcw2
    local delta_ay = (by-ay)/wd * gch2
    local delta_az = (bz-az)/wd
    local delta_aw = (bw-aw)/wd

    local cx_start = cx * gcw2
    local cy_start = cy * gch2
    local cz_start = cz
    local cw_start = cw

    local delta_cx = (dx-cx)/wd * gcw2
    local delta_cy = (dy-cy)/wd * gch2
    local delta_cz = (dz-cz)/wd
    local delta_cw = (dw-cw)/wd

    for i=0, wd do
        local delta_bw = (cw_start-aw_start)/hd
        local delta_bx = (cx_start-ax_start)/hd
        local delta_by = (cy_start-ay_start)/hd
        local delta_bz = (cz_start-az_start)/hd
        
        local start_bw = aw_start
        local start_bx = ax_start
        local start_by = ay_start
        local start_bz = az_start

        for j=0, hd do
            if backside_showing and i > 1 and i < wd -1 and j > 1 and j <hd-1 then
                goto skip_coord
            end

            --only compute if any surrounding color exists
            -- c1|c2
            -- — O —
            -- c3|c4

            if color_samples[1+j+i*hd] or color_samples[j+i*hd] or color_samples[1+j+(i-1)*hd] or color_samples[j+(i-1)*hd] then
                local index = 1+j+i*(hd+1)
                pixel_coord_x[index] = start_bx/start_bw + gcw2
                pixel_coord_y[index] = start_by/start_bw + gch2
                pixel_coord_z[index] = start_bz
            end

            ::skip_coord::

            start_bw = start_bw + delta_bw
            start_bx = start_bx + delta_bx
            start_by = start_by + delta_by
            start_bz = start_bz + delta_bz
        end

        ax_start = ax_start + delta_ax
        ay_start = ay_start + delta_ay
        az_start = az_start + delta_az
        aw_start = aw_start + delta_aw

        cx_start = cx_start + delta_cx
        cy_start = cy_start + delta_cy
        cz_start = cz_start + delta_cz
        cw_start = cw_start + delta_cw
    end

    --generate faces
    local visited = {}
    local faces = {}

    for i=0, wd-1 do
        for j=0, hd-1 do
            local index = 1+j+i*hd
            if visited[index]==nil then
                visited[index] = true
                local c = color_samples[index]
                local face_w, face_h = 1, 1

                if c ~= nil then
                    --vertical pass
                    local index_below = 1+face_h+j+i*hd
                    local next_col = color_samples[index_below]

                    while visited[index_below]==nil and next_col and (j+face_h < hd) and (c.rgbaPixel == next_col.rgbaPixel) do
                        face_h = face_h + 1
                        visited[index_below] = true
                        index_below = 1+face_h+j+i*hd
                        next_col = color_samples[index_below]
                    end

                    --next horizontal pass
                    --check if we can grow in horizontally
                    local can_grow = true

                    while can_grow do
                        if (i + face_w) < wd then
                            can_grow = true

                            for g=1,face_h do
                                next_col = color_samples[g+j+(i+face_w)*hd]
                                if next_col then
                                    can_grow = can_grow and (next_col.rgbaPixel == c.rgbaPixel)
                                else
                                    can_grow = false
                                end
                            end
                        else
                            can_grow = false
                        end
                        
                        --if yes, update the values
                        if can_grow then
                            for g=1,face_h do
                                visited[g+j+(i+face_w)*hd] = true
                            end
                            face_w = face_w + 1
                        end
                    end
                    

                    local x1 = pixel_coord_x[1+j+i*(hd+1)]
                    local y1 = pixel_coord_y[1+j+i*(hd+1)]
                    local z1 = pixel_coord_z[1+j+i*(hd+1)]

                    local x2 = pixel_coord_x[1+j+(i+face_w)*(hd+1)]
                    local y2 = pixel_coord_y[1+j+(i+face_w)*(hd+1)]
                    local z2 = pixel_coord_z[1+j+(i+face_w)*(hd+1)]

                    local x3 = pixel_coord_x[face_h+1+j+i*(hd+1)]
                    local y3 = pixel_coord_y[face_h+1+j+i*(hd+1)]
                    local z3 = pixel_coord_z[face_h+1+j+i*(hd+1)]

                    local x4 = pixel_coord_x[face_h+1+j+(i+face_w)*(hd+1)]
                    local y4 = pixel_coord_y[face_h+1+j+(i+face_w)*(hd+1)]
                    local z4 = pixel_coord_z[face_h+1+j+(i+face_w)*(hd+1)]
                    
                    c.value = c.value * tri.c
                    local newtri = {c,0,Vec2(x1,y1),Vec2(x2,y2),Vec2(x4,y4),Vec2(x3,y3)}
                    newtri[2] = (az+bz+cz+dz)/4+max(z1,z2,z3,z4)
                    table.insert(buffer, newtri)
                end
            end
        end
    end
end

local function drawQuad(gc, tri,AA) 
  

  gc.color = tri[1]
        
  gc:beginPath()
  gc:moveTo(tri[3].x, tri[3].y)

  local n = #tri
  for i=4, n do
    gc:lineTo(tri[i].x, tri[i].y)
  end

  gc:closePath()
  
  if tri[1].alpha == 255 and AA then
    gc.antialias = true
    gc:fill()
    gc:stroke()
  else
    gc.antialias = false
    gc:stroke()
  end
end

dofile("vec3.lua")
dofile("tex2.lua")
dofile("mat4x4.lua")
dofile("part.lua")
dofile("sort.lua")

MCModel = {}
MCModel.__index = MCModel

function MCModel.new(spriteScaleMultiplier)
    local inst <const> = {}
    setmetatable(inst, MCModel)

    --define model here
    inst["head"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id   = "head",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(0, 0), 
            size = Vec3(8, 8, 8),
			scaleMultiplier = spriteScaleMultiplier
		}
        :Cube{
            id   = "hat",  
            pos  = Vec3(0, -4, 0),
            uv   = Tex2(32, 0), 
            size = Vec3(8, 8, 8),
            inflate = 0.5,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}

    inst["body"] = Part{pos = Vec3(0, -6, 0)}
        :Cube{
            id = "body",
            pos  = Vec3(0,6,0),
            uv = Tex2(16, 16),
            size = Vec3(8,12,4),
			scaleMultiplier = spriteScaleMultiplier
        }
        :Cube{
            id   = "jacket",  
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(16, 32), 
            size = Vec3(8, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}

    inst["arm_r"] = Part{pos = Vec3(-5, -4, 0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-1, 4, 0),
            uv = Tex2(40, 16),
            size = Vec3(4, 12, 4),
			scaleMultiplier = spriteScaleMultiplier
        }
        :Cube{
            id   = "sleeve_r", 
            pos  = Vec3(-1, 4, 0),
            uv   = Tex2(40, 32), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}
    inst["arm_r_slim"] = Part{pos = Vec3(-5, -4, 0)}
        :Cube{
            id = "arm_r",
            pos  = Vec3(-.5, 4, 0),
            uv = Tex2(40, 16),
            size = Vec3(3, 12, 4),
			scaleMultiplier = spriteScaleMultiplier
        }
        :Cube{
            id   = "sleeve_r", 
            pos  = Vec3(-.5, 4, 0),
            uv   = Tex2(40, 32), 
            size = Vec3(3, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}

    inst["arm_l"] = Part{pos = Vec3(5, -4, 0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(1, 4, 0),
            uv = Tex2(32, 48),
            size = Vec3(4, 12, 4),
			scaleMultiplier = spriteScaleMultiplier
		}
        :Cube{
            id   = "sleeve_l", 
            pos  = Vec3(1, 4, 0),
            uv   = Tex2(48, 48), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}

    inst["arm_l_slim"] = Part{pos = Vec3(5, -4, 0)}
        :Cube{
            id = "arm_l",
            pos  = Vec3(.5, 4, 0),
            uv = Tex2(32, 48),
            size = Vec3(3, 12, 4),
			scaleMultiplier = spriteScaleMultiplier
		}
        :Cube{
            id   = "sleeve_l", 
            pos  = Vec3(.5, 4, 0),
            uv   = Tex2(48, 48), 
            size = Vec3(3, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}

    inst["leg_r"] = Part{pos = Vec3(-2, 6, 0)}
        :Cube{
            id = "leg_r",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(0, 16),
            size = Vec3(4, 12, 4),
			scaleMultiplier = spriteScaleMultiplier
        }
        :Cube{
            id   = "pants_r", 
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(0, 32), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}

    inst["leg_l"] = Part{pos = Vec3(2, 6, 0)}
        :Cube{
            id = "leg_l",
            pos  = Vec3(0, 6, 0),
            uv = Tex2(16, 48),
            size = Vec3(4, 12, 4),
			scaleMultiplier = spriteScaleMultiplier
        }
        :Cube{
            id   = "pants_l", 
            pos  = Vec3(0, 6, 0),
            uv   = Tex2(0, 48), 
            size = Vec3(4, 12, 4),
            inflate = 0.25,
            isBackfaceCulling = false,
			scaleMultiplier = spriteScaleMultiplier
		}
    
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
            for name, cube in pairs(part.mesh) do
                cube.isVisible = true
            end
        end
    end
end


function MCModel:draw(texture, camera, gc, light_dir, AA)
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

                if (not cube.isBackfaceCulling) or ( Vec3.dot(normal, pointBuffer[face[1]]) < 0) then
                    local dp = 1
                    
                    if light_dir == "Front" then
                        dp = -normal.z
                    elseif light_dir == "Top" then
                        dp = -normal.y
                    end
                    
                    local backside_showing = not cube.isBackfaceCulling and normal.z > 0
                    if backside_showing then
                        dp = math.abs(dp)
                    end

                    local projTri = triangle()
        
                    projTri.p[1] = pointBuffer[face[1]]
                    projTri.p[2] = pointBuffer[face[2]]
                    projTri.p[3] = pointBuffer[face[3]]
                    projTri.p[4] = pointBuffer[face[4]]
                        
                    if clip(Vec3(0,0,0.1), Vec3(0,0,1), projTri) then

                        projTri.c = (dp + 1)/4 + .5

                        projTri.t[1] = uv[1]
                        projTri.t[2] = uv[2]
                        projTri.t[3] = uv[3]
                        projTri.t[4] = uv[4]

                        projTri.p[1] = proj_pointBuffer[face[1]]
                        projTri.p[2] = proj_pointBuffer[face[2]]
                        projTri.p[3] = proj_pointBuffer[face[3]]
                        projTri.p[4] = proj_pointBuffer[face[4]]


                        splitQuad(faceBuffer,projTri, texture,gc, backside_showing)
                    end
                end
            end
            ::continue::
        end
        ::continue_b::
    end
    table.stable_sort(faceBuffer,function(a,b) return a[2] > b[2] end)
    local n = #faceBuffer
    for i = 1, n do
        drawQuad(gc, faceBuffer[i], AA) 
    end
end

function MCModel:draw_profile(texture, camera, gc, light_dir, AA)
    gc.strokeWidth = 1
    --initialize rotmatrices
    local matProj = Mat4x4.proj(30, gc.height / gc.width, 0.1, 1000)

    local rot = Mat4x4.rot(camera.rot.x,camera.rot.y,camera.rot.z)
    local trans = Mat4x4.trans(camera.pos.x, camera.pos.y, math.exp(camera.pos.z))
    local matView = Mat4x4.matMul(rot, trans)
    
    local profileTimes = {}
    local faceBuffer = {}
    for key, part in pairs(self) do
        if type(part) ~= "table" then goto continue_b end
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

                if (not cube.isBackfaceCulling) or ( Vec3.dot(normal, pointBuffer[face[1]]) < 0) then
                    local dp = 1
                    
                    if light_dir == "Front" then
                        dp = -normal.z
                    elseif light_dir == "Top" then
                        dp = -normal.y
                    end
                    
                    local backside_showing = not cube.isBackfaceCulling and normal.z > 0
                    if backside_showing then
                        dp = math.abs(dp)
                    end

                    local projTri = triangle()
        
                    projTri.p[1] = pointBuffer[face[1]]
                    projTri.p[2] = pointBuffer[face[2]]
                    projTri.p[3] = pointBuffer[face[3]]
                    projTri.p[4] = pointBuffer[face[4]]
                        
                    if clip(Vec3(0,0,0.1), Vec3(0,0,1), projTri) then

                        projTri.c = (dp + 1)/4 + .5

                        projTri.t[1] = uv[1]
                        projTri.t[2] = uv[2]
                        projTri.t[3] = uv[3]
                        projTri.t[4] = uv[4]

                        projTri.p[1] = proj_pointBuffer[face[1]]
                        projTri.p[2] = proj_pointBuffer[face[2]]
                        projTri.p[3] = proj_pointBuffer[face[3]]
                        projTri.p[4] = proj_pointBuffer[face[4]]


                        splitQuad(faceBuffer,projTri, texture,gc, backside_showing)
                    end
                end
            end
            ::continue::
        end
        ::continue_b::
    end
    profileTimes[1] = os.clock()
    
    table.stable_sort(faceBuffer,function(a,b) return a[2] > b[2] end)
    profileTimes[2] = os.clock()
    local n = #faceBuffer
    for i = 1, n do
        drawQuad(gc, faceBuffer[i], AA) 
    end
    profileTimes[3] = os.clock()
    return profileTimes
end

function MCModel:updateUV(uvScaleMultiplier)
	for key, part in pairs(self) do
		if type(part) == "table" then
			for _, cube in pairs(part.mesh) do
				cube:setUV(uvScaleMultiplier)
			end
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