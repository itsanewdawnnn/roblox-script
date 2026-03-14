if not table.pack then table.pack = function(...) return {n = select("#", ...), ...} end end

local Players = game:GetService("Players")
local PG = Players.LocalPlayer:WaitForChild("PlayerGui")
local RS = game:GetService("ReplicatedStorage")
local SID = "_d" .. tostring(math.random(100000, 999999))

-- Cleanup
for _, v in pairs(PG:GetChildren()) do if v.Name == "DSpyLite" then v:Destroy() end end
pcall(function() for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do if v.Name == "DSpyLite" then v:Destroy() end end end)
pcall(function() if gethui then for _, v in pairs(gethui():GetChildren()) do if v.Name == "DSpyLite" then v:Destroy() end end end end)

----------------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------------
local MAX_LOGS = 200
local STR_LIMIT = 200
local DEDUP_WINDOW = 0.05

----------------------------------------------------------------------
-- COLORS
----------------------------------------------------------------------
local C = {
    BG  = Color3.fromRGB(12, 14, 20),
    HD  = Color3.fromRGB(18, 21, 30),
    BD  = Color3.fromRGB(255, 80, 80),
    TX  = Color3.fromRGB(235, 240, 255),
    T2  = Color3.fromRGB(140, 155, 185),
    GR  = Color3.fromRGB(50, 215, 145),
    YL  = Color3.fromRGB(255, 210, 60),
    RD  = Color3.fromRGB(255, 100, 100),
    BL  = Color3.fromRGB(100, 150, 255),
    PR  = Color3.fromRGB(180, 100, 255),
    OG  = Color3.fromRGB(255, 150, 50),
    SC  = Color3.fromRGB(8, 10, 15),
    BN  = Color3.fromRGB(36, 42, 58),
    CL  = Color3.fromRGB(110, 30, 42),
    DIM = Color3.fromRGB(80, 90, 110),
}

----------------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------------
local function I(c, p, par)
    local o = Instance.new(c)
    for k, v in pairs(p) do o[k] = v end
    o.Parent = par
    return o
end
local function cr(o, r) I("UICorner", {CornerRadius = UDim.new(0, r)}, o) end

----------------------------------------------------------------------
-- STATE
----------------------------------------------------------------------
local excludeList = {}
local connections = {}
local alive = true
local pauseOn = false
local searchText = ""
local n = 0

local filterMode = 0
local filterModes = {"All", "C→S", "Btn"}
local filterCats = {nil, "remote_out", "button"}
local filterColors = {C.T2, C.RD, C.GR}

local knownServices = {
    ReplicatedStorage = true, Workspace = true, Players = true,
    ReplicatedFirst = true, StarterPlayer = true, Chat = true,
    SoundService = true, Lighting = true, StarterGui = true,
}

local function track(conn)
    connections[#connections + 1] = conn
    return conn
end

----------------------------------------------------------------------
-- GUI
----------------------------------------------------------------------
local sg = I("ScreenGui", {Name = "DSpyLite", ResetOnSpawn = false, DisplayOrder = 1001}, nil)
local guiParent
if gethui then
    guiParent = gethui()
elseif syn and syn.protect_gui then
    guiParent = PG; syn.protect_gui(sg)
else
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    guiParent = ok and cg or PG
end
sg.Parent = guiParent

local fr = I("Frame", {
    Size = UDim2.new(0, 500, 0, 400),
    Position = UDim2.new(0.5, -250, 0, 6),
    BackgroundColor3 = C.BG,
    BorderSizePixel = 0,
    Active = true,
    Draggable = true,
}, sg)
cr(fr, 10)
I("UIStroke", {Color = C.BD, Thickness = 1}, fr)

-- Title
I("TextLabel", {
    Size = UDim2.new(0, 130, 0, 32),
    BackgroundTransparency = 1,
    Text = "  DEEP Spy Lite",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = C.YL,
    TextXAlignment = Enum.TextXAlignment.Left,
}, fr)

----------------------------------------------------------------------
-- HEADER BUTTONS
----------------------------------------------------------------------
local btnX = 500 - 25

local function hdrBtn(w, txt, col)
    btnX = btnX - w - 3
    local b = I("TextButton", {
        Size = UDim2.new(0, w, 0, 20),
        Position = UDim2.new(0, btnX, 0, 6),
        BackgroundColor3 = C.BN,
        Text = txt,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextColor3 = col or C.T2,
        AutoButtonColor = false,
    }, fr)
    cr(b, 5)
    return b
end

-- Close button
local clsBtn = I("TextButton", {
    Size = UDim2.new(0, 20, 0, 20),
    Position = UDim2.new(1, -23, 0, 6),
    BackgroundColor3 = C.CL,
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(255, 200, 200),
    AutoButtonColor = false,
}, fr)
cr(clsBtn, 5)

local clrBtn  = hdrBtn(34, "Clear")
local pBtn    = hdrBtn(36, "Pause")
local fBtn    = hdrBtn(28, "All")
local dmpBtn  = hdrBtn(36, "Dump")
local unexBtn = hdrBtn(38, "UnExc")

-- Search box
local searchBox = I("TextBox", {
    Size = UDim2.new(0, 90, 0, 20),
    Position = UDim2.new(0, 130, 0, 6),
    BackgroundColor3 = C.BN,
    Text = "",
    PlaceholderText = "Search...",
    Font = Enum.Font.Gotham,
    TextSize = 9,
    TextColor3 = C.TX,
    PlaceholderColor3 = C.T2,
    ClearTextOnFocus = false,
    BorderSizePixel = 0,
}, fr)
cr(searchBox, 5)
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    searchText = searchBox.Text:lower()
end)

