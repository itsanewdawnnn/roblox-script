local TS,RS,UIS,Players,VU,Lt = game:GetService("TweenService"),game:GetService("RunService"),game:GetService("UserInputService"),game:GetService("Players"),game:GetService("VirtualUser"),game:GetService("Lighting")
local LP,PG = Players.LocalPlayer,nil
LP = Players.LocalPlayer; PG = LP:WaitForChild("PlayerGui")
local FW,FH,HH,SW,MS,BS,BG,CR = 380,300,42,40,48,26,6,12
local anim,mini,savedPos = false,false,nil
local maid,tpMaid,charConns,ncSet,ncOrig = {},{},{},{},{}
local F = {ij=false,sp=false,nc=false}
local DEF_SPD,bstSpd = 16,1000
local Teleports,refreshTP,closeGUI = {},nil,nil
local rebind,kbLabels,kbHints = nil,{},{}
local toastQ,toastOn,thumbCache,cachedHrp = {},false,{},nil
local Kb = {minimize=Enum.KeyCode.F5,ij=Enum.KeyCode.F6,sp=Enum.KeyCode.F7,nc=Enum.KeyCode.F8}
local C = {
	bg=Color3.fromRGB(15,17,23),cd=Color3.fromRGB(22,26,36),hd=Color3.fromRGB(18,21,30),
	bd=Color3.fromRGB(36,42,58),t1=Color3.fromRGB(235,240,255),t2=Color3.fromRGB(140,155,185),
	mu=Color3.fromRGB(70,82,110),gr=Color3.fromRGB(50,215,145),yl=Color3.fromRGB(255,210,60),
	rd=Color3.fromRGB(150,80,80),ov=Color3.fromRGB(32,38,54),bl=Color3.fromRGB(90,165,255),
	sa=Color3.fromRGB(28,34,50),
}

local OPT = {on=false,busy=false}
local OPT_BATCH,OPT_WATCH_BATCH,OPT_REAPPLY_SEC,OPT_DIRTY = 100,30,60,false
local NPC_STATES = {Enum.HumanoidStateType.Climbing,Enum.HumanoidStateType.Swimming,Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.Ragdoll,Enum.HumanoidStateType.StrafingNoPhysics,Enum.HumanoidStateType.RunningNoPhysics}
local OPT_SKIP = {Folder=true,Model=true,Script=true,LocalScript=true,ModuleScript=true,Configuration=true,StringValue=true,NumberValue=true,BoolValue=true,ObjectValue=true,IntValue=true,CFrameValue=true,Vector3Value=true,Color3Value=true,RayValue=true,BindableEvent=true,BindableFunction=true,RemoteEvent=true,RemoteFunction=true,Camera=true,Animator=true,AnimationController=true,BodyGyro=true,BodyPosition=true,BodyVelocity=true,Weld=true,WeldConstraint=true,Motor6D=true,Attachment=true}
local optCharSet,optCharCache,optChainBuf = {},{},{}

local function optInvalidateChar(c)
	for k in next,optCharCache do
		if typeof(k)=="Instance" then local ok,r=pcall(function()return k:IsDescendantOf(c)end);if ok and r then optCharCache[k]=nil end end
	end
	optCharCache[c]=nil
end
local function optInChar(i)
	local cn,par=0,i.Parent
	while par and par~=workspace and par~=game do
		local cached=optCharCache[par]
		if cached~=nil then for idx=1,cn do optCharCache[optChainBuf[idx]]=cached end;return cached end
		cn+=1;optChainBuf[cn]=par
		if optCharSet[par] then for idx=1,cn do optCharCache[optChainBuf[idx]]=true end;return true end
		par=par.Parent
	end
	for idx=1,cn do optCharCache[optChainBuf[idx]]=false end;return false
end
local function optTrack(pl)
	if pl.Character then optCharSet[pl.Character]=true end
	pl.CharacterAdded:Connect(function(c) optCharSet[c]=true;optInvalidateChar(c) end)
	pl.CharacterRemoving:Connect(function(c) optCharSet[c]=nil;optInvalidateChar(c) end)
end
for _,pl in ipairs(Players:GetPlayers()) do optTrack(pl) end
Players.PlayerAdded:Connect(optTrack)
Players.PlayerRemoving:Connect(function(pl) if pl.Character then optCharSet[pl.Character]=nil;optInvalidateChar(pl.Character) end end)

local function optApplyOne(obj)
	if not obj or not obj.Parent or optInChar(obj) then return end
	if obj:IsA("SpecialMesh") then pcall(function()obj.TextureId=""end);return end
	if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") or obj:IsA("WrapLayer") or obj:IsA("WrapTarget") or obj:IsA("SurfaceAppearance") then
		if obj.Parent and not optInChar(obj) then pcall(function()obj:Destroy()end) end;return
	end
	if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Trail") or obj:IsA("Highlight") then
		if obj.Parent and not optInChar(obj) then pcall(function()obj:Destroy()end) end;return
	end
	if obj:IsA("Beam") then pcall(function()obj.Enabled=false;obj.Segments=1 end)
	elseif obj:IsA("Decal") or obj:IsA("Texture") then pcall(function()obj.Transparency=1 end)
	elseif obj:IsA("Light") then pcall(function()obj.Shadows=false end)
	elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then pcall(function()obj.Enabled=false end)
	elseif obj:IsA("Sound") then pcall(function()obj.Volume=0 end)
	elseif obj:IsA("BasePart") and not obj:IsA("Terrain") then
		pcall(function()
			obj.CastShadow=false;obj.Material=Enum.Material.SmoothPlastic
			if obj:IsA("MeshPart") or obj:IsA("UnionOperation") then
				obj.RenderFidelity=Enum.RenderFidelity.Performance
				if obj:IsA("MeshPart") then obj.DoubleSided=false;obj.TextureID="" end
				if not obj.CanCollide then obj.CollisionFidelity=Enum.CollisionFidelity.Box end
			end
			if obj.Transparency>0 and obj.Transparency<1 then obj.Transparency=1 end
		end)
	elseif obj:IsA("Humanoid") then
		pcall(function()
			obj.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.None;obj.HealthDisplayDistance=0;obj.NameDisplayDistance=0
			if not optCharSet[obj.Parent] then for _,st in ipairs(NPC_STATES) do pcall(function()obj:SetStateEnabled(st,false)end) end end
		end)
	end
end

