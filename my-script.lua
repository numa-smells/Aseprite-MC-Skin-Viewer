function init(plugin)
  -- print("Aseprite is initializing my plugin")

  -- -- we can use "plugin.preferences" as a table with fields for
  -- -- our plugin (these fields are saved between sessions)
  -- if plugin.preferences.count == nil then
  --   plugin.preferences.count = 0
  -- end

  plugin:newMenuSeparator{
    group="view_screen"
  }

  plugin:newCommand{
    id="MCSkinViewer",
    title="MC Skin Viewer",
    group="view_screen",
    onclick=function()
      PluginPath = plugin.path
      VERSION = plugin.version

      dofile(plugin.path..app.fs.pathSeparator.."mcskin-viewer.lua")
    end,
    onenabled=function()
        if not app.sprite then
            return false
        end

        if not (app.sprite.width%64 == 0 and app.sprite.height%32 == 0 and (app.sprite.width == app.sprite.height or app.sprite.width/app.sprite.height==2)) then
            return false
        end

        return true
    end
  }

  plugin:newMenuGroup{
    id="mcskin_utils",
    title="MC Skin Utilities",
    group="view_screen"
  }

  plugin:newCommand{
    id="MCSkinProfiler",
    title="MC Skin Profiler",
    group="mcskin_utils",
    onclick=function()
      PluginPath = plugin.path
      VERSION = plugin.version
      dofile(plugin.path..app.fs.pathSeparator.."mcskin-profiler.lua")
    end,
    onenabled=function()
        if not app.sprite then
            return false
        end

        if not (app.sprite.width%64 == 0 and app.sprite.height%32 == 0 and (app.sprite.width == app.sprite.height or app.sprite.width/app.sprite.height==2)) then
            return false
        end

        return true
    end
  }

  
end

function exit(plugin)
  -- print("Aseprite is closing my plugin, MyFirstCommand was called "
  --       .. plugin.preferences.count .. " times")
end