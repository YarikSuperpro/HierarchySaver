--!strict
--!optimize 2
--[[
Copyright 2025 Yarik_superpro

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
		limitations under the License.
]]

plugin.Name="Hierarchy Saver (plugin)"
local TestService = game:GetService("TestService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ScriptEditorService = game:GetService("ScriptEditorService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Selection = game:GetService("Selection")

local CurrentThread = coroutine.running()
local function SetProperty(obj:any,property:string,value:any):()
	obj[property]=value
end


local _try,get = pcall(game:GetService("Players").GetNameFromUserIdAsync,game:GetService("Players"),game:GetService("StudioService"):GetUserId())
local LocalUserName:string = (_try==true and get) or "AnonimousUser"..tostring(math.random(1,9999))


local SelectedInstance:Instance? = nil
local Heartbeat = RunService.Heartbeat
local Types = require(script:WaitForChild("Types"))

local _ss_module = require(script:WaitForChild("ss"))
local ss,UpdateSS = _ss_module.ss,_ss_module.Update

local SessionData = require(script:WaitForChild("SessionData"))

local function Parser(txt:string):any
	local modulescript = Instance.new("ModuleScript")
	modulescript.Archivable=false
	modulescript.Source=txt
	task.defer(game.Destroy,modulescript)
	return (require::any)(modulescript)
end
local CleanUpTable:{Instance} = table.create(4)::{Instance}
local function AddPluginGC(ins:Instance):()
	table.insert(CleanUpTable,ins)
	ins.Destroying:Connect(function():()
		if table.isfrozen(CleanUpTable) then return end
		local needle:number? = table.find(CleanUpTable,ins)
		if needle~=nil then
			table.remove(CleanUpTable,needle)
		end
	end)
end


plugin.Unloading:Once(function():()
	table.freeze(CleanUpTable)
	for i,v in CleanUpTable do
		v:Destroy()
	end
end)


--[[
Inverse Lerp Interpolation
Example:
(5,0,100) <strong>-></strong> 0.05
Takes <strong>value</strong> and interpets it between <strong>minimum</strong> and <strong>maximum</strong> and then returns a number from 0 to 1 representing procentage of <strong>value</strong> to reaching <strong>maximum</strong>
]]
local function iLerp(value:number, minimum:number, maximum:number):number
	return (value - minimum) / (maximum - minimum)
end

--if RunService:IsRunMode() then return end


--*********************Just more convinient warn for plugin
local warn:(...any)->() = function(...:any):()
	warn("[Hierarchy Saver]:",...)
end
local switch:{[string]:(number,number)->number} = {
	["+"] = function(arg1:number,arg2:number):number
		return arg1+arg2
	end;
	["-"] = function(arg1:number,arg2:number):number
		return arg1-arg2
	end;
	["*"] = function(arg1:number,arg2:number):number
		return arg1*arg2
	end;
	["/"] = function(arg1:number,arg2:number):number
		return arg1/arg2
	end;
	["//"] = function(arg1:number,arg2:number):number
		return arg1//arg2
	end;
	["^"] = function(arg1:number,arg2:number):number
		return arg1^arg2
	end;
	["%"] = function(arg1:number,arg2:number):number
		return arg1%arg2
	end;
	["_default"] = function(arg1:number,arg2:number):number
		return arg1
	end
}

local function Calculate(str:string):number
	local arg1,operator,arg2 = string.match(str,"(%-?%d*%.*%d*)%s*%)*%s*([%+%-%*/^%%])%s*%(*%s*(%-?%d*%.*%d*)")
	if arg1==nil then return tonumber(str) or 0 end
	local res:number = (switch[operator::string] or switch["_default"])(tonumber(arg1) or 0,tonumber(arg2) or 0)
	if res~=res then res = 0 end--Nan
	return res
end
local function MathClampValue(value:number,min:number,max:number,clamp:number):number
	return math.round(math.clamp((clamp==0 and value) or value-(value%clamp),min,max)*1_000)/1_000
end
local sortCallback = function(a:any,b:any):boolean
	if typeof(a)~=typeof(b) then return false end
	return a<b
end

--Sorted dictionary closure iterator
local function spairs<K,V>(t:{[K]:V}): () -> (K?,V?)
	local keys:{any} = {}
	for k in t do
		table.insert(keys, k)
	end
	pcall(table.sort,keys,sortCallback)
	local i:number = 0
	local n:number = #keys
	-- iterator function (closure)
	return function(): (K?,V?)
		i = i + 1
		if i <= n then
			local key:any = keys[i]
			return key, t[key]
		end
		return nil,nil
	end
end

--********************* Just types for raw class

--*********************Voodoo C++ data types into Luau types
local TranslateProperties:Types.FormattedClass = {
	["bool"]="boolean";
	["int"]="number";
	["float"]="number";
	["double"]="number";
	["int32"]="number";
	["int64"]="number";
	["int16"]="number";
	["int8"]="number";
}

--*********************Assembling class
local Classes:Types.FormattedClasses = {}
--local WaitForData = coroutine.running()


--*********************Assembling widget
local Toolbar = plugin:CreateToolbar("Hierarchy Saver")
local Button = Toolbar:CreateButton("Open Hierarchy UI","Open UI","rbxassetid://98396137856895","Open UI")
Button.ClickableWhenViewportHidden=true
local Widget:DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("Hierarchy Saver ID",DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	400,800,100,200
	))
Widget.Name="Hierarchy Saver"
Widget.Title="Hierarchy Saver"
Widget:SetAttribute("Manage",false)


;(function():()
	local TestAccess = function():string
		return ""
	end
	local VerifyAccess = Instance.new("Script")
	AddPluginGC(VerifyAccess)
	local try,ret = pcall(ScriptEditorService.UpdateSourceAsync,ScriptEditorService,VerifyAccess,TestAccess)
	if try==false then
		--09.08.2025 - 01:05 : 13

		local Frame = Instance.new("Frame") do
			Frame.BackgroundColor3 = Color3.new(0.561,0.788,1)
			Frame.BorderColor3 = Color3.new(0,0,0)
			Frame.BorderSizePixel = 0
			Frame.Size = UDim2.new(1,0,1,0)
			Frame.ZIndex = 0
		end

		local TextButton = Instance.new("TextButton") do
			TextButton.AnchorPoint = Vector2.new(0.5,0.5)
			TextButton.BackgroundColor3 = Color3.new(0.196,0.231,0.267)
			TextButton.BorderColor3 = Color3.new(0,0,0)
			TextButton.BorderSizePixel = 0
			TextButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
			TextButton.Position = UDim2.new(0.494,0,0.769,0)
			TextButton.Size = UDim2.new(0.204,0,0.186,0)
			TextButton.Text = "Try again"
			TextButton.TextColor3 = Color3.new(1,1,1)
			TextButton.TextScaled = true
			TextButton.TextSize = 14
			TextButton.TextWrapped = true
			TextButton.ZIndex = 3
			TextButton.Parent = Frame
		end

		local UICorner = Instance.new("UICorner") do
			UICorner.CornerRadius = UDim.new(0.1,0)
			UICorner.Parent = TextButton
		end
		local ImageLabel = Instance.new("ImageLabel") do
			ImageLabel.AnchorPoint = Vector2.new(0.5,0.5)
			ImageLabel.BackgroundColor3 = Color3.new(1,1,1)
			ImageLabel.BackgroundTransparency = 1
			ImageLabel.BorderColor3 = Color3.new(0,0,0)
			ImageLabel.BorderSizePixel = 0
			ImageLabel.Image = "rbxassetid://101266206703626"
			ImageLabel.Position = UDim2.new(0.494,0,0.277,0)
			ImageLabel.Size = UDim2.new(0,230,0,223)
			ImageLabel.Parent = Frame
		end

		local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint",ImageLabel)
		local TextLabel = Instance.new("TextLabel") do
			TextLabel.BackgroundColor3 = Color3.new(1,1,1)
			TextLabel.BackgroundTransparency = 1
			TextLabel.BorderColor3 = Color3.new(0,0,0)
			TextLabel.BorderSizePixel = 0
			TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal)
			TextLabel.Position = UDim2.new(0,0,0.5,0)
			TextLabel.Size = UDim2.new(1,0,0.5,0)
			TextLabel.Text = "No Access"
			TextLabel.TextColor3 = Color3.new(1,1,1)
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14
			TextLabel.TextWrapped = true
			TextLabel.ZIndex = 2
			TextLabel.Parent = ImageLabel
		end
		TextButton.MouseButton1Click:Connect(function():()
			local VerifyAccess = Instance.new("Script")
			local try,ret = pcall(ScriptEditorService.UpdateSourceAsync,ScriptEditorService,VerifyAccess,TestAccess)
			if try==false then warn("No Script Edit Access") return end
			Frame:Destroy()
			coroutine.resume(CurrentThread)
		end)
		Frame.Parent=Widget
		coroutine.yield()
	end
	VerifyAccess:Destroy()

	--Menu
	local HierarchySaver_Settings_Connection:RBXScriptConnection = plugin.Unloading:Once(function()
		plugin:SetSetting("HierarchySaver_Settings",HttpService:JSONEncode(SessionData))
	end)
	local CurrentMainDebug_Scroll:ScrollingFrame? = nil

	local function BuildNewTempWidget():()
		if CurrentMainDebug_Scroll~=nil then return end
		local Temp:DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("Hierarchy Saver ID_Temp",DockWidgetPluginGuiInfo.new(
			Enum.InitialDockState.Float,
			false,
			false,
			400,800,100,200
			))
		Temp.Title = "Manage Hierarchy Saver Data"
		Temp.Name = "_tempMHSD"
		local MainDebug = Instance.new("Frame") do
			MainDebug.Name = "MainDebug"
			MainDebug.BackgroundColor3 = Color3.new(0.85098, 0.97255, 1)
			MainDebug.BorderColor3 = Color3.new(0, 0, 0)
			MainDebug.BorderSizePixel = 0
			MainDebug.Size = UDim2.new(1, 0, 1, 0)
		end
		--[Children] {
		local UIGradient = Instance.new("UIGradient") do
			UIGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.67843, 0.67843, 0.67843));ColorSequenceKeypoint.new(0.4481, Color3.new(0.88628, 0.88628, 0.88628));ColorSequenceKeypoint.new(1, Color3.new(63/85, 63/85, 63/85));})
			UIGradient.Rotation = 90
			UIGradient.Parent = MainDebug
		end
		local TextLabel = Instance.new("TextLabel") do
			TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
			TextLabel.BackgroundTransparency = 1
			TextLabel.BorderColor3 = Color3.new(0, 0, 0)
			TextLabel.BorderSizePixel = 0
			TextLabel.Font = Enum.Font.SourceSans
			TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			TextLabel.Position = UDim2.new(0.4995, 0, 0.1089, 0)
			TextLabel.Size = UDim2.new(0.68995, 0, 0.19129, 0)
			TextLabel.Text = "Data removal"
			TextLabel.TextColor3 = Color3.new(1, 1, 1)
			TextLabel.TextScaled = true
			TextLabel.ZIndex = 2
			TextLabel.Parent = MainDebug
		end
		--[Children] {
		local UIGradient_1 = Instance.new("UIGradient") do
			UIGradient_1.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0.67843, 0.67843, 0.67843));ColorSequenceKeypoint.new(0.06055, Color3.new(0.61961, 0.61961, 0.61961));ColorSequenceKeypoint.new(23/34, Color3.new(1, 1, 1));ColorSequenceKeypoint.new(1, Color3.new(63/85, 63/85, 63/85));})
			UIGradient_1.Rotation = 90
			UIGradient_1.Parent = TextLabel
		end
		local UIStroke = Instance.new("UIStroke") do
			UIStroke.Color = Color3.new(9/17, 9/17, 9/17)
			UIStroke.Parent = TextLabel
		end
		--}
		local Content = Instance.new("ScrollingFrame") do
			Content.Name = "Content"
			Content.Active = true
			Content.BackgroundColor3 = Color3.new(1, 1, 1)
			Content.BackgroundTransparency = 0.96
			Content.BorderColor3 = Color3.new(0, 0, 0)
			Content.BorderSizePixel = 0
			Content.Position = UDim2.new(0, 0, 0.20455, 0)
			Content.ScrollBarImageColor3 = Color3.new(0, 0, 0)
			Content.Size = UDim2.new(1, 0, 0.79545, 0)
			Content.Transparency = 0.96
			Content.ZIndex = 2
			Content.Parent = MainDebug
		end
		--[Children] {
		local UIListLayout = Instance.new("UIListLayout") do
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Parent = Content
		end
		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function():()
			Content.CanvasSize=UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
		end)
		--}
		--}
		CurrentMainDebug_Scroll=Content
		MainDebug.Parent=Temp
		Temp.Enabled=true
		local SelfDestructConnectionWidget:RBXScriptConnection
		local function DestructTemp():()
			CurrentMainDebug_Scroll=nil
			if SelfDestructConnectionWidget.Connected==true then
				SelfDestructConnectionWidget:Disconnect()
			end
			Temp:Destroy()
			Widget:SetAttribute("Manage",false)
		end
		MainDebug.Destroying:Connect(DestructTemp)
		MainDebug.DescendantRemoving:Connect(DestructTemp)
		SelfDestructConnectionWidget = Temp:GetPropertyChangedSignal("Enabled"):Once(function()
			MainDebug:Destroy()
		end)	
	end
	type local_info_temp = {
		{
			PluginData:string;
			Display:string?;
			func:(()->())?;
		}
	}
	local function BuildPropertiesTemp(info:local_info_temp):()
		if CurrentMainDebug_Scroll==nil then return end
		for i,v in info do
			--@Source StarterGui.Debug.Line --05.08.2025 - 23:13 : 24

			local Line = Instance.new("Frame") do
				Line.Name = "Line"
				Line.BackgroundColor3 = Color3.new(1, 1, 1)
				Line.BorderColor3 = Color3.new(0, 0, 0)
				Line.BorderSizePixel = 0
				Line.ClipsDescendants = true
				Line.Size = UDim2.new(1, -12, 0, 50)
				Line.ZIndex = 3
			end
			--[Children] {
			local TextLabel = Instance.new("TextLabel") do
				TextLabel.BackgroundColor3 = Color3.new(1, 1, 1)
				TextLabel.BackgroundTransparency = 1
				TextLabel.BorderColor3 = Color3.new(0, 0, 0)
				TextLabel.BorderSizePixel = 0
				TextLabel.Font = Enum.Font.SourceSans
				TextLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				TextLabel.Size = UDim2.new(0.5, 0, 1, 0)
				TextLabel.Text = v.Display or v.PluginData
				TextLabel.TextColor3 = Color3.new(0, 0, 0)
				TextLabel.TextScaled = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.ZIndex = 4
				TextLabel.Parent = Line
			end
			local TextLabel_1 = Instance.new("Frame") do
				TextLabel_1.Name = "TextLabel"
				TextLabel_1.BackgroundColor3 = Color3.new(1, 1, 1)
				TextLabel_1.BackgroundTransparency = 1
				TextLabel_1.BorderColor3 = Color3.new(0, 0, 0)
				TextLabel_1.BorderSizePixel = 0
				TextLabel_1.Position = UDim2.new(0.5, 0, 0, 0)
				TextLabel_1.Size = UDim2.new(0.5, 0, 1, 0)
				TextLabel_1.ZIndex = 4
				TextLabel_1.Parent = Line
			end
			--[Children] {
			local ImageButton = Instance.new("TextButton") do
				ImageButton.Name = "ImageButton"
				ImageButton.AnchorPoint = Vector2.new(0.5, 0.5)
				ImageButton.BackgroundColor3 = Color3.new(1, 0, 0)
				ImageButton.BorderColor3 = Color3.new(0, 0, 0)
				ImageButton.BorderSizePixel = 0
				ImageButton.Position = UDim2.new(0.5, 0, 0.5, 0)
				ImageButton.Size = UDim2.new(1, 0, 1, 0)
				ImageButton.Text = "X"
				ImageButton.TextColor3 = Color3.new(1, 1, 1)
				ImageButton.TextScaled = true
				ImageButton.TextSize = 20
				ImageButton.TextWrapped = true
				ImageButton.ZIndex = 5
				ImageButton.Parent = TextLabel_1
			end
			--[Children] {
			local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint") do
				UIAspectRatioConstraint.AspectRatio = 1.5
				UIAspectRatioConstraint.Parent = ImageButton
			end
			local UICorner = Instance.new("UICorner") do
				UICorner.CornerRadius = UDim.new(0.25, 0)
				UICorner.Parent = ImageButton
			end
			--}
			local Removed = Instance.new("TextLabel") do
				Removed.Name = "Removed"
				Removed.AnchorPoint = Vector2.new(1, 0.5)
				Removed.BackgroundColor3 = Color3.new(1, 1, 1)
				Removed.BackgroundTransparency = 1
				Removed.BorderColor3 = Color3.new(0, 0, 0)
				Removed.BorderSizePixel = 0
				Removed.Font = Enum.Font.SourceSans
				Removed.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
				Removed.Position = UDim2.new(1, 0, 0.5, 0)
				Removed.Size = UDim2.new(1, 0, 1, 0)
				Removed.Text = ""
				Removed.TextColor3 = Color3.new(0, 1, 0)
				Removed.TextScaled = true
				Removed.ZIndex = 5
				Removed.Parent = TextLabel_1
			end
			--[Children] {
			local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint", Removed)
			--}
			--}
			local UICorner_1 = Instance.new("UICorner") do
				UICorner_1.CornerRadius = UDim.new(0.2, 0)
				UICorner_1.Parent = Line
			end
			--}

			ImageButton.MouseButton1Click:Once(function():()
				plugin:SetSetting(v.PluginData,nil)
				if v.func~=nil then
					(v.func::()->())()
				end
				Removed.Text="•"
			end)
			Line.Parent=CurrentMainDebug_Scroll
		end
	end

	_G.HierarchySaverImport = function(json:string):()
		local try,ret = pcall(HttpService.JSONDecode,HttpService,json)
		if not try then warn(ret) return end
		for i,v in ret::{[string]:string} do
			plugin:SetSetting(i,v)
		end
		if HierarchySaver_Settings_Connection.Connected==true then
			HierarchySaver_Settings_Connection:Disconnect()
		end
		warn("Settings applied ✅. Please restart studio.")
	end

	local SaveStr:{string} = {"NE_BaseImports";"NE_pathMacro";"NE_cachedConstants";"NE_IgnoreProperties"}
	local function __ExportData():()
		local script = Instance.new("Script")
		script.Archivable=false
		script.Name = `Export_{LocalUserName}`
		script.Enabled=false
		script.Parent=game
		local try,err = ScriptEditorService:OpenScriptDocumentAsync(script)
		if try == false then script:Destroy() return end
		Heartbeat:Wait()
		local ret = ScriptEditorService:FindScriptDocument(script)::ScriptDocument?
		if ret==nil then warn("Unable to find script document") return end
		local data = {
			["HierarchySaver_Settings"] = HttpService:JSONDecode(plugin:GetSetting("HierarchySaver_Settings")::string? or "{}") or {}
		}
		for _,v in SaveStr do
			data[v] = plugin:GetSetting(v)::string? or ""
		end
		ret:EditTextAsync(`_G.HierarchySaverImport([[{HttpService:JSONEncode(data)}]])`,1,1,1,-1)
		Selection:Set({script})
	end

	local function ExportData():()
		local Line = Instance.new("TextButton") do
			Line.Name = "Line"
			Line.BackgroundColor3 = Color3.new(1, 1, 0)
			Line.BorderColor3 = Color3.new(0, 0, 0)
			Line.BorderSizePixel = 0
			Line.ClipsDescendants = true
			Line.Size = UDim2.new(1, -12, 0, 50)
			Line.ZIndex = 3
			Line.Text = "Export Data"
			Line.TextScaled=true
		end
		Line.MouseButton1Click:Connect(__ExportData)
		Line.Parent=CurrentMainDebug_Scroll
	end


	local info:local_info_temp = {
		{
			PluginData = "HierarchySaver_Settings";
			Display = "HierarchySaver Settings";
			func = function():()
				if HierarchySaver_Settings_Connection.Connected==true then
					HierarchySaver_Settings_Connection:Disconnect()
				end
			end;
		};
		{PluginData="NE_BaseImports"};
		{PluginData="NE_pathMacro"};
		{PluginData="NE_cachedConstants"};
		{PluginData="NE_IgnoreProperties"};
		{PluginData="HierarchySaver_CLASSES"};
		{PluginData="Classes_LatestCache_Valid"};
	}
	Widget:GetAttributeChangedSignal("Manage"):Connect(function():()
		if Widget:GetAttribute("Manage") == false then if CurrentMainDebug_Scroll~=nil then CurrentMainDebug_Scroll:Destroy() end return end
		BuildNewTempWidget()
		ExportData()
		BuildPropertiesTemp(info)
	end)
end)()




--Elements
local Elements = script:WaitForChild("Components")
local TabButton = Elements:WaitForChild("TabButton")--Button to open tab
local TabNameHere = Elements:WaitForChild("TabNameHere")--Tab itself
local ErrorHTTP_UI = Elements:WaitForChild("ErrorHTTP_UI")
local LightThemeColor_List:{Frame} = table.create(3)::{Frame}
local Tab_EnumColor_List:{Frame} = table.create(1)::{Frame}
local ScriptWhitespaceColorList_FOR_UI_STROKE:{UIStroke} = table.create(3)::{UIStroke}
local TextButtons_Theme:{TextLabel|TextBox|TextButton} = table.create(20)::{TextLabel|TextBox|TextButton}
local BrightestText_Theme:{TextLabel|TextBox|TextButton|ImageLabel|ImageButton} = table.create(10)::{TextLabel|TextBox|TextButton|ImageLabel|ImageButton}
--Display
local Main = script:WaitForChild("Main")
local LowerBar = Main:WaitForChild("LowerBar")
local UpperBar = Main:WaitForChild("UpperBar")
local ViewTabs = Main:WaitForChild("ViewTabs")

local Ignored_Properies = Main:WaitForChild("IgnoredProperties")
local Hint = Main:WaitForChild("Hint")
local Hint_Label = Hint:WaitForChild("Label")
table.insert(TextButtons_Theme,LowerBar:WaitForChild("Credit")::TextLabel)
table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Hint:WaitForChild("UIStroke")::UIStroke)
table.insert(Tab_EnumColor_List,Hint)
table.insert(TextButtons_Theme,Hint_Label)
table.insert(LightThemeColor_List,UpperBar)
table.insert(LightThemeColor_List,ViewTabs)

--Lists
local TabViewports:{Frame} = {}

--*********************CONSTANTS
local Thickness = 16--In pixels
local SliderResponsivenessTime = 1
local ScrollSpeed = 5.5
local Button_SlideBy_Y = Vector2.new(0,15)
local Button_SlideBy_X = Vector2.new(15,0)
local Rect_zero = Rect.new()
local UDim2_one = UDim2.new(1,0,1,0)
local UDim2_one_List = UDim2.new(1,-2,1,-1)
local UDim2_zero = UDim2.new(0,0,0,0)
local Property_Y_SizePX = 24
--Elements 2
local Property = Elements:WaitForChild("Property")
local PropertyBox = Elements:WaitForChild("PropertiesBox")
local EmptyProperty = Elements:WaitForChild("EmptyProperty")
local Category = Elements:WaitForChild("Category")
local Property_Input = Elements:WaitForChild("Input")
local Property_Boolean = Elements:WaitForChild("Boolean")
local Collapse = Elements:WaitForChild("Collapse")
local Property_NumberRange = Elements:WaitForChild("NumberRange")
local Property_EnumList = Elements:WaitForChild("EnumList")
local Property_EnumList_Sample = Elements:WaitForChild("EnumListSample")
local CodeOutput = Elements:WaitForChild("CodeOutput")

--Configs
local Y_heightPX = UDim2.new(1,0,0,Property_Y_SizePX)
local Y_height23_SUBSTRACTED = UDim2.new(1,0,0,Property_Y_SizePX-1)
Property.Size=Y_heightPX
EmptyProperty.Size=Y_heightPX
PropertyBox.Size=Y_heightPX
Category.Size=Y_heightPX

local HashMapLevel:{
	[GuiObject]:{[GuiObject]:number}	
} = {}
local function HashMapLevelScan_Func(TrueParent:GuiObject):()
	if HashMapLevel[TrueParent]==nil then return end
	local max:number = 0
	for i,v in HashMapLevel[TrueParent] do
		local object:GuiObject = i
		while object~=TrueParent and object.Visible==true do
			object=object.Parent::GuiObject
		end
		if object.Visible==false then continue end
		if v>max then max=v end
	end
	TrueParent:SetAttribute("MaxSize",(max~=0 and max) or nil)
end

--Theme handler
local _settings:any = settings()
local _studio = _settings.Studio::Studio
local Studio:Studio = _studio::Studio
local _theme:any = Studio.Theme
local StudioTheme = _theme::StudioTheme
local Checkmarks:{TextButton} = table.create(15)::{TextButton}
local Properties_ItemColor:{GuiObject} = table.create(15)::{GuiObject}
local UI_Strokes:{UIStroke} = table.create(15)::{UIStroke}


local ItemColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Item)
local ItemColor_Hover:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Item,Enum.StudioStyleGuideModifier.Hover)
local ItemColor_Selected:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Item,Enum.StudioStyleGuideModifier.Selected)

local ViewPortBackground:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground)

local TextColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainText)
local TextColor_Selected:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainText,Enum.StudioStyleGuideModifier.Selected)
local TextLittleGreyColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DiffFilePathText)

local CategoryItem:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.CategoryItem)
local CategoryList:{TextButton} = table.create(10)::{TextButton}

local TextLittleGreyColorList:{TextButton} = table.create(15)::{TextButton}


local CollapserColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ChatOutgoingTextColor)
local CollapserColor_List:{ImageLabel|ImageButton} = table.create(10)::{ImageLabel|ImageButton}
local CollapserColor_Lighter:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.AttributeCog)
local CollapserColor_Lighter_List:{ImageLabel} = table.create(10)::{ImageLabel}

local DialogColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DialogButton)
local DialogColor_Hover:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DialogButton,Enum.StudioStyleGuideModifier.Hover)
local DialogColorList:{TextButton} = table.create(5)::{TextButton}
local ItemHoverList:{ImageButton} = table.create(10)::{ImageButton}
local ScriptWhitespaceColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptWhitespace)
local ScriptWhitespaceColorList:{TextButton} = table.create(5)::{TextButton}

local ScrollBar_Color:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBar)
local ScrollBar_Color_Hover:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBar,Enum.StudioStyleGuideModifier.Hover)
local ScrollingFramesScrollBar:{ScrollingFrame} = table.create(3)::{ScrollingFrame}
local ScrollbarButtons:{ImageButton} = table.create(12)::{ImageButton}
local MainBackground:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
local MainBackground_List:{TextButton} = table.create(3)::{TextButton}
local ScrollBarBackground:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground)
local InputFieldBorder:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder)
local InputFieldBorder_List:{Frame} = table.create(1)::{Frame}
local ScriptBackground:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBackground)
local ScriptBackground_List:{GuiObject} = table.create(1)::{GuiObject}
local ScriptTextColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptText)
local ScriptTextColor_List:{TextLabel|TextBox} = table.create(1)::{TextLabel|TextBox}
local Tab_EnumColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Tab)
local BorderColorUI_StrokeList:{UIStroke} = table.create(6)::{UIStroke}

--SCRIPT EDITOR
local ScriptComment:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptComment)
local ScriptBool:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBool)
local ScriptFunction:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptFunction)
local ScriptFunctionName:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptFunctionName)
local ScriptMethod:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptMethod)
local ScriptLuauKeyword:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptLuauKeyword)
local ScriptLocal:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptLocal)
local ScriptNil:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptNil)
local ScriptNumber:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptNumber)
local ScriptSelf:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptSelf)
local ScriptString:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptString)
local ScriptBuiltInFunction:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBuiltInFunction)
local ScriptProperty:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptProperty)
---
local LightThemeColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Light)

local ScriptComment_List:{TextLabel} = table.create(1)::{TextLabel}

--NumberRange
local SelectedValue:Frame? = nil
local SelectedNumberRange:Frame? = nil

--EnumValueContainer
local SelectedContainer:Frame? = nil
--
local SelectedTarget:GuiObject? = nil
local SelectedClicks:number = 0


local function ThemeChanged():()
	local _theme:any = Studio.Theme
	StudioTheme = _theme::StudioTheme
	--Updating colors
	TextColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainText)
	TextColor_Selected = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainText,Enum.StudioStyleGuideModifier.Selected)
	TextLittleGreyColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DiffFilePathText)

	local BrightText:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.BrightText)
	local Mid:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Mid)
	local BorderColor:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Border)
	ItemColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Item)
	ItemColor_Hover = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Item,Enum.StudioStyleGuideModifier.Hover)
	ItemColor_Selected = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Item,Enum.StudioStyleGuideModifier.Selected)
	ViewPortBackground = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ViewPortBackground)
	CategoryItem = StudioTheme:GetColor(Enum.StudioStyleGuideColor.CategoryItem)
	CollapserColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ChatOutgoingTextColor)
	CollapserColor_Lighter = StudioTheme:GetColor(Enum.StudioStyleGuideColor.AttributeCog)
	DialogColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DialogButton)
	DialogColor_Hover = StudioTheme:GetColor(Enum.StudioStyleGuideColor.DialogButton,Enum.StudioStyleGuideModifier.Hover)
	ScriptWhitespaceColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptWhitespace)
	ScrollBar_Color = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBar)
	ScrollBar_Color_Hover = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBar,Enum.StudioStyleGuideModifier.Hover)
	MainBackground = StudioTheme:GetColor(Enum.StudioStyleGuideColor.MainBackground)
	ScrollBarBackground = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScrollBarBackground)
	InputFieldBorder = StudioTheme:GetColor(Enum.StudioStyleGuideColor.InputFieldBorder)
	ScriptBackground = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBackground)
	ScriptTextColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptText)
	ScriptComment = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptComment)
	ScriptBool = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBool)
	ScriptFunction = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptFunction)
	ScriptFunctionName = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptFunctionName)
	ScriptMethod = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptMethod)
	ScriptLuauKeyword = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptLuauKeyword)
	ScriptLocal = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptLocal)
	ScriptNil = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptNil)
	ScriptNumber = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptNumber)
	ScriptSelf = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptSelf)
	ScriptString = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptString)
	ScriptBuiltInFunction = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptBuiltInFunction)
	ScriptProperty = StudioTheme:GetColor(Enum.StudioStyleGuideColor.ScriptProperty)
	-------------
	LightThemeColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Light)
	Tab_EnumColor = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Tab)
	for i,v in BrightestText_Theme do
		if v:IsA("ImageLabel") or v:IsA("ImageButton") then
			v.ImageColor3=BrightText
			continue
		end
		v.TextColor3=BrightText
	end
	for i,v in BorderColorUI_StrokeList do
		v.Color = BorderColor
	end
	for i,v in Tab_EnumColor_List do
		v.BackgroundColor3=Tab_EnumColor
	end
	for i,v in LightThemeColor_List do
		v.BackgroundColor3=LightThemeColor
	end
	for i,v in ScriptComment_List do
		v.TextColor3=ScriptComment
	end
	for i,v in ScriptTextColor_List do
		v.TextColor3=ScriptTextColor
	end
	for i,v in ScriptBackground_List do
		v.BackgroundColor3=ScriptBackground
	end
	for i,v in InputFieldBorder_List do
		v.BackgroundColor3=InputFieldBorder
	end
	for i,v in MainBackground_List do
		v.BackgroundColor3=MainBackground
	end
	for i,v in ScrollbarButtons do
		v.BackgroundColor3=ScrollBar_Color
		v.BorderColor3=Mid
	end
	for i,v in ScrollingFramesScrollBar do
		v.ScrollBarImageColor3=ScrollBar_Color
		v.BackgroundColor3=ScrollBarBackground
	end
	for i,v in ScriptWhitespaceColorList do
		v.BackgroundColor3=ScriptWhitespaceColor
	end
	for i,v in ScriptWhitespaceColorList_FOR_UI_STROKE do
		v.Color=ScriptWhitespaceColor
	end
	for i,v in ItemHoverList do
		v.BackgroundColor3 = ItemColor_Hover
	end
	for i,v in DialogColorList do
		v.BackgroundColor3=DialogColor
	end
	for i,v in CollapserColor_Lighter_List do
		v.ImageColor3=CollapserColor_Lighter
	end
	for i,v in CollapserColor_List do
		v.ImageColor3=CollapserColor
	end
	for i,v in TextLittleGreyColorList do
		v.TextColor3=TextLittleGreyColor
	end
	for i,v in CategoryList do
		v.BackgroundColor3=CategoryItem
	end
	for i,v in Properties_ItemColor do
		if v:GetAttribute("Selected")==true then v.BackgroundColor3=ItemColor_Selected continue end
		if v:GetAttribute("Enabled")==true then v.BackgroundColor3=ViewPortBackground continue end		
		v.BackgroundColor3=ItemColor
	end
	for i,v in TextButtons_Theme do
		if v:GetAttribute("Selected") then v.TextColor3=TextColor_Selected continue end
		v.TextColor3=TextColor
	end
	for i,v in UI_Strokes do
		v.Color=Mid
	end
end
table.insert(InputFieldBorder_List,LowerBar)
local LowerBar_Convert = LowerBar:WaitForChild("Convert")::TextButton
local LowerBar_Convert_Label = LowerBar_Convert:WaitForChild("Label")::TextLabel
table.insert(TextButtons_Theme,LowerBar_Convert_Label)
local LowerBar_Convert_Leave = TweenService:Create(LowerBar_Convert_Label,TweenInfo.new(0.175,Enum.EasingStyle.Back),{Size=UDim2_one})
local LowerBar_Convert_Enter = TweenService:Create(LowerBar_Convert_Label,TweenInfo.new(0.25,Enum.EasingStyle.Quart),{Size=UDim2.new(0.9,0,0.95,0)})
local LowerBar_Convert_Color_Leave:Color3 = Color3.new(0.2, 0.372549, 1)
local LowerBar_Convert_Color_Enter:Color3 = Color3.new(0.133333, 0.25098, 0.670588)
local LowerBar_Convert_Color_Click:Color3 = Color3.new(0.0588235, 0.109804, 0.290196)
local LowerBar_Convert_IsEntered:boolean = false
LowerBar_Convert.MouseEnter:Connect(function()
	LowerBar_Convert_Enter:Play()
	LowerBar_Convert_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
	LowerBar_Convert_IsEntered=true
end)
LowerBar_Convert.MouseLeave:Connect(function()
	LowerBar_Convert_Leave:Play()
	LowerBar_Convert_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
	LowerBar_Convert_IsEntered=false
end)
LowerBar_Convert.MouseButton1Down:Connect(function()
	LowerBar_Convert_Label.BackgroundColor3=LowerBar_Convert_Color_Click
end)
LowerBar_Convert.MouseButton1Up:Connect(function()
	if LowerBar_Convert_IsEntered then
		LowerBar_Convert_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
	else
		LowerBar_Convert_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
	end
end)


local function HideHint():()
	Hint.Visible=false
end
local function RemoveSelectionButton():()
	HideHint()
	if SelectedValue~=nil then
		SelectedValue.BackgroundTransparency=1
		SelectedValue=nil
	end
	if SelectedNumberRange~=nil then
		SelectedNumberRange.BackgroundTransparency=1
		SelectedNumberRange=nil
	end
	if SelectedContainer~=nil then
		SelectedContainer.Visible=false
		SelectedContainer=nil
	end
	if SelectedTarget==nil then return end
	SelectedTarget:SetAttribute("Selected",nil)
	if SelectedTarget:GetAttribute("Enabled")==true then SelectedTarget.BackgroundColor3=ViewPortBackground return end		
	SelectedTarget.BackgroundColor3=ItemColor
	SelectedTarget=nil
	SelectedClicks=0
end
local function SetSelectionButton(Button:GuiObject):()
	if Button==SelectedTarget then SelectedClicks+=1 return end
	Button.BackgroundColor3=ItemColor_Selected
	Button:SetAttribute("Selected",true)
	SelectedTarget=Button
end
local function CaptureFocusFunc(ins:TextBox):()
	if SelectedClicks>=1 then
		ins:CaptureFocus()
	end
end


local connection = Studio.ThemeChanged:Connect(ThemeChanged)
plugin.Unloading:Once(function()
	connection:Disconnect()
end)

--********************* Tab related functions

--Deletes Tab
local function DeleteTab(Name:string):()
	local Upper,Tab = UpperBar:FindFirstChild(Name),ViewTabs:FindFirstChild(Name)
	if Upper~=nil then
		Upper:Destroy()
	end
	if Tab~=nil then
		Tab:Destroy()
	end
end
local CurrentConvertType:string = ss.___CurrentConvertType::string? or "Nestify"
local function SelectButtonByName(name:string):()
	SessionData.___CurrentTab = name
	ss.___CurrentTab = name
	local button = UpperBar:FindFirstChild(name)::Frame?
	local viewport = ViewTabs:FindFirstChild(name)::Frame?
	for i,v in TabViewports do
		if v==viewport then continue end
		v.Visible = false
	end
	for i,v in UpperBar:GetChildren() do
		if v==button then continue end
		if not v:IsA("Frame") then continue end
		v:SetAttribute("Enabled",false)
		v.BackgroundColor3=ItemColor
	end
	if viewport~=nil then viewport.Visible=true end
	if button~=nil then
		button:SetAttribute("Enabled",true)
		button.BackgroundColor3=ViewPortBackground
	end
	RemoveSelectionButton()
	if name~="Converted Code" and name~="Shared Settings" then
		SessionData.___CurrentConvertType = name
		ss.___CurrentConvertType = name
		CurrentConvertType = name
	end
