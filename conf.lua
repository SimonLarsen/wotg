function love.conf(t)
    t.identity = "dk.tangramgames.wotg"
    t.version = "0.10.0"
    t.console = false
    t.accelerometerjoystick = false
    t.gammacorrect = false
 
    t.window.title = "Witch of the Grove"
    t.window.icon = nil
    t.window.width = 240*4
    t.window.height = 160*4
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 1
    t.window.minheight = 1
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = true
    t.window.fsaa = 0
    t.window.display = 1
    t.window.highdpi = false
    t.window.x = nil
    t.window.y = nil
 
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.video = false
    t.modules.window = true
    t.modules.thread = true
end
