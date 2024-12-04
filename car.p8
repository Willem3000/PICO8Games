pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	plyr=car(64,64,12)
	cones={}
	
	for i=0,10 do
		pos={rnd(128),rnd(128)}
		add(cones,pos)
	end
end

function _update()
	plyr.update(plyr)
end

function _draw()
	cls()
	plyr.draw(plyr)
	for cone in all(cones) do
		spr(1,cone[1],cone[2])
	end
end
-->8
function car(x,y,clr)
	local c={}
	c.x=x
	c.y=y
	c.clr=clr--colour
	c.sdir=0 --steer direction
	c.vx=0		 --velocity x
	c.vy=0   --velocity y
	c.acc=0  --acceleration
	c.macc=5 --max acc
	
	c.update=function(o)
		-- input
		local pedal=0
		if btn(⬆️) then
			pedal+=0.1
		elseif btn(⬇️) then
			pedal-=0.1
		else
			o.acc+=-o.acc*0.05
		end
		o.acc=max(-1,min(1,o.acc+pedal))
		
		
		local steer=0
		if btn(➡️) then
			steer-=5
		end 
		if btn(⬅️) then
			steer+=5
		end
		o.sdir+=steer
		
		----process
		--velocity coords
		local vxd=cos(o.sdir/360)
		local vyd=sin(o.sdir/360)
		
		o.vx+=vxd*o.acc
		o.vy+=vyd*o.acc
		
		o.vx*=0.95
		o.vy*=0.95
		-- output
		o.x+=o.vx/10
		o.y+=o.vy/10
	end
	
	c.draw=function(o)
		pset(o.x,o.y,o.clr)
		pset(o.x+cos(o.sdir/360),
							o.y+sin(o.sdir/360),7)
		pset(o.x-cos(o.sdir/360),
							o.y-sin(o.sdir/360),8)
		--pset(o.x+o.vx,
		--					o.y+o.vy,
		--					9)
		--pset(o.x+cos(o.sdir/360)*o.acc*10,
		--		o.y+sin(o.sdir/360)*o.acc*10,
		--			10)
		print("sdr: "..o.sdir)
		print(v)
		print("vx: "..o.vx)
		print("vy: "..o.vy)
		print("acc: "..o.acc)
	end

	return c
end
-->8
function sign(x)
	if(x==0 or x==-0)return 0
	return sgn(x)
end

function lerp(a,b,t)
	return a+(b-a)*t
end
__gfx__
00000000000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