local function optSetupLighting()
	pcall(function()
		Lt.GlobalShadows=false;Lt.Technology=Enum.Technology.Compatibility;Lt.ExposureCompensation=0
		Lt.EnvironmentDiffuseScale=0.6;Lt.EnvironmentSpecularScale=0.2
		Lt.FogEnd=800;Lt.FogStart=560;Lt.FogColor=Color3.fromRGB(180,200,220)
	end)
	for _,ch in ipairs(Lt:GetChildren()) do
		if ch:IsA("PostEffect") then if not ch:IsA("ColorCorrectionEffect") then pcall(function()ch.Enabled=false end) end
		elseif ch:IsA("Atmosphere") then pcall(function()ch.Density=0 end)
		elseif ch:IsA("Clouds") then pcall(function()ch.Enabled=false end) end
	end
	pcall(function()
		local t=workspace:FindFirstChildOfClass("Terrain")
		if t then t.WaterWaveSize=0;t.WaterWaveSpeed=0;t.WaterReflectance=0;t.WaterTransparency=1;t.Decoration=false end
	end)
	pcall(function()workspace.GlobalWind=Vector3.zero end)
	pcall(function()settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end)
	pcall(function()settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level04 end)
end

local function optRunAll()
	if OPT.busy then return end
	OPT.busy=true;OPT_DIRTY=false
	optSetupLighting()
	task.spawn(function()
		pcall(function()
			local d=workspace:GetDescendants();local total=#d
			for i=1,total,OPT_BATCH do
				if not OPT.on then break end
				for j=i,math.min(i+OPT_BATCH-1,total) do local obj=d[j];if obj and obj.Parent and not OPT_SKIP[obj.ClassName] then optApplyOne(obj) end end
				RS.Heartbeat:Wait()
			end
		end)
		OPT.busy=false
	end)
end

