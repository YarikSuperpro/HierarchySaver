--!strict
local plugin = script:FindFirstAncestorOfClass("Plugin")::Plugin
local Dir:Script = script.Parent

--[[Question of a decade:
Who came first:
Plugin or this script?
Answer: plugin obviously i just made init script for people who don't understand wth does .rbxm file does.

Script is compiled by this plugin itself by the way
]]

local Main = Instance.new("Frame") do
	Main.Name = "Main"
	Main.AnchorPoint = Vector2.new(0.5,0.5)
	Main.BackgroundColor3 = Color3.new(1,1,1)
	Main.BackgroundTransparency = 1
	Main.BorderColor3 = Color3.new(0,0,0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.5,0,0.5,0)
	Main.Size = UDim2.new(1,0,1,0)
	Main.ZIndex = 0
end

local ViewTabs = Instance.new("Frame") do
	ViewTabs.Name = "ViewTabs"
	ViewTabs.AnchorPoint = Vector2.new(0.5,1)
	ViewTabs.BackgroundColor3 = Color3.new(0.196,0.196,0.196)
	ViewTabs.BorderColor3 = Color3.new(0,0,0)
	ViewTabs.BorderSizePixel = 0
	ViewTabs.Position = UDim2.new(0.5,0,0.862,0)
	ViewTabs.Size = UDim2.new(1,0,0.817,0)
	ViewTabs.Parent = Main
end
local UpperBar = Instance.new("Frame") do
	UpperBar.Name = "UpperBar"
	UpperBar.AnchorPoint = Vector2.new(0.5,0.5)
	UpperBar.BackgroundColor3 = Color3.new(0.118,0.118,0.118)
	UpperBar.BorderColor3 = Color3.new(0,0,0)
	UpperBar.BorderSizePixel = 0
	UpperBar.Position = UDim2.new(0.499,0,0.023,0)
	UpperBar.Size = UDim2.new(1,0,0.046,0)
	UpperBar.ZIndex = 2
	UpperBar.Parent = Main
end

local UIListLayout = Instance.new("UIListLayout") do
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = UpperBar
end
local LowerBar = Instance.new("Frame") do
	LowerBar.Name = "LowerBar"
	LowerBar.BackgroundColor3 = Color3.new(0.098,0.098,0.098)
	LowerBar.BorderColor3 = Color3.new(0,0,0)
	LowerBar.BorderSizePixel = 0
	LowerBar.Position = UDim2.new(0,0,0.862,0)
	LowerBar.Size = UDim2.new(1,0,0.138,0)
	LowerBar.ZIndex = 10
	LowerBar.Parent = Main
end

local Convert = Instance.new("TextButton") do
	Convert.Name = "Convert"
	Convert.AnchorPoint = Vector2.new(0.5,0.5)
	Convert.AutoButtonColor = false
	Convert.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Convert.BackgroundTransparency = 1
	Convert.BorderColor3 = Color3.new(0,0,0)
	Convert.BorderSizePixel = 0
	Convert.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Convert.Position = UDim2.new(0.5,0,0.5,0)
	Convert.RichText = true
	Convert.Size = UDim2.new(0.532,0,0.626,0)
	Convert.Text = "\\"
	Convert.TextColor3 = Color3.new(1,1,1)
	Convert.TextScaled = true
	Convert.TextSize = 14
	Convert.TextTransparency = 1
	Convert.TextWrapped = true
	Convert.ZIndex = 11
	Convert.Parent = LowerBar
end

local Label = Instance.new("TextLabel") do
	Label.Name = "Label"
	Label.Active = true
	Label.AnchorPoint = Vector2.new(0.5,0.5)
	Label.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Label.BorderColor3 = Color3.new(0,0,0)
	Label.BorderSizePixel = 0
	Label.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Label.Position = UDim2.new(0.5,0,0.5,0)
	Label.RichText = true
	Label.Selectable = true
	Label.Size = UDim2.new(1,0,1,0)
	Label.Text = "Convert"
	Label.TextColor3 = Color3.new(1,1,1)
	Label.TextScaled = true
	Label.TextSize = 14
	Label.TextWrapped = true
	Label.ZIndex = 10
	Label.Parent = Convert
end

local UICorner = Instance.new("UICorner") do
	UICorner.CornerRadius = UDim.new(0.2,0)
	UICorner.Parent = Label
end
local UIGradient = Instance.new("UIGradient") do
	UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1));ColorSequenceKeypoint.new(0.14,Color3.new(0.51,0.51,0.51));ColorSequenceKeypoint.new(0.699,Color3.new(0.69,0.69,0.69));ColorSequenceKeypoint.new(1,Color3.new(0.6,0.6,0.6));})
	UIGradient.Enabled = false
	UIGradient.Rotation = 90
	UIGradient.Parent = Label
end
local Open_Base_Frame = Instance.new("Frame") do
	Open_Base_Frame.Name = "Open_Base_Frame"
	Open_Base_Frame.Active = true
	Open_Base_Frame.AnchorPoint = Vector2.yAxis
	Open_Base_Frame.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Open_Base_Frame.BorderColor3 = Color3.new(0,0,0)
	Open_Base_Frame.BorderSizePixel = 0
	Open_Base_Frame.Position = UDim2.new(0,0,1,0)
	Open_Base_Frame.Selectable = true
	Open_Base_Frame.Size = UDim2.new(0.1,0,0.5,0)
	Open_Base_Frame.ZIndex = 11
	Open_Base_Frame.Parent = LowerBar
end

local UICorner_1 = Instance.new("UICorner") do
	UICorner_1.CornerRadius = UDim.new(0.25,0)
	UICorner_1.Parent = Open_Base_Frame
end
local Frame1 = Instance.new("Frame") do
	Frame1.Name = "Frame1"
	Frame1.AnchorPoint = Vector2.yAxis
	Frame1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1.BorderColor3 = Color3.new(0,0,0)
	Frame1.BorderSizePixel = 0
	Frame1.Position = UDim2.new(0,0,1,0)
	Frame1.Size = UDim2.new(0.25,0,1,0)
	Frame1.ZIndex = 11
	Frame1.Parent = Open_Base_Frame
end
local Frame2 = Instance.new("Frame") do
	Frame2.Name = "Frame2"
	Frame2.Active = true
	Frame2.AnchorPoint = Vector2.yAxis
	Frame2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2.BorderColor3 = Color3.new(0,0,0)
	Frame2.BorderSizePixel = 0
	Frame2.Position = UDim2.new(0,0,1,0)
	Frame2.Selectable = true
	Frame2.Size = UDim2.new(1,0,0.75,0)
	Frame2.ZIndex = 10
	Frame2.Parent = Open_Base_Frame
end
local Button = Instance.new("TextButton") do
	Button.Name = "Button"
	Button.AnchorPoint = Vector2.new(0.5,0.5)
	Button.BackgroundColor3 = Color3.new(1,1,1)
	Button.BackgroundTransparency = 1
	Button.BorderColor3 = Color3.new(0,0,0)
	Button.BorderSizePixel = 0
	Button.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Button.Position = UDim2.new(0.5,0,0.5,0)
	Button.Size = UDim2.new(1,0,1,0)
	Button.Text = "Property Configs"
	Button.TextColor3 = Color3.new(1,1,1)
	Button.TextScaled = true
	Button.TextSize = 14
	Button.TextWrapped = true
	Button.ZIndex = 11
	Button.Parent = Open_Base_Frame
end
local Credit = Instance.new("TextLabel") do
	Credit.Name = "Credit"
	Credit.AnchorPoint = Vector2.one
	Credit.BackgroundColor3 = Color3.new(1,1,1)
	Credit.BackgroundTransparency = 1
	Credit.BorderColor3 = Color3.new(0,0,0)
	Credit.BorderSizePixel = 0
	Credit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Credit.Position = UDim2.new(0.9,0,1,0)
	Credit.Size = UDim2.new(0.1,0,0.1,0)
	Credit.Text = "by @Yarik_superpro"
	Credit.TextColor3 = Color3.new(1,1,1)
	Credit.TextSize = 10
	Credit.TextXAlignment = Enum.TextXAlignment.Right
	Credit.TextYAlignment = Enum.TextYAlignment.Bottom
	Credit.ZIndex = 11
	Credit.Parent = LowerBar
end
local Ignored_Properties = Instance.new("Frame") do
	Ignored_Properties.Name = "Ignored_Properties"
	Ignored_Properties.Active = true
	Ignored_Properties.AnchorPoint = Vector2.one
	Ignored_Properties.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Ignored_Properties.BorderColor3 = Color3.new(0,0,0)
	Ignored_Properties.BorderSizePixel = 0
	Ignored_Properties.Position = UDim2.new(1,0,1,0)
	Ignored_Properties.Selectable = true
	Ignored_Properties.Size = UDim2.new(0.1,0,0.5,0)
	Ignored_Properties.ZIndex = 10
	Ignored_Properties.Parent = LowerBar
end

local UICorner_2 = Instance.new("UICorner") do
	UICorner_2.CornerRadius = UDim.new(0.25,0)
	UICorner_2.Parent = Ignored_Properties
end
local Frame1_1 = Instance.new("Frame") do
	Frame1_1.Name = "Frame1"
	Frame1_1.Active = true
	Frame1_1.AnchorPoint = Vector2.yAxis
	Frame1_1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_1.BorderColor3 = Color3.new(0,0,0)
	Frame1_1.BorderSizePixel = 0
	Frame1_1.Position = UDim2.new(0,0,1,0)
	Frame1_1.Selectable = true
	Frame1_1.Size = UDim2.new(1,0,0.75,0)
	Frame1_1.ZIndex = 11
	Frame1_1.Parent = Ignored_Properties
end
local Button_1 = Instance.new("TextButton") do
	Button_1.Name = "Button"
	Button_1.AnchorPoint = Vector2.new(0.5,0.5)
	Button_1.BackgroundColor3 = Color3.new(1,1,1)
	Button_1.BackgroundTransparency = 1
	Button_1.BorderColor3 = Color3.new(0,0,0)
	Button_1.BorderSizePixel = 0
	Button_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Button_1.Position = UDim2.new(0.5,0,0.5,0)
	Button_1.Size = UDim2.new(1,0,1,0)
	Button_1.Text = "Ignore Properties"
	Button_1.TextColor3 = Color3.new(1,1,1)
	Button_1.TextScaled = true
	Button_1.TextSize = 14
	Button_1.TextWrapped = true
	Button_1.ZIndex = 11
	Button_1.Parent = Ignored_Properties
end
local Frame2_1 = Instance.new("Frame") do
	Frame2_1.Name = "Frame2"
	Frame2_1.AnchorPoint = Vector2.yAxis
	Frame2_1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_1.BorderColor3 = Color3.new(0,0,0)
	Frame2_1.BorderSizePixel = 0
	Frame2_1.Position = UDim2.new(0.75,0,1,0)
	Frame2_1.Size = UDim2.new(0.25,0,1,0)
	Frame2_1.ZIndex = 10
	Frame2_1.Parent = Ignored_Properties
end
local Search = Instance.new("TextButton") do
	Search.Name = "Search"
	Search.AnchorPoint = Vector2.one
	Search.BackgroundColor3 = Color3.new(0.153,0.153,0.153)
	Search.BorderColor3 = Color3.new(0,0,0)
	Search.BorderSizePixel = 0
	Search.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Search.Position = UDim2.new(1,0,0.45,0)
	Search.Size = UDim2.new(0.1,0,0.4,0)
	Search.Text = "🔍"
	Search.TextColor3 = Color3.new(1,1,1)
	Search.TextScaled = true
	Search.TextSize = 14
	Search.TextWrapped = true
	Search.ZIndex = 11
	Search.Parent = LowerBar
end

local UICorner_3 = Instance.new("UICorner") do
	UICorner_3.CornerRadius = UDim.new(0.3,0)
	UICorner_3.Parent = Search
end
local Cancel = Instance.new("TextButton") do
	Cancel.Name = "Cancel"
	Cancel.AnchorPoint = Vector2.new(1,0.5)
	Cancel.BackgroundColor3 = Color3.new(1,1,1)
	Cancel.BorderColor3 = Color3.new(0,0,0)
	Cancel.BorderSizePixel = 0
	Cancel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Heavy,Enum.FontStyle.Normal)
	Cancel.Position = UDim2.new(0,0,0.5,0)
	Cancel.Size = UDim2.new(1,0,1,0)
	Cancel.Text = "X"
	Cancel.TextColor3 = Color3.new(1,0,0)
	Cancel.TextScaled = true
	Cancel.TextSize = 14
	Cancel.TextWrapped = true
	Cancel.Visible = false
	Cancel.ZIndex = 11
	Cancel.Parent = Search
end

local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint",Cancel)
local UICorner_4 = Instance.new("UICorner") do
	UICorner_4.CornerRadius = UDim.new(0.3,0)
	UICorner_4.Parent = Cancel
end
local Hint = Instance.new("Frame") do
	Hint.Name = "Hint"
	Hint.BackgroundColor3 = Color3.new(1,1,1)
	Hint.BorderColor3 = Color3.new(0,0,0)
	Hint.BorderSizePixel = 0
	Hint.Size = UDim2.new(0,100,0,16)
	Hint.Visible = false
	Hint.ZIndex = 99_999
	Hint.Parent = Main
end

local Label_1 = Instance.new("TextLabel") do
	Label_1.Name = "Label"
	Label_1.AnchorPoint = Vector2.new(0.5,0.5)
	Label_1.BackgroundColor3 = Color3.new(0,0,0)
	Label_1.BackgroundTransparency = 1
	Label_1.BorderColor3 = Color3.new(0,0,0)
	Label_1.BorderSizePixel = 0
	Label_1.Position = UDim2.new(0.5,0,0.5,0)
	Label_1.Size = UDim2.new(1,-6,1,-6)
	Label_1.TextColor3 = Color3.new(1,1,1)
	Label_1.TextWrapped = true
	Label_1.TextXAlignment = Enum.TextXAlignment.Left
	Label_1.TextYAlignment = Enum.TextYAlignment.Top
	Label_1.ZIndex = 99_999
	Label_1.Parent = Hint
end
local UIStroke = Instance.new("UIStroke",Hint)
local IgnoredProperties = Instance.new("Frame") do
	IgnoredProperties.Name = "IgnoredProperties"
	IgnoredProperties.AnchorPoint = Vector2.new(0.5,0.5)
	IgnoredProperties.BackgroundColor3 = Color3.new(0.424,0.424,0.424)
	IgnoredProperties.BorderColor3 = Color3.new(0,0,0)
	IgnoredProperties.BorderSizePixel = 0
	IgnoredProperties.Position = UDim2.new(0.5,0,0.5,0)
	IgnoredProperties.Size = UDim2.new(1,0,1,0)
	IgnoredProperties.Visible = false
	IgnoredProperties.ZIndex = 10
	IgnoredProperties.Parent = Main
end

local Exit = Instance.new("TextButton") do
	Exit.Name = "Exit"
	Exit.AutoButtonColor = false
	Exit.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit.BackgroundTransparency = 1
	Exit.BorderColor3 = Color3.new(0,0,0)
	Exit.BorderSizePixel = 0
	Exit.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Exit.Position = UDim2.new(0.5,0,0,0)
	Exit.Size = UDim2.new(0.5,0,0.1,0)
	Exit.Text = "Back"
	Exit.TextColor3 = Color3.new(1,1,1)
	Exit.TextScaled = true
	Exit.TextSize = 14
	Exit.TextWrapped = true
	Exit.ZIndex = 15
	Exit.Parent = IgnoredProperties
