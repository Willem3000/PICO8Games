pico-8 cartridge // http://www.pico-8.com
version 32
__lua__

function _init()
	poke(0x5f2d, 1)
	mx = stat(32)
	my = stat(33)
	
	dots = {}
	
	dotmap = {}
	for x=0,129 do
		clmn = {}
		for y=0,128 do
			add(clmn, nil)
		end
		add(dotmap,clmn)
	end
	
	clstrs = {}
	wind = 0.2
	slct = 0
	elmnt = "blck"
	canplace = false
	
	elmnts = {
	"blck",
	"c4",
	"gas",
	"wood",
	"smke",
	"vapr",
	"ice",
	"fire",
	"lava",
	"sand",
	"leaf",
	"watr",
	"iron",
	"acid",
	}
end

function _update()
	prevmx = mx
	prevmy = my
	mx = stat(32)
	my = stat(33)
	
	if (my < 15) then
		if(stat(34)==1) then
			slct = (abs((sgn(6 - my) - 1)) * 3.5) + flr(mx / 17 - 0.2353) % 7
			elmnt = elmnts[slct + 1]
		end
	elseif (my < 128 and mx > 1 and mx < 128) then
		
		if(stat(34)==1) then
			if (prevmx == mx and prevmy == my) then
				if(dotmap[mx][my]==nil) then
					spwn(mx,my)
				end
			else
				cls()
				line(mx, my, prevmx, prevmy, 7)
				for x=prevmx,mx,sgn(mx-prevmx) do
					for y=prevmy,my,sgn(my-prevmy) do
						if (x > 0 and x < 128 and y < 128 and pget(x, y) == 7 and dotmap[x][y]==nil) then
							spwn(x,y)
						end
					end
				end
			end
		elseif(stat(34)==2) then
			cls()
			line(mx, my, prevmx, prevmy, 7)
			for x=prevmx,mx,sgn(mx-prevmx) do
				for y=prevmy,my,sgn(my-prevmy) do
					if (x > 0 and x < 128 and y < 128 and pget(x, y) == 7 and dotmap[x][y]!=nil) then
						deldot(dotmap[x][y])
					end
				end
			end
		end
	end
	
	for d in all(dots) do
		d.update(d)
	end
end

