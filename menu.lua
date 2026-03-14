local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")

for _, ui in ipairs(PlayerGui:GetChildren()) do
	if ui.Name == "MainMenuGUI" then ui:Destroy() end
end

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------
local C = {
	Cols    = 3,
	Rows    = 3,
	Cell    = 64,
	Gap     = 5,
	Pad     = 8,
	HeaderH = 30,
	FooterH = 18,
	Radius  = 10,

	Bg      = Color3.fromRGB(17, 19, 28),
	Header  = Color3.fromRGB(22, 25, 36),
	Accent  = Color3.fromRGB(85, 135, 230),
	Text    = Color3.fromRGB(225, 230, 242),
	Dim     = Color3.fromRGB(90, 96, 115),
	Border  = Color3.fromRGB(38, 42, 56),
}

local gridW  = C.Cols * C.Cell + (C.Cols - 1) * C.Gap
local gridH  = C.Rows * C.Cell + (C.Rows - 1) * C.Gap
local frameW = gridW + C.Pad * 2
local frameH = C.HeaderH + C.Pad + gridH + C.Pad + C.FooterH

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------
local function Make(cls, p, parent)
	local o = Instance.new(cls)
	for k, v in pairs(p) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function Rnd(el, r) Make("UICorner", { CornerRadius = UDim.new(0, r or 8) }, el) end
local function Brdr(el, c, t) Make("UIStroke", { Color = c or C.Border, Transparency = t or 0.7, Thickness = 1 }, el) end

local fast   = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local smooth = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--------------------------------------------------------------------------------
-- STATE
--------------------------------------------------------------------------------
local gui
local function CloseMenu()
	if not gui then return end
	local f = gui:FindFirstChild("F")
	if f then
		TweenService:Create(f, TweenInfo.new(0.15), {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, frameW * 0.94, 0, frameH * 0.94),
		}):Play()
		task.wait(0.15)
	end
	gui:Destroy()
end

local function Run(url)
	return function()
		CloseMenu()
		loadstring(game:HttpGet(url))()
	end
end

