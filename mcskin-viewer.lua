-- MC SKIN VIEWER BY NUMA FOR ASEPRITE
-- DO NOT REUPLOAD THANKS

local FPS = 30

-- This script requires UI
if not app.isUIAvailable then
  return
end

if not app.sprite then
  app.alert("Please open on a valid sprite.")
  return
end

if not (app.sprite.width == 64 and app.sprite.height == 64) then
  app.alert("The sprite canvas must be 64 x 64")
  return
end

dofile("mcskin-modules/mcmodel.lua")

local model = MCModel.new()
--print(model)

local texture = Image(64,64)

local camera = {
  pos = Vec3(0,0,2.3),
  rot = Vec3()
}

local sprite = app.sprite
texture:drawSprite(sprite, app.frame.frameNumber)

model:auto_model(texture)

function getLocalFilename(sprite)
  local short_filename = ""
  for w in string.gmatch(sprite.filename, "([^"..app.fs.pathSeparator.."]+)") do
    short_filename = w
  end

  return short_filename
end


local modulePath = PluginPath..app.fs.pathSeparator.."mcskin-modules"..app.fs.pathSeparator
local mirror_map = Image{fromFile = modulePath ..app.fs.pathSeparator.. "mirrormap.png"}
local mirror_map_slim = Image{fromFile = modulePath ..app.fs.pathSeparator.. "mirrormap_slim.png"}

local dlg
local sin, cos = math.sin, math.cos
local repaint = function() end
local repaint_force = function() end
local texture_changed = function() end
local on_filenamechange = function() end

local fElapsedTime = 0.0
local timer = Timer{
  interval=1.0/FPS,
  ontick=function()
    fElapsedTime = fElapsedTime + 3 * 1.0/FPS

    local pose = dlg.data["pose"]

    if pose == "Stand" then
      model["arm_r_slim"].rot.x = sin(fElapsedTime) * 0.05 - 0.05
      model["arm_l_slim"].rot.x = -sin(fElapsedTime) * 0.05 + 0.05
      model["arm_r"].rot.x = sin(fElapsedTime) * 0.05 - 0.05
      model["arm_l"].rot.x = -sin(fElapsedTime) * 0.05 + 0.05

    elseif pose == "Walk" then
      model["arm_r_slim"].rot.z = sin(fElapsedTime) * 0.78
      model["arm_l_slim"].rot.z = -sin(fElapsedTime) * 0.78
      model["arm_r"].rot.z = sin(fElapsedTime) * 0.78
      model["arm_l"].rot.z = -sin(fElapsedTime) * 0.78

      model["leg_r"].rot.z = -sin(fElapsedTime) * 0.78
      model["leg_l"].rot.z = sin(fElapsedTime) * 0.7
    elseif pose == "Sit" then
      model["arm_r_slim"].rot.z = 0.62
      model["arm_l_slim"].rot.z = 0.62
      model["arm_r"].rot.z = 0.62
      model["arm_l"].rot.z = 0.62

      model["arm_r_slim"].rot.x = sin(fElapsedTime) * 0.05 - 0.05
      model["arm_l_slim"].rot.x = -sin(fElapsedTime) * 0.05 + 0.05
      model["arm_r"].rot.x = sin(fElapsedTime) * 0.05 - 0.05
      model["arm_l"].rot.x = -sin(fElapsedTime) * 0.05 + 0.05

      model["leg_r"].rot.z = 1.26
      model["leg_l"].rot.z = 1.26

      model["leg_r"].rot.x = -0.32
      model["leg_l"].rot.x = 0.32

      model["head"].rot.z = 0.09
    elseif pose == "Sneak" then
      model["body"].rot.z = -0.49
      model["head"].rot.z = -0.09

      model["head"].pos.y = -.5
      model["body"].pos.y = -.5

      model["arm_r_slim"].rot.z = sin(fElapsedTime/2) * 0.78
      model["arm_l_slim"].rot.z = -sin(fElapsedTime/2) * 0.78
      model["arm_r"].rot.z = sin(fElapsedTime/2) * 0.78
      model["arm_l"].rot.z = -sin(fElapsedTime/2) * 0.78

      model["arm_r_slim"].pos.y = -3/8
      model["arm_l_slim"].pos.y = -3/8
      model["arm_r"].pos.y = -3/8
      model["arm_l"].pos.y = -3/8

      model["leg_r"].rot.z = -sin(fElapsedTime/2) * 0.78
      model["leg_l"].rot.z = sin(fElapsedTime/2) * 0.7

      model["leg_r"].pos.z = .5
      model["leg_l"].pos.z = .5
    elseif pose == "Explode" then
      model["head"].pos.y = -10/8

      model["leg_r"].pos.y = 10/8
      model["leg_l"].pos.y = 10/8

      model["leg_r"].pos.x = -4/8
      model["leg_l"].pos.x = 4/8

      model["arm_r_slim"].pos.x = -9/8
      model["arm_l_slim"].pos.x = 9/8
      model["arm_r"].pos.x = -9/8
      model["arm_l"].pos.x = 9/8
    end

    repaint_force()
  end }