function _draw()
	cls()
		
	map()
	
	for d in all(dots) do
		d.draw(d)
	end
	
	line(0,14,128,14, 7)
	rect(slct % 7 * 17 + 4, 
		 flr(slct / 7) * 7, 
		 slct % 7 * 17 + 20, 
		 flr(slct / 7) * 7 + 6, 7)
	
	for i=0, #elmnts-1 do
		print(elmnts[i+1], 5 + (i * 17) % 119, flr(i / 7) * 7 + 1, i + 1)
	end
		
	line(mx, my, prevmx, prevmy, 7)
	
	print('dot:'..#dots, 0, 18, 8)
	print('cpu:'..stat(1))
	print('ram:'..stat(0))
	
	
	if (my < 128 and mx > 1 and mx < 128) then
		local dot = dotmap[mx][my]
		if (dot != nil) then
			print(dot.colr)
			print(dot.sttc)
		end
	end
	--print(mx)
	--print(my)
end

function spwn(x,y, elmnt_)
	if (elmnt_ == nil) then elmnt_ = elmnt end
	
	if (elmnt_ == "blck") then add(dots, blck(x,y)) end
	if (elmnt_ == "c4") then add(dots, c4(x,y)) end
	if (elmnt_ == "gas") then add(dots, gas(x,y)) end
	if (elmnt_ == "wood") then add(dots, wood(x,y)) end
	if (elmnt_ == "smke") then add(dots, smke(x,y)) end
	if (elmnt_ == "vapr") then add(dots, vapr(x,y)) end
	if (elmnt_ == "ice") then add(dots, ice(x,y)) end
	if (elmnt_ == "fire") then add(dots, fire(x,y)) end
	if (elmnt_ == "lava") then add(dots, lava(x,y)) end
	if (elmnt_ == "sand") then add(dots, sand(x,y)) end
	if (elmnt_ == "leaf") then add(dots, leaf(x,y)) end
	if (elmnt_ == "watr") then add(dots, watr(x,y)) end
	if (elmnt_ == "iron") then add(dots, iron(x,y)) end
	if (elmnt_ == "acid") then add(dots, acid(x,y)) end
end
-->8
-- elements

function blck(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.colr = 1
	c.sttc = true
	
	dotmap[x][y] = c
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	c.react = function(o, _o)
	
	end
	
	return c
end
function c4(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.colr = 2
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function gas(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 3
	c.dir = sgn(rnd(1)-0.5)
	c.vlty = -1
	c.sttc = false
	
	c.update = function(o)
		gasupdate(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	c.react = function(o, _o)
	
	end
	
	return c
end
function wood(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 4
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function smke(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 5
	c.vlty = -0.5
	c.hlty = 1
	
	c.update = function(o)
		dotupdate(o)
		gasupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function vapr(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 6
	c.vlty = -0.5
	c.hlty = 1
	
	c.update = function(o)
		dotupdate(o)
		gasupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function ice(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 7
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function fire(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 8
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function lava(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 9
	c.dir = sgn(rnd(1)-0.5)
	c.vlty = 1
	c.sttc = false
	
	c.update = function(o)
		liquidupdate(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	c.react = function(o, _o)
		deldot(_o)
		spwn(_o.x, _o.y, "gas")
	end
	
	return c
end
function sand(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 10
	c.vlty = 1
	
	c.update = function(o)
		dotupdate(o)
		powderupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function leaf(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 11
	c.sttc = true
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function watr(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 12
	c.dir = sgn(rnd(1)-0.5)
	c.vlty = 1
	c.sttc = false
	
	c.update = function(o)
		if (not o.sttc) then
			liquidupdate(o)
			dotupdate(o)
			
			for x = -1,1 do
				local dot = dotmap[min(127,max(o.x+x,1))][o.y]
				if (dot != nil and dot.colr != o.colr) then
					dot.react(dot, o)
				end
			end
			
			for y = -1,1 do
				local dot = dotmap[o.x][min(127,o.y+y)]
				if (dot != nil and dot.colr != o.colr) then
					dot.react(dot, o)
				end
			end
		end
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	c.react = function(o, _o)
	
	end
	
	return c
end
function iron(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 13
	
	c.update = function(o)
		dotupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
function acid(x,y)
	local c = {}
	c.x = x
	c.y = y
	c.ox = 0
	c.oy = 0
	c.colr = 14
	c.vlty = 1
	
	c.update = function(o)
		dotupdate(o)
		liquidupdate(o)
 	end
	
	c.draw = function(o)
		pset(o.x, o.y, o.colr)
	end
	
	return c
end
-->8
-- state updates

function liquidupdate(o)
	if (not o.sttc) then
		if (o.y + o.vlty < 128 and dotmap[o.x][o.y+o.vlty]==nil) then
			for i=0,3 do
				if i == 0 then
					dot = dotmap[o.x][o.y-1]
				elseif i == 1 then
					dot = dotmap[o.x+1][o.y]
				elseif i == 2 then
					dot = dotmap[max(o.x-1,1)][o.y]
				end
			
				if (dot != nil) then
					dot.sttc = false
				end
			end

			dotmap[o.x][o.y] = nil
			o.y += o.vlty
		else
			o.dir *= sgn(rnd(1)-0.1)
			if (o.x + o.dir > 0 and o.x + o.dir < 128 and dotmap[o.x+o.dir][o.y]==nil) then
				for i=0,1 do
					if i == 0 then
						dot = dotmap[o.x][o.y-1]
					elseif i == 1 then
						dot = dotmap[max(o.x-o.dir,1)][o.y]
					end
				
					if (dot != nil) then
						dot.sttc = false
					end
				end

				dotmap[o.x][o.y] = nil
				o.x += o.dir
			else
				o.dir *= -1
			end
		end

		dotmap[o.x][o.y] = o
	end
end
	
function gasupdate(o)
	--[[if (o.y + o.vlty > 0 and pget(o.x, o.y + ceil(abs(o.vlty))*sgn(o.vlty))==0) then
		o.y += o.vlty
	else 
		dir = sgn(rnd(1)-0.5)
		if (o.x + dir > 0 and o.x + dir < 128 and pget(o.x + dir, o.y)==0) then
			o.x += dir
		end
	end
	
	o.hlty = rnd(1) * wind
	if (o.x + o.hlty > 0 and o.x + o.hlty < 128 and pget(o.x + o.hlty, o.y)==0) then
		o.x += o.hlty
	end]]
	if (not o.sttc) then
		if (o.y + o.vlty > 15 and dotmap[o.x][o.y+sgn(o.vlty)]==nil) then
			for i=0,3 do
				if i == 0 then
					dot = dotmap[o.x][o.y+1]
				elseif i == 1 then
					dot = dotmap[o.x+1][o.y]
				elseif i == 2 then
					dot = dotmap[max(o.x-1,1)][o.y]
				end
			
				if (dot != nil) then
					dot.sttc = false
				end
			end

			dotmap[o.x][o.y] = nil
			o.y += o.vlty
		end
		
		o.dir *= sgn(rnd(1)-0.5)
		if (o.x + o.dir > 0 and o.x + o.dir < 128 and dotmap[o.x+o.dir][o.y]==nil) then
			for i=0,1 do
				if i == 0 then
					dot = dotmap[o.x][o.y-1]
				elseif i == 1 then
					dot = dotmap[max(o.x-o.dir,1)][o.y]
				end
			
				if (dot != nil) then
					dot.sttc = false
				end
			end

			dotmap[o.x][o.y] = nil
			o.x += o.dir
		else
			o.dir *= -1
		end

		dotmap[o.x][o.y] = o
	end
end

function powderupdate(o)

end

function deldot(o)
	for x=-1,1 do
		dot = dotmap[o.x+x][o.y]
		if (dot != nil) then
			dot.sttc = false
		end
	end
	
	for y=-1,1 do
		dot = dotmap[o.x][o.y+y]
		if (dot != nil) then
			dot.sttc = false
		end
	end
	
	dotmap[o.x][o.y] = nil
	del(dots, o)
end

function dotupdate(o)
	if (not o.sttc) then
		if (o.ox == o.x and o.oy == o.y and surrnd(o)) then
			o.sttc = true
		else
			o.ox = o.x
			o.oy = o.y
		end
	end
end

function surrnd(o)
	local surrnd = true
	for x = -1,1 do
		if (dotmap[min(127,max(o.x+x,1))][o.y] == nil) then
			surrnd = false
		end
	end
	
	for y = -1,1 do
		if (dotmap[o.x][min(127,o.y+y)] == nil) then
			surrnd = false
		end
	end
	
	return surrnd
end

__gfx__
00000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
