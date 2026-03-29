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
if not (app.sprite.width%64 == 0 and app.sprite.height%64 == 0 and app.sprite.width == app.sprite.height) then -- checks if this sprite is a multiple of 64 (i.e. 128, 256, etc etc)
	app.alert("The sprite canvas must be a multiple of 64 x 64")
	return
else
	spriteScaleMultiplier = app.sprite.width/64 -- if it's 64 x 64, scale multiplier will be 1. higher, it'll be 2, 3, etc
end

dofile("mcskin-modules"..app.fs.pathSeparator.."mcmodel.lua")

local model = MCModel.new(spriteScaleMultiplier)
--print(model)

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

model:auto_model(texture)

local function getLocalFilename(sprite)
	local short_filename = ""
	for w in string.gmatch(sprite.filename, "([^"..app.fs.pathSeparator.."]+)") do
		short_filename = w
	end

	return short_filename
end

TARGET_FPS = 30
local modulePath = PluginPath..app.fs.pathSeparator.."mcskin-modules"..app.fs.pathSeparator

local dlg
local sin, cos = math.sin, math.cos
local rnd = function() return math.random(-math.pi,math.pi) end

local fElapsedTime = 0.0




local curr_cell = Image(64*spriteScaleMultiplier, 64*spriteScaleMultiplier)
local curr_mode
if app.cel then
	curr_cell:drawImage(app.cel.image, app.cel.position)
	curr_mode = app.image.colorMode
end
local last_cell = curr_cell:clone()

local curr_frame = app.frame.frameNumber
local curr_layer = app.layer.stackIndex


local profile_times_total = {0,0,0}
local times = {}

local function onpaint(ev)
    --randomize rotation and pose 

    --do test
	local gc = ev.context


    local startTime = os.clock()
	local profile_times = model:draw_profile(texture, camera, gc, "Top", AA)

	gc.color = gc.theme.color.text

    --log times
    times[#times + 1] = {} 
    times[#times][1] = profile_times[1] - startTime
    times[#times][2] = profile_times[2] - startTime
    times[#times][3] = profile_times[3] - startTime

    profile_times_total[1] = profile_times_total[1] + profile_times[1] - startTime

    for i=2,3 do
        profile_times_total[i] = profile_times_total[i] + profile_times[i] - profile_times[i-1]
        
    end

    gc.strokeWidth = 2
    
    gc.color = Color{r=255,g=0,b=0,a=128}

    gc:fillText("Project: "..string.sub(tostring(profile_times_total[1]), 1,5), 8, 0)
    gc:beginPath()
    gc:moveTo(0,320-times[1][1]*2000)
    for i=2,#times do
        gc:lineTo(320.0*i/#times,320-times[i][1]*2000)
    end
    gc:stroke()

    gc.color = Color{r=0,g=255,b=0,a=128}

    gc:fillText("Sort:      "..string.sub(tostring(profile_times_total[2]), 1,5), 8, 16)
    gc:beginPath()
    gc:moveTo(0,320-times[1][2]*2000)
    for i=2,#times do
        gc:lineTo(320.0*i/#times,320-times[i][2]*2000)
    end
    gc:stroke()

    gc.color = Color{r=0,g=0,b=255,a=128}

    gc:fillText("Render: "..string.sub(tostring(profile_times_total[3]), 1,5), 8, 32)
    gc:beginPath()
    gc:moveTo(0,320-times[1][3]*2000)
    for i=2,#times do
        gc:lineTo(320.0*i/#times,320-times[i][3]*2000)
    end
    gc:stroke()
end

local pi = math.pi
local step = 2*math.pi/10
local timer = Timer{
    interval = 1.0/30,
    ontick = function()
        if camera.rot.z <= pi then
            if camera.rot.y <= pi then
                dlg:repaint()
                camera.rot.y = camera.rot.y + step
            else
                camera.rot.y = -pi
                camera.rot.z = camera.rot.z + step
            end
        end
    end
}

function test()
    for key, part in pairs(model) do
        if type(part) == "table" then
            part.rot = Vec3(rnd(),rnd(),rnd())
        end
    end

    profile_times_total = {0, 0, 0}
    times = {}
    camera.rot.z = -pi
    camera.rot.y = -pi

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

dlg:show{wait=false}