end

local Frame = Instance.new("Frame") do
	Frame.AnchorPoint = Vector2.new(0.5,0.5)
	Frame.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame.BorderColor3 = Color3.new(0,0,0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.5,0,0.5,0)
	Frame.Size = UDim2.new(1,0,1,0)
	Frame.ZIndex = 12
	Frame.Parent = Exit
end

local UICorner_5 = Instance.new("UICorner") do
	UICorner_5.CornerRadius = UDim.new(0.5,0)
	UICorner_5.Parent = Frame
end
local Frame1_2 = Instance.new("Frame") do
	Frame1_2.Name = "Frame1"
	Frame1_2.AnchorPoint = Vector2.xAxis
	Frame1_2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_2.BorderColor3 = Color3.new(0,0,0)
	Frame1_2.BorderSizePixel = 0
	Frame1_2.Position = UDim2.new(1,0,0,0)
	Frame1_2.Size = UDim2.new(1,0,0.5,0)
	Frame1_2.ZIndex = 13
	Frame1_2.Parent = Exit
end
local Frame2_2 = Instance.new("Frame") do
	Frame2_2.Name = "Frame2"
	Frame2_2.AnchorPoint = Vector2.xAxis
	Frame2_2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_2.BorderColor3 = Color3.new(0,0,0)
	Frame2_2.BorderSizePixel = 0
	Frame2_2.Position = UDim2.new(1,0,0,0)
	Frame2_2.Size = UDim2.new(0.5,0,1,0)
	Frame2_2.ZIndex = 13
	Frame2_2.Parent = Exit
end
local Import = Instance.new("TextButton") do
	Import.Name = "Import"
	Import.AnchorPoint = Vector2.xAxis
	Import.AutoButtonColor = false
	Import.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Import.BackgroundTransparency = 1
	Import.BorderColor3 = Color3.new(0,0,0)
	Import.BorderSizePixel = 0
	Import.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Import.Position = UDim2.new(0.5,0,0,0)
	Import.Size = UDim2.new(0.5,0,0.1,0)
	Import.Text = "Import"
	Import.TextColor3 = Color3.new(1,1,1)
	Import.TextScaled = true
	Import.TextSize = 14
	Import.TextWrapped = true
	Import.ZIndex = 15
	Import.Parent = IgnoredProperties
end

local Frame_1 = Instance.new("Frame") do
	Frame_1.AnchorPoint = Vector2.new(0.5,0.5)
	Frame_1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame_1.BorderColor3 = Color3.new(0,0,0)
	Frame_1.BorderSizePixel = 0
	Frame_1.Position = UDim2.new(0.5,0,0.5,0)
	Frame_1.Size = UDim2.new(1,0,1,0)
	Frame_1.ZIndex = 12
	Frame_1.Parent = Import
end

local UICorner_6 = Instance.new("UICorner") do
	UICorner_6.CornerRadius = UDim.new(0.5,0)
	UICorner_6.Parent = Frame_1
end
local Frame1_3 = Instance.new("Frame") do
	Frame1_3.Name = "Frame1"
	Frame1_3.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_3.BorderColor3 = Color3.new(0,0,0)
	Frame1_3.BorderSizePixel = 0
	Frame1_3.Size = UDim2.new(1,0,0.5,0)
	Frame1_3.ZIndex = 13
	Frame1_3.Parent = Import
end
local Frame2_3 = Instance.new("Frame") do
	Frame2_3.Name = "Frame2"
	Frame2_3.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_3.BorderColor3 = Color3.new(0,0,0)
	Frame2_3.BorderSizePixel = 0
	Frame2_3.Size = UDim2.new(0.5,0,1,0)
	Frame2_3.ZIndex = 13
	Frame2_3.Parent = Import
end
local Content = Instance.new("ScrollingFrame") do
	Content.Name = "Content"
	Content.Active = true
	Content.AnchorPoint = Vector2.new(0.5,0)
	Content.BackgroundColor3 = Color3.new(1,1,1)
	Content.BackgroundTransparency = 0.25
	Content.BorderColor3 = Color3.new(0,0,0)
	Content.BorderSizePixel = 0
	Content.Position = UDim2.new(0.5,0,0.1,0)
	Content.ScrollBarImageColor3 = Color3.new(0,0,0)
	Content.Size = UDim2.new(1,0,0.8,0)
	Content.ZIndex = 11
	Content.Parent = IgnoredProperties
end

local TextBox = Instance.new("TextBox") do
	TextBox.BackgroundColor3 = Color3.new(1,1,1)
	TextBox.BackgroundTransparency = 1
	TextBox.BorderColor3 = Color3.new(0,0,0)
	TextBox.BorderSizePixel = 0
	TextBox.ClearTextOnFocus = false
	TextBox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	TextBox.MultiLine = true
	TextBox.Size = UDim2.new(1,0,1,0)
	TextBox.Text = ""
	TextBox.TextColor3 = Color3.new(0,0,0)
	TextBox.TextSize = 14
	TextBox.TextTransparency = 0.99
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.TextYAlignment = Enum.TextYAlignment.Top
	TextBox.ZIndex = 12
	TextBox.Parent = Content
end

local Rich = Instance.new("TextLabel") do
	Rich.Name = "Rich"
	Rich.Active = true
	Rich.BackgroundColor3 = Color3.new(1,1,1)
	Rich.BackgroundTransparency = 1
	Rich.BorderColor3 = Color3.new(0,0,0)
	Rich.BorderSizePixel = 0
	Rich.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Rich.RichText = true
	Rich.Selectable = true
	Rich.Size = UDim2.new(1,0,1,0)
	Rich.Text = ""
	Rich.TextColor3 = Color3.new(0,0,0)
	Rich.TextSize = 14
	Rich.TextXAlignment = Enum.TextXAlignment.Left
	Rich.TextYAlignment = Enum.TextYAlignment.Top
	Rich.ZIndex = 11
	Rich.Parent = TextBox
end
local Import_Base = Instance.new("Frame") do
	Import_Base.Name = "Import_Base"
	Import_Base.BackgroundColor3 = Color3.new(0.31,0.31,0.31)
	Import_Base.BorderColor3 = Color3.new(0,0,0)
	Import_Base.BorderSizePixel = 0
	Import_Base.Size = UDim2.new(1,0,1,0)
	Import_Base.Visible = false
	Import_Base.ZIndex = 999
	Import_Base.Parent = Main
end

local Exit_Frame = Instance.new("Frame") do
	Exit_Frame.Name = "Exit_Frame"
	Exit_Frame.AnchorPoint = Vector2.xAxis
	Exit_Frame.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit_Frame.BorderColor3 = Color3.new(0,0,0)
	Exit_Frame.BorderSizePixel = 0
	Exit_Frame.Position = UDim2.new(1,0,0,0)
	Exit_Frame.Size = UDim2.new(0.1,0,0.1,0)
	Exit_Frame.ZIndex = 1_005
	Exit_Frame.Parent = Import_Base
end

local UICorner_7 = Instance.new("UICorner") do
	UICorner_7.CornerRadius = UDim.new(0.25,0)
	UICorner_7.Parent = Exit_Frame
end
local Frame1_4 = Instance.new("Frame") do
	Frame1_4.Name = "Frame1"
	Frame1_4.AnchorPoint = Vector2.xAxis
	Frame1_4.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_4.BorderColor3 = Color3.new(0,0,0)
	Frame1_4.BorderSizePixel = 0
	Frame1_4.Position = UDim2.new(1,0,0,0)
	Frame1_4.Size = UDim2.new(0.25,0,1,0)
	Frame1_4.ZIndex = 1_005
	Frame1_4.Parent = Exit_Frame
end
local Frame2_4 = Instance.new("Frame") do
	Frame2_4.Name = "Frame2"
	Frame2_4.AnchorPoint = Vector2.xAxis
	Frame2_4.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_4.BorderColor3 = Color3.new(0,0,0)
	Frame2_4.BorderSizePixel = 0
	Frame2_4.Position = UDim2.new(1,0,0,0)
	Frame2_4.Size = UDim2.new(1,0,0.75,0)
	Frame2_4.ZIndex = 1_005
	Frame2_4.Parent = Exit_Frame
end
local Exit_1 = Instance.new("TextButton") do
	Exit_1.Name = "Exit"
	Exit_1.AnchorPoint = Vector2.new(0.5,0.5)
	Exit_1.AutoButtonColor = false
	Exit_1.BackgroundColor3 = Color3.new(1,1,1)
	Exit_1.BackgroundTransparency = 1
	Exit_1.BorderColor3 = Color3.new(0,0,0)
	Exit_1.BorderSizePixel = 0
	Exit_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Exit_1.Position = UDim2.new(0.5,0,0.5,0)
	Exit_1.Size = UDim2.new(1,0,1,0)
	Exit_1.Text = "X"
	Exit_1.TextColor3 = Color3.new(1,1,1)
	Exit_1.TextScaled = true
	Exit_1.TextSize = 14
	Exit_1.TextWrapped = true
	Exit_1.ZIndex = 1_006
	Exit_1.Parent = Exit_Frame
end
local Exit_Back = Instance.new("Frame") do
	Exit_Back.Name = "Exit_Back"
	Exit_Back.Active = true
	Exit_Back.AnchorPoint = Vector2.yAxis
	Exit_Back.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit_Back.BorderColor3 = Color3.new(0,0,0)
	Exit_Back.BorderSizePixel = 0
	Exit_Back.Position = UDim2.new(0,0,1,0)
	Exit_Back.Selectable = true
	Exit_Back.Size = UDim2.new(0.05,0,0.05,0)
	Exit_Back.ZIndex = 1_001
	Exit_Back.Parent = Import_Base
end

local UICorner_8 = Instance.new("UICorner") do
	UICorner_8.CornerRadius = UDim.new(0.25,0)
	UICorner_8.Parent = Exit_Back
end
local Frame1_5 = Instance.new("Frame") do
	Frame1_5.Name = "Frame1"
	Frame1_5.AnchorPoint = Vector2.yAxis
	Frame1_5.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_5.BorderColor3 = Color3.new(0,0,0)
	Frame1_5.BorderSizePixel = 0
	Frame1_5.Position = UDim2.new(0,0,1,0)
	Frame1_5.Size = UDim2.new(0.25,0,1,0)
	Frame1_5.ZIndex = 1_001
	Frame1_5.Parent = Exit_Back
end
local Frame2_5 = Instance.new("Frame") do
	Frame2_5.Name = "Frame2"
	Frame2_5.Active = true
	Frame2_5.AnchorPoint = Vector2.yAxis
	Frame2_5.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_5.BorderColor3 = Color3.new(0,0,0)
	Frame2_5.BorderSizePixel = 0
	Frame2_5.Position = UDim2.new(0,0,1,0)
	Frame2_5.Selectable = true
	Frame2_5.Size = UDim2.new(1,0,0.75,0)
	Frame2_5.ZIndex = 1_001
	Frame2_5.Parent = Exit_Back
end
local Button_2 = Instance.new("TextButton") do
	Button_2.Name = "Button"
	Button_2.AnchorPoint = Vector2.new(0.5,0.5)
	Button_2.BackgroundColor3 = Color3.new(1,1,1)
	Button_2.BackgroundTransparency = 1
	Button_2.BorderColor3 = Color3.new(0,0,0)
	Button_2.BorderSizePixel = 0
	Button_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Button_2.Position = UDim2.new(0.5,0,0.5,0)
	Button_2.Size = UDim2.new(1,0,1,0)
	Button_2.Text = "Back"
	Button_2.TextColor3 = Color3.new(1,1,1)
	Button_2.TextScaled = true
	Button_2.TextSize = 14
	Button_2.TextWrapped = true
	Button_2.ZIndex = 1_002
	Button_2.Parent = Exit_Back
end
local _base = Instance.new("Frame") do
	_base.Name = "_base"
	_base.BackgroundColor3 = Color3.new(0.247,0.247,0.247)
	_base.BorderColor3 = Color3.new(0,0,0)
	_base.BorderSizePixel = 0
	_base.Position = UDim2.new(0.055,0,0.241,0)
	_base.Size = UDim2.new(0.94,0,0.759,0)
	_base.ZIndex = 999
	_base.Parent = Import_Base
end

local Imported_Scroll = Instance.new("ScrollingFrame") do
	Imported_Scroll.Name = "Imported_Scroll"
	Imported_Scroll.AnchorPoint = Vector2.new(1,0.5)
	Imported_Scroll.BackgroundColor3 = Color3.new(0,0,0)
	Imported_Scroll.BackgroundTransparency = 0.9
	Imported_Scroll.BorderColor3 = Color3.new(0,0,0)
	Imported_Scroll.BorderSizePixel = 0
	Imported_Scroll.Position = UDim2.new(0.975,0,0.55,0)
	Imported_Scroll.Selectable = false
	Imported_Scroll.Size = UDim2.new(0.45,0,0.719,0)
	Imported_Scroll.ZIndex = 1_001
	Imported_Scroll.Parent = _base
end

local Imported = Instance.new("TextBox") do
	Imported.Name = "Imported"
	Imported.Active = false
	Imported.BackgroundColor3 = Color3.new(0,0,0)
	Imported.BackgroundTransparency = 1
	Imported.BorderColor3 = Color3.new(0,0,0)
	Imported.BorderSizePixel = 0
	Imported.ClearTextOnFocus = false
	Imported.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Imported.MultiLine = true
	Imported.Selectable = false
	Imported.Size = UDim2.new(1,0,1,0)
	Imported.Text = ""
	Imported.TextColor3 = Color3.new(1,1,1)
	Imported.TextEditable = false
	Imported.TextSize = 14
	Imported.TextStrokeColor3 = Color3.new(1,1,1)
	Imported.TextTransparency = 0.99
	Imported.TextXAlignment = Enum.TextXAlignment.Left
	Imported.TextYAlignment = Enum.TextYAlignment.Top
	Imported.ZIndex = 1_001
	Imported.Parent = Imported_Scroll
end

local Rich_1 = Instance.new("TextLabel") do
	Rich_1.Name = "Rich"
	Rich_1.BackgroundColor3 = Color3.new(0,0,0)
	Rich_1.BackgroundTransparency = 1
	Rich_1.BorderColor3 = Color3.new(0,0,0)
	Rich_1.BorderSizePixel = 0
	Rich_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Rich_1.RichText = true
	Rich_1.Size = UDim2.new(1,0,1,0)
	Rich_1.Text = "0x_deadbeef"
	Rich_1.TextColor3 = Color3.new(1,1,1)
	Rich_1.TextSize = 14
	Rich_1.TextStrokeColor3 = Color3.new(1,1,1)
	Rich_1.TextXAlignment = Enum.TextXAlignment.Left
	Rich_1.TextYAlignment = Enum.TextYAlignment.Top
	Rich_1.ZIndex = 1_000
	Rich_1.Parent = Imported
end
local UICorner_9 = Instance.new("UICorner") do
	UICorner_9.CornerRadius = UDim.new(0.025,0)
	UICorner_9.Parent = Imported_Scroll
end
local UIStroke_1 = Instance.new("UIStroke") do
	UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_1.Parent = Imported_Scroll
end
local Insert_Scroll = Instance.new("ScrollingFrame") do
	Insert_Scroll.Name = "Insert_Scroll"
	Insert_Scroll.Active = true
	Insert_Scroll.AnchorPoint = Vector2.new(0,0.5)
	Insert_Scroll.BackgroundColor3 = Color3.new(1,1,1)
	Insert_Scroll.BorderColor3 = Color3.new(0,0,0)
	Insert_Scroll.BorderSizePixel = 0
	Insert_Scroll.Position = UDim2.new(0.025,0,0.55,0)
	Insert_Scroll.Size = UDim2.new(0.45,0,0.719,0)
	Insert_Scroll.ZIndex = 1_000
	Insert_Scroll.Parent = _base
