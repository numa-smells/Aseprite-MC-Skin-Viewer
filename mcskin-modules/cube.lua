if not Vec2 then
  local Vec2 = dofile("vec2.lua")
end
if not Vec3 then
  local Vec3 = dofile("vec3.lua")
end

Cube = {}
Cube.__index = Cube

setmetatable(Cube, {
	__call = function(cls,...)
		return cls.new(...)
	end
})

function Cube:setUV(uvScaleMultiplier)
	local u = self.uvOrigin.x -- UV position X
	local v = self.uvOrigin.y -- UV position Y
	local wt = self.cubeSize.x 
	local ht = self.cubeSize.y
	local dt = self.cubeSize.z
	
	--yeah this is kinda long and dumb but it works ok !!

	if self.isMirrored then
		self.uv = {
			{ --FRONT
				Vec2((u+wt+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ -- LEFT
				Vec2((u+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ --BACK
				Vec2((u+wt+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ -- RIGHT
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ --BOTTOM
				Vec2((u+wt+dt+wt)*uvScaleMultiplier,(v+dt)*uvScaleMultiplier),
				Vec2((u+dt+wt+wt)*uvScaleMultiplier,(v)*uvScaleMultiplier),
				Vec2((u+dt+wt)*uvScaleMultiplier, 	(v)*uvScaleMultiplier),
				Vec2((u+dt+wt)*uvScaleMultiplier, 	(v+dt)*uvScaleMultiplier),
			},
			{ --TOP
				Vec2((u+dt)*uvScaleMultiplier, 	(v)*uvScaleMultiplier),
				Vec2((u+wt+dt)*uvScaleMultiplier, (v)*uvScaleMultiplier),
				Vec2((u+wt+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, 	(v+dt)*uvScaleMultiplier),
			}
		}
	else
		self.uv = {
			{ --FRONT
				Vec2((u+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ -- LEFT
				Vec2((u+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ --BACK
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2((u+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ --RIGHT
				Vec2(u*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
				Vec2(u*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			},
			{ --BOTTOM
				Vec2((u+dt+wt)*uvScaleMultiplier, 	(v+dt)*uvScaleMultiplier),
				Vec2((u+dt+wt)*uvScaleMultiplier, 	(v)*uvScaleMultiplier),
				Vec2((u+dt+wt+wt)*uvScaleMultiplier,(v)*uvScaleMultiplier),
				Vec2((u+wt+dt+wt)*uvScaleMultiplier,(v+dt)*uvScaleMultiplier),
			},
			{ --TOP
				Vec2((u+wt+dt)*uvScaleMultiplier, (v)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, 	(v)*uvScaleMultiplier),
				Vec2((u+dt)*uvScaleMultiplier, 	(v+dt)*uvScaleMultiplier),
				Vec2((u+wt+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			}
		}
	end

	return self
end

function Cube.new(params)
	local inst <const> = {}
	setmetatable(inst, Cube)

	inst.isVisible = true
	if params.isVisible ~= nil then
		inst.isVisible = params.isVisible
	end

	if params.isMirrored ~= nil then
		inst.isMirrored = params.isMirrored
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
		{1,2,4,3},	--FRONT
		{2,6,8,4},	--LEFT
		{6,5,7,8},	--BACK
		{5,1,3,7},	--RIGHT
		{1,5,6,2},	--BOTTOM
		{8,7,3,4}	 --TOP
	}

	inst.pixelMeshes = {c={},x={},y={},w={},h={},n=0}

	local size = params.size or Vec3(1,1,1)
	inst.cubeSize = size -- used in UV recalculation
	local pos = params.pos or Vec3()
	local scaleMultiplier = params.scaleMultiplier or 1

	local uv = params.uv or Vec2()
	inst.uvOrigin = uv -- used in UV recalculation
	local inflate = params.inflate or 0
	
	inst:setUV(scaleMultiplier)

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
	-- local uv = params.uv or Vec2()
	-- local inflate = params.inflate or 0
	-- local showBackface = params.showBackface or false
	-- local isVisible = params.isVisible or true

	inst.t = {{},{},{},{},{},{}}
	inst.p = {{},{},{},{},{},{}}
	return inst
end

function Cube:updatePixelMesh(texture)
	
	--generate pixel meshes
	for face=1, 6 do
		local t = self.uv[face]
	
		--get bounds of UV
		local min_u, min_v = t[1].x, t[1].y
		local max_u, max_v = t[1].x, t[1].y

		for i = 2, 4 do
			local t_n = t[i]
			if t_n.x < min_u then min_u = t_n.x end
			if t_n.y < min_v then min_v = t_n.y end
			if t_n.x > max_u then max_u = t_n.x end
			if t_n.y > max_v then max_v = t_n.y end
		end
		min_u = min_u // 1 --floor min
		min_v = min_v // 1

		max_u = -((-max_u) // 1) --ceil max
		max_v = -((-max_v) // 1)

		local u_width = max_u - min_u + 1
		local v_width = max_v - min_v + 1

		local uvImage = Image(texture, Rectangle(min_u,min_v,u_width-1,v_width-1))
		local bounds = uvImage:shrinkBounds()

		bounds.x = bounds.x + min_u
  		bounds.y = bounds.y + min_v

		local src_a, src_b, src_c = t[1], t[2], t[3]
		local dst_a, dst_b, dst_c = self.points[self.faces[face][1]], self.points[self.faces[face][2]], self.points[self.faces[face][3]]

		local bary_c = (src_c.x - src_a.x) * (src_b.y - src_a.y) - (src_b.x - src_a.x) * (src_c.y - src_a.y)
		local bary_0 = Vec2.normalVector(src_a,src_c):div(bary_c)
		local bary_1 = Vec2.normalVector(src_b,src_a):div(bary_c)

		local w_ratio = bounds.w / (u_width - 1)
		local h_ratio = bounds.h / (v_width - 1)

		local min_uv = Vec2(min_u,min_v)

		for i = 1, 4 do
			local uvTrans = self.uv[face][i] - min_uv

			uvTrans = Vec2(bounds.x + uvTrans.x * w_ratio, bounds.y + uvTrans.y * h_ratio)

			local w1 = Vec2.dot(uvTrans - src_a, bary_0)
			local w2 = Vec2.dot(uvTrans - src_a, bary_1)

			self.p[face][i] = Vec3(dst_a.x + w1 * (dst_b.x - dst_a.x) + w2 * (dst_c.x - dst_a.x),
			dst_a.y + w1 * (dst_b.y - dst_a.y) + w2 * (dst_c.y - dst_a.y),
			dst_a.z + w1 * (dst_b.z - dst_a.z) + w2 * (dst_c.z - dst_a.z),
			dst_a.w + w1 * (dst_b.w - dst_a.w) + w2 * (dst_c.w - dst_a.w))
			self.t[face][i] = uvTrans
		end

		local Color = Color

		--find the most common collor
		local pixelCount = {}
		local most_common_color = -1
		local most_common_count = -1

		min_u, min_v = bounds.x, bounds.y
		max_u, max_v = bounds.w + min_u , bounds.h + min_v

		u_width = max_u - min_u + 1
		v_width = max_v - min_v + 1

		for i = min_u, max_u - 1 do
			for j = min_v, max_v - 1 do
				if most_common_color ~= 0 then
					local c = texture:getPixel(i, j)
				
					
					if app.pixelColor.rgbaA(c) ~= 255 then
						most_common_color = 0
					elseif not pixelCount[c] then
						pixelCount[c] = 1
						if 1 > most_common_count then
							most_common_count = 1
							most_common_color = c
						end
					
					else
						pixelCount[c] = pixelCount[c] + 1
						if pixelCount[c] > most_common_count then
							most_common_count = pixelCount[c]
							most_common_color = c
						end
					end
				end
			end
		end

		local pixels = {c={},x={},y={},w={},h={},n=1,isOpaque=false}
		local visited = {}
		local index = 1
		local count = 0

		if most_common_color ~= 0 then
			count = count + 1
			pixels.c[count] = most_common_color
			pixels.x[count] = min_u
			pixels.y[count] = min_v
			pixels.w[count] = u_width-1
			pixels.h[count] = v_width-1
			pixels.isOpaque = true
		end

		for i = min_u, max_u - 1 do
			for j = min_v, max_v - 1 do
			if visited[index] == nil then
				local c = texture:getPixel(i, j)
				if c > 0 and c ~= most_common_color then
				visited[index] = true

				--compute extents
				--first vertically
				local face_w, face_h = 1, 1

				local index_below = index + face_h
				local next_col = texture:getPixel(i, j + face_h)
				while visited[index_below] == nil and next_col > 0 and (j + face_h <= max_v - 1) and (c == next_col) do
					face_h = face_h + 1
					visited[index_below] = true
					index_below = index + face_h
					next_col = texture:getPixel(i, j + face_h)
				end

				--then horizontally
				local can_grow = true
				while can_grow and (i + face_w) < max_u do
					for g = 0, face_h - 1 do
					next_col = texture:getPixel(i + face_w, j + g)
					if next_col then
						can_grow = can_grow and (next_col == c)
					else
						can_grow = false
					end
					end

					--if yes, update the values
					if can_grow then
					for g = 0, face_h - 1 do
						visited[index + g + face_w * v_width] = true
					end
					face_w = face_w + 1
					end
				end

				
				count = count + 1

				pixels.c[count] = c
				pixels.x[count] = i
				pixels.y[count] = j
				pixels.w[count] = face_w
				pixels.h[count] = face_h
				end
			end

			index = index + 1
			end
			index = index + 1
		end

		pixels.n = count

		self.pixelMeshes[face] = pixels
	end

end


return Cube