dlg = Dialog{
  title=getLocalFilename(sprite),
  onclose = function(ev)
    app.events:off(texture_changed)
    sprite.events:off(texture_changed)
    sprite.events:off(texture_changed)
    sprite.events:off(texture_changed)
    sprite.events:off(texture_changed)
    sprite.events:off(on_filenamechange)
    timer:stop()
  end
}

repaint_force = function()
  dlg:repaint()
end

repaint = function()
  if not timer.isRunning then
    repaint_force()
  end
end

on_filenamechange = function(ev)
 dlg:modify{title = getLocalFilename(sprite)} 
end

local curr_cell = Image(64, 64)
curr_cell:drawImage(app.cel.image, app.cel.position)
local last_cell = curr_cell:clone()

local curr_frame = app.frame.frameNumber
local curr_layer = app.layer.stackIndex

texture_changed = function(ev)
  if app.sprite == sprite and app.cel then
    if app.sprite.width == 64 and app.sprite.height == 64 then
      
      --make sure we are still on the same cell
      local last_frame = curr_frame
      curr_frame = app.frame.frameNumber

      local last_layer = curr_layer
      curr_layer = app.layer.stackIndex

    

      if dlg.data["toggle_mirror"] then  

        --if were mirroring
        last_cell = curr_cell:clone()
        curr_cell = Image(64, 64)
        curr_cell:drawImage(app.cel.image, app.cel.position)
          
        if last_frame ~= curr_frame or curr_layer ~= last_layer then
          last_cell = curr_cell:clone()
        end

        if (not ev.fromUndo) then
          

          for x=0, 63 do
            for y=0,63 do
              local a = Color(last_cell:getPixel(x,y))
              local b = Color(curr_cell:getPixel(x,y))

              if a.red ~= b.red or a.blue ~= b.blue or a.green ~= b.green or a.alpha ~= b.alpha then
                local c
                if model.isSlim then
                  c = Color(mirror_map_slim:getPixel(x,y))
                else
                  c = Color(mirror_map:getPixel(x,y))
                end

                curr_cell:drawPixel(c.red/4,c.green/4,b)
              end
            end
          end

          app.cel.image = curr_cell:clone()
          app.cel.position = Point(0,0)
        end
      end
      app.refresh() 
      texture:drawSprite(sprite, app.frame.frameNumber, Point(0,0))

      if dlg.data["model_type"] == "Auto" then
        model:auto_model(texture)
      end
    end
  end

  repaint()
end

sprite.events:on('change', texture_changed)
sprite.events:on('layerblendmode', texture_changed)
sprite.events:on('layeropacity', texture_changed)
sprite.events:on('layervisibility', texture_changed)
app.events:on('sitechange', texture_changed)
sprite.events:on('filenamechange', on_filenamechange)

function onpaint(ev)
  local gc = ev.context

  
  model:draw(texture, camera, gc,dlg.data["light_dir"])
  --gc:drawImage(last_cell, 0 ,0, 64, 64, 0, 0, 128, 128)
end

local mouse = Point(0, 0)
--local cw_offset = 0
local ch_offset = 0

