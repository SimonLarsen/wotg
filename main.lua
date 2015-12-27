require("slam.slam")
require("mymath")
class = require("middleclass.middleclass")
gamestate = require("hump.gamestate")
timer = require("hump.timer")
tween = require("tween.tween")

Serial = require("Serial")
Animation = require("animation.Animation")
Animator = require("animation.Animator")
Screen = require("Screen")
Keyboard = require("input.Keyboard")
Joystick = require("input.Joystick")
Scene = require("Scene")
Entity = require("Entity")
Resources = require("Resources")
BoxCollider = require("BoxCollider")
Score = require("Score")

local canvas
local canvas_buffer
local canvas_x, canvas_y
local canvas_scale
local resized = 0

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	love.graphics.setLineStyle("rough")

	canvas = love.graphics.newCanvas(Screen.WIDTH, Screen.HEIGHT)
	canvas_buffer = love.graphics.newCanvas(Screen.WIDTH, Screen.HEIGHT)

	canvas_x = 0
	canvas_y = 0
	canvas_scale = 1

	Resources.initialize()
	Keyboard.initialize()
	Joystick.initialize()

	local w, h = love.window.getDesktopDimensions()
	Screen.SCALE = math.floor(h / Screen.HEIGHT)
	love.window.setMode(Screen.WIDTH*Screen.SCALE, Screen.HEIGHT*Screen.SCALE, {fullscreen=false})

	gamestate.registerEvents()
	gamestate.switch(require("title.TitleScene")())
end

function love.gui()
	gamestate.current():gui()
end

function love.keypressed(k)
	Keyboard.keypressed(k)
end

function love.keyreleased(k)
	Keyboard.keyreleased(k)
end

function love.gamepadpressed(joystick, button)
	Joystick.keypressed(joystick:getID(), button)
end

function love.gamepadreleased(joystick, button)
	Joystick.keyreleased(joystick:getID(), button)
end

function drawFullscreenShader(shader)
	love.graphics.setCanvas(canvas_buffer)
	love.graphics.clear(0, 0, 0, 0)
	love.graphics.setShader(shader)
	love.graphics.draw(canvas, 0, 0)

	love.graphics.setShader()
	canvas, canvas_buffer = canvas_buffer, canvas
end

function love.run()
	love.math.setRandomSeed(os.time())
 
	love.load(arg)
	love.timer.step()
 
	local acc = 0
	local dt = 1/60

	while true do
		love.timer.step()
		acc = acc + love.timer.getDelta()
		while acc > dt do
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end

			if Keyboard.wasPressed("f11")
			or ((Keyboard.isDown("lalt") or Keyboard.isDown("ralt"))
			and Keyboard.wasPressed("return", true)) then
				Screen.FULLSCREEN = not Screen.FULLSCREEN
				if Screen.FULLSCREEN then
					local w, h = love.window.getDesktopDimensions()
					love.window.setMode(w, h, {fullscreen = true})
					canvas_scale = h/Screen.HEIGHT
					canvas_x = math.floor((w - Screen.WIDTH*canvas_scale)/2)
					canvas_y = 0
				else
					love.window.setMode(Screen.WIDTH*Screen.SCALE, Screen.HEIGHT*Screen.SCALE, {fullscreen=false})
					canvas_scale = 1
					canvas_x, canvas_y = 0, 0
				end
			end
 
			acc = acc - dt
			love.update(dt)
			
			Keyboard.clear()
			Joystick.clear()
		end
	 
		love.graphics.origin()

		love.graphics.clear()
		love.graphics.setCanvas(canvas)
		love.graphics.clear(love.graphics.getBackgroundColor())

		love.draw()
		love.gui()

		love.graphics.setCanvas()
		love.graphics.push()
		if not Screen.FULLSCREEN then
			love.graphics.scale(Screen.SCALE, Screen.SCALE)
		end
		love.graphics.draw(canvas, canvas_x, canvas_y, 0, canvas_scale, canvas_scale)
		love.graphics.pop()

		love.graphics.present()
		love.timer.sleep(0.001)
	end
end