end
local OnConvert:BindableEvent = Instance.new("BindableEvent")
local UncollapseCategoryies:BindableEvent = Instance.new("BindableEvent")
local AllPropertyRelatives:{[TextLabel]:GuiObject} = {}--TextLabel.Text -> Target
do
	local SearchKeybind = plugin:CreatePluginAction("NE_StartSearch","Search","Search for property","rbxassetid://98396137856895",true)
	SearchKeybind.Name = "Search for property"
	local CancelKeybind = plugin:CreatePluginAction("NE_CancelSearch","Cancel Search","Cancel Search for property","rbxassetid://98396137856895",true)
	CancelKeybind.Name = "Cancel Search for property"
	local SearchBox = Main:WaitForChild("Search")::TextBox
	local SearchButton = LowerBar:WaitForChild("Search")
	local CancelSearch = SearchButton:WaitForChild("Cancel")
	local AspectRatioSearchButton:UIAspectRatioConstraint? = Instance.new("UIAspectRatioConstraint",SearchButton)
	CancelSearch:SetAttribute("Enabled",true)
	SearchButton:SetAttribute("Enabled",true)
	SearchBox:SetAttribute("Enabled",true)
	table.insert(Properties_ItemColor,CancelSearch)
	table.insert(Properties_ItemColor,SearchButton)
	table.insert(Properties_ItemColor,SearchBox)
	--text
	table.insert(BrightestText_Theme,SearchButton)
	table.insert(BrightestText_Theme,SearchBox)
	local function BegginTheSearch():()
		if SearchBox.Visible==true then return end
		SearchBox.Visible = true
		if AspectRatioSearchButton~=nil then AspectRatioSearchButton:Destroy() end
		AspectRatioSearchButton=nil
		SearchBox:CaptureFocus()
		CancelSearch.Visible = true
	end
	local function CancelTheSearch():()
		SearchBox.Visible = false
		SearchButton.Text="🔍"
		SearchBox.Text = ""
		CancelSearch.Visible = false
		if AspectRatioSearchButton~=nil then AspectRatioSearchButton:Destroy() end
		AspectRatioSearchButton = Instance.new("UIAspectRatioConstraint",SearchButton)
	end
	SearchBox.FocusLost:Connect(function()
		SearchBox.Visible = false
		if SearchBox.Text=="" then
			CancelTheSearch()
		end
	end)
	SearchBox:GetPropertyChangedSignal("Text"):Connect(function():()
		UncollapseCategoryies:Fire()
		local txt:string = string.lower(SearchBox.Text)
		if SearchBox.Visible==true then
			SearchButton.Text=txt
		end
		if txt=="" then
			for i,v in AllPropertyRelatives do
				v.Visible = true
			end
		else
			for i,v in AllPropertyRelatives do
				v.Visible = false
			end
			for i,v in AllPropertyRelatives do
				if string.find(string.lower(i.Text),txt)~=nil then
					v.Visible=true
				end
			end
		end
	end)
	CancelKeybind.Triggered:Connect(CancelTheSearch)
	CancelSearch.MouseButton1Click:Connect(CancelTheSearch)
	SearchKeybind.Triggered:Connect(BegginTheSearch)
	SearchButton.MouseButton1Click:Connect(BegginTheSearch)
end
plugin.Unloading:Once(function()
	OnConvert:Destroy()
	UncollapseCategoryies:Destroy()
end)

local TabIndex:number = 0
-- Returns New window and container for this window!
local function CreateTab(Name:string,Icon:string):(Frame,TextButton)
	--Grabbing elements
	local Tab_Button = TabButton:Clone()
	local Tab = TabNameHere:Clone()
	table.insert(Properties_ItemColor,Tab_Button)
	--Initialization
	--Button
	local ImageButton = Tab_Button.ImageButton
	local TextButton = Tab_Button.TextButton
	Tab_Button.Name=Name
	ImageButton.Image=Icon
	TextButton.Text=Name
	Tab_Button.Visible=true
	table.insert(TextButtons_Theme,TextButton)
	local function HideButtons():()
		SelectButtonByName(Name)
	end
	Tab_Button.MouseEnter:Connect(function()
		Tab_Button.BackgroundColor3=ViewPortBackground
	end)
	Tab_Button.MouseLeave:Connect(function()
		if Tab_Button:GetAttribute("Enabled")==true then return end
		Tab_Button.BackgroundColor3=ItemColor
	end)
	ImageButton.MouseButton1Click:Connect(HideButtons)
	TextButton.MouseButton1Click:Connect(HideButtons)

	--Tab
	Tab.Name=Name
	local Tab_Scroll = Tab.Scroll
	local Tab_Left = Tab.Left
	local Tab_Upper = Tab.Upper
	local Tab_Lower = Tab.Lower
	local Tab_Right = Tab.Right
	table.insert(CollapserColor_Lighter_List,Tab_Left)
	table.insert(CollapserColor_Lighter_List,Tab_Right)
	table.insert(CollapserColor_Lighter_List,Tab_Lower)
	table.insert(CollapserColor_Lighter_List,Tab_Upper)
	local List = Tab_Scroll.List
	local List_Layout = List.UIListLayout
	local Bottom_Outline = Tab.Bottom_Outline
	local Right_Outline = Tab.Right_Outline
	Bottom_Outline.Size = UDim2.new(1,0,0.0000001,Thickness)--Hack to make it draw over scrollbar
	table.insert(BorderColorUI_StrokeList,Bottom_Outline:WaitForChild("UIStroke")::UIStroke)
	Right_Outline.Size = UDim2.new(0.0000001,Thickness,1,0)--Hack to make it draw over scrollbar
	table.insert(BorderColorUI_StrokeList,Right_Outline:WaitForChild("UIStroke")::UIStroke)
	table.insert(ScrollingFramesScrollBar,Tab_Scroll)
	table.insert(MainBackground_List,List)
	table.insert(ScrollbarButtons,Tab_Left)
	table.insert(ScrollbarButtons,Tab_Right)
	table.insert(ScrollbarButtons,Tab_Upper)
	table.insert(ScrollbarButtons,Tab_Lower)
	local ButtonHover:boolean = false
	Tab_Right:GetPropertyChangedSignal("Visible"):Connect(function()
		Bottom_Outline.Visible=Tab_Right.Visible
	end)
	Tab_Lower:GetPropertyChangedSignal("Visible"):Connect(function()
		Right_Outline.Visible=Tab_Lower.Visible
	end)
	Bottom_Outline.Visible=Tab_Right.Visible
	Right_Outline.Visible=Tab_Lower.Visible
	Tab_Left.MouseEnter:Connect(function()
		ButtonHover=true
		Tab_Left.BackgroundColor3=ScrollBar_Color_Hover
		Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
	end)
	Tab_Right.MouseEnter:Connect(function()
		ButtonHover=true
		Tab_Right.BackgroundColor3=ScrollBar_Color_Hover
		Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
	end)
	Tab_Upper.MouseEnter:Connect(function()
		ButtonHover=true
		Tab_Upper.BackgroundColor3=ScrollBar_Color_Hover
		Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
	end)
	Tab_Lower.MouseEnter:Connect(function()
		ButtonHover=true
		Tab_Lower.BackgroundColor3=ScrollBar_Color_Hover
		Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
	end)

	Tab_Left.MouseLeave:Connect(function()
		ButtonHover=false
		Tab_Left.BackgroundColor3=ScrollBar_Color
	end)
	Tab_Right.MouseLeave:Connect(function()
		ButtonHover=false
		Tab_Right.BackgroundColor3=ScrollBar_Color
	end)
	Tab_Upper.MouseLeave:Connect(function()
		ButtonHover=false
		Tab_Upper.BackgroundColor3=ScrollBar_Color
	end)
	Tab_Lower.MouseLeave:Connect(function()
		ButtonHover=false
		Tab_Lower.BackgroundColor3=ScrollBar_Color
	end)



	local HighlightedScrollbar:boolean = false
	Tab.MouseLeave:Connect(function():()
		if Tab.Visible==false or not HighlightedScrollbar then return end
		Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
		HighlightedScrollbar=false
	end)
	Tab.MouseMoved:Connect(function():()
		if Tab.Visible==false or ButtonHover then return end
		local AbsoluteSize_Y:number = UpperBar.AbsoluteSize.Y+ViewTabs.AbsoluteSize.Y
		local BarThickness:number = Tab_Scroll.ScrollBarThickness
		local mouse:Vector2 =  Widget:GetRelativeMousePosition()
		local mouse_X,mouse_Y:number = mouse.X,mouse.Y
		if Tab_Right.Visible==true and Tab_Lower.Visible==true then
			if mouse_Y>AbsoluteSize_Y-BarThickness or mouse_X>ViewTabs.AbsoluteSize.X-BarThickness then
				Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color_Hover
				HighlightedScrollbar=true
			else
				Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
				HighlightedScrollbar=false
			end
		elseif Tab.Right.Visible==true then
			if mouse_Y>AbsoluteSize_Y-BarThickness then
				Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color_Hover
				HighlightedScrollbar=true
			else
				Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
				HighlightedScrollbar=false
			end
		elseif Tab_Lower.Visible == true then
			if mouse_X>ViewTabs.AbsoluteSize.X-BarThickness then
				Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color_Hover
				HighlightedScrollbar=true
			else
				Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
				HighlightedScrollbar=false
			end
		elseif HighlightedScrollbar then
			Tab_Scroll.ScrollBarImageColor3=ScrollBar_Color
			HighlightedScrollbar=false
		end

	end)

	List.MouseButton1Click:Connect(RemoveSelectionButton)

	--local function ScaleProperties()
	--	local AbsoluteWindowSize = Tab_Scroll.AbsoluteWindowSize
	--	local CanvasSize = Tab_Scroll.CanvasSize
	--	local Size = UDim2.new(0,Tab_Scroll.AbsoluteSize.X-((CanvasSize.Y.Offset>AbsoluteWindowSize.Y and Thickness) or 0)-2,0,Property_Y_SizePX)
	--	local FrameSize = UDim2.new(1,0,0,Property_Y_SizePX)
	--	for i,v in List:GetChildren() do
	--		if not v:IsA("GuiObject") then continue end
	--		v.Size=FrameSize
	--		local Content_Frame = v:FindFirstChild("Content")::Frame?
	--		if Content_Frame==nil then continue end
	--		Content_Frame.Size=Size
	--	end
	--end

	local function VisualizeSliders():()
		if not Tab.Visible then return end
		local AbsoluteWindowSize = Tab_Scroll.AbsoluteWindowSize
		local CanvasSize = Tab_Scroll.CanvasSize
		if CanvasSize.Y.Offset>AbsoluteWindowSize.Y and CanvasSize.X.Offset>AbsoluteWindowSize.X then
			Tab_Upper.Visible=true;Tab_Lower.Visible=true;Tab_Right.Visible=true;Tab_Left.Visible=true
			List.Size=UDim2_one_List
			Tab_Right.Position=UDim2.new(1,-Tab.Right.Size.X.Offset,1,0)
			Tab_Lower.Position=UDim2.new(1,0,1,-Tab_Lower.Size.Y.Offset)
		elseif CanvasSize.Y.Offset>AbsoluteWindowSize.Y then
			Tab_Right.Visible=false;Tab_Left.Visible=false
			if Tab_Scroll.CanvasPosition.X~=0 then
				Tab_Scroll.CanvasPosition-=Vector2.new(Tab_Scroll.CanvasPosition.X::number,0)
			end
			Tab_Lower.Position=UDim2_one
			Tab_Upper.Visible=true;Tab_Lower.Visible=true;
			List.Size=UDim2.new(0,Tab_Scroll.AbsoluteSize.X-Thickness-2,1,-1)
		elseif CanvasSize.X.Offset>AbsoluteWindowSize.X then
			Tab_Upper.Visible=false;Tab_Lower.Visible=false;
			Tab_Right.Position=UDim2_one
			Tab_Right.Visible=true;Tab_Left.Visible=true
			List.Size=UDim2_one_List
		else
			if Tab_Scroll.CanvasPosition.X~=0 then
				Tab_Scroll.CanvasPosition-=Vector2.new(Tab_Scroll.CanvasPosition.X::number,0)
			end
			Tab_Upper.Visible=false;Tab_Lower.Visible=false;Tab_Right.Visible=false;Tab_Left.Visible=false
			List.Size=UDim2_one_List	
		end
	end
	local function ScaleCanvas():()
		if not Tab.Visible then return end
		local highestX:number = 0
		local sumY:number = 0
		local AbsoluteWindowSize = Tab_Scroll.AbsoluteWindowSize
		local CanvasSize = Tab_Scroll.CanvasSize
		local Size = UDim2.new(0,Tab_Scroll.AbsoluteSize.X-((CanvasSize.Y.Offset>AbsoluteWindowSize.Y and Thickness) or 0)-2,1,0)
		--local FrameSize = UDim2.new(1,0,0,Property_Y_SizePX)
		for i,v in List:GetChildren() do
			if not v:IsA("GuiObject") or v:GetAttribute("NoScale")==true then continue end
			HashMapLevelScan_Func(v)
			if v:GetAttribute("YSize")~=nil then
				v.Size=UDim2.new(1,0,0,v:GetAttribute("YSize")::number)
			else
				v.Size=Y_heightPX
			end
			local Content_Frame = v:FindFirstChild("Content")::Frame?
			if Content_Frame==nil then continue end
			Content_Frame.Size=Size
		end
		local Size_X_Offset = Size.X.Offset

		for i,v in List:GetChildren() do
			if not v:IsA("GuiObject") or not v:IsA("GuiBase2d") or v.Visible==false then continue end
			sumY+=v.AbsoluteSize.Y
			local MaxSize:number? = (tonumber(v:GetAttribute("MaxSize")::number?)~=nil and (tonumber(v:GetAttribute("MaxSize")::number?)::number)+(Size_X_Offset*0.5)) or nil
			--local v_Content = v:FindFirstChild("Content")::Frame?
			if MaxSize==nil or (Size_X_Offset>=(MaxSize or 0)) then

				--if v_Content==nil then continue end
				MaxSize=Size_X_Offset
			end
			if MaxSize::number>highestX then highestX=MaxSize::number end
		end
		highestX=math.min(highestX,10_000)--10k pixels limit
		local Size_X_Offset = Size.X.Offset
		List:SetAttribute("Offset_True_X",Size_X_Offset)
		List:SetAttribute("HighestX",highestX)
		local scaled = UDim2.new(0,highestX-(Size_X_Offset*0.5)+((Size_X_Offset<highestX and 6) or 0),1,0)
		for i,v in List:GetChildren() do
			if not v:IsA("GuiObject") then continue end
			local v_Content = v:FindFirstChild("Content")::Frame?
			if v_Content==nil then continue end
			local value = v_Content:FindFirstChild("Value")::Frame?
			if value==nil then continue end
			value.Size=scaled

		end
		Tab_Scroll.CanvasSize=UDim2.new(0,highestX+1--[[+2+((Size_X_Offset<highestX and 6) or 0)+((sumY>AbsoluteWindowSize.Y and -1) or 0)]],0,sumY+2)
		VisualizeSliders()
	end

	local Scaled = UDim2.new(0.0000001,Thickness,0.0000001,Thickness)--Hack (yet again to make it scale properly)
	Tab_Scroll.ScrollBarThickness=Thickness
	Tab_Upper.Size=Scaled
	Tab_Lower.Size=Scaled
	Tab_Left.Size=Scaled
	Tab_Right.Size=Scaled
	local CanvasScaleUpdater = Instance.new("BindableEvent")
	CanvasScaleUpdater.Event:Connect(ScaleCanvas)
	CanvasScaleUpdater.Name="Updater"
	CanvasScaleUpdater.Parent=List

	Tab:GetPropertyChangedSignal("Visible"):Connect(function()
		if not Tab.Visible then return end
		ScaleCanvas()
	end)
	--List:GetPropertyChangedSignal("AbsoluteSize"):Connect(ScaleProperties)
	--Tab_Scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(VisualizeSliders)
	List_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ScaleCanvas)
	Tab_Scroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(ScaleCanvas)
	--ScaleProperties()
	local Lower_DB:boolean = false
	local Upper_DB:boolean = false
	local Right_DB:boolean = false
	local Left_DB:boolean = false
	local function Release():()
		Lower_DB = false
		Upper_DB = false
		Right_DB = false
		Left_DB = false
	end
	Tab_Lower.MouseLeave:Connect(Release)
	Tab_Upper.MouseLeave:Connect(Release)
	Tab_Right.MouseLeave:Connect(Release)
	Tab_Left.MouseLeave:Connect(Release)
	Tab_Lower.MouseButton1Up:Connect(Release)
	Tab_Upper.MouseButton1Up:Connect(Release)
	Tab_Right.MouseButton1Up:Connect(Release)
	Tab_Left.MouseButton1Up:Connect(Release)
	Tab_Lower.MouseButton1Down:Connect(function():()
		Lower_DB=true
		Tab_Scroll.CanvasPosition+=Button_SlideBy_Y
		local run:RBXScriptConnection
		local yieldTime:number = 0
		run = Heartbeat:Connect(function(delta:number):()
			yieldTime+=delta
			if not Lower_DB then
				run:Disconnect()
				return
			end
			if yieldTime>SliderResponsivenessTime then
				Tab_Scroll.CanvasPosition+=Button_SlideBy_Y*(delta*ScrollSpeed)
			end
		end)
	end)
	Tab_Upper.MouseButton1Down:Connect(function():()
		Upper_DB=true
		Tab_Scroll.CanvasPosition-=Button_SlideBy_Y
		local run:RBXScriptConnection
		local yieldTime:number = 0
		run = Heartbeat:Connect(function(delta:number):()
			yieldTime+=delta
			if not Upper_DB then
				run:Disconnect()
				return
			end
			if yieldTime>SliderResponsivenessTime then
				Tab_Scroll.CanvasPosition-=Button_SlideBy_Y*(delta*ScrollSpeed)
			end
		end)
	end)
	Tab_Right.MouseButton1Down:Connect(function():()
		Right_DB=true
		Tab_Scroll.CanvasPosition+=Button_SlideBy_X
		local run:RBXScriptConnection
		local yieldTime:number = 0
		run = Heartbeat:Connect(function(delta:number):()
			yieldTime+=delta
			if not Right_DB then
				run:Disconnect()
				return
			end
			if yieldTime>SliderResponsivenessTime then
				Tab_Scroll.CanvasPosition+=Button_SlideBy_X*(delta*ScrollSpeed)
			end
		end)
	end)
	Tab_Left.MouseButton1Down:Connect(function():()
		Left_DB=true
		Tab_Scroll.CanvasPosition-=Button_SlideBy_X
		local run:RBXScriptConnection
		local yieldTime:number = 0
		run = Heartbeat:Connect(function(delta:number):()
			yieldTime+=delta
			if not Left_DB then
				run:Disconnect()
				return
			end
			if yieldTime>SliderResponsivenessTime then
				Tab_Scroll.CanvasPosition-=Button_SlideBy_X*(delta*ScrollSpeed)
			end
		end)
	end)
	table.insert(TabViewports,Tab)
	--Parenting
	Tab_Button.LayoutOrder=TabIndex
	Tab_Button.Parent = UpperBar
	Tab.Parent=ViewTabs
	ScaleCanvas()
	TabIndex+=1
	return Tab,List
end


local __classesData
local LatestCache:number = tonumber(plugin:GetSetting("Classes_LatestCache_Valid")) or 0

local GET_SAVE:string? = nil and plugin:GetSetting("HierarchySaver_CLASSES")

local WidgetToggle__DB:boolean = false

--Initializing
if _G.__classesData==nil and (GET_SAVE==nil or LatestCache<workspace:GetServerTimeNow()) then
	__classesData = {__loaded=false;_event = Instance.new("BindableEvent");}
	_G.__classesData = __classesData

	local success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
	if success then
		__classesData.Classes = HttpService:JSONDecode(ret::string)::Types.API_Dump
		plugin:SetSetting("Classes_LatestCache_Valid",workspace:GetServerTimeNow()+60*60*24)	
		;(__classesData::any).__loaded = true
		;((__classesData::any)._event::BindableEvent):Fire()
		;((__classesData::any)._event::BindableEvent):Destroy()
	else
		-- No perms but has a backup

		--No perms and no backup
		local ErrorTab = CreateTab("Can't Access HTTP request","http://www.roblox.com/asset/?id=77195333607477");
		(ErrorTab:WaitForChild("Scroll")::ScrollingFrame):Destroy();
		((UpperBar::any)[ErrorTab.Name]::Frame):SetAttribute("Enabled",true)
		local Data_UI = ErrorHTTP_UI:WaitForChild("Data")
		local EventHandler = Data_UI:WaitForChild("EventHandler")
		local Effect = EventHandler:WaitForChild("Effect")
		local Button_Try = Effect:WaitForChild("Button")
		local Info = TweenInfo.new(0.25,Enum.EasingStyle.Bounce)
		local Enter = TweenService:Create(Button_Try,Info,{Position=UDim2.new(0.5,0,0.5,0)})
		local Leave = TweenService:Create(Button_Try,Info,{Position=UDim2.new(0.5,0,0.4,0)})
		local ButtonIdleColor:Color3 = Color3.new(0.376471, 1, 0.0901961)
		local ButtonHoverColor:Color3 = Color3.new(0.243137, 0.647059, 0.0588235)
		local ButtonClickColor:Color3 = Color3.new(0.145098, 0.380392, 0.0352941)
		local __db_Hovering:boolean = false

		EventHandler.MouseEnter:Connect(function():()
			__db_Hovering=true
			Button_Try.BackgroundColor3 = ButtonHoverColor
			Enter:Play()
		end)
		EventHandler.MouseLeave:Connect(function():()
			__db_Hovering=false
			Button_Try.BackgroundColor3 = ButtonIdleColor
			Leave:Play()
		end)
		EventHandler.MouseButton1Down:Connect(function()
			Button_Try.BackgroundColor3 = ButtonClickColor
		end)
		EventHandler.MouseButton1Up:Connect(function()
			if __db_Hovering then Button_Try.BackgroundColor3 = ButtonHoverColor return end
			Button_Try.BackgroundColor3 = ButtonIdleColor
		end)
		local button_DB:boolean = false
		EventHandler.MouseButton1Click:Connect(function():()
			if button_DB==true then return end
			button_DB=true
			local success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
			if success then
				Enter:Destroy()
				Leave:Destroy()
				Button_Try:Destroy()
				__classesData.Classes = HttpService:JSONDecode(ret::string)::Types.API_Dump
				plugin:SetSetting("Classes_LatestCache_Valid",workspace:GetServerTimeNow()+60*60*24)
				DeleteTab(ErrorTab.Name)
				;(__classesData::any).__loaded = true
				;((__classesData::any)._event::BindableEvent):Fire()
			else
				warn(`No access to HTTP requests: {string.gsub(ret,"%d+%.*$",plugin.Name)}`)
			end
			button_DB=false
		end)
		ErrorHTTP_UI.Parent=ErrorTab
		ErrorHTTP_UI.Visible=true
		ErrorTab.Visible=true
		ThemeChanged()
		warn(`No access to HTTP requests: {string.gsub(ret,"%d+%.*$",plugin.Name)}`)
		for i,v in ViewTabs:GetChildren()::{Frame} do
			if v.Visible==true then
				local Button = UpperBar:FindFirstChild(v.Name)
				if Button==nil then continue end
				Button:SetAttribute("Enabled",true)
			end
		end
		Main.Parent=Widget
		Button.Click:Connect(function()
			Widget.Enabled = not Widget.Enabled
		end)
		WidgetToggle__DB = true
		;((__classesData::any)._event::BindableEvent).Event:Wait()
	end
elseif _G.__classesData~=nil then
	__classesData = _G.__classesData
	if __classesData.__loaded==false then
		local t:thread = task.delay(10,function():()
			warn(`Waiting for Classes from different plugin; Make sure you aswell give them HTTP permissions perhabs or get rid of them.`)
		end)
		;((__classesData::any)._event::BindableEvent).Event:Wait()
		if coroutine.status(t)~="dead" then
			task.cancel(t)
		end
	end
end



local function SuccessResult(ret:Types.API_Dump):()
	local raw_Classes:Types.AllRobloxClasses = ret.Classes
	local Enums:Types.AllRobloxEnums = ret.Enums
	for i,v in raw_Classes do
		--if v.MemoryCategory~="Instances" then continue end
		if v.Tags~=nil and (table.find(v.Tags,"NotCreatable")~=nil or table.find(v.Tags,"NotScriptable")~=nil) then continue end
		local tab:Types.FormattedClass = {}
		local Superclass:string? = v.Name
		while Superclass~=nil do
			local search:number? = nil
			for i,v in raw_Classes do
				if v.Name==Superclass then search=i break end
			end
			if search==nil then break end
			for ii,vv in raw_Classes[search].Members do
				if vv.MemberType~="Property" then continue end
				if (type(vv.Security)=="string" and vv.Security~="None") or (type(vv.Security)=="table" and (vv.Security.Write~="None" or vv.Security.Read~="None")) then continue end
				if vv.ValueType==nil then continue end
				if vv.Tags~=nil and (table.find(vv.Tags,"ReadOnly")~=nil or table.find(vv.Tags,"NotScriptable")~=nil or table.find(vv.Tags,"Deprecated")~=nil or table.find(vv.Tags,"PluginSecurity")~=nil) then continue end
				tab[vv.Name]=(vv.ValueType.Category=="Class" and "Instance") or (vv.ValueType.Category=="Enum" and `Enum.{vv.ValueType.Name}`) or (TranslateProperties[vv.ValueType.Name] or vv.ValueType.Name)
			end
			Superclass=raw_Classes[search].Superclass
		end
		Classes[v.Name]=tab
	end
	if _G.__classesData~=nil then
		(_G.__classesData::any).HierarchySaver_CLASSES = Classes
	end
	plugin:SetSetting("HierarchySaver_CLASSES",HttpService:JSONEncode(Classes))
end

if GET_SAVE~=nil and LatestCache>workspace:GetServerTimeNow() then
	Classes = (_G.__classesData~=nil and _G.__classesData.HierarchySaver_CLASSES::Types.FormattedClasses?) or HttpService:JSONDecode(GET_SAVE)::Types.FormattedClasses
	--if WaitForData then coroutine.resume(WaitForData) end
else
	SuccessResult(__classesData.Classes::Types.API_Dump)
end


--*********************Obtaining classes
--if LatestCache>workspace:GetServerTimeNow() and type(GET_SAVE)=="string" then
--	Classes = HttpService:JSONDecode(GET_SAVE)::Types.FormattedClasses
--	if WaitForData then coroutine.resume(WaitForData) end
--else

--end

--********************* Assembling widget UI
if WidgetToggle__DB==false then
	Main.Parent=Widget
	Button.Click:Connect(function()
		Widget.Enabled = not Widget.Enabled
	end)
end
--********************* AFTER RECIVING CLASSES --[[
--if next(Classes)==nil and Data==nil then
--	--waiting for data
--	coroutine.yield()
--end
LowerBar.Visible=true
if ErrorHTTP_UI then ErrorHTTP_UI:Destroy() end
--Typecheker plz shut up
--if Classes==nil and Data==nil then return end
--Thanks typecheker for shutting up
--]]
type cache_prop = {[string]:any}
local Default_Properties_Cache:{[string]:cache_prop} = {}
--[[
Returns all non default properties of an Instance
]]

local InstanceClassProperties:{[string]:string} = {
	Archivable = "boolean";
	Capabilities = "SecurityCapabilities";
	Name = "string";
	Parent = "Instance";
	Sandboxed = "boolean";	
}

local InstanceDefPropertiesFallback:cache_prop = {
	Archivable = true;
	Capabilities = SecurityCapabilities.new();
	Sandboxed = false;
}

local function __Index(ins:Instance,prop:string):any
	return (ins::any)[prop]::any
end

local function GetProperties(instance:any,AllPropertiesBypass:true?,ClassNameReplace:string?):cache_prop
	local ClassName:string = ClassNameReplace or instance.ClassName
	--Bypass
	if AllPropertiesBypass==true then
		local prop:{[string]:any} = {}
		for i,v in Classes[ClassName] or InstanceClassProperties do
			local try,ret = pcall(__Index,instance::Instance,i)
			if try then
				prop[i]=ret
			end
		end
		return prop
	end
	--
	if Default_Properties_Cache[ClassName]==nil then
		local cache_prop:cache_prop = {}
		local try,ins = pcall(Instance.new,ClassName)
		if try then
			for i,v in Classes[ClassName] or InstanceClassProperties do
				local try,ret = pcall(__Index,(ins::any)::Instance,i)
				if not try then continue end
				cache_prop[i]=ret
			end
			(ins::Instance|any):Destroy()
			Default_Properties_Cache[ClassName]=cache_prop
		end
	end
	local cache_prop:cache_prop = Default_Properties_Cache[ClassName] or InstanceDefPropertiesFallback
	local prop:{[string]:any} = {}
	for i,v in Classes[ClassName] or InstanceClassProperties do
		local try,ret = pcall(__Index,instance::Instance,i)
		if not try then continue end
		if ret==cache_prop[i] or i=="ClassName" or i=="className" or i=="Parent" then continue end
		prop[i]=ret
	end
	return prop
end



--local RecursionFunctionIncld__1,RecursionFunctionIncld__2 = [[local function ]],[[(self:Instance,Up:number,Path:{string}):()
--	local dir:Instance = self
--	for i=1,Up do
--		dir=dir.Parent::Instance
--	end
--	for i,v in Path do
--		dir=dir[v]
--	end
--	self.Parent=dir
--end

--]]

--[[Make meshparts cache  OR NOT and ability to add function for caching method
Using :ApplyMesh resets the texture!!


]]





local function BlankPropertyCreate(Name:string,DisplayName:string?,Description:string?,OffsetLevel:number?,Relative:GuiObject?):(TextButton,Frame,Frame)
	local Property = Property:Clone()::TextButton
	local Property_Content = Property:WaitForChild("Content")::Frame
	local LabelFrame = Property_Content:WaitForChild("LabelFrame")::Frame
	--[[Content offset]]
	if OffsetLevel~=nil then
		LabelFrame.Size=UDim2.new(0.5,-(16--[[OffsetBy]]*OffsetLevel),1, 0)
	end
	---
	local Label = LabelFrame:WaitForChild("Label")::TextLabel
	local Gap = LabelFrame:WaitForChild("Gap")::Frame
	table.insert(UI_Strokes,Property:WaitForChild("UIStroke")::UIStroke)
	table.insert(Properties_ItemColor,Property)
	table.insert(TextButtons_Theme,Label)
	AllPropertyRelatives[Label] = (Relative~=nil and Relative) or Property
	if Description~=nil then
		local function UpdateHint():()
			if Property:GetAttribute("Selected")==true then return end
			local pos:Vector2 = Widget:GetRelativeMousePosition()
			Hint.Position = UDim2.new(0,pos.X,0,pos.Y+20)
			local bounds:Vector2 = TextService:GetTextSize(Description,Hint_Label.TextSize,Hint_Label.Font,Vector2.new(Widget.AbsoluteSize.X-pos.X,Widget.AbsoluteSize.Y-pos.Y))
			Hint.Size=UDim2.new(0,bounds.X+6,0,bounds.Y+6)
			Hint.AnchorPoint = (pos.X>Widget.AbsoluteSize.X*0.5 and Vector2.xAxis) or Vector2.zero
			Hint_Label.Text=Description
			Hint.Visible=true
		end
		LabelFrame.MouseEnter:Connect(UpdateHint)
		LabelFrame.MouseMoved:Connect(UpdateHint)
		LabelFrame.MouseLeave:Connect(HideHint)
	end
	Property.MouseEnter:Connect(function()
		if Property:GetAttribute("Selected") then return end
		Property.BackgroundColor3=ItemColor_Hover
	end)
	Property.MouseLeave:Connect(function()
		if Property:GetAttribute("Selected") then return end
		Property.BackgroundColor3=ItemColor
	end)
	Property:GetAttributeChangedSignal("Selected"):Connect(function()
		if Property:GetAttribute("Selected") then
			Label:SetAttribute("Selected",true)
			Label.TextColor3=TextColor_Selected
		else
			Label:SetAttribute("Selected",nil)
			Label.TextColor3=TextColor
		end
	end)
	--select
	Property.MouseButton1Click:Connect(function()
		if SelectedTarget~=Property then RemoveSelectionButton() end
		SetSelectionButton(Property)
	end)

	local text = DisplayName or Name
	Label.Text=text
	Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local bounds_X:number = TextService:GetTextSize(text,Label.TextSize,Label.Font,Label.AbsoluteSize).X
		for i=#text,1,-1 do
			if TextService:GetTextSize(string.sub(text,1,i),Label.TextSize,Label.Font,Label.AbsoluteSize).X~=bounds_X or i==1 then
				if Label.TextFits==true and i==#text-1 then
					Label.Text = text
					return
				end
				local str:string = `{string.gsub(text," ",".")}`
				str = string.sub(str,1,#str-4)--UI never made any sense so...
				Label.Text=`{str}...`
				return
			end
		end
	end)

	return Property,Property_Content,Gap
end

local const_StaticInputRange:UDim2 = UDim2.new(0,64,1,0)