function onmousemove(ev)
  local delta = Point(ev.x - mouse.x, ev.y - mouse.y)

  mouse = Point(ev.x, ev.y)
  
  if ev.button == MouseButton.LEFT then
    camera.rot.y = camera.rot.y + delta.x/40
    camera.rot.z = camera.rot.z - delta.y/40
    repaint()
  elseif ev.button == MouseButton.RIGHT then
    local d = dlg.bounds
    --local cw = d.width - cw_offset 
    local ch = d.height - ch_offset

    local zoom_offset = math.exp(camera.pos.z) / 600 * 360 / ch

    camera.pos.x = camera.pos.x + delta.x * zoom_offset
    camera.pos.y = camera.pos.y + delta.y * zoom_offset

    repaint()
  end
end

function onwheel(ev)
  camera.pos.z = math.max(camera.pos.z + 0.1 * ev.deltaY,0)
  repaint()
end

dlg:canvas{
  autoscaling=true, 
  width = 320,
  height = 320,
  focus = false,
  onpaint = onpaint,
  onmousemove = onmousemove, 
  onwheel = onwheel,
}

dlg:tab{
  id="pose_tab",
  text="Pose"
}

-- TODO:

dlg:label{text="Pose"}
dlg:combobox{
  id="pose",
  option="Stand",
  options={"Stand", "Walk", "Sneak", "Sit", "Explode"},
  onchange = function()
    timer:start()
    model:reset_pose()
  end
}

dlg:button{
  id="reset",
  text="Reset",
  onclick = function()
    camera = {
      pos = Vec3(0,0,2.3),
      rot = Vec3()
    }
    fElapsedTime = 0
    model:reset_pose()
    repaint()
  end
}

dlg:button{
  id="play",
  text="Play/Pause",
  onclick = function()
    if timer.isRunning then
      timer:stop()
    else
      timer:start()
    end
  end
}

dlg:label{text="Align View"}
dlg:button{
  id="top",
  text="Top",
  onclick = function()
    camera = {
      rot = Vec3(0,0,-math.pi/2),
      pos = Vec3(0,0,2.3)
    }
    repaint()
  end
}

dlg:button{
  id="back",
  text="Back",
  onclick = function()
    camera = {
      rot = Vec3(0,math.pi,0),
      pos = Vec3(0,0,2.3)
    }
    repaint()
  end
}

dlg:button{
  id="bottom",
  text="Bottom",
  onclick = function()
    camera = {
      rot = Vec3(0,0,math.pi/2),
      pos = Vec3(0,0,2.3)
    }
    repaint()
  end
}

dlg:newrow()

dlg:button{
  id="left",
  text="Left",
  onclick = function()
    camera = {
      rot = Vec3(0,math.pi/2,0),
      pos = Vec3(0,0,2.3)
      
    }
    repaint()
  end
}

dlg:button{
  id="front",
  text="Front",
  onclick = function()
    camera = {
      rot = Vec3(0,0,0),
      pos = Vec3(0,0,2.3)
    }
    repaint()
  end
}


dlg:button{
  id="right",
  text="Right",
  onclick = function()
    camera = {
      rot = Vec3(0,-math.pi/2,0),
      pos = Vec3(0,0,2.3)
    }
    repaint()
  end
}


dlg:tab{
  id="model_tab",
  text="Model"
}

dlg:label{text="Model Type"}
dlg:combobox{
  id="model_type",
  option="Auto",
  options={"Auto", "Classic", "Slim"},
  onchange = function(ev)
    local result = dlg.data["model_type"]

    if result == "Classic" then
      model:classic_model()
      repaint()
      return
    end

    if result == "Slim" then
      model:slim_model()
      repaint()
      return
    end

    if result == "Auto" then
      model:auto_model(texture)
      repaint()
      return
    end
  end
}

-- TODO:
-- this is insane, please rewrite to be more dynamic
-- also !! should be able to toggle visibility for non-jacket too :>

