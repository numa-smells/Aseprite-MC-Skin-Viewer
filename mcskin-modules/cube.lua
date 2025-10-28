dofile("vec3.lua")
dofile("tex2.lua")


Cube = {}
Cube.__index = Cube

setmetatable(Cube, {
	__call = function(cls,...)
		return cls.new(...)
	end
})

function Cube:setUV(uvScaleMultiplier)
	local u = self.uvOrigin.u -- UV position X
	local v = self.uvOrigin.v -- UV position Y
	local wt = self.cubeSize.x 
	local ht = self.cubeSize.y
	local dt = self.cubeSize.z
	
	self.uv = {
		{ --FRONT
			Tex2((u+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+wt+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			Tex2((u+wt+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier)
		},
		{ -- LEFT
			Tex2((u+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			Tex2((u+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier)
		},
		{ --BACK
			Tex2((u+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+wt+dt+dt+wt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			Tex2((u+wt+dt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier)
		},
		{ --RIGHT
			Tex2(u*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2((u+dt)*uvScaleMultiplier, (v+ht+dt)*uvScaleMultiplier),
			Tex2(u*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			Tex2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier)
		},
		{ --BOTTOM
			Tex2((u+dt+wt)*uvScaleMultiplier, v*uvScaleMultiplier),
			Tex2((u+dt+wt+wt)*uvScaleMultiplier, v*uvScaleMultiplier),
			Tex2((u+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			Tex2((u+wt+dt+wt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier)
		},
		{ --TOP
			Tex2((u+wt+dt)*uvScaleMultiplier, v*uvScaleMultiplier),
			Tex2((u+dt)*uvScaleMultiplier, v*uvScaleMultiplier),
			Tex2((u+wt+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier),
			Tex2((u+dt)*uvScaleMultiplier, (v+dt)*uvScaleMultiplier)
		}
	}
	return self
end

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
		{1,2,3,4},	--FRONT
		{2,6,4,8},	--LEFT
		{6,5,8,7},	--BACK
		{5,1,7,3},	--RIGHT
		{5,6,1,2},	--BOTTOM
		{8,7,4,3}	 --TOP
	}

	local size = params.size or Vec3(1,1,1)
	inst.cubeSize = size -- used in UV recalculation
	local pos = params.pos or Vec3()
	local scaleMultiplier = params.scaleMultiplier or 1

	local uv = params.uv or Tex2()
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
	-- local uv = params.uv or Tex2()
	-- local inflate = params.inflate or 0
	-- local showBackface = params.showBackface or false
	-- local isVisible = params.isVisible or true

	return inst
end


return Cube