local function PropertyTypeInitiator(Property:TextButton,Property_Content:Frame,Type:Types.PropertyTypes,i:string,Updater:BindableEvent,TrueParent:GuiObject?,Data:Types.RecursiveTree):()
	if Type=="NumberRange" then
		local Min:number = tonumber((Data.DataComponent~=nil and Data.DataComponent.Min) or 0) or 0
		local Max:number = tonumber((Data.DataComponent~=nil and Data.DataComponent.Max) or 10) or 10
		local Clamp:number = tonumber((Data.DataComponent~=nil and Data.DataComponent.Clamp) or 0.05) or 0.05
		local Increment:number = tonumber((Data.DataComponent~=nil and Data.DataComponent.Increment) or Clamp) or Clamp
		local value = Property_NumberRange:Clone()
		value.Name="Value"
		value:SetAttribute("Enabled",true)
		table.insert(Properties_ItemColor,value)
		table.insert(UI_Strokes,value:WaitForChild("UIStroke")::UIStroke)
		local Input_Frame = value:WaitForChild("Input_Frame")
		local Input_Frame_Stroke = Input_Frame:WaitForChild("UIStroke")::UIStroke
		table.insert(UI_Strokes,Input_Frame_Stroke)
		local Input = Input_Frame:WaitForChild("Input")
		local _buttons = Input:WaitForChild("Buttons")
		local Input_UP = _buttons:WaitForChild("Up")
		local Input_DOWN = _buttons:WaitForChild("Down")
		local _Slider = value:WaitForChild("Slider")
		local Bar = _Slider:WaitForChild("Bar")
		local Slider = _Slider:WaitForChild("Slider")
		table.insert(UI_Strokes,Slider:WaitForChild("UIStroke")::UIStroke)
		table.insert(TextButtons_Theme,Input)
		table.insert(ItemHoverList,Input_UP)
		table.insert(ItemHoverList,Input_DOWN)
		table.insert(DialogColorList,Slider)
		table.insert(ScriptWhitespaceColorList,Bar)
		Slider.MouseEnter:Connect(function()
			Slider.BackgroundColor3=DialogColor_Hover
		end)
		Slider.MouseLeave:Connect(function()
			Slider.BackgroundColor3=DialogColor
		end)

		Input_UP.MouseEnter:Connect(function()
			Input_UP.BackgroundTransparency=0
		end)
		Input_DOWN.MouseEnter:Connect(function()
			Input_DOWN.BackgroundTransparency=0
		end)
		Input_UP.MouseLeave:Connect(function()
			Input_UP.BackgroundTransparency=1
		end)
		Input_DOWN.MouseLeave:Connect(function()
			Input_DOWN.BackgroundTransparency=1
		end)

		_buttons.Visible=false
		_Slider.Visible=false
		Input_Frame_Stroke.Enabled=false
		local MouseInsideValue:boolean = false
		value.MouseEnter:Connect(function()
			MouseInsideValue=true
		end)
		value.MouseLeave:Connect(function()
			MouseInsideValue=false
		end)

		local function ScaleInputBar()
			if _buttons.Visible==true then return end
			Input.Size=value.Size
		end
		value:GetPropertyChangedSignal("BackgroundTransparency"):Connect(function()
			if value.BackgroundTransparency==1 then
				_buttons.Visible=false
				_Slider.Visible=false
				Input_Frame_Stroke.Enabled=false
				ScaleInputBar()
			else
				_buttons.Visible=true
				_Slider.Visible=true
				Input_Frame_Stroke.Enabled=true
				Input.Size=const_StaticInputRange
				SelectedValue=value::Frame|any
			end
		end)
		local incrementWorker:RBXScriptConnection?=nil
		local tottalDelta:number=0
		local function Increase(delta:number):()
			tottalDelta+=delta
			if tottalDelta<0.25 then return end
			tottalDelta=0
			local num:number = MathClampValue((tonumber(SessionData[i] or 0) or 0)+Increment+0.0000005,Min,Max,Clamp)
			SessionData[i]=num
			Input.Text=tostring(num)
			Slider.Position=UDim2.new(iLerp(num,Min,Max),0,0.5,0)
		end
		local function Decrease(delta:number):()
			tottalDelta+=delta
			if tottalDelta<0.25 then return end
			tottalDelta=0
			local num:number = MathClampValue((tonumber(SessionData[i] or 0) or 0)-Increment+0.0000005,Min,Max,Clamp)
			SessionData[i]=num
			Input.Text=tostring(num)
			Slider.Position=UDim2.new(iLerp(num,Min,Max),0,0.5,0)
		end

		local function StopWorker():()
			if incrementWorker==nil then return end
			incrementWorker:Disconnect()
			incrementWorker=nil
			tottalDelta=0
		end
		Input_UP.MouseButton1Up:Connect(StopWorker)
		Input_DOWN.MouseButton1Up:Connect(StopWorker)
		Input_UP.MouseButton1Down:Connect(function()
			Input:ReleaseFocus()
			task.spawn(Increase,1)
			incrementWorker=Heartbeat:Connect(Increase)
		end)
		Input_DOWN.MouseButton1Down:Connect(function()
			Input:ReleaseFocus()
			task.spawn(Decrease,1)
			incrementWorker=Heartbeat:Connect(Decrease)
		end)
		local drag = Instance.new("UIDragDetector")
		drag.DragStyle=Enum.UIDragDetectorDragStyle.TranslateLine
		drag.BoundingUI=_Slider
		drag.ResponseStyle=Enum.UIDragDetectorResponseStyle.Scale
		drag.ReferenceUIInstance=_Slider
		drag.DragContinue:Connect(function():()
			local num:number = MathClampValue(math.lerp(Min,Max,Slider.Position.X.Scale),Min,Max,Clamp)
			SessionData[i]=num
			Input.Text=tostring(num)
		end)
		drag.DragEnd:Connect(function():()
			local num:number = MathClampValue(math.lerp(Min,Max,Slider.Position.X.Scale),Min,Max,Clamp)
			SessionData[i]=num
			Input.Text=tostring(num)
			Slider.Position=UDim2.new(iLerp(num,Min,Max),0,0.5,0)
		end)
		Slider.Position=UDim2.new(iLerp(tonumber(SessionData[i] or Min) or Min,Min,Max),0,0.5,0)
		drag.Parent=Slider

		local function InputEnded(key:InputObject):()
			if key.KeyCode~=Enum.KeyCode.Return then return end
			--Pressed enter
			value.BackgroundTransparency=1
			local num:number = MathClampValue(Calculate(Input.Text),Min,Max,Clamp)
			SessionData[i]=num
			Input.Text=tostring(num)
			Slider.Position=UDim2.new(iLerp(num,Min,Max),0,0.5,0)
		end
		Input.InputEnded:Connect(InputEnded)
		_buttons.InputEnded:Connect(InputEnded)
		value.InputEnded:Connect(InputEnded)
		Input_Frame.InputEnded:Connect(InputEnded)
		_Slider.InputEnded:Connect(InputEnded)
		Input_DOWN.InputEnded:Connect(InputEnded)
		Input_UP.InputEnded:Connect(InputEnded)
		Bar.InputEnded:Connect(InputEnded)
		Slider.InputEnded:Connect(InputEnded)

		Input.Focused:Connect(function():()
			value.BackgroundTransparency=0
			if SelectedNumberRange~=nil then
				SelectedNumberRange.BackgroundTransparency=1
				SelectedNumberRange=nil
			end
			SelectedNumberRange=value
		end)
		Input.FocusLost:Connect(function():()
			if MouseInsideValue==true then return end
			--Lost focus when cursor being outside the pannel
			value.BackgroundTransparency=1
			local num:number = MathClampValue(Calculate(Input.Text),Min,Max,Clamp)
			SessionData[i]=num
			Input.Text=tostring(num)
			Slider.Position=UDim2.new(iLerp(num,Min,Max),0,0.5,0)
		end)

		Input.Text=tostring(SessionData[i])
		value:GetPropertyChangedSignal("AbsoluteSize"):Connect(ScaleInputBar)
		ScaleInputBar()
		value.Visible=true
		value.Parent=Property_Content
	elseif Type=="Enum" then
		local value = Property_EnumList:Clone()
		local Button = value:WaitForChild("Button")::TextButton
		local Container = Button:WaitForChild("Container")::Frame
		local Container_UIListLayout = Container:WaitForChild("UIListLayout")::UIListLayout
		value:SetAttribute("Enabled",true)
		value.Name="Value"
		table.insert(UI_Strokes,value:WaitForChild("UIStroke")::UIStroke)
		table.insert(UI_Strokes,Container:WaitForChild("UIStroke")::UIStroke)
		table.insert(Properties_ItemColor,value)
		table.insert(TextButtons_Theme,Button)
		table.insert(CollapserColor_Lighter_List,Button:WaitForChild("Down")::ImageLabel)
		Button.Text=tostring((SessionData[i] and `  {SessionData[i]}`) or "  Unknown")
		for ii,vv in Data.DataComponent or {}::{[string]:any} do
			local setvalue_button = Property_EnumList_Sample:Clone()
			table.insert(Properties_ItemColor,setvalue_button)
			table.insert(TextLittleGreyColorList,setvalue_button)
			setvalue_button.MouseEnter:Connect(function()
				setvalue_button.TextColor3=TextColor
				setvalue_button.BackgroundColor3=ItemColor_Hover
			end)
			setvalue_button.MouseLeave:Connect(function()
				setvalue_button.TextColor3=TextLittleGreyColor
				setvalue_button.BackgroundColor3=ItemColor
			end)
			setvalue_button.MouseButton1Click:Connect(function()
				SessionData[i]=ii::string
				Button.Text=`  {ii::string}`
				Container.Visible=false
				SelectedContainer=nil
			end)
			setvalue_button.Text=`  {ii::string}`
			setvalue_button.Visible=true
			setvalue_button.Parent=Container
		end
		local function ScaleContainer():()
			Container.Size = UDim2.new(1,0,0,Container_UIListLayout.AbsoluteContentSize.Y)
		end
		Container:GetPropertyChangedSignal("Visible"):Connect(function():()
			value.BackgroundTransparency = (Container.Visible==true and 0) or 1
		end)
		Button.MouseButton1Click:Connect(function():()
			if SelectedContainer~=nil then
				SelectedContainer.Visible=false
				SelectedContainer=nil
			end
			if value.BackgroundTransparency==0 then return end
			Container.Visible=true
			SelectedContainer=Container
		end)
		Container_UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ScaleContainer)
		ScaleContainer()
		value.Visible=true
		value.Parent=Property_Content
	elseif Type=="boolean" then
		local value = Property_Boolean:Clone()
		value.Name="Value"
		local value_button = value:WaitForChild("Button")::ImageButton
		local Hitbox = value:WaitForChild("Hitbox")::TextButton
		table.insert(UI_Strokes,value:WaitForChild("UIStroke")::UIStroke)
		table.insert(Properties_ItemColor,value_button)
		local debounce_boolean:boolean = (SessionData[i]::boolean) or false
		Hitbox.MouseButton1Click:Connect(function()
			debounce_boolean = not (debounce_boolean::boolean)
			SessionData[i]=debounce_boolean
			if debounce_boolean==true then--enabled
				value_button.Image="http://www.roblox.com/asset/?id=80963663462977"
			else--disabled
				value_button.Image="http://www.roblox.com/asset/?id=122392313117967"
			end
			RemoveSelectionButton()
			SetSelectionButton(Property)
		end)
		if debounce_boolean==true then--enabled
			value_button.Image="http://www.roblox.com/asset/?id=80963663462977"
		else--disabled
			value_button.Image="http://www.roblox.com/asset/?id=122392313117967"
		end
		value.Visible=true
		value.Parent=Property_Content
	elseif Type=="string" then
		local value = Property_Input:Clone()::Frame
		value:SetAttribute("Enabled",true)
		table.insert(Properties_ItemColor,value)
		value.BackgroundTransparency=1
		value.Name="Value"
		local value_input = value:WaitForChild("Input")::TextBox

		value_input.Text=(SessionData[i]::string) or ""
		table.insert(UI_Strokes,value:WaitForChild("UIStroke")::UIStroke)
		table.insert(TextButtons_Theme,value_input)
		local function ScaleTextToFit()
			local sz:number = TextService:GetTextSize(value_input.Text,value_input.TextSize,value_input.Font,Vector2.new(math.huge,value_input.TextSize)).X
			Property:SetAttribute("MaxSize",sz+6)
			if TrueParent~=nil then HashMapLevel[TrueParent][Property]=sz end
		end
		value_input:GetPropertyChangedSignal("AbsoluteSize"):Connect(ScaleTextToFit)
		value_input:GetPropertyChangedSignal("TextFits"):Connect(ScaleTextToFit)
		value_input.Focused:Connect(function()
			value.BackgroundTransparency=0
			RemoveSelectionButton()
			SetSelectionButton(Property)
		end)
		value_input.FocusLost:Connect(function()
			value.BackgroundTransparency=1
			SessionData[i]=value_input.Text
			ScaleTextToFit()
			task.defer(Updater.Fire,Updater)

		end)

		Property.MouseButton1Click:Connect(function()
			task.defer(CaptureFocusFunc,value_input)
		end)
		ScaleTextToFit()
		value.Visible=true
		value.Parent=Property_Content
	elseif Type=="number" then
		local value = Property_Input:Clone()::Frame
		value:SetAttribute("Enabled",true)
		table.insert(Properties_ItemColor,value)
		value.BackgroundTransparency=1
		value.Name="Value"
		local value_input = value:WaitForChild("Input")::TextBox
		value_input.Text=tostring((SessionData[i]::number) or 0)
		table.insert(UI_Strokes,value:WaitForChild("UIStroke")::UIStroke)
		table.insert(TextButtons_Theme,value_input)
		local function ScaleTextToFit()
			local sz:number = TextService:GetTextSize(value_input.Text,value_input.TextSize,value_input.Font,Vector2.new(math.huge,value_input.TextSize)).X
			Property:SetAttribute("MaxSize",sz+6)
			if TrueParent~=nil then HashMapLevel[TrueParent][Property]=sz end
		end
		value_input:GetPropertyChangedSignal("AbsoluteSize"):Connect(ScaleTextToFit)
		value_input:GetPropertyChangedSignal("TextFits"):Connect(ScaleTextToFit)
		value_input.Focused:Connect(function()
			value.BackgroundTransparency=0
			RemoveSelectionButton()
			SetSelectionButton(Property)
		end)
		value_input.FocusLost:Connect(function()
			value.BackgroundTransparency=1
			SessionData[i]=Calculate(value_input.Text) or 0
			value_input.Text=tostring(SessionData[i])
			ScaleTextToFit()
			task.defer(Updater.Fire,Updater)
		end)

		Property.MouseButton1Click:Connect(function()
			task.defer(CaptureFocusFunc,value_input)
		end)
		ScaleTextToFit()
		value.Visible=true
		value.Parent=Property_Content
	end
end

local function SumSizeY(Parent:GuiObject):number
	if Parent.Visible==false then return Property_Y_SizePX end
	local sum:number = 0
	for i,v in Parent:GetChildren() do
		if not v:IsA("GuiObject") or v.Visible==false then continue end
		sum+= v.AbsoluteSize.Y
	end
	return sum
end

local function TreeRecursive(Parent:GuiObject,Data:Types.RecursiveRoot,Updater:BindableEvent,Layer:number,TrueParent:GuiObject,Relative:GuiObject?):()
	local ParentProperty_Content = Parent.Parent::Frame
	local ParentPropertyBox = ParentProperty_Content.Parent::Frame
	for _,Tree in Data do
		local Property,Property_Content,Gap = BlankPropertyCreate(Tree.Name,Tree.DisplayName,Tree.Description,Layer,Relative)
		PropertyTypeInitiator(Property,Property_Content,Tree.Type,Tree.Name,Updater,TrueParent,Tree)
		if Tree.Tree~=nil then
			Property.Size=Y_height23_SUBSTRACTED--Hacky to fix weird roblox scaling glitch
			local Box = PropertyBox:Clone()
			local Box_Content = Box:WaitForChild("Content")::Frame
			local Box_Nest = Box_Content:WaitForChild("NestedProperties")::Frame
			local Box_Nest_UIList = Box_Nest:WaitForChild("UIListLayout")::UIListLayout
			table.insert(UI_Strokes,Box:WaitForChild("UIStroke")::UIStroke)
			EmptyProperty:Clone().Parent=Box_Nest

			local function UpdateList():()
				if Box_Nest.Visible==false then Box.Size=Y_heightPX
					ParentPropertyBox:SetAttribute("YSize",SumSizeY(Parent))
					return 
				end
				Box.Size=UDim2.new(1,0,0,Box_Nest_UIList.AbsoluteContentSize.Y)
				ParentPropertyBox:SetAttribute("YSize",SumSizeY(Parent))
			end
			table.insert(CollapserColor_List,Collapse)
			TreeRecursive(Box_Nest,Tree.Tree,Updater,Layer+1,TrueParent,Relative)
			local Collapse = Collapse:Clone()
			local Collapse_Expanded:boolean = false
			Collapse.MouseButton1Click:Connect(function()
				local state = not Collapse_Expanded
				Collapse_Expanded=state
				if state==true then
					Collapse.Image="rbxassetid://121275826762496"
					Box_Nest.Visible=true
				else
					Collapse.Image="rbxassetid://75405344316847"
					Box_Nest.Visible=false
				end
				UpdateList()
				task.defer(Updater.Fire,Updater)
			end)
			Box_Nest.Visible=false
			Collapse.Parent=Gap
			Property.Visible=true
			Property.Parent=Box_Content
			Box.Visible=true
			Box.Parent=Parent
			Box_Nest_UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateList)
			UpdateList()
		else
			Property.Visible=true
			Property.Parent=Parent
			ParentPropertyBox:SetAttribute("YSize",SumSizeY(Parent))
		end
	end
end

local function BuildPropertiesList(Parent:Instance,Data:Types.BuildProperties):()
	local Index:number = 0
	local Updater = Parent:WaitForChild("Updater")::BindableEvent
	for CategoryName__,ArrayOfProperties__ in Data do
		local CategoryName = ArrayOfProperties__.Name
		local ArrayOfProperties = ArrayOfProperties__.Content
		local Expanded:boolean = true
		local CategoryDescendants:{GuiObject} = table.create(#ArrayOfProperties)::{GuiObject}
		local Category = Category:Clone()
		local Category_Label = Category:WaitForChild("Label")
		local Category_Collapser = Category:WaitForChild("Collapser")
		table.insert(CollapserColor_List,Category_Collapser)
		table.insert(UI_Strokes,Category:WaitForChild("UIStroke")::UIStroke)
		table.insert(CategoryList,Category)
		table.insert(TextButtons_Theme,Category_Label)
		Category_Label.Text=CategoryName

		Category.MouseEnter:Connect(function()
			Category.BackgroundColor3=ItemColor_Hover
		end)
		Category.MouseLeave:Connect(function()
			Category.BackgroundColor3=CategoryItem
		end)
		UncollapseCategoryies.Event:Connect(function():()
			Category_Collapser.Image="rbxassetid://134054819148055"
			Expanded=true
		end)
		Category.MouseButton1Click:Connect(function()
			task.defer(RemoveSelectionButton)
			Expanded = not Expanded
			if Expanded==true then
				--Expanded
				Category_Collapser.Image="rbxassetid://134054819148055"
				for i,v in CategoryDescendants do
					v.Visible=true
				end
			else
				--Collapsed
				Category_Collapser.Image="rbxassetid://113991226200270"
				for i,v in CategoryDescendants do
					v.Visible=false
				end
			end
			Updater:Fire()
		end)


		Category.LayoutOrder=Index
		Index += 1
		for _,v in ArrayOfProperties do
			local i = v.Name
			if v.Tree==nil then
				local Property,Property_Content,Gap = BlankPropertyCreate(i,v.DisplayName,v.Description)
				PropertyTypeInitiator(Property,Property_Content,v.Type,i,Updater,nil,v)
				table.insert(CategoryDescendants,Property)
				Property.LayoutOrder=Index
				Property.Visible=true
				Property.Parent=Parent
			else
				Property.Size=Y_heightPX--Hacky to fix weird roblox scaling glitch
				local Box = PropertyBox:Clone()
				local Property,Property_Content,Gap = BlankPropertyCreate(i,v.DisplayName,v.Description,nil,Box)
				PropertyTypeInitiator(Property,Property_Content,v.Type,i,Updater,nil,v)
				local Box_Content = Box:WaitForChild("Content")::Frame
				local Box_Nest = Box_Content:WaitForChild("NestedProperties")::Frame
				local Collapse = Collapse:Clone()
				local Collapse_Expanded:boolean = false
				table.insert(UI_Strokes,Box:WaitForChild("UIStroke")::UIStroke)
				EmptyProperty:Clone().Parent=Box_Nest
				HashMapLevel[Box]={}
				local function UpdateDescedants():()
					local FullScale:UDim2 = UDim2.new(0,Box.AbsoluteSize.X,0,Property_Y_SizePX-1)
					local ContentSize:UDim2 = Box_Content.Size
					local ValueProductSize = UDim2.new(0,Box.AbsoluteSize.X-(Box.Content.Size.X.Offset/2),1,0)
					for i,v in Box_Content:GetDescendants() do
						if not v:IsA("GuiObject") then continue end
						if v.Name=="Property" then
							v.Size=FullScale
						elseif v.Name=="Content" then
							v.Size=ContentSize
						elseif v.Name=="Value" then
							v.Size=ValueProductSize
						end
					end
				end
				table.insert(CollapserColor_List,Collapse)
				TreeRecursive(Box_Nest,v.Tree,Updater,1,Box,Box)
				Collapse.MouseButton1Click:Connect(function()
					local state = not Collapse_Expanded
					Collapse_Expanded=state
					if state==true then
						Collapse.Image="rbxassetid://121275826762496"
						Box_Nest.Visible=true
					else
						Collapse.Image="rbxassetid://75405344316847"
						Box_Nest.Visible=false
					end
					Box:SetAttribute("YSize",SumSizeY(Box_Nest))
					task.defer(Updater.Fire,Updater)
				end)
				Box:SetAttribute("YSize",Property_Y_SizePX)
				Box_Nest.Visible=false
				Collapse.Parent=Gap
				table.insert(CategoryDescendants,Box)
				Property.Visible=true
				Property.Parent=Box_Content
				Box.LayoutOrder=Index
				Box.Visible=true
				Box.Parent=Parent
				Parent:GetAttributeChangedSignal("HighestX"):Connect(UpdateDescedants)
				task.defer(UpdateDescedants)
			end

			Index+=1
		end



		Category.Visible=true
		Category.Parent=Parent
	end
	task.defer(Updater.Fire,Updater)
end
local CachedConstants:{[any]:string}


local hexDigits:string = "0123456789abcdef"
local escape:{[string]:string} = {
	['&'] = '&amp;',
	['<'] = '&lt;',
	['>'] = '&gt;',
	['"'] = '&quot;',
	['\''] = '&apos;',
}
local function WriteRichText(str:string,color:Color3):string
	if ss.WriteRichText~=true then return str end
	return `<font color="#{color:ToHex()}">{string.gsub(str,`[&<>"\']`,escape)}</font>`
end

local ConstructorTostring_Switch:{[string]:(data:any,true?)->(string,string)}
local function ConstructorTostring(type:string,data:any,Bypass:true?):(string,string)
	if Bypass~=true then
		for i,v in CachedConstants do
			if data==i then return tostring(v),tostring(v) end
		end
	end
	return (ConstructorTostring_Switch[type] or ConstructorTostring_Switch["_Default"])(data,Bypass)
end
--Init ConstructorTostring
(function():()
	local function ToQuaternion(cf: CFrame): (number,number,number,number)
		local _, _, _, 
		m00, m01, m02,
		m10, m11, m12,
		m20, m21, m22 = cf:GetComponents()
		local x, y, z, w:number
		local trace:number = m00 + m11 + m22
		if trace > 0 then
			local s = math.sqrt(trace + 1) * 2
			w = 0.25 * s
			x = (m21 - m12) / s
			y = (m02 - m20) / s
			z = (m10 - m01) / s
		elseif m00 > m11 and m00 > m22 then
			local s = math.sqrt(1 + m00 - m11 - m22) * 2
			x = 0.25 * s
			y = (m01 + m10) / s
			z = (m02 + m20) / s
			w = (m21 - m12) / s
		elseif m11 > m22 then
			local s = math.sqrt(1 + m11 - m00 - m22) * 2
			x = (m01 + m10) / s
			y = 0.25 * s
			z = (m12 + m21) / s
			w = (m02 - m20) / s
		else
			local s = math.sqrt(1 + m22 - m00 - m11) * 2
			x = (m02 + m20) / s
			y = (m12 + m21) / s
			z = 0.25 * s
			w = (m10 - m01) / s
		end
		return x,y,z,w
	end
	local function IsCleanNumber(num:number):boolean
		local absnum:number = math.abs(num)
		if absnum > 10^-math.floor(ss.SN_Float) and absnum < 10^math.floor(ss.SN_Integer) then return false end

		local str:string = tostring(absnum)
		if num >= 1 or num <= -1 then
			-- Matches things like "1000", "200000"
			return string.match(str,"^%d0+$") ~= nil
		elseif num > -1 and num < 1 then
			-- Matches things like "0.0001"
			return string.match(str,"^0%.0+[1-9]%d*$") ~= nil
		end
		return false
	end

	local function ToScientificNotation(num:number):(string,boolean)
		if num == 0 then
			return "0",false
		elseif IsCleanNumber(num)==false then
			return tostring(num),false
		end
		local exponent:number = math.floor(math.log10(math.abs(num)))
		local mantissa = num / (10^exponent)
		return `{mantissa}e{exponent}`,true
	end

	local function decimalToFraction(x:number):(number,number)
		local sign:number = 1
		if x < 0 then
			sign = -1
			x = -x
		end
		local a, b = 0, 1
		local c, d = 1, 0
		while true do
			local mediant_n:number = a + c
			local mediant_d:number = b + d
			if mediant_d > ss.Fraction::number then break end
			if x * mediant_d > mediant_n then
				a, b = mediant_n, mediant_d
			else
				c, d = mediant_n, mediant_d
			end
		end
		local lower:number = a / b
		local upper:number = c / d
		if math.abs(lower - x) < math.abs(upper - x) then
			return sign*a, b
		end
		return sign*c, d
	end



	--[[Number you want to round]]
	local function Round(x:number):number
		if ss.Rounding==false then return x end
		local Precision:number = 10^math.floor(ss.Precision)
		return math.round(x*Precision)/Precision
	end
	local function ToMatrixUnit(x:number):(string,string)
		local deg:number = math.round(math.deg(x)*1000)/1000
		x = math.rad(deg)

		if ss.MatrixCFrameMeasurements=="Degrees" then
			return `math{(ss.IndexingBy=="Dots" and ".rad") or `[{ConstructorTostring("string","rad")}]`}({ConstructorTostring("number",deg)})`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("rad",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","rad"))}]`}({select(2,ConstructorTostring("number",deg))})`
		elseif ss.MatrixCFrameMeasurements=="Raw" or x==0 or x==math.pi then
			if x==math.pi then return `math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi")}]`}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi"))}]`}` end
			return ConstructorTostring("number",x)
		elseif ss.MatrixCFrameMeasurements=="Balance" then
			local mul = x/math.pi
			if #tostring(mul%1)<7 then return `math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi")}]`}{ss.Mult}{ConstructorTostring("number",mul)}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi"))}]`}{ss.Mult}{select(2,ConstructorTostring("number",mul))}` end

			local sub = math.pi/x
			if #tostring(sub%1)<7 then 
				return `math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi")}]`}{ss.Div}{ConstructorTostring("number",sub)}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi"))}]`}{ss.Div}{select(2,ConstructorTostring("number",sub))}` 
			else
				return `math{(ss.IndexingBy=="Dots" and ".rad") or `[{ConstructorTostring("string","rad")}]`}({ConstructorTostring("number",deg)})`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("rad",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","rad"))}]`}({select(2,ConstructorTostring("number",deg))})`
			end
		else--Radians
			local mul = x/math.pi
			if #tostring(mul%1)<7 then return `math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi")}]`}{ss.Mult}{ConstructorTostring("number",mul)}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi"))}]`}{ss.Mult}{select(2,ConstructorTostring("number",mul))}` end

			local sub = math.pi/x
			if #tostring(sub%1)<7 then 
				return `math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi")}]`}{ss.Div}{ConstructorTostring("number",sub)}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi"))}]`}{ss.Div}{select(2,ConstructorTostring("number",sub))}` 
			else
				return `math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi")}]`}{ss.Mult}{ConstructorTostring("number",mul)}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi"))}]`}{ss.Mult}{select(2,ConstructorTostring("number",mul))}`
			end
		end
	end
	local escapes_str:{[string]:string} = {
		["\\"] = "\\\\",
		["\n"] = "\\n",
		["\t"] = "\\t",
		["\r"] = "\\r",
		["\""] = "\\\"",
		["\b"] = "\\b",
		["\v"] = "\\v",
		["\f"] = "\\f",
	}
	local match_escapes_str_ptrn:string = "[\n\t\r\\\"\b\v\f]"

	ConstructorTostring_Switch = {
		EnumItem = function(data:EnumItem,Bypass:true?):(string,string)
			if ss.IndexingBy=="Dots" then
				return tostring(data),`{WriteRichText("Enum",ScriptBuiltInFunction)}.{WriteRichText(tostring(data.EnumType),ScriptBuiltInFunction)}.{WriteRichText(data.Name,ScriptProperty)}`
			else
				return `Enum[{ConstructorTostring("string",tostring(data.EnumType),Bypass)}][{ConstructorTostring("string",tostring(data.Name),Bypass)}]`,`{WriteRichText("Enum",ScriptBuiltInFunction)}[{select(2,ConstructorTostring("string",tostring(data.EnumType),Bypass))}][{select(2,ConstructorTostring("string",tostring(data.Name),Bypass))}]`
			end
		end;
		number = function(data:number,Bypass:true?):(string,string)
			--constants
			if ss.NanConstant==true and data~=data and Bypass~=true then
				return ss.NanConstant_Name,ss.NanConstant_Name
			elseif data==math.pi or data==-math.pi then
				return `{(data<0 and "-")or""}math{(ss.IndexingBy=="Dots" and ".pi") or `[{ConstructorTostring("string","pi",Bypass)}]`}`,`{(data<0 and "-")or""}{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi",Bypass))}]`}`
			elseif data==math.huge or data==-math.huge then
				return `{(data<0 and "-")or""}math{(ss.IndexingBy=="Dots" and ".huge") or `[{ConstructorTostring("string","huge",Bypass)}]`}`,`{(data<0 and "-")or""}{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("huge",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","huge",Bypass))}]`}`
			elseif data~=data then
				return `0{ss.Div}0`,`{select(2,ConstructorTostring("number",0,Bypass))}{ss.Div}{select(2,ConstructorTostring("number",0,Bypass))}`
			end
			--Numbers
			if ss.Rounding==true then
				local Precision:number = 10^math.floor(ss.All_NumbersRound)
				data = math.round(data*Precision)/Precision
			end
			local data_str:string = tostring(data)
			if ss.HexNumbers==true and data%1==0 and Bypass~=true then
				if data == 0 then
					data_str = "0x0"
				else
					local negative:string = (data<0 and "-") or ""
					local result:string = ""
					data = math.abs(data)

					while data > 0 do
						local remainder:number = data % 16
						result = string.sub(hexDigits,remainder + 1, remainder + 1) .. result
						data //= 16
					end
					data_str = negative.."0x"..result
				end
			elseif ss.ScientificNotations==true then
				local num,IsScientific = ToScientificNotation(data)
				if IsScientific then
					data_str = num
					return num,WriteRichText(num,ScriptNumber)
				end
			end
			if ss.FriendlyFraction==true and data%1~=0 and (#data_str-string.find(data_str,"%.")::number)>=ss.FractionThreshold::number then
				if math.abs(data)<ss.FractionMaxInt::number then
					local num, den = decimalToFraction(data)
					local approx = num / den
					local err:number = math.abs(data - approx) / math.abs(data)
					if err < 0.5 * 10^((-math.floor(ss.FractionThreshold::number)-1)) then
						return `{ConstructorTostring("number",num)}{ss.Div}{ConstructorTostring("number",den)}`,`{select(2,ConstructorTostring("number",num))}{ss.Div}{select(2,ConstructorTostring("number",den))}`
					end
				end
			end
			if ss.UnderscoreNumbers==true then
				local len:number = #data_str
				local Index:number = 0
				local matchDot:number? = (ss.UnderscoreNumbers_IgnoreFloats==true and string.find(data_str,"%.")) or nil
				local result:string = (matchDot~=nil and string.sub(data_str,matchDot,-1)) or ""

				for i=(matchDot and matchDot-1) or len,1,-1 do

					local char:string = string.sub(data_str,i,i)
					if char=="-" then result = char..result 
						break
					elseif char=="." then
						Index=0
						result = char..result 
						continue
					end
					if Index~=0 and Index%math.floor(ss.UnderscoreNumbers_Count)==0 then
						result = "_"..result
					end

					result = char..result
					Index+=1
				end

				return tostring(result),WriteRichText(tostring(result),ScriptNumber)
			end
			return tostring(data_str),WriteRichText(tostring(data_str),ScriptNumber)
		end;
		boolean = function(data:boolean):(string,string)
			return tostring(data),WriteRichText(tostring(data),ScriptBool)
		end;
		["nil"] = function(data:nil):(string,string)
			return "nil",WriteRichText("nil",ScriptNil)
		end;
		Vector2 = function(data:Vector2,Bypass:true?):(string,string)
			--Constants
			if data==Vector2.one then
				return `Vector2{(ss.IndexingBy=="Dots" and ".one") or `[{ConstructorTostring("string","one",Bypass)}]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("one",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","one",Bypass))}]`}`
			elseif data==Vector2.zero then
				return `Vector2{(ss.IndexingBy=="Dots" and ".zero") or `[{ConstructorTostring("string","zero",Bypass)}]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("zero",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","zero",Bypass))}]`}`
			elseif data==Vector2.xAxis then
				return `Vector2{(ss.IndexingBy=="Dots" and ".xAxis") or `[{ConstructorTostring("string","xAxis",Bypass)}]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("xAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","xAxis",Bypass))}]`}`
			elseif data==Vector2.yAxis then
				return `Vector2{(ss.IndexingBy=="Dots" and ".yAxis") or `[{ConstructorTostring("string","yAxis",Bypass)}]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("yAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","yAxis",Bypass))}]`}`
			end
			--Vector2
			local X,Y = Round(data.X),Round(data.Y)
			return `Vector2{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)})`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))})`
		end;
		Vector2int16 = function(data:Vector2,Bypass:true?):(string,string)
			return `Vector2int16{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Y,Bypass)})`,`{WriteRichText("Vector2int16",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y,Bypass))})`
		end;
		Vector3 = function(data:Vector3,Bypass:true?):(string,string)
			local X,Y,Z = Round(data.X),Round(data.Y),Round(data.Z)
			if ss.VectorLibUse=="vector" then
				--constants
				if data==Vector3.one then
					return `vector{(ss.IndexingBy=="Dots" and ".one") or `[{ConstructorTostring("string","one",Bypass)}]`}`,`{WriteRichText("vector",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("one",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","one",Bypass))}]`}`
				elseif data==Vector3.zero then
					return `vector{(ss.IndexingBy=="Dots" and ".zero") or `[{ConstructorTostring("string","zero",Bypass)}]`}`,`{WriteRichText("vector",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("zero",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","zero",Bypass))}]`}`
				end
				--vectors
				return `vector{(ss.IndexingBy=="Dots" and ".create") or `[{ConstructorTostring("string","create",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)})`,`{WriteRichText("vector",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("create",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","create",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))})`
			else
				--constants
				if data==Vector3.one then
					return `Vector3{(ss.IndexingBy=="Dots" and ".one") or `[{ConstructorTostring("string","one",Bypass)}]`}`,`{WriteRichText("Vector3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("one",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","one",Bypass))}]`}`
				elseif data==Vector3.zero then
					return `Vector3{(ss.IndexingBy=="Dots" and ".zero") or `[{ConstructorTostring("string","zero",Bypass)}]`}`,`{WriteRichText("Vector3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("zero",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","zero",Bypass))}]`}`
				elseif data==Vector3.xAxis then
					return `Vector3{(ss.IndexingBy=="Dots" and ".xAxis") or `[{ConstructorTostring("string","xAxis",Bypass)}]`}`,`{WriteRichText("Vector3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("xAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","xAxis",Bypass))}]`}`
				elseif data==Vector3.yAxis then
					return `Vector3{(ss.IndexingBy=="Dots" and ".yAxis") or `[{ConstructorTostring("string","yAxis",Bypass)}]`}`,`{WriteRichText("Vector3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("yAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","yAxis",Bypass))}]`}`
				elseif data==Vector3.zAxis then
					return `Vector3{(ss.IndexingBy=="Dots" and ".zAxis") or `[{ConstructorTostring("string","zAxis",Bypass)}]`}`,`{WriteRichText("Vector3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("zAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","zAxis",Bypass))}]`}`
				end
				--Vector3
				return `Vector3{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)})`,`{WriteRichText("Vector3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))})`
			end
		end;
		Vector3int16 = function(data:Vector3int16,Bypass:true?):(string,string)
			return `Vector3int16{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Z,Bypass)})`,`{WriteRichText("Vector3int16",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Z,Bypass))})`
		end;
		BrickColor = function(data:BrickColor,Bypass:true?):(string,string)
			return `BrickColor{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("string",data.Name,Bypass)})`,`{WriteRichText("BrickColor",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("string",data.Name,Bypass))})`
		end;
		Color3 = function(data:Color3,Bypass:true?):(string,string)
			if ss.Color3Format=="Color3_new" then
				local R,G,B = math.round(data.R*1_000_000)/1_000_000,math.round(data.G*1_000_000)/1_000_000,math.round(data.B*1_000_000)/1_000_000
				return `Color3{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",R,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",G,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",B,Bypass)})`,`{WriteRichText("Color3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",R,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",G,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",B,Bypass))})`
			elseif ss.Color3Format=="Color3_fromRGB" then
				local R,G,B = math.round(data.R*255),math.round(data.G*255),math.round(data.B*255)
				return `Color3{(ss.IndexingBy=="Dots" and ".fromRGB") or `[{ConstructorTostring("string","fromRGB",Bypass)}]`}({ConstructorTostring("number",R,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",G,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",B,Bypass)})`,`{WriteRichText("Color3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromRGB",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromRGB",Bypass))}]`}({select(2,ConstructorTostring("number",R,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",G,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",B,Bypass))})`
			elseif ss.Color3Format=="Color3_fromHEX" then
				local HEX:string = `#{data:ToHex()}`
				return `Color3{(ss.IndexingBy=="Dots" and ".fromHex") or `[{ConstructorTostring("string","fromHex",Bypass)}]`}({ConstructorTostring("string",HEX,Bypass)})`,`{WriteRichText("Color3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromHex",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromHex",Bypass))}]`}({select(2,ConstructorTostring("string",HEX,Bypass))})`
			else--Color3_fromHSV
				local H,S,V = data:ToHSV()
				H,S,V = math.round(H*1_000_000)/1_000_000,math.round(S*1_000_000)/1_000_000,math.round(V*1_000_000)/1_000_000
				return `Color3{(ss.IndexingBy=="Dots" and ".fromHSV") or `[{ConstructorTostring("string","fromHSV",Bypass)}]`}({ConstructorTostring("number",H,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",S,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",V,Bypass)})`,`{WriteRichText("Color3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromHSV",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromHSV",Bypass))}]`}({select(2,ConstructorTostring("number",H,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",S,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",V,Bypass))})`
			end
		end;
		CFrame = function(data:CFrame,Bypass:true?):(string,string)
			--Empty cframe
			if data==CFrame.identity then
				return `CFrame{(ss.IndexingBy=="Dots" and ".identity") or `[{ConstructorTostring("string","identity",Bypass)}]`}`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("identity",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","identity",Bypass))}]`}`
			end
			--CFrame
			local x,y,z = data:ToOrientation()
			if x==0 and y==0 and z==0 then--No rotation
				local X,Y,Z = Round(data.X),Round(data.Y),Round(data.Z)
				return `CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))})`
			elseif data.Position.Magnitude==0 then--No position
				if ss.CFrameFormatting=="CFrameNewYXZRotation" then
					local rX,rX_rich = ToMatrixUnit(x)
					local rY,rY_rich = ToMatrixUnit(y)
					local rZ,rZ_rich = ToMatrixUnit(z)
					return `CFrame{(ss.IndexingBy=="Dots" and `.fromEulerAnglesYXZ`) or `[{ConstructorTostring("string","fromEulerAnglesYXZ",Bypass)}]`}({rX}{ss.FuncSeparator}{rY}{ss.FuncSeparator}{rZ})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromEulerAnglesYXZ",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromEulerAnglesYXZ",Bypass))}]`}({rX_rich}{ss.FuncSeparator}{rY_rich}{ss.FuncSeparator}{rZ_rich})`
				elseif ss.CFrameFormatting=="CFrameNewPlusAngles" then
					x,y,z = data:ToEulerAnglesXYZ()
					local rX,rX_rich = ToMatrixUnit(x)
					local rY,rY_rich = ToMatrixUnit(y)
					local rZ,rZ_rich = ToMatrixUnit(z)
					return `CFrame{(ss.IndexingBy=="Dots" and `.Angles`) or `[{ConstructorTostring("string","Angles",Bypass)}]`}({rX}{ss.FuncSeparator}{rY}{ss.FuncSeparator}{rZ})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("Angles",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","Angles",Bypass))}]`}({rX_rich}{ss.FuncSeparator}{rY_rich}{ss.FuncSeparator}{rZ_rich})`
				elseif ss.CFrameFormatting=="Quaternions" then
					local X,Y,Z,qX,qY,qZ,qW:number = data.X,data.Y,data.Z,ToQuaternion(data)
					X,Y,Z = Round(X),Round(Y),Round(Z)
					return `CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qX,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qY,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qZ,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qW,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qX,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qY,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qZ,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qW,Bypass))})`
				else--RawCFrameNew
					local X,Y,Z,R00,R01,R02,R10,R11,R12,R20,R21,R22 = data:GetComponents()
					X,Y,Z = Round(X),Round(Y),Round(Z)
					return `CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R00,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R01,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R02,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R10,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R11,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R12,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R20,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R21,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R22,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R00,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R01,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R02,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R10,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R11,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R12,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R20,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R21,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R22,Bypass))})`
				end
			else--Has rotation and position
				if ss.CFrameFormatting=="CFrameNewYXZRotation" or ss.CFrameFormatting=="CFrameNewPlusAngles" then
					local X,Y,Z = Round(data.X),Round(data.Y),Round(data.Z)
					local txt,rich = ConstructorTostring("CFrame",data.Rotation)
					return `{(ss.FNC_UserData==true and `{ss.NC_CfrMul}(`) or ""}CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}){(ss.FNC_UserData==true and ss.FuncSeparator) or ss.Mult}{txt}{(ss.FNC_UserData==true and `){(ss.Typechecking==true and `{ss.TC_Casting}CFrame`) or ""}`) or ""}`,`{(ss.FNC_UserData==true and `{WriteRichText(ss.NC_CfrMul,ScriptMethod)}(`) or ""}{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}){(ss.FNC_UserData==true and ss.FuncSeparator) or ss.Mult}{rich}{(ss.FNC_UserData==true and `){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText("CFrame",Color3.new(0,1,1))}`) or ""}`) or ""}`
				elseif ss.CFrameFormatting=="Quaternions" then
					local X,Y,Z,qX,qY,qZ,qW:number = data.X,data.Y,data.Z,ToQuaternion(data)
					X,Y,Z = Round(X),Round(Y),Round(Z)
					return `CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qX,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qY,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qZ,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",qW,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qX,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qY,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qZ,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",qW,Bypass))})`
				else--RawCFrameNew
					local X,Y,Z,R00,R01,R02,R10,R11,R12,R20,R21,R22 = data:GetComponents()
					X,Y,Z = Round(X),Round(Y),Round(Z)
					return `CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R00,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R01,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R02,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R10,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R11,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R12,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R20,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R21,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R22,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R00,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R01,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R02,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R10,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R11,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R12,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R20,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R21,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R22,Bypass))})`
				end
			end
		end;
		Axes = function(data:Axes,Bypass:true?):(string,string)
			return `Axes{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}()`,`{WriteRichText("Axes",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}()`
		end;
		ColorSequenceKeypoint = function(data:ColorSequenceKeypoint,Bypass:true?):(string,string)
			local color,rich = ConstructorTostring("Color3",data.Value)
			return `ColorSequenceKeypoint{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.Time,Bypass)}{ss.FuncSeparator}{color})`,`{WriteRichText("ColorSequenceKeypoint",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.Time,Bypass))}{ss.FuncSeparator}{rich})`
		end;
		ColorSequence = function(data:ColorSequence,Bypass:true?):(string,string)
			local txt,rich = "",""
			if #data.Keypoints>=3 then
				txt,rich = "{","{"
				for i,v in data.Keypoints do
					local t,r = ConstructorTostring("ColorSequenceKeypoint",v,Bypass)
					txt..=`{t}{ss._Separator}`
					rich..=`{r}{ss._Separator}`
				end
				txt..="}";rich..="}"
			elseif data.Keypoints[1].Value~=data.Keypoints[2].Value then
				txt = `{ConstructorTostring("Color3",data.Keypoints[1].Value,Bypass)}{ss.FuncSeparator}{ConstructorTostring("Color3",data.Keypoints[2].Value,Bypass)}`
				rich = `{select(2,ConstructorTostring("Color3",data.Keypoints[1].Value,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("Color3",data.Keypoints[2].Value,Bypass))}`
			else--1
				txt = `{ConstructorTostring("Color3",data.Keypoints[1].Value,Bypass)}`
				rich = `{select(2,ConstructorTostring("Color3",data.Keypoints[1].Value,Bypass))}`
			end
			return `ColorSequence{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("ColorSequence",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		Faces = function(data:Faces,Bypass:true?):(string,string)
			local txt,rich = "",""
			for i,v in Enum.NormalId:GetEnumItems() do
				if (data :: any)[v.Name] then
					if txt~="" then
						txt..=ss.FuncSeparator
						rich..=ss.FuncSeparator
					end
					txt..=ConstructorTostring("EnumItem",v,Bypass);rich..=select(2,ConstructorTostring("EnumItem",v,Bypass))
				end
			end
			return `Faces{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("Faces",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		FloatCurveKey = function(data:FloatCurveKey,Bypass:true?):(string,string)
			return `FloatCurveKey{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.Time,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Value,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Interpolation,Bypass)})`,`{WriteRichText("FloatCurveKey",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.Time,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Value,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Interpolation,Bypass))})`	
		end;
		Font = function(data:Font,Bypass:true?):(string,string)
			return `Font{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("string",data.Family,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Weight,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Style,Bypass)})`,`{WriteRichText("Font",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("string",data.Family,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Weight,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Style,Bypass))})`
		end;
		NumberRange = function(data:NumberRange,Bypass:true?):(string,string)
			return `NumberRange{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({(data.Min==data.Max and `{ConstructorTostring("number",data.Max,Bypass)}`) or `{ConstructorTostring("number",data.Min,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Max,Bypass)}`})`,`{WriteRichText("NumberRange",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({(data.Min==data.Max and `{select(2,ConstructorTostring("number",data.Max,Bypass))}`) or `{select(2,ConstructorTostring("number",data.Min,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Max,Bypass))}`})`
		end;
		NumberSequenceKeypoint = function(data:NumberSequenceKeypoint,Bypass:true?):(string,string)
			return `NumberSequenceKeypoint{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.Time,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Value,Bypass)}{(data.Envelope~=0 and `{ss.FuncSeparator}{ConstructorTostring("number",data.Envelope,Bypass)}`) or ""})`,`{WriteRichText("NumberSequenceKeypoint",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.Time,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Value,Bypass))}{(data.Envelope~=0 and `{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Envelope,Bypass))}`) or ""})`
		end;
		NumberSequence = function(data:NumberSequence,Bypass:true?):(string,string)
			local txt,rich = "",""
			if #data.Keypoints>=3 then
				txt,rich = "{","{"
				for i,v in data.Keypoints do
					local t,r = ConstructorTostring("NumberSequenceKeypoint",v,Bypass)
					txt..=`{t}{ss._Separator}`
					rich..=`{r}{ss._Separator}`
				end
				txt..="}";rich..="}"
			elseif data.Keypoints[1].Value~=data.Keypoints[2].Value then
				txt = `{ConstructorTostring("number",data.Keypoints[1].Value,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Keypoints[2].Value,Bypass)}`
				rich = `{select(2,ConstructorTostring("number",data.Keypoints[1].Value,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Keypoints[2].Value,Bypass))}`
			else--1
				txt = `{ConstructorTostring("number",data.Keypoints[1].Value,Bypass)}`
				rich = `{select(2,ConstructorTostring("number",data.Keypoints[1].Value,Bypass))}`
			end
			return `NumberSequence{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("NumberSequence",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		Path2DControlPoint = function(data:Path2DControlPoint,Bypass:true?):(string,string)
			local txt,rich = "",""
			if data.LeftTangent~=UDim2_zero and data.RightTangent~=UDim2_zero then
				--Full constructor
				txt = `{ConstructorTostring("UDim2",data.Position,Bypass)}{ss.FuncSeparator}{ConstructorTostring("UDim2",data.LeftTangent,Bypass)}{ss.FuncSeparator}{ConstructorTostring("UDim2",data.RightTangent,Bypass)}`
				rich = `{select(2,ConstructorTostring("UDim2",data.Position,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("UDim2",data.LeftTangent,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("UDim2",data.RightTangent,Bypass))}`
			elseif data.Position~=UDim2_zero then
				--Position only
				txt = `{ConstructorTostring("UDim2",data.Position,Bypass)}`
				rich = `{select(2,ConstructorTostring("UDim2",data.Position,Bypass))}`
			end
			return `Path2DControlPoint{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("Path2DControlPoint",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		PathWaypoint = function(data:PathWaypoint,Bypass:true?):(string,string)
			return `PathWaypoint{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("Vector3",data.Position,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Action,Bypass)}{(data.Label~="" and `{ss.FuncSeparator}{ConstructorTostring("string",data.Label,Bypass)}`) or ""})`,`{WriteRichText("PathWaypoint",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("Vector3",data.Position,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Action,Bypass))}{(data.Label~="" and `{ss.FuncSeparator}{select(2,ConstructorTostring("string",data.Label,Bypass))}`) or ""})`
		end;
		PhysicalProperties = function(data:PhysicalProperties,Bypass:true?):(string,string)
			local txt,rich = "",""
			for i,v in Enum.Material:GetEnumItems() do
				if data==PhysicalProperties.new(v) then
					txt = `{ConstructorTostring("EnumItem",v,Bypass)}`
					rich = `{select(2,ConstructorTostring("EnumItem",v,Bypass))}`
					break
				end
			end
			if txt=="" then
				if data.FrictionWeight==1 and data.ElasticityWeight==1 then--3 args
					txt = `{ConstructorTostring("EnumItem",data.Density,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Friction,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Elasticity,Bypass)}`
					rich = `{select(2,ConstructorTostring("EnumItem",data.Density,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Friction,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Elasticity,Bypass))}`
				else--All args
					txt = `{ConstructorTostring("EnumItem",data.Density,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Friction,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.Elasticity,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.FrictionWeight,Bypass)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",data.ElasticityWeight,Bypass)}`
					rich = `{select(2,ConstructorTostring("EnumItem",data.Density,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Friction,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.Elasticity,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.FrictionWeight,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",data.ElasticityWeight,Bypass))}`
				end
			end
			return `PhysicalProperties{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("PhysicalProperties",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		Ray = function(data:Ray,Bypass:true?):(string,string)
			return `Ray{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("Vector3",data.Origin,Bypass)}{ss.FuncSeparator}{ConstructorTostring("Vector3",data.Direction,Bypass)})`,`{WriteRichText("Ray",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("Vector3",data.Origin,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("Vector3",data.Direction,Bypass))})`
		end;
		Rect = function(data:Rect,Bypass:true?):(string,string)
			local txt,rich = "",""
			if data~=Rect_zero then
				txt = `{ConstructorTostring("number",data.Min.X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Min.Y)}{ss.FuncSeparator}{ConstructorTostring("number",data.Max.X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Max.Y,Bypass)}`
				rich = `{select(2,ConstructorTostring("number",data.Min.X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Min.Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Max.X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Max.Y,Bypass))}`
			end
			return `Rect{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("Rect",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		Region3 = function(data:Region3,Bypass:true?):(string,string)
			local min,max = data.CFrame.Position-data.Size*0.5,data.CFrame.Position+data.Size*0.5
			return `Region3{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("Vector3",min,Bypass)}{ss.FuncSeparator}{ConstructorTostring("Vector3",max,Bypass)})`,`{WriteRichText("Region3",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("Vector3",min,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("Vector3",max,Bypass))})`
		end;
		Region3int16 = function(data:Region3int16,Bypass:true?):(string,string)
			return `Region3int16{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("Vector3int16",data.Min,Bypass)}{ss.FuncSeparator}{ConstructorTostring("Vector3int16",data.Max,Bypass)})`,`{WriteRichText("Region3int16",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("Vector3int16",data.Min,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("Vector3int16",data.Max,Bypass))})`
		end;
		UDim = function(data:UDim,Bypass:true?):(string,string)
			return `UDim{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.Scale,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Offset,Bypass)})`,`{WriteRichText("UDim",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.Scale,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Offset,Bypass))})`
		end;
		UDim2 = function(data:UDim2,Bypass:true?):(string,string)
			if ss.UDIM2_MoreConstructors==true then
				if data.X.Offset==0 and data.Y.Offset==0 and (data.X.Scale~=0 or data.Y.Scale~=0) then
					--Scale constructor
					return `UDim2{(ss.IndexingBy=="Dots" and `.fromScale`) or `[{ConstructorTostring("string","fromScale",Bypass)}]`}({ConstructorTostring("number",data.X.Scale,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",(data::UDim2).Y.Scale,Bypass)})`,`{WriteRichText("UDim2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromScale",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromScale",Bypass))}]`}({select(2,ConstructorTostring("number",data.X.Scale,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y.Scale,Bypass))})`
				elseif (data.X.Offset~=0 or (data::UDim2).Y.Offset~=0) and data.X.Scale==0 and (data::UDim2).Y.Scale==0 then
					--Offset constructor
					return `UDim2{(ss.IndexingBy=="Dots" and `.fromOffset`) or `[{ConstructorTostring("string","fromOffset",Bypass)}]`}({ConstructorTostring("number",data.X.Offset,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",(data::UDim2).Y.Offset,Bypass)})`,`{WriteRichText("UDim2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromOffset",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromOffset",Bypass))}]`}({select(2,ConstructorTostring("number",data.X.Offset,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y.Offset,Bypass))})`
				end
			end
			return `UDim2{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.X.Scale,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.X.Offset,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Y.Scale,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Y.Offset,Bypass)})`,`{WriteRichText("UDim2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.X.Scale,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.X.Offset,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y.Scale,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y.Offset,Bypass))})`
		end;
		string = function(data:string,Bypass:true?):(string,string)
			--Its for a joke mainly idk why i added that
			if Bypass==true then return `"{data}"`,WriteRichText(`"{data}"`,ScriptString) end
			if ss.HexademicalString==true then
				local ret:string = ""
				for s,e in utf8.graphemes(data) do
					local char:string = string.sub(data,s,e)
					for i = 1, #char do
						local byte:number = string.byte(char, i)
						ret..=`\\x{string.format("%02X", byte)}`
					end
				end
				return `"{ret}"`,WriteRichText(`"{ret}"`,ScriptString)
			end
			-------------------------------------
			data = string.gsub(data,match_escapes_str_ptrn,escapes_str)
			--data=data:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t"):gsub("\r","\\r"):gsub("\"","\\\""):gsub("\b","\\b"):gsub("\v","\\v"):gsub("\f","\\f"):gsub("\"",`\"`)
			return `"{data}"`,WriteRichText(`"{data}"`,ScriptString)
		end;
		SecurityCapabilities = function(data:SecurityCapabilities,Bypass:true?):(string,string)
			local txt,rich = "",""
			for i,v in Enum.SecurityCapability:GetEnumItems() do
				if data:Contains(v) then
					if txt~="" then
						txt..=ss.FuncSeparator
						rich..=ss.FuncSeparator
					end
					txt..=ConstructorTostring("EnumItem",v,Bypass);rich..=select(2,ConstructorTostring("EnumItem",v,Bypass))
				end
			end
			txt=string.sub(txt,#ss.FuncSeparator,-1);rich=string.sub(rich,#ss.FuncSeparator,-1)
			return `SecurityCapabilities{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({txt})`,`{WriteRichText("SecurityCapabilities",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({rich})`
		end;
		_Default = function(data:any):(string,string)
			return tostring(data),WriteRichText(tostring(data),ScriptLuauKeyword)
		end
	}::typeof(ConstructorTostring_Switch)

	do
		local function TableTostring(tbl:{[any]:any}|any,Bypass:true?,Level:number?):(string,string)
			Level = (Level or 1)::number
			local tbl_txt,tbl_rich = "{\n","{\n"
			for i,v in spairs(tbl) do
				if type(i)~="number" or i%1~=0 or (i~=1 and tbl[i-1]==nil) then
					local regular,rich = ConstructorTostring(typeof(i),i,true)
					tbl_txt..=`{string.rep("\t",Level)}[{regular}]{ss._Equal}`
					tbl_rich..=`{string.rep("\t",Level)}[{rich}]{ss._Equal}`
				else
					tbl_txt..=string.rep("\t",Level)
					tbl_rich..=string.rep("\t",Level)
				end
				if type(v)=="table" then
					local regular,rich = TableTostring(v::{[any]:any},Bypass,Level+1)
					tbl_txt..=regular..`{ss._Separator}\n`
					tbl_rich..=rich..`{ss._Separator}\n`
				else
					local regular,rich = ConstructorTostring(typeof(v),v,true)
					tbl_txt..=regular..`{ss._Separator}\n`
					tbl_rich..=rich..`{ss._Separator}\n`
				end
			end
			tbl_txt..=string.rep("\t",Level-1).."}"
			tbl_rich..=string.rep("\t",Level-1).."}"
			return tbl_txt,tbl_rich
		end
		ConstructorTostring_Switch.table=function(tbl:{[any]:any}|any,Bypass:true?):(string,string)
			return TableTostring(tbl,Bypass)
		end
	end
