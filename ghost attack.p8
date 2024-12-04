pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- main

function _init()
	furns={
	furniture(0,20,11,14,2,3), -- cabinet
	furniture(0,28,64,66,2,2), -- couch
	furniture(0,20,68,100,2,2), -- painting
	furniture(0,29,96,98,2,2), -- telly
	furniture(0,28,74,76,2,2), -- vase
	furniture(0,28,128,130,2,2), -- table
	furniture(0,29,136,134,2,2), -- bed
	furniture(0,29,138,140,2,2), -- bear
	furniture(0,28,106,108,2,2), -- lamp 
	furniture(0,12,78,142,2,4), -- clock
	furniture(0,28,192,194,2,2), -- fridge
	furniture(0,28,160,162,2,2), -- coathanger
	}
	
	start=false
	won=false
	lost=false
	
	btrycntmax=4
	
	btrycnt=btrycntmax
	while btrycnt > 0 do
		for furn in all(furns) do
			if(not furn.btry and rnd(1)>0.5 and btrycnt>0) then
				furn.btry=true
				btrycnt-=1
			end
		end
	end
	
	btrycnt=btrycntmax
	
	objects={
		door(1,107),
		door(1,67),
		door(1,27),
		door(119,107),
		door(119,67),
		door(119,27),
		sidedoor(60,102),
		sidedoor(60,62),
		sidedoor(60,22),
		floor(0,10,35),
		floor(0,50,35),
		floor(0,90,35),
		ghost(30,20),
		darkness(),
		human(0,112,0),
		human(0,112,1),
	}
	
	for o in all(objects) do
		o.objects=objects
	end
	
	for f in all(furns) do
		f.objects=objects
	end
	
	for o in all(objects) do
		o.start(o)
	end
	
	sfx(13,3)
	
	endscrn=0
end

function _update()
	if(start and not won and not lost and btrycnt>0 ) then
		for o in all(objects) do
			o.update(o)
		end
	elseif(not start) then
		if(btnp(❎) or btnp(🅾️)) then
			btrycnt+=2
			if(btnp(🅾️)) then
				del(objects,objects[16])
				btrycnt-=1
			end
			sfx(14,3)
			start=true
		end
	elseif(won or lost or btrycnt==0) then
		endscrn+=1
		if((btnp(❎) or btnp(🅾️)) and endscrn > 30) then
			_init()
		end
	end
end

function _draw()
	cls()
	
	if(start) then
		map(0,0)
		for o in all(objects) do
			o.draw(o)
		end
		
		if(lost) then
			rectfill(32,32,96,96,1)
			rectfill(35,35,92,92,7)
			print('you died!',64-8*2,62-12-5,8)
			print('the ghost of',64-12*2,62-5,8)
			print('the mansion',64-11*2,62+3,8)
			print('has expelled',64-12*2,62+11,8)
			print('you!',64-3*2,62+19,8)
		elseif(won) then
			rectfill(32,32,96,96,1)
			rectfill(35,35,92,92,7)
			print('you won!',64-8*2,62-12-5,8)
			print('the ghost of',64-12*2,62-5,8)
			print('the mansion',64-11*2,62+3,8)
			print('has been',64-7*2,62+11,8)
			print('expelled!',64-8*2,62+19,8)
		elseif(btrycnt==0) then
			rectfill(32,32,96,96,1)
			rectfill(35,35,92,92,7)
			print('you ran out ',64-11*2,62-23,8)
			print('of batteries!',64-12*2,62-16,8)
			print('the ghost of',64-12*2,62-4,8)
			print('the mansion',64-11*2,62+4,8)
			print('could not be',64-11*2,62+12,8)
			print('expelled!',64-8*2,62+20,8)
		end
	else
		spr(102,(time()*30%208-80),sin(time()/1)*8+90,2,2,true)
		print('press 🅾️ for 1p',64-14*2-1,62-4,8)
		print('press ❎ for 2p',64-14*2-1,62+6,8)
		spr(164,64-4*8-4,12,9,5)
		
	end
end
-->8
-- ghost class