end

local UICorner_10 = Instance.new("UICorner") do
	UICorner_10.CornerRadius = UDim.new(0.025,0)
	UICorner_10.Parent = Insert_Scroll
end
local Insert = Instance.new("TextBox") do
	Insert.Name = "Insert"
	Insert.BackgroundColor3 = Color3.new(1,1,1)
	Insert.BackgroundTransparency = 1
	Insert.BorderColor3 = Color3.new(0,0,0)
	Insert.BorderSizePixel = 0
	Insert.ClearTextOnFocus = false
	Insert.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Insert.MultiLine = true
	Insert.PlaceholderText = "Insert code here"
	Insert.Size = UDim2.new(1,0,1,0)
	Insert.Text = ""
	Insert.TextColor3 = Color3.new(1,1,1)
	Insert.TextSize = 14
	Insert.TextStrokeColor3 = Color3.new(1,1,1)
	Insert.TextXAlignment = Enum.TextXAlignment.Left
	Insert.TextYAlignment = Enum.TextYAlignment.Top
	Insert.ZIndex = 1_000
	Insert.Parent = Insert_Scroll
end
local UIStroke_2 = Instance.new("UIStroke") do
	UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_2.Parent = Insert_Scroll
end
local Import_1 = Instance.new("TextButton") do
	Import_1.Name = "Import"
	Import_1.AnchorPoint = Vector2.new(0.5,0.5)
	Import_1.AutoButtonColor = false
	Import_1.BackgroundColor3 = Color3.new(1,1,1)
	Import_1.BackgroundTransparency = 1
	Import_1.BorderColor3 = Color3.new(0,0,0)
	Import_1.BorderSizePixel = 0
	Import_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Import_1.Position = UDim2.new(0.5,0,0.55,0)
	Import_1.Size = UDim2.new(0.043,0,0.719,0)
	Import_1.Text = ""
	Import_1.TextColor3 = Color3.new(0,0,0)
	Import_1.TextSize = 14
	Import_1.TextTransparency = 1
	Import_1.ZIndex = 1_001
	Import_1.Parent = _base
end

local Label_2 = Instance.new("ImageLabel") do
	Label_2.Name = "Label"
	Label_2.AnchorPoint = Vector2.new(0.5,0.5)
	Label_2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Label_2.BorderColor3 = Color3.new(0,0,0)
	Label_2.BorderSizePixel = 0
	Label_2.Image = "rbxassetid://153287088"
	Label_2.Position = UDim2.new(0.5,0,0.5,0)
	Label_2.Size = UDim2.new(1,0,1,0)
	Label_2.ZIndex = 1_000
	Label_2.Parent = Import_1
end

local UICorner_11 = Instance.new("UICorner") do
	UICorner_11.CornerRadius = UDim.new(0.1,0)
	UICorner_11.Parent = Label_2