function update_toggle_overlay()
  local overlay_toggles = {"toggle_hat", "toggle_jacket", "toggle_sleeve_r", "toggle_sleeve_l", "toggle_pants_r", "toggle_pants_l"}
  local visible = false

  for _,v in ipairs(overlay_toggles) do
    if dlg.data[v] == true then
      dlg:modify{id="toggle_overlay", selected = true}
      return
    end
  end
  
  dlg:modify{id="toggle_overlay", selected = false}
end

dlg:check{
  id="toggle_overlay",
  text="Toggle Overlay Layers",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_overlay"]

    dlg:modify{id="toggle_hat", selected = res}
    dlg:modify{id="toggle_jacket", selected = res}
    dlg:modify{id="toggle_sleeve_r", selected = res}
    dlg:modify{id="toggle_sleeve_l", selected = res}
    dlg:modify{id="toggle_pants_r", selected = res}
    dlg:modify{id="toggle_pants_l", selected = res}

    model:cube_visibility("hat", res)
    model:cube_visibility("jacket", res)
    model:cube_visibility("sleeve_r", res)
    model:cube_visibility("sleeve_l", res)
    model:cube_visibility("pants_r", res)
    model:cube_visibility("pants_l", res)

    repaint()
  end
}

dlg:newrow()

dlg:check{
  id="toggle_hat",
  text="••• Hat",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_hat"]
    model:cube_visibility("hat", res)
    update_toggle_overlay()
    repaint()
  end
}

dlg:newrow()

dlg:check{
  id="toggle_jacket",
  text="••• Jacket",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_jacket"]
    model:cube_visibility("jacket", res)
    update_toggle_overlay()
    repaint()
  end
}

dlg:newrow()

dlg:check{
  id="toggle_sleeve_r",
  text="••• Sleeve R",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_sleeve_r"]
    model:cube_visibility("sleeve_r", res)
    update_toggle_overlay()
    repaint()
  end
}

dlg:check{
  id="toggle_sleeve_l",
  text="••• Sleeve L",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_sleeve_l"]
    model:cube_visibility("sleeve_l", res)
    update_toggle_overlay()
    repaint()
  end
}

dlg:newrow()

dlg:check{
  id="toggle_pants_r",
  text="••• Pants R",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_pants_r"]
    model:cube_visibility("pants_r", res)
    update_toggle_overlay()
    repaint()
  end
}

dlg:check{
  id="toggle_pants_l",
  text="••• Pants L",
  selected=true,
  onclick = function()
    local res = dlg.data["toggle_pants_l"]
    model:cube_visibility("pants_l", res)
    update_toggle_overlay()
    repaint()
  end
}

dlg:newrow()

dlg:tab{
  id="edit_tab",
  text="Edit"
}

dlg:check{
  id="toggle_mirror",
  text="Mirror Draw",
  selected=false,
  onclick = function()
    if app.sprite == sprite and app.cel then
      if app.sprite.width == 64 and app.sprite.height == 64 then

        last_cell = curr_cell:clone()
        curr_cell = Image(64, 64)
        curr_cell:drawImage(app.cel.image, app.cel.position)
      end
    end
  end
}

--TODO: MAKE THIS WORK

dlg:label{text="Copy From"}

function removeFirst(tbl, val)
  for i, v in ipairs(tbl) do
    if v == val then
      return table.remove(tbl, i)
    end
  end
end

dlg:combobox{
  id = "copy_from",
  option = "-",
  options = {"-","Head","Hat", "Body", "Jacket", "Arm R", "Sleeve R", "Arm L", "Sleeve L", "Leg R", "Pants R", "Leg L", "Pants L"},
  onchange = function()
    --update paste_to
    local res = dlg.data["copy_from"]
    

    if res == "-" then
      dlg:modify{id = "paste_to", option = "-", options = {"-"}, enabled = false}
    else
      local options_set = {"-","Head","Hat", "Body", "Jacket", "Arm R", "Sleeve R", "Arm L", "Sleeve L", "Leg R", "Pants R", "Leg L", "Pants L"}
      
      --removeFirst(options_set, res)
      
      dlg:modify{id = "paste_to", option = "-", options = options_set, enabled = true}
    end

    dlg:modify{id = "copy_confirm", enabled = false}
    dlg:modify{id = "flip_confirm", enabled = true}

    --todo update model to show highlights
  end
}

