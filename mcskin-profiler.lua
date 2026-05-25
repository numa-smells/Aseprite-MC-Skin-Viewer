-- PROFILE RENDERING
-- DO NOT REUPLOAD THANKS

-- This script requires UI
if not app.isUIAvailable then
	return
end
--version requirement
if app.apiVersion < 35 then
	app.alert("Warning: This extention is designed to work on Aseprite v1.3.15 or newer. Some functions may not be available nor work as expected.")
end
-- checking for sprite
if not app.sprite then
	app.alert("Please open on a valid sprite.")
	return
end

local spriteScaleMultiplier = 1
if not (app.sprite.width%64 == 0 and app.sprite.height%32 == 0 and (app.sprite.width == app.sprite.height or app.sprite.width/app.sprite.height==2)) then -- checks if this sprite is a multiple of 64 (i.e. 128, 256, etc etc)
	app.alert("The sprite canvas must be a multiple of 64 x 64 or 64 x 32")
	return
else
	spriteScaleMultiplier = app.sprite.width/64 -- if it's 64 x 64, scale multiplier will be 1. higher, it'll be 2, 3, etc
end

local TARGET_FPS = 24
--load model handler
local MCModelHandler = dofile("mcskin-modules"..app.fs.pathSeparator.."modelhandler.lua")
local modelHandler = MCModelHandler.new()
modelHandler:setScale(spriteScaleMultiplier)


local showDebug = false
local AA = true
local tools_visible = true

local camera = {
	pos = Vec3(0,0,2.3),
	rot = Vec3()
}

local curr_sprite = app.sprite
local texture = Image(64*spriteScaleMultiplier, 64*spriteScaleMultiplier, curr_sprite.colorMode)

texture:drawSprite(curr_sprite, app.frame.frameNumber)

modelHandler:auto_model(texture) -- set model first
modelHandler.current:updateTexture(texture) --then update texture
local function getLocalFilename(sprite)
	local short_filename = ""
	for w in string.gmatch(sprite.filename, "([^"..app.fs.pathSeparator.."]+)") do
		short_filename = w
	end

	return short_filename
end

TARGET_FPS = 24
local modulePath = PluginPath..app.fs.pathSeparator.."mcskin-modules"..app.fs.pathSeparator

local dlg
local sin, cos = math.sin, math.cos
local rnd = function() return math.random(-math.pi,math.pi) end

local fElapsedTime = 0.0



local profile_times_total = {0, 0, 0, 0}
local times = {}

local function onpaint(ev)
    --randomize rotation and pose 

    --do test
	local gc = ev.context


    local startTime = os.clock()

    local depth, count, true_count = modelHandler.current:draw(camera, gc, "Top", AA)

    local endTime = os.clock()
    
    local upper_bound =true_count +  2 * true_count * math.log(true_count,10)



    profile_times_total[1] = profile_times_total[1] + endTime - startTime
    profile_times_total[2] = profile_times_total[2] + depth
    profile_times_total[3] = profile_times_total[3] + count 
    profile_times_total[4] = profile_times_total[4] + upper_bound

    times[#times+1] = endTime - startTime
    
    gc.strokeWidth = 2
    gc.color = Color{gray=128}

    gc:beginPath()
    gc:moveTo(0,320-(1/TARGET_FPS)*2000)
    gc:lineTo(320,320-(1/TARGET_FPS)*2000)
    gc:stroke()

    gc:beginPath()
    gc:moveTo(0,320-(1/TARGET_FPS/2)*2000)
    gc:lineTo(320,320-(1/TARGET_FPS/2)*2000)
    gc:stroke()

    gc.color = Color{gray=255}

    gc:fillText("Total: "..string.sub(tostring(#times/profile_times_total[1]), 1,5), 8, 0)
    gc:fillText("Max-Depth: "..string.sub(tostring(profile_times_total[2]/#times), 1,5), 8, 24)
    gc:fillText("#+Poly: "..string.sub(tostring(profile_times_total[3]/#times),1,5).." ("..string.sub(tostring(profile_times_total[3]/profile_times_total[4]*100),1,5).."%)", 8, 48)
    gc:beginPath()
    gc:moveTo(0,320-times[1]*2000)
    for i=2,#times do
        gc:lineTo(320.0*i/#times,320-times[i]*2000)
    end
    gc:stroke()

    gc.color = Color{red=255,g=0,b=0,a=128}

    gc:beginPath()
    gc:moveTo(0,320-(profile_times_total[1]/#times)*2000)
    gc:lineTo(320,320-(profile_times_total[1]/#times)*2000)
    gc:stroke()


    
end

local pi = math.pi
local step = 2*math.pi/10

local timer = Timer{
    interval = 1.0/TARGET_FPS,
    ontick = function()
        for key, part in pairs(modelHandler.current) do
            part.rot = Vec3(rnd(),rnd(),rnd())
        end

        if camera.rot.z <= pi*2 then
            if camera.rot.y <= pi*2 then
                dlg:repaint()
                camera.rot.y = camera.rot.y + step
            else
                camera.rot.y = 0
                camera.rot.z = camera.rot.z + step
            end
        end
    end
}

local function test()
    math.randomseed(411)
    
    
    profile_times_total = {0, 0, 0, 0}
    times = {}
    camera.rot.z = 0
    camera.rot.y = 0

    timer:start()
end

dlg = Dialog{
	title=getLocalFilename(curr_sprite),
	autofit = Align.TOP,
    onclose = function(ev)
		timer:stop()
    end
}

dlg:canvas{
	id = 'canvas',
	autoscaling=true, 
	width = 320,
	height = 320,
	focus = false,
	onpaint = onpaint,
}

dlg:button{
    text = "run",
    onclick = test
}

dlg:show{}