--------------------------------------------------------------------------------
-- MENU DATA
--------------------------------------------------------------------------------
local items = {
	{ name = "Deep Spy",  bg = Color3.fromRGB(30, 46, 78),  hv = Color3.fromRGB(38, 56, 95),  gl = Color3.fromRGB(65, 115, 215), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/deepspy.lua") },

	{ name = "Tools",   bg = Color3.fromRGB(58, 42, 20),  hv = Color3.fromRGB(72, 54, 28),  gl = Color3.fromRGB(210, 145, 45), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/tools.lua") },

	{ name = "67",         bg = Color3.fromRGB(32, 34, 44),  hv = Color3.fromRGB(42, 44, 56),  gl = Color3.fromRGB(140, 146, 170), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/67.luaa") },

	{ name = "Menu 4",    bg = Color3.fromRGB(55, 24, 34),  hv = Color3.fromRGB(68, 32, 44),  gl = Color3.fromRGB(215, 65, 85), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/menu4.lua") },

	{ name = "Menu 5",    bg = Color3.fromRGB(18, 44, 34),  hv = Color3.fromRGB(26, 58, 45),  gl = Color3.fromRGB(45, 180, 95), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/menu5.lua") },

	{ name = "Menu 6",    bg = Color3.fromRGB(38, 28, 58),  hv = Color3.fromRGB(50, 38, 72),  gl = Color3.fromRGB(115, 80, 215), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/menu6.lua.lua") },

	{ name = "Menu 7",    bg = Color3.fromRGB(18, 38, 46),  hv = Color3.fromRGB(26, 50, 60),  gl = Color3.fromRGB(45, 158, 182), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/menu7.lua.lua") },

	{ name = "Menu 8",    bg = Color3.fromRGB(46, 40, 18),  hv = Color3.fromRGB(58, 52, 26),  gl = Color3.fromRGB(178, 158, 42), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/menu8.lua") },

	{ name = "Template",    bg = Color3.fromRGB(28, 30, 36),  hv = Color3.fromRGB(38, 40, 48),  gl = Color3.fromRGB(128, 134, 155), fn = Run("https://raw.githubusercontent.com/itsanewdawnnn/roblox-script/refs/heads/main/release/template.lua") },
}

--------------------------------------------------------------------------------
-- BUILD
--------------------------------------------------------------------------------
gui = Make("ScreenGui", {
	Name = "MainMenuGUI", ResetOnSpawn = false, DisplayOrder = 9999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, PlayerGui)

local frame = Make("Frame", {
	Name             = "F",
	Size             = UDim2.new(0, frameW, 0, frameH),
	Position         = UDim2.new(0.5, -frameW / 2, 0.5, -frameH / 2),
	BackgroundColor3 = C.Bg,
	Active           = true,
	Draggable        = true,
	ZIndex           = 5,
}, gui)
Rnd(frame, C.Radius)
Brdr(frame, C.Border, 0.55)

-- Gradient overlay (non-interactable so buttons underneath remain clickable)
local ov = Make("Frame", {
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 0.75,
	ZIndex = 5,
}, frame)
Rnd(ov, C.Radius)
Make("UIGradient", {
	Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 62, 110)),
		ColorSequenceKeypoint.new(1, C.Bg),
	},
	Rotation = 150,
}, ov)

-- Accent line
local glow = Make("Frame", {
	Size = UDim2.new(0.45, 0, 0, 1),
	Position = UDim2.new(0.275, 0, 0, 0),
	BackgroundColor3 = C.Accent,
	BackgroundTransparency = 0.45,
	BorderSizePixel = 0,
	ZIndex = 12,
}, frame)

--------------------------------------------------------------------------------
-- HEADER
--------------------------------------------------------------------------------
local hdr = Make("Frame", {
	Size = UDim2.new(1, 0, 0, C.HeaderH),
	BackgroundColor3 = C.Header,
	BackgroundTransparency = 0.1,
	ZIndex = 6,
}, frame)
Rnd(hdr, C.Radius)

-- Separator
Make("Frame", {
	Size = UDim2.new(1, -16, 0, 1),
	Position = UDim2.new(0, 8, 1, -1),
	BackgroundColor3 = C.Border,
	BackgroundTransparency = 0.55,
	BorderSizePixel = 0,
	ZIndex = 7,
}, hdr)

-- Dot
local dot = Make("Frame", {
	Size = UDim2.new(0, 5, 0, 5),
	Position = UDim2.new(0, 10, 0.5, -2),
	BackgroundColor3 = C.Accent,
	ZIndex = 10,
}, hdr)
Rnd(dot, 3)

spawn(function()
	while gui and gui.Parent do
		TweenService:Create(dot, TweenInfo.new(1, Enum.EasingStyle.Sine), { BackgroundTransparency = 0.55 }):Play()
		task.wait(1)
		TweenService:Create(dot, TweenInfo.new(1, Enum.EasingStyle.Sine), { BackgroundTransparency = 0 }):Play()
		task.wait(1)
	end
end)

-- Title
Make("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -60, 1, 0),
	Position = UDim2.new(0, 22, 0, 0),
	Font = Enum.Font.GothamBold,
	Text = "MAIN MENU",
	TextColor3 = C.Text,
	TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left,
	ZIndex = 10,
}, hdr)

--------------------------------------------------------------------------------
-- HEADER BUTTONS
--------------------------------------------------------------------------------
local minimized = false
local toggles   = { ov, glow }

local function HBtn(txt, ox, hvCol, act)
	local b = Make("TextButton", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(1, ox, 0.5, -9),
		BackgroundColor3 = Color3.fromRGB(28, 32, 44),
		TextColor3 = C.Dim,
		Font = Enum.Font.GothamBold,
		Text = txt, TextSize = 10,
		AutoButtonColor = false, ZIndex = 10,
	}, hdr)
	Rnd(b, 5)
	Brdr(b, C.Border, 0.78)
	b.MouseEnter:Connect(function() TweenService:Create(b, fast, { BackgroundColor3 = hvCol, TextColor3 = C.Text }):Play() end)
	b.MouseLeave:Connect(function() TweenService:Create(b, fast, { BackgroundColor3 = Color3.fromRGB(28, 32, 44), TextColor3 = C.Dim }):Play() end)
	if act then b.MouseButton1Click:Connect(act) end
	return b
end

local minBtn = HBtn("–", -44, Color3.fromRGB(40, 45, 62), function()
	minimized = not minimized
	local sz = minimized and UDim2.new(0, frameW, 0, C.HeaderH) or UDim2.new(0, frameW, 0, frameH)
	TweenService:Create(frame, smooth, { Size = sz }):Play()
	for _, e in ipairs(toggles) do e.Visible = not minimized end
	minBtn.Text = minimized and "+" or "–"
end)

HBtn("✕", -22, Color3.fromRGB(62, 26, 30), CloseMenu)

--------------------------------------------------------------------------------
-- GRID (3×3, text only)
--------------------------------------------------------------------------------
local gy = C.HeaderH + C.Pad

for i, m in ipairs(items) do
	local col = (i - 1) % C.Cols
	local row = math.floor((i - 1) / C.Cols)
	local px  = C.Pad + col * (C.Cell + C.Gap)
	local py  = gy + row * (C.Cell + C.Gap)

	local btn = Make("TextButton", {
		Size = UDim2.new(0, C.Cell, 0, C.Cell),
		Position = UDim2.new(0, px, 0, py),
		BackgroundColor3 = m.bg,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 8,
	}, frame)
	Rnd(btn, 9)
	Brdr(btn, C.Border, 0.78)

	-- Inner glow
	local ig = Make("Frame", {
		Size = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = m.gl,
		BackgroundTransparency = 1,
		ZIndex = 8,
	}, btn)
	Rnd(ig, 9)
	Make("UIGradient", {
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		},
		Rotation = 180,
	}, ig)

	-- Label (centered, text only)
	Make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -8, 1, 0),
		Position = UDim2.new(0, 4, 0, 0),
		Font = Enum.Font.GothamMedium,
		Text = m.name,
		TextColor3 = Color3.fromRGB(195, 200, 218),
		TextSize = 10,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 10,
	}, btn)

	-- Hover
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, fast, { BackgroundColor3 = m.hv }):Play()
		TweenService:Create(ig, fast, { BackgroundTransparency = 0.84 }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, fast, { BackgroundColor3 = m.bg }):Play()
		TweenService:Create(ig, fast, { BackgroundTransparency = 1 }):Play()
	end)

	-- Action
	btn.MouseButton1Click:Connect(m.fn or function()
		warn("[Menu] " .. m.name .. " — belum tersedia")
	end)

	table.insert(toggles, btn)
end

--------------------------------------------------------------------------------
-- FOOTER
--------------------------------------------------------------------------------
local ftr = Make("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, -C.Pad * 2, 0, C.FooterH),
	Position = UDim2.new(0, C.Pad, 1, -C.FooterH),
	Font = Enum.Font.Gotham,
	Text = "MADE WITH ♥ BY ITSANEWDAWNNN",
	TextColor3 = Color3.fromRGB(50, 55, 70),
	TextSize = 7,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 10,
}, frame)
table.insert(toggles, ftr)