end)()
local pathMacro:{[Instance]:string}


local IgnoredPropertiesList:{[string]:any}
;(function():()
	local IgnoreProp_Def_TextSource:string = [[return {
	BasePart = {
		"BrickColor";
		"Position";
		"Rotation";
		"Orientation";
	};
	LuaSourceContainer = {"Source"};
	Motor6D = {"Transform"};
	Tool = {
		"GripForward";
		"GripPos";
		"GripRight";
		"GripUp";
	};
	GuiObject = {"Transparency";"Font"};
}]]
	local _try,ret = pcall(Parser,plugin:GetSetting("NE_IgnoreProperties") or IgnoredPropertiesList)
	if _try and type(ret)=="table" then
		IgnoredPropertiesList = ret
	else
		IgnoredPropertiesList={["BasePart"]={"BrickColor";"Position";"Rotation";"Orientation";};["LuaSourceContainer"]={"Source"};["Motor6D"]={"Transform"};["Tool"]={"GripForward";"GripPos";"GripRight";"GripUp";};["GuiObject"]={"Transparency";"Font"};}
	end



	local IgnoredProperties_Button_Frame = LowerBar:WaitForChild("Ignored_Properties")
	local Frame1 = IgnoredProperties_Button_Frame:WaitForChild("Frame1")
	local Frame2 = IgnoredProperties_Button_Frame:WaitForChild("Frame2")
	local Button = IgnoredProperties_Button_Frame:WaitForChild("Button")
	local Exit = Ignored_Properies:WaitForChild("Exit")
	local __Edit = Ignored_Properies:WaitForChild("Edit")
	local EFrame,EFrame1,EFrame2 = Exit:WaitForChild("Frame"),Exit:WaitForChild("Frame1"),Exit:WaitForChild("Frame2")
	local Import = Ignored_Properies:WaitForChild("Import")
	local IFrame,IFrame1,IFrame2 = Import:WaitForChild("Frame"),Import:WaitForChild("Frame1"),Import:WaitForChild("Frame2")
	local ContentScroll = Ignored_Properies:WaitForChild("Content")
	local Input_Rich = ContentScroll:WaitForChild("Rich")

	Input_Rich:GetPropertyChangedSignal("TextBounds"):Connect(function():()
		ContentScroll.CanvasSize=UDim2.new(0,Input_Rich.TextBounds.X,0,Input_Rich.TextBounds.Y)
	end)
	local function AdjustTextSize():()
		Input_Rich.TextSize=ss.CodeOutputTextSize
	end
	local __IgnoreProperties__ModuleCurrent = Instance.new("ModuleScript")
	__IgnoreProperties__ModuleCurrent.Archivable=false
	__IgnoreProperties__ModuleCurrent.Name = `IgnoredProperties_{LocalUserName}`
	AddPluginGC(__IgnoreProperties__ModuleCurrent)
	pcall(SetProperty,__IgnoreProperties__ModuleCurrent,"Source",plugin:GetSetting("NE_IgnoreProperties") or IgnoreProp_Def_TextSource)

	OnConvert.Event:Connect(AdjustTextSize)
	task.defer(AdjustTextSize)
	table.insert(BrightestText_Theme,Import)
	table.insert(BrightestText_Theme,Exit)
	table.insert(BrightestText_Theme,Button)
	table.insert(BrightestText_Theme,__Edit)
	table.insert(ScriptTextColor_List,Input_Rich)
	table.insert(LightThemeColor_List,Ignored_Properies)
	ContentScroll:SetAttribute("Enabled",true)
	table.insert(Properties_ItemColor,ContentScroll)
	local Import_IsHower:boolean = false
	local Exit_IsHower:boolean = false
	local __Edit_IsHower:boolean = false
	__Edit.MouseEnter:Connect(function():()
		__Edit.BackgroundColor3=LowerBar_Convert_Color_Enter
		__Edit_IsHower=true
	end)
	__Edit.MouseLeave:Connect(function():()
		__Edit.BackgroundColor3=LowerBar_Convert_Color_Leave
		__Edit_IsHower=false
	end)
	__Edit.MouseButton1Down:Connect(function():()
		__Edit.BackgroundColor3=LowerBar_Convert_Color_Click
	end)
	__Edit.MouseButton1Up:Connect(function():()
		if __Edit_IsHower then __Edit.BackgroundColor3=LowerBar_Convert_Color_Enter return end
		__Edit.BackgroundColor3=LowerBar_Convert_Color_Leave
	end)

	__Edit.MouseButton1Click:Connect(function():()
		__IgnoreProperties__ModuleCurrent.Parent = game
		local try,err = ScriptEditorService:OpenScriptDocumentAsync(__IgnoreProperties__ModuleCurrent)
		if try==false then
			task.spawn(game.Destroy,__IgnoreProperties__ModuleCurrent)
			local n = Instance.new("ModuleScript")
			n.Archivable=false
			__IgnoreProperties__ModuleCurrent = n
			n.Name = `IgnoredProperties_{LocalUserName}`
			AddPluginGC(n)
			pcall(SetProperty,n,"Source",plugin:GetSetting("NE_IgnoreProperties") or IgnoreProp_Def_TextSource)
		end
	end)

	Button.MouseEnter:Connect(function():()
		IgnoredProperties_Button_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
		Button.BackgroundColor3=LowerBar_Convert_Color_Enter
		Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
		Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
	end)
	Button.MouseLeave:Connect(function():()
		IgnoredProperties_Button_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
		Button.BackgroundColor3=LowerBar_Convert_Color_Leave
		Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
		Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
	end)
	Exit.MouseEnter:Connect(function():()
		EFrame.BackgroundColor3=LowerBar_Convert_Color_Enter
		EFrame1.BackgroundColor3=LowerBar_Convert_Color_Enter
		EFrame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		Exit_IsHower=true
	end)
	Import.MouseEnter:Connect(function():()
		IFrame.BackgroundColor3=LowerBar_Convert_Color_Enter
		IFrame1.BackgroundColor3=LowerBar_Convert_Color_Enter
		IFrame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		Import_IsHower=true
	end)
	Exit.MouseLeave:Connect(function():()
		EFrame.BackgroundColor3=LowerBar_Convert_Color_Leave
		EFrame1.BackgroundColor3=LowerBar_Convert_Color_Leave
		EFrame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		Exit_IsHower=false
	end)
	Exit.MouseButton1Down:Connect(function()
		EFrame.BackgroundColor3=LowerBar_Convert_Color_Click
		EFrame1.BackgroundColor3=LowerBar_Convert_Color_Click
		EFrame2.BackgroundColor3=LowerBar_Convert_Color_Click
	end)
	Exit.MouseButton1Up:Connect(function()
		if Exit_IsHower then
			EFrame.BackgroundColor3=LowerBar_Convert_Color_Enter
			EFrame1.BackgroundColor3=LowerBar_Convert_Color_Enter
			EFrame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		else
			EFrame.BackgroundColor3=LowerBar_Convert_Color_Leave
			EFrame1.BackgroundColor3=LowerBar_Convert_Color_Leave
			EFrame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		end
	end)
	Import.MouseLeave:Connect(function():()
		IFrame.BackgroundColor3=LowerBar_Convert_Color_Leave
		IFrame1.BackgroundColor3=LowerBar_Convert_Color_Leave
		IFrame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		Import_IsHower=false
	end)
	Import.MouseButton1Down:Connect(function()
		IFrame.BackgroundColor3=LowerBar_Convert_Color_Click
		IFrame1.BackgroundColor3=LowerBar_Convert_Color_Click
		IFrame2.BackgroundColor3=LowerBar_Convert_Color_Click
	end)
	Import.MouseButton1Up:Connect(function()
		if Import_IsHower then
			IFrame.BackgroundColor3=LowerBar_Convert_Color_Enter
			IFrame1.BackgroundColor3=LowerBar_Convert_Color_Enter
			IFrame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		else
			IFrame.BackgroundColor3=LowerBar_Convert_Color_Leave
			IFrame1.BackgroundColor3=LowerBar_Convert_Color_Leave
			IFrame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		end
	end)
	Button.MouseButton1Click:Connect(function():()
		task.defer(RemoveSelectionButton)
		SelectButtonByName(CurrentConvertType)
		local tab = ViewTabs:FindFirstChild(CurrentConvertType)::Frame?
		if tab~=nil then
			tab.Visible = false
		end
		Ignored_Properies.Visible=true
		LowerBar.Visible=false
	end)
	Exit.MouseButton1Click:Connect(function():()
		task.defer(RemoveSelectionButton)
		SelectButtonByName(CurrentConvertType)
		Ignored_Properies.Visible=false
		LowerBar.Visible=true
	end)
	local function ApplyTable(tbl:{[any]:any},str:string?):()
		Input_Rich.Text=select(2,ConstructorTostring("table",tbl,true))
		if str~=nil then
			IgnoredPropertiesList=tbl
			plugin:SetSetting("NE_IgnoreProperties",str)
		end
	end

	ApplyTable(IgnoredPropertiesList)
	Import.MouseButton1Click:Connect(function():()
		--Parse table
		local txt:string = __IgnoreProperties__ModuleCurrent.Source
		task.spawn(game.Destroy,__IgnoreProperties__ModuleCurrent)
		local n = Instance.new("ModuleScript")
		n.Archivable=false
		__IgnoreProperties__ModuleCurrent = n
		n.Name = `IgnoredProperties_{LocalUserName}`
		AddPluginGC(n)
		pcall(SetProperty,n,"Source",txt)

		local try,res = pcall(Parser,txt)
		if try and type(res)=="table" then
			for i,v in res::{[any]:any} do
				if type(i)~="string" or type(v)~="table" then
					warn("Ensure you formatted table properly:",`Type has to be table: \{\n\tClassName{ss._Equal}\{...Banned properties here in array\}\n\}`,"Your example were:",res)
					return
				else
					for ii,vv in v do
						if type(ii)=="number" and type(vv)=="string" then continue end
						warn("Ensure you formatted table properly:",`Type has to be table: \{\n\tClassName{ss._Equal}\{...Banned properties here in array\}\n\}`,"Your example were:",res)
						return
					end
				end
			end
			ApplyTable(res,txt)
		elseif try then
			warn(`Type has to be table: \{\n\tClassName{ss._Equal}\{...Banned properties here in array\}\n\}`)
		else
			warn(res)
		end
		local n = Instance.new("ModuleScript")
		n.Archivable=false
		__IgnoreProperties__ModuleCurrent = n
		n.Name = `IgnoredProperties_{LocalUserName}`
		AddPluginGC(n)
		pcall(SetProperty,n,"Source",plugin:GetSetting("NE_IgnoreProperties") or IgnoreProp_Def_TextSource)
	end)
end)()

type _baseImports = {[string]:{[string]:any}}

local _baseImports:_baseImports