----------------------------------------------------------------------
-- SCROLL AREA
----------------------------------------------------------------------
local scroll = I("ScrollingFrame", {
    Size = UDim2.new(1, -12, 1, -38),
    Position = UDim2.new(0, 6, 0, 32),
    BackgroundColor3 = C.SC,
    BorderSizePixel = 0,
    ScrollBarThickness = 5,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, fr)
cr(scroll, 6)
I("UIListLayout", {Padding = UDim.new(0, 1)}, scroll)

----------------------------------------------------------------------
-- SERIALIZER (simplified)
----------------------------------------------------------------------
local function ser(v, d, seen)
    d = d or 0
    seen = seen or {}
    if d > 5 then return "..." end
    local t = typeof(v)

    if t == "string" then
        local e = v:gsub("\\","\\\\"):gsub("\n","\\n"):gsub('"','\\"')
        if #e > STR_LIMIT then return '"'..e:sub(1,STR_LIMIT)..'..."' end
        return '"'..e..'"'
    elseif t == "number" or t == "boolean" then return tostring(v)
    elseif t == "nil" then return "nil"
    elseif t == "Instance" then
        local ok, r = pcall(function() return v:GetFullName().." ["..v.ClassName.."]" end)
        return ok and r or "<destroyed>"
    elseif t == "Vector3" then return string.format("Vector3.new(%g,%g,%g)", v.X, v.Y, v.Z)
    elseif t == "CFrame" then return string.format("CFrame.new(%g,%g,%g,...)", v.Position.X, v.Position.Y, v.Position.Z)
    elseif t == "Color3" then return string.format("Color3.fromRGB(%d,%d,%d)", math.floor(v.R*255), math.floor(v.G*255), math.floor(v.B*255))
    elseif t == "EnumItem" then return tostring(v)
    elseif t == "UDim2" then return string.format("UDim2.new(%g,%d,%g,%d)", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset)
    elseif t == "table" then
        if seen[v] then return "<circular>" end
        seen[v] = true
        local p = {}
        for k, x in pairs(v) do
            if k ~= "n" then
                p[#p+1] = "["..ser(k,d+1,seen).."]="..ser(x,d+1,seen)
            end
        end
        seen[v] = nil
        return #p == 0 and "{}" or "{"..table.concat(p,", ").."}"
    else
        return "<"..t..":"..tostring(v)..">"
    end
end

----------------------------------------------------------------------
-- CODE BUILDER (for copy/run)
----------------------------------------------------------------------
local function buildCode(cls, path, args)
    local parts = string.split(path, ".")
    local si = 1
    for i, p in ipairs(parts) do if knownServices[p] then si = i; break end end
    local code = 'game:GetService("'..parts[si]..'")'
    for i = si+1, #parts do code = code..':WaitForChild("'..parts[i]..'")'  end
    code = code..(cls == "RemoteEvent" and ":FireServer(" or ":InvokeServer(")

    local a = {}
    local argc = args.n or #args
    for i = 1, argc do
        local v = args[i]
        local t = typeof(v)
        if t == "Instance" then
            local fp = v:GetFullName()
            local pts = string.split(fp, ".")
            local s2 = 1
            for j, p2 in ipairs(pts) do if knownServices[p2] then s2 = j; break end end
            local c2 = 'game:GetService("'..pts[s2]..'")'
            for j = s2+1, #pts do c2 = c2..':WaitForChild("'..pts[j]..'")' end
            a[#a+1] = c2
        elseif t == "CFrame" then
            local comp = {v:GetComponents()}
            a[#a+1] = string.format("CFrame.new(%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g)", unpack(comp))
        else
            a[#a+1] = ser(v)
        end
    end
    return code..table.concat(a, ", ")..")"
end

----------------------------------------------------------------------
-- DEDUP
----------------------------------------------------------------------
local dedupCache = {}

local function isDuplicate(name, args)
    local parts = {name}
    local argc = args.n or #args
    for i = 1, math.min(argc, 3) do
        parts[#parts+1] = ser(args[i], 0):sub(1, 40)
    end
    local fp = table.concat(parts, "|")
    local now = os.clock()
    if dedupCache[fp] and (now - dedupCache[fp]) < DEDUP_WINDOW then return true end
    dedupCache[fp] = now
    return false
end

----------------------------------------------------------------------
-- LOG FUNCTION
----------------------------------------------------------------------
local function log(txt, col, cat, code)
    if not alive or pauseOn then return
    end
    if filterMode > 0 and filterCats[filterMode+1] ~= cat then return end
    if searchText ~= "" and not string.find(txt:lower(), searchText) then return end

    n += 1
    local timeStr = string.format("%.3f", os.clock() % 1000)

    local container = I("Frame", {
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = n,
    }, scroll)

    local row = I("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
    }, container)
    I("UIListLayout", {FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2)}, row)

    -- Time
    I("TextLabel", {
        Size = UDim2.new(0, 42, 0, 14),
        BackgroundTransparency = 1,
        Text = timeStr,
        Font = Enum.Font.Code,
        TextSize = 8,
        TextColor3 = C.DIM,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
    }, row)

    -- Main text
    local lb = I("TextLabel", {
        Size = UDim2.new(1, code and -100 or -50, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "["..n.."] "..txt,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = col or C.GR,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        LayoutOrder = 2,
    }, row)

    -- Run & Copy buttons
    if code then
        local runBtn = I("TextButton", {
            Size = UDim2.new(0, 24, 0, 16),
            BackgroundColor3 = Color3.fromRGB(25, 108, 73),
            Text = "▶", Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.GR, AutoButtonColor = false, LayoutOrder = 3,
        }, row)
        cr(runBtn, 4)
        runBtn.MouseButton1Click:Connect(function()
            local ok = pcall(function() return loadstring(code)() end)
            runBtn.Text = ok and "✓" or "✗"
            runBtn.TextColor3 = ok and C.GR or C.RD
            task.delay(1, function() if runBtn.Parent then runBtn.Text = "▶"; runBtn.TextColor3 = C.GR end end)
        end)

        local cpBtn = I("TextButton", {
            Size = UDim2.new(0, 24, 0, 16),
            BackgroundColor3 = C.BN,
            Text = "⎘", Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = C.T2, AutoButtonColor = false, LayoutOrder = 4,
        }, row)
        cr(cpBtn, 4)
        cpBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(code) end
            cpBtn.TextColor3 = C.GR
            task.delay(0.5, function() if cpBtn.Parent then cpBtn.TextColor3 = C.T2 end end)
        end)
    end

    -- Long press to exclude
    local remoteName = txt:match("Name: ([^\n]+)")
    local pressStart = 0
    lb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            pressStart = os.clock()
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 and remoteName then
            excludeList[remoteName] = true
            log("Excluded: "..remoteName, C.YL, "remote_out")
        end
    end)
    lb.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if (os.clock() - pressStart) >= 0.6 and remoteName then
                excludeList[remoteName] = true
                log("Excluded: "..remoteName, C.YL, "remote_out")
            elseif code and setclipboard then
                setclipboard(code)
                local orig = lb.TextColor3
                lb.TextColor3 = C.GR
                task.delay(0.5, function() if lb.Parent then lb.TextColor3 = orig end end)
            end
        end
    end)

    task.defer(function() scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y) end)

    -- Trim old logs
    local labels = {}
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("Frame") then labels[#labels+1] = c end
    end
    if #labels > MAX_LOGS then
        table.sort(labels, function(a, b) return a.LayoutOrder < b.LayoutOrder end)
        while #labels > MAX_LOGS do labels[1]:Destroy(); table.remove(labels, 1) end
    end
end

----------------------------------------------------------------------
-- REMOTE LOGGER
----------------------------------------------------------------------
local function logRemote(icon, col, cls, method, self, args, cat)
    local ok, name = pcall(function() return self.Name end)
    if not ok then return end
    if excludeList[self] or excludeList[name] then return end
    if isDuplicate(name, args) then return end

    local ok2, path = pcall(function() return self:GetFullName() end)
    if not ok2 then path = "<unknown>" end

    local txt = icon.." "..cls..":"..method.."()\n  Path: "..path.."\n  Name: "..name
    local argc = args.n or #args
    if argc == 0 then
        txt = txt.."\n  (no args)"
    else
        for i = 1, argc do
            txt = txt.."\n  arg["..i.."]="..ser(args[i])
        end
    end

    -- Source script
    if getcallingscript then
        local ok3, src = pcall(getcallingscript)
        if ok3 and src then
            local ok4, fp = pcall(function() return src:GetFullName() end)
            if ok4 then txt = txt.."\n  Source: "..fp end
        end
    end

    local code = (cat == "remote_out") and buildCode(cls, path, args) or nil
    if code then txt = txt.."\n  ── code ──\n  "..code end

    log(txt, col, cat, code)
end

----------------------------------------------------------------------
-- HEADER BUTTON HANDLERS
----------------------------------------------------------------------
clrBtn.MouseButton1Click:Connect(function()
    for _, c in pairs(scroll:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    n = 0
end)

pBtn.MouseButton1Click:Connect(function()
    pauseOn = not pauseOn
    pBtn.Text = pauseOn and "Play" or "Pause"
    pBtn.TextColor3 = pauseOn and C.YL or C.T2
end)

fBtn.MouseButton1Click:Connect(function()
    filterMode = (filterMode + 1) % #filterModes
    fBtn.Text = filterModes[filterMode+1]
    fBtn.TextColor3 = filterColors[filterMode+1]
end)

unexBtn.MouseButton1Click:Connect(function()
    local count = 0
    local list = {}
    for name, _ in pairs(excludeList) do
        if type(name) == "string" then count += 1; list[#list+1] = name end
    end
    if count == 0 then
        log("No excluded remotes", C.T2, "remote_out")
        return
    end
    excludeList = {}
    log("UN-EXCLUDED "..count.." remote(s): "..table.concat(list, ", "), C.GR, "remote_out")
end)

dmpBtn.MouseButton1Click:Connect(function()
    local dump = ""
    for svc, _ in pairs(knownServices) do
        pcall(function()
            for _, v in ipairs(game:GetService(svc):GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    dump = dump..v.ClassName..": "..v:GetFullName().."\n"
                end
            end
        end)
    end
    if setclipboard then
        setclipboard(dump)
        log("Dump copied to clipboard!", C.GR, "remote_out")
    else
        log(dump, C.T2, "remote_out")
    end
end)

----------------------------------------------------------------------
-- METATABLE HOOKS — captures ALL remote fires (no checkcaller skip)
----------------------------------------------------------------------
local mt = getrawmetatable and getrawmetatable(game)
local oldNamecall, oldIndex
local wrappedCache = setmetatable({}, {__mode = "k"})

if mt then
    oldNamecall = mt.__namecall
    oldIndex = mt.__index
    if setreadonly then setreadonly(mt, false) end

    local clonedNamecall = clonefunction and clonefunction(oldNamecall) or oldNamecall
    local clonedIndex = clonefunction and clonefunction(oldIndex) or oldIndex

    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if typeof(self) == "Instance" then
            local args = table.pack(...)
            if m == "FireServer" and self:IsA("RemoteEvent") then
                local isExec = checkcaller and checkcaller()
                logRemote(isExec and "▶EX" or "▶RE", isExec and C.OG or C.RD, "RemoteEvent", "FireServer", self, args, "remote_out")
            elseif m == "InvokeServer" and self:IsA("RemoteFunction") then
                local isExec = checkcaller and checkcaller()
                local ret = table.pack(clonedNamecall(self, ...))
                logRemote(isExec and "▶EX" or "▶RF", isExec and C.OG or C.PR, "RemoteFunction", "InvokeServer", self, args, "remote_out")
                return unpack(ret, 1, ret.n)
            end
        end
        return clonedNamecall(self, ...)
    end)

    mt.__index = newcclosure(function(self, key)
        local result = clonedIndex(self, key)
        if typeof(self) == "Instance" and typeof(result) == "function" then
            if (key == "FireServer" and self:IsA("RemoteEvent")) or (key == "InvokeServer" and self:IsA("RemoteFunction")) then
                if not wrappedCache[self] then wrappedCache[self] = {} end
                if not wrappedCache[self][key] then
                    local orig = result
                    wrappedCache[self][key] = newcclosure(function(s, ...)
                        local isExec = checkcaller and checkcaller()
                        local args = table.pack(...)
                        if key == "InvokeServer" and s:IsA("RemoteFunction") then
                            local ret = table.pack(orig(s, ...))
                            logRemote(isExec and "▶EX" or "▶IX", isExec and C.OG or C.OG, "RemoteFunction", key, s, args, "remote_out")
                            return unpack(ret, 1, ret.n)
                        end
                        local cls = s:IsA("RemoteEvent") and "RemoteEvent" or "RemoteFunction"
                        logRemote(isExec and "▶EX" or "▶IX", isExec and C.OG or C.OG, cls, key, s, args, "remote_out")
                        return orig(s, ...)
                    end)
                end
                return wrappedCache[self][key]
            end
        end
        return result
    end)

    if setreadonly then setreadonly(mt, true) end
end

----------------------------------------------------------------------
-- HOOKFUNCTION — captures ALL remote fires
----------------------------------------------------------------------
if hookfunction or hookfunc then
    local hf = hookfunction or hookfunc
    pcall(function()
        local o; o = hf(Instance.new("RemoteEvent").FireServer, newcclosure(function(self, ...)
            if typeof(self) == "Instance" and self:IsA("RemoteEvent") then
                local isExec = checkcaller and checkcaller()
                logRemote(isExec and "▶EX" or "▶HK", isExec and C.OG or C.RD, "RemoteEvent", "FireServer", self, table.pack(...), "remote_out")
            end
            return o(self, ...)
        end))
    end)
    pcall(function()
        local o; o = hf(Instance.new("RemoteFunction").InvokeServer, newcclosure(function(self, ...)
            if typeof(self) == "Instance" and self:IsA("RemoteFunction") then
                local isExec = checkcaller and checkcaller()
                local args = table.pack(...)
                local ret = table.pack(o(self, ...))
                logRemote(isExec and "▶EX" or "▶HK", isExec and C.OG or C.PR, "RemoteFunction", "InvokeServer", self, args, "remote_out")
                return unpack(ret, 1, ret.n)
            end
            return o(self, ...)
        end))
    end)
end

----------------------------------------------------------------------
-- BUTTON HOOKS (UI clicks)
----------------------------------------------------------------------
local function hookSingleBtn(d, gui)
    if (d:IsA("TextButton") or d:IsA("ImageButton")) and not d:GetAttribute(SID) then
        d:SetAttribute(SID, true)
        track(d.MouseButton1Click:Connect(function()
            local t = d:IsA("TextButton") and d.Text or ""
            local tl = d:FindFirstChildWhichIsA("TextLabel")
            if tl then t = t.." | "..tl.Text end
            log("BTN "..gui.Name.." → "..d:GetFullName().."\n  Text: "..t, Color3.fromRGB(100, 255, 100), "button")
        end))
    end
end

local function hookGuiButtons(gui)
    if not gui:IsA("ScreenGui") or gui.Name == "DSpyLite" then return end
    for _, d in ipairs(gui:GetDescendants()) do hookSingleBtn(d, gui) end
    track(gui.DescendantAdded:Connect(function(d)
        task.wait(0.1)
        if alive then hookSingleBtn(d, gui) end
    end))
end

for _, gui in ipairs(PG:GetChildren()) do hookGuiButtons(gui) end
track(PG.ChildAdded:Connect(function(gui)
    task.wait(0.3)
    if alive then hookGuiButtons(gui) end
end))

----------------------------------------------------------------------
-- CLOSE
----------------------------------------------------------------------
clsBtn.MouseButton1Click:Connect(function()
    alive = false
    for _, conn in ipairs(connections) do pcall(function() conn:Disconnect() end) end
    connections = {}
    if mt then
        pcall(function()
            mt.__namecall = oldNamecall
            mt.__index = oldIndex
            if setreadonly then setreadonly(mt, true) end
        end)
    end
    sg:Destroy()
end)

----------------------------------------------------------------------
-- STARTUP
----------------------------------------------------------------------
local rc = 0
for _, v in ipairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then rc += 1 end
end
log("DEEP Spy Lite | Remotes: "..rc.." | ▶=run ⎘=copy | Hold=exclude\n  Captures ALL remote fires (game + executor)\n  ▶RE=game RemoteEvent | ▶RF=game RemoteFunction | ▶EX=executor", C.YL, "remote_out")