end
local TextLabel = Instance.new("TextLabel") do
	TextLabel.AnchorPoint = Vector2.yAxis
	TextLabel.BackgroundColor3 = Color3.new(1,1,1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderColor3 = Color3.new(0,0,0)
	TextLabel.BorderSizePixel = 0
	TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
	TextLabel.Position = UDim2.new(0,0,1,0)
	TextLabel.Size = UDim2.new(0.5,0,0.5,0)
	TextLabel.Text = "{}"
	TextLabel.TextColor3 = Color3.new(1,1,1)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14
	TextLabel.TextWrapped = true
	TextLabel.ZIndex = 1_000
	TextLabel.Parent = Label_2
end
local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint",Label_2)
local UICorner_12 = Instance.new("UICorner") do
	UICorner_12.CornerRadius = UDim.new(0.025,0)
	UICorner_12.Parent = _base
end
local Frame_2 = Instance.new("Frame") do
	Frame_2.AnchorPoint = Vector2.yAxis
	Frame_2.BackgroundColor3 = Color3.new(0.247,0.247,0.247)
	Frame_2.BorderColor3 = Color3.new(0,0,0)
	Frame_2.BorderSizePixel = 0
	Frame_2.Position = UDim2.new(0,0,1,0)
	Frame_2.Size = UDim2.new(1,0,0.025,0)
	Frame_2.ZIndex = 999
	Frame_2.Parent = _base
end
local Title = Instance.new("TextLabel") do
	Title.Name = "Title"
	Title.AnchorPoint = Vector2.new(0.5,0)
	Title.BackgroundColor3 = Color3.new(1,1,1)
	Title.BackgroundTransparency = 1
	Title.BorderColor3 = Color3.new(0,0,0)
	Title.BorderSizePixel = 0
	Title.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Title.Position = UDim2.new(0.5,0,0,0)
	Title.Size = UDim2.new(0.5,0,0.175,0)
	Title.Text = "_base"
	Title.TextColor3 = Color3.new(1,1,1)
	Title.TextScaled = true
	Title.TextSize = 14
	Title.TextWrapped = true
	Title.ZIndex = 999
	Title.Parent = _base
end
local Buttons = Instance.new("Frame") do
	Buttons.Name = "Buttons"
	Buttons.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Buttons.BorderColor3 = Color3.new(0,0,0)
	Buttons.BorderSizePixel = 0
	Buttons.Size = UDim2.new(0.29,0,0.074,0)
	Buttons.ZIndex = 999
	Buttons.Parent = Import_Base
end

local UICorner_13 = Instance.new("UICorner") do
	UICorner_13.CornerRadius = UDim.new(0.25,0)
	UICorner_13.Parent = Buttons
end
local Frame_3 = Instance.new("Frame") do
	Frame_3.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame_3.BorderColor3 = Color3.new(0,0,0)
	Frame_3.BorderSizePixel = 0
	Frame_3.Size = UDim2.new(0.5,0,1,0)
	Frame_3.ZIndex = 999
	Frame_3.Parent = Buttons
end
local Frame2_6 = Instance.new("Frame") do
	Frame2_6.Name = "Frame2"
	Frame2_6.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_6.BorderColor3 = Color3.new(0,0,0)
	Frame2_6.BorderSizePixel = 0
	Frame2_6.Size = UDim2.new(1,0,0.25,0)
	Frame2_6.ZIndex = 999
	Frame2_6.Parent = Buttons
end
local Buttons_1 = Instance.new("Frame") do
	Buttons_1.Name = "Buttons"
	Buttons_1.BackgroundColor3 = Color3.new(1,1,1)
	Buttons_1.BackgroundTransparency = 1
	Buttons_1.BorderColor3 = Color3.new(0,0,0)
	Buttons_1.BorderSizePixel = 0
	Buttons_1.Size = UDim2.new(1,0,1,0)
	Buttons_1.ZIndex = 999
	Buttons_1.Parent = Buttons
end

local UIListLayout_1 = Instance.new("UIListLayout") do
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.Parent = Buttons_1
end
local CachedConsts = Instance.new("TextButton") do
	CachedConsts.Name = "CachedConsts"
	CachedConsts.Active = false
	CachedConsts.AutoButtonColor = false
	CachedConsts.BackgroundColor3 = Color3.new(1,1,1)
	CachedConsts.BackgroundTransparency = 1
	CachedConsts.BorderColor3 = Color3.new(0,0,0)
	CachedConsts.BorderSizePixel = 0
	CachedConsts.Selectable = false
	CachedConsts.Size = UDim2.new(1,0,1,0)
	CachedConsts.Text = ""
	CachedConsts.TextColor3 = Color3.new(1,1,1)
	CachedConsts.TextTransparency = 1
	CachedConsts.TextWrapped = true
	CachedConsts.ZIndex = 1_002
	CachedConsts.Parent = Buttons_1
end

local UIFlexItem = Instance.new("UIFlexItem") do
	UIFlexItem.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem.Parent = CachedConsts
end
local TextLabel_1 = Instance.new("TextLabel") do
	TextLabel_1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	TextLabel_1.BorderColor3 = Color3.new(0,0,0)
	TextLabel_1.BorderSizePixel = 0
	TextLabel_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	TextLabel_1.Size = UDim2.new(1,0,1,0)
	TextLabel_1.Text = "Constants"
	TextLabel_1.TextColor3 = Color3.new(1,1,1)
	TextLabel_1.TextScaled = true
	TextLabel_1.TextSize = 14
	TextLabel_1.TextWrapped = true
	TextLabel_1.ZIndex = 1_001
	TextLabel_1.Parent = CachedConsts
end
local PathMacro = Instance.new("TextButton") do
	PathMacro.Name = "PathMacro"
	PathMacro.Active = false
	PathMacro.AutoButtonColor = false
	PathMacro.BackgroundColor3 = Color3.new(1,1,1)
	PathMacro.BackgroundTransparency = 1
	PathMacro.BorderColor3 = Color3.new(0,0,0)
	PathMacro.BorderSizePixel = 0
	PathMacro.LayoutOrder = 1
	PathMacro.Selectable = false
	PathMacro.Size = UDim2.new(1,0,1,0)
	PathMacro.Text = ""
	PathMacro.TextColor3 = Color3.new(1,1,1)
	PathMacro.TextTransparency = 1
	PathMacro.TextWrapped = true
	PathMacro.ZIndex = 1_002
	PathMacro.Parent = Buttons_1
end

local UIFlexItem_1 = Instance.new("UIFlexItem") do
	UIFlexItem_1.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem_1.Parent = PathMacro
end
local TextLabel_2 = Instance.new("TextLabel") do
	TextLabel_2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	TextLabel_2.BorderColor3 = Color3.new(0,0,0)
	TextLabel_2.BorderSizePixel = 0
	TextLabel_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	TextLabel_2.Size = UDim2.new(1,0,1,0)
	TextLabel_2.Text = "Path Macro"
	TextLabel_2.TextColor3 = Color3.new(1,1,1)
	TextLabel_2.TextScaled = true
	TextLabel_2.TextSize = 14
	TextLabel_2.TextWrapped = true
	TextLabel_2.ZIndex = 1_001
	TextLabel_2.Parent = PathMacro
end

local UICorner_14 = Instance.new("UICorner") do
	UICorner_14.CornerRadius = UDim.new(0.25,0)
	UICorner_14.Parent = TextLabel_2
end
local Frame_4 = Instance.new("Frame") do
	Frame_4.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame_4.BorderColor3 = Color3.new(0,0,0)
	Frame_4.BorderSizePixel = 0
	Frame_4.Size = UDim2.new(0.5,0,1,0)
	Frame_4.ZIndex = 1_000
	Frame_4.Parent = PathMacro
end
local Frame2_7 = Instance.new("Frame") do
	Frame2_7.Name = "Frame2"
	Frame2_7.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_7.BorderColor3 = Color3.new(0,0,0)
	Frame2_7.BorderSizePixel = 0
	Frame2_7.Size = UDim2.new(1,0,0.25,0)
	Frame2_7.ZIndex = 1_000
	Frame2_7.Parent = PathMacro
end
local Search_1 = Instance.new("TextBox") do
	Search_1.Name = "Search"
	Search_1.AnchorPoint = Vector2.new(0.5,0.5)
	Search_1.BackgroundColor3 = Color3.new(0.153,0.153,0.153)
	Search_1.BackgroundTransparency = 0.5
	Search_1.BorderColor3 = Color3.new(0,0,0)
	Search_1.BorderSizePixel = 0
	Search_1.ClearTextOnFocus = false
	Search_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Search_1.PlaceholderText = "Search🔍"
	Search_1.Position = UDim2.new(0.5,0,0.5,0)
	Search_1.Size = UDim2.new(0.8,0,0.2,0)
	Search_1.Text = ""
	Search_1.TextColor3 = Color3.new(1,1,1)
	Search_1.TextScaled = true
	Search_1.TextSize = 14
	Search_1.TextWrapped = true
	Search_1.Visible = false
	Search_1.ZIndex = 100_000
	Search_1.Parent = Main
end
local Import_Constants = Instance.new("Frame") do
	Import_Constants.Name = "Import_Constants"
	Import_Constants.BackgroundColor3 = Color3.new(0.31,0.31,0.31)
	Import_Constants.BorderColor3 = Color3.new(0,0,0)
	Import_Constants.BorderSizePixel = 0
	Import_Constants.Size = UDim2.new(1,0,1,0)
	Import_Constants.Visible = false
	Import_Constants.ZIndex = 999
	Import_Constants.Parent = Main
end

local Exit_Frame_1 = Instance.new("Frame") do
	Exit_Frame_1.Name = "Exit_Frame"
	Exit_Frame_1.AnchorPoint = Vector2.xAxis
	Exit_Frame_1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit_Frame_1.BorderColor3 = Color3.new(0,0,0)
	Exit_Frame_1.BorderSizePixel = 0
	Exit_Frame_1.Position = UDim2.new(1,0,0,0)
	Exit_Frame_1.Size = UDim2.new(0.1,0,0.1,0)
	Exit_Frame_1.ZIndex = 1_005
	Exit_Frame_1.Parent = Import_Constants
end

local UICorner_15 = Instance.new("UICorner") do
	UICorner_15.CornerRadius = UDim.new(0.25,0)
	UICorner_15.Parent = Exit_Frame_1
end
local Frame1_6 = Instance.new("Frame") do
	Frame1_6.Name = "Frame1"
	Frame1_6.AnchorPoint = Vector2.xAxis
	Frame1_6.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_6.BorderColor3 = Color3.new(0,0,0)
	Frame1_6.BorderSizePixel = 0
	Frame1_6.Position = UDim2.new(1,0,0,0)
	Frame1_6.Size = UDim2.new(0.25,0,1,0)
	Frame1_6.ZIndex = 1_005
	Frame1_6.Parent = Exit_Frame_1
end
local Frame2_8 = Instance.new("Frame") do
	Frame2_8.Name = "Frame2"
	Frame2_8.AnchorPoint = Vector2.xAxis
	Frame2_8.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_8.BorderColor3 = Color3.new(0,0,0)
	Frame2_8.BorderSizePixel = 0
	Frame2_8.Position = UDim2.new(1,0,0,0)
	Frame2_8.Size = UDim2.new(1,0,0.75,0)
	Frame2_8.ZIndex = 1_005
	Frame2_8.Parent = Exit_Frame_1
end
local Exit_2 = Instance.new("TextButton") do
	Exit_2.Name = "Exit"
	Exit_2.AnchorPoint = Vector2.new(0.5,0.5)
	Exit_2.AutoButtonColor = false
	Exit_2.BackgroundColor3 = Color3.new(1,1,1)
	Exit_2.BackgroundTransparency = 1
	Exit_2.BorderColor3 = Color3.new(0,0,0)
	Exit_2.BorderSizePixel = 0
	Exit_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Exit_2.Position = UDim2.new(0.5,0,0.5,0)
	Exit_2.Size = UDim2.new(1,0,1,0)
	Exit_2.Text = "X"
	Exit_2.TextColor3 = Color3.new(1,1,1)
	Exit_2.TextScaled = true
	Exit_2.TextSize = 14
	Exit_2.TextWrapped = true
	Exit_2.ZIndex = 1_006
	Exit_2.Parent = Exit_Frame_1
end
local Exit_Back_1 = Instance.new("Frame") do
	Exit_Back_1.Name = "Exit_Back"
	Exit_Back_1.Active = true
	Exit_Back_1.AnchorPoint = Vector2.yAxis
	Exit_Back_1.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit_Back_1.BorderColor3 = Color3.new(0,0,0)
	Exit_Back_1.BorderSizePixel = 0
	Exit_Back_1.Position = UDim2.new(0,0,1,0)
	Exit_Back_1.Selectable = true
	Exit_Back_1.Size = UDim2.new(0.05,0,0.05,0)
	Exit_Back_1.ZIndex = 1_001
	Exit_Back_1.Parent = Import_Constants
end

local UICorner_16 = Instance.new("UICorner") do
	UICorner_16.CornerRadius = UDim.new(0.25,0)
	UICorner_16.Parent = Exit_Back_1
end
local Frame1_7 = Instance.new("Frame") do
	Frame1_7.Name = "Frame1"
	Frame1_7.AnchorPoint = Vector2.yAxis
	Frame1_7.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_7.BorderColor3 = Color3.new(0,0,0)
	Frame1_7.BorderSizePixel = 0
	Frame1_7.Position = UDim2.new(0,0,1,0)
	Frame1_7.Size = UDim2.new(0.25,0,1,0)
	Frame1_7.ZIndex = 1_001
	Frame1_7.Parent = Exit_Back_1
end
local Frame2_9 = Instance.new("Frame") do
	Frame2_9.Name = "Frame2"
	Frame2_9.Active = true
	Frame2_9.AnchorPoint = Vector2.yAxis
	Frame2_9.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_9.BorderColor3 = Color3.new(0,0,0)
	Frame2_9.BorderSizePixel = 0
	Frame2_9.Position = UDim2.new(0,0,1,0)
	Frame2_9.Selectable = true
	Frame2_9.Size = UDim2.new(1,0,0.75,0)
	Frame2_9.ZIndex = 1_001
	Frame2_9.Parent = Exit_Back_1
end
local Button_3 = Instance.new("TextButton") do
	Button_3.Name = "Button"
	Button_3.AnchorPoint = Vector2.new(0.5,0.5)
	Button_3.BackgroundColor3 = Color3.new(1,1,1)
	Button_3.BackgroundTransparency = 1
	Button_3.BorderColor3 = Color3.new(0,0,0)
	Button_3.BorderSizePixel = 0
	Button_3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Button_3.Position = UDim2.new(0.5,0,0.5,0)
	Button_3.Size = UDim2.new(1,0,1,0)
	Button_3.Text = "Back"
	Button_3.TextColor3 = Color3.new(1,1,1)
	Button_3.TextScaled = true
	Button_3.TextSize = 14
	Button_3.TextWrapped = true
	Button_3.ZIndex = 1_002
	Button_3.Parent = Exit_Back_1
end
local Constants = Instance.new("Frame") do
	Constants.Name = "Constants"
	Constants.BackgroundColor3 = Color3.new(0.247,0.247,0.247)
	Constants.BorderColor3 = Color3.new(0,0,0)
	Constants.BorderSizePixel = 0
	Constants.Position = UDim2.new(0.055,0,0.241,0)
	Constants.Size = UDim2.new(0.94,0,0.759,0)
	Constants.ZIndex = 999
	Constants.Parent = Import_Constants
end

local Imported_Scroll_1 = Instance.new("ScrollingFrame") do
	Imported_Scroll_1.Name = "Imported_Scroll"
	Imported_Scroll_1.AnchorPoint = Vector2.new(1,0.5)
	Imported_Scroll_1.BackgroundColor3 = Color3.new(0,0,0)
	Imported_Scroll_1.BackgroundTransparency = 0.9
	Imported_Scroll_1.BorderColor3 = Color3.new(0,0,0)
	Imported_Scroll_1.BorderSizePixel = 0
	Imported_Scroll_1.Position = UDim2.new(0.975,0,0.55,0)
	Imported_Scroll_1.Selectable = false
	Imported_Scroll_1.Size = UDim2.new(0.45,0,0.719,0)
	Imported_Scroll_1.ZIndex = 1_001
	Imported_Scroll_1.Parent = Constants
end

local Imported_1 = Instance.new("TextBox") do
	Imported_1.Name = "Imported"
	Imported_1.Active = false
	Imported_1.BackgroundColor3 = Color3.new(0,0,0)
	Imported_1.BackgroundTransparency = 1
	Imported_1.BorderColor3 = Color3.new(0,0,0)
	Imported_1.BorderSizePixel = 0
	Imported_1.ClearTextOnFocus = false
	Imported_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Imported_1.MultiLine = true
	Imported_1.Selectable = false
	Imported_1.Size = UDim2.new(1,0,1,0)
	Imported_1.Text = ""
	Imported_1.TextColor3 = Color3.new(1,1,1)
	Imported_1.TextEditable = false
	Imported_1.TextSize = 14
	Imported_1.TextStrokeColor3 = Color3.new(1,1,1)
	Imported_1.TextTransparency = 0.99
	Imported_1.TextXAlignment = Enum.TextXAlignment.Left
	Imported_1.TextYAlignment = Enum.TextYAlignment.Top
	Imported_1.ZIndex = 1_001
	Imported_1.Parent = Imported_Scroll_1
end

local Rich_2 = Instance.new("TextLabel") do
	Rich_2.Name = "Rich"
	Rich_2.BackgroundColor3 = Color3.new(0,0,0)
	Rich_2.BackgroundTransparency = 1
	Rich_2.BorderColor3 = Color3.new(0,0,0)
	Rich_2.BorderSizePixel = 0
	Rich_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Rich_2.RichText = true
	Rich_2.Size = UDim2.new(1,0,1,0)
	Rich_2.Text = "0x_deadbeef"
	Rich_2.TextColor3 = Color3.new(1,1,1)
	Rich_2.TextSize = 14
	Rich_2.TextStrokeColor3 = Color3.new(1,1,1)
	Rich_2.TextXAlignment = Enum.TextXAlignment.Left
	Rich_2.TextYAlignment = Enum.TextYAlignment.Top
	Rich_2.ZIndex = 1_000
	Rich_2.Parent = Imported_1
end
local UICorner_17 = Instance.new("UICorner") do
	UICorner_17.CornerRadius = UDim.new(0.025,0)
	UICorner_17.Parent = Imported_Scroll_1
end
local UIStroke_3 = Instance.new("UIStroke") do
	UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_3.Parent = Imported_Scroll_1
end
local Insert_Scroll_1 = Instance.new("ScrollingFrame") do
	Insert_Scroll_1.Name = "Insert_Scroll"
	Insert_Scroll_1.Active = true
	Insert_Scroll_1.AnchorPoint = Vector2.new(0,0.5)
	Insert_Scroll_1.BackgroundColor3 = Color3.new(1,1,1)
	Insert_Scroll_1.BorderColor3 = Color3.new(0,0,0)
	Insert_Scroll_1.BorderSizePixel = 0
	Insert_Scroll_1.Position = UDim2.new(0.025,0,0.55,0)
	Insert_Scroll_1.Size = UDim2.new(0.45,0,0.719,0)
	Insert_Scroll_1.ZIndex = 1_000
	Insert_Scroll_1.Parent = Constants
end

local UICorner_18 = Instance.new("UICorner") do
	UICorner_18.CornerRadius = UDim.new(0.025,0)
	UICorner_18.Parent = Insert_Scroll_1
end
local Insert_1 = Instance.new("TextBox") do
	Insert_1.Name = "Insert"
	Insert_1.BackgroundColor3 = Color3.new(1,1,1)
	Insert_1.BackgroundTransparency = 1
	Insert_1.BorderColor3 = Color3.new(0,0,0)
	Insert_1.BorderSizePixel = 0
	Insert_1.ClearTextOnFocus = false
	Insert_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Insert_1.MultiLine = true
	Insert_1.PlaceholderText = "Insert code here"
	Insert_1.Size = UDim2.new(1,0,1,0)
	Insert_1.Text = ""
	Insert_1.TextColor3 = Color3.new(1,1,1)
	Insert_1.TextSize = 14
	Insert_1.TextStrokeColor3 = Color3.new(1,1,1)
	Insert_1.TextXAlignment = Enum.TextXAlignment.Left
	Insert_1.TextYAlignment = Enum.TextYAlignment.Top
	Insert_1.ZIndex = 1_000
	Insert_1.Parent = Insert_Scroll_1
end
local UIStroke_4 = Instance.new("UIStroke") do
	UIStroke_4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_4.Parent = Insert_Scroll_1
end
local Import_2 = Instance.new("TextButton") do
	Import_2.Name = "Import"
	Import_2.AnchorPoint = Vector2.new(0.5,0.5)
	Import_2.AutoButtonColor = false
	Import_2.BackgroundColor3 = Color3.new(1,1,1)
	Import_2.BackgroundTransparency = 1
	Import_2.BorderColor3 = Color3.new(0,0,0)
	Import_2.BorderSizePixel = 0
	Import_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Import_2.Position = UDim2.new(0.5,0,0.55,0)
	Import_2.Size = UDim2.new(0.043,0,0.719,0)
	Import_2.Text = ""
	Import_2.TextColor3 = Color3.new(0,0,0)
	Import_2.TextSize = 14
	Import_2.TextTransparency = 1
	Import_2.ZIndex = 1_001
	Import_2.Parent = Constants
end

local Label_3 = Instance.new("ImageLabel") do
	Label_3.Name = "Label"
	Label_3.AnchorPoint = Vector2.new(0.5,0.5)
	Label_3.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Label_3.BorderColor3 = Color3.new(0,0,0)
	Label_3.BorderSizePixel = 0
	Label_3.Image = "rbxassetid://153287088"
	Label_3.Position = UDim2.new(0.5,0,0.5,0)
	Label_3.Size = UDim2.new(1,0,1,0)
	Label_3.ZIndex = 1_000
	Label_3.Parent = Import_2
end

local UICorner_19 = Instance.new("UICorner") do
	UICorner_19.CornerRadius = UDim.new(0.1,0)
	UICorner_19.Parent = Label_3
end
local TextLabel_3 = Instance.new("TextLabel") do
	TextLabel_3.AnchorPoint = Vector2.yAxis
	TextLabel_3.BackgroundColor3 = Color3.new(1,1,1)
	TextLabel_3.BackgroundTransparency = 1
	TextLabel_3.BorderColor3 = Color3.new(0,0,0)
	TextLabel_3.BorderSizePixel = 0
	TextLabel_3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
	TextLabel_3.Position = UDim2.new(0,0,1,0)
	TextLabel_3.Size = UDim2.new(0.5,0,0.5,0)
	TextLabel_3.Text = "{}"
	TextLabel_3.TextColor3 = Color3.new(1,1,1)
	TextLabel_3.TextScaled = true
	TextLabel_3.TextSize = 14
	TextLabel_3.TextWrapped = true
	TextLabel_3.ZIndex = 1_000
	TextLabel_3.Parent = Label_3
end
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint",Label_3)
local UICorner_20 = Instance.new("UICorner") do
	UICorner_20.CornerRadius = UDim.new(0.025,0)
	UICorner_20.Parent = Constants
end
local Frame_5 = Instance.new("Frame") do
	Frame_5.AnchorPoint = Vector2.yAxis
	Frame_5.BackgroundColor3 = Color3.new(0.247,0.247,0.247)
	Frame_5.BorderColor3 = Color3.new(0,0,0)
	Frame_5.BorderSizePixel = 0
	Frame_5.Position = UDim2.new(0,0,1,0)
	Frame_5.Size = UDim2.new(1,0,0.025,0)
	Frame_5.ZIndex = 999
	Frame_5.Parent = Constants
end
local Title_1 = Instance.new("TextLabel") do
	Title_1.Name = "Title"
	Title_1.AnchorPoint = Vector2.new(0.5,0)
	Title_1.BackgroundColor3 = Color3.new(1,1,1)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.new(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Title_1.Position = UDim2.new(0.5,0,0,0)
	Title_1.Size = UDim2.new(0.5,0,0.175,0)
	Title_1.Text = "Constants"
	Title_1.TextColor3 = Color3.new(1,1,1)
	Title_1.TextScaled = true
	Title_1.TextSize = 14
	Title_1.TextWrapped = true
	Title_1.ZIndex = 999
	Title_1.Parent = Constants
end
local Import_PathMacro = Instance.new("Frame") do
	Import_PathMacro.Name = "Import_PathMacro"
	Import_PathMacro.BackgroundColor3 = Color3.new(0.31,0.31,0.31)
	Import_PathMacro.BorderColor3 = Color3.new(0,0,0)
	Import_PathMacro.BorderSizePixel = 0
	Import_PathMacro.Size = UDim2.new(1,0,1,0)
	Import_PathMacro.Visible = false
	Import_PathMacro.ZIndex = 999
	Import_PathMacro.Parent = Main
end

local Exit_Frame_2 = Instance.new("Frame") do
	Exit_Frame_2.Name = "Exit_Frame"
	Exit_Frame_2.AnchorPoint = Vector2.xAxis
	Exit_Frame_2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit_Frame_2.BorderColor3 = Color3.new(0,0,0)
	Exit_Frame_2.BorderSizePixel = 0
	Exit_Frame_2.Position = UDim2.new(1,0,0,0)
	Exit_Frame_2.Size = UDim2.new(0.1,0,0.1,0)
	Exit_Frame_2.ZIndex = 1_005
	Exit_Frame_2.Parent = Import_PathMacro
end

local UICorner_21 = Instance.new("UICorner") do
	UICorner_21.CornerRadius = UDim.new(0.25,0)
	UICorner_21.Parent = Exit_Frame_2
end
local Frame1_8 = Instance.new("Frame") do
	Frame1_8.Name = "Frame1"
	Frame1_8.AnchorPoint = Vector2.xAxis
	Frame1_8.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_8.BorderColor3 = Color3.new(0,0,0)
	Frame1_8.BorderSizePixel = 0
	Frame1_8.Position = UDim2.new(1,0,0,0)
	Frame1_8.Size = UDim2.new(0.25,0,1,0)
	Frame1_8.ZIndex = 1_005
	Frame1_8.Parent = Exit_Frame_2
end
local Frame2_10 = Instance.new("Frame") do
	Frame2_10.Name = "Frame2"
	Frame2_10.AnchorPoint = Vector2.xAxis
	Frame2_10.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_10.BorderColor3 = Color3.new(0,0,0)
	Frame2_10.BorderSizePixel = 0
	Frame2_10.Position = UDim2.new(1,0,0,0)
	Frame2_10.Size = UDim2.new(1,0,0.75,0)
	Frame2_10.ZIndex = 1_005
	Frame2_10.Parent = Exit_Frame_2
end
local Exit_3 = Instance.new("TextButton") do
	Exit_3.Name = "Exit"
	Exit_3.AnchorPoint = Vector2.new(0.5,0.5)
	Exit_3.AutoButtonColor = false
	Exit_3.BackgroundColor3 = Color3.new(1,1,1)
	Exit_3.BackgroundTransparency = 1
	Exit_3.BorderColor3 = Color3.new(0,0,0)
	Exit_3.BorderSizePixel = 0
	Exit_3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Exit_3.Position = UDim2.new(0.5,0,0.5,0)
	Exit_3.Size = UDim2.new(1,0,1,0)
	Exit_3.Text = "X"
	Exit_3.TextColor3 = Color3.new(1,1,1)
	Exit_3.TextScaled = true
	Exit_3.TextSize = 14
	Exit_3.TextWrapped = true
	Exit_3.ZIndex = 1_006
	Exit_3.Parent = Exit_Frame_2
end
local Exit_Back_2 = Instance.new("Frame") do
	Exit_Back_2.Name = "Exit_Back"
	Exit_Back_2.Active = true
	Exit_Back_2.AnchorPoint = Vector2.yAxis
	Exit_Back_2.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Exit_Back_2.BorderColor3 = Color3.new(0,0,0)
	Exit_Back_2.BorderSizePixel = 0
	Exit_Back_2.Position = UDim2.new(0,0,1,0)
	Exit_Back_2.Selectable = true
	Exit_Back_2.Size = UDim2.new(0.05,0,0.05,0)
	Exit_Back_2.ZIndex = 1_001
	Exit_Back_2.Parent = Import_PathMacro
end

local UICorner_22 = Instance.new("UICorner") do
	UICorner_22.CornerRadius = UDim.new(0.25,0)
	UICorner_22.Parent = Exit_Back_2
end
local Frame1_9 = Instance.new("Frame") do
	Frame1_9.Name = "Frame1"
	Frame1_9.AnchorPoint = Vector2.yAxis
	Frame1_9.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame1_9.BorderColor3 = Color3.new(0,0,0)
	Frame1_9.BorderSizePixel = 0
	Frame1_9.Position = UDim2.new(0,0,1,0)
	Frame1_9.Size = UDim2.new(0.25,0,1,0)
	Frame1_9.ZIndex = 1_001
	Frame1_9.Parent = Exit_Back_2
end
local Frame2_11 = Instance.new("Frame") do
	Frame2_11.Name = "Frame2"
	Frame2_11.Active = true
	Frame2_11.AnchorPoint = Vector2.yAxis
	Frame2_11.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Frame2_11.BorderColor3 = Color3.new(0,0,0)
	Frame2_11.BorderSizePixel = 0
	Frame2_11.Position = UDim2.new(0,0,1,0)
	Frame2_11.Selectable = true
	Frame2_11.Size = UDim2.new(1,0,0.75,0)
	Frame2_11.ZIndex = 1_001
	Frame2_11.Parent = Exit_Back_2
end
local Button_4 = Instance.new("TextButton") do
	Button_4.Name = "Button"
	Button_4.AnchorPoint = Vector2.new(0.5,0.5)
	Button_4.BackgroundColor3 = Color3.new(1,1,1)
	Button_4.BackgroundTransparency = 1
	Button_4.BorderColor3 = Color3.new(0,0,0)
	Button_4.BorderSizePixel = 0
	Button_4.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Button_4.Position = UDim2.new(0.5,0,0.5,0)
	Button_4.Size = UDim2.new(1,0,1,0)
	Button_4.Text = "Back"
	Button_4.TextColor3 = Color3.new(1,1,1)
	Button_4.TextScaled = true
	Button_4.TextSize = 14
	Button_4.TextWrapped = true
	Button_4.ZIndex = 1_002
	Button_4.Parent = Exit_Back_2
end
local PathMacro_1 = Instance.new("Frame") do
	PathMacro_1.Name = "PathMacro"
	PathMacro_1.BackgroundColor3 = Color3.new(0.247,0.247,0.247)
	PathMacro_1.BorderColor3 = Color3.new(0,0,0)
	PathMacro_1.BorderSizePixel = 0
	PathMacro_1.Position = UDim2.new(0.055,0,0.241,0)
	PathMacro_1.Size = UDim2.new(0.94,0,0.759,0)
	PathMacro_1.ZIndex = 999
	PathMacro_1.Parent = Import_PathMacro
end

local Imported_Scroll_2 = Instance.new("ScrollingFrame") do
	Imported_Scroll_2.Name = "Imported_Scroll"
	Imported_Scroll_2.AnchorPoint = Vector2.new(1,0.5)
	Imported_Scroll_2.BackgroundColor3 = Color3.new(0,0,0)
	Imported_Scroll_2.BackgroundTransparency = 0.9
	Imported_Scroll_2.BorderColor3 = Color3.new(0,0,0)
	Imported_Scroll_2.BorderSizePixel = 0
	Imported_Scroll_2.Position = UDim2.new(0.975,0,0.55,0)
	Imported_Scroll_2.Selectable = false
	Imported_Scroll_2.Size = UDim2.new(0.45,0,0.719,0)
	Imported_Scroll_2.ZIndex = 1_001
	Imported_Scroll_2.Parent = PathMacro_1
end

local Imported_2 = Instance.new("TextBox") do
	Imported_2.Name = "Imported"
	Imported_2.Active = false
	Imported_2.BackgroundColor3 = Color3.new(0,0,0)
	Imported_2.BackgroundTransparency = 1
	Imported_2.BorderColor3 = Color3.new(0,0,0)
	Imported_2.BorderSizePixel = 0
	Imported_2.ClearTextOnFocus = false
	Imported_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Imported_2.MultiLine = true
	Imported_2.Selectable = false
	Imported_2.Size = UDim2.new(1,0,1,0)
	Imported_2.Text = ""
	Imported_2.TextColor3 = Color3.new(1,1,1)
	Imported_2.TextEditable = false
	Imported_2.TextSize = 14
	Imported_2.TextStrokeColor3 = Color3.new(1,1,1)
	Imported_2.TextTransparency = 0.99
	Imported_2.TextXAlignment = Enum.TextXAlignment.Left
	Imported_2.TextYAlignment = Enum.TextYAlignment.Top
	Imported_2.ZIndex = 1_001
	Imported_2.Parent = Imported_Scroll_2
end

local Rich_3 = Instance.new("TextLabel") do
	Rich_3.Name = "Rich"
	Rich_3.BackgroundColor3 = Color3.new(0,0,0)
	Rich_3.BackgroundTransparency = 1
	Rich_3.BorderColor3 = Color3.new(0,0,0)
	Rich_3.BorderSizePixel = 0
	Rich_3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Rich_3.RichText = true
	Rich_3.Size = UDim2.new(1,0,1,0)
	Rich_3.Text = "0x_deadbeef"
	Rich_3.TextColor3 = Color3.new(1,1,1)
	Rich_3.TextSize = 14
	Rich_3.TextStrokeColor3 = Color3.new(1,1,1)
	Rich_3.TextXAlignment = Enum.TextXAlignment.Left
	Rich_3.TextYAlignment = Enum.TextYAlignment.Top
	Rich_3.ZIndex = 1_000
	Rich_3.Parent = Imported_2
end
local UICorner_23 = Instance.new("UICorner") do
	UICorner_23.CornerRadius = UDim.new(0.025,0)
	UICorner_23.Parent = Imported_Scroll_2
end
local UIStroke_5 = Instance.new("UIStroke") do
	UIStroke_5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_5.Parent = Imported_Scroll_2
end
local Insert_Scroll_2 = Instance.new("ScrollingFrame") do
	Insert_Scroll_2.Name = "Insert_Scroll"
	Insert_Scroll_2.Active = true
	Insert_Scroll_2.AnchorPoint = Vector2.new(0,0.5)
	Insert_Scroll_2.BackgroundColor3 = Color3.new(1,1,1)
	Insert_Scroll_2.BorderColor3 = Color3.new(0,0,0)
	Insert_Scroll_2.BorderSizePixel = 0
	Insert_Scroll_2.Position = UDim2.new(0.025,0,0.55,0)
	Insert_Scroll_2.Size = UDim2.new(0.45,0,0.719,0)
	Insert_Scroll_2.ZIndex = 1_000
	Insert_Scroll_2.Parent = PathMacro_1
end

local UICorner_24 = Instance.new("UICorner") do
	UICorner_24.CornerRadius = UDim.new(0.025,0)
	UICorner_24.Parent = Insert_Scroll_2
end
local Insert_2 = Instance.new("TextBox") do
	Insert_2.Name = "Insert"
	Insert_2.BackgroundColor3 = Color3.new(1,1,1)
	Insert_2.BackgroundTransparency = 1
	Insert_2.BorderColor3 = Color3.new(0,0,0)
	Insert_2.BorderSizePixel = 0
	Insert_2.ClearTextOnFocus = false
	Insert_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Insert_2.MultiLine = true
	Insert_2.PlaceholderText = "Insert code here"
	Insert_2.Size = UDim2.new(1,0,1,0)
	Insert_2.Text = ""
	Insert_2.TextColor3 = Color3.new(1,1,1)
	Insert_2.TextSize = 14
	Insert_2.TextStrokeColor3 = Color3.new(1,1,1)
	Insert_2.TextXAlignment = Enum.TextXAlignment.Left
	Insert_2.TextYAlignment = Enum.TextYAlignment.Top
	Insert_2.ZIndex = 1_000
	Insert_2.Parent = Insert_Scroll_2
end
local UIStroke_6 = Instance.new("UIStroke") do
	UIStroke_6.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_6.Parent = Insert_Scroll_2
end
local Import_3 = Instance.new("TextButton") do
	Import_3.Name = "Import"
	Import_3.AnchorPoint = Vector2.new(0.5,0.5)
	Import_3.AutoButtonColor = false
	Import_3.BackgroundColor3 = Color3.new(1,1,1)
	Import_3.BackgroundTransparency = 1
	Import_3.BorderColor3 = Color3.new(0,0,0)
	Import_3.BorderSizePixel = 0
	Import_3.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Import_3.Position = UDim2.new(0.5,0,0.55,0)
	Import_3.Size = UDim2.new(0.043,0,0.719,0)
	Import_3.Text = ""
	Import_3.TextColor3 = Color3.new(0,0,0)
	Import_3.TextSize = 14
	Import_3.TextTransparency = 1
	Import_3.ZIndex = 1_001
	Import_3.Parent = PathMacro_1
end

local Label_4 = Instance.new("ImageLabel") do
	Label_4.Name = "Label"
	Label_4.AnchorPoint = Vector2.new(0.5,0.5)
	Label_4.BackgroundColor3 = Color3.new(0.2,0.373,1)
	Label_4.BorderColor3 = Color3.new(0,0,0)
	Label_4.BorderSizePixel = 0
	Label_4.Image = "rbxassetid://153287088"
	Label_4.Position = UDim2.new(0.5,0,0.5,0)
	Label_4.Size = UDim2.new(1,0,1,0)
	Label_4.ZIndex = 1_000
	Label_4.Parent = Import_3
end

local UICorner_25 = Instance.new("UICorner") do
	UICorner_25.CornerRadius = UDim.new(0.1,0)
	UICorner_25.Parent = Label_4
end
local TextLabel_4 = Instance.new("TextLabel") do
	TextLabel_4.AnchorPoint = Vector2.yAxis
	TextLabel_4.BackgroundColor3 = Color3.new(1,1,1)
	TextLabel_4.BackgroundTransparency = 1
	TextLabel_4.BorderColor3 = Color3.new(0,0,0)
	TextLabel_4.BorderSizePixel = 0
	TextLabel_4.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
	TextLabel_4.Position = UDim2.new(0,0,1,0)
	TextLabel_4.Size = UDim2.new(0.5,0,0.5,0)
	TextLabel_4.Text = "{}"
	TextLabel_4.TextColor3 = Color3.new(1,1,1)
	TextLabel_4.TextScaled = true
	TextLabel_4.TextSize = 14
	TextLabel_4.TextWrapped = true
	TextLabel_4.ZIndex = 1_000
	TextLabel_4.Parent = Label_4
end
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint",Label_4)
local UICorner_26 = Instance.new("UICorner") do
	UICorner_26.CornerRadius = UDim.new(0.025,0)
	UICorner_26.Parent = PathMacro_1
end
local Frame_6 = Instance.new("Frame") do
	Frame_6.AnchorPoint = Vector2.yAxis
	Frame_6.BackgroundColor3 = Color3.new(0.247,0.247,0.247)
	Frame_6.BorderColor3 = Color3.new(0,0,0)
	Frame_6.BorderSizePixel = 0
	Frame_6.Position = UDim2.new(0,0,1,0)
	Frame_6.Size = UDim2.new(1,0,0.025,0)
	Frame_6.ZIndex = 999
	Frame_6.Parent = PathMacro_1
end
local Title_2 = Instance.new("TextLabel") do
	Title_2.Name = "Title"
	Title_2.AnchorPoint = Vector2.new(0.5,0)
	Title_2.BackgroundColor3 = Color3.new(1,1,1)
	Title_2.BackgroundTransparency = 1
	Title_2.BorderColor3 = Color3.new(0,0,0)
	Title_2.BorderSizePixel = 0
	Title_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Title_2.Position = UDim2.new(0.5,0,0,0)
	Title_2.Size = UDim2.new(0.5,0,0.175,0)
	Title_2.Text = "Path Macro"
	Title_2.TextColor3 = Color3.new(1,1,1)
	Title_2.TextScaled = true
	Title_2.TextSize = 14
	Title_2.TextWrapped = true
	Title_2.ZIndex = 999
	Title_2.Parent = PathMacro_1
end


local Components = Instance.new("Folder") do
	Components.Name = "Components"
end

local PropertiesBox = Instance.new("Frame") do
	PropertiesBox.Name = "PropertiesBox"
	PropertiesBox.BackgroundColor3 = Color3.new(0.153,0.153,0.153)
	PropertiesBox.BorderColor3 = Color3.new(0,0,0)
	PropertiesBox.BorderSizePixel = 0
	PropertiesBox.Size = UDim2.new(1,0,0,100)
	PropertiesBox.Visible = false
	PropertiesBox.ZIndex = 5
	PropertiesBox.Parent = Components
end

local UIStroke = Instance.new("UIStroke",PropertiesBox)
local Content = Instance.new("Frame") do
	Content.Name = "Content"
	Content.BackgroundColor3 = Color3.new(1,1,1)
	Content.BackgroundTransparency = 1
	Content.BorderColor3 = Color3.new(0,0,0)
	Content.BorderSizePixel = 0
	Content.Size = UDim2.new(1,0,1,0)
	Content.ZIndex = 5
	Content.Parent = PropertiesBox
end

local NestedProperties = Instance.new("Frame") do
	NestedProperties.Name = "NestedProperties"
	NestedProperties.BackgroundColor3 = Color3.new(1,1,1)
	NestedProperties.BorderColor3 = Color3.new(0,0,0)
	NestedProperties.BorderSizePixel = 0
	NestedProperties.Size = UDim2.new(1,0,1,0)
	NestedProperties.ZIndex = 5
	NestedProperties.Parent = Content
end

local UIListLayout = Instance.new("UIListLayout") do
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = NestedProperties
end
local TabButton = Instance.new("Frame") do
	TabButton.Name = "TabButton"
	TabButton.BackgroundColor3 = Color3.new(0.686,0.686,0.686)
	TabButton.BorderColor3 = Color3.new(0,0,0)
	TabButton.BorderSizePixel = 0
	TabButton.Size = UDim2.new(1,0,1,0)
	TabButton.ZIndex = 3
	TabButton.Parent = Components
end

local UIFlexItem = Instance.new("UIFlexItem") do
	UIFlexItem.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem.Parent = TabButton
end
local TextButton = Instance.new("TextButton") do
	TextButton.AnchorPoint = Vector2.new(0.5,0)
	TextButton.BackgroundColor3 = Color3.new(1,1,1)
	TextButton.BackgroundTransparency = 1
	TextButton.BorderColor3 = Color3.new(0,0,0)
	TextButton.BorderSizePixel = 0
	TextButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	TextButton.LayoutOrder = 1
	TextButton.Size = UDim2.new(1,0,1,0)
	TextButton.TextColor3 = Color3.new(0,0,0)
	TextButton.TextScaled = true
	TextButton.TextSize = 14
	TextButton.TextWrapped = true
	TextButton.ZIndex = 4
	TextButton.Parent = TabButton
end

local UIFlexItem_1 = Instance.new("UIFlexItem") do
	UIFlexItem_1.FlexMode = Enum.UIFlexMode.Custom
	UIFlexItem_1.ItemLineAlignment = Enum.ItemLineAlignment.Stretch
	UIFlexItem_1.ShrinkRatio = 4
	UIFlexItem_1.Parent = TextButton
end
local UIListLayout_1 = Instance.new("UIListLayout") do
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.Parent = TabButton
end
local ImageButton = Instance.new("ImageButton") do
	ImageButton.BackgroundColor3 = Color3.new(1,1,1)
	ImageButton.BackgroundTransparency = 1
	ImageButton.BorderColor3 = Color3.new(0,0,0)
	ImageButton.BorderSizePixel = 0
	ImageButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	ImageButton.Size = UDim2.new(1,0,1,0)
	ImageButton.ZIndex = 4
	ImageButton.Parent = TabButton
end

local UIFlexItem_2 = Instance.new("UIFlexItem") do
	UIFlexItem_2.FlexMode = Enum.UIFlexMode.Grow
	UIFlexItem_2.ItemLineAlignment = Enum.ItemLineAlignment.Stretch
	UIFlexItem_2.Parent = ImageButton
end
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint",ImageButton)
local Boolean = Instance.new("Frame") do
	Boolean.Name = "Boolean"
	Boolean.Active = true
	Boolean.AnchorPoint = Vector2.new(0,0.5)
	Boolean.BackgroundColor3 = Color3.new(1,1,1)
	Boolean.BackgroundTransparency = 1
	Boolean.BorderColor3 = Color3.new(0,0,0)
	Boolean.BorderSizePixel = 0
	Boolean.Position = UDim2.new(0.5,0,0.5,0)
	Boolean.Selectable = true
	Boolean.Size = UDim2.new(0.5,0,1,0)
	Boolean.ZIndex = 5
	Boolean.Parent = Components
end

local UIStroke_1 = Instance.new("UIStroke") do
	UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_1.Parent = Boolean
end
local Button = Instance.new("ImageButton") do
	Button.Name = "Button"
	Button.AnchorPoint = Vector2.new(0,0.5)
	Button.AutoButtonColor = false
	Button.BackgroundColor3 = Color3.new(0.18,0.18,0.18)
	Button.BorderColor3 = Color3.new(0,0,0)
	Button.BorderSizePixel = 0
	Button.Image = "http://www.roblox.com/asset/?id=80963663462977"
	Button.Position = UDim2.new(0,4,0.5,0)
	Button.Size = UDim2.new(0,16,0,16)
	Button.ZIndex = 6
	Button.Parent = Boolean
end

local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint",Button)
local Hitbox = Instance.new("TextButton") do
	Hitbox.Name = "Hitbox"
	Hitbox.BackgroundColor3 = Color3.new(1,1,1)
	Hitbox.BackgroundTransparency = 1
	Hitbox.BorderColor3 = Color3.new(0,0,0)
	Hitbox.BorderSizePixel = 0
	Hitbox.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Hitbox.Size = UDim2.new(1,0,1,0)
	Hitbox.Text = ""
	Hitbox.TextColor3 = Color3.new(0,0,0)
	Hitbox.TextSize = 14
	Hitbox.TextTransparency = 1
	Hitbox.TextXAlignment = Enum.TextXAlignment.Right
	Hitbox.ZIndex = 7
	Hitbox.Parent = Boolean
end
local Input = Instance.new("Frame") do
	Input.Name = "Input"
	Input.Active = true
	Input.AnchorPoint = Vector2.new(0,0.5)
	Input.BackgroundColor3 = Color3.new(1,1,1)
	Input.BackgroundTransparency = 1
	Input.BorderColor3 = Color3.new(0,0,0)
	Input.BorderSizePixel = 0
	Input.Position = UDim2.new(0.5,0,0.5,0)
	Input.Selectable = true
	Input.Size = UDim2.new(0.5,0,1,0)
	Input.Visible = false
	Input.ZIndex = 5
	Input.Parent = Components
end

local UIStroke_2 = Instance.new("UIStroke") do
	UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_2.Parent = Input
end
local Input_1 = Instance.new("TextBox") do
	Input_1.Name = "Input"
	Input_1.AnchorPoint = Vector2.new(0,0.5)
	Input_1.BackgroundColor3 = Color3.new(1,1,1)
	Input_1.BackgroundTransparency = 1
	Input_1.BorderColor3 = Color3.new(0,0,0)
	Input_1.BorderSizePixel = 0
	Input_1.ClearTextOnFocus = false
	Input_1.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
	Input_1.PlaceholderColor3 = Color3.new(0.698,0.698,0.698)
	Input_1.Position = UDim2.new(0,6,0.5,0)
	Input_1.Size = UDim2.new(1,-6,1,0)
	Input_1.TextColor3 = Color3.new(1,1,1)
	Input_1.TextSize = 14
	Input_1.TextWrapped = true
	Input_1.TextXAlignment = Enum.TextXAlignment.Left
	Input_1.ZIndex = 6
	Input_1.Parent = Input
end
local Category = Instance.new("TextButton") do
	Category.Name = "Category"
	Category.Active = false
	Category.AutoButtonColor = false
	Category.BackgroundColor3 = Color3.new(0.255,0.255,0.255)
	Category.BorderColor3 = Color3.new(0,0,0)
	Category.BorderSizePixel = 0
	Category.Selectable = false
	Category.Size = UDim2.new(1,0,0,24)
	Category.Text = ""
	Category.TextTransparency = 1
	Category.Visible = false
	Category.ZIndex = 5
	Category.Parent = Components
end

local UIStroke_3 = Instance.new("UIStroke") do
	UIStroke_3.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_3.Parent = Category
end
local Label = Instance.new("TextLabel") do
	Label.Name = "Label"
	Label.AnchorPoint = Vector2.new(0,0.5)
	Label.BackgroundColor3 = Color3.new(1,1,1)
	Label.BackgroundTransparency = 1
	Label.BorderColor3 = Color3.new(0,0,0)
	Label.BorderSizePixel = 0
	Label.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)
	Label.LayoutOrder = 1
	Label.Position = UDim2.new(0,24,0.5,0)
	Label.Size = UDim2.new(1,0,1,0)
	Label.Text = "Appearance"
	Label.TextColor3 = Color3.new(1,1,1)
	Label.TextSize = 14
	Label.TextWrapped = true
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.ZIndex = 6
	Label.Parent = Category
end
local Collapser = Instance.new("ImageLabel") do
	Collapser.Name = "Collapser"
	Collapser.AnchorPoint = Vector2.new(0,0.5)
	Collapser.BackgroundColor3 = Color3.new(1,1,1)
	Collapser.BackgroundTransparency = 1
	Collapser.BorderColor3 = Color3.new(0,0,0)
	Collapser.BorderSizePixel = 0
	Collapser.Image = "http://www.roblox.com/asset/?id=134054819148055"
	Collapser.Position = UDim2.new(0,0,0.5,0)
	Collapser.Size = UDim2.new(0,24,1,0)
	Collapser.ZIndex = 6
	Collapser.Parent = Category
end
local Property = Instance.new("TextButton") do
	Property.Name = "Property"
	Property.Active = false
	Property.AutoButtonColor = false
	Property.BackgroundColor3 = Color3.new(0.153,0.153,0.153)
	Property.BorderColor3 = Color3.new(0,0,0)
	Property.BorderSizePixel = 0
	Property.Selectable = false
	Property.Size = UDim2.new(1,0,0,100)
	Property.Text = ""
	Property.TextTransparency = 1
	Property.ZIndex = 5
	Property.Parent = Components
end

local UIStroke_4 = Instance.new("UIStroke") do
	UIStroke_4.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_4.Parent = Property
end
local Content_1 = Instance.new("Frame") do
	Content_1.Name = "Content"
	Content_1.BackgroundColor3 = Color3.new(1,1,1)
	Content_1.BackgroundTransparency = 1
	Content_1.BorderColor3 = Color3.new(0,0,0)
	Content_1.BorderSizePixel = 0
	Content_1.Size = UDim2.new(1,0,1,0)
	Content_1.ZIndex = 5
	Content_1.Parent = Property
end

local LabelFrame = Instance.new("Frame") do
	LabelFrame.Name = "LabelFrame"
	LabelFrame.AnchorPoint = Vector2.new(1,0.5)
	LabelFrame.BackgroundColor3 = Color3.new(1,1,1)
	LabelFrame.BackgroundTransparency = 1
	LabelFrame.BorderColor3 = Color3.new(0,0,0)
	LabelFrame.BorderSizePixel = 0
	LabelFrame.Position = UDim2.new(0.5,0,0.5,0)
	LabelFrame.Size = UDim2.new(0.5,0,1,0)
	LabelFrame.ZIndex = 6
	LabelFrame.Parent = Content_1
end

local Label_1 = Instance.new("TextLabel") do
	Label_1.Name = "Label"
	Label_1.AnchorPoint = Vector2.new(1,0.5)
	Label_1.BackgroundColor3 = Color3.new(1,1,1)
	Label_1.BackgroundTransparency = 1
	Label_1.BorderColor3 = Color3.new(0,0,0)
	Label_1.BorderSizePixel = 0
	Label_1.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
	Label_1.LayoutOrder = 1
	Label_1.Position = UDim2.new(0.5,0,0.5,0)
	Label_1.Size = UDim2.new(0.2,0,1,0)
	Label_1.TextColor3 = Color3.new(1,1,1)
	Label_1.TextSize = 14
	Label_1.TextWrapped = true
	Label_1.TextXAlignment = Enum.TextXAlignment.Left
	Label_1.ZIndex = 6
	Label_1.Parent = LabelFrame
end

local UIFlexItem_3 = Instance.new("UIFlexItem") do
	UIFlexItem_3.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem_3.GrowRatio = 1.2
	UIFlexItem_3.Parent = Label_1
end
local Gap = Instance.new("Frame") do
	Gap.Name = "Gap"
	Gap.AnchorPoint = Vector2.new(0,0.5)
	Gap.BackgroundColor3 = Color3.new(1,1,1)
	Gap.BorderColor3 = Color3.new(0,0,0)
	Gap.BorderSizePixel = 0
	Gap.Position = UDim2.new(0,0,0.5,0)
	Gap.Size = UDim2.new(0,24,1,0)
	Gap.Parent = LabelFrame
end
local UIListLayout_2 = Instance.new("UIListLayout") do
	UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_2.Parent = LabelFrame
end
local EmptyProperty = Instance.new("Frame") do
	EmptyProperty.Name = "EmptyProperty"
	EmptyProperty.BackgroundColor3 = Color3.new(0.153,0.153,0.153)
	EmptyProperty.BackgroundTransparency = 1
	EmptyProperty.BorderColor3 = Color3.new(0,0,0)
	EmptyProperty.BorderSizePixel = 0
	EmptyProperty.LayoutOrder = -1
	EmptyProperty.Size = UDim2.new(1,0,0,25)
	EmptyProperty.ZIndex = 5
	EmptyProperty.Parent = Components
end
local Collapse = Instance.new("ImageButton") do
	Collapse.Name = "Collapse"
	Collapse.AnchorPoint = Vector2.new(0.5,0.5)
	Collapse.BackgroundColor3 = Color3.new(1,1,1)
	Collapse.BackgroundTransparency = 1
	Collapse.BorderColor3 = Color3.new(0,0,0)
	Collapse.BorderSizePixel = 0
	Collapse.Image = "rbxassetid://75405344316847"
	Collapse.Position = UDim2.new(0.5,0,0.5,0)
	Collapse.Size = UDim2.new(1,0,1,0)
	Collapse.ZIndex = 9
	Collapse.Parent = Components
end

local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint",Collapse)
local EnumListSample = Instance.new("TextButton") do
	EnumListSample.Name = "EnumListSample"
	EnumListSample.AnchorPoint = Vector2.new(1,0.5)
	EnumListSample.AutoButtonColor = false
	EnumListSample.BackgroundColor3 = Color3.new(0.039,0.039,0.039)
	EnumListSample.BorderColor3 = Color3.new(0,0,0)
	EnumListSample.BorderSizePixel = 0
	EnumListSample.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
	EnumListSample.LayoutOrder = 1
	EnumListSample.Modal = true
	EnumListSample.Position = UDim2.new(0.5,0,0.5,0)
	EnumListSample.Selectable = false
	EnumListSample.Size = UDim2.new(1,0,0,16)
	EnumListSample.Text = "Label"
	EnumListSample.TextColor3 = Color3.new(1,1,1)
	EnumListSample.TextSize = 14
	EnumListSample.TextWrapped = true
	EnumListSample.TextXAlignment = Enum.TextXAlignment.Left
	EnumListSample.Visible = false
	EnumListSample.ZIndex = 999_999
	EnumListSample.Parent = Components
end
local EnumList = Instance.new("Frame") do
	EnumList.Name = "EnumList"
	EnumList.Active = true
	EnumList.AnchorPoint = Vector2.new(0,0.5)
	EnumList.BackgroundColor3 = Color3.new(1,1,1)
	EnumList.BackgroundTransparency = 1
	EnumList.BorderColor3 = Color3.new(0,0,0)
	EnumList.BorderSizePixel = 0
	EnumList.Position = UDim2.new(0.5,0,0.5,0)
	EnumList.Selectable = true
	EnumList.Size = UDim2.new(0.5,0,1,0)
	EnumList.ZIndex = 5
	EnumList.Parent = Components
end

local UIStroke_5 = Instance.new("UIStroke") do
	UIStroke_5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_5.Parent = EnumList
end
local Button_1 = Instance.new("TextButton") do
	Button_1.Name = "Button"
	Button_1.Active = false
	Button_1.AnchorPoint = Vector2.new(0,0.5)
	Button_1.AutoButtonColor = false
	Button_1.BackgroundColor3 = Color3.new(0.039,0.039,0.039)
	Button_1.BackgroundTransparency = 1
	Button_1.BorderColor3 = Color3.new(0,0,0)
	Button_1.BorderSizePixel = 0
	Button_1.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
	Button_1.LayoutOrder = 1
	Button_1.Position = UDim2.new(0,0,0.5,0)
	Button_1.Selectable = false
	Button_1.Size = UDim2.new(1,0,1,0)
	Button_1.Text = "Label"
	Button_1.TextColor3 = Color3.new(1,1,1)
	Button_1.TextSize = 14
	Button_1.TextWrapped = true
	Button_1.TextXAlignment = Enum.TextXAlignment.Left
	Button_1.ZIndex = 20
	Button_1.Parent = EnumList
end

local Down = Instance.new("ImageLabel") do
	Down.Name = "Down"
	Down.AnchorPoint = Vector2.new(1,0.5)
	Down.BackgroundColor3 = Color3.new(1,1,1)
	Down.BackgroundTransparency = 1
	Down.BorderColor3 = Color3.new(0,0,0)
	Down.BorderSizePixel = 0
	Down.Image = "http://www.roblox.com/asset/?id=98915295553134"
	Down.Position = UDim2.new(1,0,0.5,0)
	Down.Selectable = true
	Down.Size = UDim2.new(0,16,0,16)
	Down.ZIndex = 19
	Down.Parent = Button_1
end
local Container = Instance.new("Frame") do
	Container.Name = "Container"
	Container.BackgroundColor3 = Color3.new(0.157,0.157,0.157)
	Container.BorderColor3 = Color3.new(0,0,0)
	Container.BorderSizePixel = 0
	Container.Position = UDim2.new(0,0,1,0)
	Container.Size = UDim2.new(1,0,1.61,0)
	Container.Visible = false
	Container.ZIndex = 20
	Container.Parent = Button_1
end

local UIListLayout_3 = Instance.new("UIListLayout") do
	UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_3.Parent = Container
end
local UIStroke_6 = Instance.new("UIStroke") do
	UIStroke_6.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_6.Parent = Container
end
local NumberRange = Instance.new("Frame") do
	NumberRange.Name = "NumberRange"
	NumberRange.Active = true
	NumberRange.AnchorPoint = Vector2.new(0,0.5)
	NumberRange.BackgroundColor3 = Color3.new(1,1,1)
	NumberRange.BackgroundTransparency = 1
	NumberRange.BorderColor3 = Color3.new(0,0,0)
	NumberRange.BorderSizePixel = 0
	NumberRange.Position = UDim2.new(0.5,0,0.5,0)
	NumberRange.Selectable = true
	NumberRange.Size = UDim2.new(0.5,0,1,0)
	NumberRange.ZIndex = 5
	NumberRange.Parent = Components
end

local UIStroke_7 = Instance.new("UIStroke") do
	UIStroke_7.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_7.Parent = NumberRange
end
local Slider = Instance.new("Frame") do
	Slider.Name = "Slider"
	Slider.AnchorPoint = Vector2.new(0,0.5)
	Slider.BackgroundColor3 = Color3.new(1,1,1)
	Slider.BackgroundTransparency = 1
	Slider.BorderColor3 = Color3.new(0,0,0)
	Slider.BorderSizePixel = 0
	Slider.Position = UDim2.new(0,70,0.5,0)
	Slider.Size = UDim2.new(1,-70,1,0)
	Slider.ZIndex = 5
	Slider.Parent = NumberRange
end

local Bar = Instance.new("TextButton") do
	Bar.Name = "Bar"
	Bar.AnchorPoint = Vector2.new(0.5,0.5)
	Bar.AutoButtonColor = false
	Bar.BackgroundColor3 = Color3.new(1,0,0)
	Bar.BorderColor3 = Color3.new(0,0,0)
	Bar.BorderSizePixel = 0
	Bar.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Bar.Position = UDim2.new(0.5,0,0.5,0)
	Bar.Size = UDim2.new(1,0,0,3)
	Bar.Text = ""
	Bar.TextColor3 = Color3.new(0,0,0)
	Bar.TextSize = 14
	Bar.TextTransparency = 1
	Bar.ZIndex = 5
	Bar.Parent = Slider
end
local Slider_1 = Instance.new("TextButton") do
	Slider_1.Name = "Slider"
	Slider_1.AnchorPoint = Vector2.new(0.5,0.5)
	Slider_1.AutoButtonColor = false
	Slider_1.BackgroundColor3 = Color3.new(1,1,1)
	Slider_1.BorderColor3 = Color3.new(0,0,0)
	Slider_1.BorderSizePixel = 0
	Slider_1.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Slider_1.Position = UDim2.new(0.5,0,0.5,0)
	Slider_1.Size = UDim2.new(0,10,0,14)
	Slider_1.Text = ""
	Slider_1.TextColor3 = Color3.new(0,0,0)
	Slider_1.TextSize = 14
	Slider_1.TextTransparency = 1
	Slider_1.ZIndex = 6
	Slider_1.Parent = Slider
end

local UIStroke_8 = Instance.new("UIStroke") do
	UIStroke_8.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_8.Parent = Slider_1
end
local Input_Frame = Instance.new("Frame") do
	Input_Frame.Name = "Input_Frame"
	Input_Frame.Active = true
	Input_Frame.AnchorPoint = Vector2.new(0,0.5)
	Input_Frame.BackgroundColor3 = Color3.new(1,1,1)
	Input_Frame.BackgroundTransparency = 1
	Input_Frame.BorderColor3 = Color3.new(0,0,0)
	Input_Frame.BorderSizePixel = 0
	Input_Frame.Position = UDim2.new(0,0,0.5,0)
	Input_Frame.Selectable = true
	Input_Frame.Size = UDim2.new(0,70,1,-2)
	Input_Frame.ZIndex = 6
	Input_Frame.Parent = NumberRange
end

local UIStroke_9 = Instance.new("UIStroke") do
	UIStroke_9.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_9.Parent = Input_Frame
end
local Input_2 = Instance.new("TextBox") do
	Input_2.Name = "Input"
	Input_2.AnchorPoint = Vector2.new(0,0.5)
	Input_2.BackgroundColor3 = Color3.new(1,1,1)
	Input_2.BackgroundTransparency = 1
	Input_2.BorderColor3 = Color3.new(0,0,0)
	Input_2.BorderSizePixel = 0
	Input_2.ClearTextOnFocus = false
	Input_2.FontFace = Font.new("rbxasset://fonts/families/BuilderSans.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
	Input_2.PlaceholderColor3 = Color3.new(0.698,0.698,0.698)
	Input_2.Position = UDim2.new(0,6,0.5,0)
	Input_2.Size = UDim2.new(0,64,1,0)
	Input_2.Text = "0"
	Input_2.TextColor3 = Color3.new(1,1,1)
	Input_2.TextSize = 14
	Input_2.TextWrapped = true
	Input_2.TextXAlignment = Enum.TextXAlignment.Left
	Input_2.ZIndex = 6
	Input_2.Parent = Input_Frame
end

local Buttons = Instance.new("Frame") do
	Buttons.Name = "Buttons"
	Buttons.AnchorPoint = Vector2.new(1,0.5)
	Buttons.BackgroundColor3 = Color3.new(1,1,1)
	Buttons.BackgroundTransparency = 1
	Buttons.BorderColor3 = Color3.new(0,0,0)
	Buttons.BorderSizePixel = 0
	Buttons.Position = UDim2.new(1,0,0.5,0)
	Buttons.Size = UDim2.new(0,16,1,0)
	Buttons.ZIndex = 5
	Buttons.Parent = Input_2
end

local Up = Instance.new("ImageButton") do
	Up.Name = "Up"
	Up.AnchorPoint = Vector2.new(0.5,0)
	Up.AutoButtonColor = false
	Up.BackgroundColor3 = Color3.new(1,1,1)
	Up.BackgroundTransparency = 1
	Up.BorderColor3 = Color3.new(0,0,0)
	Up.BorderSizePixel = 0
	Up.Image = "http://www.roblox.com/asset/?id=87816246791812"
	Up.Position = UDim2.new(0.5,0,0,0)
	Up.Size = UDim2.new(1,0,0.5,0)
	Up.ZIndex = 10
	Up.Parent = Buttons
end
local Down_1 = Instance.new("ImageButton") do
	Down_1.Name = "Down"
	Down_1.AnchorPoint = Vector2.new(0.5,1)
	Down_1.AutoButtonColor = false
	Down_1.BackgroundColor3 = Color3.new(1,1,1)
	Down_1.BackgroundTransparency = 1
	Down_1.BorderColor3 = Color3.new(0,0,0)
	Down_1.BorderSizePixel = 0
	Down_1.Image = "http://www.roblox.com/asset/?id=98915295553134"
	Down_1.Position = UDim2.new(0.5,0,1,0)
	Down_1.Size = UDim2.new(1,0,0.5,0)
	Down_1.ZIndex = 10
	Down_1.Parent = Buttons
end
local TabNameHere = Instance.new("Frame") do
	TabNameHere.Name = "TabNameHere"
	TabNameHere.AnchorPoint = Vector2.new(0.5,0.5)
	TabNameHere.BackgroundColor3 = Color3.new(1,1,1)
	TabNameHere.BackgroundTransparency = 1
	TabNameHere.BorderColor3 = Color3.new(0,0,0)
	TabNameHere.BorderSizePixel = 0
	TabNameHere.Position = UDim2.new(0.5,0,0.5,0)
	TabNameHere.Size = UDim2.new(1,0,1,0)
	TabNameHere.Visible = false
	TabNameHere.ZIndex = 2
	TabNameHere.Parent = Components
end

local Scroll = Instance.new("ScrollingFrame") do
	Scroll.Name = "Scroll"
	Scroll.Active = true
	Scroll.AnchorPoint = Vector2.new(0.5,0.5)
	Scroll.BackgroundColor3 = Color3.new(0.102,0.102,0.102)
	Scroll.BorderColor3 = Color3.new(0,0,0)
	Scroll.BorderSizePixel = 0
	Scroll.BottomImage = ""
	Scroll.CanvasSize = UDim2.new(0,0,0,1_000)
	Scroll.ElasticBehavior = Enum.ElasticBehavior.Never
	Scroll.MidImage = "rbxassetid://117496832406243"
	Scroll.Position = UDim2.new(0.5,0,0.5,0)
	Scroll.ScrollBarImageColor3 = Color3.new(0.392,0.392,0.392)
	Scroll.Size = UDim2.new(1,0,1,0)
	Scroll.TopImage = ""
	Scroll.ZIndex = 3
	Scroll.Parent = TabNameHere
end

local List = Instance.new("TextButton") do
	List.Name = "List"
	List.Active = false
	List.AutoButtonColor = false
	List.BackgroundColor3 = Color3.new(0.263,0.263,0.263)
	List.BorderColor3 = Color3.new(0.263,0.263,0.263)
	List.BorderSizePixel = 30
	List.Position = UDim2.new(0,1,0,1)
	List.Selectable = false
	List.Size = UDim2.new(0.985,0,1,0)
	List.Text = ""
	List.TextTransparency = 1
	List.ZIndex = 4
	List.Parent = Scroll
end

local UIListLayout_4 = Instance.new("UIListLayout") do
	UIListLayout_4.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_4.Parent = List
end
local Lower = Instance.new("ImageButton") do
	Lower.Name = "Lower"
	Lower.Active = false
	Lower.AnchorPoint = Vector2.one
	Lower.AutoButtonColor = false
	Lower.BackgroundColor3 = Color3.new(0.333,0.333,0.333)
	Lower.BorderColor3 = Color3.new(0,0,0)
	Lower.BorderMode = Enum.BorderMode.Inset
	Lower.Image = "rbxassetid://76128775374929"
	Lower.Position = UDim2.new(1,0,1,0)
	Lower.Selectable = false
	Lower.Size = UDim2.new(0,16,0,16)
	Lower.ZIndex = 3
	Lower.Parent = TabNameHere
end
local Upper = Instance.new("ImageButton") do
	Upper.Name = "Upper"
	Upper.Active = false
	Upper.AnchorPoint = Vector2.xAxis
	Upper.AutoButtonColor = false
	Upper.BackgroundColor3 = Color3.new(0.333,0.333,0.333)
	Upper.BorderColor3 = Color3.new(0,0,0)
	Upper.BorderMode = Enum.BorderMode.Inset
	Upper.Image = "rbxassetid://107323324017183"
	Upper.Position = UDim2.new(1,0,0,0)
	Upper.Selectable = false
	Upper.Size = UDim2.new(0,16,0,16)
	Upper.ZIndex = 3
	Upper.Parent = TabNameHere
end
local Left = Instance.new("ImageButton") do
	Left.Name = "Left"
	Left.Active = false
	Left.AnchorPoint = Vector2.yAxis
	Left.AutoButtonColor = false
	Left.BackgroundColor3 = Color3.new(0.333,0.333,0.333)
	Left.BorderColor3 = Color3.new(0,0,0)
	Left.BorderMode = Enum.BorderMode.Inset
	Left.Image = "rbxassetid://76128775374929"
	Left.Position = UDim2.new(0,0,1,0)
	Left.Rotation = 90
	Left.Selectable = false
	Left.Size = UDim2.new(0,16,0,16)
	Left.ZIndex = 19
	Left.Parent = TabNameHere
end
local Right = Instance.new("ImageButton") do
	Right.Name = "Right"
	Right.Active = false
	Right.AnchorPoint = Vector2.one
	Right.AutoButtonColor = false
	Right.BackgroundColor3 = Color3.new(0.333,0.333,0.333)
	Right.BorderColor3 = Color3.new(0,0,0)
	Right.BorderMode = Enum.BorderMode.Inset
	Right.Image = "rbxassetid://107323324017183"
	Right.Position = UDim2.new(1,-16,1,0)
	Right.Rotation = 90
	Right.Selectable = false
	Right.Size = UDim2.new(0,16,0,16)
	Right.ZIndex = 19
	Right.Parent = TabNameHere
end
local Right_Outline = Instance.new("Frame") do
	Right_Outline.Name = "Right_Outline"
	Right_Outline.Active = true
	Right_Outline.AnchorPoint = Vector2.xAxis
	Right_Outline.BackgroundColor3 = Color3.new(1,1,1)
	Right_Outline.BackgroundTransparency = 1
	Right_Outline.BorderColor3 = Color3.new(0,0,0)
	Right_Outline.BorderSizePixel = 0
	Right_Outline.Position = UDim2.new(1,0,0,0)
	Right_Outline.Size = UDim2.new(0,16,1,0)
	Right_Outline.Visible = false
	Right_Outline.ZIndex = 50
	Right_Outline.Parent = TabNameHere
end

local UIStroke_10 = Instance.new("UIStroke") do
	UIStroke_10.Color = Color3.new(0.133,0.133,0.133)
	UIStroke_10.Parent = Right_Outline
end
local Bottom_Outline = Instance.new("Frame") do
	Bottom_Outline.Name = "Bottom_Outline"
	Bottom_Outline.Active = true
	Bottom_Outline.AnchorPoint = Vector2.yAxis
	Bottom_Outline.BackgroundColor3 = Color3.new(1,1,1)
	Bottom_Outline.BackgroundTransparency = 1
	Bottom_Outline.BorderColor3 = Color3.new(0,0,0)
	Bottom_Outline.BorderSizePixel = 0
	Bottom_Outline.Position = UDim2.new(0,0,1,0)
	Bottom_Outline.Size = UDim2.new(1,0,0,16)
	Bottom_Outline.Visible = false
	Bottom_Outline.ZIndex = 50
	Bottom_Outline.Parent = TabNameHere
end

local UIStroke_11 = Instance.new("UIStroke",Bottom_Outline)
local CodeOutput = Instance.new("Frame") do
	CodeOutput:SetAttribute("NoScale",true)
	CodeOutput.Name = "CodeOutput"
	CodeOutput.BackgroundColor3 = Color3.new(0,0,0)
	CodeOutput.BorderColor3 = Color3.new(0,0,0)
	CodeOutput.BorderSizePixel = 0
	CodeOutput.Size = UDim2.new(1,0,1,0)
	CodeOutput.Visible = false
	CodeOutput.ZIndex = 5
	CodeOutput.Parent = Components
end

local UIListLayout_5 = Instance.new("UIListLayout") do
	UIListLayout_5.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_5.Parent = CodeOutput
end
local ScrollingFrame = Instance.new("ScrollingFrame") do
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.new(1,1,1)
	ScrollingFrame.BackgroundTransparency = 1
	ScrollingFrame.BorderColor3 = Color3.new(0,0,0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.LayoutOrder = 1
	ScrollingFrame.Position = UDim2.new(0,0,0.063,0)
	ScrollingFrame.ScrollBarImageColor3 = Color3.new(0,0,0)
	ScrollingFrame.Size = UDim2.new(1,0,0.942,0)
	ScrollingFrame.ZIndex = 6
	ScrollingFrame.Parent = CodeOutput
end

local Code = Instance.new("TextBox") do
	Code.Name = "Code"
	Code.BackgroundColor3 = Color3.new(1,1,1)
	Code.BackgroundTransparency = 1
	Code.BorderColor3 = Color3.new(0,0,0)
	Code.BorderSizePixel = 0
	Code.ClearTextOnFocus = false
	Code.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Code.Size = UDim2.new(1,0,1,0)
	Code.TextColor3 = Color3.new(0,0,0)
	Code.TextSize = 14
	Code.TextTransparency = 0.99
	Code.TextXAlignment = Enum.TextXAlignment.Left
	Code.TextYAlignment = Enum.TextYAlignment.Top
	Code.ZIndex = 8
	Code.Parent = ScrollingFrame
end
local Rich = Instance.new("TextLabel") do
	Rich.Name = "Rich"
	Rich.Active = true
	Rich.BackgroundColor3 = Color3.new(1,1,1)
	Rich.BackgroundTransparency = 1
	Rich.BorderColor3 = Color3.new(0,0,0)
	Rich.BorderSizePixel = 0
	Rich.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Rich.RichText = true
	Rich.Selectable = true
	Rich.Size = UDim2.new(1,0,1,0)
	Rich.Text = "TextBox"
	Rich.TextColor3 = Color3.new(0,0,0)
	Rich.TextSize = 14
	Rich.TextXAlignment = Enum.TextXAlignment.Left
	Rich.TextYAlignment = Enum.TextYAlignment.Top
	Rich.ZIndex = 7
	Rich.Parent = ScrollingFrame
end
local Content_2 = Instance.new("Frame") do
	Content_2.Name = "Content"
	Content_2.BackgroundColor3 = Color3.new(1,1,1)
	Content_2.BackgroundTransparency = 1
	Content_2.BorderColor3 = Color3.new(0,0,0)
	Content_2.BorderSizePixel = 0
	Content_2.Size = UDim2.new(1,0,0.063,0)
	Content_2.ZIndex = 6
	Content_2.Parent = CodeOutput
end

local Frame = Instance.new("Frame") do
	Frame.BackgroundColor3 = Color3.new(1,1,1)
	Frame.BackgroundTransparency = 1
	Frame.BorderColor3 = Color3.new(0,0,0)
	Frame.BorderSizePixel = 0
	Frame.LayoutOrder = 3
	Frame.Position = UDim2.new(1,0,0,0)
	Frame.Size = UDim2.new(0.54,0,1,0)
	Frame.ZIndex = 6
	Frame.Parent = Content_2
end

local UIListLayout_6 = Instance.new("UIListLayout") do
	UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_6.Parent = Frame
end
local Left_1 = Instance.new("ImageButton") do
	Left_1.Name = "Left"
	Left_1.AnchorPoint = Vector2.one
	Left_1.BackgroundColor3 = Color3.new(1,1,1)
	Left_1.BackgroundTransparency = 1
	Left_1.BorderColor3 = Color3.new(0,0,0)
	Left_1.BorderSizePixel = 0
	Left_1.Image = "rbxassetid://116652457497210"
	Left_1.Size = UDim2.new(1,0,1,0)
	Left_1.ZIndex = 7
	Left_1.Parent = Frame
end

local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint",Left_1)
local UIFlexItem_4 = Instance.new("UIFlexItem") do
	UIFlexItem_4.FlexMode = Enum.UIFlexMode.Grow
	UIFlexItem_4.ItemLineAlignment = Enum.ItemLineAlignment.Start
	UIFlexItem_4.Parent = Left_1
end
local Num = Instance.new("TextLabel") do
	Num.Name = "Num"
	Num.Active = true
	Num.BackgroundColor3 = Color3.new(1,1,1)
	Num.BackgroundTransparency = 1
	Num.BorderColor3 = Color3.new(0,0,0)
	Num.BorderSizePixel = 0
	Num.LayoutOrder = 1
	Num.Selectable = true
	Num.Size = UDim2.new(1,0,1,0)
	Num.Text = "1"
	Num.TextColor3 = Color3.new(1,1,1)
	Num.TextScaled = true
	Num.TextWrapped = true
	Num.ZIndex = 7
	Num.Parent = Frame
end

local UIFlexItem_5 = Instance.new("UIFlexItem") do
	UIFlexItem_5.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem_5.GrowRatio = 2
	UIFlexItem_5.ItemLineAlignment = Enum.ItemLineAlignment.Center
	UIFlexItem_5.ShrinkRatio = 0.5
	UIFlexItem_5.Parent = Num
end
local Right_1 = Instance.new("ImageButton") do
	Right_1.Name = "Right"
	Right_1.AnchorPoint = Vector2.one
	Right_1.BackgroundColor3 = Color3.new(1,1,1)
	Right_1.BackgroundTransparency = 1
	Right_1.BorderColor3 = Color3.new(0,0,0)
	Right_1.BorderSizePixel = 0
	Right_1.Image = "rbxassetid://121804704003360"
	Right_1.LayoutOrder = 3
	Right_1.Size = UDim2.new(1,0,1,0)
	Right_1.ZIndex = 7
	Right_1.Parent = Frame
end

local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint",Right_1)
local UIFlexItem_6 = Instance.new("UIFlexItem") do
	UIFlexItem_6.FlexMode = Enum.UIFlexMode.Grow
	UIFlexItem_6.ItemLineAlignment = Enum.ItemLineAlignment.End
	UIFlexItem_6.Parent = Right_1
end
local UIFlexItem_7 = Instance.new("UIFlexItem") do
	UIFlexItem_7.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem_7.ItemLineAlignment = Enum.ItemLineAlignment.End
	UIFlexItem_7.Parent = Frame
end
local Hint = Instance.new("TextLabel") do
	Hint.Name = "Hint"
	Hint.BackgroundColor3 = Color3.new(1,1,1)
	Hint.BackgroundTransparency = 1
	Hint.BorderColor3 = Color3.new(0,0,0)
	Hint.BorderSizePixel = 0
	Hint.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Hint.LayoutOrder = 2
	Hint.Size = UDim2.new(1,0,1,0)
	Hint.TextColor3 = Color3.new(1,1,1)
	Hint.TextScaled = true
	Hint.TextSize = 14
	Hint.TextWrapped = true
	Hint.TextXAlignment = Enum.TextXAlignment.Left
	Hint.ZIndex = 6
	Hint.Parent = Content_2
end

local UIFlexItem_8 = Instance.new("UIFlexItem") do
	UIFlexItem_8.FlexMode = Enum.UIFlexMode.Fill
	UIFlexItem_8.ItemLineAlignment = Enum.ItemLineAlignment.Start
	UIFlexItem_8.Parent = Hint
end
local UIListLayout_7 = Instance.new("UIListLayout") do
	UIListLayout_7.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_7.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_7.Parent = Content_2
end
local SaveScript = Instance.new("ImageButton") do
	SaveScript.Name = "SaveScript"
	SaveScript.BackgroundColor3 = Color3.new(1,1,1)
	SaveScript.BackgroundTransparency = 1
	SaveScript.BorderColor3 = Color3.new(0,0,0)
	SaveScript.BorderSizePixel = 0
	SaveScript.Image = "rbxassetid://81867126737174"
	SaveScript.Size = UDim2.new(1,0,1,0)
	SaveScript.ZIndex = 7
	SaveScript.Parent = Content_2
end

local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint",SaveScript)
local UIFlexItem_9 = Instance.new("UIFlexItem") do
	UIFlexItem_9.FlexMode = Enum.UIFlexMode.Grow
	UIFlexItem_9.ItemLineAlignment = Enum.ItemLineAlignment.Start
	UIFlexItem_9.Parent = SaveScript
end
local Fill = Instance.new("Frame") do
	Fill.Name = "Fill"
	Fill.AnchorPoint = Vector2.new(0.5,0.5)
	Fill.BackgroundColor3 = Color3.new(1,1,1)
	Fill.BorderColor3 = Color3.new(0,0,0)
	Fill.BorderSizePixel = 0
	Fill.Interactable = false
	Fill.Position = UDim2.new(0.5,0,0.5,0)
	Fill.ZIndex = 6
	Fill.Parent = SaveScript
end
local BuildScript = Instance.new("ImageButton") do
	BuildScript.Name = "BuildScript"
	BuildScript.BackgroundColor3 = Color3.new(1,1,1)
	BuildScript.BackgroundTransparency = 1
	BuildScript.BorderColor3 = Color3.new(0,0,0)
	BuildScript.BorderSizePixel = 0
	BuildScript.Image = "rbxassetid://118179134997415"
	BuildScript.LayoutOrder = 1
	BuildScript.Size = UDim2.new(1,0,1,0)
	BuildScript.ZIndex = 7
	BuildScript.Parent = Content_2
end

local UIAspectRatioConstraint_6 = Instance.new("UIAspectRatioConstraint",BuildScript)
local UIFlexItem_10 = Instance.new("UIFlexItem") do
	UIFlexItem_10.FlexMode = Enum.UIFlexMode.Grow
	UIFlexItem_10.ItemLineAlignment = Enum.ItemLineAlignment.Start
	UIFlexItem_10.Parent = BuildScript
end
local Fill_1 = Instance.new("Frame") do
	Fill_1.Name = "Fill"
	Fill_1.AnchorPoint = Vector2.new(0.5,0.5)
	Fill_1.BackgroundColor3 = Color3.new(1,1,1)
	Fill_1.BorderColor3 = Color3.new(0,0,0)
	Fill_1.BorderSizePixel = 0
	Fill_1.Interactable = false
	Fill_1.Position = UDim2.new(0.5,0,0.5,0)
	Fill_1.ZIndex = 6
	Fill_1.Parent = BuildScript
end
local ErrorHTTP_UI = Instance.new("Frame") do
	ErrorHTTP_UI:SetAttribute("NoScale",true)
	ErrorHTTP_UI.Name = "ErrorHTTP_UI"
	ErrorHTTP_UI.BackgroundColor3 = Color3.new(0.118,0.118,0.118)
	ErrorHTTP_UI.BorderColor3 = Color3.new(0,0,0)
	ErrorHTTP_UI.BorderSizePixel = 0
	ErrorHTTP_UI.Size = UDim2.new(1,0,1,0)
	ErrorHTTP_UI.Visible = false
	ErrorHTTP_UI.ZIndex = 2
	ErrorHTTP_UI.Parent = Components
end

local Data = Instance.new("Frame") do
	Data.Name = "Data"
	Data.AnchorPoint = Vector2.new(0.5,0.5)
	Data.BackgroundColor3 = Color3.new(1,1,1)
	Data.BackgroundTransparency = 1
	Data.BorderColor3 = Color3.new(0,0,0)
	Data.BorderSizePixel = 0
	Data.Position = UDim2.new(0.5,0,0.5,0)
	Data.Size = UDim2.new(1,0,1,0)
	Data.ZIndex = 3
	Data.Parent = ErrorHTTP_UI
end

local UIAspectRatioConstraint_7 = Instance.new("UIAspectRatioConstraint",Data)
local ImageLabel = Instance.new("ImageLabel") do
	ImageLabel.AnchorPoint = Vector2.new(0.5,0.5)
	ImageLabel.BackgroundColor3 = Color3.new(1,1,1)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.new(0,0,0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Image = "rbxassetid://77195333607477"
	ImageLabel.Position = UDim2.new(0.5,0,0.316,0)
	ImageLabel.Size = UDim2.new(0.5,0,0.5,0)
	ImageLabel.ZIndex = 4
	ImageLabel.Parent = Data
end
local TextLabel = Instance.new("TextLabel") do
	TextLabel.AnchorPoint = Vector2.new(0.5,0.5)
	TextLabel.BackgroundColor3 = Color3.new(1,1,1)
	TextLabel.BackgroundTransparency = 1
	TextLabel.BorderColor3 = Color3.new(0,0,0)
	TextLabel.BorderSizePixel = 0
	TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	TextLabel.Position = UDim2.new(0.5,0,0.65,0)
	TextLabel.Size = UDim2.new(1,0,0.1,0)
	TextLabel.Text = "ERROR: No access to HTTP requests"
	TextLabel.TextColor3 = Color3.new(1,1,1)
	TextLabel.TextScaled = true
	TextLabel.TextSize = 14
	TextLabel.TextWrapped = true
	TextLabel.ZIndex = 4
	TextLabel.Parent = Data
end
local EventHandler = Instance.new("TextButton") do
	EventHandler.Name = "EventHandler"
	EventHandler.AnchorPoint = Vector2.new(0.5,0.5)
	EventHandler.BackgroundColor3 = Color3.new(1,1,1)
	EventHandler.BackgroundTransparency = 1
	EventHandler.BorderColor3 = Color3.new(0,0,0)
	EventHandler.BorderSizePixel = 0
	EventHandler.Position = UDim2.new(0.5,0,0.825,0)
	EventHandler.Size = UDim2.new(0.36,0,0.125,0)
	EventHandler.Text = ""
	EventHandler.TextTransparency = 1
	EventHandler.ZIndex = 10
	EventHandler.Parent = Data
end

local Effect = Instance.new("TextLabel") do
	Effect.Name = "Effect"
	Effect.Active = true
	Effect.AnchorPoint = Vector2.new(0.5,0.5)
	Effect.BackgroundColor3 = Color3.new(0.165,0.435,0.039)
	Effect.BorderColor3 = Color3.new(0,0,0)
	Effect.BorderSizePixel = 0
	Effect.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Effect.Position = UDim2.new(0.5,0,0.55,0)
	Effect.Selectable = true
	Effect.Size = UDim2.new(1,0,0.9,0)
	Effect.Text = ""
	Effect.TextColor3 = Color3.new(1,1,1)
	Effect.TextScaled = true
	Effect.TextSize = 14
	Effect.TextTransparency = 1
	Effect.TextWrapped = true
	Effect.ZIndex = 8
	Effect.Parent = EventHandler
end

local UIGradient = Instance.new("UIGradient") do
	UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1));ColorSequenceKeypoint.new(0.5,Color3.new(0.451,0.451,0.451));ColorSequenceKeypoint.new(1,Color3.new(1,1,1));})
	UIGradient.Rotation = 90
	UIGradient.Parent = Effect
