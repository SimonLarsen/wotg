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
Scene = require("Scene")
Entity = require("Entity")
Resources = require("Resources")
BoxCollider = require("BoxCollider")
Score = require("Score")

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	love.graphics.setLineStyle("rough")

	Resources.initialize()

	local w, h = love.window.getDesktopDimensions()
	Screen.SCALE = math.floor(h / Screen.HEIGHT)
	love.window.setMode(Screen.WIDTH*Screen.SCALE, Screen.HEIGHT*Screen.SCALE)

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

function love.run()
	love.math.setRandomSeed(os.time())
	for i=1,3 do love.math.random() end

	love.event.pump()

	love.load(arg)

	love.timer.step()
	local acc = 0
	local dt = 1/60

	local canvas_x = 0
	local canvas_y = 0
	local canvas_scale = 1

	local scale_keys = {"f1","f2","f3","f4","f5","f6"}

	-- Create root canvas
	local canvas = love.graphics.newCanvas(Screen.WIDTH, Screen.HEIGHT)

	-- Main loop time.
	while true do
		-- Update dt, as we'll be passing it to update
		love.timer.step()
		acc = acc + love.timer.getDelta()

		-- Call update and draw
		while acc > dt do
			-- Process events.
			love.event.pump()
			for e,a,b,c,d in love.event.poll() do
				if e == "quit" then
					if not love.quit or not love.quit() then
						if love.audio then
							love.audio.stop()
						end
						return
					end
				end
				love.handlers[e](a,b,c,d)
			end

			-- change screen size
			for i,v in ipairs(scale_keys) do
				if Keyboard.wasPressed(v) then
					Screen.SCALE = i
					if not Screen.FULLSCREEN then
						love.window.setMode(Screen.WIDTH*Screen.SCALE, Screen.HEIGHT*Screen.SCALE, {fullscreen = false})
					end
				end
			end

			-- toggle fullscreen
			if Keyboard.wasPressed("f11")
			or ((Keyboard.isDown("lalt") or Keyboard.isDown("ralt")) and Keyboard.wasPressed("return", true)) then
				Screen.FULLSCREEN = not Screen.FULLSCREEN
				if Screen.FULLSCREEN then
					local w, h = love.window.getDesktopDimensions()
					love.window.setMode(w, h, {fullscreen = true})

					canvas_scale = h/Screen.HEIGHT
					canvas_x = math.floor((w - Screen.WIDTH*canvas_scale)/2)
					canvas_y = 0
				else
					love.window.setMode(Screen.WIDTH*Screen.SCALE, Screen.HEIGHT*Screen.SCALE, {fullscreen = false})
					canvas_scale = 1
					canvas_x, canvas_y = 0, 0
				end
			end

			acc = acc - dt
			love.update(dt)

			Keyboard.clear()
		end

		if love.window.isCreated() then
			love.graphics.clear()
			love.graphics.origin()

			canvas:clear(gamestate.current():getBackgroundColor())
			love.graphics.setCanvas(canvas)

			love.draw()
			love.gui()

			if not Screen.FULLSCREEN then
				love.graphics.scale(Screen.SCALE, Screen.SCALE)
			end
			love.graphics.setCanvas()
			love.graphics.draw(canvas, canvas_x, canvas_y, 0, canvas_scale, canvas_scale)

			love.graphics.present()
		end

		love.timer.sleep(0.001)
	end
end