dlg:label{text="Paste To"}

dlg:combobox{
  id = "paste_to",
  option = "-",
  options = {"-"},
  enabled = false,
  onchange = function()
    local res = dlg.data["paste_to"]
    --TODO update model to show highlights

    --unlock button
    dlg:modify{id = "copy_confirm", enabled = (res ~= "-") }
  end
}

function title_to_camel(s)
  return s:gsub("%s+", "_"):lower()
end

dlg:button{
  id="copy_confirm",
  text = "Copy",
  enabled = false,
  onclick = function()
    --TODO: do the copy
    app.transaction(
      function()
        

        local cube_from = model:get_cube(title_to_camel(dlg.data["copy_from"]))
        local cube_to = model:get_cube(title_to_camel(dlg.data["paste_to"]))
        
        curr_cell = Image(64, 64)
        curr_cell:drawImage(app.cel.image, app.cel.position)
        
        for i=1, 6 do
          local uv_a = cube_from.uv[i]
          local uv_b = cube_to.uv[i]

          local a_min_u = math.min(uv_a[1].u,uv_a[2].u,uv_a[3].u,uv_a[4].u)
          local a_min_v = math.min(uv_a[1].v,uv_a[2].v,uv_a[3].v,uv_a[4].v)

          local a_max_u = math.max(uv_a[1].u,uv_a[2].u,uv_a[3].u,uv_a[4].u)
          local a_max_v = math.max(uv_a[1].v,uv_a[2].v,uv_a[3].v,uv_a[4].v)

          local b_min_u = math.min(uv_b[1].u,uv_b[2].u,uv_b[3].u,uv_b[4].u)
          local b_min_v = math.min(uv_b[1].v,uv_b[2].v,uv_b[3].v,uv_b[4].v)

          local b_max_u = math.max(uv_b[1].u,uv_b[2].u,uv_b[3].u,uv_b[4].u)
          local b_max_v = math.max(uv_b[1].v,uv_b[2].v,uv_b[3].v,uv_b[4].v)

          local a_rect = Rectangle(a_min_u,a_min_v,a_max_u-a_min_u,a_max_v-a_min_v)
          local b_rect = Rectangle(b_min_u,b_min_v,b_max_u-b_min_u,b_max_v-b_min_v)

          local face_tex = Image(curr_cell, a_rect)

          face_tex:resize{width = b_rect.width, height = b_rect.height}

          curr_cell:drawImage(face_tex, Point(b_rect.x,b_rect.y))

        end

        app.cel.image = curr_cell:clone()
        app.cel.position = Point(0,0)
      end)

    --then reset the combo-boxes
    dlg:modify{id = "copy_from", option = "-"}
    dlg:modify{id = "paste_to", option = "-", options = {"-"}, enabled = false}
    dlg:modify{id = "copy_confirm", enabled = false}
    dlg:modify{id = "flip_confirm", enabled = false}
  end
}

