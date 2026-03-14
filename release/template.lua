local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local PG=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local FW,FH,HH,SW,MS,BS,BG,CR=300,200,42,40,48,26,6,12
local FBW=BG*3+BS*2+54
local anim,mini=false,false
local maid={}
local C={
    bg=Color3.fromRGB(15,17,23),cd=Color3.fromRGB(22,26,36),hd=Color3.fromRGB(18,21,30),
    bd=Color3.fromRGB(36,42,58),t1=Color3.fromRGB(235,240,255),t2=Color3.fromRGB(140,155,185),
    mu=Color3.fromRGB(70,82,110),gr=Color3.fromRGB(50,215,145),yl=Color3.fromRGB(255,210,60),
    rd=Color3.fromRGB(255,75,75),ov=Color3.fromRGB(32,38,54),bl=Color3.fromRGB(90,165,255),
    sa=Color3.fromRGB(28,34,50),
}
local function N(c,p,pr)local o=Instance.new(c);for k,v in pairs(p)do o[k]=v end;o.Parent=pr;return o end
local function rc(o,r)N("UICorner",{CornerRadius=r and UDim.new(0,r)or UDim.new(1,0)},o)end
local function tw(o,p,d)TS:Create(o,TweenInfo.new(d or.2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),p):Play()end
local function mc(s,f)local c=s:Connect(f);maid[#maid+1]=c;return c end
local function fc(f)return f>=55 and C.gr or f>=30 and C.yl or C.rd end
local function u2(x,y,x2,y2)return UDim2.new(x,y,x2 or 0,y2 or 0)end
local function fill(pr,p)return N("Frame",{Size=p.s or UDim2.new(1,0,1,0),Position=p.p or UDim2.new(),BackgroundColor3=p.c,BorderSizePixel=0,ZIndex=p.z or 5},pr)end
local fps={n=0,t=tick(),v=-1,last=-1}
local function ft()
    fps.n+=1;local now=tick()
    if now-fps.t>=.5 then fps.v=math.floor(fps.n/(now-fps.t)+.5);fps.n=0;fps.t=now end
    return fps.v
end
for _,u in pairs(PG:GetChildren())do if u.Name=="UOpt"then u:Destroy()end end
local sg=N("ScreenGui",{Name="UOpt",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999},PG)
maid[#maid+1]=sg
local mn=N("Frame",{Size=u2(0,FW,0,FH),Position=u2(.5,-FW/2,.5,-FH/2),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true,Active=true},sg)
rc(mn,CR);N("UIStroke",{Color=C.bd,Thickness=1},mn)
local hd=N("Frame",{Size=u2(1,0,0,HH),BackgroundColor3=C.hd,BorderSizePixel=0,ZIndex=10},mn)
rc(hd,CR)
fill(hd,{s=u2(1,0,0,CR),p=u2(0,0,1,-CR),c=C.hd,z=10})
fill(hd,{s=u2(1,0,0,1),p=u2(0,0,1,0),c=C.bd,z=11})
rc(fill(hd,{s=u2(0,22,0,3),p=u2(0,SW+8,1,-2),c=C.bl,z=12}),2)
N("TextLabel",{Size=u2(0,150,0,16),Position=u2(0,SW+8,.5,-8),BackgroundTransparency=1,Text="Roblox GUI",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.t1,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},hd)
local fb=fill(hd,{s=u2(0,54,0,22),p=u2(1,-FBW,.5,-11),c=C.cd,z=12});rc(fb,6)
local fL=N("TextLabel",{Size=u2(1,0,1,0),BackgroundTransparency=1,Text="--",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.gr,ZIndex=13},fb)
local function hBtn(x,bg,tx,ts,tc)
    local b=N("TextButton",{Size=u2(0,BS,0,BS),Position=u2(1,x,.5,-BS/2),BackgroundColor3=bg,BorderSizePixel=0,Text=tx,Font=Enum.Font.GothamBold,TextSize=ts,TextColor3=tc,AutoButtonColor=false,ZIndex=12},hd)
    rc(b,6);return b
end
local miB=hBtn(-(BG*2+BS*2),C.cd,"–",15,C.t2)
local clB=hBtn(-(BG+BS),Color3.fromRGB(110,30,42),"×",16,Color3.fromRGB(255,200,200))
local sb=N("Frame",{Size=u2(0,SW,1,-HH),Position=u2(0,0,0,HH),BackgroundColor3=C.cd,BorderSizePixel=0,ZIndex=5},mn)
rc(sb,CR)
fill(sb,{s=u2(1,0,0,CR),c=C.cd})
fill(sb,{s=u2(0,CR,0,CR),p=u2(1,-CR,1,-CR),c=C.cd})
fill(sb,{s=u2(0,1,1,0),p=u2(1,0,0,0),c=C.bd,z=6})
local si=fill(sb,{s=u2(0,3,0,22),p=u2(0,0,0,11),c=C.bl,z=8});rc(si,2)
local function sBtn(y,ic)
    local b=N("TextButton",{Size=u2(0,30,0,30),Position=u2(.5,-15,0,y),BackgroundColor3=C.sa,BorderSizePixel=0,Text=ic,Font=Enum.Font.Gotham,TextSize=15,TextColor3=C.t2,AutoButtonColor=false,ZIndex=7},sb);rc(b,8)
    mc(b.MouseEnter,function()tw(b,{BackgroundColor3=C.ov,TextColor3=C.t1},.1)end)
    mc(b.MouseLeave,function()tw(b,{BackgroundColor3=C.sa,TextColor3=C.t2},.1)end)
    return b
end
local bM,bE=sBtn(6,"🔧"),sBtn(42,"🔧")
local ct=N("Frame",{Size=u2(1,-SW,1,-HH),Position=u2(0,SW,0,HH),BackgroundColor3=C.bg,BorderSizePixel=0,ZIndex=5},mn)
rc(ct,CR)
fill(ct,{s=u2(1,0,0,CR),c=C.bg})
fill(ct,{s=u2(0,CR,0,CR),p=u2(0,0,1,-CR),c=C.bg})
local function mkPage(vis,title,sub,tc)
    local pg=N("Frame",{Size=u2(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=vis},ct)
    N("TextLabel",{Size=u2(1,-14,0,14),Position=u2(0,7,0,10),BackgroundTransparency=1,Text=title,Font=Enum.Font.GothamBold,TextSize=13,TextColor3=tc,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},pg)
    N("TextLabel",{Size=u2(1,-14,0,12),Position=u2(0,7,0,28),BackgroundTransparency=1,Text=sub,Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.mu,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},pg)
    return pg
end
local pgM=mkPage(true,"🔧 Menu 1","Tambahkan fitur di sini",C.t2)
local pgE=mkPage(false,"🔧 Menu 2","Tambahkan fitur lainnya",C.t2)
local mb=N("Frame",{Size=u2(0,MS,0,MS),Position=u2(.5,-MS/2,.5,-MS/2),BackgroundColor3=C.hd,BorderSizePixel=0,ZIndex=20,Visible=false,Active=true,ClipsDescendants=true},sg)
rc(mb);local mbSt=N("UIStroke",{Color=C.bl,Thickness=2,Transparency=.3},mb)
local mbi=fill(mb,{s=u2(1,-6,1,-6),p=u2(0,3,0,3),c=C.hd,z=21});mbi.BackgroundTransparency=1;rc(mbi)
local mbiSt=N("UIStroke",{Color=C.bl,Thickness=1,Transparency=.7},mbi)
local mfL=N("TextLabel",{Size=u2(1,0,0,14),Position=u2(0,0,.5,-9),BackgroundTransparency=1,Text="--",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.gr,ZIndex=22},mb)
local mfS=N("TextLabel",{Size=u2(1,0,0,9),Position=u2(0,0,.5,5),BackgroundTransparency=1,Text="FPS",Font=Enum.Font.Gotham,TextSize=8,TextColor3=C.t2,ZIndex=22},mb)
local function setMiniContent(v)
    mfL.Visible=v;mfS.Visible=v;mbi.Visible=v;mbSt.Enabled=v;mbiSt.Enabled=v
end
local function setMini(m)
    if anim or mini==m then return end
    anim=true;mini=m
    if m then
        local ap,as=mn.AbsolutePosition,mn.AbsoluteSize
        mb.Position=u2(0,ap.X+as.X/2-MS/2,0,ap.Y+as.Y/2-MS/2)
        mb.Size=u2(0,0,0,0);mb.BackgroundTransparency=1;mb.Visible=true
        setMiniContent(true)
        tw(mn,{Size=u2(0,0,0,0),BackgroundTransparency=1},.22)
        tw(mb,{Size=u2(0,MS,0,MS),BackgroundTransparency=0},.25)
        task.delay(.28,function()mn.Visible=false;anim=false end)
    else
        setMiniContent(false)
        mn.Visible=true
        local ap,as=mb.AbsolutePosition,mb.AbsoluteSize
        local cx,cy=ap.X+as.X/2,ap.Y+as.Y/2
        local ss=sg.AbsoluteSize
        mn.Position=u2(0,math.clamp(cx-FW/2,0,ss.X-FW),0,math.clamp(cy-FH/2,0,ss.Y-FH))
        mn.Size=u2(0,0,0,0);mn.BackgroundTransparency=1
        tw(mb,{Size=u2(0,0,0,0),BackgroundTransparency=1},.18)
        tw(mn,{Size=u2(0,FW,0,FH),BackgroundTransparency=0},.25)
        task.delay(.28,function()mb.Visible=false;anim=false end)
    end
end
local function makeDrag(h,tgt,clk)
    local mc2,ec
    local function cl()if mc2 then mc2:Disconnect();mc2=nil end;if ec then ec:Disconnect();ec=nil end end
    mc(h.InputBegan,function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
        cl();local si2=inp.Position;local ap=tgt.AbsolutePosition;local sp=u2(0,ap.X,0,ap.Y);tgt.Position=sp;local dr=false
        mc2=UIS.InputChanged:Connect(function(mi)
            if mi.UserInputType~=Enum.UserInputType.MouseMovement and mi.UserInputType~=Enum.UserInputType.Touch then return end
            local d=mi.Position-si2
            if not dr and d.Magnitude>=5 then dr=true end
            if dr then
                local ss,ts=sg.AbsoluteSize,tgt.AbsoluteSize
                tgt.Position=u2(0,math.clamp(sp.X.Offset+d.X,0,ss.X-ts.X),0,math.clamp(sp.Y.Offset+d.Y,0,ss.Y-ts.Y))
            end
        end)
        ec=inp.Changed:Connect(function()
            if inp.UserInputState==Enum.UserInputState.End then cl();if not dr and clk then clk()end end
        end)
    end)
end
makeDrag(hd,mn)
makeDrag(mb,mb,function()setMini(false)end)
local nav={
    {id="main",pg=pgM,btn=bM},
    {id="extra",pg=pgE,btn=bE},
}
local function navTo(sid)
    for _,d in ipairs(nav)do
        local s=d.id==sid;d.pg.Visible=s
        tw(d.btn,{BackgroundColor3=s and C.ov or C.sa,TextColor3=s and C.t1 or C.t2},.1)
        if s then
            local by,bh=d.btn.Position.Y.Offset,d.btn.Size.Y.Offset
            tw(si,{Position=u2(0,0,0,by+(bh-si.Size.Y.Offset)/2)},.18)
        end
    end
end
for _,d in ipairs(nav)do local id=d.id;mc(d.btn.MouseButton1Click,function()navTo(id)end)end
navTo("main")
mc(miB.MouseButton1Click,function()setMini(true)end)
mc(clB.MouseButton1Click,function()
    tw(mn,{Size=u2(0,0,0,0),BackgroundTransparency=1},.2)
    task.delay(.25,function()
        for _,v in ipairs(maid)do if typeof(v)=="RBXScriptConnection"then v:Disconnect()end end
        for _,v in ipairs(maid)do if typeof(v)=="Instance"then v:Destroy()end end
        maid={}
    end)
end)
mc(UIS.InputBegan,function(inp,gpe)
    if not gpe and inp.KeyCode==Enum.KeyCode.F5 then setMini(not mini)end
end)
mc(RS.Heartbeat,function()
    local f=ft()
    if f>0 and f~=fps.last then
        fps.last=f;local col=fc(f)
        fL.Text=f.." FPS";fL.TextColor3=col
        mfL.Text=tostring(f);mfL.TextColor3=col
    end
end)
local cam=workspace.CurrentCamera
if cam then
    mc(cam:GetPropertyChangedSignal("ViewportSize"),function()
        local ss=sg.AbsoluteSize
        if not mini and mn.Visible then
            local p=mn.AbsolutePosition
            mn.Position=u2(0,math.clamp(p.X,0,math.max(ss.X-FW,0)),0,math.clamp(p.Y,0,math.max(ss.Y-FH,0)))
        end
        if mini and mb.Visible then
            local p=mb.AbsolutePosition
            mb.Position=u2(0,math.clamp(p.X,0,math.max(ss.X-MS,0)),0,math.clamp(p.Y,0,math.max(ss.Y-MS,0)))
        end
    end)
end
mn.Size=u2(0,0,0,0);mn.BackgroundTransparency=1
task.delay(.1,function()tw(mn,{Size=u2(0,FW,0,FH),BackgroundTransparency=0},.35)end)