end
local UICorner = Instance.new("UICorner") do
	UICorner.CornerRadius = UDim.new(0.2,0)
	UICorner.Parent = Effect
end
local Button_2 = Instance.new("TextLabel") do
	Button_2.Name = "Button"
	Button_2.Active = true
	Button_2.AnchorPoint = Vector2.new(0.5,0.5)
	Button_2.BackgroundColor3 = Color3.new(0.376,1,0.09)
	Button_2.BorderColor3 = Color3.new(0,0,0)
	Button_2.BorderSizePixel = 0
	Button_2.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
	Button_2.Position = UDim2.new(0.5,0,0.4,0)
	Button_2.Selectable = true
	Button_2.Size = UDim2.new(1,0,1,0)
	Button_2.Text = "Retry"
	Button_2.TextColor3 = Color3.new(1,1,1)
	Button_2.TextScaled = true
	Button_2.TextSize = 14
	Button_2.TextWrapped = true
	Button_2.ZIndex = 9
	Button_2.Parent = Effect
end

local UICorner_1 = Instance.new("UICorner") do
	UICorner_1.CornerRadius = UDim.new(0.2,0)
	UICorner_1.Parent = Button_2
end
local UIGradient_1 = Instance.new("UIGradient") do
	UIGradient_1.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1));ColorSequenceKeypoint.new(0.5,Color3.new(0.451,0.451,0.451));ColorSequenceKeypoint.new(1,Color3.new(1,1,1));})
	UIGradient_1.Rotation = 90
	UIGradient_1.Parent = Button_2
end
local UIStroke_12 = Instance.new("UIStroke") do
	UIStroke_12.Thickness = 1.5
	UIStroke_12.Parent = Button_2
end

Components.Parent=Dir
Main.Parent=Dir