dlg:button{
  id="flip_confirm",
  text = "Flip",
  enabled = false,
  onclick = function()
    --TODO: do the copy
    local has_target = true

    app.transaction(
      function()
        local cube_from = model:get_cube(title_to_camel(dlg.data["copy_from"]))
        local cube_to = model:get_cube(title_to_camel(dlg.data["paste_to"]))
        
        if not cube_to then
          cube_to = cube_from
          has_target = false
        end

        curr_cell = Image(64, 64)
        curr_cell:drawImage(app.cel.image, app.cel.position)

        local cell_copy = Image(curr_cell)
        
        local flip_order = {1,4,3,2,5,6}

        for i=1, 6 do
          local uv_a = cube_from.uv[i]
          local uv_b = cube_to.uv[flip_order[i]]

          local a_min_u = math.min(uv_a[1].u,uv_a[2].u,uv_a[3].u,uv_a[4].u)
          local a_min_v = math.min(uv_a[1].v,uv_a[2].v,uv_a[3].v,uv_a[4].v)

          local a_max_u = math.max(uv_a[1].u,uv_a[2].u,uv_a[3].u,uv_a[4].u)
          local a_max_v = math.max(uv_a[1].v,uv_a[2].v,uv_a[3].v,uv_a[4].v)

          local b_min_u = math.min(uv_b[1].u,uv_b[2].u,uv_b[3].u,uv_b[4].u)
          local b_min_v = math.min(uv_b[1].v,uv_b[2].v,uv_b[3].v,uv_b[4].v)

          local b_max_u = math.max(uv_b[1].u,uv_b[2].u,uv_b[3].u,uv_b[4].u)
          local b_max_v = math.max(uv_b[1].v,uv_b[2].v,uv_b[3].v,uv_b[4].v)

          local a_rect = Rectangle(a_min_u,a_min_v,a_max_u-a_min_u,a_max_v-a_min_v)
          local b_rect = Rectangle(b_min_u,b_min_v,b_max_u-b_min_u,b_max_v-b_min_v)

          local face_tex = Image(cell_copy, a_rect)

          face_tex:resize{width = b_rect.width, height = b_rect.height}
          face_tex:flip()
          curr_cell:drawImage(face_tex, Point(b_rect.x,b_rect.y))

        end
        app.cel.image = curr_cell:clone()
        app.cel.position = Point(0,0)
      end)

    --then reset the combo-boxes
    if has_target then
      dlg:modify{id = "copy_from", option = "-"}
      dlg:modify{id = "paste_to", option = "-", options = {"-"}, enabled = false}
      dlg:modify{id = "copy_confirm", enabled = false}
      dlg:modify{id = "flip_confirm", enabled = false}
    end
  end
}

dlg:tab{
  id="export_tab",
  text="Export"
}

dlg:label{text="Light Direction"}

dlg:combobox{
  id = "light_dir",
  option = "Front",
  options = {"Front","Top","None"},
  onchange = function()
    repaint()
  end
}

dlg:label{text="Background Color"}

dlg:color{id = "bg_color", color=Color{gray=64, alpha=255}}
dlg:button{
  id="export_preview",
  text = "Export Preview",
  onclick = function()
    model:reset_pose()
    fElapsedTime = -math.pi/6

    model["arm_r_slim"].rot.z = sin(fElapsedTime) * 0.78
    model["arm_l_slim"].rot.z = -sin(fElapsedTime) * 0.78
    model["arm_r"].rot.z = sin(fElapsedTime) * 0.78
    model["arm_l"].rot.z = -sin(fElapsedTime) * 0.78

    model["leg_r"].rot.z = -sin(fElapsedTime) * 0.78
    model["leg_l"].rot.z = sin(fElapsedTime) * 0.7

    local export_camera = {pos = Vec3(0,0,2.5), rot=Vec3(0,0.5,-0.2)}
    local exportImage1 = Image(960,1080)

    model:draw(texture, export_camera, exportImage1.context,dlg.data["light_dir"])

    export_camera = {pos = Vec3(0,0,2.5), rot=Vec3(0,math.pi+0.5,-0.2)}
    local exportImage2 = Image(960,1080)
    model:draw(texture, export_camera, exportImage2.context,dlg.data["light_dir"])

    local finalImage = Image(1920,1080)

    local gc = finalImage.context
    gc.color = dlg.data["bg_color"]
    
    gc:beginPath()
    gc:moveTo(0, 0)
    gc:lineTo(1920, 0)
    gc:lineTo(1920, 1080)
    gc:lineTo(0, 1080)
    
    gc:closePath()
    gc:fill()

    gc.color = Color{gray=255, alpha=255}
    
    gc:drawImage(exportImage1, 200,0)
    gc:drawImage(exportImage2, 760,0)

    finalImage:saveAs("mcskin-export.aseprite")
    local sprite = Sprite{fromFile="mcskin-export.aseprite"}

    dlg:close()
  end
}



dlg:endtabs{
  align = Align.LEFT

}

dlg:separator{id="ver", text="MC-Skin Viewer v".. tostring(VERSION) .." by @numa_smells"}

dlg:show{wait=false}
timer:start()

--cw_offset = dlg.bounds.width - 360 
ch_offset = dlg.bounds.height - 360