function ghost(x, y)
	local c={}
	c.name='ghost'
	c.x=x
	c.y=y
	c.targ=x
	c.w=2
	c.h=2
	c.mirr=true
	
	c.spts={roam=102,hit=104,invis=255,attk=70,pnic=72}
	c.currsprt=102
	
	c.box={x1=0,y1=0,x2=c.w*8,y2=c.h*8}
	c.atkbox={x1=2,y1=2,x2=c.w*8-2,y2=c.h*8-2}
	c.vibx={x1=0,y1=0,x2=0,y2=0}
	
	c.sts={roam=0,hide=1,flee=2,attk=3,pnic=4,folw=5,srch=6}
	c.st=c.sts.roam
	
	c.rmx=0
	c.rmy=0
	c.rmdir=1
	c.rmspd=0.75
	
	c.cldn=6
	
	c.furn=nil
	c.furns={}
	c.room=nil
	c.found=false
	
	c.trck=nil
	c.lstseen={x=0,y=0}
	c.flwcnt=3
	
	c.life=3
	c.mxlf=3
	
	c.start=function(o) 
			o.room=o.getrndrm(o)
			o.x=o.room.x
			o.y=o.room.y
		end
	
	c.draw=function(o)	
			spr(o.currsprt, o.x, o.y, o.w, o.h,o.mirr)
			
			for i=-1,o.mxlf-2 do
				outln(58,1,61-10*i,0,1,1)
				pal(11,0)
				pal(7,0)
				spr(58,61-10*i,0,1,1)
				pal()
			end
			
			for i=-1,o.life-2 do
				spr(58,61+10*i,0,1,1)
			end
		end
	
	c.roam=function(o)
			o.targx=sin((o.rmx)/100)*(o.room.w/5)-(o.w*8)/2+o.room.x+o.room.w/2+sgn(btoi(o.room.left)-0.5)*10
			o.targy=sin((o.rmy)/24)*(o.room.h/4)-(o.h*8)/2+o.room.y+o.room.h/2
			o.x=o.x+0.2*(o.targx-o.x)
			o.y=o.y+0.2*(o.targy-o.y)
		end
		
	c.update=function(o)
		if (o.mirr) then 
			o.vibx.x1=o.x+(o.w*8)/2-o.room.x
			o.vibx.x2=max(btoi(o.room.flor.open)*128,o.room.w)
		else 
			o.vibx.x1=-btoi(o.room.flor.open)*66
			o.vibx.x2=o.x+(o.w*8)/2-o.room.x
		end
		o.vibx.y1=o.y-o.room.y+2
		o.vibx.y2=o.y-o.room.y+20
		
		prvx = o.x
		if(o.st==o.sts.roam) then
			o.roam(o)
			o.rmx+=o.rmdir*o.rmspd
			o.rmy+=o.rmspd*0.6
			
			for _o in all(o.objects) do
				if(_o.name=='human') then
					if(cantouch(o.room,_o,o.vibx,_o.box) and _o.st!=_o.sts.hide) then
						o.trck=_o
						o.currsprt=o.spts.attk
						o.st=o.sts.attk
						sfx(9,2)
						sfx(15,3)
					end
				end
			end
			
		elseif(o.st==o.sts.hide) then	
			o.cldn-=1		
			if(o.found) then
				o.cldn=120
				o.furn.ghst=nil
				o.currsprt=o.spts.pnic
				o.st=o.sts.pnic
				sfx(12,2)
				sfx(15,3)
				while (abs(o.x-ceil(sin((o.rmx)/100)*(o.room.w/3)-(o.w*8)/2+o.room.x+o.room.w/2))>5) o.rmx+=1
				while (abs(o.y-ceil(sin((o.rmy)/24 )*(o.room.h/4)-(o.h*8)/2+o.room.y+o.room.h/2))>5) o.rmy+=1
				o.found=false
				return
			end
			
			if(o.cldn<=0 and not o.room.light) then
				o.furn.ghst=nil
				o.currsprt=o.spts.roam
				o.st=o.sts.roam
				while (abs(o.x-ceil(sin((o.rmx)/100)*(o.room.w/3)-(o.w*8)/2+o.room.x+o.room.w/2))>5) o.rmx+=1
				while (abs(o.y-ceil(sin((o.rmy)/24 )*(o.room.h/4)-(o.h*8)/2+o.room.y+o.room.h/2))>5) o.rmy+=1
				return
			end
		
		elseif(o.st==o.sts.pnic) then
			o.roam(o)
			o.rmx+=o.rmdir*o.rmspd*2
			o.rmy+=o.rmspd*1.25
			
			o.cldn-=1
			if(o.cldn<=0) then
				sfx(12,-2)
				sfx(14,3)
				o.currsprt=o.spts.roam
				o.cldn=6
				o.st=o.sts.roam
			end
			
		elseif(o.st==o.sts.flee) then
			o.cldn-=1
			sfx(9,-2)
			if(o.cldn<=0) then
				if(o.life>0) then
					o.room=o.getrndrm(o)
					o.furn=o.room.furns[flr(rnd(#o.room.furns)+1)]
					o.currsprt=o.spts.invis
					o.cldn=450
					o.x=o.furn.x
					o.y=o.room.y+o.room.h/2
					o.furn.ghst=o
					o.st=o.sts.hide
				else
					o.currsprt=o.spts.invis
					won=true
				end
			end
			
		elseif(o.st==o.sts.attk) then
			o.rmy+=o.rmspd*0.75
			o.targx+=sgn(o.trck.x-o.x)*1
			o.targy=o.room.y+15+sin(o.rmy*0.07)*5
			o.x=o.x+0.2*(o.targx-o.x)
			o.y=o.y+0.2*(o.targy-o.y)
			
			if(not cantouch(o.room,o.trck,o.vibx,o.trck.box)) then
				sfx(9,-2)
				o.flwcnt=3
				o.currsprt=o.spts.roam
				o.st=o.sts.folw
				return
			end
			
			for _o in all(o.objects) do
				if(_o.name=='human') then
					if(cantouch(o,_o,o.atkbox,_o.colbox) and (_o.st!=_o.sts.hide or (_o.st==_o.sts.hide and _o==o.trck))) then
						sfx(9,-2)
						sfx(10,1)
						sfx(14,3)
						_o.dmg(_o)
						o.currsprt=o.spts.roam
						o.st=o.sts.flee
					end
				end
			end
			
			o.lstseen.x=o.trck.x
			o.lstseen.y=o.trck.y
			
		elseif(o.st==o.sts.folw) then
			o.rmy+=o.rmspd*1.25
			if(ceil(o.x-o.lstseen.x)!=0 or ceil(o.y-o.room.y-15)!=0) then
				if(ceil(o.x-o.lstseen.x)!=0) then
					o.x+=sgn(o.lstseen.x-o.x)*0.75
					o.y=o.room.y+15+sin(o.rmy*0.025)*5
				end
				if(ceil(o.y-o.room.y-15)!=0) then
					o.y+=sgn(o.room.y+15-o.y)
				end
				
				if(ceil(o.x-o.lstseen.x)==0 and ceil(o.y-o.room.y-15)!=0) then
					if(o.x < 64) then
						prvx-=2
					else
						prvx+=2
					end
				end
			elseif(o.flwcnt>0) then
				o.flwcnt-=1
				o.st=o.sts.srch
			else
				while (abs(o.x-ceil(sin((o.rmx)/100)*(o.room.w/3)-(o.w*8)/2+o.room.x+o.room.w/2))>7) o.rmx+=1
				while (abs(o.y-ceil(sin((o.rmy)/24 )*(o.room.h/4)-(o.h*8)/2+o.room.y+o.room.h/2))>7) o.rmy+=1
				sfx(14,3)
				o.currsprt=o.spts.roam
				o.st=o.sts.roam
			end
			
			for _o in all(o.objects) do
				if(_o.name=='human' and ceil(o.y-o.room.y-15)==0) then
					if(cantouch(o.room,_o,o.vibx,_o.box) and _o.st!=_o.sts.hide) then
						o.targx=o.x
						o.targy=o.y
						o.trck=_o
						sfx(9,1)
						sfx(15,3)
						o.currsprt=o.spts.attk
						o.st=o.sts.attk
					end
				end
			end
			
		elseif(o.st==o.sts.srch) then
			local nflr=nil
			if(o.lstseen.x>32 and o.lstseen.x<96) or (o.flwcnt<2 and rnd(1)>0.5) then
				if(o.room==o.room.flor.rrom) then
					o.room=o.room.flor.lrom
					o.lstseen.x=o.room.x
				else
					o.room=o.room.flor.rrom
					o.lstseen.x=o.room.x+o.room.w-16
				end
			else
				if(o.y<50) then
						nflr=getflrs()[2]
					elseif(o.y>90) then
						nflr=getflrs()[2]
					else
						nflr=getflrs()[1+2*btoi(rnd(1)>0.5)]
				end
				
				if(o.x>96) then
					o.room=nflr.rrom
				elseif(o.x<32) then
					o.room=nflr.lrom
				end
			end
			o.st=o.sts.folw
		end
		if(prvx-o.x!=0) then
			o.mirr=prvx-o.x<0
		end
	end
	
	c.dmg=function(o)
		if(o.st!=o.sts.flee and o.st!=o.sts.hide) then
			o.currsprt=o.spts.hit
			o.slctfurn(o)
			o.st=o.sts.flee
			o.cldn=6
			sfx(11,2)
			sfx(14,3)
			o.life-=1
		end
	end
		
	c.slctfurn=function(o)
		local f=o.getfurns(o)
		o.furn=f[flr(rnd(#f))+1]
	end
	
	c.getfurns=function(o)
		if(o.furns[1]==nil) then
			for _o in all(o.objects) do
				if(_o.name=='furniture') then add(o.furns,_o) end
			end
		end
		return o.furns
	end
	
	function getflrs()
		local flrs={}
		for o in all(objects) do
			if(o.name=='floor') then
				add(flrs,o)
			end
		end
		return flrs
	end
	
	c.getrndrm=function(o)
		local flrs=getflrs()
		local nwrm=o.room
		while(nwrm==nil or nwrm==o.room or nwrm.light) do
			if(rnd(1)>0.5) then
				nwrm=flrs[flr(rnd(#flrs)+1)].lrom
			else
				nwrm=flrs[flr(rnd(#flrs)+1)].rrom
			end
		end
		return nwrm
	end
	
	return c
end
-->8
-- tools

function outln(n,col_outline,x,y,w,h,flip_x,flip_y)
	for c=1,15 do
		pal(c,col_outline)
	end
	for xx=-1,1 do
		spr(n,x+xx,y,w,h,flip_x,flip_y)
	end
	for yy=-1,1 do
		spr(n,x,y+yy,w,h,flip_x,flip_y)
	end
	pal()	
end

function btoi(b)
	return b and 1 or 0
end

function lengthdirx(dist,dir)
	return dist*sin(dir)
end

function cantouch(a,b,ba,bb)
	if(ba!=nil and bb!=nil)then
	return (ba.x1+a.x < bb.x2+b.x and
									ba.x2+a.x > bb.x1+b.x and
									ba.y1+a.y < bb.y2+b.y and
									ba.y2+a.y > bb.y1+b.y)
	end
	return false
end
	
function highlight(o)
	o.hlght=false
	for _o in all(objects) do
		if(cantouch(o,_o,o.box,_o.box)) and
			 (_o.name=='human') then	
				o.hlght=true
		end
	end
end

-->8
-- human class

function human(x, y,plyr)
	local c={}
	c.plyr=plyr
	c.name='human'
	c.x=x
	c.y=y
	c.w=2
	c.h=2
	c.box={x1=0,y1=0,x2=0,y2=0}
	c.colbox={x1=0,y1=0,x2=0,y2=0}
	c.flbox={x1=0,y1=0,x2=0,y2=0}
	
	c.sts={free=0,chck=1,hide=2,hold=3}
	c.st=c.sts.free
	
	c.side=true
	c.flor=0
	c.spd=1.1
	c.v=1
	
	c.btrylf=1
	c.btry=1
	
	c.life=2
	c.mxlf=2
	
	c.flsh=false
	c.empt=false
	c.flshcnt=0

	c.furn=nil
	
	c.slctd=nil
	
	c.actcnt=0
	
	c.sprt=1
	if(plyr==0) then c.shrt=12 else c.shrt=14 end
	
	c.start=function(o) 
	end
	
	c.draw=function(o)
		if(o.sprt!=255) then rectfill(o.x+4,o.y+8,o.x+11,o.y+12,c.shrt) end
		spr(o.sprt, o.x, o.y, o.w, o.h, o.side)

		if(o.st==o.sts.free) then
			line(o.x+2+(o.flbox.x1-2)*btoi(o.side),
				 o.y+11,
				 o.x+2+(o.flbox.x1-2)*btoi(o.side),
				 o.y+12,10)
		end
		
		if(o.st!=o.sts.hide) then
			--rectfill(o.x+3,o.y-4,o.x+13,o.y-2,7)
			local btryclr=8+o.btrylf*3
			rectfill(o.x+3,o.y-4,o.x+13,o.y-2,btryclr)
			rect(o.x+3,o.y-4,o.x+13,o.y-2,1)
		end
		
		for i=1,o.mxlf do
			outln(42,1,(o.plyr*120)+(-sgn(o.plyr-0.5))*10*i+o.plyr,0,1,1)
			pal(8,0)
			spr(42,(o.plyr*120)+(-sgn(o.plyr-0.5))*10*i+o.plyr,0,1,1)
			pal()
		end
		
		for i=1,o.life do
			spr(42,(o.plyr*120)+(-sgn(o.plyr-0.5))*10*i+o.plyr,0,1,1)
		end
		
		print("p"..o.plyr+1,1+o.plyr*119,1,6)
		
		if(o.st==o.sts.hold) then
			spr(57,o.x+4,o.y-6)
		end
		if(o.flsh) then
			local cl=0
			if(o.flshcnt<3) then cl=7
			elseif(o.flshcnt<4) then cl=10
			else cl=9
			end
			
			if (not o.empt) then
				for i=-7,7 do
					if(i%2==0) then
						local y1=11+(1+sgn(i))/2
						local y2=8+i,cl
						if (not o.side) then
							y1=8+i,cl
							y2=11+(1+sgn(i))/2
						end
						line(o.x+o.flbox.x1,
							 o.y+y1,
							 o.x+o.flbox.x2,
							 o.y+y2,cl)
					end
				end
			else
				line(o.x+2+(o.flbox.x1-2)*btoi(o.side),
					 o.y+11,
					 o.x+2+(o.flbox.x1-2)*btoi(o.side),
					 o.y+12,cl)
			end
			o.flshcnt+=1
			if (o.flshcnt>7) then
				o.flsh=false
				o.flshcnt=0
				
				if (not o.empt) then
					btrycnt-=1
				end
			end
		end
	end
		
	c.update=function(o)
		if (o.st==o.sts.free) then
			local hinp=btoi(btn(➡️,o.plyr))-btoi(btn(⬅️,o.plyr))
			o.side=getside(hinp, o.side)
			o.x += hinp*o.spd
			
			local flh=flheight(o.flor)
			if(hinp != 0 and o.y == flh and o.v>0) then
			 o.v=-3
			 sfx(0,o.plyr)
			end
			
			if(o.v>0 and o.y >= flh) then
				o.y=flh
			else		
				o.y += o.v
				o.v += 1
			end
			
			if(o.x<-2) then
				o.x -= hinp*o.spd
			elseif(o.x>115) then
				o.x -= hinp*o.spd
			end
			
								
			if (o.furn!=nil) then
				if(o.furn.occp==nil) then
					if (btnp(🅾️,o.plyr)) then 			
						sfx(6,o.plyr)
						o.x=o.furn.x
						o.st=o.sts.chck
						o.furn.occp=o
					end
					if (btnp(⬆️,o.plyr)) then 
						o.x=o.furn.x
						o.st=o.sts.hide
						o.furn.occp=o
					end
				end
			end
			
			local moved=false
			for _o in all(objects) do
				if(cantouch(o,_o,o.box,_o.box)) then
				
					if (_o.name=='door'and moved == false) then
						if (btnp(⬆️,o.plyr)) then moveflor(o,1) end
						if (btnp(⬇️,o.plyr)) then moveflor(o,-1) end
						moved=true
					end
					
					if (_o.name=='sidedoor') then
						if (btnp(🅾️,o.plyr)) then 
							if(_o.opened and cantouch(o,_o,o.colbox,_o.box)) then
								o.x=_o.x+2-btoi(o.x-_o.x+2<0)*12
							end
							_o.opendoor(_o,o.x-_o.x>0)
							sfx(1,2)
						end
						if (_o.opened==false and cantouch(o,_o,o.colbox,_o.box)) then
						 o.x -= hinp*o.spd
						end
					end
				end
			end
			
			if(o.side==true) then
				o.box.x1=8
				o.box.y1=0
				o.box.x2=14
				o.box.y2=16
				o.colbox.x1=8
				o.colbox.y1=0
				o.colbox.x2=9
				o.colbox.y2=16
				o.flbox.x1=13
				o.flbox.y1=1
				o.flbox.x2=24
				o.flbox.y2=15
			else
				o.box.x1=2
				o.box.y1=0
				o.box.x2=8
				o.box.y2=16
				o.colbox.x1=6
				o.colbox.y1=0
				o.colbox.x2=7
				o.colbox.y2=16
				o.flbox.x1=-11
				o.flbox.y1=1
				o.flbox.x2=2
				o.flbox.y2=15
			end
			
			if(btnp(❎,o.plyr) and not o.flsh) then
				o.flsh=true
				if o.btrylf>0 then
					o.empt=false
					o.btrylf-=1
					sfx(5,o.plyr)
					for _o in all(objects) do				
						if _o.name=='ghost' and cantouch(o,_o,o.flbox,_o.box) then
							_o.dmg(_o)
						end
					end
				else
					o.empt=true
					sfx(4,o.plyr)
				end
			end
		
		elseif(o.st==o.sts.chck) then
			o.actcnt+=1
			o.y=flheight(o.flor)
			c.sprt=132
			
			if(o.actcnt>30) then
				if(o.furn.btry and o.furn.ghst==nil) then
					sfx(7,o.plyr)
					o.st=o.sts.hold
					o.actcnt=0
					o.sprt=33
				elseif(o.furn.ghst!=nil) then
					o.furn.ghst.found=true
					o.furn.occp=nil
					o.st=o.sts.free
					o.actcnt=0
					o.sprt=1
					o.furn=nil
					o.v=-5
					sfx(8,o.plyr)
				else
					o.furn.occp=nil
					o.st=o.sts.free
					o.actcnt=0
					o.sprt=1
					o.furn=nil
				end
			end
		elseif(o.st==o.sts.hide) then
			o.y=flheight(o.flor)
			o.sprt=255
			
			if(btnp(⬇️,o.plyr)) then
				o.furn.occp=nil
				o.st=o.sts.free
				o.sprt=1
				o.furn=nil
			end
		elseif(o.st==o.sts.hold) then
			o.actcnt+=1
			
			if(o.actcnt>20) then
				if(o.btrylf<o.btry) then
					o.furn.btry=false
					o.btrylf+=1
					sfx(2,o.plyr)
				end
				o.furn.occp=nil
				o.st=o.sts.free
				o.actcnt=0
				o.sprt=1
				o.furn=nil
			end
		end
	end
	
	c.dmg=function(o)
		o.st=o.sts.free
		o.sprt=1
		o.life-=1
		o.v=-5
		
		if(o.furn!=nil) then
			o.furn.occp=nil
			o.furn=nil
		end
		
		if(o.life<=0) then
			o.sprt=255
			lost=true
		end
	end
	
	return c
end

function getside(inp, side)
	if inp > 0 then
		return true
	elseif inp < 0 then
		return false
	else 
		return side
	end
end

function moveflor(o,dir)
	nf=max(0,min(o.flor+dir,2))
	if(flheight(nf)!=flheight(o.flor)) then
	 o.flor=nf
	 o.y=flheight(o.flor)
	 sfx(1,o.plyr)
	end
end

function flheight(fl)
	return 128-(40*fl)-19
end
-->8
-- object class

function furniture(x,y,sprt,hdsprt,w,h)
	local c={}
	c.name='furniture'
	c.x=x
	c.y=y
	c.w=w
	c.h=h
	
	c.sprt=sprt
	c.hdsprt=hdsprt
	c.hlght=false
	c.currsprt=sprt
	
	c.btry = false
	
	c.occp=nil
	c.ghst=nil
	c.box={x1=0,y1=0,x2=w*8,y2=h*8}
	
	c.start=function(o) end
	
	c.draw=function(o)
		if(o.hlght) then outln(o.sprt,8,o.x,o.y,o.w,o.h) end
		if(o.occp!=nil) then 
			if(o.currsprt==100 or o.currsprt==108 or o.currsprt==162 or o.currsprt==76) then
				rectfill(o.x+5,o.y+4,o.x+o.w*8-5,o.y+o.h*8-4,o.occp.shrt)
			elseif(o.currsprt==14 or o.currsprt==142) then
				rectfill(o.x+1,o.y+8,o.x+o.w*8-4,o.y+o.h*8-5,o.occp.shrt)
			end
		end
		spr(o.currsprt,o.x,o.y,o.w,o.h)
	end
	
	c.update=function(o)
		o.currsprt=o.sprt
		if(o.occp==nil) then 
			highlight(o) 
		else 
			o.hlght=false 
			if(o.occp.st==o.occp.sts.hide) then
				o.currsprt=o.hdsprt
			end
		end
		
		for _o in all(objects) do
			if(_o.name=='human') then
				if(cantouch(o,_o,o.box,_o.box)) then
					_o.furn=o
				elseif (_o.furn==o) then
					_o.furn=nil
				end
			end
		end
	end
	
	return c
end
-->8
-- door classes

function door(x,y)
	local c={}
	c.name='door'
	c.objects=nil
	c.sprt=13
	c.hlght=false
	c.currsprt=c.sprt
	c.x=x
	c.y=y
	c.w=1
	c.h=2
	c.box={x1=2,y1=0,x2=c.w*8-1,y2=c.h*8}
	
	c.start=function(o) end
	
	c.draw=function(o)
		if(o.hlght) then outln(o.sprt,8,o.x,o.y,o.w,o.h) end
		spr(o.currsprt,o.x,o.y,o.w,o.h)
	end
	
	c.update=function(o)
		highlight(o)
	end
	return c
end

function sidedoor(x,y)
	local c={}
	c.name='sidedoor'
	c.sprt=9
	c.hlght=false
	c.side=false
	c.x=x
	c.y=y
	c.w=1
	c.h=3
	c.opened=false
	c.box={x1=-2,y1=0,x2=c.w*8+1,y2=c.h*8}
	
	c.start=function(o) end
	
	c.draw=function(o)
		if(o.hlght) then outln(o.sprt,8,o.x-btoi(o.side and o.opened)*8,o.y,o.w,o.h,o.side) end
		spr(o.sprt,o.x-btoi(o.side and o.opened)*8,o.y,o.w,o.h,o.side)
	end
	
	c.update=function(o)
		if(o.opened!=true) then
			highlight(o)
		else
			highlight(o)
		end
	end
	
	c.opendoor=function(o,side)
		if(not o.opened) then
			o.opened=true
			o.sprt=21
			o.w=2
			o.side=side
		else
			o.opened=false
			o.sprt=9
			o.w=1
			o.side=side
		end
	end
		
	return c
end
-->8
--floor and room class

function floor(x,y,h)
	local c={}
	c.name='floor'
	c.w=128
	c.rw=61
	c.h=h
	c.x=x
	c.y=y
	
	c.box={x1=0,y1=0,x2=c.w,y2=c.h}
	c.lb={x1=0,y1=0,x2=c.rw,y2=c.h}
	c.rb={x1=66,y1=0,x2=66+c.rw,y2=c.h}
	
	c.open=false
	c.onfl=false
	c.cldn=2
	
	
	c.start=function(o)
		local f1=genfurn(o,true,true)
		local f2=genfurn(o,true,false)
		c.lrom=room(true,o,f1,f2)
		local f1=genfurn(o,false,true)
		local f2=genfurn(o,false,false)
		c.rrom=room(false,o,f1,f2)
		
		if(o.y==90) then o.lrom.light=true end
	end
	
	function genfurn(o,rlft,flft)
		if(#furns>0) then
			local f=furns[flr(rnd(#furns)+1)]
			del(furns,f)
			f.x+=btoi(rlft)*5+btoi(not rlft)*68+btoi(flft)*22+9

			f.y+=o.y+(o.h-45)
			return(f)
		end
		return nil
	end
	
	c.draw=function(o)
		o.lrom.draw(o.lrom)
		o.rrom.draw(o.rrom)
	end
	
	c.update=function(o)
		highlight(o)
		
		o.lrom.lit=false
		o.rrom.lit=false
		o.onfl=false
		for _o in all(objects) do
		 if(_o.name=='human') and (cantouch(o,_o,o.box,_o.box)) then
				o.onfl=true
				if(cantouch(o,_o,o.lb,_o.box)) then
					o.lrom.lit=true
				else
					o.rrom.lit=true
				end
			end
		end
		
		o.open=false
		for _o in all(objects) do
			if(_o.name=='sidedoor' and cantouch(o,_o,o.box,_o.box) and _o.opened) then
				o.open=true
			end
		end
					
		if(o.onfl and o.open) then
			o.lrom.lit=true
			o.rrom.lit=true
		end
		
		if(o.onfl) then
			o.cldn=2
			o.lclr=1
		elseif(o.cldn>0) then
			o.cldn-=1
		else
			o.lclr=0
		end
		c.lrom.update(c.lrom)
		c.rrom.update(c.rrom)
	end
	return c
end

function room(left,flor,furn1,furn2)
	local c={}
	c.flor=flor
	c.left=left
	
	c.light=false
	c.lit=false
	c.lclr=0
	c.cldn=6
	
	c.x=btoi(not left)*66
	c.y=flor.y
	c.w=61
	if(flor.y==3) then c.h=42 else c.h=35 end
	
	c.furns={furn1,furn2}
	
	c.draw=function(o)
		for furn in all(o.furns) do
			furn.draw(furn)
		end
	end
		
	c.update=function(o)
		if(o.lit) then
			o.light=true
			o.cldn=2
		elseif(o.cldn>0) then
			o.light=false
			o.cldn-=1
			o.lclr=1
		else
			o.lclr=0
		end
		for furn in all(o.furns) do
			furn.update(furn)
		end
	end
	
	return c
end

function darkness()
	local c={}
	
	c.start=function(o) end
	
	c.draw=function(o)
		line(0,45,61,45,6)
		line(66,45,128,45,6)
		rectfill(0,46,128,49,13)
		rectfill(0,47,128,48,5)
		line(63,49,64,49,5)
		
		line(0,85,61,85,6)
		line(66,85,128,85,6)
		rectfill(0,86,128,89,13)
		rectfill(0,87,128,88,5)
		line(63,89,64,89,5)
		
		for f in all(getflrs()) do
			if(not f.lrom.light) rectfill(f.x+f.lb.x1,f.y+f.lb.y1,f.x+f.lb.x2,f.y+f.lb.y2,f.lrom.lclr)
			if(not f.rrom.light) rectfill(f.x+f.rb.x1,f.y+f.rb.y1,f.x+f.rb.x2,f.y+f.rb.y2,f.rrom.lclr)
			if(not f.onfl) rectfill(f.x+62,f.y+f.h-22,f.x+65,f.y+f.h,f.lclr)  
		end
	end
	
	c.update=function(o) end
	
	return c
end
	
__gfx__
00000000000555555550000000000010000000105d200000000004d5555555555555555500066000000000000000000000000000dddddddd0000000000000000
00000000000555fff555000044444144444441445d202044444402d5dddddddddddddddd000dd000000000000dddddd99dddddd0d511115d0dddddd99dddddd0
0070070000005ff4ff55000042222144422220445d022044422220d54444444444444444000dd00000000000d55555544555555dd155551dd55555544555555d
0007700000005ff4ff55000022222022222220425d402022222204d50000000000000000000dd00000000000d52222255222225dd151151dd52222255222225d
00077000000599ffffff500000000000000000005d200000000004d50000000000000000000dd00000000000d54444444444445dd151151dd54444444444445d
007007000005999fffff500014444444144444445d202444044402d50222222202222222000dd00000000000d54111144111145dd151151dd54111145555545d
000000000005444fff5500001444422214444222d00222220444200d0222222202222222000dd00000000000d54161144161145dd151151dd54161145555545d
0000000000005fffff550000142222221422222222222222044442221444444414444444000dd00000000000d54161644161645dd151151dd54161644ff4f45d
000000000000544fff55000000001000000000000006600ddddddd000000000000000000000dd00000000000d54555544555545dd151191dd54555544994f45d
0000000000005fff550050004441444444414444000d511111115d100000000000000000000dd00000000000d54116144111c45dd151151dd5411614f44ff45d
0000000000d05555050050002221444222214442000d151111151d100000000000000000000dd00000000000d5461614416cc45dd151151dd5461614f44ff45d
00000000006df50005ff50002220422222204222000d115555511d100000000000000000000dd00000000000d545555445ddd45dd151151dd5455554fffff45d
00000000006df50005ff50000000000100000001000d115111511d10000000000000000000adda0000000000d5411164accc745dd151151dd5411164f44f545d
0000000000d05555555500004444441444444414000d115111511d100000000000000000009dd90000000000d54161699c7c745dd155551dd5416169ffff5499
0000000000000550055500004444220244442202000d115111511d100000000000000000009dd90000000000d545555a4dddd45dd511115dd545555a555504ad
0000000000001110011100002222220422222202000d115111511d100000000000000000000dd00000000000d54111c44cccc45dddddddddd54111c40000045d
0000000000000555555000000000000000000000000d115111511d100000000000000000000dd00000000000d5416cc44c7cc45d00000000d5416cc40000045d
0000000000005555555500004441444442221444000d115111511d100000000000000000000dd00007808800d545ddd44dddd45d00000000d545ddd40000045d
0000000000005f4ff4f500002221442222221442000d1151119a1d100000000000000000000dd00078888880d54cc7c44ccc145d00000000d54cc7c45555545d
0000000000005f4994f500006666666666666666000d115111991d100000000000000000000dd00088888880d54cc7c44c76145d00000000d54cc7c45545545d
000000000005fff44fff50006666666666666666000d115111511d100000000000000000000dd00008888800d54dddd44d55545d00000000d54dddd411d1145d
000000000005fff44fff50006666666666666666000d115111511d100000000000000000001dd10000888000d54444444444445d00000000d54444444444445d
0000000000005ffffff55000dddddddddddddddd000d115111511d100000000000000000001dd10000080000d52222222222225d00000000d52222222222225d
0000000000005ff44f5ff5005555555555555555000d115111511d100000000000000000001dd100000000001122222222222211000000001122222222222211
00000000000055ffff5ff5005555555555555555000d115111511d10000000000000000000011000000000000000100000000000000000000000000000000000
000000000000dd5555005500ddddddd55ddddddd000d115555511d1000000000000000000016610007b0bb004441444444414444000000000000000000000000
00000000000d66d000005000444444d55d444444000d151111151d10000000000000000001999a107bbbbbb02221444222214442000000000000000000000000
00000000000d66d000050000000000d55d000000000d511111115d10000000000000000001999a10bbbbbbb06666666666666666000000000000000000000000
000000000000dd0000050000000000d55d000000000ddddddddddd10000000000000000001555d100bbbbb006666666666666666000000000000000000000000
000000000000055555550000022202d55d202222000000000000000000000000000000000155661000bbb0006666666666666666000000000000000000000000
000000000000055505550000022220d55d0222220000000000000000000000000000000001555d10000b0000dddddddddddddddd000000000000000000000000
000000000000011101110000144404d55d4044440000000000000000000000000000000000111100000000005555555555555555000000000000000000000000
00000000000000000000000000000000111111111111111100000000eee000000000000011100000000000000000000000000011111000000000001111000000
000000000000000000000000000000001cccccccccccccc10e0000ee888e000001000011ccc100000000011111100000000001aaaaa100000000114994110000
000011111111000000001111111100001cccccccccccc771e8e00e878888e0001c1001c7cccc100000001cccccc1000000001ccccccc10000001445555441000
000133bbbb331000000133bbbb3310001c777ccccccc7771e8e0e8778878e0001c101c77cc7c10000001cc1111cc10000001aaaaaaaaa1000014457777544100
00013bbbbbb3100000013bbbbbb31000177777ccccc77771e88e88788778e0001cc1cc7cc77c100000001cc11cc100000001ccccccccc1000144577577754410
0001bbbbbbbb10000001bbbbbbbb10001777777ccccc77710e8e88788788e00001c1cc7cc7cc1000000001cccc1000000001aaaaaaaaa1000145777577775410
0001bbbbbbbb10000001bbbbbbbb10001c7777ccccccccc100e887787788e0e0001cc77c77cc1010000001aaaa1000000001ccccccccc1000145777577775410
0001bbbbbbbb100000011111111110001cccccccbcccccc100e888888888ee8e001ccccccccc11c1000001cccc10000000001aaaaaaa10000145777757775410
01113bbbbbb3111001113555555311101ccccccbbbccccc100e888878888888e001cccc7ccccccc100001aaaaaa10000000001ccccc100000145777775775410
1bb1333bb3331bb11bb1555555551bb11ccccccc4cccccc100e88877788eeeee001ccc777cc111110001cccccccc1000000001aaaaa100000145577777755410
13b1111111111b3113b15f4ff4f51b311cccccc4cc9999910e888777888e000001ccc777ccc100000001aaaaaaaa1000000001ccccc100000144557777554410
13b1333333331b3113b15f4994f51b3119999cc4c9aaaaa1e88887788888e0001cccc77ccccc10000001cccccccc100000001cc000cc10000114455555544110
1b311111111113b11b311111111113b11aaa99999aaaaaa1e88888888888e0001ccccccccccc10000001aaaaaaaa100000001500000510001444444444444441
1b333333333333b11b333333333333b11aaaaaaaa99aaaa10e88888888ee000001cccccccc11000000001cccccc1000000001555555510000155555555555510
111111111111111111111111111111111aaaaaaaaaa9aaa100ee8888ee0000000011cccc11000000000001aaaa1000000000155505551000014dddddddddd410
0100000000000010010000000000001011111111111111110000eeee00000000000011110000000000000011110000000000011101110000014d59191591d410
0000060000000000000006000000000011111111111111110000000033300000000000009990000000000111110000000000111111110000014d59191591d410
000000600600000000000060060000001cccccccccccccc103000033bbb3000009000099aaa9000000001222221000000001222222221000014d59191591d410
000000066000000000000006600000001cccccccccccc7713b3003b7bbbb30009a9009a7aaaa900000001e2e2e1000000001222222221000014d59191591d410
000000666600000000000066660000001c777ccccccc77713b303b77bb7b30009a909a77aa7a90000001e2eee2e100000012222222222100014d591915a1d410
000dddddddddd000000dddddddddd000177777ccccc777713bb3bb7bb77b30009aa9aa7aa77a90000001e2eee2e100000012222222222100014d59191551d410
00d6555555666d0000d6555555666d001777777ccccc777103b3bb7bb7bb300009a9aa7aa7aa900000012222222100000012222222222100014d5a191555d410
00d57777c2576d0000d57777ff576d001c7777ccccccccc1003bb77b77bb3030009aa77a77aa909000001117111000000001111111111000014d55191555d410
00d579abc2566d0000d574ff4f566d001cccccc55cccccc1003bbbbbbbbb33b3009aaaaaaaaa99a9000000161000000000015ffffff51000014d555a1555d410
00d579abc2576d0000d574994f576d001ccccc5ff5ccccc1003bbbb7bbbbbbb3009aaaa7aaaaaaa9000000161000000000015ff44ff51000014d55aaa555d410
00d589abc2566d0000d5ff44ff566d001ccccc5ff5ccccc1003bbb777bb33333009aaa777aa999990000001510000000000015ffff510000014d555a1155d410
00d589abc2576d0000d5ff44ff576d001cccccf55f99999103bbb777bbb3000009aaa777aaa9000000000015100000000001505555051000014d55551555d410
00d6555555666d0000d6555555666d0019999cf00faaaaa13bbbb77bbbbb30009aaaa77aaaaa9000000000151000000000015f0000f51000014dddddddddd410
000dddddddddd000000dddddddddd0001aaa99911aaaaaa13bbbbbbbbbbb30009aaaaaaaaaaa9000000000151000000000015f0000f510000144444444444410
0000d000000d00000000d000000d00001aaaaaa9999aaaa103bbbbbbbb33000009aaaaaaaa990000000000151000000000001555555100000144551111554410
000d00000000d000000d00000000d0001aaaaaaaaaa9aaa10033bbbb330000000099aaaa99000000000001151100000000001555555100000144551001554410
00000000000000000000000000000000111111111111111100003333000000000000999900000000000015555510000000001551155100000111110000111110
00000000000000000000000000000000000005555550000000000000000000000000000000000000001110000001110000000111111000000000001111000000
00001111000000000000111100000000000055555555000000000000000000000000000000000000001511111111510000001555555100000000114994110000
00015555100000000001555510000000000055555555000000000000000000000000000000000000001455555555410000015f4ff4f510000001445555441000
00015ac51110000000015ac511100000000055555555000000000000000000000000000000000000015557555575551000015f4994f510000014457777544100
00015ed51aa1000000015ed51aa10000000f55555555f000000011111000000000000000000000000155ee5445ee55100015fff44fff51000144577577754410
00015555199910000001555519991000000f55555555f00000012eee21000000000000000000000001555555555555100015fff44fff51000145777577775410
0014444444444100001444444444410000005555555500000012eeeee10000100000000000000010001555577555510000015ffffff510000145777577775410
001466666666410000146666666641000000f555555f0000001eeeeee21011510000000000001151000115555551100000015ff44ff510000145777757775410
001455555555410000145555555541000000ffffffff0000011eeeeeee21225101111111111122510015111111115100001515ffff5151000145777775775410
001435155555410000145f4ff4f54100000500ffff0050001eeeeeeeeee722511eeeeeeeeee72251015515544551551001551155551155100145577777755410
00143913e555410000143f4994f5410000050000000050001ee2eeeee2e722511eeeeeeeeee72251011515444451511001151511115151100144557777554410
00143913e335410000143ef44f33410000005000000500001eee22ee2ee722411eeeeeeeeee72241011111444411111001111144441111100114455555544110
00146666666641000014666666664100000050000005000012222222222622411222222222262241000155144155100000015514415510001444444444444441
00144444444441000014443334444100000005555550000014444444444444411444444444444441001115155151110000111515515111000155555555555510
0014111111114100001419911eee410000000550055000001411111111111141141111111111114100111111111111000011111111111100014dddddddddd410
0001000000001000000101111111100000000110011000000100000000000010010000000000001000011100001110000001110000111000014d55555555d410
0000001100000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014d5f4ff4f5d410
000001ee1000000000001ee10110000000000000000000000000000000000000000000000000000000000000000000000000000000000000014d5f4994f5d410
00001eee210000000001eee21551100000000000000000000000000007777777777777777700000000000000000000000000000000000000014dfff44fffd410
00001ee2100000000001ee21f4f5100000000000000000000000000007000077000000000707777777770000000000000000000000000000014dfff44fffd410
00001124111000000001124994f51000000000000000000000000000770660770666666a0777000000077000000000000000000000000000014d5ffffff5d410
000141141bb100000015fff44fff5100000000000000000777777700700660770666a6660000066666007700000000000000000000000000014df5f44f5fd410
0000144444bb10000015fff44ff551000000000000000007000007007066600006a6a6660a00666666600700000000000000000000000000014df5ffff5fd410
0000011413bb100000015fffff5bb50000000000000000070666070070666006666666a66000666666660707777700000000000000000000014d00555500d410
0000001413bb100000015ff44f5fbb100000000077777777066607707066600a66a9a9666000666666660777000777000000000000000000014d00000000d410
0000001413bb1000000155ffff5fbb100000000770000007066600707066600666aaaaaa6000666006660070060007770000000000000000014d50000005d410
0000001413bb1000001550555500bb1000000077006666000666607070666066669aaaaa6000666000666000666600077000000000000000014d50000005d410
0000001413bb10000015f0000000bb10000007700666666006666070706a606aa6aaaaaa6600666000666006666666007700000000000000014dddddddddd410
0000001411b100000015f0000000bb100000770066666666066660777066606666aaaaaa66066660006660066666666007700000000000000144444444444410
0000001411100000000155555555bb100000700666666666066660077066606669aaaaa966066660006660006666666600770000000000000144551111554410
0000014441000000000015550555b100000770666666666600666607706660666aaaaaa660066600066660700666666660077000000000000144551001554410
00001444441000000000011101111000000700666660066600666607706660666aaaaaa660066600066000770066666666007700000000000111110000111110
00011111111100000001111111111100000706666600066000666607706660aa6aaaaaa660066666000077770066666666600700000000000000000000000000
00177777777d1000001d55555516710000070666660000000006660000666066aaaaaaa660066666000077700666666666660700000000000000000000000000
00176666666d10000015555555167100000706666600000000066666666660666aaaaaaa60006666666077706666600666660700000000000000000000000000
00176666666d10000015f4ff4f167100000700666600666660066666666660666aaaaa9660000666666007006666000006660700000000000000000000000000
001711d6666d10000015f4994f167110000770666600666666006666666660666aaaaa666000a006666607066660077700600700000000000000000000000000
001ddddddddd1000001fff44ff167100000070066660066666606660006660666aaaaa66600a0000666600066660777770007700000000000000000000000000
00111111111110000011111111111100000077066666006666606660000660a6a9aaa96a60666000666600666600777777777000000000000000000000000000
00177777777d100000177777777d1000000007006666666666600666000666066666666600666606666600666007770000700000000000000000000000000000
00176666666d100000176666666d10000000077006aaa666aaaaaaaaa0aaaaaaaaaa66aaa0066666aaaaa06aa077770aa0700000000000000000000000000000
001711d6666d1000001711d6666d10000000007700aaaa66aaaaaaaaa0aaaaaaaaaa6aaaaa00666aaaaaa0aaa077700aa0700000000000000000000000000000
0017ddd6666d10000017ddd6666d1000000000770aaaaa00aa0aaaaaa0000aaaaaa00aaaaa0000aaaa0aa0aaa00000aaa0700000000000000000000000000000
00176666666d100000176666666d1000000000700aa0aaa0000aaa0000770aaa00000aa0aaa000aaa00000aaa00a00aaa0700000000000000000000000000000
00176666666d100000176666666d100000000770aaa0aaa0770aaa0777770aaa0770aaa0aaa00aaa007770aaa0aaa0aaa0700000000000000000000000000000
00176666666d100000176666666d100000000700aaa00aa0070aaa0700070aaa0700aaa00aa00aaa077770aaaaaaa0aaa0700000000000000000000000000000
001ddddddddd1000001ddddddddd10000000070aaaaaaaaa070aaa0700070aaa070aaaaaaaaa0aaa077770aaaaaa00aaa0700000000000000000000000000000
001111111111100000111111111110000000770aaaaaaaaa070aaa0700070aaa070aaaaaaaaa0aaa000000aaaa0000aaa0700000000000000000000000000000
000000000000000000000000000000000000700aaaaaaaaa070aaa0700070aaa000aaaaaaaaa0aaa00aaa0aaaaa0000000700000000000000000000000000000
00000000000000000000000000000000000070aaa00000aa070aaa0700070aaa00aaa00000aa00aaaaaaa0aaaaaaa00a00700000000000000000000000000000
00000000000000000000000000000000000070aaa07770aa070aa00700070aa000aaa07770aa00aaaaaa00aaa0aaa0aaa0700000000000000000000000000000
00000000000000000000000000000000000070aa0070700a070aa07700070aa070aa0070700a0000aa00000aa00aa00aa0700000000000000000000000000000
00000000000000000000000000000000000070000770770007000070000700007000077077000770000777000000000000700000000000000000000000000000
00000000000000000000000000000000000077777700077777777770000777777777770007777777777707777777777777700000000000000000000000000000
__map__
2000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0707070707070733340707070707070700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040306050403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141313141413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040303040303040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3c3b3c3b3c3b3c3b3c3b3c3b3c3b3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0708070807080733340807080708070800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141306051413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040304030403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3c3b3c3b3c3b3c3b3c3b3c3b3c3b3c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0708080708070833340708070807080700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040306050403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1314131413141314131413141314131400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0304030403040303040403040304030400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3c3b3c3b3c3b3c3b3c3b3c3b3b3c3b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00030000075500d5301350015500185001a5001c5001d5001e5001f5002050020500205001f5001d5001b50019500000000000000000000000000000000000000000000000000000000000000000000000000000
0002000009610096100962018200182000d6500d6500d6500e20011200172001f2002020000100001000010000100002000020000200002000020000200002000020012500125001350000000000000000000000
00040000041200512006120091201b1201f0203400012200122001220013200142001520015200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00040000000002c7501875009750047500105002050060500a050247000000021700000001f700000001c70000000000001970000000157000000011700000000f7000d7000b7000b70000000000000000000000
0006000025720157201272013700067200572003020000200002000000147002ea002da002da002ca002ca002ca002ca002ba002ba002ba002ba002aa002aa002aa0029a0029a0029a0029a0029a0028a0028a00
00030000257202d720245201a520135200e5200a52006520030500105000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000600000c6100c6000c610076000660006610066000661000000076000c6100a6000c61000000000000661000000066100660000000000000000000000000000000000000000000000000000000000000000000
000a00000a05015050100501b05001000000000b0000a000080000700007000070003c2003b2003b200132003b2003b2003b2001b2003a2003a2003a2003a2003b2003b2003b2003b2003b2003c2003c20000000
0003000005020100201a0201f02024020280202d02031020330203402034020330202f0202a020220201800013000100000b0000b0000a000080000600005000050000600005000040000400004000050001a000
0005021f1802016020140201202010020100200f0200f0200f0200f0201002012020130201502017020190201a0201c0201d0201e0201f0201f0201f0201f0201e0201e0201d0201c0201b0201a0201802023000
000300000c640266102c61023610326002a6002c60027600035000350003500030000300000000075500d55007500000000000000000000000000000000000000000000000000000000000000000000000000000
0003000011320163201a3201e3201d320173200b32007320043200132000320003200004000040000000000000000000300003000000000000000000000000000000000010000100000000000000000000000000
0002021f1802016020140201202010020100200f0200f0200f0200f0201002012020130201502017020190201a0201c0201d0201e0201f0201f0201f0201f0201e0201e0201d0201c0201b0201a0201802023000
0013001f0401004010040100450404500045050401004010040100450404500045050401004010040101f0101f0101f0101e0101e010006040060000600006000060000600006000060502010020100201000000
911800080001300015000000070000013000150170002700000000270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00080002300025000000070000023000250170002700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 0d424344