(function()-- Import_Base (register limit)
	local Import_Base = Main:WaitForChild("Import_Base")
	local Import_Constants = Main:WaitForChild("Import_Constants")
	local Import_Macro = Main:WaitForChild("Import_PathMacro")
	local _base = Import_Base:WaitForChild("_base")
	table.insert(LightThemeColor_List,Import_Base)
	table.insert(LightThemeColor_List,Import_Constants)
	table.insert(LightThemeColor_List,Import_Macro)
	do--Buttons
		local __Buttons = Import_Base:WaitForChild("Buttons")
		local Buttons = __Buttons:WaitForChild("Buttons")
		local CachedConsts = Buttons:WaitForChild("CachedConsts")
		local PathMacro = Buttons:WaitForChild("PathMacro")
		local _txtCachedConsts = CachedConsts:WaitForChild("TextLabel")
		local _txtPathMacro = PathMacro:WaitForChild("TextLabel")
		local db_PathMacro:boolean = false
		local db_CachedConsts:boolean = false
		local PathMacro_Frame = PathMacro:WaitForChild("Frame")
		local PathMacro_Frame2 = PathMacro:WaitForChild("Frame2")
		table.insert(BrightestText_Theme,_txtCachedConsts)
		table.insert(BrightestText_Theme,_txtPathMacro)
		CachedConsts.MouseEnter:Connect(function()
			db_CachedConsts=true
			_txtCachedConsts.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		CachedConsts.MouseLeave:Connect(function()
			db_CachedConsts=false
			_txtCachedConsts.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		CachedConsts.MouseButton1Down:Connect(function()
			_txtCachedConsts.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		CachedConsts.MouseButton1Up:Connect(function()
			if db_CachedConsts==true then
				_txtCachedConsts.BackgroundColor3=LowerBar_Convert_Color_Enter
			else
				_txtCachedConsts.BackgroundColor3=LowerBar_Convert_Color_Leave
			end
		end)
		PathMacro.MouseEnter:Connect(function()
			db_PathMacro=true
			_txtPathMacro.BackgroundColor3=LowerBar_Convert_Color_Enter
			PathMacro_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
			PathMacro_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		PathMacro.MouseLeave:Connect(function()
			db_PathMacro=false
			_txtPathMacro.BackgroundColor3=LowerBar_Convert_Color_Leave
			PathMacro_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			PathMacro_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		PathMacro.MouseButton1Down:Connect(function()
			_txtPathMacro.BackgroundColor3=LowerBar_Convert_Color_Click
			PathMacro_Frame.BackgroundColor3=LowerBar_Convert_Color_Click
			PathMacro_Frame2.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		PathMacro.MouseButton1Up:Connect(function()
			if db_PathMacro==true then
				_txtPathMacro.BackgroundColor3=LowerBar_Convert_Color_Enter
				PathMacro_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
				PathMacro_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			else
				_txtPathMacro.BackgroundColor3=LowerBar_Convert_Color_Leave
				PathMacro_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
				PathMacro_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			end
		end)
		CachedConsts.MouseButton1Click:Connect(function()
			Import_Base.Visible = false
			Import_Constants.Visible=true
		end)
		PathMacro.MouseButton1Click:Connect(function()
			Import_Base.Visible = false
			Import_Macro.Visible=true
		end)	
	end
	do--Constants
		local def_Constants_Source:string = [[return {[2.718281828459045]="math.exp(1)"}]]
		do
			local _try,ret = pcall(Parser,plugin:GetSetting("NE_cachedConstants") or def_Constants_Source)
			if _try and type(ret)=="table" then
				CachedConstants=ret
			else
				CachedConstants = {[2.718281828459045]="math.exp(1)"}
			end
		end
		local _constants = Import_Constants:WaitForChild("Constants")
		local __Edit = _constants:WaitForChild("Edit")
		table.insert(BrightestText_Theme,__Edit:WaitForChild("Title"))
		local __Edit_Title = __Edit:WaitForChild("Title")
		local __Edit_Frame = __Edit:WaitForChild("Frame")
		local __Edit_Frame2 = __Edit:WaitForChild("Frame2")

		local __Constants__ModuleCurrent = Instance.new("ModuleScript")
		__Constants__ModuleCurrent.Archivable=false
		__Constants__ModuleCurrent.Name = `Constants_{LocalUserName}`
		AddPluginGC(__Constants__ModuleCurrent)
		pcall(SetProperty,__Constants__ModuleCurrent,"Source",plugin:GetSetting("NE_cachedConstants") or def_Constants_Source)


		table.insert(Tab_EnumColor_List,_constants)
		table.insert(Tab_EnumColor_List,_constants:WaitForChild("Frame")::Frame)
		table.insert(BrightestText_Theme,_constants:WaitForChild("Title")::TextLabel)
		-------
		local Import_Exit_Frame = Import_Constants:WaitForChild("Exit_Frame")
		local Import_Frame1,Import_Frame2 = Import_Exit_Frame:WaitForChild("Frame1"),Import_Exit_Frame:WaitForChild("Frame2")
		local Import_Button = Import_Exit_Frame:WaitForChild("Exit")
		local _backImport_Exit_Frame = Import_Constants:WaitForChild("Exit_Back")
		local _backImport_Frame1,_backImport_Frame2 = _backImport_Exit_Frame:WaitForChild("Frame1"),_backImport_Exit_Frame:WaitForChild("Frame2")
		local _backImport_Button = _backImport_Exit_Frame:WaitForChild("Button")

		--adding highlights
		local Import_box = _constants:WaitForChild("Import")
		local Import_Label = Import_box:WaitForChild("Label")
		local Imported_Scroll = _constants:WaitForChild("Imported_Scroll")
		local Rich = Imported_Scroll:WaitForChild("Rich")
		local EnterState:boolean = false
		table.insert(BrightestText_Theme,Import_Label)
		table.insert(BrightestText_Theme,Import_Label:WaitForChild("TextLabel"))
		table.insert(BrightestText_Theme,Import_Button)
		table.insert(BrightestText_Theme,_backImport_Button)
		----
		----||Visuals||----
		Import_box.MouseEnter:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		Import_box.MouseLeave:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_box.MouseButton1Down:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		Import_box.MouseButton1Up:Connect(function()
			if EnterState then
				Import_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
			else
				Import_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
			end
		end)


		local __Edit_IsHower:boolean = false
		__Edit.MouseEnter:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_IsHower=true
		end)
		__Edit.MouseLeave:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_IsHower=false
		end)
		__Edit.MouseButton1Down:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Click
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Click
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		__Edit.MouseButton1Up:Connect(function():()
			if __Edit_IsHower then
				__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Enter 
				__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
				__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
				return 
			end
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)

		__Edit.MouseButton1Click:Connect(function():()
			__Constants__ModuleCurrent.Parent = game
			local try,err = ScriptEditorService:OpenScriptDocumentAsync(__Constants__ModuleCurrent)
			if try==false then
				task.spawn(game.Destroy,__Constants__ModuleCurrent)
				local n = Instance.new("ModuleScript")
				n.Archivable=false
				__Constants__ModuleCurrent = n
				n.Name = `Constants_{LocalUserName}`
				AddPluginGC(n)
				pcall(SetProperty,n,"Source",plugin:GetSetting("NE_cachedConstants") or def_Constants_Source)
			end
		end)

		local function AdjustTextSize():()
			Rich.TextSize=ss.CodeOutputTextSize
		end
		OnConvert.Event:Connect(AdjustTextSize)
		task.defer(AdjustTextSize)
		--table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptBackground_List,Imported_Scroll)
		table.insert(ScriptTextColor_List,Rich)
		table.insert(ScriptTextColor_List,__Edit)
		--strokes
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Imported_Scroll:WaitForChild("UIStroke")::UIStroke)
		----||-----------------------------------------------||----
		Rich:GetPropertyChangedSignal("TextBounds"):Connect(function():()
			Imported_Scroll.CanvasSize = UDim2.new(0,Rich.TextBounds.X,0,Rich.TextBounds.Y)
		end)
		Imported_Scroll.CanvasSize = UDim2.new(0,Rich.TextBounds.X,0,Rich.TextBounds.Y)

		Import_box.MouseButton1Click:Connect(function():()
			--Parse
			local Insert_txt:string = __Constants__ModuleCurrent.Source
			task.spawn(game.Destroy,__Constants__ModuleCurrent)
			local n = Instance.new("ModuleScript")
			n.Archivable=false
			__Constants__ModuleCurrent = n
			n.Name = `Constants_{LocalUserName}`
			AddPluginGC(n)
			pcall(SetProperty,n,"Source",Insert_txt)
			local try,parsed = pcall(Parser,Insert_txt)
			if try and type(parsed)=="table" then
				--Type validation
				for i,v in parsed::{[any]:any} do
					if type(v)~="string"  then
						warn("Ensure you formatted table properly:",`Type has to be table: \{\n\tValue{ss._Equal}string\n\}`,"Your example were:",parsed)
						return
					end
				end
				CachedConstants = parsed
				Rich.Text = select(2,ConstructorTostring("table",parsed,true))
				plugin:SetSetting("NE_cachedConstants",Insert_txt)
			elseif try then
				warn(`Type has to be table: \{\n\tValue{ss._Equal}string\n\}`)
			else
				warn(parsed)
			end
		end)
		Rich.Text = select(2,ConstructorTostring("table",CachedConstants,true))


		_backImport_Button.MouseEnter:Connect(function()
			_backImport_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
			_backImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
			_backImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			_backImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		Import_Button.MouseEnter:Connect(function()
			Import_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
			Import_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
			Import_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			Import_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		_backImport_Button.MouseLeave:Connect(function()
			_backImport_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
			_backImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
			_backImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			_backImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_Button.MouseLeave:Connect(function()
			Import_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
			Import_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
			Import_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			Import_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_Button.MouseButton1Click:Connect(function()
			task.defer(RemoveSelectionButton)
			SelectButtonByName(CurrentConvertType)
			Import_Constants.Visible=false
			LowerBar.Visible=true
		end)
		_backImport_Button.MouseButton1Click:Connect(function()
			Import_Base.Visible=true
			Import_Constants.Visible=false
		end)
	end
	do--PathMacro
		local def_pathmacro_source:string = "return {}"
		do
			local _try,ret = pcall(Parser,plugin:GetSetting("NE_pathMacro") or def_pathmacro_source)
			if _try and type(ret)=="table" then
				pathMacro=ret
			else
				pathMacro = {}
			end

		end

		local _pathMacro = Import_Macro:WaitForChild("PathMacro")
		local __Edit = _pathMacro:WaitForChild("Edit")
		table.insert(BrightestText_Theme,__Edit:WaitForChild("Title"))
		local __Edit_Title = __Edit:WaitForChild("Title")
		local __Edit_Frame = __Edit:WaitForChild("Frame")
		local __Edit_Frame2 = __Edit:WaitForChild("Frame2")

		local __PathMacro__ModuleCurrent = Instance.new("ModuleScript")
		__PathMacro__ModuleCurrent.Archivable=false
		__PathMacro__ModuleCurrent.Name = `PathMacro_{LocalUserName}`
		AddPluginGC(__PathMacro__ModuleCurrent)
		pcall(SetProperty,__PathMacro__ModuleCurrent,"Source",plugin:GetSetting("NE_pathMacro") or def_pathmacro_source)


		local __Edit_IsHower:boolean = false
		__Edit.MouseEnter:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_IsHower=true
		end)
		__Edit.MouseLeave:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_IsHower=false
		end)
		__Edit.MouseButton1Down:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Click
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Click
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		__Edit.MouseButton1Up:Connect(function():()
			if __Edit_IsHower then
				__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Enter 
				__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
				__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
				return 
			end
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)

		__Edit.MouseButton1Click:Connect(function():()
			__PathMacro__ModuleCurrent.Parent = game
			local try,err = ScriptEditorService:OpenScriptDocumentAsync(__PathMacro__ModuleCurrent)
			if try==false then
				task.spawn(game.Destroy,__PathMacro__ModuleCurrent)
				local n = Instance.new("ModuleScript")
				n.Archivable=false
				__PathMacro__ModuleCurrent = n
				n.Name = `PathMacro_{LocalUserName}`
				AddPluginGC(n)
				pcall(SetProperty,n,"Source",plugin:GetSetting("NE_pathMacro") or def_pathmacro_source)
			end
		end)

		table.insert(Tab_EnumColor_List,_pathMacro)
		table.insert(Tab_EnumColor_List,_pathMacro:WaitForChild("Frame")::Frame)
		table.insert(BrightestText_Theme,_pathMacro:WaitForChild("Title")::TextLabel)
		-------
		local Import_Exit_Frame = Import_Macro:WaitForChild("Exit_Frame")
		local Import_Frame1,Import_Frame2 = Import_Exit_Frame:WaitForChild("Frame1"),Import_Exit_Frame:WaitForChild("Frame2")
		local Import_Button = Import_Exit_Frame:WaitForChild("Exit")
		local _backImport_Exit_Frame = Import_Macro:WaitForChild("Exit_Back")
		local _backImport_Frame1,_backImport_Frame2 = _backImport_Exit_Frame:WaitForChild("Frame1"),_backImport_Exit_Frame:WaitForChild("Frame2")
		local _backImport_Button = _backImport_Exit_Frame:WaitForChild("Button")

		--adding highlights
		local Import_box = _pathMacro:WaitForChild("Import")
		local Import_Label = Import_box:WaitForChild("Label")
		local Imported_Scroll = _pathMacro:WaitForChild("Imported_Scroll")
		local Rich = Imported_Scroll:WaitForChild("Rich")
		local EnterState:boolean = false
		table.insert(BrightestText_Theme,Import_Button)
		table.insert(BrightestText_Theme,_backImport_Button)
		table.insert(BrightestText_Theme,Import_Label)
		table.insert(BrightestText_Theme,Import_Label:WaitForChild("TextLabel"))

		----
		----||Visuals||----
		Import_box.MouseEnter:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		Import_box.MouseLeave:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_box.MouseButton1Down:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		Import_box.MouseButton1Up:Connect(function()
			if EnterState then
				Import_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
			else
				Import_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
			end
		end)
		local function AdjustTextSize():()
			Rich.TextSize=ss.CodeOutputTextSize
		end
		OnConvert.Event:Connect(AdjustTextSize)
		task.defer(AdjustTextSize)
		--table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptTextColor_List,Rich)
		table.insert(ScriptTextColor_List,__Edit)
		--strokes
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Imported_Scroll:WaitForChild("UIStroke")::UIStroke)
		----||-----------------------------------------------||----
		Rich:GetPropertyChangedSignal("TextBounds"):Connect(function():()
			Imported_Scroll.CanvasSize = UDim2.new(0,Rich.TextBounds.X,0,Rich.TextBounds.Y)
		end)
		Imported_Scroll.CanvasSize = UDim2.new(0,Rich.TextBounds.X,0,Rich.TextBounds.Y)


		Import_box.MouseButton1Click:Connect(function():()
			--Parse
			local Insert_txt:string = __PathMacro__ModuleCurrent.Source
			task.spawn(game.Destroy,__PathMacro__ModuleCurrent)
			local n = Instance.new("ModuleScript")
			n.Archivable=false
			__PathMacro__ModuleCurrent = n
			n.Name = `PathMacro_{LocalUserName}`
			AddPluginGC(n)
			pcall(SetProperty,n,"Source",Insert_txt)

			local try,parsed = pcall(Parser,Insert_txt)
			if try and type(parsed)=="table" then
				--Type validation
				for i,v in parsed::{[any]:any} do
					if type(v)~="string" or typeof(i)~="Instance" then
						warn("Ensure you formatted table properly:",`Type has to be table: \{\n\tPath.To.Instance{ss._Equal}string\n\}`,"Your example were:",parsed)
						return
					end
				end
				pathMacro = parsed
				Rich.Text = select(2,ConstructorTostring("table",parsed,true))
				plugin:SetSetting("NE_pathMacro",Insert_txt)
			elseif try then
				warn(`Type has to be table: \{\n\tPath.To.Instance{ss._Equal}string\n\}`)
			else
				warn(parsed)
			end
		end)
		Rich.Text = select(2,ConstructorTostring("table",pathMacro,true))


		_backImport_Button.MouseEnter:Connect(function()
			_backImport_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
			_backImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
			_backImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			_backImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		Import_Button.MouseEnter:Connect(function()
			Import_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
			Import_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
			Import_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			Import_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		_backImport_Button.MouseLeave:Connect(function()
			_backImport_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
			_backImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
			_backImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			_backImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_Button.MouseLeave:Connect(function()
			Import_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
			Import_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
			Import_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			Import_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_Button.MouseButton1Click:Connect(function()
			task.defer(RemoveSelectionButton)
			SelectButtonByName(CurrentConvertType)
			Import_Macro.Visible=false
			LowerBar.Visible=true
		end)
		_backImport_Button.MouseButton1Click:Connect(function()
			Import_Base.Visible=true
			Import_Macro.Visible=false
		end)
	end

	table.insert(Tab_EnumColor_List,_base)
	table.insert(Tab_EnumColor_List,_base:WaitForChild("Frame")::Frame)

	local Import_Exit_Frame = Import_Base:WaitForChild("Exit_Frame")
	local Import_Frame1,Import_Frame2 = Import_Exit_Frame:WaitForChild("Frame1"),Import_Exit_Frame:WaitForChild("Frame2")
	local Import_Button = Import_Exit_Frame:WaitForChild("Exit")
	local _backImport_Exit_Frame = Import_Base:WaitForChild("Exit_Back")
	local _backImport_Frame1,_backImport_Frame2 = _backImport_Exit_Frame:WaitForChild("Frame1"),_backImport_Exit_Frame:WaitForChild("Frame2")
	local _backImport_Button = _backImport_Exit_Frame:WaitForChild("Button")
	local _goImport_Exit_Frame = LowerBar:WaitForChild("Open_Base_Frame")
	local _goImport_Frame1,_goImport_Frame2 = _goImport_Exit_Frame:WaitForChild("Frame1"),_goImport_Exit_Frame:WaitForChild("Frame2")
	local _goImport_Button = _goImport_Exit_Frame:WaitForChild("Button")
	table.insert(BrightestText_Theme,_goImport_Button)

	table.insert(BrightestText_Theme,_base:WaitForChild("Title"))

	do--_base
		local def_base_source:string = "return {}"
		do
			local _try,ret = pcall(Parser,plugin:GetSetting("NE_BaseImports") or def_base_source)
			if _try and type(ret)=="table" then
				_baseImports=ret
			else
				_baseImports = {}
			end
		end


		local __Edit = _base:WaitForChild("Edit")
		table.insert(BrightestText_Theme,__Edit:WaitForChild("Title"))
		local __Edit_Title = __Edit:WaitForChild("Title")
		local __Edit_Frame = __Edit:WaitForChild("Frame")
		local __Edit_Frame2 = __Edit:WaitForChild("Frame2")


		local __Base__ModuleCurrent = Instance.new("ModuleScript")
		__Base__ModuleCurrent.Archivable=false
		__Base__ModuleCurrent.Name = `Base_{LocalUserName}`
		AddPluginGC(__Base__ModuleCurrent)
		pcall(SetProperty,__Base__ModuleCurrent,"Source",plugin:GetSetting("NE_BaseImports") or def_base_source)

		local __Edit_IsHower:boolean = false
		__Edit.MouseEnter:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
			__Edit_IsHower=true
		end)
		__Edit.MouseLeave:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_IsHower=false
		end)
		__Edit.MouseButton1Down:Connect(function():()
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Click
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Click
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		__Edit.MouseButton1Up:Connect(function():()
			if __Edit_IsHower then
				__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Enter 
				__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
				__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
				return 
			end
			__Edit_Title.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
			__Edit_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)

		__Edit.MouseButton1Click:Connect(function():()
			__Base__ModuleCurrent.Parent = game
			local try,err = ScriptEditorService:OpenScriptDocumentAsync(__Base__ModuleCurrent)
			if try==false then
				task.spawn(game.Destroy,__Base__ModuleCurrent)
				local n = Instance.new("ModuleScript")
				n.Archivable=false
				__Base__ModuleCurrent = n
				n.Name = `Base_{LocalUserName}`
				AddPluginGC(n)
				pcall(SetProperty,n,"Source",plugin:GetSetting("NE_BaseImports") or def_base_source)
			end
		end)


		local Import_box = _base:WaitForChild("Import")
		local Import_Label = Import_box:WaitForChild("Label")
		local Imported_Scroll = _base:WaitForChild("Imported_Scroll")
		local Rich = Imported_Scroll:WaitForChild("Rich")
		local EnterState:boolean = false
		table.insert(BrightestText_Theme,Import_Label)
		table.insert(BrightestText_Theme,Import_Label:WaitForChild("TextLabel"))
		table.insert(BrightestText_Theme,Import_Button)
		table.insert(BrightestText_Theme,_backImport_Button)
		----||Visuals||----
		Import_box.MouseEnter:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
		end)
		Import_box.MouseLeave:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
		end)
		Import_box.MouseButton1Down:Connect(function()
			Import_Label.BackgroundColor3=LowerBar_Convert_Color_Click
		end)
		Import_box.MouseButton1Up:Connect(function()
			if EnterState then
				Import_Label.BackgroundColor3=LowerBar_Convert_Color_Enter
			else
				Import_Label.BackgroundColor3=LowerBar_Convert_Color_Leave
			end
		end)
		local function AdjustTextSize():()
			Rich.TextSize=ss.CodeOutputTextSize
		end
		OnConvert.Event:Connect(AdjustTextSize)
		task.defer(AdjustTextSize)
		--table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptTextColor_List,Rich)
		--strokes
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Imported_Scroll:WaitForChild("UIStroke")::UIStroke)
		----||-----------------------------------------------||----
		Rich:GetPropertyChangedSignal("TextBounds"):Connect(function():()
			Imported_Scroll.CanvasSize = UDim2.new(0,Rich.TextBounds.X,0,Rich.TextBounds.Y)
		end)
		Imported_Scroll.CanvasSize = UDim2.new(0,Rich.TextBounds.X,0,Rich.TextBounds.Y)

		Import_box.MouseButton1Click:Connect(function():()
			--Parse
			local Insert_txt:string = __Base__ModuleCurrent.Source
			task.spawn(game.Destroy,__Base__ModuleCurrent)
			local n = Instance.new("ModuleScript")
			n.Archivable=false
			__Base__ModuleCurrent = n
			n.Name = `Base_{LocalUserName}`
			AddPluginGC(n)
			pcall(SetProperty,n,"Source",Insert_txt)

			local try,parsed = pcall(Parser,Insert_txt)
			if try and type(parsed)=="table" then
				--Type validation
				for i,v in parsed::{[any]:any} do
					if type(i)~="string" or type(v)~="table"  then
						warn("Ensure you formatted table properly:",`Type has to be table: \{\n\t_BaseName{ss._Equal}\{\}\n\}`,"Your example were:",parsed)
						return
					end
				end
				_baseImports = parsed
				Rich.Text = select(2,ConstructorTostring("table",parsed,true))
				plugin:SetSetting("NE_BaseImports",Insert_txt)
			elseif try then
				warn(`Type has to be table: \{\n\t_BaseName{ss._Equal}\{\}\n\}`)
			else
				warn(parsed)
			end
		end)
		Rich.Text = select(2,ConstructorTostring("table",_baseImports,true))

	end
	--Base
	_goImport_Button.MouseEnter:Connect(function()
		_goImport_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
		_goImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
		_goImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		_goImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter 
	end)
	_goImport_Button.MouseLeave:Connect(function()
		_goImport_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
		_goImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
		_goImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		_goImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
	end)
	_goImport_Button.MouseButton1Click:Connect(function()
		task.defer(RemoveSelectionButton)
		SelectButtonByName(CurrentConvertType)
		local tab = ViewTabs:FindFirstChild(CurrentConvertType)::Frame?
		if tab~=nil then
			tab.Visible = false
		end
		Import_Base.Visible=true
		LowerBar.Visible=false
	end)

	_backImport_Button.MouseEnter:Connect(function()
		_backImport_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
		_backImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
		_backImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		_backImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
	end)
	Import_Button.MouseEnter:Connect(function()
		Import_Button.BackgroundColor3=LowerBar_Convert_Color_Enter
		Import_Frame1.BackgroundColor3=LowerBar_Convert_Color_Enter
		Import_Frame2.BackgroundColor3=LowerBar_Convert_Color_Enter
		Import_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Enter
	end)
	_backImport_Button.MouseLeave:Connect(function()
		_backImport_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
		_backImport_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
		_backImport_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		_backImport_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
	end)
	Import_Button.MouseLeave:Connect(function()
		Import_Button.BackgroundColor3=LowerBar_Convert_Color_Leave
		Import_Frame1.BackgroundColor3=LowerBar_Convert_Color_Leave
		Import_Frame2.BackgroundColor3=LowerBar_Convert_Color_Leave
		Import_Exit_Frame.BackgroundColor3=LowerBar_Convert_Color_Leave
	end)
	Import_Button.MouseButton1Click:Connect(function()
		task.defer(RemoveSelectionButton)
		SelectButtonByName(CurrentConvertType)
		Import_Base.Visible=false
		LowerBar.Visible=true
	end)
	_backImport_Button.MouseButton1Click:Connect(function()
		task.defer(RemoveSelectionButton)
		SelectButtonByName(CurrentConvertType)
		Import_Base.Visible=false
		LowerBar.Visible=true
	end)

end)()


do
	local sharedSettings,sharedSettings_Content = CreateTab("Shared Settings","rbxassetid://7059346373")
	local Nestify,Nestify_Content = CreateTab("Nestify","rbxassetid://103418028764678")
	local Raw_Luau,Raw_Luau_Content = CreateTab("Raw Luau","rbxassetid://18606791059")
	--Nestify.Visible=true
	BuildPropertiesList(sharedSettings_Content,require(script:WaitForChild("SharedSettings")))
	BuildPropertiesList(Nestify_Content,require(script:WaitForChild("Properties_Nestify")))
	BuildPropertiesList(Raw_Luau_Content,require(script:WaitForChild("Properties_RawLuau")))
end
local Converted_Code,Converted_Code_Content = CreateTab("Converted Code","rbxassetid://103299698303653")
do
	local EvilScroll = Converted_Code_Content.Parent::ScrollingFrame
	EvilScroll:Destroy()
end

--warn("YAY",Classes,Data)
for i,v in ViewTabs:GetChildren()::{Frame} do
	if v.Visible==true then
		local Button = UpperBar:FindFirstChild(v.Name)
		if Button==nil then continue end
		Button:SetAttribute("Enabled",true)
	end
end


local function GetTypeOfInstance(ins:Instance):string
	if ins.ClassName=="NegateOperation" then return "Part" end
	return (Classes[ins.ClassName]~=nil and ins.ClassName) or ss._ReplacementInstance
end

local function RecursionFindFirstChildSafeMethod(txt:string,rich:string,Index:number,Hierarchy:{Instance},Layer:number,PreviousVar:string,Value:{Text:string;Rich:string},ValueProperty:string):(string,string)
	local v:Instance? = Hierarchy[Index]
	local PreviousVar_Rich:string = PreviousVar
	if PreviousVar=="workspace" then
		PreviousVar_Rich = WriteRichText("workspace",ScriptBuiltInFunction)
	elseif PreviousVar=="game" then
		PreviousVar_Rich = WriteRichText("game",ScriptBuiltInFunction)
	end
	if v==nil then 
		--Assign value
		if ss.FNC_Properties==true then
			txt..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({Value.Text}{ss.FuncSeparator}{ConstructorTostring("string",ValueProperty)}{ss.FuncSeparator}{PreviousVar})`
			rich..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({Value.Rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",ValueProperty))}{ss.FuncSeparator}{PreviousVar})`
		else
			txt..=`\n{string.rep(ss.t,Layer)}{Value.Text}{(ss.Indexing_Instances_By=="Dots" and `.{ValueProperty}`) or `[{ConstructorTostring("string",ValueProperty)}]`}{ss._Equal}{PreviousVar}`
			rich..=`\n{string.rep(ss.t,Layer)}{Value.Rich}{(ss.Indexing_Instances_By=="Dots" and `.{WriteRichText(ValueProperty,ScriptProperty)}`) or `[{select(2,ConstructorTostring("string",ValueProperty))}]`}{ss._Equal}{PreviousVar_Rich}`
		end
		return txt,rich 
	end

	local sanitizedName:string = string.gsub(v.Name,"[^%w_]","_")
	if string.match(sanitizedName,"^%d") then
		sanitizedName = `_{sanitizedName}`
	end
	--variable
	local varName:string = `{(ss.SafeIndexSubtag=="" and v.Name=="" and "_") or ss.SafeIndexSubtag}{(ss.SafeIndexNaming=="SubtagPlusInstanceNamePlusNumber" and sanitizedName) or ""}{Index-1}`
	if ss.FastNamecall == true then
		txt..=`\n{string.rep(ss.t,Layer)}{ss._local}{varName}{ss._Equal}FindFirstChild({PreviousVar}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName}?`) or ""}`
		rich..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varName}{ss._Equal}{WriteRichText("FindFirstChild",ScriptMethod)}({PreviousVar_Rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))}?`) or ""}`
	else
		txt..=`\n{string.rep(ss.t,Layer)}{ss._local}{varName}{ss._Equal}{PreviousVar}:FindFirstChild({ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName}?`) or ""}`
		rich..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varName}{ss._Equal}{PreviousVar_Rich}:{WriteRichText("FindFirstChild",ScriptMethod)}({select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))}?`) or ""}`
	end
	--if statement
	txt..=`\n{string.rep(ss.t,Layer)}{ss["if"]}{varName}{ss["then"]}`
	rich..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss["if"],ScriptLuauKeyword)}{varName}{WriteRichText(ss["then"],ScriptLuauKeyword)}`
	txt,rich = RecursionFindFirstChildSafeMethod(txt,rich,Index+1,Hierarchy,Layer+1,varName,Value,ValueProperty)
	--End closing
	txt..=`\n{string.rep(ss.t,Layer)}{ss["end"]}`
	rich..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss["end"],ScriptLuauKeyword)}`
	return txt,rich
end
local function ___IsAProperty(ins:any,prop:string):any
	return ins[prop]
end
local function IsAProperty(ins:any|Instance,prop:string):boolean
	local try,res = pcall(___IsAProperty,ins,prop)
	return (try and ins:FindFirstChild(prop) ~= res) or ins:IsA("ObjectValue")
end