local optWatchQ,optWatchHead={},1
workspace.DescendantAdded:Connect(function(i) optWatchQ[#optWatchQ+1]=i;OPT_DIRTY=true end)
RS.Heartbeat:Connect(function()
	local total=#optWatchQ
	if optWatchHead>total then optWatchHead=1;table.clear(optWatchQ);return end
	local limit=math.min(optWatchHead+OPT_WATCH_BATCH-1,total)
	for idx=optWatchHead,limit do local i=optWatchQ[idx];optWatchQ[idx]=nil;if i and i.Parent and not OPT_SKIP[i.ClassName] and not optInChar(i) and OPT.on then pcall(optApplyOne,i) end end
	optWatchHead=limit+1;if optWatchHead>total then optWatchHead=1;table.clear(optWatchQ) end
end)

local function optStartReapplyLoop()
	task.spawn(function()
		while OPT.on do task.wait(OPT_REAPPLY_SEC);if OPT.on and not OPT.busy and OPT_DIRTY then optRunAll() end end
	end)
end

local N=function(c,pr,par) local o=Instance.new(c);for k,v in pairs(pr) do o[k]=v end;o.Parent=par;return o end
local rc=function(o,r) N("UICorner",{CornerRadius=r and UDim.new(0,r) or UDim.new(1,0)},o) end
local TI={}
local function tw(o,pr,d) local ti=TI[d or.2];if not ti then ti=TweenInfo.new(d or.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out);TI[d or.2]=ti end;TS:Create(o,ti,pr):Play() end
local function mc(s,f) local c=s:Connect(f);maid[#maid+1]=c;return c end
local u2=function(x,y,x2,y2) return UDim2.new(x,y,x2 or 0,y2 or 0) end
local function fill(pr,t) return N("Frame",{Size=t.s or UDim2.new(1,0,1,0),Position=t.p or UDim2.new(),BackgroundColor3=t.c,BorderSizePixel=0,ZIndex=t.z or 5},pr) end
local function fc(f) return f>=55 and C.gr or f>=30 and C.yl or Color3.fromRGB(255,75,75) end
local function hover(b,c1,c2,tc1,tc2)
	mc(b.MouseEnter,function()tw(b,{BackgroundColor3=c2,TextColor3=tc2 or b.TextColor3},.1)end)
	mc(b.MouseLeave,function()tw(b,{BackgroundColor3=c1,TextColor3=tc1 or b.TextColor3},.1)end)
end
local fps={n=0,t=tick(),v=-1,last=-1}
local function ft()
	fps.n+=1;local now=tick()
	if now-fps.t>=.5 then fps.v=math.floor(fps.n/(now-fps.t)+.5);fps.n=0;fps.t=now end;return fps.v
end
local function cleanCC() for _,c in pairs(charConns) do c:Disconnect() end;charConns={} end
local function tpTo(cf) local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart");if hrp then hrp.CFrame=cf end end
local function restoreCol() for pt,o in pairs(ncOrig) do if pt.Parent then pt.CanCollide=o end end;ncOrig={} end
local function applySpd() local c=LP.Character;if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed=F.sp and bstSpd or DEF_SPD end end
local function resetCam() local c=LP.Character;if c then local h=c:FindFirstChild("HumanoidRootPart");if h then workspace.CurrentCamera.CameraSubject=h end end end

for _,u in pairs(PG:GetChildren()) do if u.Name=="UOpt" then u:Destroy() end end
local sg=N("ScreenGui",{Name="UOpt",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999},PG)
maid[#maid+1]=sg

local function toast(msg,col)
	if #toastQ>=4 then table.remove(toastQ,1) end;toastQ[#toastQ+1]={m=msg,c=col or C.bl}
	if toastOn then return end;toastOn=true
	task.spawn(function()
		while #toastQ>0 do
			local t=table.remove(toastQ,1);if not sg.Parent then toastOn=false;return end
			local f=N("Frame",{Size=u2(0,220,0,32),Position=u2(.5,-110,1,10),BackgroundColor3=C.hd,BorderSizePixel=0,ZIndex=50},sg);rc(f,8)
			N("UIStroke",{Color=t.c,Thickness=1,Transparency=.3},f)
			rc(fill(f,{s=u2(0,3,0,18),p=u2(0,8,.5,-9),c=t.c,z=51}),2)
			N("TextLabel",{Size=u2(1,-22,1,0),Position=u2(0,16,0,0),BackgroundTransparency=1,Text=t.m,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=51},f)
			tw(f,{Position=u2(.5,-110,1,-42)},.25);task.wait(#toastQ>0 and .7 or 1.2)
			tw(f,{Position=u2(.5,-110,1,10),BackgroundTransparency=1},.25);task.wait(.3);f:Destroy()
		end;toastOn=false
	end)
end

local mn=N("Frame",{Size=u2(0,FW,0,FH),Position=u2(.5,-FW/2,.5,-FH/2),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Active=true},sg)
rc(mn,CR);N("UIStroke",{Color=C.bd,Thickness=1},mn)

local hd=N("Frame",{Size=u2(1,0,0,HH),BackgroundColor3=C.hd,BorderSizePixel=0,ZIndex=10},mn);rc(hd,CR)
fill(hd,{s=u2(1,0,0,CR),p=u2(0,0,1,-CR),c=C.hd,z=10});fill(hd,{s=u2(1,0,0,1),p=u2(0,0,1,0),c=C.bd,z=11})
rc(fill(hd,{s=u2(0,22,0,3),p=u2(0,SW+8,1,-2),c=C.bl,z=12}),2)
N("TextLabel",{Size=u2(0,150,0,16),Position=u2(0,SW+8,.5,-8),BackgroundTransparency=1,Text="Roblox Tools",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},hd)
local fb=fill(hd,{s=u2(0,54,0,22),p=u2(1,-(BG*3+BS*2+54),.5,-11),c=C.cd,z=12});rc(fb,6)
local fL=N("TextLabel",{Size=u2(1,0,1,0),BackgroundTransparency=1,Text="--",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.gr,ZIndex=13},fb)
local function hBtn(x,bg2,tx,ts,tc)
	local b=N("TextButton",{Size=u2(0,BS,0,BS),Position=u2(1,x,.5,-BS/2),BackgroundColor3=bg2,BorderSizePixel=0,Text=tx,Font=Enum.Font.GothamBold,TextSize=ts,TextColor3=tc,AutoButtonColor=false,ZIndex=12},hd);rc(b,6);return b
end
local miB=hBtn(-(BG*2+BS*2),C.cd,"–",15,C.t2)
local clB=hBtn(-(BG+BS),Color3.fromRGB(110,30,42),"×",16,Color3.fromRGB(255,200,200))

local sb=N("Frame",{Size=u2(0,SW,1,-HH),Position=u2(0,0,0,HH),BackgroundColor3=C.cd,BorderSizePixel=0,ZIndex=5},mn);rc(sb,CR)
fill(sb,{s=u2(1,0,0,CR),c=C.cd});fill(sb,{s=u2(0,CR,0,CR),p=u2(1,-CR,1,-CR),c=C.cd});fill(sb,{s=u2(0,1,1,0),p=u2(1,0,0,0),c=C.bd,z=6})
local si=fill(sb,{s=u2(0,3,0,22),p=u2(0,0,0,11),c=C.bl,z=8});rc(si,2)
local function sBtn(y,ic)
	local b=N("TextButton",{Size=u2(0,30,0,30),Position=u2(.5,-15,0,y),BackgroundColor3=C.sa,BorderSizePixel=0,Text=ic,Font=Enum.Font.Gotham,TextSize=15,TextColor3=C.t2,AutoButtonColor=false,ZIndex=7},sb);rc(b,8);hover(b,C.sa,C.ov,C.t2,C.t1);return b
end
local sideButtons={}
for _,d in ipairs{{"opt",6,"⚡"},{"tools",42,"🔧"},{"loc",78,"📍"},{"players",114,"👥"},{"more",150,"🔗"}} do sideButtons[d[1]]=sBtn(d[2],d[3]) end

local ct=N("Frame",{Size=u2(1,-SW,1,-HH),Position=u2(0,SW,0,HH),BackgroundColor3=C.bg,BorderSizePixel=0,ZIndex=5},mn);rc(ct,CR)
fill(ct,{s=u2(1,0,0,CR),c=C.bg});fill(ct,{s=u2(0,CR,0,CR),p=u2(0,0,1,-CR),c=C.bg})

local function mkPageHdr(par,txt)
	local bar=N("Frame",{Size=u2(1,-14,0,28),Position=u2(0,7,0,6),BackgroundColor3=C.hd,BorderSizePixel=0,ZIndex=7},par);rc(bar,8)
	N("UIStroke",{Color=C.bd,Thickness=1,Transparency=.5},bar)
	N("TextLabel",{Size=u2(1,-12,1,0),Position=u2(0,10,0,0),BackgroundTransparency=1,Text=txt,Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},bar)
end
local function mkScroll(par,off)
	local s=N("ScrollingFrame",{Size=u2(1,0,1,-(off or 0)),Position=u2(0,0,0,off or 0),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=C.bl,CanvasSize=u2(),BorderSizePixel=0,ZIndex=6},par)
	N("UIPadding",{PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,7),PaddingRight=UDim.new(0,7)},s)
	local l=N("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},s)
	mc(l:GetPropertyChangedSignal("AbsoluteContentSize"),function()s.CanvasSize=u2(0,0,0,l.AbsoluteContentSize.Y+16)end);return s
end
local function mkSec(par,txt,ord) return N("TextLabel",{Size=u2(1,0,0,14),BackgroundTransparency=1,Text=txt,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,LayoutOrder=ord},par) end
local function mkRow(par,ord,h) local r=N("Frame",{Size=u2(1,0,0,h or 32),BackgroundColor3=C.cd,BorderSizePixel=0,ZIndex=7,LayoutOrder=ord},par);rc(r,8);N("UIStroke",{Color=C.bd,Thickness=1,Transparency=.4},r);return r end
local function mkSBtn(par,txt,pos,sz,c1,c2,cb) local b=N("TextButton",{Size=sz,Position=pos,BackgroundColor3=c1,BorderSizePixel=0,Text=txt,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,AutoButtonColor=false,ZIndex=9},par);rc(b,6);hover(b,c1,c2);if cb then mc(b.MouseButton1Click,cb) end;return b end
local function mkInput(row,def,xpos)
	local bg2=N("Frame",{Size=u2(0,42,0,22),Position=u2(1,xpos or -162,.5,-11),BackgroundColor3=C.sa,BorderSizePixel=0,ZIndex=8},row);rc(bg2,6)
	N("UIStroke",{Color=C.bd,Thickness=1,Transparency=.5},bg2)
	local box=N("TextBox",{Size=u2(1,-6,1,0),Position=u2(0,3,0,0),BackgroundTransparency=1,Text=tostring(def),Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.bl,PlaceholderText=tostring(def),PlaceholderColor3=C.mu,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Center,ZIndex=9},bg2)
	mc(box.Focused,function()tw(bg2,{BackgroundColor3=Color3.fromRGB(35,42,62)},.1)end)
	mc(box.FocusLost,function()tw(bg2,{BackgroundColor3=C.sa},.15)end);return box
end
local toggleUpd={}
local function mkToggle(par,ord,label,key,kbKey)
	local row=mkRow(par,ord)
	N("TextLabel",{Size=u2(1,-110,1,0),Position=u2(0,10,0,0),BackgroundTransparency=1,Text=label,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},row)
	local kbH=N("TextLabel",{Size=u2(0,44,1,0),Position=u2(1,-106,0,0),BackgroundTransparency=1,Text=kbKey and(" ["..Kb[kbKey].Name.."]")or"",Font=Enum.Font.Gotham,TextSize=8,TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=8},row)
	if kbKey then kbHints[kbKey]=kbHints[kbKey] or{};kbHints[kbKey][#kbHints[kbKey]+1]=kbH end
	local btn=N("TextButton",{Size=u2(0,50,0,22),Position=u2(1,-58,.5,-11),BackgroundColor3=C.rd,BorderSizePixel=0,Text="OFF",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,AutoButtonColor=false,ZIndex=9},row);rc(btn,6)
	local function upd() if F[key] then tw(btn,{BackgroundColor3=C.gr},.15);btn.Text="ON" else tw(btn,{BackgroundColor3=C.rd},.15);btn.Text="OFF" end end
	mc(btn.MouseEnter,function()tw(btn,{BackgroundColor3=F[key] and Color3.fromRGB(70,235,165) or Color3.fromRGB(170,100,100)},.1)end)
	mc(btn.MouseLeave,function()upd()end);upd();toggleUpd[key]=upd;return btn,upd,row
end
local toggleActions={
	ij=function() F.ij=not F.ij;toggleUpd.ij();toast("Infinite Jump "..(F.ij and"ON"or"OFF"),F.ij and C.gr or C.rd) end,
	sp=function() F.sp=not F.sp;toggleUpd.sp();applySpd();toast("Speed "..(F.sp and bstSpd or DEF_SPD),F.sp and C.gr or C.rd) end,
	nc=function() F.nc=not F.nc;toggleUpd.nc();if not F.nc then restoreCol() end;toast("No-Clip "..(F.nc and"ON"or"OFF"),F.nc and C.gr or C.rd) end,
}

local pgOpt=N("Frame",{Size=u2(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=true},ct)
mkPageHdr(pgOpt,"⚡ Optimizer");local oScr=mkScroll(pgOpt,42)
mkSec(oScr,"STATUS",1);local oSR=mkRow(oScr,2,52)
local lbl=function(y,h,ts) return N("TextLabel",{Size=u2(1,-16,0,h),Position=u2(0,8,0,y),BackgroundTransparency=1,Text="",Font=Enum.Font.GothamBold,TextSize=ts,TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},oSR) end
local oSL=lbl(4,16,11);oSL.Text="Siap dijalankan"
local oDL=lbl(22,13,10);local oRL=lbl(36,13,9)
local oRB
local function updOpt()
	if OPT.busy then oSL.Text="Memproses...";oSL.TextColor3=C.yl;oDL.Text="Sedang mengoptimasi workspace...";oRL.Text=""
	elseif OPT.on then oSL.Text="✓ AKTIF";oSL.TextColor3=C.gr;oDL.Text="Lighting, PostFX, Material, Mesh aktif";oRL.Text="Auto-reapply setiap "..OPT_REAPPLY_SEC.."s"
	else oSL.Text="Siap dijalankan";oSL.TextColor3=C.mu;oDL.Text="";oRL.Text="" end
end
mkSec(oScr,"AKSI",3);local oBR=mkRow(oScr,4,32);oBR.BackgroundTransparency=1
oRB=N("TextButton",{Size=u2(1,0,0,26),Position=u2(0,0,.5,-13),BackgroundColor3=Color3.fromRGB(50,140,110),BorderSizePixel=0,Text="▶ Jalankan Optimizer",Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.t1,AutoButtonColor=false,ZIndex=9},oBR);rc(oRB,6)
hover(oRB,Color3.fromRGB(50,140,110),Color3.fromRGB(70,165,130))
mc(oRB.MouseButton1Click,function()
	if OPT.on then return end;OPT.on=true;tw(oRB,{BackgroundColor3=C.mu},.1);oRB.Text="Memproses...";updOpt()
	task.spawn(function()
		optRunAll();while OPT.busy do task.wait(0.2) end
		updOpt();tw(oRB,{BackgroundColor3=C.gr},.15);oRB.Text="✓ Aktif";toast("Optimizer aktif!",C.gr);optStartReapplyLoop()
	end)
end)
mkSec(oScr,"INFO",5);local oIR=mkRow(oScr,6,68)
N("TextLabel",{Size=u2(1,-16,1,0),Position=u2(0,8,0,0),BackgroundTransparency=1,Text="• Hapus partikel, aksesori, decal\n• Matikan shadow & PostFX\n• Kurangi render fidelity mesh\n• Watch & auto-reapply objek baru",Font=Enum.Font.Gotham,TextSize=9,TextColor3=C.t2,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,ZIndex=8},oIR)

local pgTools=N("Frame",{Size=u2(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=false},ct)
mkPageHdr(pgTools,"🔧 Tools");local tScr=mkScroll(pgTools,42);mkSec(tScr,"FITUR",1)
local ijBtn=mkToggle(tScr,2,"Infinite Jump","ij","ij");mc(ijBtn.MouseButton1Click,toggleActions.ij)
local spBtn,_,spRow=mkToggle(tScr,3,"Speed Boost","sp","sp")
local spInput=mkInput(spRow,bstSpd)
mc(spInput.FocusLost,function() local v=tonumber(spInput.Text);if v and v>=1 and v<=1000000000000000000 then bstSpd=math.floor(v);spInput.Text=tostring(bstSpd);if F.sp then applySpd() end else spInput.Text=tostring(bstSpd) end end)
mc(spBtn.MouseButton1Click,toggleActions.sp)
local ncBtn=mkToggle(tScr,4,"No-Clip","nc","nc");mc(ncBtn.MouseButton1Click,toggleActions.nc)
mkSec(tScr,"KEYBINDS",5)
for i,kb in ipairs{{"Minimize","minimize"},{"Inf Jump","ij"},{"Speed","sp"},{"No-Clip","nc"}} do
	local row=mkRow(tScr,5+i,26)
	N("TextLabel",{Size=u2(.5,0,1,0),Position=u2(0,8,0,0),BackgroundTransparency=1,Text=kb[1],Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.t2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},row)
	local kbB=N("TextButton",{Size=u2(.5,-12,0,18),Position=u2(.5,4,.5,-9),BackgroundColor3=C.sa,BorderSizePixel=0,Text=Kb[kb[2]].Name,Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.bl,AutoButtonColor=false,ZIndex=9},row);rc(kbB,5);kbLabels[kb[2]]=kbB
	mc(kbB.MouseButton1Click,function() if rebind then return end;rebind=kb[2];kbB.Text="Press key...";kbB.TextColor3=C.yl end)
end

local pgLoc=N("Frame",{Size=u2(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=false},ct)
mkPageHdr(pgLoc,"📍 Teleport");local lastCoord=""
local clipBox=N("TextBox",{Size=u2(0,1,0,1),Position=u2(2,0,2,0),BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=1,TextColor3=Color3.new(),TextTransparency=1,ZIndex=1},sg)
local lScr=mkScroll(pgLoc,42)
mkSec(lScr,"KOORDINAT",1);local coR=mkRow(lScr,2,30)
local coL=N("TextLabel",{Size=u2(1,-68,1,0),Position=u2(0,8,0,0),BackgroundTransparency=1,Text="X: -  Y: -  Z: -",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.bl,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},coR)
local cpB=N("TextButton",{Size=u2(0,58,0,20),Position=u2(1,-62,.5,-10),BackgroundColor3=C.sa,BorderSizePixel=0,Text="Copy",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.t2,AutoButtonColor=false,ZIndex=9},coR);rc(cpB,5);hover(cpB,C.sa,C.ov,C.t2,C.t1)
mc(cpB.MouseButton1Click,function()
	if lastCoord=="" then return end
	if setclipboard then setclipboard(lastCoord) else clipBox.Text=lastCoord;clipBox:CaptureFocus();task.defer(function()clipBox:ReleaseFocus()end) end
	toast("Koordinat disalin!",C.bl)
end)
mkSec(lScr,"SAVE POSITION",3);local svIR=mkRow(lScr,4,32)
local svL=N("TextLabel",{Size=u2(1,-16,1,0),Position=u2(0,8,0,0),BackgroundTransparency=1,Text="Belum ada posisi tersimpan",Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.rd,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=8},svIR)
local function svUpd()
	if savedPos then local pos=savedPos.Position;local _,ry=savedPos:ToEulerAnglesYXZ();svL.Text="✓ "..math.floor(pos.X)..", "..math.floor(pos.Y)..", "..math.floor(pos.Z).."  ↻"..math.floor(math.deg(ry)).."°";svL.TextColor3=C.gr
	else svL.Text="Belum ada posisi tersimpan";svL.TextColor3=C.rd end
end
local svBR=mkRow(lScr,5,36);svBR.BackgroundTransparency=1
N("UIListLayout",{Padding=UDim.new(0,5),FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder},svBR)
for i,d in ipairs{
	{"Save",Color3.fromRGB(50,160,120),Color3.fromRGB(70,180,140),function() local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart");if hrp then savedPos=hrp.CFrame;svUpd();toast("Position saved",C.gr) end end},
	{"Teleport",Color3.fromRGB(60,140,200),Color3.fromRGB(80,160,220),function() if savedPos then tpTo(savedPos);toast("Teleported!",C.bl) end end},
	{"Delete",C.rd,Color3.fromRGB(180,90,90),function() savedPos=nil;svUpd();toast("Position deleted",C.rd) end},
} do local b=N("TextButton",{Size=u2(1/3,-6,0,24),LayoutOrder=i,BackgroundColor3=d[2],BorderSizePixel=0,Text=d[1],Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,AutoButtonColor=false,ZIndex=9},svBR);rc(b,6);hover(b,d[2],d[3]);mc(b.MouseButton1Click,d[4]) end
svUpd()
mkSec(lScr,"TELEPORT KE KOORDINAT",6);local tpCW=mkRow(lScr,7,58);tpCW.Size=u2(1,0,0,58)
N("TextLabel",{Size=u2(1,-8,0,14),Position=u2(0,8,0,4),BackgroundTransparency=1,Text="Teleport ke Koordinat",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},tpCW)
local cBg=N("Frame",{Size=u2(1,-56,0,24),Position=u2(0,8,0,22),BackgroundColor3=C.sa,BorderSizePixel=0,ZIndex=8},tpCW);rc(cBg,6);N("UIStroke",{Color=C.bd,Thickness=1,Transparency=.5},cBg)
local cBox=N("TextBox",{Size=u2(1,-8,1,0),Position=u2(0,4,0,0),BackgroundTransparency=1,Text="",PlaceholderText="X, Y, Z",PlaceholderColor3=C.mu,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.bl,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},cBg)
mc(cBox.Focused,function()tw(cBg,{BackgroundColor3=Color3.fromRGB(35,42,62)},.1)end);mc(cBox.FocusLost,function()tw(cBg,{BackgroundColor3=C.sa},.15)end)
mkSBtn(tpCW,"GO",u2(1,-46,0,24),u2(0,38,0,24),Color3.fromRGB(60,140,220),Color3.fromRGB(80,160,240),function()
	local x,y,z=cBox.Text:gsub("%s",""):match("(-?[%d%.]+),(-?[%d%.]+),(-?[%d%.]+)")
	if x then local nx,ny,nz=tonumber(x),tonumber(y),tonumber(z);tpTo(CFrame.new(nx,ny,nz));toast("TP → "..math.floor(nx)..", "..math.floor(ny)..", "..math.floor(nz),C.bl)
	else toast("Format salah! Gunakan: X, Y, Z",C.rd) end
end)
mkSec(lScr,"TELEPORT LIST",8)
local tpScr=N("ScrollingFrame",{Size=u2(1,0,0,40),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=C.bl,CanvasSize=u2(),BorderSizePixel=0,ZIndex=7,LayoutOrder=9},lScr)
local tpLay=N("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},tpScr)
mc(tpLay:GetPropertyChangedSignal("AbsoluteContentSize"),function() local h=tpLay.AbsoluteContentSize.Y+8;tpScr.CanvasSize=u2(0,0,0,h);tpScr.Size=u2(1,0,0,math.clamp(h,40,120)) end)
local tpActRow=mkRow(lScr,10,26);tpActRow.BackgroundTransparency=1
local clrP,clrT=false,0
mkSBtn(tpActRow,"+ Add",u2(0,0,0,0),u2(.49,-2,1,0),Color3.fromRGB(60,130,200),Color3.fromRGB(80,150,220),function()
	local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
	if hrp then Teleports[#Teleports+1]={CFrame=hrp.CFrame,Label="TP "..(#Teleports+1)};refreshTP();toast("TP added",C.gr) end
end)
mkSBtn(tpActRow,"Clear",u2(.51,0,0,0),u2(.49,0,1,0),C.rd,Color3.fromRGB(180,90,90),function()
	if not clrP then clrP=true;clrT=tick();toast("Klik lagi untuk konfirmasi",C.yl)
	elseif tick()-clrT<=2 then Teleports={};refreshTP();toast("All TP cleared",C.rd);clrP=false
	else clrT=tick();toast("Klik lagi untuk konfirmasi",C.yl) end
end)
refreshTP=function()
	for _,c in ipairs(tpMaid) do c:Disconnect() end;tpMaid={}
	for _,ch in pairs(tpScr:GetChildren()) do if ch:IsA("Frame") then ch:Destroy() end end
	for idx,tp in ipairs(Teleports) do
		local row=N("Frame",{Size=u2(1,0,0,32),BackgroundColor3=C.sa,LayoutOrder=idx,ZIndex=9},tpScr);rc(row,6)
		N("UIStroke",{Color=C.bd,Thickness=1,Transparency=.6},row)
		local nm=N("TextBox",{Size=u2(1,-120,1,0),Position=u2(0,8,0,0),BackgroundTransparency=1,Text=tp.Label,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=10},row)
		tpMaid[#tpMaid+1]=nm.FocusLost:Connect(function() if nm.Text~="" then tp.Label=nm.Text end;nm.Text=tp.Label end)
		local function tpBtn(txt,xoff,w,col,colH,cb)
			local b=N("TextButton",{Size=u2(0,w,0,22),Position=u2(1,xoff,.5,-11),BackgroundColor3=col,BorderSizePixel=0,Text=txt,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,AutoButtonColor=false,ZIndex=10},row);rc(b,6)
			tpMaid[#tpMaid+1]=b.MouseEnter:Connect(function()tw(b,{BackgroundColor3=colH},.1)end)
			tpMaid[#tpMaid+1]=b.MouseLeave:Connect(function()tw(b,{BackgroundColor3=col},.1)end)
			tpMaid[#tpMaid+1]=b.MouseButton1Click:Connect(cb)
		end
		tpBtn("GO",-112,34,Color3.fromRGB(60,140,220),Color3.fromRGB(80,160,240),function()tpTo(tp.CFrame);toast(tp.Label.." → GO",C.bl)end)
		tpBtn("▲",-74,22,C.ov,C.ov,function()if idx>1 then Teleports[idx],Teleports[idx-1]=Teleports[idx-1],Teleports[idx];refreshTP()end end)
		tpBtn("▼",-50,22,C.ov,C.ov,function()if idx<#Teleports then Teleports[idx],Teleports[idx+1]=Teleports[idx+1],Teleports[idx];refreshTP()end end)
		tpBtn("×",-26,22,C.rd,Color3.fromRGB(180,90,90),function()table.remove(Teleports,idx);refreshTP();toast("TP removed",C.rd)end)
	end
end
refreshTP()

local pgPlayers=N("Frame",{Size=u2(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=false},ct)
mkPageHdr(pgPlayers,"👥 Players");local plScr=mkScroll(pgPlayers,42);local plRows={}
local function refreshPlayers()
	for _,r in pairs(plRows) do if r.Parent then r:Destroy() end end;plRows={}
	local selfRow=mkRow(plScr,0,36)
	N("TextLabel",{Size=u2(1,-100,1,0),Position=u2(0,8,0,0),BackgroundTransparency=1,Text="▶ "..LP.DisplayName.." (You)",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.gr,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},selfRow)
	local rcB=N("TextButton",{Size=u2(0,86,0,22),Position=u2(1,-90,.5,-11),BackgroundColor3=C.sa,BorderSizePixel=0,Text="Reset Camera",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.t2,AutoButtonColor=false,ZIndex=10},selfRow);rc(rcB,6);hover(rcB,C.sa,C.ov,C.t2,C.t1)
	mc(rcB.MouseButton1Click,function()resetCam();toast("Camera reset",C.gr)end);plRows["self"]=selfRow
	local ord=1
	for _,pl in ipairs(Players:GetPlayers()) do
		if pl==LP then continue end
		local row=mkRow(plScr,ord,36);ord+=1;plRows[pl]=row
		local thumb=N("ImageLabel",{Size=u2(0,28,0,28),Position=u2(0,4,.5,-14),BackgroundColor3=C.sa,BorderSizePixel=0,ZIndex=9},row);rc(thumb,6)
		task.spawn(function()
			if thumbCache[pl.UserId] then if thumb.Parent then thumb.Image=thumbCache[pl.UserId] end
			else local ok,img=pcall(Players.GetUserThumbnailAsync,Players,pl.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);if ok and thumb.Parent then thumb.Image=img;thumbCache[pl.UserId]=img end end
		end)
		N("TextLabel",{Size=u2(1,-130,0,18),Position=u2(0,38,0,5),BackgroundTransparency=1,Text=pl.DisplayName,Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=9},row)
		N("TextLabel",{Size=u2(1,-130,0,12),Position=u2(0,38,0,22),BackgroundTransparency=1,Text="@"..pl.Name,Font=Enum.Font.Gotham,TextSize=8,TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=9},row)
		local tpB=N("TextButton",{Size=u2(0,34,0,22),Position=u2(1,-84,.5,-11),BackgroundColor3=Color3.fromRGB(60,140,220),BorderSizePixel=0,Text="TP",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.t1,AutoButtonColor=false,ZIndex=10},row);rc(tpB,6);hover(tpB,Color3.fromRGB(60,140,220),Color3.fromRGB(80,160,240))
		mc(tpB.MouseButton1Click,function() local hrp=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart");if hrp then tpTo(hrp.CFrame+hrp.CFrame.LookVector*3);toast("TP → "..pl.DisplayName,C.bl) else toast(pl.DisplayName.." tidak ditemukan",C.rd) end end)
		local spB=N("TextButton",{Size=u2(0,40,0,22),Position=u2(1,-42,.5,-11),BackgroundColor3=Color3.fromRGB(70,60,100),BorderSizePixel=0,Text="Spy",Font=Enum.Font.GothamBold,TextSize=9,TextColor3=C.t1,AutoButtonColor=false,ZIndex=10},row);rc(spB,6);hover(spB,Color3.fromRGB(70,60,100),Color3.fromRGB(100,85,140))
		mc(spB.MouseButton1Click,function() local hrp=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart");if hrp then workspace.CurrentCamera.CameraSubject=hrp;toast("Spectating "..pl.DisplayName,C.yl) else toast(pl.DisplayName.." tidak ada karakter",C.rd) end end)
	end
end
mc(Players.PlayerAdded,function()task.wait(.5);if pgPlayers.Visible then refreshPlayers()end end)
mc(Players.PlayerRemoving,function(pl)
	thumbCache[pl.UserId]=nil
	local cam=workspace.CurrentCamera;if cam.CameraSubject and pl.Character and cam.CameraSubject:IsDescendantOf(pl.Character) then resetCam()end
	task.wait(.1);if pgPlayers.Visible then refreshPlayers()end
end)

local pgMore=N("Frame",{Size=u2(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=false},ct)
mkPageHdr(pgMore,"🔗 More Scripts");local mScr=mkScroll(pgMore,42);mkSec(mScr,"PILIH SKRIP",1)
local function mkScriptRow(par,ord,title,desc,url)
	local row=mkRow(par,ord,52)
	N("TextLabel",{Size=u2(1,-68,0,18),Position=u2(0,10,0,6),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamBold,TextSize=11,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},row)
	N("TextLabel",{Size=u2(1,-68,0,14),Position=u2(0,10,0,26),BackgroundTransparency=1,Text=desc,Font=Enum.Font.Gotham,TextSize=9,TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},row)
	local rb=N("TextButton",{Size=u2(0,50,0,28),Position=u2(1,-58,.5,-14),BackgroundColor3=Color3.fromRGB(60,130,200),BorderSizePixel=0,Text="▶ Run",Font=Enum.Font.GothamBold,TextSize=10,TextColor3=C.t1,AutoButtonColor=false,ZIndex=9},row);rc(rb,6);hover(rb,Color3.fromRGB(60,130,200),Color3.fromRGB(80,155,230))
	mc(rb.MouseButton1Click,function() toast("Memuat: "..title,C.bl);task.spawn(function()local fn=loadstring(game:HttpGet(url));if fn then fn()end;task.wait(.3);closeGUI()end) end)
end
mkScriptRow(mScr,2,"Main Menu","Kembali ke menu utama","https://sbstrans.net/rbxscript/release/menu.lua")

local mb=N("Frame",{Size=u2(0,MS,0,MS),Position=u2(.5,-MS/2,.5,-MS/2),BackgroundColor3=C.hd,BorderSizePixel=0,ZIndex=20,Visible=false,Active=true},sg);rc(mb)
local mbSt=N("UIStroke",{Color=C.bl,Thickness=2,Transparency=.3},mb)
local mbi=fill(mb,{s=u2(1,-6,1,-6),p=u2(0,3,0,3),c=C.hd,z=21});mbi.BackgroundTransparency=1;rc(mbi)
local mbiSt=N("UIStroke",{Color=C.bl,Thickness=1,Transparency=.7},mbi)
local mfL=N("TextLabel",{Size=u2(1,0,0,14),Position=u2(0,0,.5,-9),BackgroundTransparency=1,Text="--",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.gr,ZIndex=22,Visible=false},mb)
local mfS=N("TextLabel",{Size=u2(1,0,0,9),Position=u2(0,0,.5,5),BackgroundTransparency=1,Text="FPS",Font=Enum.Font.Gotham,TextSize=8,TextColor3=C.t2,ZIndex=22,Visible=false},mb)
local function setMV(v) mfL.Visible=v;mfS.Visible=v;mbi.Visible=v;mbSt.Enabled=v;mbiSt.Enabled=v end

closeGUI=function()
	OPT.on=false;restoreCol();resetCam()
	local ch=LP.Character;if ch then local hum=ch:FindFirstChildOfClass("Humanoid");if hum then hum.WalkSpeed=DEF_SPD;hum.PlatformStand=false end end
	for k in pairs(F) do F[k]=false end;mini=false;mb.Visible=false
	table.clear(thumbCache);table.clear(optCharSet);table.clear(optCharCache)
	tw(mn,{Size=u2(0,0,0,0),BackgroundTransparency=1},.2)
	task.delay(.25,function()
		for _,c in ipairs(tpMaid) do c:Disconnect()end;tpMaid={};cleanCC()
		for _,v in ipairs(maid) do if typeof(v)=="RBXScriptConnection" then v:Disconnect() elseif typeof(v)=="Instance" then v:Destroy()end end;maid={}
	end)
end

local function setMini(m)
	if anim or mini==m then return end;anim=true;mini=m
	if m then
		local ap,as=mn.AbsolutePosition,mn.AbsoluteSize
		mb.Position=u2(0,ap.X+as.X/2-MS/2,0,ap.Y+as.Y/2-MS/2)
		mb.Size=u2(0,0,0,0);mb.BackgroundTransparency=1;mb.Visible=true;setMV(false)
		tw(mn,{Size=u2(0,0,0,0),BackgroundTransparency=1},.22);tw(mb,{Size=u2(0,MS,0,MS),BackgroundTransparency=0},.25)
		task.delay(.28,function()mn.Visible=false;setMV(true);anim=false end)
	else
		setMV(false);mn.Visible=true
		local ap,as=mb.AbsolutePosition,mb.AbsoluteSize;local ss=sg.AbsoluteSize
		mn.Position=u2(0,math.clamp(ap.X+as.X/2-FW/2,0,ss.X-FW),0,math.clamp(ap.Y+as.Y/2-FH/2,0,ss.Y-FH))
		mn.Size=u2(0,0,0,0);mn.BackgroundTransparency=1
		tw(mb,{Size=u2(0,0,0,0),BackgroundTransparency=1},.18);tw(mn,{Size=u2(0,FW,0,FH),BackgroundTransparency=0},.25)
		task.delay(.28,function()mb.Visible=false;anim=false end)
	end
end

local function makeDrag(h,tgt,clk)
	local mc2,ec
	local function cl() if mc2 then mc2:Disconnect();mc2=nil end;if ec then ec:Disconnect();ec=nil end end
	mc(h.InputBegan,function(inp)
		if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
		cl();local si2=inp.Position;local ap=tgt.AbsolutePosition;local sp=u2(0,ap.X,0,ap.Y);tgt.Position=sp;local dr=false
		mc2=UIS.InputChanged:Connect(function(mi)
			if mi.UserInputType~=Enum.UserInputType.MouseMovement and mi.UserInputType~=Enum.UserInputType.Touch then return end
			local d=mi.Position-si2;if not dr and d.Magnitude>=5 then dr=true end
			if dr then local ss,ts=sg.AbsoluteSize,tgt.AbsoluteSize;tgt.Position=u2(0,math.clamp(sp.X.Offset+d.X,0,ss.X-ts.X),0,math.clamp(sp.Y.Offset+d.Y,0,ss.Y-ts.Y))end
		end)
		ec=inp.Changed:Connect(function() if inp.UserInputState==Enum.UserInputState.End then cl();if not dr and clk then clk()end end end)
	end)
end
makeDrag(hd,mn);makeDrag(mb,mb,function()setMini(false)end)

local pages={opt=pgOpt,tools=pgTools,loc=pgLoc,players=pgPlayers,more=pgMore}
local navOrder={"opt","tools","loc","players","more"}
local function navTo(sid)
	for _,id in ipairs(navOrder) do
		local s=id==sid;pages[id].Visible=s
		tw(sideButtons[id],{BackgroundColor3=s and C.ov or C.sa,TextColor3=s and C.t1 or C.t2},.1)
		if s then
			local btn=sideButtons[id];tw(si,{Position=u2(0,0,0,btn.Position.Y.Offset+(btn.Size.Y.Offset-si.Size.Y.Offset)/2)},.18)
			if sid=="players" then task.spawn(refreshPlayers)end;if sid=="opt" then updOpt()end
		end
	end
end
for _,id in ipairs(navOrder) do mc(sideButtons[id].MouseButton1Click,function()navTo(id)end)end
navTo("opt");mc(miB.MouseButton1Click,function()setMini(true)end);mc(clB.MouseButton1Click,function()closeGUI()end)

mc(UIS.InputBegan,function(inp,gpe)
	local kc=inp.KeyCode;if kc==Enum.KeyCode.Unknown then return end
	if rebind then
		if UIS:GetFocusedTextBox() then return end
		local function cancelRebind(msg) local l=kbLabels[rebind];if l then l.Text=Kb[rebind].Name;l.TextColor3=C.bl end;rebind=nil;toast(msg,C.mu) end
		if kc==Enum.KeyCode.Escape then cancelRebind("Rebind cancelled");return end
		if kc==Kb[rebind] then cancelRebind("Key tidak berubah");return end
		for k,v in pairs(Kb) do if v==kc and k~=rebind then cancelRebind("Key sudah dipakai: "..k);return end end
		Kb[rebind]=kc;local l=kbLabels[rebind];if l then l.Text=kc.Name;l.TextColor3=C.bl end
		if kbHints[rebind] then for _,lh in ipairs(kbHints[rebind]) do if lh.Parent then lh.Text=" ["..kc.Name.."]"end end end
		toast("Rebound → "..kc.Name,C.bl);rebind=nil;return
	end
	if gpe then return end
	if kc==Kb.minimize then setMini(not mini);return end
	for id,bound in pairs(Kb) do if bound==kc and toggleActions[id] then toggleActions[id]();return end end
end)

mc(RS.Heartbeat,function()
	local f=ft();if f>0 and f~=fps.last then fps.last=f;local col=fc(f);fL.Text=f.." FPS";fL.TextColor3=col;mfL.Text=tostring(f);mfL.TextColor3=col end
	local char=LP.Character;if not char then cachedHrp=nil;return end
	local hrp=cachedHrp;if not hrp or not hrp.Parent then hrp=char:FindFirstChild("HumanoidRootPart");cachedHrp=hrp end
	if hrp and pgLoc.Visible then
		local fx,fy,fz=math.floor(hrp.Position.X),math.floor(hrp.Position.Y),math.floor(hrp.Position.Z)
		lastCoord=string.format("%d, %d, %d",fx,fy,fz);coL.Text=string.format("X: %d  Y: %d  Z: %d",fx,fy,fz)
	end
end)

local afkActs={
	function()VU:Button2Down(Vector2.new(math.random(100,400),math.random(100,300)),workspace.CurrentCamera.CFrame);task.wait(math.random(60,180)/1000);VU:Button2Up(Vector2.new(math.random(100,400),math.random(100,300)),workspace.CurrentCamera.CFrame)end,
	function()VU:Button1Down(Vector2.new(math.random(200,500),math.random(150,350)),workspace.CurrentCamera.CFrame);task.wait(math.random(40,120)/1000);VU:Button1Up(Vector2.new(math.random(200,500),math.random(150,350)),workspace.CurrentCamera.CFrame)end,
	function()for _=1,math.random(2,4)do VU:MoveMouse(Vector2.new(math.random(-5,5),math.random(-5,5)));task.wait(math.random(30,80)/1000)end end,
	function()VU:SetKeyDown("w");task.wait(math.random(200,600)/1000);VU:SetKeyUp("w")end,
	function()local k=({"a","s","d"})[math.random(1,3)];VU:SetKeyDown(k);task.wait(math.random(150,400)/1000);VU:SetKeyUp(k)end,
	function()VU:SetKeyDown(" ");task.wait(math.random(80,200)/1000);VU:SetKeyUp(" ")end,
}
local afkIdx=0
mc(LP.Idled,function()task.wait(math.random(50,150)/1000);afkIdx=afkIdx%#afkActs+1;afkActs[afkIdx]();task.wait(math.random(100,300)/1000);afkActs[math.random(1,#afkActs)]()end)
local afkT=0
mc(RS.Heartbeat,function(dt)
	afkT+=dt;if afkT>=240 then afkT=0;task.spawn(function()
		VU:MoveMouse(Vector2.new(math.random(-3,3),math.random(-3,3)));task.wait(0.05)
		VU:Button2Down(Vector2.new(math.random(100,300),math.random(100,300)),workspace.CurrentCamera.CFrame);task.wait(math.random(80,160)/1000)
		VU:Button2Up(Vector2.new(math.random(100,300),math.random(100,300)),workspace.CurrentCamera.CFrame)
	end)end
end)

mc(UIS.JumpRequest,function() if not F.ij then return end;local c=LP.Character;if c and c:FindFirstChild("Humanoid") then c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)end end)
mc(LP.CharacterAdded,function(char)
	cleanCC();cachedHrp=nil
	local hrp=char:WaitForChild("HumanoidRootPart",5);if not hrp then return end
	local hum=char:WaitForChild("Humanoid",5);if not hum then return end
	cachedHrp=hrp;ncSet={};ncOrig={}
	for _,pt in ipairs(char:GetDescendants())do if pt:IsA("BasePart")then ncSet[pt]=true end end
	charConns.add=char.DescendantAdded:Connect(function(pt) if pt:IsA("BasePart")then ncSet[pt]=true;if F.nc then if ncOrig[pt]==nil then ncOrig[pt]=pt.CanCollide end;pt.CanCollide=false end end end)
	charConns.rem=char.DescendantRemoving:Connect(function(pt) if pt:IsA("BasePart")then ncSet[pt]=nil;ncOrig[pt]=nil end end)
	local ncFC=0
	charConns.ncLoop=RS.Heartbeat:Connect(function()
		if not F.nc then return end;ncFC+=1;if ncFC<10 then return end;ncFC=0
		for pt in pairs(ncSet)do if pt.Parent and pt.CanCollide then if ncOrig[pt]==nil then ncOrig[pt]=pt.CanCollide end;pt.CanCollide=false end end
	end)
	if F.sp then hum.WalkSpeed=bstSpd end
	if savedPos then task.wait(.3);if not char.Parent then return end;char:MoveTo(savedPos.Position);task.wait(.1);if hrp.Parent then hrp.CFrame=savedPos end end
end)
mc(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),function()
	local ss=sg.AbsoluteSize
	if not mini and mn.Visible then local pos=mn.AbsolutePosition;mn.Position=u2(0,math.clamp(pos.X,0,math.max(ss.X-FW,0)),0,math.clamp(pos.Y,0,math.max(ss.Y-FH,0)))end
	if mini and mb.Visible then local pos=mb.AbsolutePosition;mb.Position=u2(0,math.clamp(pos.X,0,math.max(ss.X-MS,0)),0,math.clamp(pos.Y,0,math.max(ss.Y-MS,0)))end
end)

mn.Size=u2(0,0,0,0);mn.BackgroundTransparency=1
task.delay(.1,function()tw(mn,{Size=u2(0,FW,0,FH),BackgroundTransparency=0},.35)end)