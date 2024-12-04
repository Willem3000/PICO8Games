pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
b={[false]=0,[true]=1}
t=time

function _init()
	m=mimi(64,64,true)
end

function _update()
	m.update(m)
end

function _draw()
	cls()
	m.draw(m)
end
-->8
--classes
function limb(body)
	local c={}
	c.x=0
	c.y=0
	c.body=body
	
	return c
end

function larm(body,armor,wep)
	local c=limb(body)
	c.armor=armor
	c.wep=wep
	
	function c.update(o)
		if o.body!=nil then
			o.x=o.body.x+3
			o.y=o.body.y+3
		else
			
		end
	end
	
	function c.draw(o)
		pset(o.x,o.y,15)
	end
	
	return c
end

function rarm(body,armor,wep)
	local c=limb(body)
	c.armor=armor
	c.wep=wep
	
	function c.update(o)
		if o.body!=nil then
			o.x=o.body.x+1
			o.y=o.body.y+3
		else
			
		end
	end
	
	function c.draw(o)
		pset(o.x,o.y,15)
	end
	
	return c
end

function lleg(body,armor)
	local c=limb(body)
	c.armor=armor
	c.walking=false

	function c.walk(o)
		o.walking=true
	end

	function c.halt(o)
		o.walking=false
	end
	
	function c.update(o)
		if o.body!=nil then
			if o.walking then
				xm=3-flr(t()*10%2)
			else
				xm=3
			end
			o.x=o.body.x+xm
			o.y=o.body.y+5
		else
			
		end
	end
	
	function c.draw(o)
		pset(o.x,o.y,15)
	end
	
	return c
end

function rleg(body,armor)
	local c=limb(body)
	c.armor=armor
	c.walking=false

	function c.walk(o)
		o.walking=true
	end

	function c.halt(o)
		o.walking=false
	end
	
	function c.update(o)
		if body!=nil then
			if o.walking==true then
				xm=1+flr(t()*10%2)
			else
				xm=1
			end
			o.x=o.body.x+xm
			o.y=o.body.y+5
		else
			
		end
	end
	
	function c.draw(o)
		pset(o.x,o.y,15)
	end
	
	return c
end

function head(body,armor)
	local c=limb(body)
	c.armor=armor
	
	function c.update(o)
		if body!=nil then
			o.x=o.body.x+2
			o.y=o.body.y+1
		else
			
		end
	end
	
	function c.draw(o)
		pset(o.x,o.y,15)
	end
	
	return c
end

function torso(body,armor)
	local c=limb(body)
	c.armor=armor
	
	function c.update(o)
		if body!=nil then
			o.x=o.body.x+2
			o.y=o.body.y+3
		else
			
		end
	end
	
	function c.draw(o)
		line(o.x,o.y,o.x,o.y+1,15)
	end
	
	return c
end



function mimi(x,y,plyr)
	local c={}
	c.x=x
	c.y=y
	c.head=head(c)
	c.torso=torso(c)
	c.larm=larm(c)
	c.rarm=rarm(c)
	c.lleg=lleg(c)
	c.rleg=rleg(c)
	c.plyr=plyr
	
	function c.control(o)
		if plyr==true then
			local hm=btoi(btn(➡️))-btoi(btn(⬅️))
			local vm=btoi(btn(⬇️))-btoi(btn(⬆️))
			o.x+=hm
			o.y+=vm

			if hm!=0 or vm!=0 then
				o.lleg.walk(o.lleg)
				o.rleg.walk(o.rleg)
			else
				o.lleg.halt(o.lleg)
				o.rleg.halt(o.rleg)
			end
		end
	end
	
	function c.update(o)
		o.head.update(o.head)
		o.control(o)
		o.torso.update(o.torso)
		o.larm.update(o.larm)
		o.rarm.update(o.rarm)
		o.lleg.update(o.lleg)
		o.rleg.update(o.rleg)
	end
	
	function c.draw(o)
		o.head.draw(o.head)
		o.torso.draw(o.torso)
		o.larm.draw(o.larm)
		o.rarm.draw(o.rarm)
		o.lleg.draw(o.lleg)
		o.rleg.draw(o.rleg)
	end
	
	return c
end
-->8

function btoi(bool)
	return b[bool]
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