local function GoToIndexPath(ins:Instance,Recursive:Instance?,Value:{Text:string;Rich:string}?,ValueProperty:string?,Layer:number?):(string,string)
	local Layer:number = (Layer or 1)::number
	ValueProperty = (ValueProperty~=nil and ValueProperty) or "Unknown"
	local IsRecursive:boolean = (Recursive~=nil and (Recursive:IsDescendantOf(SelectedInstance::Instance) or ins==Recursive or SelectedInstance==Recursive)) or false
	local txt,rich = "",""

	local Mode:"SafeIndex"|"Index"|"WaitForChild" = ss.OutsideHierarchyInstances
	--Hierarchy
	local arraySize:number = 0
	local path:Instance? = ins
	while path~=nil do
		arraySize += 1
		path = path.Parent
	end
	local Hierarchy:{Instance} = table.create(arraySize)::{Instance}
	path = ins
	if IsRecursive==false then--Regular from top to bottom
		if Recursive~=nil then path = Recursive end
		while path::Instance?~=nil do
			table.insert(Hierarchy,1,path)
			if type(select(2,pcall(game.FindService,game,(path::Instance).ClassName::string))::Instance?|"string")=="userdata" or (pathMacro::{[Instance]:string})[path::Instance]~=nil then
				break
			end
			--Move up
			path=path.Parent::Instance
		end
	elseif Recursive~=nil then --Recursive
		while (path::Instance?)~=(Recursive::Instance) and (path::Instance?)~=nil do
			if Recursive:IsDescendantOf(path) then
				--go down
				for i,v in path:GetChildren() do
					if Recursive:IsDescendantOf(v) or v==Recursive then
						path=v::Instance
						table.insert(Hierarchy,path)
						break
					end
				end
			else
				--go up
				path=path.Parent::Instance
				table.insert(Hierarchy,path)
			end
		end
	end
	--Recursive
	if IsRecursive and Recursive~=nil then--Recursive
		if Value~=nil then
			txt,rich = Value.Text,Value.Rich	
		end
		for i,v in Hierarchy do
			if v:IsAncestorOf(ins) then
				--Down
				if ss.FNC_Properties==true then
					txt = `{ss.NC_InsIndex}({txt}{ss.FuncSeparator}{ConstructorTostring("string","Parent")}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName}`) or ""}`
					rich = `{WriteRichText(ss.NC_InsIndex,ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string","Parent"))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))}`) or ""}`
					continue
				elseif ss.Indexing_Instances_By=="Dots" then
					txt =`{(ss.Typechecking==true and "(")or""}{txt}.Parent{(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
					rich =`{(ss.Typechecking==true and "(")or""}{rich}.{WriteRichText("Parent",ScriptProperty)}{(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
					continue
				end
				txt =`{(ss.Typechecking==true and "(")or""}{txt}[{ConstructorTostring("string","Parent")}]{(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
				rich =`{(ss.Typechecking==true and "(")or""}{rich}[{select(2,ConstructorTostring("string","Parent"))}]{(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
			else--Up
				--If child has a name "Parent" there so having to use FindFirstChild
				if i~=1 and IsAProperty(Hierarchy[i-1],v.Name) then
					if ss.FastNamecall==true then
						txt = `{(ss.Typechecking==true and "(")or""}FindFirstChild({txt}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
						rich = `{(ss.Typechecking==true and "(")or""}{WriteRichText("FindFirstChild",ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
					else
						txt = `{(ss.Typechecking==true and "(")or""}{txt}:FindFirstChild({ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
						rich = `{(ss.Typechecking==true and "(")or""}{rich}:{WriteRichText("FindFirstChild",ScriptMethod)}({select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
					end
					continue
				end
				--Normal
				if ss.FNC_Properties==true then
					txt = `{(ss.Typechecking==true and "(")or""}{ss.NC_InsIndex}({txt}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
					rich = `{(ss.Typechecking==true and "(")or""}{WriteRichText(ss.NC_InsIndex,ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
					continue
				elseif ss.Indexing_Instances_By=="Dots" and string.match(v.Name,"^[_%a][^%.@#%+%*/=%$!№]*$")~=nil then
					txt = `{(ss.Typechecking==true and "(")or""}{txt}.{v.Name}{(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
					rich = `{(ss.Typechecking==true and "(")or""}{rich}.{WriteRichText(v.Name,ScriptProperty)}{(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
					continue
				end
				txt = `{(ss.Typechecking==true and "(")or""}{txt}[{ConstructorTostring("string",v.Name)}]{(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
				rich =`{(ss.Typechecking==true and "(")or""}{txt}[{select(2,ConstructorTostring("string",v.Name))}]{(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
			end
		end
		if ss.FNC_Properties==true and Value~=nil then
			txt = `\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({Value.Text}{ss.FuncSeparator}{ConstructorTostring("string",ValueProperty)}{ss.FuncSeparator}{txt})`
			rich = `\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({Value.Rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",ValueProperty))}{ss.FuncSeparator}{rich})`
		elseif Value~=nil then
			txt = `\n{string.rep(ss.t,Layer)}{Value.Text}{(ss.Indexing_Instances_By=="Dots" and `.{ValueProperty}`) or `[{ConstructorTostring("string",ValueProperty)}]`}{ss._Equal}{txt}`
			rich = `\n{string.rep(ss.t,Layer)}{Value.Rich}{(ss.Indexing_Instances_By=="Dots" and `.{WriteRichText(ValueProperty::string,ScriptProperty)}`) or `[{select(2,ConstructorTostring("string",ValueProperty))}]`}{ss._Equal}{rich}`
		end
		return txt,rich
	elseif Recursive~=nil then--Safe index
		--SAFEINDEX
		local prevVar:string = "Unknown"
		local grab = Hierarchy[1]::Instance
		if grab==workspace then
			prevVar = "workspace"
		elseif grab==game then
			prevVar = "game"
		else
			prevVar = grab.ClassName
		end
		txt,rich = RecursionFindFirstChildSafeMethod(txt,rich,2,Hierarchy,Layer,prevVar,Value::{Text:string;Rich:string},ValueProperty::string)	
		return txt,rich
	end
	--Top- to-Bottom
	for i,v in Hierarchy do
		if v==game then
			txt = "game"
			rich = "game"
		elseif (pathMacro::{[Instance]:string})[v]~=nil then
			--pathMacro
			txt = (pathMacro::{[Instance]:string})[v]
			rich = (pathMacro::{[Instance]:string})[v]
		elseif type(select(2,pcall(game.FindService,game,v.ClassName))::Instance?|"string")=="userdata" then
			--service
			if v==workspace then
				txt = "workspace"
				rich = WriteRichText("workspace",ScriptBuiltInFunction)
				continue
			end
			txt = v.ClassName
			rich = v.ClassName
		else--Instances
			if Mode=="SafeIndex" then
				if ss.FastNamecall==true then
					txt = `FindFirstChild({txt}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)})`
					rich = `{WriteRichText("FindFirstChild",ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))})`
				else
					txt = `{txt}:FindFirstChild({ConstructorTostring("string",v.Name)})`
					rich = `{rich}:{WriteRichText("FindFirstChild",ScriptMethod)}({select(2,ConstructorTostring("string",v.Name))})`
				end
			elseif Mode=="WaitForChild" then
				if ss.FastNamecall==true then
					txt = `WaitForChild({txt}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)})`
					rich = `{WriteRichText("WaitForChild",ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))})`
				else
					txt = `{txt}:WaitForChild({ConstructorTostring("string",v.Name)})`
					rich = `{rich}:{WriteRichText("WaitForChild",ScriptMethod)}({select(2,ConstructorTostring("string",v.Name))})`
				end
			else--Index
				--Make sure to check for peoperties
				if IsAProperty(Hierarchy[i-1],v.Name)==true then
					--Using FindFirstChild Instead
					if ss.FastNamecall==true then
						txt = `FindFirstChild({txt}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName}`) or ""}`
						rich = `{WriteRichText("FindFirstChild",ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))}`) or ""}`
					else
						txt = `{(ss.Typechecking==true and "(") or ""}{txt}:FindFirstChild({ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName})`) or ""}`
						rich = `{(ss.Typechecking==true and "(") or ""}{rich}:{WriteRichText("FindFirstChild",ScriptMethod)}({select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))})`) or ""}`
					end
					continue
				end
				if ss.FNC_Properties==true then
					txt= `{ss.NC_InsIndex}({txt}{ss.FuncSeparator}{ConstructorTostring("string",v.Name)}){(ss.Typechecking==true and `{ss.TC_Casting}{v.ClassName}`) or ""}`
					rich = `{WriteRichText(ss.NC_InsIndex,ScriptMethod)}({rich}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v.Name))}){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText(v.ClassName,Color3.new(0,1,1))}`) or ""}`
				elseif ss.Indexing_Instances_By=="Dots" and string.match(v.Name,"^[_%a][^%.@#%+%*/=%$!№]*$")~=nil then
					txt = `{txt}.{v.Name}`
					rich = `{rich}.{WriteRichText(v.Name,ScriptProperty)}`
				else--Brackets
					txt = `{txt}[{ConstructorTostring("string",v.Name)}]`
					rich = `{rich}[{select(2,ConstructorTostring("string",v.Name))}]`
				end
			end
		end
	end
	return txt,rich
end
--Converter stuff
(function():()
	local __FuzzyEq = CFrame.identity.FuzzyEq::(cf1:CFrame,cf2:CFrame,epsilon:number?)->boolean
	local function FuzzyEq(cf1:CFrame,cf2:CFrame,epsilon:number?):boolean
		if ss.Rounding==false then
			return cf1==cf2
		end
		return __FuzzyEq(cf1,cf2,epsilon)
	end
	--local GoToIndexPath = GoToIndexPath::(ins:Instance,Recursive:Instance?,Value:{Text:string;Rich:string}?,ValueProperty:string?,Layer:number?)->(string,string)

	local CreateStr = require(script:WaitForChild("strWrap"))
	local strMaxSize:number = 199_999;

	local ComputedCode:{string} = {""}
	local buffLen:number = 0
	local buffString:buffer = buffer.create(0)
	local buffTarget:string = ""
	local ComputedRichCode:{string} = ComputedCode
	local Num_Needle:number = 1


	local CodeOutput_Content = CodeOutput:WaitForChild("Content")
	local CodeOutput_Title = CodeOutput_Content:WaitForChild("Hint")::TextLabel	
	local CodeOutput_Title_Frame = CodeOutput_Content:WaitForChild("Frame")::Frame
	local SaveScript = CodeOutput_Content:WaitForChild("SaveScript")::ImageButton
	local SaveScript_Fill = SaveScript:WaitForChild("Fill")::Frame
	local BuildScript = CodeOutput_Content:WaitForChild("BuildScript")::ImageButton
	local BuildScript_Fill = BuildScript:WaitForChild("Fill")::Frame
	local __sz_Full = {Size = UDim2_one}
	local __sz_None = {Size = UDim2_zero}
	local __tw_In,__tw_Out = TweenInfo.new(0.35,Enum.EasingStyle.Quint),TweenInfo.new(0.255,Enum.EasingStyle.Cubic)

	local BuildScript_Fill_In = TweenService:Create(BuildScript_Fill,__tw_In,__sz_Full)
	local BuildScript_Fill_Out = TweenService:Create(BuildScript_Fill,__tw_Out,__sz_None)
	local SaveScript_Fill_In = TweenService:Create(SaveScript_Fill,__tw_In,__sz_Full)
	local SaveScript_Fill_Out = TweenService:Create(SaveScript_Fill,__tw_Out,__sz_None)

	table.insert(ItemHoverList,SaveScript_Fill)
	table.insert(ItemHoverList,BuildScript_Fill)

	BuildScript.MouseEnter:Connect(function()
		BuildScript_Fill_In:Play()
	end)
	BuildScript.MouseLeave:Connect(function()
		BuildScript_Fill_Out:Play()
	end)
	SaveScript.MouseEnter:Connect(function()
		SaveScript_Fill_In:Play()
	end)
	SaveScript.MouseLeave:Connect(function()
		SaveScript_Fill_Out:Play()
	end)


	BuildScript.MouseButton1Click:Connect(function():()
		local script:Script = Instance.new("Script")
		script.Name = `{buffTarget} {os.date("%d.%m.%y - %H:%M: %S")}`
		local try = pcall(SetProperty,script,"Parent",workspace)
		if try==false then warn("No script access. Please give script injection access.") script:Destroy() return end
		script.Source = ""
		Selection:Set({script})
		local try,err = ScriptEditorService:OpenScriptDocumentAsync(script)
		if try==false then warn(err) return end
		Heartbeat:Wait()
		local ret = ScriptEditorService:FindScriptDocument(script)::ScriptDocument?
		if ret==nil then warn("Unable to find script document") return end
		ret:EditTextAsync(buffer.readstring(buffString,0,buffLen),1,1,1,-1)
	end)
	SaveScript.MouseButton1Click:Connect(function():()
		local script:Script = Instance.new("Script")
		local name:string = `{buffTarget} {os.date("%d.%m.%y - %H.%M. %S")}.hs`
		script.Name = name
		script.Archivable=false
		local try = pcall(SetProperty,script,"Parent",game)
		if try==false then warn("No script access. Please give script injection access.") script:Destroy() return end
		script.Source = ""
		local OldSelection = Selection:Get()
		Selection:Set({script})
		local try,err = ScriptEditorService:OpenScriptDocumentAsync(script)
		if try==false then warn(err) return end
		Heartbeat:Wait()
		local ret = ScriptEditorService:FindScriptDocument(script)::ScriptDocument?
		if ret==nil then warn("Unable to find script document") return end
		ret:EditTextAsync(buffer.readstring(buffString,0,buffLen),1,1,1,-1)
		plugin:PromptSaveSelection(name)
		script:Destroy()
		Selection:Set(OldSelection)
	end)

	--[[Num]] local Num = CodeOutput_Title_Frame:WaitForChild("Num")::TextLabel
	local Num_Left = CodeOutput_Title_Frame:WaitForChild("Left")::ImageButton
	local Num_Right = CodeOutput_Title_Frame:WaitForChild("Right")::ImageButton
	table.insert(ScrollbarButtons,Num_Left)
	table.insert(ScrollbarButtons,Num_Right)
	table.insert(BrightestText_Theme,Num)
	CodeOutput_Title_Frame.Visible = false

	local CodeOutput_Scrolling = CodeOutput:WaitForChild("ScrollingFrame")
	local Code = CodeOutput_Scrolling:WaitForChild("Code")::TextBox
	local Rich = CodeOutput_Scrolling:WaitForChild("Rich")::TextLabel
	CodeOutput_Title.TextSize=ss.CodeOutputTextSize
	Rich.TextSize = ss.CodeOutputTextSize
	Code.TextSize = ss.CodeOutputTextSize
	CodeOutput_Title.Text=ss["--"].."CTRL+A and then CTRL+C code below:"
	table.insert(ScriptBackground_List,CodeOutput)
	table.insert(ScriptTextColor_List,Rich)
	table.insert(ScriptTextColor_List,Code)
	table.insert(ScriptComment_List,CodeOutput_Title)
	table.insert(ScrollingFramesScrollBar,CodeOutput_Scrolling)
	Code:GetPropertyChangedSignal("Text"):Connect(function():()
		if not Code:IsFocused() then return end
		Code.Text = ComputedCode[Num_Needle] or ""
	end)
	local function ApplyText():()
		Num.Text = tostring(Num_Needle)
		Code.Text = ComputedCode[Num_Needle] or ""
		Rich.Text = ComputedRichCode[Num_Needle] or ""
	end
	Num_Left.MouseButton1Click:Connect(function():()
		local needle:number = Num_Needle-1
		if ComputedCode[needle]~=nil then
			Num_Needle = needle
			ApplyText()
		end
	end)
	Num_Right.MouseButton1Click:Connect(function():()
		local needle:number = Num_Needle+1
		if ComputedCode[needle]~=nil then
			Num_Needle = needle
			ApplyText()
		end
	end)

	CodeOutput.Visible=true
	CodeOutput.Parent=Converted_Code



	local function ShowText(txt:CreateStr.class,rich:CreateStr.class):()
		Num_Needle = 1
		Num.Text = "1"
		buffString = txt.b
		buffLen = txt.len
		buffTarget = (SelectedInstance~=nil and SelectedInstance.Name) or "Code"
		if ss.WriteRichText~=true or rich.len>strMaxSize then rich = txt end
		if txt.len>strMaxSize then
			rich = txt
			CodeOutput_Title_Frame.Visible = true
		else
			CodeOutput_Title_Frame.Visible = false
		end
		if txt==rich then
			local compute:{string} = txt:Extract()
			ComputedCode = compute
			ComputedRichCode = compute
			ApplyText()
			return
		end
		ComputedCode = txt:Extract()
		ComputedRichCode = rich:Extract()
		ApplyText()
	end



	local function GetMeshPropertiesConfigs(ins:MeshPart):(string,string)
		if ss.CMPAsyncService=="InsertService" then
			return `{ss.FuncSeparator}{ConstructorTostring("EnumItem",ins.CollisionFidelity)}{ss.FuncSeparator}{ConstructorTostring("EnumItem",ins.RenderFidelity)}{(ss.CMPAsyncService_PassFuildFidility==true and `{ss.FuncSeparator}{ConstructorTostring("EnumItem",ins.FluidFidelity)}`) or ""}`,`{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",ins.CollisionFidelity))}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",ins.RenderFidelity))}{(ss.CMPAsyncService_PassFuildFidility==true and `{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",ins.FluidFidelity))}`) or ""}`
		end
		local dictionary,dictionary_rich:string = "{","{"
		if ins.CollisionFidelity~=Enum.CollisionFidelity.Default then
			dictionary..=`CollisionFidelity{ss._Equal}{ConstructorTostring("EnumItem",ins.CollisionFidelity)}{ss._Separator}`
			dictionary_rich..=`CollisionFidelity{ss._Equal}{select(2,ConstructorTostring("EnumItem",ins.CollisionFidelity))}{ss._Separator}`
		end
		if ins.RenderFidelity ~= Enum.RenderFidelity.Automatic then
			dictionary..=`RenderFidelity{ss._Equal}{ConstructorTostring("EnumItem",ins.RenderFidelity)}{ss._Separator}`
			dictionary_rich..=`RenderFidelity{ss._Equal}{select(2,ConstructorTostring("EnumItem",ins.RenderFidelity))}{ss._Separator}`
		end
		if ins.FluidFidelity ~= Enum.FluidFidelity.Automatic then
			dictionary..=`FluidFidelity{ss._Equal}{ConstructorTostring("EnumItem",ins.FluidFidelity)}{ss._Separator}`
			dictionary_rich..=`FluidFidelity{ss._Equal}{select(2,ConstructorTostring("EnumItem",ins.FluidFidelity))}{ss._Separator}`
		end
		dictionary..="}";dictionary_rich..="}"
		dictionary = (dictionary=="{}" and ""::string) or ss.FuncSeparator..dictionary
		dictionary_rich = (dictionary_rich=="{}" and ""::string) or ss.FuncSeparator..dictionary_rich
		return dictionary,dictionary_rich
	end

	local function get__count(v:Instance,children:{Instance},_CountWrapped:{Instance},Attributes:{[string]:any},Tags:{string},DirrectAccessToVarAvalible:{[Instance]:string}?,varName:string?):number?
		if ss.CountEnabled==true then
			if #v:GetChildren()~=0 then return nil end
			local ClassName:string = v.ClassName
			local counter:number = 0
			local properties = GetProperties(v)
			for ii,vv in children::{Instance} do
				if vv==v or vv.ClassName~=ClassName or table.find(_CountWrapped,vv)~=nil or #(vv::any):GetChildren()~=0 then continue end
				local vv_prop = GetProperties(vv)
				local Equal:boolean = true
				--tags
				local _tags = (vv::any):GetTags()::{string}
				if #_tags~=#Tags then Equal = false continue end
				for iii,vvv in Tags do
					if table.find(_tags,vvv)==nil then Equal = false break end
				end
				if Equal==false then continue end
				for iii,vvv in _tags do
					if table.find(Tags,vvv)==nil then Equal = false break end
				end
				if Equal==false then continue end
				--Attributes
				local _attributes = (vv::any):GetAttributes()::{[string]:any}
				if (next(Attributes)==nil and next(_attributes)~=nil) or (next(_attributes)==nil and next(Attributes)~=nil) then Equal = false continue end
				for iii,vvv in Attributes do
					if _attributes[iii]~=vvv and (typeof(vvv)~="CFrame" or typeof(_attributes[iii])~="CFrame" or not FuzzyEq(vvv::CFrame,_attributes[iii]::CFrame,10^ss.FuzzyCFrame)) then Equal = false break end
				end
				if Equal==false then continue end
				for iii,vvv in _attributes do
					if Attributes[iii]~=vvv and (typeof(vvv)~="CFrame" or typeof(Attributes[iii])~="CFrame" or not FuzzyEq(vvv::CFrame,Attributes[iii]::CFrame,10^ss.FuzzyCFrame)) then Equal = false break end
				end
				if Equal==false then continue end
				--prop
				for iii,vvv in vv_prop do
					if properties[iii]~=vvv and (typeof(vvv)~="CFrame" or typeof(properties[iii])~="CFrame" or not FuzzyEq(vvv::CFrame,properties[iii]::CFrame,10^ss.FuzzyCFrame)) then Equal = false break end
				end
				if Equal==false then continue end
				for iii,vvv in properties do
					if vv_prop[iii]~=vvv and (typeof(vvv)~="CFrame" or typeof(vv_prop[iii])~="CFrame" or not FuzzyEq(vvv::CFrame,vv_prop[iii]::CFrame,10^ss.FuzzyCFrame)) then Equal = false break end
				end
				if Equal==false then continue end
				if DirrectAccessToVarAvalible~=nil then
					DirrectAccessToVarAvalible[(vv::any)::Instance] = varName or "RefError_0xbadc0ffee"
				end
				table.insert(_CountWrapped,vv)
				counter+=1	
			end
			if counter~=0 then return counter+1 end
		end
		return nil
	end
	local function NE____RecursiveHierarchy(ins:Instance,properties:cache_prop,code:CreateStr.class|any,riched_code:CreateStr.class|any,Layer:number):()
		for key,value in spairs(properties) do
			if typeof(value)=="Instance" and (value:IsDescendantOf(SelectedInstance::Instance) or value==ins or value==SelectedInstance or (ss.OutsideHierarchyInstances=="SafeIndex" and ((value.Parent~=game and typeof(select(2,pcall(game.FindService,game,(value.Parent::Instance).ClassName))::any|string)~="Instance")))) then 
				--Recursive hierarchy 
				if value:IsDescendantOf(SelectedInstance::Instance) or ins==value or SelectedInstance==value then
					--Recursive
					local c,r = GoToIndexPath(ins,value,{Text = "self",Rich = WriteRichText("self",ScriptSelf)},key,Layer+1)
					code..=c
					riched_code..=r
				else
					--SafeIndex
					local c,r = GoToIndexPath(ins,value,{Text = "self",Rich = WriteRichText("self",ScriptSelf)},key,Layer+1)
					code..=c
					riched_code..=r
				end
			end
		end
	end

	local function NE__TagsAndAttributes(code:CreateStr.class|any,riched_code:CreateStr.class|any,Layer:number,Attributes:{[string]:any},Tags:{string},baseImport:string?):()
		if #Tags~=0 then
			if ss.FastNamecall==true then
				for i,v in Tags do
					code..=`\n{string.rep(ss.t,Layer+1)}AddTag(self{ss.FuncSeparator}{ConstructorTostring("string",v)})`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("AddTag",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v))})`
				end
			else
				for i,v in Tags do
					code..=`\n{string.rep(ss.t,Layer+1)}self:AddTag({ConstructorTostring("string",v)})`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("AddTag",ScriptMethod)}({select(2,ConstructorTostring("string",v))})`
				end
			end
		end
		--Attributes
		if next(Attributes)~=nil then
			if ss.FastNamecall==true then
				for i,v in spairs(Attributes) do
					code..=`\n{string.rep(ss.t,Layer+1)}SetAttribute(self{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{ConstructorTostring(typeof(v),v)})`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("SetAttribute",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(v),v))})`
				end
			else
				for i,v in spairs(Attributes) do
					code..=`\n{string.rep(ss.t,Layer+1)}self:SetAttribute({ConstructorTostring("string",i)}{ss.FuncSeparator}{ConstructorTostring(typeof(v),v)})`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("SetAttribute",ScriptMethod)}({select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(v),v))})`
				end
			end
		end
	end

	--Removes alredy added tags and attributes and returns <strong>baseimport</strong> if such is found
	local function NE__Base(Attributes:{[string]:any},Tags:{string},Type:string,bypass__properties:{[string]:any}):string?
		if ss.Use_Base_Imports and Classes[Type]~=nil then
			local baseImport:string? = nil
			--Grabbing best match for _base
			local persentage:number = 0
			for _base,tab in _baseImports do
				local Matches:number = 0
				local MatcheCount:number = 0
				if type(tab._exec)=="table" and type(tab._exec.SetAttribute)=="table" then
					for i,v in tab._exec.SetAttribute do
						if Attributes[i::string]==v then Matches+=1 end
						MatcheCount+=1
					end
				end
				if type(tab._exec)=="table" and type(tab._exec.AddTag)=="table" then
					for i,v in tab._exec.AddTag do
						if table.find(Tags,v)~=nil then Matches+=1 end
						MatcheCount+=1
					end
				end
				for i,v in tab do
					if (Classes[Type][i]::string?)==nil then break end
					if (bypass__properties[i]==v or (typeof(v)=="CFrame" and typeof(bypass__properties[i])=="CFrame") and FuzzyEq(v,bypass__properties[i],10^ss.FuzzyCFrame)) and (typeof(bypass__properties[i])==typeof(v) or (v==nil or bypass__properties[i]==nil)) then Matches+=1 end
					if i=="_exec" then continue end
					MatcheCount+=1
				end

				if Matches~=0 and MatcheCount~=0 then
					local _procentage:number = Matches/MatcheCount*100
					if _procentage>persentage and _procentage>=ss.Use_Base_Properties_MatchPersentage then
						baseImport = _base
						persentage = _procentage
					end
				end
			end
			if baseImport==nil then return nil end
			local import = (_baseImports::_baseImports)[baseImport::string]
			if type(import._exec)=="table" then
				local _exec:{[any]:any}&{SetAttribute:{[string]:any};AddTag:{string}} = import._exec
				if type(_exec.SetAttribute)=="table" then
					for i,v in _exec.SetAttribute do
						Attributes[i] = nil
					end
				end
				if type(_exec.AddTag)=="table" then
					for i,v in _exec.AddTag do
						local needle:number? = table.find(Tags,v)
						if needle~=nil then
							table.remove(Tags,needle::number)
						end
					end
				end
			end

			return baseImport
		end
		return nil
	end
	local function IsBlocked(ins:Instance,prop:string):boolean
		for ii,vv in (IgnoredPropertiesList::{[string]:any}) do
			if ins:IsA(ii) and table.find(vv,prop)~=nil then
				return true
			end
		end
		return false
	end

	local function GetVarName(name:string,tbl:{[string]:true}):string
		name = string.gsub(name,"[^%w_]","_")
		if string.match(name,"^%d") then
			name = `_{name}`
		end
		if tbl[name]==true then
			local indexator:number = 1
			while tbl[`{name}_{indexator}`]==true do
				indexator+=1
			end
			local ret:string = `{name}_{indexator}`
			tbl[ret]=true
			return ret
		end
		tbl[name]=true
		return name
	end



	local function __IncludeTopCode__WriteTopFunctionHeader(txt:CreateStr.class|any,rich:CreateStr.class|any):()
		txt..=`{ss._local}function {ss._SaveMeshes_FN_Name}(Id{(ss.Typechecking==true and `{ss.TC_Type}string`) or ""}{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{(ss.Typechecking==true and `{ss.TC_Type}Enum.CollisionFidelity`) or ""}{ss.FuncSeparator}r{(ss.Typechecking==true and `{ss.TC_Type}Enum.RenderFidelity`) or ""}`) or `t{(ss.Typechecking==true and `{ss.TC_Type}\{CollisionFidelity{ss.TC_Type}Enum.CollisionFidelity?{ss._Separator}RenderFidelity{ss.TC_Type}Enum.RenderFidelity?{ss._Separator}FluidFidelity{ss.TC_Type}Enum.FluidFidelity?\}?`) or ""}`}){(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss["fbend"]}`
		rich..=`{WriteRichText(ss._local,ScriptLocal)}{WriteRichText("function",ScriptFunction)} {WriteRichText(ss._SaveMeshes_FN_Name,ScriptFunctionName)}(Id{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("string",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}r{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}`) or ""}`) or `t{(ss.Typechecking==true and `{ss.TC_Type}\{CollisionFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}?{ss._Separator}RenderFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}?{ss._Separator}FluidFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("FluidFidelity",Color3.new(0,1,1))}?\}?`) or ""}`}){(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""}{ss["fbend"]}`
	end
	local __Write__HashTable_Enum_CollisionFidelity = Enum.CollisionFidelity:GetEnumItems()
	local __Write__HashTable_Enums_RenderFidelity = Enum.RenderFidelity:GetEnumItems()
	local __Write__HashTable_Enums_FluidFidelity = Enum.FluidFidelity:GetEnumItems()
	local function __Write__HashTable(txt:CreateStr.class|any,rich:CreateStr.class|any):()
		txt..=`{ss._local}{ss._SaveMeshes_CacheTableName}` 				
		rich..=`{WriteRichText(ss._local,ScriptLocal)}{ss._SaveMeshes_CacheTableName}` 				
		if ss.CMPAsyncService=="InsertService" then
			txt..=`{(ss.Typechecking==true and `{ss.TC_Type}\{[Enum.CollisionFidelity]{ss.TC_Type}\{[Enum.RenderFidelity]{ss.TC_Type}\{[string]{ss.TC_Type}MeshPart\}\}\}`) or ""}{ss._Equal}\{`
			rich..=`{(ss.Typechecking==true and `{ss.TC_Type}\{[{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}]{ss.TC_Type}\{[{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}]{ss.TC_Type}\{[{WriteRichText("string",Color3.new(0,1,1))}]{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}\}\}\}`) or ""}{ss._Equal}\{`
			for i,v in __Write__HashTable_Enum_CollisionFidelity do
				txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}[{ConstructorTostring("EnumItem",v::Enum.CollisionFidelity)}]{ss._Equal}\{`
				rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}[{select(2,ConstructorTostring("EnumItem",v::Enum.CollisionFidelity))}]{ss._Equal}\{`
				for ii,vv in __Write__HashTable_Enums_RenderFidelity do
					txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}`) or ""}[{ConstructorTostring("EnumItem",vv::Enum.RenderFidelity)}]{ss._Equal}\{\}{ss._Separator}`
					rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}`) or ""}[{select(2,ConstructorTostring("EnumItem",vv::Enum.RenderFidelity))}]{ss._Equal}\{\}{ss._Separator}`
				end
				txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}\}{ss._Separator}`
				rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}\}{ss._Separator}`
			end
		else
			txt..=`{(ss.Typechecking==true and `{ss.TC_Type}\{[Enum.CollisionFidelity]{ss.TC_Type}\{[Enum.RenderFidelity]{ss.TC_Type}\{[Enum.FluidFidelity]{ss.TC_Type}\{[string]{ss.TC_Type}MeshPart\}\}\}\}`) or ""}{ss._Equal}\{`
			rich..=`{(ss.Typechecking==true and `{ss.TC_Type}\{[{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}]{ss.TC_Type}\{[{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}]{ss.TC_Type}\{[{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("FluidFidelity",Color3.new(0,1,1))}]{ss.TC_Type}\{[{WriteRichText("string",Color3.new(0,1,1))}]{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}\}\}\}\}`) or ""}{ss._Equal}\{`
			for i,v in __Write__HashTable_Enum_CollisionFidelity do
				txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}[{ConstructorTostring("EnumItem",v::Enum.CollisionFidelity)}]{ss._Equal}\{`
				rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}[{select(2,ConstructorTostring("EnumItem",v::Enum.CollisionFidelity))}]{ss._Equal}\{`
				for ii,vv in __Write__HashTable_Enums_RenderFidelity do
					txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}`) or ""}[{ConstructorTostring("EnumItem",vv::Enum.RenderFidelity)}]{ss._Equal}\{`
					rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}`) or ""}[{select(2,ConstructorTostring("EnumItem",vv::Enum.RenderFidelity))}]{ss._Equal}\{`
					for iii,vvv in __Write__HashTable_Enums_FluidFidelity do
						txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}{ss.t}`) or ""}[{ConstructorTostring("EnumItem",vvv::Enum.FluidFidelity)}]{ss._Equal}\{\}{ss._Separator}`
						rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}{ss.t}`) or ""}[{select(2,ConstructorTostring("EnumItem",vvv::Enum.FluidFidelity))}]{ss._Equal}\{\}{ss._Separator}`
					end
					txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}`) or ""}\}{ss._Separator}`
					rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}{ss.t}`) or ""}\}{ss._Separator}`
				end
				txt..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}\}{ss._Separator}`
				rich..=`{(ss.CacheHashTableSpacing==true and `\n{ss.t}`) or ""}\}{ss._Separator}`
			end	
		end
		txt..=`{(ss.CacheHashTableSpacing==true and `\n`) or ""}\}\n`
		rich..=`{(ss.CacheHashTableSpacing==true and `\n`) or ""}\}\n`
	end

	local function IncludeTopCode(txt:CreateStr.class|any,rich:CreateStr.class|any,IncludeFunctions:true?):()
		if ss.DisplaySource==true then
			local t:string = (SelectedInstance or workspace):GetFullName()
			txt..=`{ss["--"]}@Source {t}`
			rich..=WriteRichText(`{ss["--"]}@Source {t}`,ScriptComment)
		end
		if ss.DisplayDate==true then
			txt..=`{(ss.DisplaySource==true and " ") or ""}{ss["--"]}{os.date("%d.%m.%Y - %H:%M : %S")}`
			rich..=WriteRichText(`{(ss.DisplaySource==true and " ") or ""}{ss["--"]}{os.date("%d.%m.%Y - %H:%M : %S")}`,ScriptComment)
		end
		if ss.DisplaySource==true or ss.DisplayDate==true then
			txt..="\n"
			rich..="\n"
		end
		--base imports
		if ss.Use_Base_Imports==true and ss.RL_Compile_baseFunctions==true and CurrentConvertType=="Raw Luau" then
			local _base:string = ss.Base_Imports_FN_subName::string
			for i,v in _baseImports do
				txt..=`{ss._local}function {_base}{i}(ins{(ss.Typechecking==true and `{ss.TC_Type}Instance`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
				rich..=`{WriteRichText(ss._local,ScriptLocal)}{WriteRichText("function",ScriptFunction)} {WriteRichText(`{_base}{i}`,ScriptFunctionName)}(ins{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Instance",Color3.new(0,1,1))}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
				local _exec:{[any]:any} = (type(v._exec)=="table" and v._exec) or {}
				local Attributes:{[any]:any} = (type(_exec.SetAttribute)=="table" and _exec.SetAttribute) or {}
				local Tags:{[any]:any} = (type(_exec.AddTag)=="table" and _exec.AddTag) or {}
				if ss.FastNamecall==true then
					for ii,vv in Attributes do
						txt..=`\n{ss.t}SetAttribute(ins{ss.FuncSeparator}{ConstructorTostring("string",tostring(ii))}{ss.FuncSeparator}{ConstructorTostring(typeof(vv),vv)})`
						rich..=`\n{ss.t}{WriteRichText("SetAttribute",ScriptMethod)}(ins{ss.FuncSeparator}{select(2,ConstructorTostring("string",tostring(ii)))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(vv),vv))})`
					end
					for ii,vv in Tags do
						txt..=`\n{ss.t}AddTag(ins{ss.FuncSeparator}{ConstructorTostring("string",tostring(vv))})`
						rich..=`\n{ss.t}{WriteRichText("AddTag",ScriptMethod)}(ins{ss.FuncSeparator}{select(2,ConstructorTostring("string",tostring(vv)))})`
					end
					for ii,vv in v do
						if ii=="_exec" then continue end
						txt..=`\n{ss.t}{ss.NC_InsSetProperty}(ins{ss.FuncSeparator}{ConstructorTostring("string",ii)}{ss.FuncSeparator}{ConstructorTostring(typeof(vv),vv)})`
						rich..=`\n{ss.t}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}(ins{ss.FuncSeparator}{select(2,ConstructorTostring("string",ii))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(vv),vv))})`
					end
				else
					for ii,vv in Attributes do
						txt..=`\n{ss.t}ins:SetAttribute({ConstructorTostring("string",tostring(ii))}{ss.FuncSeparator}{ConstructorTostring(typeof(vv),vv)})`
						rich..=`\n{ss.t}ins:{WriteRichText("SetAttribute",ScriptMethod)}({select(2,ConstructorTostring("string",tostring(ii)))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(vv),vv))})`
					end
					for ii,vv in Tags do
						txt..=`\n{ss.t}ins:AddTag({ConstructorTostring("string",tostring(vv))})`
						rich..=`\n{ss.t}ins:{WriteRichText("AddTag",ScriptMethod)}({select(2,ConstructorTostring("string",tostring(vv)))})`
					end
					for ii,vv in v do
						if ii=="_exec" then continue end
						txt..=`\n{ss.t}ins{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",ii)}]`) or "."..ii}{ss._Equal}{ConstructorTostring(typeof(vv),vv)}`
						rich..=`\n{ss.t}ins{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",ii))}]`) or "."..WriteRichText(ii,ScriptProperty)}{ss._Equal}{select(2,ConstructorTostring(typeof(vv),vv))}`
					end
				end
				txt..=`\n{ss["end"]}\n`
				rich..=`\n{WriteRichText(ss["end"],ScriptLuauKeyword)}\n`
			end
		end

		if ss._SaveMeshes_IncludeFN==true and ((SelectedInstance::Instance).ClassName=="MeshPart" or (SelectedInstance::Instance):FindFirstChildWhichIsA("MeshPart",true)) then
			--services
			txt..=`\n{ss._local}{ss.CMPAsyncService}{ss._Equal}game:GetService({ConstructorTostring("string",ss.CMPAsyncService)})\n`
			rich..=`\n{WriteRichText(ss._local,ScriptLocal)}{ss.CMPAsyncService}{ss._Equal}{WriteRichText("game",ScriptBuiltInFunction)}:{WriteRichText("GetService",ScriptMethod)}({select(2,ConstructorTostring("string",ss.CMPAsyncService))})\n`

			if ss._SaveMeshes_Cache then
				--local alloc
				if ss.CacheTableType=="Array" then
					txt..=`{ss._local}{ss._SaveMeshes_CacheTableName}{(ss.Typechecking==true and `{ss.TC_Type}\{[number]{ss.TC_Type}\{M{ss.TC_Type}MeshPart{ss._Separator}Id{ss.TC_Type}string{ss._Separator}Cf{ss.TC_Type}Enum.CollisionFidelity?{ss._Separator}Rf{ss.TC_Type}Enum.RenderFidelity?{(ss.CMPAsyncService=="InsertService" and "") or `{ss._Separator}Ff{ss.TC_Type}Enum.FluidFidelity?`}\}\}`) or ""}{ss._Equal}\{\}\n`
					rich..=`{WriteRichText(ss._local,ScriptLocal)}{ss._SaveMeshes_CacheTableName}{(ss.Typechecking==true and `{ss.TC_Type}\{[{WriteRichText("number",Color3.new(0,1,1))}]{ss.TC_Type}\{M{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}{ss._Separator}Id{ss.TC_Type}{WriteRichText("string",Color3.new(0,1,1))}{ss._Separator}Cf{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}?{ss._Separator}Rf{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}?{(ss.CMPAsyncService=="InsertService" and "") or `{ss._Separator}Ff{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("FluidFidelity",Color3.new(0,1,1))}?`}\}\}`) or ""}{ss._Equal}\{\}\n`	
				else--Hash table
					__Write__HashTable(txt,rich)
				end
				__IncludeTopCode__WriteTopFunctionHeader(txt,rich)
				if ss.CacheTableType=="Array" then
					--for loop
					if ss.CMPAsyncService=="InsertService" then
						txt..=`\n{ss.t}{ss["for"]}i{ss.TupleSeparator}v{ss["in"]}{ss._SaveMeshes_CacheTableName}{ss["do"]}\n{ss.t}{ss.t}{ss["if"]}v{(ss.IndexingBy=="Dots" and `.Id`) or `[{ConstructorTostring("string","Id")}]`}{ss["=="]}Id{ss["and"]}v{(ss.IndexingBy=="Dots" and `.Cf`) or `[{ConstructorTostring("string","Cf")}]`}{ss["=="]}c{ss["and"]}v{(ss.IndexingBy=="Dots" and `.Rf`) or `[{ConstructorTostring("string","Rf")}]`}{ss["=="]}r`
						rich..=`\n{ss.t}{WriteRichText(ss["for"],ScriptLuauKeyword)}i{ss.TupleSeparator}v{WriteRichText(ss["in"],ScriptLuauKeyword)}{ss._SaveMeshes_CacheTableName}{WriteRichText(ss["do"],ScriptLuauKeyword)}\n{ss.t}{ss.t}{WriteRichText(ss["if"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Id",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Id"))}]`}{ss["=="]}Id{WriteRichText(ss["and"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Cf",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Cf"))}]`}{ss["=="]}c{WriteRichText(ss["and"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Rf",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Rf"))}]`}{ss["=="]}r`
					else
						txt..=`\n{ss.t}t{ss._Equal}t{ss["or"]}\{\}\n{ss.t}{ss._local}cf{ss.TupleSeparator}rf{ss.TupleSeparator}ff{ss._Equal}t{(ss.IndexingBy=="Dots" and `.CollisionFidelity`) or `[{ConstructorTostring("string","CollisionFidelity")}]`}{ss.TupleSeparator}t{(ss.IndexingBy=="Dots" and `.RenderFidelity`) or `[{ConstructorTostring("string","RenderFidelity")}]`}{ss.TupleSeparator}t{(ss.IndexingBy=="Dots" and `.FluidFidelity`) or `[{ConstructorTostring("string","FluidFidelity")}]`}\n{ss.t}{ss["for"]}i{ss.TupleSeparator}v{ss["in"]}{ss._SaveMeshes_CacheTableName}{ss["do"]}\n{ss.t}{ss.t}{ss["if"]}v{(ss.IndexingBy=="Dots" and `.Id`) or `[{ConstructorTostring("string","Id")}]`}{ss["=="]}Id{ss["and"]}v{(ss.IndexingBy=="Dots" and `.Cf`) or `[{ConstructorTostring("string","Cf")}]`}{ss["=="]}cf{ss["and"]}v{(ss.IndexingBy=="Dots" and `.Rf`) or `[{ConstructorTostring("string","Rf")}]`}{ss["=="]}rf{ss["and"]}v{(ss.IndexingBy=="Dots" and `.Ff`) or `[{ConstructorTostring("string","Ff")}]`}{ss["=="]}ff`
						rich..=`\n{ss.t}t{ss._Equal}t{WriteRichText(ss["or"],ScriptLuauKeyword)}\{\}\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}cf{ss.TupleSeparator}rf{ss.TupleSeparator}ff{ss._Equal}t{(ss.IndexingBy=="Dots" and `.{WriteRichText("CollisionFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","CollisionFidelity"))}]`}{ss.TupleSeparator}t{(ss.IndexingBy=="Dots" and `.{WriteRichText("RenderFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","RenderFidelity"))}]`}{ss.TupleSeparator}t{(ss.IndexingBy=="Dots" and `.{WriteRichText("FluidFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","FluidFidelity"))}]`}\n{ss.t}{WriteRichText(ss["for"],ScriptLuauKeyword)}i{ss.TupleSeparator}v{WriteRichText(ss["in"],ScriptLuauKeyword)}{ss._SaveMeshes_CacheTableName}{WriteRichText(ss["do"],ScriptLuauKeyword)}\n{ss.t}{ss.t}{WriteRichText(ss["if"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Id",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Id"))}]`}{ss["=="]}Id{WriteRichText(ss["and"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Cf",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Cf"))}]`}{ss["=="]}cf{WriteRichText(ss["and"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Rf",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Rf"))}]`}{ss["=="]}rf{WriteRichText(ss["and"],ScriptLuauKeyword)}v{(ss.IndexingBy=="Dots" and `.{WriteRichText("Ff",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Ff"))}]`}{ss["=="]}ff`
					end
					--closing for loop
					txt..=`{ss["then"]}{ss.s}{ss["return"]} v{(ss.IndexingBy=="Dots" and `.M`) or `[{ConstructorTostring("string","M")}]`}{ss.s}{ss["end"]}\n{ss.t}{ss["end"]}`
					rich..=`{WriteRichText(ss["then"],ScriptLuauKeyword)}{ss.s}{WriteRichText(ss["return"],ScriptLuauKeyword)} v{(ss.IndexingBy=="Dots" and `.{WriteRichText("M",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","M"))}]`}{ss.s}{WriteRichText(ss["end"],ScriptLuauKeyword)}\n{ss.t}{WriteRichText(ss["end"],ScriptLuauKeyword)}`
					--Create cache
					if ss.FNC_Mesh==true then
						txt..=`\n{ss.t}{ss._local}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
						rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(`MeshPart`,Color3.new(0,1,1))}`) or ""}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
					else
						txt..=`\n{ss.t}{ss._local}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
						rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(`MeshPart`,Color3.new(0,1,1))}`) or ""}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
					end
					--insert
					if ss.CMPAsyncService=="InsertService" then
						txt..=`\n{ss.t}table{(ss.IndexingBy=="Dots" and `.insert`) or `[{ConstructorTostring("string","insert")}]`}({ss._SaveMeshes_CacheTableName}{ss.FuncSeparator}\{M{ss._Equal}{ss.localMeshVariableName}{ss._Separator}Id{ss._Equal}Id{ss._Separator}Cf{ss._Equal}c{ss._Separator}Rf{ss._Equal}r\})`
						rich..=`\n{ss.t}{WriteRichText("table",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("insert",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","insert"))}]`}({ss._SaveMeshes_CacheTableName}{ss.FuncSeparator}\{M{ss._Equal}{ss.localMeshVariableName}{ss._Separator}Id{ss._Equal}Id{ss._Separator}Cf{ss._Equal}c{ss._Separator}Rf{ss._Equal}r\})`
					else
						txt..=`\n{ss.t}table{(ss.IndexingBy=="Dots" and `.insert`) or `[{ConstructorTostring("string","insert")}]`}({ss._SaveMeshes_CacheTableName}{ss.FuncSeparator}\{M{ss._Equal}{ss.localMeshVariableName}{ss._Separator}Id{ss._Equal}Id{ss._Separator}Cf{ss._Equal}cf{ss._Separator}Rf{ss._Equal}rf{ss._Separator}Ff{ss._Equal}ff\})`
						rich..=`\n{ss.t}{WriteRichText("table",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("insert",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","insert"))}]`}({ss._SaveMeshes_CacheTableName}{ss.FuncSeparator}\{M{ss._Equal}{ss.localMeshVariableName}{ss._Separator}Id{ss._Equal}Id{ss._Separator}Cf{ss._Equal}cf{ss._Separator}Rf{ss._Equal}rf{ss._Separator}Ff{ss._Equal}ff\})`
					end
					--end
					txt..=`\n{ss.t}{ss["return"]} {ss.localMeshVariableName}`
					rich..=`\n{ss.t}{WriteRichText(ss["return"],ScriptLuauKeyword)} {ss.localMeshVariableName}`
				else--Hash table
					--Retriving cache if possible
					--t = t or {}
					if ss.CMPAsyncService~="InsertService" then
						txt..=`\n{ss.t}t{ss._Equal}t{ss["or"]}\{\}`
						rich..=`\n{ss.t}t{ss._Equal}t{WriteRichText(ss["or"],ScriptLuauKeyword)}\{\}`
					end
					--local M:MeshPart
					txt..=`\n{ss.t}{ss._local}M{(ss.Typechecking==true and `{ss.TC_Type}MeshPart?`) or ""}{ss._Equal}{ss._SaveMeshes_CacheTableName}`
					rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}M{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}?`) or ""}{ss._Equal}{ss._SaveMeshes_CacheTableName}`
					--indexing
					if ss.CMPAsyncService=="InsertService" then
						txt..="[c][r][Id]"
						rich..="[c][r][Id]"
					else
						txt..=`[t{(ss.IndexingBy=="Dots" and `.CollisionFidelity`) or `[{ConstructorTostring("string","CollisionFidelity")}]`}{ss["or"]}{ConstructorTostring("EnumItem",Enum.CollisionFidelity.Default)}][t{(ss.IndexingBy=="Dots" and `.RenderFidelity`) or `[{ConstructorTostring("string","RenderFidelity")}]`}{ss["or"]}{ConstructorTostring("EnumItem",Enum.RenderFidelity.Automatic)}][t{(ss.IndexingBy=="Dots" and `.FluidFidelity`) or `[{ConstructorTostring("string","FluidFidelity")}]`}{ss["or"]}{ConstructorTostring("EnumItem",Enum.FluidFidelity.Automatic)}][Id]`
						rich..=`[t{(ss.IndexingBy=="Dots" and `.{WriteRichText("CollisionFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","CollisionFidelity"))}]`}{WriteRichText(ss["or"],ScriptLuauKeyword)}{select(2,ConstructorTostring("EnumItem",Enum.CollisionFidelity.Default))}][t{(ss.IndexingBy=="Dots" and `.{WriteRichText("RenderFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","RenderFidelity"))}]`}{WriteRichText(ss["or"],ScriptLuauKeyword)}{select(2,ConstructorTostring("EnumItem",Enum.RenderFidelity.Automatic))}][t{(ss.IndexingBy=="Dots" and `.{WriteRichText("FluidFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","FluidFidelity"))}]`}{WriteRichText(ss["or"],ScriptLuauKeyword)}{select(2,ConstructorTostring("EnumItem",Enum.FluidFidelity.Automatic))}][Id]`
					end
					--if return part
					txt..=`\n{ss.t}{ss["if"]}M{ss["then"]} {ss["return"]} M{(ss.Typechecking==true and `{ss.TC_Casting}MeshPart`) or ""} {ss["end"]}`
					rich..=`\n{ss.t}{WriteRichText(ss["if"],ScriptLuauKeyword)}M{WriteRichText(ss["then"],ScriptLuauKeyword)} {WriteRichText(ss["return"],ScriptLuauKeyword)} M{(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""} {WriteRichText(ss["end"],ScriptLuauKeyword)}`
					--Create cache
					if ss.FNC_Mesh then
						txt..=`\n{ss.t}{ss._local}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
						rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(`MeshPart`,Color3.new(0,1,1))}`) or ""}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
					else
						txt..=`\n{ss.t}{ss._local}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
						rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(`MeshPart`,Color3.new(0,1,1))}`) or ""}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
					end
					--set cache
					txt..=`\n{ss.t}{ss._SaveMeshes_CacheTableName}`
					rich..=`\n{ss.t}{ss._SaveMeshes_CacheTableName}`
					if ss.CMPAsyncService=="InsertService" then
						txt..=`[c][r][Id]{ss._Equal}{ss.localMeshVariableName}`
						rich..=`[c][r][Id]{ss._Equal}{ss.localMeshVariableName}`
					else
						txt..=`[t{(ss.IndexingBy=="Dots" and `.CollisionFidelity`) or `[{ConstructorTostring("string","CollisionFidelity")}]`}{ss["or"]}{ConstructorTostring("EnumItem",Enum.CollisionFidelity.Default)}][t{(ss.IndexingBy=="Dots" and `.RenderFidelity`) or `[{ConstructorTostring("string","RenderFidelity")}]`}{ss["or"]}{ConstructorTostring("EnumItem",Enum.RenderFidelity.Automatic)}][t{(ss.IndexingBy=="Dots" and `.FluidFidelity`) or `[{ConstructorTostring("string","FluidFidelity")}]`}{ss["or"]}{ConstructorTostring("EnumItem",Enum.FluidFidelity.Automatic)}][Id]{ss._Equal}{ss.localMeshVariableName}`
						rich..=`[t{(ss.IndexingBy=="Dots" and `.{WriteRichText("CollisionFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","CollisionFidelity"))}]`}{WriteRichText(ss["or"],ScriptLuauKeyword)}{select(2,ConstructorTostring("EnumItem",Enum.CollisionFidelity.Default))}][t{(ss.IndexingBy=="Dots" and `.{WriteRichText("RenderFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","RenderFidelity"))}]`}{WriteRichText(ss["or"],ScriptLuauKeyword)}{select(2,ConstructorTostring("EnumItem",Enum.RenderFidelity.Automatic))}][t{(ss.IndexingBy=="Dots" and `.{WriteRichText("FluidFidelity",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","FluidFidelity"))}]`}{WriteRichText(ss["or"],ScriptLuauKeyword)}{select(2,ConstructorTostring("EnumItem",Enum.FluidFidelity.Automatic))}][Id]{ss._Equal}{ss.localMeshVariableName}`
					end
					txt..=`\n{ss.t}{ss["return"]}{ss.s}{ss.localMeshVariableName}`
					rich..=`\n{ss.t}{WriteRichText(ss["return"],ScriptLuauKeyword)}{ss.s}{ss.localMeshVariableName}`
				end
			else--No caching
				--function open
				__IncludeTopCode__WriteTopFunctionHeader(txt,rich)
				--Create object
				if ss.FNC_Mesh then
					txt..=`\n{ss.t}{ss._local}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}){(CurrentConvertType=="Nestify" and `\n{ss.t}task{(ss.IndexingBy=="Dots" and `.defer`) or `[{ConstructorTostring("string","defer")}]`}(Destroy{ss.FuncSeparator}{ss.localMeshVariableName})`) or ""}\n{ss.t}{ss["return"]} {ss.localMeshVariableName}`
					rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(`MeshPart`,Color3.new(0,1,1))}`) or ""}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}){(CurrentConvertType=="Nestify" and `\n{ss.t}{WriteRichText("task",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("defer",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","defer"))}]`}(Destroy{ss.FuncSeparator}{ss.localMeshVariableName})`) or ""}\n{ss.t}{WriteRichText(ss["return"],ScriptLuauKeyword)} {ss.localMeshVariableName}`
				else
					txt..=`\n{ss.t}{ss._local}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}){(CurrentConvertType=="Nestify" and `\n{ss.t}task{(ss.IndexingBy=="Dots" and `.defer`) or `[{ConstructorTostring("string","defer")}]`}(game{((ss.IndexingBy=="Dots" and `.Destroy`) or `[{ConstructorTostring("string","Destroy")}]`)}{ss.FuncSeparator}{ss.localMeshVariableName})`) or ""}\n{ss.t}{ss["return"]} {ss.localMeshVariableName}`
					rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(`MeshPart`,Color3.new(0,1,1))}`) or ""}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}){(CurrentConvertType=="Nestify" and `\n{ss.t}{WriteRichText("task",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("defer",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","defer"))}]`}({WriteRichText("game",ScriptBuiltInFunction)}{((ss.IndexingBy=="Dots" and `.{WriteRichText("Destroy",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","Destroy"))}]`)}{ss.FuncSeparator}{ss.localMeshVariableName})` or "")}\n{ss.t}{WriteRichText(ss["return"],ScriptLuauKeyword)} {ss.localMeshVariableName}`
				end
			end
			--function close
			txt..=`\n{ss["end"]}\n`
			rich..=`\n{WriteRichText(ss["end"],ScriptLuauKeyword)}\n`

		end

		if CurrentConvertType=="Raw Luau" and ss.MeshPartCreationMode=="Defered" and ss.RL_DFM_Include==true and ((SelectedInstance::Instance).ClassName=="MeshPart" or (SelectedInstance::Instance):FindFirstChildWhichIsA("MeshPart",true)) then
			--function open
			txt..=`{ss._local}function __{ss.RL_Deffered_Fn_Mesh}({ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss.FuncSeparator}tx{(ss.Typechecking==true and `{ss.TC_Type}string`) or ""}{ss.FuncSeparator}Id{(ss.Typechecking==true and `{ss.TC_Type}string`) or ""}{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{(ss.Typechecking==true and `{ss.TC_Type}Enum.CollisionFidelity`) or ""}{ss.FuncSeparator}r{(ss.Typechecking==true and `{ss.TC_Type}Enum.RenderFidelity`) or ""}`) or `t{(ss.Typechecking==true and `{ss.TC_Type}\{CollisionFidelity{ss.TC_Type}Enum.CollisionFidelity?{ss._Separator}RenderFidelity{ss.TC_Type}Enum.RenderFidelity?{ss._Separator}FluidFidelity{ss.TC_Type}Enum.FluidFidelity?\}?`) or ""}`}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
			rich..=`{WriteRichText(ss._local,ScriptLocal)}{WriteRichText("function",ScriptFunction)} {WriteRichText("__"..ss.RL_Deffered_Fn_Mesh,ScriptFunctionName)}({ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}tx{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("string",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}Id{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("string",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}r{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}`) or ""}`) or `t{(ss.Typechecking==true and `{ss.TC_Type}\{CollisionFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}?{ss._Separator}RenderFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}?{ss._Separator}FluidFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("FluidFidelity",Color3.new(0,1,1))}?\}?`) or ""}`}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
			if ss._SaveMeshes_Cache==true then
				if ss.FNC_Mesh==true then
					txt..=`\n{ss.t}ApplyMesh({ss.localMeshVariableName}{ss.FuncSeparator}{ss._SaveMeshes_FN_Name}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}))`
					rich..=`\n{ss.t}{WriteRichText("ApplyMesh",ScriptMethod)}({ss.localMeshVariableName}{ss.FuncSeparator}{WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}))`

					txt..=`\n{ss.t}{ss.NC_InsSetProperty}({ss.localMeshVariableName}{ss.FuncSeparator}{ConstructorTostring("string","TextureID")}{ss.FuncSeparator}tx)`
					rich..=`\n{ss.t}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({ss.localMeshVariableName}{ss.FuncSeparator}{select(2,ConstructorTostring("string","TextureID"))}{ss.FuncSeparator}tx)`
				else
					txt..=`\n{ss.t}{ss.localMeshVariableName}:ApplyMesh({ss._SaveMeshes_FN_Name}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}))`
					rich..=`\n{ss.t}{ss.localMeshVariableName}:{WriteRichText("ApplyMesh",ScriptMethod)}({WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"}))`

					txt..=`\n{ss.t}{ss.localMeshVariableName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string","TextureID")}]`) or ".".."TextureID"}{ss._Equal}tx`
					rich..=`\n{ss.t}{ss.localMeshVariableName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string","TextureID"))}]`) or "."..WriteRichText("TextureID",ScriptProperty)}{ss._Equal}tx`
				end
			elseif ss.UseMeshFunction==true then
				--Manually apply meshes but through function
				txt..=`\n{ss.t}{ss._local}_{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}{ss._SaveMeshes_FN_Name}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
				rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}_{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""}{ss._Equal}{WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
				if ss.FNC_Mesh==true then
					txt..=`\n{ss.t}ApplyMesh({ss.localMeshVariableName}{ss.FuncSeparator}_{ss.localMeshVariableName})\n{ss.t}Destroy(_{ss.localMeshVariableName})`
					rich..=`\n{ss.t}{WriteRichText("ApplyMesh",ScriptMethod)}({ss.localMeshVariableName}{ss.FuncSeparator}_{ss.localMeshVariableName})\n{ss.t}{WriteRichText("Destroy",ScriptMethod)}(_{ss.localMeshVariableName})`

					txt..=`\n{ss.t}{ss.NC_InsSetProperty}({ss.localMeshVariableName}{ss.FuncSeparator}{ConstructorTostring("string","TextureID")}{ss.FuncSeparator}tx)`
					rich..=`\n{ss.t}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({ss.localMeshVariableName}{ss.FuncSeparator}{select(2,ConstructorTostring("string","TextureID"))}{ss.FuncSeparator}tx)`
				else
					txt..=`\n{ss.t}{ss.localMeshVariableName}:ApplyMesh(_{ss.localMeshVariableName})\n{ss.t}_{ss.localMeshVariableName}:Destroy()`
					rich..=`\n{ss.t}{ss.localMeshVariableName}:{WriteRichText("ApplyMesh",ScriptMethod)}(_{ss.localMeshVariableName})\n{ss.t}_{ss.localMeshVariableName}:{WriteRichText("Destroy",ScriptMethod)}()`

					txt..=`\n{ss.t}{ss.localMeshVariableName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string","TextureID")}]`) or ".".."TextureID"}{ss._Equal}tx`
					rich..=`\n{ss.t}{ss.localMeshVariableName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string","TextureID"))}]`) or "."..WriteRichText("TextureID",ScriptProperty)}{ss._Equal}tx`
				end
			else--Manually apply meshes
				if ss.FNC_Mesh==true then
					txt..=`\n{ss.t}{ss._local}_{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
					rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}_{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`

					txt..=`\n{ss.t}ApplyMesh({ss.localMeshVariableName}{ss.FuncSeparator}_{ss.localMeshVariableName})\n{ss.t}Destroy(_{ss.localMeshVariableName})`
					rich..=`\n{ss.t}{WriteRichText("ApplyMesh",ScriptMethod)}({ss.localMeshVariableName}{ss.FuncSeparator}_{ss.localMeshVariableName})\n{ss.t}{WriteRichText("Destroy",ScriptMethod)}(_{ss.localMeshVariableName})`

					txt..=`\n{ss.t}{ss.NC_InsSetProperty}({ss.localMeshVariableName}{ss.FuncSeparator}{ConstructorTostring("string","TextureID")}{ss.FuncSeparator}tx)`
					rich..=`\n{ss.t}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({ss.localMeshVariableName}{ss.FuncSeparator}{select(2,ConstructorTostring("string","TextureID"))}{ss.FuncSeparator}tx)`
				else
					txt..=`\n{ss.t}{ss._local}_{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
					rich..=`\n{ss.t}{WriteRichText(ss._local,ScriptLocal)}_{ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}(Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`


					txt..=`\n{ss.t}{ss.localMeshVariableName}:ApplyMesh(_{ss.localMeshVariableName})\n{ss.t}_{ss.localMeshVariableName}:Destroy()`
					rich..=`\n{ss.t}{ss.localMeshVariableName}:{WriteRichText("ApplyMesh",ScriptMethod)}(_{ss.localMeshVariableName})\n{ss.t}_{ss.localMeshVariableName}:{WriteRichText("Destroy",ScriptMethod)}()`

					txt..=`\n{ss.t}{ss.localMeshVariableName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string","TextureID")}]`) or ".".."TextureID"}{ss._Equal}tx`
					rich..=`\n{ss.t}{ss.localMeshVariableName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string","TextureID"))}]`) or "."..WriteRichText("TextureID",ScriptProperty)}{ss._Equal}tx`
				end
			end
			--function close
			txt..=`\n{ss["end"]}\n`
			rich..=`\n{WriteRichText(ss["end"],ScriptLuauKeyword)}\n`

			--Proxy function
			--function open
			txt..=`{ss._local}function {ss.RL_Deffered_Fn_Mesh}({ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}MeshPart`) or ""}{ss.FuncSeparator}tx{(ss.Typechecking==true and `{ss.TC_Type}string`) or ""}{ss.FuncSeparator}Id{(ss.Typechecking==true and `{ss.TC_Type}string`) or ""}{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{(ss.Typechecking==true and `{ss.TC_Type}Enum.CollisionFidelity`) or ""}{ss.FuncSeparator}r{(ss.Typechecking==true and `{ss.TC_Type}Enum.RenderFidelity`) or ""}`) or `t{(ss.Typechecking==true and `{ss.TC_Type}\{CollisionFidelity{ss.TC_Type}Enum.CollisionFidelity?{ss._Separator}RenderFidelity{ss.TC_Type}Enum.RenderFidelity?{ss._Separator}FluidFidelity{ss.TC_Type}Enum.FluidFidelity?\}?`) or ""}`}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
			rich..=`{WriteRichText(ss._local,ScriptLocal)}{WriteRichText("function",ScriptFunction)} {WriteRichText(ss.RL_Deffered_Fn_Mesh,ScriptFunctionName)}({ss.localMeshVariableName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("MeshPart",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}tx{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("string",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}Id{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("string",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}`) or ""}{ss.FuncSeparator}r{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}`) or ""}`) or `t{(ss.Typechecking==true and `{ss.TC_Type}\{CollisionFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("CollisionFidelity",Color3.new(0,1,1))}?{ss._Separator}RenderFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("RenderFidelity",Color3.new(0,1,1))}?{ss._Separator}FluidFidelity{ss.TC_Type}{WriteRichText("Enum",Color3.new(0,1,1))}.{WriteRichText("FluidFidelity",Color3.new(0,1,1))}?\}?`) or ""}`}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
			--body
			txt..=`\n{ss.t}task{(ss.IndexingBy=="Dots" and `.spawn`) or `[{ConstructorTostring("string","spawn")}]`}(__{ss.RL_Deffered_Fn_Mesh}{ss.FuncSeparator}{ss.localMeshVariableName}{ss.FuncSeparator}tx{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
			rich..=`\n{ss.t}{WriteRichText("task",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("spawn",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","spawn"))}]`}(__{ss.RL_Deffered_Fn_Mesh}{ss.FuncSeparator}{ss.localMeshVariableName}{ss.FuncSeparator}tx{ss.FuncSeparator}Id{ss.FuncSeparator}{(ss.CMPAsyncService=="InsertService" and `c{ss.FuncSeparator}r`) or "t"})`
			--function close
			txt..=`\n{ss["end"]}\n`
			rich..=`\n{WriteRichText(ss["end"],ScriptLuauKeyword)}\n`
		end

		return txt,rich
	end


	-- true = no any properties nor children, nil = no properties but have children,false = has properties and maybe children
	local function __IsPropertieLessDoEnd(ins:Instance,baseImport:string?,Attributes:{[string]:any},Tags:{string},properties:{[string]:any}):boolean
		if ss.RL_Referanceless==true and baseImport==nil and next(Attributes)==nil and #Tags==0 then
			local HasProperties:boolean = false 
			for i,v in properties do
				local foundBreak:boolean = IsBlocked(ins,i)
				--Ignore List
				if foundBreak then continue end
				--Already in _base
				if baseImport~=nil and (_baseImports::_baseImports)[baseImport][i]==v then continue end
				return false
			end
		else
			return false
		end
		return true
	end	
	local function Luau_DoEndWrite(ins:Instance,code:CreateStr.class|any,riched_code:CreateStr.class|any,varName:string,IsPropertieLessDoEnd:boolean,Layer:number,Attributes:{[string]:any},Tags:{string},properties:{[string]:any},baseImport:string?,Parent:string?,RecursiveHierarchyQueue:{[Instance]:{{Prop:string;Var:string}}},DirrectAccessToVarAvalible:{[Instance]:string}):()
		if ss.RL_WrapPropDoEnd==true and IsPropertieLessDoEnd==false then
			Layer+=1
			code..=`{ss["do"]}`
			riched_code..=`{WriteRichText(ss["do"],ScriptLuauKeyword)}`
		end
		if ins.ClassName == "MeshPart" and (ins::MeshPart).MeshId~="" and ss._SaveMeshes==true and ss.MeshPartCreationMode=="Defered" then
			local dictionary,dictionary_rich = GetMeshPropertiesConfigs(ins::MeshPart)
			code..=`\n{string.rep(ss.t,Layer)}{ss.RL_Deffered_Fn_Mesh}({varName}{ss.FuncSeparator}{ConstructorTostring("string",properties.TextureID::string? or "")}{ss.FuncSeparator}{ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.RL_Deffered_Fn_Mesh,ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",properties.TextureID::string? or ""))}{ss.FuncSeparator}{select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})`
		end
		--Prop
		--Tags and Attributes
		if ss.RL_AttributesTags==true then
			--Attributes
			if ss.FastNamecall==true then
				for i,v in Attributes do
					code..=`\n{string.rep(ss.t,Layer)}SetAttribute({varName}{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{ConstructorTostring(typeof(v),v)})`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText("SetAttribute",ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(v),v))})`
				end
			else
				for i,v in Attributes do
					code..=`\n{string.rep(ss.t,Layer)}{varName}:SetAttribute({ConstructorTostring("string",i)}{ss.FuncSeparator}{ConstructorTostring(typeof(v),v)})`
					riched_code..=`\n{string.rep(ss.t,Layer)}{varName}:{WriteRichText("SetAttribute",ScriptMethod)}({select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(v),v))})`
				end
			end
			--Tags
			if ss.FastNamecall==true then
				for i,v in Tags do
					code..=`\n{string.rep(ss.t,Layer)}AddTag({varName}{ss.FuncSeparator}{ConstructorTostring("string",v)})`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText("AddTag",ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v))})`
				end
			else
				for i,v in Tags do
					code..=`\n{string.rep(ss.t,Layer)}{varName}:AddTag({ConstructorTostring("string",v)})`
					riched_code..=`\n{string.rep(ss.t,Layer)}{varName}:{WriteRichText("AddTag",ScriptMethod)}({select(2,ConstructorTostring("string",v))})`
				end
			end
		end

		--Setting _base
		if baseImport~=nil then
			code..=`\n{string.rep(ss.t,Layer)}{ss.Base_Imports_FN_subName}{baseImport}({varName})`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(`{ss.Base_Imports_FN_subName}{baseImport}`,ScriptMethod)}({varName})`
		end
		local AllowPositionOverCFrame:boolean = (ss.PreferVectorForEmptyRotCFrame==true and properties.CFrame~=nil and properties.Position~=nil and vector.magnitude(vector.create((properties.CFrame::CFrame):ToOrientation()))==0) or false
		if ss.NameOnTop==true and properties.Name~=nil and IsBlocked(ins,"Name")==false then
			local i:string = "Name"
			local c_code,c_rich = ConstructorTostring("string",properties.Name::string)
			if ss.FNC_Properties==true then
				code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({varName}{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{Parent})`
				riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{Parent})`
			else
				code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",i)}]`) or "."..i}{ss._Equal}{c_code}`
				riched_code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",i))}]`) or "."..WriteRichText(i,ScriptProperty)}{ss._Equal}{c_rich}`
			end	
		end
		----------
		for i,v in spairs(properties) do
			if i=="Name" and ss.NameOnTop==true then continue end
			local foundBreak:boolean = false
			for ii,vv in IgnoredPropertiesList do
				if ins:IsA(ii) and table.find(vv,i)~=nil then
					foundBreak=true
					break
				end
			end
			--Ignore List
			if (foundBreak and (i~="Position" or AllowPositionOverCFrame==false)) or (i::string=="CFrame" and AllowPositionOverCFrame==true) then continue end
			--Already in _base
			if baseImport~=nil and (_baseImports::_baseImports)[baseImport][i]==v then continue end
			if (ss.AvoiddoubleTextureID==true and ins.ClassName=="MeshPart" and ss._SaveMeshes==true and (ins::MeshPart).MeshId~="" and ss.MeshPartCreationMode=="Defered" and i::string=="TextureID") then continue end
			local type:string = typeof(v)
			if type=="Instance" then
				if not (v::Instance):IsDescendantOf(SelectedInstance::Instance) and v~=ins and v~=SelectedInstance and (ss.OutsideHierarchyInstances~="SafeIndex" or (v~=SelectedInstance and (v.Parent==game or typeof(select(2,pcall(game.FindService,game,v.Parent.ClassName))::any|string)=="Instance"))) then
					--Outside of hierarchy
					local c_code,c_rich = GoToIndexPath(v::Instance)
					if ss.FNC_Properties==true then
						code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({varName}{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{c_code})`
						riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{c_rich})`
						continue
					end
					code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",i)}]`) or "."..i}{ss._Equal}{c_code}`
					riched_code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",i))}]`) or "."..WriteRichText(i,ScriptProperty)}{ss._Equal}{c_rich}`
				elseif ((ss.RL_RecursionWrite=="Instant" or ss.RL_RecursionWrite=="Hybrid") and (v==ins or v==SelectedInstance)) or ((ss.RL_RecursionWrite=="Instant" or ss.RL_RecursionWrite=="Hybrid") and ((v::Instance):IsDescendantOf(SelectedInstance::Instance) and DirrectAccessToVarAvalible[v]~=nil)) then	
					--Recursive hierarchy instance already exists
					if ss.FNC_Properties==true then
						code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({varName}{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{DirrectAccessToVarAvalible[v]::string? or varName})`
						riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{DirrectAccessToVarAvalible[v]::string? or varName})`
						continue
					end
					code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",i)}]`) or "."..i}{ss._Equal}{DirrectAccessToVarAvalible[v]::string? or varName}`
					riched_code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",i))}]`) or "."..WriteRichText(i,ScriptProperty)}{ss._Equal}{DirrectAccessToVarAvalible[v]::string? or varName}`
				elseif ss.RL_RecursionWrite=="InTheEnd" or ((v::Instance):IsDescendantOf(SelectedInstance::Instance) and DirrectAccessToVarAvalible[v]::string?==nil) then
					--Recursive hierarchy write
					if RecursiveHierarchyQueue[v]==nil then
						RecursiveHierarchyQueue[v]={{Var=varName;Prop=i;}}
					else
						table.insert(RecursiveHierarchyQueue[v],{Var=varName;Prop=i;})
					end
				elseif ss.OutsideHierarchyInstances=="SafeIndex" and type=="Instance" then
					--Safe index
					local c,r = GoToIndexPath(ins,v::Instance,{Text = varName,Rich = varName},i,Layer+((ss.RL_WrapSafeIndexDoEnd==true  and 1) or 0)::number)
					code..=((ss.RL_WrapSafeIndexDoEnd==true and `\n{string.rep(ss.t,Layer)}do`) or "")..c..((ss.RL_WrapSafeIndexDoEnd==true and `\n{string.rep(ss.t,Layer)}end`) or "")
					riched_code..=((ss.RL_WrapSafeIndexDoEnd==true and `\n{string.rep(ss.t,Layer)}{WriteRichText("do",ScriptLuauKeyword)}`) or "")..r..((ss.RL_WrapSafeIndexDoEnd==true and `\n{string.rep(ss.t,Layer)}{WriteRichText("end",ScriptLuauKeyword)}`) or "")
				end
				continue
			end
			if ConstructorTostring_Switch[type]==nil then continue end
			local c_code,c_rich = ConstructorTostring(type,v)
			if ss.FNC_Properties==true then
				code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({varName}{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{c_code})`
				riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{c_rich})`
				continue
			end
			code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",i)}]`) or "."..i}{ss._Equal}{c_code}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",i))}]`) or "."..WriteRichText(i,ScriptProperty)}{ss._Equal}{c_rich}`
		end


		--Parent
		if Parent~=nil and IsPropertieLessDoEnd==false then
			local i:string = "Parent"
			if ss.FNC_Properties==true then
				code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({varName}{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{Parent})`
				riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({varName}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{Parent})`
			else
				code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",i)}]`) or "."..i}{ss._Equal}{Parent}`
				riched_code..=`\n{string.rep(ss.t,Layer)}{varName}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",i))}]`) or "."..WriteRichText(i,ScriptProperty)}{ss._Equal}{Parent}`
			end	
		end
		--Closing do end
		if ss.RL_WrapPropDoEnd==true  and IsPropertieLessDoEnd==false then
			Layer-=1
			code..=`\n{string.rep(ss.t,Layer)}{ss["end"]}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss["end"],ScriptLuauKeyword)}`
		end

	end
	local function GetArgsUnionAsyncOperation(ins:UnionOperation|IntersectOperation|NegateOperation):(string,string)
		return `{(ins.CollisionFidelity~=Enum.CollisionFidelity.Default and `{ss.FuncSeparator}{ConstructorTostring("EnumItem",ins.CollisionFidelity)}`) or ""}{(ins.RenderFidelity~=Enum.RenderFidelity.Automatic and `{(ins.CollisionFidelity==Enum.CollisionFidelity.Default and `{ss.FuncSeparator}{ConstructorTostring("nil",nil)}`) or ""}{ss.FuncSeparator}{ConstructorTostring("EnumItem",ins.RenderFidelity)}`) or ""}`,`{(ins.CollisionFidelity~=Enum.CollisionFidelity.Default and `{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",ins.CollisionFidelity))}`) or ""}{(ins.RenderFidelity~=Enum.RenderFidelity.Automatic and `{(ins.CollisionFidelity==Enum.CollisionFidelity.Default and `{ss.FuncSeparator}{select(2,ConstructorTostring("nil",nil))}`) or ""}{ss.FuncSeparator}{select(2,ConstructorTostring("EnumItem",ins.RenderFidelity))}`) or ""}`
	end
	local function NeedsUnionOperation(obj:Instance):boolean
		if not obj:IsA("PartOperation") or ss.SaveUnions==false then return false end
		local ret:boolean = true
		local self = Instance.fromExisting(obj)
		local loot = plugin:Separate({self})
		if #loot==1 and not loot[1]:IsA("PartOperation") then ret=false end

		for i,v in loot do
			v:Destroy()
		end
		self:Destroy()
		return ret
	end
	--Returns variable name of produced union
	local function __WriteUnionConstructor(obj:Instance,code:CreateStr.class|any,riched_code:CreateStr.class|any,Layer:number,reg:{[string]:true},reg_ptr:{[Instance]:string},Depth:number):string
		local varname = reg_ptr[obj] or GetVarName(obj.Name,reg)
		reg_ptr[obj]=varname



		if obj:IsA("UnionOperation") or obj:IsA("IntersectOperation") or (obj:IsA("NegateOperation") and NeedsUnionOperation(obj)) then
			--Unify
			local self = obj:Clone()
			local loot = plugin:Separate({self})
			--Initiate children
			local Union=table.create(#loot)::{BasePart}
			local Negate=table.create(#loot)::{NegateOperation}
			if #loot==1 then
				reg_ptr[loot[1]]=varname
			end
			local _depth:number = 0
			for i,v in loot do
				if v:IsA("NegateOperation") then table.insert(Negate,v);__WriteUnionConstructor(v,code,riched_code,Layer,reg,reg_ptr,_depth);continue end
				table.insert(Union,v)
				__WriteUnionConstructor(v,code,riched_code,Layer,reg,reg_ptr,_depth)
				_depth+=1
			end

			local target:string = varname
			--Combine
			if #Union>1 then
				target=if #Negate==0 then varname else GetVarName(varname,reg)

				if ss.FNC_SolidModeling == true then
					code..=`\n{string.rep(ss.t,Layer)}{ss._local}{target}{ss._Equal}{(obj:IsA("IntersectOperation") and "IntersectAsync") or "UnionAsync"}({reg_ptr[Union[1]]}{ss.FuncSeparator}\{`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{target}{ss._Equal}{(obj:IsA("IntersectOperation") and WriteRichText("IntersectAsync",ScriptMethod)) or WriteRichText("UnionAsync",ScriptMethod)}({reg_ptr[Union[1]]}{ss.FuncSeparator}\{`
				else
					code..=`\n{string.rep(ss.t,Layer)}{ss._local}{target}{ss._Equal}{reg_ptr[Union[1]]}:{(obj:IsA("IntersectOperation") and "IntersectAsync") or "UnionAsync"}(\{`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{target}{ss._Equal}{reg_ptr[Union[1]]}:{(obj:IsA("IntersectOperation") and WriteRichText("IntersectAsync",ScriptMethod)) or WriteRichText("UnionAsync",ScriptMethod)}(\{`
				end

				for i,v in Union do
					if i==1 then continue end
					code..=`{reg_ptr[v]}{ss._Separator}`
					riched_code..=`{reg_ptr[v]}{ss._Separator}`
				end
				local c,r = GetArgsUnionAsyncOperation(self)
				code..=`\}{c})`
				riched_code..=`\}{r})`

				local baseImport:string? = (CurrentConvertType=="Raw Luau" and NE__Base({},{},(obj:IsA("IntersectOperation") and "IntersectOperation") or "UnionOperation",GetProperties(obj,true))) or nil
				local Properties = {}
				if Depth==0 then Properties.Anchored=true end
				Luau_DoEndWrite(obj,code,riched_code,varname,__IsPropertieLessDoEnd(obj,baseImport,{},{},Properties),Layer,{},{},Properties,baseImport,(Depth==0 and "workspace") or nil,{},{})


			else
				if reg_ptr[Union[1]]::string?==nil then return varname end
				target = reg_ptr[Union[1]]::string
			end
			if #Negate~=0 then

				if ss.FNC_SolidModeling == true then
					code..=`\n{string.rep(ss.t,Layer)}{ss._local}{varname}{ss._Equal}SubtractAsync({target}{ss.FuncSeparator}\{`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varname}{ss._Equal}{WriteRichText("SubtractAsync",ScriptMethod)}({target}{ss.FuncSeparator}\{`
				else
					code..=`\n{string.rep(ss.t,Layer)}{ss._local}{varname}{ss._Equal}{target}:SubtractAsync(\{`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varname}{ss._Equal}{target}:{WriteRichText("SubtractAsync",ScriptMethod)}(\{`
				end
				for i,v in Negate do
					code..=`{reg_ptr[v]}{ss._Separator}`
					riched_code..=`{reg_ptr[v]}{ss._Separator}`
				end
				local c,r = GetArgsUnionAsyncOperation(self)
				code..=`\}{c})`
				riched_code..=`\}{r})`

				local baseImport:string? = (CurrentConvertType=="Raw Luau" and NE__Base({},{},"UnionOperation",GetProperties(obj,true))) or nil
				local Properties = {}
				if Depth==0 then Properties.Anchored=true end
				Luau_DoEndWrite(obj,code,riched_code,varname,__IsPropertieLessDoEnd(obj,baseImport,{},{},Properties),Layer,{},{},Properties,baseImport,(Depth==0 and "workspace") or nil,{},{})


			end
			--Clean
			for i,v in loot do
				v:Destroy()
			end
			self:Destroy()
		else
			--Children initiation

			local class:string = GetTypeOfInstance(obj)
			code..=`\n{string.rep(ss.t,Layer)}{ss._local}{varname}{ss._Equal}Instance{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new")}]`}({ConstructorTostring("string",class)})`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varname}{ss._Equal}{WriteRichText("Instance",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new"))}]`}({select(2,ConstructorTostring("string",class))})`
			local baseImport:string? = (CurrentConvertType=="Raw Luau" and NE__Base({},{},class,GetProperties(obj,true))) or nil
			local Properties = GetProperties(obj)
			if Depth==0 then Properties.Anchored=true end
			Luau_DoEndWrite(obj,code,riched_code,varname,__IsPropertieLessDoEnd(obj,baseImport,{},{},Properties),Layer,{},{},Properties,baseImport,(Depth==0 and "workspace") or nil,{},{})

		end

		return varname
	end

	local function WriteUnionConstructor(obj:Instance,code:CreateStr.class|any,riched_code:CreateStr.class|any,Layer:number,reg:{[string]:true},reg_ptr:{[Instance]:string}):string
		local selfVar = (next::any)(reg)::string?
		local ret:string = __WriteUnionConstructor(obj,code,riched_code,Layer,reg,reg_ptr,1)
		if ss.FastNamecall==true then
			for i in reg do
				if i==ret or i==selfVar then continue end
				code..=`\n{string.rep(ss.t,Layer)}Destroy({i})`
				riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText("Destroy",ScriptMethod)}({i})`
			end
		else
			for i in reg do
				if i==ret or i==selfVar then continue end
				code..=`\n{string.rep(ss.t,Layer)}{i}:Destroy()`
				riched_code..=`\n{string.rep(ss.t,Layer)}{i}:{WriteRichText("Destroy",ScriptMethod)}()`
			end
		end
		return ret	
	end



	local function NE_BuildProperties(ins:Instance,code:CreateStr.class|any,riched_code:CreateStr.class|any,Layer:number,Initiator:true?,_count:number?):()
		local Type:string = GetTypeOfInstance(ins)
		if ins:IsA("PartOperation") and NeedsUnionOperation(ins)==false then
			Type="Part"
		end
		local properties = GetProperties(ins,nil,Type)
		local bypass__properties = GetProperties(ins,true)
		local Tags = ins:GetTags()
		local Attributes = ins:GetAttributes()
		local HasMacros:boolean = false
		local properties__bool:boolean = false
		local children = ins:GetChildren()
		if NeedsUnionOperation(ins) and ss.NE_using_run==true then
			Type=ss._ReplacementInstance;
			properties={}::{[string]:any};
			Tags = {};
			Attributes = {};
		end

		--Brackets
		if Initiator~=true then
			if ss.NE_NewArgConstructor==true then
				--code..=`{ss._local}{ss._NE_HierrarchyName}{ss._Equal}{ss._HierarchyBuilderFunctionName}{(ss.NE_NewArgConstructor==true and ss.NE_NAC_New_2_Spacing) or ""}{(ss.NE_NewArgConstructor==true and `{(ss._NE_FN_BRACKETS==true and "(") or ""}{ConstructorTostring("string",Type)}{ss.NE_NAC_Spacing}{(ss._NE_FN_BRACKETS==true and ss.FuncSeparator) or ""}`) or ""}{(ss.NE_NewArgConstructor==false and ss._NE_FN_BRACKETS==true and "(") or ""}\{`
				code..=`\n{string.rep(ss.t,Layer-1)}{ss._HierarchyBuilderFunctionName}{(ss.NE_NewArgConstructor==true and ss.NE_NAC_New_2_Spacing) or ""}{(ss.NE_NewArgConstructor==true and `{(ss._NE_FN_BRACKETS==true and "(") or ""}{ConstructorTostring("string",Type)}{ss.NE_NAC_Spacing}{(ss._NE_FN_BRACKETS==true and ss.FuncSeparator) or ""}`) or ""}{(ss.NE_NewArgConstructor==false and ss._NE_FN_BRACKETS==true and "(") or ""}\{`
				riched_code..=`\n{string.rep(ss.t,Layer-1)}{WriteRichText(ss._HierarchyBuilderFunctionName,ScriptMethod)}{(ss.NE_NewArgConstructor==true and ss.NE_NAC_New_2_Spacing) or ""}{(ss.NE_NewArgConstructor==true and `{(ss._NE_FN_BRACKETS==true and "(") or ""}{select(2,ConstructorTostring("string",Type))}{ss.NE_NAC_Spacing}{(ss._NE_FN_BRACKETS==true and ss.FuncSeparator) or ""}`) or ""}{(ss.NE_NewArgConstructor==false and ss._NE_FN_BRACKETS==true and "(") or ""}\{`
			else
				code..=`\n{string.rep(ss.t,Layer-1)}\{`
				riched_code..=`\n{string.rep(ss.t,Layer-1)}\{`
			end
		end
		--Declearing ClassName
		if ss._NE_Prop_Type_Newline==true then
			code..=`\n{string.rep(ss.t,Layer)}`
			riched_code..=`\n{string.rep(ss.t,Layer)}`
		end
		if ss.NE_NewArgConstructor==true and properties.Name~=nil and ss.NameOnTop==true then
			code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string","Name")}]`) or "Name"}{ss._Equal}{ConstructorTostring("string",properties.Name::string)}{ss._Separator}`
			riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string","Name"))}]`) or "Name"}{ss._Equal}{select(2,ConstructorTostring("string",properties.Name::string))}{ss._Separator}`
		end

		if ss.NE_NewArgConstructor==false then
			if properties.Name==nil or IsBlocked(ins,"Name") or ss.NameOnTop==false then
				--Declear instance for for mesh
				if ins.ClassName=="MeshPart" and (ins::MeshPart).MeshId~="" and ss._SaveMeshes==true and ss.MeshPartCreationMode=="Compute" then
					local dictionary,dictionary_rich = GetMeshPropertiesConfigs(ins::MeshPart)

					if ss.UseMeshFunction==true then
						code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ss._SaveMeshes_FN_Name}({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}){ss._Separator}`
						riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}){ss._Separator}`
					elseif ss.UseMeshFunction==false and ss.NE_using_run==true then
						code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ConstructorTostring("string",Type)}{ss._Separator}`
						riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{select(2,ConstructorTostring("string",Type))}{ss._Separator}`
					elseif ss.FNC_Mesh==true then
						code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}{ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}){ss._Separator}`
						riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}{select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}){ss._Separator}`
					else
						code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}){ss._Separator}`
						riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}){ss._Separator}`
					end
				else
					--Type
					code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ConstructorTostring("string",Type)}{ss._Separator}`
					riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{select(2,ConstructorTostring("string",Type))}{ss._Separator}`
				end
			else
				properties__bool=true
				--Name
				code..=`{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string","Name")}]`) or "Name"}{ss._Equal}{ConstructorTostring("string",properties.Name::string)}{ss._Separator}`
				riched_code..=`{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string","Name"))}]`) or "Name"}{ss._Equal}{select(2,ConstructorTostring("string",properties.Name::string))}{ss._Separator}`
				--Type
				--Declear instance for for mesh
				if ins.ClassName=="MeshPart" and (ins::MeshPart).MeshId~="" and ss._SaveMeshes==true and ss.MeshPartCreationMode=="Compute" then
					local dictionary,dictionary_rich = GetMeshPropertiesConfigs(ins::MeshPart)
					if ss.UseMeshFunction==true then
						code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ss._SaveMeshes_FN_Name}({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}){ss._Separator}`
						riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}){ss._Separator}`
					elseif ss.UseMeshFunction==false and ss.NE_using_run==true then
						code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ConstructorTostring("string",Type)}{ss._Separator}`
						riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{select(2,ConstructorTostring("string",Type))}{ss._Separator}`
					elseif ss.FNC_Mesh==true then
						code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}{ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}){ss._Separator}`
						riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}{select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}){ss._Separator}`
					else
						code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}){ss._Separator}`
						riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}){ss._Separator}`
					end
				else
					code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",ss.NE_ClassName)}]`) or ss.NE_ClassName}{ss._Equal}{ConstructorTostring("string",Type)}{ss._Separator}`
					riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.NE_ClassName))}]`) or ss.NE_ClassName}{ss._Equal}{select(2,ConstructorTostring("string",Type))}{ss._Separator}`
				end
			end
		end
		----------------------
		---_base---
		local baseImport:string? = NE__Base(Attributes,Tags,GetTypeOfInstance(ins),bypass__properties)
		--Setting _base
		if baseImport~=nil then
			code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","_base")}]`) or "_base"}{ss._Equal}{baseImport}{ss._Separator}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_base"))}]`) or "_base"}{ss._Equal}{baseImport}{ss._Separator}`
			HasMacros=true	
		end

		if _count~=nil then
			code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","_count")}]`) or "_count"}{ss._Equal}{ConstructorTostring("number",_count)}{ss._Separator}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_count"))}]`) or "_count"}{ss._Equal}{select(2,ConstructorTostring("number",_count))}{ss._Separator}`
			HasMacros=true	
		end
		local AllowPositionOverCFrame:boolean = (ss.PreferVectorForEmptyRotCFrame==true and properties.CFrame~=nil and properties.Position~=nil and vector.magnitude(vector.create((properties.CFrame::CFrame):ToOrientation()))==0) or false
		----------
		for i,v in spairs(properties) do
			if i=="Name" and ss.NameOnTop==true then continue end
			local foundBreak:boolean = IsBlocked(ins,i)
			--Ignore List
			if (foundBreak and (i~="Position" or AllowPositionOverCFrame==false)) or (i::string=="CFrame" and AllowPositionOverCFrame==true) then continue end
			--Already in _base
			if baseImport~=nil and (_baseImports::_baseImports)[baseImport][i]==v then continue end
			if (ss.AvoiddoubleTextureID==true and ins.ClassName=="MeshPart" and ss._SaveMeshes==true and (ins::MeshPart).MeshId~="" and (ss.MeshPartCreationMode=="Defered" or (ss.MeshPartCreationMode=="Compute"  and (ss.UseMeshFunction==false or ss.NE_NewArgConstructor==true) and ss.NE_using_run==true)) and i::string=="TextureID") then continue end
			properties__bool=true
			local type:string = typeof(v)
			if type=="Instance" then
				if not (v::Instance):IsDescendantOf(SelectedInstance::Instance) and v~=ins and v~=SelectedInstance and (ss.OutsideHierarchyInstances~="SafeIndex" or (v~=SelectedInstance and (v.Parent==game or typeof(select(2,pcall(game.FindService,game,v.Parent.ClassName))::any|string)=="Instance"))) then
					--Outside of hierarchy
					local c_code,c_rich = GoToIndexPath(v::Instance)
					code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{c_code}{ss._Separator}`
					riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{c_rich}{ss._Separator}`
				end
				continue
			end
			if ConstructorTostring_Switch[type]==nil then continue end

			local c_code,c_rich = ConstructorTostring(type,v)
			code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{c_code}{ss._Separator}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{c_rich}{ss._Separator}`
		end

		--_run--
		--Include__run?
		local Include__run:boolean = ((ss._NE_Hierrarchy_TagsAndAttributes=="_run" and (#Tags~=0 or next(Attributes)~=nil)) or NeedsUnionOperation(ins) or (ins.ClassName=="MeshPart" and ss._SaveMeshes==true and (ins::MeshPart).MeshId~="" and ss.MeshPartCreationMode=="Compute" and (ss.UseMeshFunction==false or ss.NE_NewArgConstructor==true))) and ss.NE_using_run==true
		if Include__run==false and ss._runRecursiveHierarchy==true then
			for i,v in properties do
				if typeof(v)=="Instance" and (v:IsDescendantOf(SelectedInstance::Instance) or v==ins or v==SelectedInstance or (ss.OutsideHierarchyInstances=="SafeIndex" and ((v.Parent~=game and typeof(select(2,pcall(game.FindService,game,(v.Parent::Instance).ClassName))::any|string)~="Instance")))) then Include__run=true break end
			end
		end
		if Include__run==true then
			HasMacros=true
			--opening function
			code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","_run")}]`) or `_run`}{ss._Equal}function(self{(ss.Typechecking==true and `{ss.TC_Type}{Type}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}{if NeedsUnionOperation(ins)==true then if ins.ClassName=="IntersectOperation" then "IntersectOperation" else "UnionOperation" else "()"}`) or ""}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_run"))}]`) or `_run`}{ss._Equal}{WriteRichText("function",ScriptFunction)}({WriteRichText("self",ScriptSelf)}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(Type,Color3.new(0,1,1))}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}{if NeedsUnionOperation(ins)==true then if ins.ClassName=="IntersectOperation" then WriteRichText("IntersectOperation",Color3.new(0,1,1)) else WriteRichText("UnionOperation",Color3.new(0,1,1)) else "()"}`) or ""}`
			if ss._runRecursiveHierarchy==true then
				NE____RecursiveHierarchy(ins,properties,code,riched_code,Layer)
			end
			if ss._NE_Hierrarchy_TagsAndAttributes=="_run" and (#Tags~=0 or next(Attributes)~=nil) then
				NE__TagsAndAttributes(code,riched_code,Layer,Attributes,Tags,baseImport)
			end
			--Mesh
			if ins.ClassName=="MeshPart" and ss._SaveMeshes==true and (ins::MeshPart).MeshId~="" and ss.MeshPartCreationMode=="Compute" and ss.UseMeshFunction==false and ss.NE_using_run==true then
				local dictionary,dictionary_rich = GetMeshPropertiesConfigs(ins::MeshPart)
				if ss.FNC_Mesh==true then
					code..=`\n{string.rep(ss.t,Layer+1)}{ss._local}{ss.localMeshVariableName}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}{ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})\n{string.rep(ss.t,Layer+1)}ApplyMesh(self{ss.FuncSeparator}{ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}Destroy({ss.localMeshVariableName})`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}{select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})\n{string.rep(ss.t,Layer+1)}{WriteRichText("ApplyMesh",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}{WriteRichText("Destroy",ScriptMethod)}({ss.localMeshVariableName})`
				else
					code..=`\n{string.rep(ss.t,Layer+1)}{ss._local}{ss.localMeshVariableName}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})\n{string.rep(ss.t,Layer+1)}self:ApplyMesh({ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}{ss.localMeshVariableName}:Destroy()`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("ApplyMesh",ScriptMethod)}({ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}{ss.localMeshVariableName}:{WriteRichText("Destroy",ScriptMethod)}()`
				end
				--TextureID
				if properties.TextureID~=nil then
					properties__bool=true
					if ss.FNC_Properties==true then
						code..=`\n{string.rep(ss.t,Layer+1)}{ss.NC_InsSetProperty}(self{ss.FuncSeparator}{ConstructorTostring("string","TextureID")}{ss.FuncSeparator}{ConstructorTostring("string",properties.TextureID)})`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{select(2,ConstructorTostring("string","TextureID"))}{ss.FuncSeparator}{select(2,ConstructorTostring("string",properties.TextureID))})`
					else
						code..=`\n{string.rep(ss.t,Layer+1)}self{(ss.Indexing_Instances_By=="Dots" and `.TextureID`) or `[{ConstructorTostring("string","TextureID")}]`}{ss._Equal}{ConstructorTostring("string",properties.TextureID)}`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}{(ss.Indexing_Instances_By=="Dots" and `.{WriteRichText("TextureID",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","TextureID"))}]`}{ss._Equal}{select(2,ConstructorTostring("string",properties.TextureID))}`
					end
				end
			elseif NeedsUnionOperation(ins) then
				--Build Unions
				if ss.FastNamecall==true then
					code..=`\n{string.rep(ss.t,Layer+1)}Destroy(self)`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("Destroy",ScriptMethod)}({WriteRichText("self",ScriptSelf)})`
				else
					code..=`\n{string.rep(ss.t,Layer+1)}self:Destroy()`
					riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("Destroy",ScriptMethod)}()`
				end
				local reg:{[string]:true} = {}
				local reg_ptr:{[Instance]:string} = {}

				local var = WriteUnionConstructor(ins,code,riched_code,Layer+1,reg,reg_ptr)
				local Tags = ins:GetTags()
				local Attributes = ins:GetAttributes()
				local Properties = GetProperties(ins)
				local class = GetTypeOfInstance(ins,nil,(ins.ClassName=="NegateOperation" and "Part") or nil)
				local baseImport:string? = NE__Base(Attributes,Tags,class,GetProperties(ins,true))
				Luau_DoEndWrite(ins,code,riched_code,var,__IsPropertieLessDoEnd(ins,baseImport,Attributes,Tags,Properties),Layer+1,Attributes,Tags,Properties,baseImport,nil,{},{})
				code..=`\n{string.rep(ss.t,Layer+1)}{ss["return"]} {var}`
				riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss["return"],ScriptLuauKeyword)} {var}`
			end
			--closing function
			code..=`\n{string.rep(ss.t,Layer)}end{ss._Separator}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText("end",ScriptLuauKeyword)}{ss._Separator}`
		end
		--_init--
		--IncludeInit?
		local IncludeInit:boolean = (ss._NE_Hierrarchy_TagsAndAttributes=="_init" and (#Tags~=0 or next(Attributes)~=nil)) or (ins.ClassName=="MeshPart" and ss._SaveMeshes==true and (ins::MeshPart).MeshId~="" and ss.MeshPartCreationMode=="Defered")
		if IncludeInit==false and ss._runRecursiveHierarchy==false then
			for i,v in properties do
				if typeof(v)=="Instance" and (v:IsDescendantOf(SelectedInstance::Instance) or v==ins or v==SelectedInstance or (ss.OutsideHierarchyInstances=="SafeIndex" and ((v.Parent~=game and typeof(select(2,pcall(game.FindService,game,(v.Parent::Instance).ClassName))::any|string)~="Instance")))) then IncludeInit=true break end
			end
		end
		--Actual _init here
		--Mainly for inner hierarchy/outer instance indexing with SafeIndex/Initiation of properties like MeshId
		--Note that Instance property could be self
		if IncludeInit then
			HasMacros=true
			code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","_init")}]`) or `_init`}{ss._Equal}function(self{(ss.Typechecking==true and `{ss.TC_Type}{Type}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_init"))}]`) or `_init`}{ss._Equal}{WriteRichText("function",ScriptFunction)}({WriteRichText("self",ScriptSelf)}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(Type,Color3.new(0,1,1))}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}`
			if ss._runRecursiveHierarchy==false then
				NE____RecursiveHierarchy(ins,properties,code,riched_code,Layer)
			end
			if ss._NE_Hierrarchy_TagsAndAttributes=="_init" and (#Tags~=0 or next(Attributes)~=nil) then
				--tags
				NE__TagsAndAttributes(code,riched_code,Layer,Attributes,Tags,baseImport)
			end
			--Meshes
			if (ins.ClassName=="MeshPart" and (ins::MeshPart).MeshId~="" and ss.MeshPartCreationMode=="Defered") then
				--MeshID
				local dictionary,dictionary_rich = GetMeshPropertiesConfigs(ins::MeshPart)
				if ss.FNC_Mesh==true then
					if ss.UseMeshFunction==true then
						code..=`\n{string.rep(ss.t,Layer+1)}ApplyMesh(self{ss.FuncSeparator}{ss._SaveMeshes_FN_Name}({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}))`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("ApplyMesh",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}))`
					else
						code..=`\n{string.rep(ss.t,Layer+1)}{ss._local}{ss.localMeshVariableName}{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}{ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})\n{string.rep(ss.t,Layer+1)}ApplyMesh(self{ss.FuncSeparator}{ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}Destroy({ss.localMeshVariableName})`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}{select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})\n{string.rep(ss.t,Layer+1)}{WriteRichText("ApplyMesh",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}{WriteRichText("Destroy",ScriptMethod)}({ss.localMeshVariableName})`
					end
				else
					if ss.UseMeshFunction==true then
						code..=`\n{string.rep(ss.t,Layer+1)}self:ApplyMesh({ss._SaveMeshes_FN_Name}({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}))`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("ApplyMesh",ScriptMethod)}({WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}))`
					else
						code..=`\n{string.rep(ss.t,Layer+1)}{ss._local}{ss.localMeshVariableName}{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})\n{string.rep(ss.t,Layer+1)}self:ApplyMesh({ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}{ss.localMeshVariableName}:Destroy()`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss._local,ScriptLocal)}{ss.localMeshVariableName}{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("ApplyMesh",ScriptMethod)}({ss.localMeshVariableName})\n{string.rep(ss.t,Layer+1)}{ss.localMeshVariableName}:{WriteRichText("Destroy",ScriptMethod)}()`
					end	
				end
				--TextureID
				if properties.TextureID~=nil then
					properties__bool=true
					if ss.FNC_Properties==true then
						code..=`\n{string.rep(ss.t,Layer+1)}{ss.NC_InsSetProperty}(self{ss.FuncSeparator}{ConstructorTostring("string","TextureID")}{ss.FuncSeparator}{ConstructorTostring("string",properties.TextureID)})`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{select(2,ConstructorTostring("string","TextureID"))}{ss.FuncSeparator}{select(2,ConstructorTostring("string",properties.TextureID))})`
					else
						code..=`\n{string.rep(ss.t,Layer+1)}self{(ss.Indexing_Instances_By=="Dots" and `.TextureID`) or `[{ConstructorTostring("string","TextureID")}]`}{ss._Equal}{ConstructorTostring("string",properties.TextureID)}`
						riched_code..=`\n{string.rep(ss.t,Layer+1)}{WriteRichText("self",ScriptSelf)}{(ss.Indexing_Instances_By=="Dots" and `.{WriteRichText("TextureID",ScriptProperty)}`) or `[{select(2,ConstructorTostring("string","TextureID"))}]`}{ss._Equal}{select(2,ConstructorTostring("string",properties.TextureID))}`
					end
				end
			end
			--
			code..=`\n{string.rep(ss.t,Layer)}end{ss._Separator}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText("end",ScriptLuauKeyword)}{ss._Separator}`
		end

		---_exec---
		if ss._NE_Hierrarchy_TagsAndAttributes=="_exec" and (#Tags~=0 or next(Attributes)~=nil) then
			HasMacros=true
			code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","_exec")}]`) or "_exec"}{ss._Equal}\{`
			riched_code..=`\n{string.rep(ss.t,Layer)}{(ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_exec"))}]`) or "_exec"}{ss._Equal}\{`
			if #Tags~=0 then
				local txt,rich = "",""
				if ss.NE_New_exec==true then
					for i,v in Tags do
						txt..=`{ConstructorTostring("string",v)}{ss._Separator}`;
						rich..=`{select(2,ConstructorTostring("string",v))}{ss._Separator}`
					end
				else
					for i,v in Tags do
						txt..=`\{{ConstructorTostring("string",v)}\}{ss._Separator}`;
						rich..=`\{{select(2,ConstructorTostring("string",v))}\}{ss._Separator}`
					end
				end
				code..=`\n{string.rep(ss.t,Layer+1)}{((ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","AddTag")}]`) or "AddTag")}{ss._Equal}\{{txt}\}{ss._Separator}`
				riched_code..=`\n{string.rep(ss.t,Layer+1)}{((ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","AddTag"))}]`) or "AddTag")}{ss._Equal}\{{rich}\}{ss._Separator}`
			end
			if next(Attributes)~=nil then
				code..=`\n{string.rep(ss.t,Layer+1)}{(ss.NE_PropBrecketsToInit==true and `[{ConstructorTostring("string","SetAttribute")}]`) or "SetAttribute"}{ss._Equal}\{`
				riched_code..=`\n{string.rep(ss.t,Layer+1)}{(ss.NE_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","SetAttribute"))}]`) or "SetAttribute"}{ss._Equal}\{`
				if ss.NE_New_exec==true then
					for i,v in spairs(Attributes) do
						code..=`\n{string.rep(ss.t,Layer+2)}{(ss.NE_New_exec_AttributeBrackets==true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{ConstructorTostring(typeof(v),v)}{ss._Separator}`
						riched_code..=`\n{string.rep(ss.t,Layer+2)}{(ss.NE_New_exec_AttributeBrackets==true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{select(2,ConstructorTostring(typeof(v),v))}{ss._Separator}`
					end
				else
					for i,v in spairs(Attributes) do
						code..=`\n{string.rep(ss.t,Layer+2)}\{{ConstructorTostring("string",i)}{ss._Separator}{ConstructorTostring(typeof(v),v)}\}{ss._Separator}`
						riched_code..=`\n{string.rep(ss.t,Layer+2)}\{{select(2,ConstructorTostring("string",i))}{ss._Separator}{select(2,ConstructorTostring(typeof(v),v))}\}{ss._Separator}`
					end
				end
				code..=`\n{string.rep(ss.t,Layer+1)}\}{ss._Separator}`
				riched_code..=`\n{string.rep(ss.t,Layer+1)}\}{ss._Separator}`
			end
			--Closing _exec
			code..=`\n{string.rep(ss.t,Layer)}\}{ss._Separator}`
			riched_code..=`\n{string.rep(ss.t,Layer)}\}{ss._Separator}`
		end
		-------
		--Children----

		local children__bool:boolean = false
		if #children~=0 then
			local _CountWrapped = table.create(#children)::{Instance}
			local _CountWinners:{[Instance]:number} = {}

			code..=string.rep("\n",ss.SeparateChildren::number)
			riched_code..=string.rep("\n",ss.SeparateChildren::number)
			code..=string.rep(ss.t,Layer)..string.gsub(string.gsub(string.gsub(ss.Separate_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n")
			riched_code..=string.rep(ss.t,Layer)..WriteRichText(string.gsub(string.gsub(string.gsub(ss.Separate_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n"),ScriptComment)

			if ss.NE_ChildrenTable==true then
				code..=`\n{string.rep(ss.t,Layer)}[{ss.NE_ChildrenTable__Name}]{ss._Equal}\{`
				riched_code..=`\n{string.rep(ss.t,Layer)}[{ss.NE_ChildrenTable__Name}]{ss._Equal}\{`
			end
			if ss.CountEnabled==true then
				for i,v in children do
					if table.find(_CountWrapped,v)~=nil then continue end
					_CountWinners[v] = get__count(v,children,_CountWrapped,v:GetAttributes(),v:GetTags())
				end
			end
			for i,v in children do
				if (ss.RespectArchivable==true and v.Archivable==false) or table.find(_CountWrapped,v)~=nil then continue end
				NE_BuildProperties(v,code,riched_code,Layer+1+((ss.NE_ChildrenTable==true and 1) or 0)::number,nil,_CountWinners[v]::number?)
				children__bool=true
			end
			if ss.NE_ChildrenTable==true then
				code..=`\n{string.rep(ss.t,Layer)}\}{ss._Separator}`
				riched_code..=`\n{string.rep(ss.t,Layer)}\}{ss._Separator}`
			end
			code..=string.rep(ss.t,Layer)..string.gsub(string.gsub(string.gsub(ss.SeparatePost_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n")
			riched_code..=string.rep(ss.t,Layer)..WriteRichText(string.gsub(string.gsub(string.gsub(ss.SeparatePost_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n"),ScriptComment)

		end
		-----
		if Initiator~=true then
			--Step out from Type/Name
			if (properties__bool==true or children__bool==true or #Tags~=0 or next(Attributes)~=nil or HasMacros==true) or ss._NE_Prop_Type_Newline==true then
				code..=`\n{string.rep(ss.t,Layer-1)}`
				riched_code..=`\n{string.rep(ss.t,Layer-1)}`
			end
			--Step out from instance constructor and close it
			code..=`\}{(ss.NE_NewArgConstructor==true and ss._NE_FN_BRACKETS==true and ")") or ""}{ss._Separator}`
			riched_code..=`\}{(ss.NE_NewArgConstructor==true and ss._NE_FN_BRACKETS==true and ")") or ""}{ss._Separator}`
		elseif Initiator==true and ((children__bool==false and (properties__bool==true or HasMacros==true)) or #children>0) then
			code..=`\n`
			riched_code..=`\n`
		end
		-----
		--return code,riched_code
	end

	local function Luau_Recursion(ins:Instance,code:CreateStr.class|any,riched_code:CreateStr.class|any,b_Layer:buffer,ClaimedVariableNames:{[string]:true},b_Registers:buffer,DirrectAccessToVarAvalible:{[Instance]:string},SameChildren:number?,Parent:string?,RecursiveHierarchyQueue:{[Instance]:{{Prop:string;Var:string}}}):()
		local Type:string = GetTypeOfInstance(ins)
		if ins:IsA("PartOperation") and NeedsUnionOperation(ins)==false then
			Type="Part"
		end
		local properties = GetProperties(ins,nil,Type)

		local bypass__properties = GetProperties(ins,true)
		local Tags = ins:GetTags()
		local Attributes = ins:GetAttributes()
		local Children = ins:GetChildren()

		local Registers:number = buffer.readu32(b_Registers,0)
		local Layer:number = buffer.readu32(b_Layer,0)

		local baseImport:string? = NE__Base(Attributes,Tags,Type,bypass__properties)

		local varName:string = GetVarName(ins.Name,ClaimedVariableNames)
		local IsPropertieLessDoEnd:boolean = __IsPropertieLessDoEnd(ins,baseImport,Attributes,Tags,properties)

		ClaimedVariableNames[varName]=true
		DirrectAccessToVarAvalible[ins]=varName

		--Registers and closures
		if Registers>=ss.RegisterLimit::number then	
			code..=`{ss.PreJMPClosureSeparator}{(ss.ClosureJMP==true and string.rep(ss.t,Layer)) or ""}{ss.ClosureSeparator}(function(){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
			riched_code..=`{ss.PreJMPClosureSeparator}{(ss.ClosureJMP==true and string.rep(ss.t,Layer)) or ""}{ss.ClosureSeparator}({WriteRichText("function",ScriptFunction)}(){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
			Registers=0
			Layer+=1	
		end


		--MAKE RECURSIVES UNNASESIBLE FOR THIS SORT OF VARIABLES IF ITS A COMPLEX RECURSION/Unable to referance them either
		if SameChildren~=nil then
			code..=`\n{string.rep(ss.t,Layer)}{ss._local}{varName}{(ss.Typechecking==true and `{ss.TC_Type}{Type}`) or ""}\n{string.rep(ss.t,Layer)}{ss["for"]}i{ss._Equal}{ConstructorTostring("number",1)}{ss.TupleSeparator}{ConstructorTostring("number",SameChildren)}{ss["do"]}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varName}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(Type,Color3.new(0,1,1))}`) or ""}{string.rep(ss.t,Layer)}\n{WriteRichText(ss["for"],ScriptLuauKeyword)}i{ss._Equal}{select(2,ConstructorTostring("number",1))}{ss.TupleSeparator}{select(2,ConstructorTostring("number",SameChildren))}{WriteRichText(ss["do"],ScriptLuauKeyword)}`
			Layer+=1
			--if ins.ClassName=="MeshPart" and (ins::MeshPart).MeshId~="" and ss._SaveMeshes==true and ss.MeshPartCreationMode=="Compute" then
			if (not ins:IsA("UnionOperation") and not ins:IsA("IntersectOperation") and not ins:IsA("NegateOperation")) then
				code..=`\n{string.rep(ss.t,Layer)}{varName}`
				riched_code..=`\n{string.rep(ss.t,Layer)}{varName}`
			end
		else
			code..=`\n{string.rep(ss.t,Layer)}{ss._local}{varName}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss._local,ScriptLocal)}{varName}`
		end
		if ins.ClassName == "MeshPart" and (ins::MeshPart).MeshId~="" and ss._SaveMeshes==true and ss.MeshPartCreationMode=="Compute" then
			local dictionary,dictionary_rich = GetMeshPropertiesConfigs(ins::MeshPart)
			if ss.UseMeshFunction==true then
				if ss._SaveMeshes_Cache==true then
					code..=`{ss._Equal}Instance{(ss.IndexingBy=="Dots" and `.fromExisting`) or `[{ConstructorTostring("string","fromExisting")}]`}({ss._SaveMeshes_FN_Name}({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary}))`
					riched_code..=`{ss._Equal}{WriteRichText("Instance",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromExisting",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","fromExisting")}]`}({WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich}))`
				else
					code..=`{ss._Equal}{ss._SaveMeshes_FN_Name}({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})`
					riched_code..=`{ss._Equal}{WriteRichText(ss._SaveMeshes_FN_Name,ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})`
				end
			else
				if ss.FNC_Mesh==true then
					code..=`{ss._Equal}CreateMeshPartAsync({ss.CMPAsyncService}{ss.FuncSeparator}{ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})`
					riched_code..=`{ss._Equal}{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({ss.CMPAsyncService}{ss.FuncSeparator}{select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})`
				else
					code..=`{ss._Equal}{ss.CMPAsyncService}:CreateMeshPartAsync({ConstructorTostring("string",(ins::MeshPart).MeshId)}{dictionary})`
					riched_code..=`{ss._Equal}{ss.CMPAsyncService}:{WriteRichText("CreateMeshPartAsync",ScriptMethod)}({select(2,ConstructorTostring("string",(ins::MeshPart).MeshId))}{dictionary_rich})`
				end
			end
		elseif NeedsUnionOperation(ins) then
			local reg:{[string]:true} = {[varName]=true}
			local reg_ptr:{[Instance]:string} = {}

			if SameChildren~=nil then
				--open
				code..=`{ss.PreJMPClosureSeparator}{(ss.ClosureJMP==true and string.rep(ss.t,Layer)) or ""}(function(){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
				riched_code..=`{ss.PreJMPClosureSeparator}{(ss.ClosureJMP==true and string.rep(ss.t,Layer)) or ""}({WriteRichText("function",ScriptFunction)}(){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
				--assign
				local var = WriteUnionConstructor(ins,code,riched_code,Layer+1,reg,reg_ptr)
				code..=`\n{string.rep(ss.t,Layer+1)}{varName}{ss._Equal}{var}`
				riched_code..=`\n{string.rep(ss.t,Layer+1)}{varName}{ss._Equal}{var}`
				--close
				code..=`\n{string.rep(ss.t,Layer)}{ss["end"]})()`
				riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss["end"],ScriptLuauKeyword)})()`
			else
				code..=`{(ss.Typechecking==true and `{ss.TC_Type}{Type}`) or ""}{ss.PreJMPClosureSeparator}{(ss.ClosureJMP==true and string.rep(ss.t,Layer)) or ""}{ss.ClosureSeparator}(function(){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
				riched_code..=`{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(Type,Color3.new(0,1,1))}`) or ""}{ss.PreJMPClosureSeparator}{(ss.ClosureJMP==true and string.rep(ss.t,Layer)) or ""}{ss.ClosureSeparator}({WriteRichText("function",ScriptFunction)}(){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}{ss["fbend"]}`
				--assign
				local var = WriteUnionConstructor(ins,code,riched_code,Layer+1,reg,reg_ptr)
				code..=`\n{string.rep(ss.t,Layer+1)}{varName}{ss._Equal}{var}`
				riched_code..=`\n{string.rep(ss.t,Layer+1)}{varName}{ss._Equal}{var}`
				--close
				code..=`\n{string.rep(ss.t,Layer)}{ss["end"]})()`
				riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss["end"],ScriptLuauKeyword)})()`
			end
		else
			code..=`{ss._Equal}Instance{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new")}]`}({ConstructorTostring("string",Type)}{(Parent~=nil and IsPropertieLessDoEnd==true and `{ss.FuncSeparator}{Parent}`) or ""})`
			riched_code..=`{ss._Equal}{WriteRichText("Instance",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new"))}]`}({select(2,ConstructorTostring("string",Type))}{(Parent~=nil and IsPropertieLessDoEnd==true and `{ss.FuncSeparator}{Parent}`) or ""})`
		end

		Luau_DoEndWrite(ins,code,riched_code,varName,IsPropertieLessDoEnd,Layer,Attributes,Tags,properties,baseImport,Parent,RecursiveHierarchyQueue,DirrectAccessToVarAvalible)

		--closing for loop
		if SameChildren~=nil then
			Layer-=1
			code..=`\n{string.rep(ss.t,Layer)}{ss["end"]}`
			riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss["end"],ScriptLuauKeyword)}`
		end

		--late recursive hierarchy
		if ss.RL_RecursionWrite=="Instant" and RecursiveHierarchyQueue[ins]~=nil then
			if ss.FNC_Properties==true then
				for i,v in RecursiveHierarchyQueue[ins] do
					local Var,Prop = v.Var,v.Prop
					code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({Var}{ss.FuncSeparator}{ConstructorTostring("string",Prop)}{ss.FuncSeparator}{varName})`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({Var}{ss.FuncSeparator}{select(2,ConstructorTostring("string",Prop))}{ss.FuncSeparator}{varName})`
				end
			else
				for i,v in RecursiveHierarchyQueue[ins] do
					local Var,Prop = v.Var,v.Prop
					code..=`\n{string.rep(ss.t,Layer)}{Var}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",Prop)}]`) or "."..Prop}{ss._Equal}{varName}`
					riched_code..=`\n{string.rep(ss.t,Layer)}{Var}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",Prop))}]`) or "."..WriteRichText(Prop,ScriptProperty)}{ss._Equal}{varName}`
				end	
			end
			RecursiveHierarchyQueue[ins]=nil
		end


		Registers+=1
		buffer.writeu32(b_Registers,0,Registers)
		buffer.writeu32(b_Layer,0,Layer)




		--children
		if #Children~=0 then
			local _CountWrapped = table.create(#Children)::{Instance}
			local _CountWinners:{[Instance]:number} = {}

			code..=string.rep("\n",ss.SeparateChildren::number)
			riched_code..=string.rep("\n",ss.SeparateChildren::number)
			code..=string.rep(ss.t,Layer)..string.gsub(string.gsub(string.gsub(ss.Separate_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n")
			riched_code..=string.rep(ss.t,Layer)..WriteRichText(string.gsub(string.gsub(string.gsub(ss.Separate_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n"),ScriptComment)
			if ss.CountEnabled==true then
				for i,v in Children do
					if table.find(_CountWrapped,v)~=nil then continue end
					local varName:string = string.gsub(v.Name,"[^%w_]","_")
					if string.match(varName,"^%d") then
						varName = `_{varName}`
					end
					if ClaimedVariableNames[varName]==true then
						local Indexator:number = 1
						while ClaimedVariableNames[`{varName}_{Indexator}`]==true do
							Indexator+=1
						end
						varName..=`_{Indexator}`
					end
					_CountWinners[v] = get__count(v,Children,_CountWrapped,v:GetAttributes(),v:GetTags(),DirrectAccessToVarAvalible,varName)
				end
			end
			for i,v in Children do
				if (ss.RespectArchivable==true and v.Archivable==false) or table.find(_CountWrapped,v)~=nil then continue end
				Luau_Recursion(v,code,riched_code,b_Layer,ClaimedVariableNames,b_Registers,DirrectAccessToVarAvalible,_CountWinners[v]::number?,varName,RecursiveHierarchyQueue)
			end
			code..=string.rep(ss.t,Layer)..string.gsub(string.gsub(string.gsub(ss.SeparatePost_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n")
			riched_code..=string.rep(ss.t,Layer)..WriteRichText(string.gsub(string.gsub(string.gsub(ss.SeparatePost_Advanced,"\\\\","\\"),"\\t","\t"),"\\n","\n"),ScriptComment)

		end

	end

	local function Nestify_Convert(ins:Instance):()
		local code:CreateStr.class|any = CreateStr()
		local riched_code:CreateStr.class|any = CreateStr(ss.WriteRichText==false)
		local Type:string = GetTypeOfInstance(ins)
		if Type=="UnionOperation" or Type=="IntersectOperation" then Type=ss._ReplacementInstance end
		IncludeTopCode(code,riched_code,true)
		code..=`{ss._local}{ss._NE_HierrarchyName}{ss._Equal}{ss._HierarchyBuilderFunctionName}{(ss.NE_NewArgConstructor==true and ss.NE_NAC_New_2_Spacing) or ""}{(ss.NE_NewArgConstructor==true and `{(ss._NE_FN_BRACKETS==true and "(") or ""}{ConstructorTostring("string",Type)}{ss.NE_NAC_Spacing}{(ss._NE_FN_BRACKETS==true and ss.FuncSeparator) or ""}`) or ""}{(ss.NE_NewArgConstructor==false and ss._NE_FN_BRACKETS==true and "(") or ""}\{`
		riched_code..=`{WriteRichText(ss._local,ScriptLocal)}{ss._NE_HierrarchyName}{ss._Equal}{WriteRichText(ss._HierarchyBuilderFunctionName,ScriptMethod)}{(ss.NE_NewArgConstructor==true and ss.NE_NAC_New_2_Spacing) or ""}{(ss.NE_NewArgConstructor==true and `{(ss._NE_FN_BRACKETS==true and "(") or ""}{select(2,ConstructorTostring("string",Type))}{ss.NE_NAC_Spacing}{(ss._NE_FN_BRACKETS==true and ss.FuncSeparator) or ""}`) or ""}{(ss.NE_NewArgConstructor==false and ss._NE_FN_BRACKETS==true and "(") or ""}\{`
		NE_BuildProperties(ins,code,riched_code,1,true)
		code..=`\}{(ss._NE_FN_BRACKETS==true and ")") or ""}`
		riched_code..=`\}{(ss._NE_FN_BRACKETS==true and ")") or ""}`
		ShowText(code,riched_code)
	end
	local function RawLuau_Convert(ins:Instance):()
		local code:CreateStr.class|any = CreateStr()
		local riched_code:CreateStr.class|any = CreateStr(ss.WriteRichText==false)
		IncludeTopCode(code,riched_code,true)
		local u_int32_Buff:buffer = buffer.create(4)
		buffer.writeu32(u_int32_Buff,0,ss.StartRegisterCount::number? or 0)
		local b_Layer = buffer.create(4)
		buffer.writeu32(b_Layer,0,0)
		local RecursiveHierarchyQueue:{[Instance]:{{Prop:string;Var:string}}} = {}
		local DirrectAccessToVarAvalible:{[Instance]:string} = {}

		Luau_Recursion(ins,code,riched_code,b_Layer,{},u_int32_Buff,DirrectAccessToVarAvalible,nil,nil,RecursiveHierarchyQueue)
		local Layer:number = buffer.readu32(b_Layer,0)

		--Adding recursive properties that has been set to InTheEnd
		for i,__v in RecursiveHierarchyQueue do
			local varName:string = DirrectAccessToVarAvalible[i]::string? or "____ERROR0xdeadbeef"
			if ss.FNC_Properties==true then
				for i,v in __v do
					local Var,Prop = v.Var,v.Prop
					code..=`\n{string.rep(ss.t,Layer)}{ss.NC_InsSetProperty}({Var}{ss.FuncSeparator}{ConstructorTostring("string",Prop)}{ss.FuncSeparator}{varName})`
					riched_code..=`\n{string.rep(ss.t,Layer)}{WriteRichText(ss.NC_InsSetProperty,ScriptMethod)}({Var}{ss.FuncSeparator}{select(2,ConstructorTostring("string",Prop))}{ss.FuncSeparator}{varName})`
				end
			else
				for i,v in __v do
					local Var,Prop = v.Var,v.Prop
					code..=`\n{string.rep(ss.t,Layer)}{Var}{(ss.Indexing_Instances_By == "Brackets" and `[{ConstructorTostring("string",Prop)}]`) or "."..Prop}{ss._Equal}{varName}`
					riched_code..=`\n{string.rep(ss.t,Layer)}{Var}{(ss.Indexing_Instances_By == "Brackets" and `[{select(2,ConstructorTostring("string",Prop))}]`) or "."..WriteRichText(Prop,ScriptProperty)}{ss._Equal}{varName}`
				end	
			end
		end
		--closing closures
		for i=Layer,1,-1 do
			code..=`\n{string.rep(ss.t,i)}{ss["end"]})()`
			riched_code..=`\n{string.rep(ss.t,i)}{WriteRichText(ss["end"],ScriptLuauKeyword)})()`
		end
		ShowText(code,riched_code)
	end


	local function GrabPropertiesOfSingularInstance(ins:Instance):()
		local code:CreateStr.class|any = CreateStr()
		local riched_code:CreateStr.class|any = CreateStr()
		code..= `{ss["--"]}{ins.ClassName}`
		riched_code..= WriteRichText(`{ss["--"]}{ins.ClassName}`,ScriptComment)
		for i,v in spairs(GetProperties(ins,true)) do
			if typeof(v)=="Instance" then
				local c,r = GoToIndexPath(v)
				code..=`\n{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{c}`
				riched_code..=`\n{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{r}`
				continue
			end
			local c,r = ConstructorTostring(typeof(v),v)
			code..=`\n{(ss.NE_PropBreckets == true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{c}`
			riched_code..=`\n{(ss.NE_PropBreckets == true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{r}`
		end
		ShowText(code,riched_code)
	end
	Code:GetPropertyChangedSignal("TextBounds"):Connect(function():()
		CodeOutput_Scrolling.CanvasSize = UDim2.new(0,Code.TextBounds.X,0,Code.TextBounds.Y)
	end)
	Code.Text = "--Code here"
	Rich.Text = WriteRichText("--Code here",ScriptComment)

	local function __BegginConvert():()
		--Mutate variables
		UpdateSS()
		OnConvert:Fire()
		--Configs init
		Rich.TextSize = ss.CodeOutputTextSize
		Code.TextSize = ss.CodeOutputTextSize
		CodeOutput_Title.TextSize=ss.CodeOutputTextSize
		--
		SelectedInstance = Selection:Get()[1]
		if (SelectedInstance::Instance?)==nil then warn("Please select any instance to convert") return end
		if ss.Instance_PropGrab==true then
			GrabPropertiesOfSingularInstance(SelectedInstance)
		elseif CurrentConvertType=="Nestify" then
			Nestify_Convert(SelectedInstance)
		elseif CurrentConvertType=="Raw Luau" then
			RawLuau_Convert(SelectedInstance)
		else
			error("Something unexpected heppened somehow, This tab converter does not exist")
		end
		SelectButtonByName("Converted Code")
	end
	local function ErrPrintFunc(...:any):()
		local msg:string = ...
		if string.find(msg::string,"bounds")~=nil then
			warn("Please increase \"Buffer Size\" property inside Shared Settings")
		else
			warn(...)
			TestService:Message(debug.traceback(coroutine.running()),script)
		end
	end

	local function BegginConvert():()
		xpcall(__BegginConvert,ErrPrintFunc)
	end


	do
		--Connecting convert stuff
		local ConvertKeybind = plugin:CreatePluginAction("NE_Convert","Convert","Convert","rbxassetid://98396137856895",true)
		ConvertKeybind.Name = "Convert"
		LowerBar_Convert.MouseButton1Click:Connect(BegginConvert)
		ConvertKeybind.Triggered:Connect(BegginConvert)
	end



end)()
ThemeChanged()
SelectButtonByName(ss.___CurrentTab::string? or "Nestify")








