pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
function _init()
	pi=3.14
	ampl=20
	wvln=200
	pos=0
	seapal()
	wind=0
	lightning=0

	wlut={}
	wlut_prlx={}
	raint={}
	clouds={}
	clouds_prlx={}

	for i=0,100 do
		add(clouds,cloud(rnd(127),rnd(10)))
		add(clouds_prlx,cloud(rnd(127),rnd(10)+10))
	end

	lpaltbl={
		1,13,14,11,9,13,7,7,14,10,7,7,6,6,7,7
	}
end

function _update60()
	wvln=(ampl-1)*30
	k=2*pi/wvln
	input()
	wlut=srfc(wvln,pos,ampl)
	wlut_prlx=srfc(wvln*2,pos/1.5,ampl/2)
	ampl=min(60, max(ampl,1))
	pos-=0.005

	for i=0,ampl/10 do
		local x=rnd(256)
		local y=0
		if x > 127 then
			y=x-127
			x=-5
		end
		add(raint,raindrop(x,y))
	end

	for r in all(raint) do
		r.update(r)
	end

	for c in all(clouds) do
		c.update(c)
	end
	for c in all(clouds_prlx) do
		c.update(c)
	end

	wind=(ampl-1)/10
end

function _draw()
	cls(12)
	if lightning>0 then
		if lightning%2==0 then
			lightningstrike()
		end
		lightningpal()
		lightning-=1
	else
		seapal()
	end
	sea()
	logs(64,5)

	for c in all(clouds_prlx) do
		c.drawb(c)
	end
	for c in all(clouds_prlx) do
		c.drawf(c)
	end

	for c in all(clouds) do
		c.drawb(c)
	end
	rectfill(0,0,128,7,13)
	for r in all(raint) do
		r.draw(r)
	end
	for c in all(clouds) do
		c.drawf(c)
	end
	rectfill(0,0,128,5,6)
	debug()
end

function input()
--  if btn(⬅️) then wvln-=1 end
--  if btn(➡️) then wvln+=1 end
 if btn(⬆️) then ampl+=1 end
 if btn(⬇️) then ampl-=1 end
 if btnp(❎) then 
 	lightning=ceil(rnd(10))
end
 if btn(🅾️) then pos+=0.01 end
end

function trochx(x,w,p,a)
	return cos(x/w+p)*a
end

function trochy(x,w,p,a)
	big=sin(x/w+p)*a
	return big+sin(x/40)
end

function srfc(w,p,a)
	local y=90
	t={}
	start=ampl+1
	for x=start,256+ampl,2 do
		nx=flr(x+trochx(x,w,p,a))
		ny=y+trochy(x,w,p,a)
		t[start+nx]=ny
	end

	return t
end

function sea()
	for x=0,127 do
		local y=wget(wlut_prlx,x)
		line(x,y,x,128,1)
		local y=wget(wlut,x)
		line(x,y,x,128,8)
		pset(x,y,7)
		fillp()
	end
end

function wget(t,x)
	x+=ampl+128
	if t[x]==nil then
		l=x
		while t[l]==nil and l>0 do l-=1 end
		r=x
		while t[r]==nil and r<256+ampl*2 do r+=1 end
		local ratio=(x-l)/(r-l)
		return lerp(t[l],t[r],ratio)
	else
		return t[x]
	end
end

function raft()
end

function logs(x,n)
	if n<=1 then
		local y=wget(wlut,x)
		circfill(x,y,2,4)
	else
		ly=wget(wlut,x)-1
		lx=x
		ry=wget(wlut,x+n*5)-1
		rx=x+n*5

		for i=0,n do
			local x=lx+5*i
			local y=ly+lerp(0,(ry-ly),i/n)
			circfill(x,y,2,4)
			circfill(x,y,1,9)
		end
	end
end

--util

function lerp(a,b,t)
	return a+(b-a)*t
end

function seapal()
	pal()
	pal(8,-4,1)
	pal(12,5,1)
end

function lightningpal()
	-- for i=0,15 do
	-- 	pal(i,lpaltbl[i+1],1)
	-- end
	pal(12,13,1)
	pal(1,12,1)
	pal(13,7,1)
	pal(6,7,1)
end

function lightningstrike()
	local xa=rnd(127)
	local xb=xa+rnd(8)
	local ya=0
	local yb=7
	for i=0,15 do
		line(xa,ya,xb,yb,10)
		xa=xb
		xb+=8-rnd(16)
		ya=yb
		yb+=rnd(8)+3
	end
end

function debug()
	color(7)
	print("ampl: "..ampl)
	print("wvln: "..wvln)
	print("cpu: "..stat(1))
end

--weather

function raindrop(x,y)
	local c = {}
	c.x=x
	c.y=y
	c.clr=6
	c.update=function(o)
		o.x+=wind
		o.y+=2

		if o.y > 135 or x > 127 then
			del(raint,o)
		end
	end

	c.draw=function(o)
		line(o.x,o.y-5,o.x+wind*2,o.y,o.clr)
	end

	return c
end

function cloud(x,y)
	local c = {}
	c.x=x
	c.y=y
	c.s=rnd(5)+2
	c.a=c.s
	c.update=function(o)
		o.x+=(wind/((y+5)*2))

		o.x%=128+o.a

		c.a=c.s+sin(time()/o.s)
	end

	c.drawf=function(o)
		circfill(o.x,o.y,o.a,6)
	end

	c.drawb=function(o)
		circfill(o.x-o.a/3,o.y+o.a/3,o.a,13)
	end

	return c
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
