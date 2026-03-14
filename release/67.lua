local TS=game:GetService("TweenService")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local PG=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local FW,FH,HDH,SBW=300,200,42,40
local MINI_SZ,BTN_SZ,BTN_GAP,CORNER=48,26,6,12
local INT=0.15

local C={
    BG=Color3.fromRGB(15,17,23),CD=Color3.fromRGB(22,26,36),
    HD=Color3.fromRGB(18,21,30),BD=Color3.fromRGB(36,42,58),
    TX=Color3.fromRGB(235,240,255),T2=Color3.fromRGB(140,155,185),
    MU=Color3.fromRGB(70,82,110),GR=Color3.fromRGB(50,215,145),
    YL=Color3.fromRGB(255,210,60),KN=Color3.fromRGB(240,245,255),
    OF=Color3.fromRGB(32,38,54),BL=Color3.fromRGB(90,165,255),
    SA=Color3.fromRGB(28,34,50),
}

local S={mini=false,on=false,count=0}
local maid={}

local function I(cls,pr,par) local o=Instance.new(cls);for k,v in pairs(pr) do o[k]=v end;o.Parent=par;return o end
local function cr(o,r) I("UICorner",{CornerRadius=UDim.new(0,r or 10)},o) end
local function crf(o) I("UICorner",{CornerRadius=UDim.new(1,0)},o) end
local function tw(o,pr,d) TS:Create(o,TweenInfo.new(d or .2,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),pr):Play() end
local function mCon(sig,cb) local c=sig:Connect(cb);maid[#maid+1]=c;return c end

local fps={n=0,t=0,v=0,last=-1}
local function fTick() fps.n+=1;local now=tick();if now-fps.t>=.5 then fps.v=math.floor(fps.n/(now-fps.t)+.5);fps.n=0;fps.t=now end;return fps.v end
local function fCol(f) return f>=55 and C.GR or f>=30 and C.YL or C.MU end

for _,u in pairs(PG:GetChildren()) do if u.Name=="UOpt" then u:Destroy() end end
local sg=I("ScreenGui",{Name="UOpt",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999},PG)
maid[#maid+1]=sg

local mn=I("Frame",{Size=UDim2.new(0,FW,0,FH),Position=UDim2.new(.5,-FW/2,.5,-FH/2),BackgroundColor3=C.BG,BorderSizePixel=0,ClipsDescendants=true,Active=true},sg)
cr(mn,CORNER);I("UIStroke",{Color=C.BD,Thickness=1},mn)

local hd=I("Frame",{Size=UDim2.new(1,0,0,HDH),BackgroundColor3=C.HD,BorderSizePixel=0,ZIndex=10},mn)
cr(hd,CORNER)
I("Frame",{Size=UDim2.new(1,0,0,CORNER),Position=UDim2.new(0,0,1,-CORNER),BackgroundColor3=C.HD,BorderSizePixel=0,ZIndex=10},hd)
I("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=C.BD,BorderSizePixel=0,ZIndex=11},hd)
I("Frame",{Size=UDim2.new(0,22,0,3),Position=UDim2.new(0,SBW+8,1,-2),BackgroundColor3=C.BL,BorderSizePixel=0,ZIndex=12},hd);cr(hd:FindFirstChildWhichIsA("Frame",true),2)
I("TextLabel",{Size=UDim2.new(0,150,0,16),Position=UDim2.new(0,SBW+8,.5,-8),BackgroundTransparency=1,Text="Roblox Tools",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.TX,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},hd)

local fb=I("Frame",{Size=UDim2.new(0,54,0,22),Position=UDim2.new(1,-(BTN_GAP*3+BTN_SZ*2+54),.5,-11),BackgroundColor3=C.CD,BorderSizePixel=0,ZIndex=12},hd);cr(fb,6)
local fL=I("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="--",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.GR,ZIndex=13},fb)

local miB=I("TextButton",{Size=UDim2.new(0,BTN_SZ,0,BTN_SZ),Position=UDim2.new(1,-(BTN_GAP*2+BTN_SZ*2),.5,-BTN_SZ/2),BackgroundColor3=C.CD,BorderSizePixel=0,Text="–",Font=Enum.Font.GothamBold,TextSize=15,TextColor3=C.T2,AutoButtonColor=false,ZIndex=12},hd);cr(miB,6)
local clB=I("TextButton",{Size=UDim2.new(0,BTN_SZ,0,BTN_SZ),Position=UDim2.new(1,-(BTN_GAP+BTN_SZ),.5,-BTN_SZ/2),BackgroundColor3=Color3.fromRGB(110,30,42),BorderSizePixel=0,Text="×",Font=Enum.Font.GothamBold,TextSize=16,TextColor3=Color3.fromRGB(255,200,200),AutoButtonColor=false,ZIndex=12},hd);cr(clB,6)

local sb=I("Frame",{Size=UDim2.new(0,SBW,1,-HDH),Position=UDim2.new(0,0,0,HDH),BackgroundColor3=C.CD,BorderSizePixel=0,ZIndex=5},mn)
cr(sb,CORNER)
I("Frame",{Size=UDim2.new(1,0,0,CORNER),Position=UDim2.new(0,0,0,0),BackgroundColor3=C.CD,BorderSizePixel=0,ZIndex=5},sb)
I("Frame",{Size=UDim2.new(0,CORNER,0,CORNER),Position=UDim2.new(1,-CORNER,1,-CORNER),BackgroundColor3=C.CD,BorderSizePixel=0,ZIndex=5},sb)
I("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=C.BD,BorderSizePixel=0,ZIndex=6},sb)
local sideInd=I("Frame",{Size=UDim2.new(0,3,0,22),Position=UDim2.new(0,0,0,11),BackgroundColor3=C.BL,BorderSizePixel=0,ZIndex=8},sb);cr(sideInd,2)

local function mkSideBtn(y,icon)
    local btn=I("TextButton",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(.5,-15,0,y),BackgroundColor3=C.SA,BorderSizePixel=0,Text=icon,Font=Enum.Font.Gotham,TextSize=15,TextColor3=C.T2,AutoButtonColor=false,ZIndex=7},sb);cr(btn,8)
    mCon(btn.MouseEnter,function() tw(btn,{BackgroundColor3=C.OF,TextColor3=C.TX},.1) end)
    mCon(btn.MouseLeave,function() tw(btn,{BackgroundColor3=C.SA,TextColor3=C.T2},.1) end)
    return btn
end
local mbRepair=mkSideBtn(6,"🔧")
local mbExtra=mkSideBtn(42,"⚡")

local ct=I("Frame",{Size=UDim2.new(1,-SBW,1,-HDH),Position=UDim2.new(0,SBW,0,HDH),BackgroundColor3=C.BG,BorderSizePixel=0,ZIndex=5},mn)
cr(ct,CORNER)
I("Frame",{Size=UDim2.new(1,0,0,CORNER),Position=UDim2.new(0,0,0,0),BackgroundColor3=C.BG,BorderSizePixel=0,ZIndex=5},ct)
I("Frame",{Size=UDim2.new(0,CORNER,0,CORNER),Position=UDim2.new(0,0,1,-CORNER),BackgroundColor3=C.BG,BorderSizePixel=0,ZIndex=5},ct)

local pgR=I("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=true},ct)
local tgRow=I("Frame",{Size=UDim2.new(1,-14,0,36),Position=UDim2.new(0,7,0,6),BackgroundColor3=C.CD,BorderSizePixel=0,ZIndex=7},pgR);cr(tgRow,7)
local repDot=I("Frame",{Size=UDim2.new(0,7,0,7),Position=UDim2.new(0,10,.5,-3),BackgroundColor3=C.MU,BorderSizePixel=0,ZIndex=8},tgRow);crf(repDot)
I("TextLabel",{Size=UDim2.new(0,130,0,13),Position=UDim2.new(0,22,.5,-6),BackgroundTransparency=1,Text="Auto Repair Door",Font=Enum.Font.GothamBold,TextSize=12,TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},tgRow)
local tf=I("Frame",{Size=UDim2.new(0,36,0,20),Position=UDim2.new(1,-44,.5,-10),BackgroundColor3=C.OF,BorderSizePixel=0,ZIndex=8},tgRow);cr(tf,10)
local ts=I("UIStroke",{Color=C.BD,Thickness=1},tf)
local tk=I("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,3,.5,-7),BackgroundColor3=C.KN,BorderSizePixel=0,ZIndex=9},tf);cr(tk,7)
local tb=I("TextButton",{Size=UDim2.new(1,8,1,8),Position=UDim2.new(.5,0,.5,0),AnchorPoint=Vector2.new(.5,.5),BackgroundTransparency=1,Text="",ZIndex=10},tf)
local stLine=I("TextLabel",{Size=UDim2.new(1,-14,0,12),Position=UDim2.new(0,7,0,48),BackgroundTransparency=1,Text="Nonaktif",Font=Enum.Font.Gotham,TextSize=11,TextColor3=C.MU,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},pgR)
local ctLine=I("TextLabel",{Size=UDim2.new(1,-14,0,12),Position=UDim2.new(0,7,0,62),BackgroundTransparency=1,Text="",Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.T2,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},pgR)

local pgE=I("Frame",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Visible=false},ct)
I("TextLabel",{Size=UDim2.new(1,-14,0,14),Position=UDim2.new(0,7,0,10),BackgroundTransparency=1,Text="⚡ Coming Soon",Font=Enum.Font.GothamBold,TextSize=13,TextColor3=C.MU,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},pgE)
I("TextLabel",{Size=UDim2.new(1,-14,0,12),Position=UDim2.new(0,7,0,28),BackgroundTransparency=1,Text="Nantikan fitur lainnya",Font=Enum.Font.Gotham,TextSize=10,TextColor3=C.MU,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},pgE)

local miniBox=I("Frame",{Size=UDim2.new(0,MINI_SZ,0,MINI_SZ),Position=UDim2.new(.5,-MINI_SZ/2,.5,-MINI_SZ/2),BackgroundColor3=C.HD,BorderSizePixel=0,ZIndex=20,Visible=false,Active=true},sg)
crf(miniBox);I("UIStroke",{Color=C.BL,Thickness=2,Transparency=0.3},miniBox)
local miniRing=I("Frame",{Size=UDim2.new(1,-6,1,-6),Position=UDim2.new(0,3,0,3),BackgroundTransparency=1,BorderSizePixel=0,ZIndex=21},miniBox)
crf(miniRing);I("UIStroke",{Color=C.BL,Thickness=1,Transparency=0.7},miniRing)
local miniFps=I("TextLabel",{Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,.5,-9),BackgroundTransparency=1,Text="--",Font=Enum.Font.GothamBold,TextSize=14,TextColor3=C.GR,ZIndex=22},miniBox)
I("TextLabel",{Size=UDim2.new(1,0,0,9),Position=UDim2.new(0,0,.5,5),BackgroundTransparency=1,Text="FPS",Font=Enum.Font.Gotham,TextSize=8,TextColor3=C.T2,ZIndex=22},miniBox)
local miniDot=I("Frame",{Size=UDim2.new(0,10,0,10),Position=UDim2.new(1,-12,0,2),BackgroundColor3=C.MU,BorderSizePixel=0,ZIndex=23},miniBox)
crf(miniDot);I("UIStroke",{Color=C.HD,Thickness=2},miniDot)

local function setMini(m)
    S.mini=m
    if m then
        local cx=mn.Position.X.Offset+FW/2;local cy=mn.Position.Y.Offset+FH/2
        miniBox.Position=UDim2.new(mn.Position.X.Scale,cx-MINI_SZ/2,mn.Position.Y.Scale,cy-MINI_SZ/2)
        miniBox.Size=UDim2.new(0,0,0,0);miniBox.BackgroundTransparency=1;miniBox.Visible=true
        tw(mn,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.22)
        tw(miniBox,{Size=UDim2.new(0,MINI_SZ,0,MINI_SZ),BackgroundTransparency=0},.25)
        task.delay(.24,function() mn.Visible=false end)
    else
        mn.Visible=true
        local cx=miniBox.Position.X.Offset+MINI_SZ/2;local cy=miniBox.Position.Y.Offset+MINI_SZ/2
        mn.Position=UDim2.new(0,math.clamp(cx-FW/2,0,sg.AbsoluteSize.X-FW),0,math.clamp(cy-FH/2,0,sg.AbsoluteSize.Y-FH))
        mn.Size=UDim2.new(0,0,0,0);mn.BackgroundTransparency=1
        tw(miniBox,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.18)
        tw(mn,{Size=UDim2.new(0,FW,0,FH),BackgroundTransparency=0},.25)
        task.delay(.2,function() miniBox.Visible=false end)
    end
end

local function makeDrag(handle,target,onClick)
    local mc,ec
    local function cl() if mc then mc:Disconnect();mc=nil end;if ec then ec:Disconnect();ec=nil end end
    mCon(handle.InputBegan,function(inp)
        if inp.UserInputType~=Enum.UserInputType.MouseButton1 and inp.UserInputType~=Enum.UserInputType.Touch then return end
        cl();local si,sp,dr=inp.Position,target.Position,false
        mc=UIS.InputChanged:Connect(function(mi)
            if mi.UserInputType~=Enum.UserInputType.MouseMovement and mi.UserInputType~=Enum.UserInputType.Touch then return end
            local d=mi.Position-si;if not dr and d.Magnitude>=5 then dr=true end
            if dr then target.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y) end
        end)
        ec=inp.Changed:Connect(function()
            if inp.UserInputState==Enum.UserInputState.End then cl();if not dr and onClick then onClick() end end
        end)
    end)
end
makeDrag(hd,mn)
makeDrag(miniBox,miniBox,function() setMini(false) end)

local pages={repair=pgR,extra=pgE}
local sideBtns={repair=mbRepair,extra=mbExtra}
local sideY={repair=11,extra=47}
local function sw(id)
    for k,pg in pairs(pages) do pg.Visible=(k==id) end
    tw(sideInd,{Position=UDim2.new(0,0,0,sideY[id] or 11)},.18)
    for k,btn in pairs(sideBtns) do tw(btn,{BackgroundColor3=(k==id) and C.OF or C.SA,TextColor3=(k==id) and C.TX or C.T2},.1) end
end
mCon(mbRepair.MouseButton1Click,function() sw("repair") end)
mCon(mbExtra.MouseButton1Click,function() sw("extra") end)
sw("repair")

mCon(miB.MouseButton1Click,function() setMini(true) end)
mCon(clB.MouseButton1Click,function()
    S.on=false
    tw(mn,{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1},.2)
    task.delay(.25,function() for _,v in ipairs(maid) do if typeof(v)=="RBXScriptConnection" then v:Disconnect() elseif typeof(v)=="Instance" then v:Destroy() end end;maid={} end)
end)
mCon(UIS.InputBegan,function(inp,gpe)
    if not gpe and inp.KeyCode==Enum.KeyCode.F5 then setMini(not S.mini) end
end)

local function updUI()
    stLine.Text=S.on and "✓ Aktif" or "Nonaktif"
    stLine.TextColor3=S.on and C.GR or C.MU
    ctLine.Text=S.on and string.format("Repair: %d",S.count) or ""
    repDot.BackgroundColor3=S.on and C.GR or C.MU
    miniDot.BackgroundColor3=S.on and C.GR or C.MU
end

mCon(tb.MouseButton1Click,function()
    if S.on then
        S.on=false
        tw(tf,{BackgroundColor3=C.OF},.15);tw(tk,{Position=UDim2.new(0,3,.5,-7),BackgroundColor3=C.KN},.15);tw(ts,{Color=C.BD},.15)
        updUI()
    else
        S.on=true;S.count=0
        tw(tf,{BackgroundColor3=Color3.fromRGB(25,108,73)},.15);tw(tk,{Position=UDim2.new(1,-17,.5,-7),BackgroundColor3=C.GR},.15);tw(ts,{Color=C.GR},.15)
        updUI()
        task.spawn(function()
    local remote = game:GetService("ReplicatedStorage")
        :WaitForChild("Remotes")
        :WaitForChild("Base")
    while S.on do
        local hud = PG:FindFirstChild("Hud")
        local repBtn = hud and hud:FindFirstChild("Repair")
        if repBtn and repBtn.Visible then
            pcall(function()
                remote:FireServer("repair")
            end)
            S.count += 1
        end
        task.wait(INT)
    end
end)
        task.spawn(function() while S.on do task.wait(1);updUI() end end)
    end
end)

RS.Heartbeat:Connect(function()
    local f=fTick()
    if f~=fps.last then fps.last=f;local col=fCol(f);fL.Text=f.." FPS";fL.TextColor3=col;miniFps.Text=tostring(f);miniFps.TextColor3=col end
end)

mn.Size=UDim2.new(0,0,0,0);mn.BackgroundTransparency=1
task.delay(.1,function() tw(mn,{Size=UDim2.new(0,FW,0,FH),BackgroundTransparency=0},.35) end)
