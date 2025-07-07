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

--!optimize 2
plugin.Name="Hierarchy Saver (plugin)"
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Selection = game:GetService("Selection")
local SelectedInstance:Instance? = nil
local Heartbeat = RunService.Heartbeat
local Types = require(script:WaitForChild("Types"))

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
local Data:Types.API_Dump? = nil
local Classes:Types.FormattedClasses = {}
local WaitForData = coroutine.running()

local LasestCache:number = tonumber(plugin:GetSetting("HierarchySaver_LatestCache_Valid")) or 0
local GET_SAVE:string? = plugin:GetSetting("HierarchySaver_CLASSES")

local function SuccessResult(ret:string):()
	Data = HttpService:JSONDecode(ret)::Types.API_Dump
	local raw_Classes:Types.AllRobloxClasses = (Data :: Types.API_Dump).Classes
	local Enums:Types.AllRobloxEnums = (Data :: Types.API_Dump).Enums
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
				if vv.Tags~=nil and (table.find(vv.Tags,"ReadOnly")~=nil or table.find(vv.Tags,"NotScriptable")~=nil or table.find(vv.Tags,"Deprecated")~=nil or table.find(vv.Tags,"PluginSecurity")~=nil or table.find(vv.Tags,"Hidden")~=nil or table.find(vv.Tags,"Not Replicated")~=nil) then continue end
				tab[vv.Name]=(vv.ValueType.Category=="Class" and "Instance") or (vv.ValueType.Category=="Enum" and `Enum.{vv.ValueType.Name}`) or (TranslateProperties[vv.ValueType.Name] or vv.ValueType.Name)
			end
			Superclass=raw_Classes[search].Superclass
		end
		Classes[v.Name]=tab
	end
	plugin:SetSetting("HierarchySaver_CLASSES",HttpService:JSONEncode(Classes))
	plugin:SetSetting("HierarchySaver_LatestCache_Valid",workspace:GetServerTimeNow()+60*60*24)
	if WaitForData then coroutine.resume(WaitForData) end
end
--*********************Assembling widget
local Toolbar = plugin:CreateToolbar("Hierarchy Saver")
local Button = Toolbar:CreateButton("Open Hierarchy UI","Open UI","rbxassetid://75358548882112","Open UI")
Button.ClickableWhenViewportHidden=true
local Widget:DockWidgetPluginGui = plugin:CreateDockWidgetPluginGui("Hierarchy Saver ID",DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	400,800,100,200
	))
Widget.Name="Hierarchy Saver"
Widget.Title="Hierarchy Saver"
--Elements
local Elements = script:WaitForChild("Components")
local TabButton = Elements:WaitForChild("TabButton")--Button to open tab
local TabNameHere = Elements:WaitForChild("TabNameHere")--Tab itself
local ErrorHTTP_UI = Elements:WaitForChild("ErrorHTTP_UI")
local LightThemeColor_List:{Frame} = table.create(3)::{Frame}
local Tab_EnumColor_List:{Frame} = table.create(1)::{Frame}
local ScriptWhitespaceColorList_FOR_UI_STROKE:{UIStroke} = table.create(3)::{UIStroke}
local TextButtons_Theme:{TextLabel|TextBox|TextButton} = table.create(20)::{TextLabel|TextBox|TextButton}
local BrightestText_Theme:{TextLabel|TextBox|TextButton|ImageLabel|ImageButton} = table.create(10)::{TextLabel|TextBox|TextButton}
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
local Parser =require(script:WaitForChild("Parser"))

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
local function SetProperty(obj:any,property:string,value:any):()
	obj[property]=value
end
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
local CurrentConvertType:string = "Hierarchy Builder"
local function SelectButtonByName(name:string):()
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
	if name~="Converted Code" and name~="Shared Settings" then CurrentConvertType = name end
end
local OnConvert:BindableEvent = Instance.new("BindableEvent")
local UncollapseCategoryies:BindableEvent = Instance.new("BindableEvent")
local AllPropertyRelatives:{[TextLabel]:GuiObject} = {}--TextLabel.Text -> Target
do
	local SearchKeybind = plugin:CreatePluginAction("HB_StartSearch","Search","Search for property","rbxassetid://75358548882112",true)
	SearchKeybind.Name = "Search for property"
	local CancelKeybind = plugin:CreatePluginAction("HB_CancelSearch","Cancel Search","Cancel Search for property","rbxassetid://75358548882112",true)
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
				Tab_Scroll.CanvasPosition-=Vector2.new(Tab_Scroll.CanvasPosition.X,0)
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
				Tab_Scroll.CanvasPosition-=Vector2.new(Tab_Scroll.CanvasPosition.X,0)
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

--*********************Obtaining classes
if LasestCache>workspace:GetServerTimeNow() and type(GET_SAVE)=="string" then
	Classes = HttpService:JSONDecode(GET_SAVE)::Types.FormattedClasses
	if WaitForData then coroutine.resume(WaitForData) end
else
	local success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
	if success then
		SuccessResult(ret)
	else
		-- No perms but has a backup
		if type(GET_SAVE)=="string" then
			Classes = HttpService:JSONDecode(GET_SAVE)::Types.FormattedClasses
			warn(`Unable to send HTTP request; Using latest backup`)
		else
			--No perms and no backup
			local ErrorTab,Content = CreateTab("Can't Access HTTP request","http://www.roblox.com/asset/?id=77195333607477")
			local Data_UI = ErrorHTTP_UI:WaitForChild("Data")
			local Effect = Data_UI:WaitForChild("Effect")
			local Button_Try = Effect:WaitForChild("TextButton")
			local Info = TweenInfo.new(0.25,Enum.EasingStyle.Bounce)
			local Enter = TweenService:Create(Button_Try,Info,{Position=UDim2.new(0.5,0,0.5,0)})
			local Leave = TweenService:Create(Button_Try,Info,{Position=UDim2.new(0.5,0,0.4,0)})
			Button_Try.MouseEnter:Connect(function():()
				Enter:Play()
			end)
			Button_Try.MouseLeave:Connect(function():()
				Leave:Play()
			end)
			local button_DB:boolean = false
			Button_Try.MouseButton1Click:Connect(function():()
				if button_DB==true then return end
				button_DB=true
				local success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
				if success then
					Enter:Destroy()
					Leave:Destroy()
					Button_Try:Destroy()
					SuccessResult(ret)
					DeleteTab(ErrorTab.Name)
					coroutine.resume(WaitForData)
				else
					warn(`No access to HTTP requests: {ret}`)
				end
				button_DB=false
			end)
			ErrorHTTP_UI.Parent=Content
			ErrorHTTP_UI.Visible=true
			ErrorTab.Visible=true
			warn(`No access to HTTP requests: {ret}`)
			for i,v in ViewTabs:GetChildren()::{Frame} do
				if v.Visible==true then
					local Button = UpperBar:FindFirstChild(v.Name)
					if Button==nil then continue end
					Button:SetAttribute("Enabled",true)
				end
			end
		end
	end
end

--********************* Assembling widget UI
Main.Parent=Widget
Button.Click:Connect(function()
	Widget.Enabled = not Widget.Enabled
end)

--********************* AFTER RECIVING CLASSES --[[
if next(Classes)==nil and Data==nil then
	--waiting for data
	coroutine.yield()
end
LowerBar.Visible=true
if ErrorHTTP_UI then ErrorHTTP_UI:Destroy() end
--Typecheker plz shut up
if Classes==nil and Data==nil then return end
--Thanks typecheker for shutting up
--]]
type cache_prop = {[string]:any}
local Default_Properties_Cache:{[string]:cache_prop} = {}
--[[
Returns all non default properties of an Instance
]]
local function GetProperties(instance:any):cache_prop
	local ClassName:string = instance.ClassName
	if Classes[ClassName]==nil then return {} end
	if Default_Properties_Cache[ClassName]==nil then
		local cache_prop:cache_prop = {}
		local ins:any = Instance.new(ClassName)
		for i,v in Classes[ClassName] do
			cache_prop[i]=ins[i]
		end
		ins:Destroy()
		Default_Properties_Cache[ClassName]=cache_prop
	end
	local cache_prop:cache_prop = Default_Properties_Cache[ClassName] 
	local prop = {}
	for i,v in Classes[ClassName] do
		if instance[i]==cache_prop[i] or i=="ClassName" or i=="className" or i=="Parent" then continue end
		prop[i]=instance[i]
	end
	return prop
end

local SessionData = require(script:WaitForChild("SessionData"))

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

local _ss_module = require(script:WaitForChild("ss"))
local ss,UpdateSS = _ss_module.ss,_ss_module.Update



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
				SelectedValue=value
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
do
	local _try,ret = pcall(Parser,plugin:GetSetting("HB_cachedConstants") or "{}")
	if _try and type(ret)=="table" then
		CachedConstants=ret
	else
		CachedConstants = {}
	end
end


local escape:{[string]:string} = {
	['&'] = '&amp;',
	['<'] = '&lt;',
	['>'] = '&gt;',
	['"'] = '&quot;',
	['\''] = '&apos;',
}
local function WriteRichText(str:string,color:Color3):string
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
--[[Number you want to round]]
local function Round(x:number):number
	if ss.Rounding==false then return x end
	local Precision:number = 10^ss.Precision
	return math.round(x*Precision)/Precision
end
local function ToMatrixUnit(x:number):(string,string)
	local deg:number = math.round(math.deg(x)*1000)/1000
	x = math.rad(deg)

	if ss.MatrixCFrameMeasurements=="Degrees" then
		return `math{(ss.IndexingBy=="Dots" and ".rad") or "[\"rad\"]"}({deg})`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("rad",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","rad"))}]`}({select(2,ConstructorTostring("number",deg))})`
	elseif ss.MatrixCFrameMeasurements=="Raw" or x==0 or x==math.pi then
		if x==math.pi then return `math{(ss.IndexingBy=="Dots" and ".pi") or "[\"pi\"]"}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","pi")}]`}` end
		return tostring(x),select(2,ConstructorTostring("number",x))
	elseif ss.MatrixCFrameMeasurements=="Balance" then
		local mul = x/math.pi
		if #tostring(mul%1)<7 then return `math{(ss.IndexingBy=="Dots" and ".pi") or "[\"pi\"]"}{ss.Mult}{mul}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","pi")}]`}{ss.Mult}{select(2,ConstructorTostring("number",mul))}` end

		local sub = math.pi/x
		if #tostring(sub%1)<7 then 
			return `math{(ss.IndexingBy=="Dots" and ".pi") or "[\"pi\"]"}{ss.Div}{sub}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","pi")}]`}{ss.Div}{select(2,ConstructorTostring("number",sub))}` 
		else
			return `math{(ss.IndexingBy=="Dots" and ".rad") or "[\"rad\"]"}({deg})`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("rad",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","rad"))}]`}({select(2,ConstructorTostring("number",deg))})`
		end
	else--Radians
		local mul = x/math.pi
		if #tostring(mul%1)<7 then return `math{(ss.IndexingBy=="Dots" and ".pi") or "[\"pi\"]"}{ss.Mult}{mul}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","pi")}]`}{ss.Mult}{select(2,ConstructorTostring("number",mul))}` end

		local sub = math.pi/x
		if #tostring(sub%1)<7 then 
			return `math{(ss.IndexingBy=="Dots" and ".pi") or "[\"pi\"]"}{ss.Div}{sub}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","pi")}]`}{ss.Div}{select(2,ConstructorTostring("number",sub))}` 
		else
			return `math{(ss.IndexingBy=="Dots" and ".pi") or "[\"pi\"]"}{ss.Mult}{mul}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{ConstructorTostring("string","pi")}]`}{ss.Mult}{select(2,ConstructorTostring("number",mul))}`
		end
	end
end
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
		if ss.NanConstant==true and data~=data then
			return ss.NanConstant_Name,ss.NanConstant_Name
		elseif data==math.pi then
			return `math{(ss.IndexingBy=="Dots" and ".pi") or `["pi"]`}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("pi",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","pi",Bypass))}]`}`
		elseif data==math.huge then
			return `math{(ss.IndexingBy=="Dots" and ".huge") or `["huge"]`}`,`{WriteRichText("math",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("huge",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","huge",Bypass))}]`}`
		elseif data~=data then
			return `0{ss.Div}0`,`{select(2,ConstructorTostring("number",0,Bypass))}{ss.Div}{select(2,ConstructorTostring("number",0,Bypass))}`
		end
		--Numbers
		data = math.round(data*1_000_000)/1_000_000
		return tostring(data),WriteRichText(tostring(data),ScriptNumber)
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
			return `Vector2{(ss.IndexingBy=="Dots" and ".one") or `["one"]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("one",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","one"))}]`}`
		elseif data==Vector2.zero then
			return `Vector2{(ss.IndexingBy=="Dots" and ".zero") or `["zero"]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("zero",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","zero"))}]`}`
		elseif data==Vector2.xAxis then
			return `Vector2{(ss.IndexingBy=="Dots" and ".xAxis") or `["xAxis"]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("xAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","xAxis"))}]`}`
		elseif data==Vector2.yAxis then
			return `Vector2{(ss.IndexingBy=="Dots" and ".yAxis") or `["yAxis"]`}`,`{WriteRichText("Vector2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("yAxis",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","yAxis"))}]`}`
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
				return `CFrame{(ss.IndexingBy=="Dots" and `.fromEulerAnglesYXZ`) or `[{ConstructorTostring("string","fromEulerAnglesYXZ",Bypass)}]`}({ConstructorTostring("number",rX,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",rY,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",rZ,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("fromEulerAnglesYXZ",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","fromEulerAnglesYXZ",Bypass))}]`}({select(2,ConstructorTostring("number",rX_rich,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",rY_rich,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",rZ_rich,Bypass))})`
			elseif ss.CFrameFormatting=="CFrameNewPlusAngles" then
				x,y,z = data:ToEulerAnglesXYZ()
				local rX,rX_rich = ToMatrixUnit(x)
				local rY,rY_rich = ToMatrixUnit(y)
				local rZ,rZ_rich = ToMatrixUnit(z)
				return `CFrame{(ss.IndexingBy=="Dots" and `.Angles`) or `[{ConstructorTostring("string","Angles",Bypass)}]`}({ConstructorTostring("number",rX,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",rY,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",rZ,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("Angles",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","Angles",Bypass))}]`}({select(2,ConstructorTostring("number",rX_rich,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",rY_rich,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",rZ_rich,Bypass))})`
			else--RawCFrameNew
				local X,Y,Z,R00,R01,R02,R10,R11,R12,R20,R21,R22 = data:GetComponents()
				X,Y,Z = Round(X),Round(Y),Round(Z)
				return `CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R00,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R01,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R02,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R10,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R11,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R12,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R20,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R21,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",R22,Bypass)})`,`{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R00,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R01,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R02,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R10,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R11,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R12,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R20,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R21,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",R22,Bypass))})`
			end
		else--Has rotation and position
			if ss.CFrameFormatting=="CFrameNewYXZRotation" or ss.CFrameFormatting=="CFrameNewPlusAngles" then
				local X,Y,Z = Round(data.X),Round(data.Y),Round(data.Z)
				local txt,rich = ConstructorTostring("CFrame",data.Rotation)
				return `{(ss.FastNamecall==true and `{ss.NC_CfrMul}(`) or ""}CFrame{(ss.IndexingBy=="Dots" and ".new") or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",X,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Y,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",Z,Bypass)}){(ss.FastNamecall==true and ss.FuncSeparator) or ss.Mult}{txt}{(ss.FastNamecall==true and `){(ss.Typechecking==true and `{ss.TC_Casting}CFrame`) or ""}`) or ""}`,`{(ss.FastNamecall==true and `{WriteRichText(ss.NC_CfrMul,ScriptMethod)}(`) or ""}{WriteRichText("CFrame",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",X,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Y,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",Z,Bypass))}){(ss.FastNamecall==true and ss.FuncSeparator) or ss.Mult}{rich}{(ss.FastNamecall==true and `){(ss.Typechecking==true and `{ss.TC_Casting}{WriteRichText("CFrame",Color3.new(0,1,1))}`) or ""}`) or ""}`
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
		return `UDim2{(ss.IndexingBy=="Dots" and `.new`) or `[{ConstructorTostring("string","new",Bypass)}]`}({ConstructorTostring("number",data.X.Scale,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.X.Offset,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Y.Scale,Bypass)}{ss.FuncSeparator}{ConstructorTostring("number",data.Y.Offset,Bypass)})`,`{WriteRichText("UDim2",ScriptBuiltInFunction)}{(ss.IndexingBy=="Dots" and `.{WriteRichText("new",ScriptBuiltInFunction)}`) or `[{select(2,ConstructorTostring("string","new",Bypass))}]`}({select(2,ConstructorTostring("number",data.X.Scale,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.X.Offset,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y.Scale,Bypass))}{ss.FuncSeparator}{select(2,ConstructorTostring("number",data.Y.Offset,Bypass))})`
	end;
	string = function(data:string):(string,string)
		--Its for a joke mainly idk why i added that
		if ss.HexademicalString==true then
			local ret:string = ""
			for char in string.gmatch(data, ".") do
				ret ..= `\\x{string.format("%x", utf8.codepoint(char))}`
			end
			return `"{ret}"`,WriteRichText(`"{ret}"`,ScriptString)
		end
		-------------------------------------
		data=data:gsub("\\","\\\\"):gsub("\n","\\n"):gsub("\t","\\t"):gsub("\r","\\r"):gsub("\"","\\\""):gsub("\b","\\b"):gsub("\v","\\v"):gsub("\f","\\f"):gsub("\"",`\"`)
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
	local function TableTostring(tbl:{[any]:any},Bypass:true?,Level:number?):(string,string)
		local Level = (Level or 1)::number
		local tbl_txt,tbl_rich = "{\n","{\n"
		for i,v in tbl do
			if type(i)~="number" then
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

	ConstructorTostring_Switch.table=function(tbl:{[any]:any},Bypass:true?):(string,string)
		return TableTostring(tbl,Bypass)
	end
end
local pathMacro:{[Instance]:string}
do
	local _try,ret = pcall(Parser,plugin:GetSetting("HB_pathMacro") or "{}")
	if _try and type(ret)=="table" then
		pathMacro=ret
	else
		pathMacro = {}
	end

end

local IgnoredPropertiesList:{[any]:any}
do
	local _try,ret = pcall(Parser,plugin:GetSetting("HB_IgnoreProperties") or [[{["BasePart"]={"BrickColor";"Position";"Rotation";}]])
	if _try and type(ret)=="table" then
		IgnoredPropertiesList = ret
	else
		IgnoredPropertiesList={["BasePart"]={"BrickColor";"Position";"Rotation";}}
	end
end

do
	local IgnoredProperties_Button_Frame = LowerBar:WaitForChild("Ignored_Properties")
	local Frame1 = IgnoredProperties_Button_Frame:WaitForChild("Frame1")
	local Frame2 = IgnoredProperties_Button_Frame:WaitForChild("Frame2")
	local Button = IgnoredProperties_Button_Frame:WaitForChild("Button")
	local Exit = Ignored_Properies:WaitForChild("Exit")
	local EFrame,EFrame1,EFrame2 = Exit:WaitForChild("Frame"),Exit:WaitForChild("Frame1"),Exit:WaitForChild("Frame2")
	local Import = Ignored_Properies:WaitForChild("Import")
	local IFrame,IFrame1,IFrame2 = Import:WaitForChild("Frame"),Import:WaitForChild("Frame1"),Import:WaitForChild("Frame2")
	local ContentScroll = Ignored_Properies:WaitForChild("Content")
	local Input_txt = ContentScroll:WaitForChild("TextBox")
	local Input_Rich = Input_txt:WaitForChild("Rich")
	local function AdjustCanvas():()
		local sz:Vector2 = TextService:GetTextSize(Input_txt.Text,Input_txt.TextSize,Input_txt.Font,Vector2.new(math.huge,math.huge))
		ContentScroll.CanvasSize=UDim2.new(0,sz.X,0,sz.Y)
	end
	local function AdjustTextSize():()
		Input_txt.TextSize=ss.CodeOutputTextSize
		Input_Rich.TextSize=ss.CodeOutputTextSize
	end
	Input_txt:GetPropertyChangedSignal("Text"):Connect(AdjustCanvas)
	Input_txt.Focused:Connect(function()
		Input_Rich.Visible = false
		Input_txt.TextTransparency=0
	end)
	Input_txt.FocusLost:Connect(function()
		Input_Rich.Visible = true
		Input_txt.TextTransparency=0.99
	end)
	OnConvert.Event:Connect(AdjustTextSize)
	task.defer(AdjustCanvas)
	task.defer(AdjustTextSize)
	table.insert(BrightestText_Theme,Import)
	table.insert(BrightestText_Theme,Exit)
	table.insert(BrightestText_Theme,Button)
	table.insert(ScriptTextColor_List,Input_txt)
	table.insert(ScriptTextColor_List,Input_Rich)
	table.insert(LightThemeColor_List,Ignored_Properies)
	ContentScroll:SetAttribute("Enabled",true)
	table.insert(Properties_ItemColor,ContentScroll)
	local Import_IsHower:boolean = false
	local Exit_IsHower:boolean = false
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
		local tab,tab_rich = ConstructorTostring("table",tbl,true)
		Input_txt.Text=tab
		Input_Rich.Text=tab_rich
		if str~=nil then
			IgnoredPropertiesList=tbl
			plugin:SetSetting("HB_IgnoreProperties",str)
		end
	end

	ApplyTable(IgnoredPropertiesList)
	Import.MouseButton1Click:Connect(function():()
		--Parse table
		local txt:string = Input_txt.Text
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
	end)
end
local _baseImports:{[string]:{string:any}}
do
	local _try,ret = pcall(Parser,plugin:GetSetting("HB_BaseImports") or "{}")
	if _try and type(ret)=="table" then
		_baseImports=ret
	else
		_baseImports = {}
	end
end

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
		local _constants = Import_Constants:WaitForChild("Constants")
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
		local Insert_Scroll = _constants:WaitForChild("Insert_Scroll")
		local Insert = Insert_Scroll:WaitForChild("Insert")
		local Imported_Scroll = _constants:WaitForChild("Imported_Scroll")
		local Imported = Imported_Scroll:WaitForChild("Imported")
		local Rich = Imported:WaitForChild("Rich")
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
		local function AdjustTextSize():()
			Imported.TextSize=ss.CodeOutputTextSize
			Rich.TextSize=ss.CodeOutputTextSize
			Insert.TextSize=ss.CodeOutputTextSize
		end
		OnConvert.Event:Connect(AdjustTextSize)
		task.defer(AdjustTextSize)
		--table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptTextColor_List,Rich)
		table.insert(ScriptTextColor_List,Imported)
		table.insert(ScriptTextColor_List,Insert)
		--strokes
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Imported_Scroll:WaitForChild("UIStroke")::UIStroke)
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Insert_Scroll:WaitForChild("UIStroke")::UIStroke)
		----||-----------------------------------------------||----
		Insert:GetPropertyChangedSignal("Text"):Connect(function():()
			local Size:Vector2 = TextService:GetTextSize(Insert.Text,Insert.TextSize,Insert.Font,Vector2.new(math.huge,math.huge))
			Insert_Scroll.CanvasSize = UDim2.new(0,Size.X,0,Size.Y)
		end)
		Insert_Scroll.CanvasSize = UDim2_zero
		local function ScaleImported():()
			local Size:Vector2 = TextService:GetTextSize(Imported.Text,Imported.TextSize,Imported.Font,Vector2.new(math.huge,math.huge))
			Imported_Scroll.CanvasSize = UDim2.new(0,Size.X,0,Size.Y)
		end
		Imported:GetPropertyChangedSignal("Text"):Connect(ScaleImported)
		task.defer(ScaleImported)

		Import_box.MouseButton1Click:Connect(function():()
			--Parse
			local Insert_txt:string = Insert.Text
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
				local tbl,rich_tbl = ConstructorTostring("table",parsed,true)
				Imported.Text = tbl
				Rich.Text = rich_tbl
				plugin:SetSetting("HB_cachedConstants",Insert_txt)
			elseif try then
				warn(`Type has to be table: \{\n\tValue{ss._Equal}string\n\}`)
			else
				warn(parsed)
			end
		end)
		local tbl,rich_tbl = ConstructorTostring("table",CachedConstants,true)
		Imported.Text = tbl
		Rich.Text = rich_tbl


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
		local _pathMacro = Import_Macro:WaitForChild("PathMacro")
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
		local Insert_Scroll = _pathMacro:WaitForChild("Insert_Scroll")
		local Insert = Insert_Scroll:WaitForChild("Insert")
		local Imported_Scroll = _pathMacro:WaitForChild("Imported_Scroll")
		local Imported = Imported_Scroll:WaitForChild("Imported")
		local Rich = Imported:WaitForChild("Rich")
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
		local function AdjustTextSize():()
			Imported.TextSize=ss.CodeOutputTextSize
			Rich.TextSize=ss.CodeOutputTextSize
			Insert.TextSize=ss.CodeOutputTextSize
		end
		OnConvert.Event:Connect(AdjustTextSize)
		task.defer(AdjustTextSize)
		--table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptTextColor_List,Rich)
		table.insert(ScriptTextColor_List,Imported)
		table.insert(ScriptTextColor_List,Insert)
		--strokes
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Imported_Scroll:WaitForChild("UIStroke")::UIStroke)
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Insert_Scroll:WaitForChild("UIStroke")::UIStroke)
		----||-----------------------------------------------||----
		Insert:GetPropertyChangedSignal("Text"):Connect(function():()
			local Size:Vector2 = TextService:GetTextSize(Insert.Text,Insert.TextSize,Insert.Font,Vector2.new(math.huge,math.huge))
			Insert_Scroll.CanvasSize = UDim2.new(0,Size.X,0,Size.Y)
		end)
		Insert_Scroll.CanvasSize = UDim2_zero
		local function ScaleImported():()
			local Size:Vector2 = TextService:GetTextSize(Imported.Text,Imported.TextSize,Imported.Font,Vector2.new(math.huge,math.huge))
			Imported_Scroll.CanvasSize = UDim2.new(0,Size.X,0,Size.Y)
		end
		Imported:GetPropertyChangedSignal("Text"):Connect(ScaleImported)
		task.defer(ScaleImported)

		Import_box.MouseButton1Click:Connect(function():()
			--Parse
			local Insert_txt:string = Insert.Text
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
				local tbl,rich_tbl = ConstructorTostring("table",parsed,true)
				Imported.Text = tbl
				Rich.Text = rich_tbl
				plugin:SetSetting("HB_pathMacro",Insert_txt)
			elseif try then
				warn(`Type has to be table: \{\n\tPath.To.Instance{ss._Equal}string\n\}`)
			else
				warn(parsed)
			end
		end)
		local tbl,rich_tbl = ConstructorTostring("table",pathMacro,true)
		Imported.Text = tbl
		Rich.Text = rich_tbl


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
		local Import_box = _base:WaitForChild("Import")
		local Import_Label = Import_box:WaitForChild("Label")
		local Insert_Scroll = _base:WaitForChild("Insert_Scroll")
		local Insert = Insert_Scroll:WaitForChild("Insert")
		local Imported_Scroll = _base:WaitForChild("Imported_Scroll")
		local Imported = Imported_Scroll:WaitForChild("Imported")
		local Rich = Imported:WaitForChild("Rich")
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
			Imported.TextSize=ss.CodeOutputTextSize
			Rich.TextSize=ss.CodeOutputTextSize
			Insert.TextSize=ss.CodeOutputTextSize
		end
		OnConvert.Event:Connect(AdjustTextSize)
		task.defer(AdjustTextSize)
		--table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptBackground_List,Insert_Scroll)
		table.insert(ScriptTextColor_List,Rich)
		table.insert(ScriptTextColor_List,Imported)
		table.insert(ScriptTextColor_List,Insert)
		--strokes
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Imported_Scroll:WaitForChild("UIStroke")::UIStroke)
		table.insert(ScriptWhitespaceColorList_FOR_UI_STROKE,Insert_Scroll:WaitForChild("UIStroke")::UIStroke)
		----||-----------------------------------------------||----
		Insert:GetPropertyChangedSignal("Text"):Connect(function():()
			local Size:Vector2 = TextService:GetTextSize(Insert.Text,Insert.TextSize,Insert.Font,Vector2.new(math.huge,math.huge))
			Insert_Scroll.CanvasSize = UDim2.new(0,Size.X,0,Size.Y)
		end)
		Insert_Scroll.CanvasSize = UDim2_zero
		local function ScaleImported():()
			local Size:Vector2 = TextService:GetTextSize(Imported.Text,Imported.TextSize,Imported.Font,Vector2.new(math.huge,math.huge))
			Imported_Scroll.CanvasSize = UDim2.new(0,Size.X,0,Size.Y)
		end
		Imported:GetPropertyChangedSignal("Text"):Connect(ScaleImported)
		task.defer(ScaleImported)

		Import_box.MouseButton1Click:Connect(function():()
			--Parse
			local Insert_txt:string = Insert.Text
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
				local tbl,rich_tbl = ConstructorTostring("table",parsed,true)
				Imported.Text = tbl
				Rich.Text = rich_tbl
				plugin:SetSetting("HB_BaseImports",Insert_txt)
			elseif try then
				warn(`Type has to be table: \{\n\t_BaseName{ss._Equal}\{\}\n\}`)
			else
				warn(parsed)
			end
		end)
		local tbl,rich_tbl = ConstructorTostring("table",_baseImports,true)
		Imported.Text = tbl
		Rich.Text = rich_tbl

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
	local Hierarchy_Builder,Hierarchy_Builder_Content = CreateTab("Hierarchy Builder","rbxassetid://72069099688057")
	local Raw_Luau,Raw_Luau_Content = CreateTab("Raw Luau","rbxassetid://18606791059")
	Hierarchy_Builder.Visible=true
	BuildPropertiesList(sharedSettings_Content,require(script:WaitForChild("SharedSettings")))
	BuildPropertiesList(Hierarchy_Builder_Content,require(script:WaitForChild("Properties_HierarchyBuilder")))
	BuildPropertiesList(Raw_Luau_Content,require(script:WaitForChild("Properties_RawLuau")))
end
local Converted_Code,Converted_Code_Content = CreateTab("Converted Code","rbxassetid://46342657")
do
	local EvilScroll = Converted_Code_Content.Parent::ScrollingFrame
	EvilScroll:Destroy()
end
--game.Selection:Set{Hierarchy_Builder_Content}
local CodeOutput_Title = CodeOutput:WaitForChild("TextLabel")::TextLabel	
local CodeOutput_Scrolling = CodeOutput:WaitForChild("ScrollingFrame")
local Code = CodeOutput_Scrolling:WaitForChild("Code")::TextBox
local Rich = CodeOutput_Scrolling:WaitForChild("Rich")::TextLabel
CodeOutput_Title.TextSize=ss.CodeOutputTextSize
Rich.TextSize = ss.CodeOutputTextSize
Code.TextSize = ss.CodeOutputTextSize
CodeOutput_Title.Text="--CTRL+A and then CTRL+C code below:"
table.insert(ScriptBackground_List,CodeOutput)
table.insert(ScriptTextColor_List,Rich)
table.insert(ScriptTextColor_List,Code)
table.insert(ScriptComment_List,CodeOutput_Title)
table.insert(ScrollingFramesScrollBar,CodeOutput_Scrolling)
CodeOutput.Visible=true
CodeOutput.Parent=Converted_Code

warn("YAY",Classes,Data)
for i,v in ViewTabs:GetChildren()::{Frame} do
	if v.Visible==true then
		local Button = UpperBar:FindFirstChild(v.Name)
		if Button==nil then continue end
		Button:SetAttribute("Enabled",true)
	end
end
ThemeChanged()

local function GetTypeOfInstance(ins:Instance):string
	return (Classes[ins.ClassName]~=nil and ins.ClassName) or ss._ReplacementInstance
end

local GoToIndexPath:(ins:Instance,Recursive:Instance?,RecursionStartKeyword:string?,RSK_rich:string?,Layer:number?)->(string,string)
do
	local function ___IsAProperty(ins:any,prop:string):any
		return ins[prop]
	end
	local function IsAProperty(ins:any|Instance,prop:string):boolean
		local try,res = pcall(___IsAProperty,ins,prop)
		return (try and ins:FindFirstChild(prop) ~= res) or ins:IsA("ObjectValue")
	end
	GoToIndexPath = function(ins:Instance,Recursive:Instance?,RecursionStartKeyword:string?,RSK_rich:string?,Layer:number?):(string,string)
		RSK_rich = (RSK_rich~=nil and RSK_rich) or RecursionStartKeyword
		local IsRecursive:boolean = (Recursive~=nil and (Recursive:IsDescendantOf(SelectedInstance::Instance) or ins==Recursive or SelectedInstance==Recursive)) or false
		local txt,rich = "",""
		if IsRecursive==true and RecursionStartKeyword~=nil then
			txt,rich = RecursionStartKeyword,RSK_rich
		end
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
			while path~=nil do
				table.insert(Hierarchy,1,path)
				if type(select(2,pcall(game.FindService,game,path.ClassName)))=="userdata" or pathMacro[path]~=nil then
					break
				end
				--Move up
				path=path.Parent::Instance
			end
		elseif Recursive~=nil then --Recursive
			while path~=Recursive and path~=nil do
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
			for i,v in Hierarchy do
				if v:IsAncestorOf(ins) then
					--Down
					if ss.FastNamecall==true then
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
					if ss.FastNamecall==true then
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
			return txt,rich
		elseif Recursive~=nil then--Safe index
			Layer=Layer or 1
			local InstanceIndex:number = 1
			print("safeindex")
			
			
			return txt,rich
		end
		print("------")
		--Top- to-Bottom
		for i,v in Hierarchy do
			if v==game then
				txt = "game"
				rich = "game"
			elseif pathMacro[v]~=nil then
				--pathMacro
				txt = pathMacro[v]
				rich = pathMacro[v]
			elseif type(select(2,pcall(game.FindService,game,v.ClassName)))=="userdata" then
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
					if ss.FastNamecall==true then
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

end



local function HB_BuildProperties(ins:Instance,code:string,riched_code:string,Layer:number,Initiator:true?):(string,string)
	local properties = GetProperties(ins)
	local Tags = ins:GetTags()
	local Attributes = ins:GetAttributes()
	--Brackets
	if Initiator~=true then
		code..=`\n{string.rep("\t",Layer-1)}\{`
		riched_code..=`\n{string.rep("\t",Layer-1)}\{`
	end
	--Declearing ClassName
	if ss._HB_Prop_Type_Newline==true then
		code..=`\n{string.rep("\t",Layer)}`
		riched_code..=`\n{string.rep("\t",Layer)}`
	end
	local Type:string = GetTypeOfInstance(ins)
	if properties.Name==nil then
		--Type
		code..=`{(ss.HB_PropBreckets == true and `[{ConstructorTostring("string",ss.HB_ClassName)}]`) or ss.HB_ClassName}{ss._Equal}{ConstructorTostring("string",Type)}{ss._Separator}`
		riched_code..=`{(ss.HB_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.HB_ClassName))}]`) or ss.HB_ClassName}{ss._Equal}{select(2,ConstructorTostring("string",Type))}{ss._Separator}`
	else
		--Name
		code..=`{(ss.HB_PropBreckets == true and `[{ConstructorTostring("string","Name")}]`) or "Name"}{ss._Equal}{ConstructorTostring("string",properties.Name::string)}{ss._Separator}`
		riched_code..=`{(ss.HB_PropBreckets == true and `[{select(2,ConstructorTostring("string","Name"))}]`) or "Name"}{ss._Equal}{select(2,ConstructorTostring("string",properties.Name::string))}{ss._Separator}`
		--Type
		code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBreckets == true and `[{ConstructorTostring("string",ss.HB_ClassName)}]`) or ss.HB_ClassName}{ss._Equal}{ConstructorTostring("string",Type)}{ss._Separator}`
		riched_code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBreckets == true and `[{select(2,ConstructorTostring("string",ss.HB_ClassName))}]`) or ss.HB_ClassName}{ss._Equal}{select(2,ConstructorTostring("string",Type))}{ss._Separator}`
	end
	----------------------
	---_base---
	local baseImport:string? = nil
	if ss.Use_Base_Imports and Classes[Type]~=nil then
		--Grabbing best match for _base
		local persentage:number = 0
		for _base,tab in _baseImports do
			local Matches:number = 0
			local PropertyCount:number = 0
			if type(tab._exec)=="table" and type(tab._exec.SetAttribute)=="table" then
				for i,v in tab._exec.SetAttribute do
					if Attributes[i]==v then Matches+=1 end
					PropertyCount+=1
				end
			end
			if type(tab._exec)=="table" and type(tab._exec.AddTag)=="table" then
				for i,v in tab._exec.AddTag do
					if table.find(Tags,v)~=nil then Matches+=1 end
					PropertyCount+=1
				end
			end
			for i,v in tab do
				if Classes[Type][i]==nil then break end
				if properties[i]==v and (typeof(properties[i])==typeof(v) or (v==nil or properties[i]==nil)) then Matches+=1 end
				if i=="_exec" then continue end
				PropertyCount+=1
			end

			if Matches~=0 and PropertyCount~=0 then
				local _procentage:number = PropertyCount/Matches*100
				if _procentage>persentage and _procentage>=ss.Use_Base_Properties_MatchPersentage then
					baseImport = _base
					persentage = _procentage
				end
			end
		end
		--Setting _base
		if baseImport~=nil then
			code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBrecketsToInit==true and `[{ConstructorTostring("string","_base")}]`) or "_base"}{ss._Equal}{baseImport}{ss._Separator}`
			riched_code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_base"))}]`) or "_base"}{ss._Equal}{baseImport}{ss._Separator}`
		end
	end
	----------
	for i,v in properties do
		if i=="Name" then continue end
		local foundBreak:boolean = false
		for ii,vv in IgnoredPropertiesList do
			if ins:IsA(ii) and table.find(vv,i)~=nil then
				foundBreak=true
				break
			end
		end
		--Ignore List
		if foundBreak then continue end
		--Already in _base
		if baseImport~=nil and _baseImports[baseImport][i]==v then continue end


		local type:string = typeof(v)
		if type=="Instance" then
			if not (v::Instance):IsDescendantOf(SelectedInstance::Instance) and v~=ins and v~=SelectedInstance and (ss.OutsideHierarchyInstances~="SafeIndex" or (v~=SelectedInstance and (v.Parent==game or typeof(select(2,pcall(game.FindService,game,v.Parent.ClassName)))=="Instance"))) then
				--Outside of hierarchy
				local c_code,c_rich = GoToIndexPath(v)
				code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBreckets == true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{c_code}{ss._Separator}`
				riched_code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBreckets == true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{c_rich}{ss._Separator}`
			end
			continue
		end
		if ConstructorTostring_Switch[type]==nil then continue end

		local c_code,c_rich = ConstructorTostring(type,v)
		code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBreckets == true and `[{ConstructorTostring("string",i)}]`) or i}{ss._Equal}{c_code}{ss._Separator}`
		riched_code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBreckets == true and `[{select(2,ConstructorTostring("string",i))}]`) or i}{ss._Equal}{c_rich}{ss._Separator}`
	end
	local _baseIncludesAllTagsAndAttributes:boolean = baseImport~=nil
	local IncludesAllTags:boolean = _baseIncludesAllTagsAndAttributes
	local IncludesAllAttributes:boolean = _baseIncludesAllTagsAndAttributes
	if _baseIncludesAllTagsAndAttributes then
		local import = _baseImports[baseImport::string]
		if type(import._exec)=="table" then
			local _exec:{[any]:any} = import._exec
			_baseIncludesAllTagsAndAttributes=((type(_exec.SetAttribute)=="table" or type(_exec.AddTag)=="table") and true )or false
			if _baseIncludesAllTagsAndAttributes then
				if type(_exec.SetAttribute)=="table" then
					for i,v in Attributes do
						if _exec.SetAttribute[i]~=v then _baseIncludesAllTagsAndAttributes = false IncludesAllAttributes=false break end
					end
				end
				if type(_exec.AddTag)=="table" then
					for i,v in Tags do
						if table.find(_exec.AddTag,v)==nil then _baseIncludesAllTagsAndAttributes = false IncludesAllTags=false break end
					end
				end
			end
		else
			_baseIncludesAllTagsAndAttributes=false
		end
	end
	--_init--
	--IncludeInit?
	local IncludeInit:boolean = (ss._HB_Hierrarchy_TagsAndAttributes=="_init" and (#ins:GetTags()~=0 or next(ins:GetAttributes())~=nil)) or (Type=="MeshPart" and properties.MeshId~=nil)
	if IncludeInit==false then
		for i,v in properties do
			if typeof(v)=="Instance" and (v:IsDescendantOf(SelectedInstance::Instance) or v==ins or v==SelectedInstance or (ss.OutsideHierarchyInstances=="SafeIndex" and ((v.Parent~=game and typeof(select(2,pcall(game.FindService,game,(v.Parent::Instance).ClassName)))~="Instance")))) then IncludeInit=true break end
		end
	end
	--Actual _init here
	--Mainly for inner hierarchy/outer instance indexing with SafeIndex/Initiation of properties like MeshId
	--Note that Instance property could be self
	if IncludeInit then
		code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBrecketsToInit==true and `[{ConstructorTostring("string","_init")}]`) or `_init`}{ss._Equal}function(self{(ss.Typechecking==true and `{ss.TC_Type}{Type}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}`
		riched_code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_init"))}]`) or `_init`}{ss._Equal}{WriteRichText("function",ScriptFunction)}({WriteRichText("self",ScriptSelf)}{(ss.Typechecking==true and `{ss.TC_Type}{WriteRichText(Type,Color3.new(0,1,1))}`) or ""}){(ss.Typechecking==true and `{ss.TC_Type}()`) or ""}`
		--Recursive Hierarchy
		for key,value in properties do
			if typeof(value)=="Instance" and (value:IsDescendantOf(SelectedInstance::Instance) or value==ins or value==SelectedInstance or (ss.OutsideHierarchyInstances=="SafeIndex" and ((value.Parent~=game and typeof(select(2,pcall(game.FindService,game,(value.Parent::Instance).ClassName)))~="Instance")))) then 
				--Recursive hierarchy 
				if value:IsDescendantOf(SelectedInstance::Instance) or ins==value or SelectedInstance==value then
					--Recursive
					local c,r = GoToIndexPath(ins,value,"self",WriteRichText("self",ScriptSelf))
					code..=`\n{string.rep("\t",Layer+1)}self{(ss.HB_PropBrecketsToInit==true and `[{ConstructorTostring("string",key)}]`) or `.{key}`}{ss._Equal}{c}`
					riched_code..=`\n{string.rep("\t",Layer+1)}{WriteRichText("self",ScriptSelf)}{(ss.HB_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string",key))}]`) or `.{WriteRichText(key,ScriptProperty)}`}{ss._Equal}{r}`
				else
					--SafeIndex
					local c,r = GoToIndexPath(ins,value,`self{(ss.HB_PropBrecketsToInit==true and `[{ConstructorTostring("string",key)}]`) or `.{key}`}`,`{WriteRichText("self",ScriptSelf)}{(ss.HB_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string",key))}]`) or `.{WriteRichText(key,ScriptProperty)}`}`,Layer+1)
					code..=c
					riched_code..=r
				end
			end
		end






		--Tags and attributes
		if ss._HB_Hierrarchy_TagsAndAttributes=="_init" and (#ins:GetTags()~=0 or next(ins:GetAttributes())~=nil) and _baseIncludesAllTagsAndAttributes == false then
			--tags
			if #Tags~=0 and IncludesAllTags==false then
				local IncludedTags:{any} = (baseImport~=nil and type((_baseImports[baseImport::string]::any)._exec)=="table" and (type((_baseImports[baseImport]::any)._exec.AddTag)=="table" and (_baseImports[baseImport]::any)._exec.AddTag)) or {}
				if ss.FastNamecall==true then
					for i,v in Tags do
						if table.find(IncludedTags,v)~=nil then continue end
						code..=`\n{string.rep("\t",Layer+1)}AddTag(self{ss.FuncSeparator}{ConstructorTostring("string",v)})`
						riched_code..=`\n{string.rep("\t",Layer+1)}{WriteRichText("AddTag",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{select(2,ConstructorTostring("string",v))})`
					end
				else
					for i,v in Tags do
						if table.find(IncludedTags,v)~=nil then continue end
						code..=`\n{string.rep("\t",Layer+1)}self:AddTag({ConstructorTostring("string",v)})`
						riched_code..=`\n{string.rep("\t",Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("AddTag",ScriptMethod)}({select(2,ConstructorTostring("string",v))})`
					end
				end
			end
			--Attributes
			if next(Attributes)~=nil and IncludesAllAttributes==false then
				local IncludedAttributes:{any} = (baseImport~=nil and type((_baseImports[baseImport::string]::any)._exec)=="table" and (type((_baseImports[baseImport]::any)._exec.SetAttribute)=="table" and (_baseImports[baseImport]::any)._exec.SetAttribute)) or {}
				if ss.FastNamecall==true then
					for i,v in Attributes do
						if IncludedAttributes[i]~=nil then continue end
						code..=`\n{string.rep("\t",Layer+1)}SetAttribute(self{ss.FuncSeparator}{ConstructorTostring("string",i)}{ss.FuncSeparator}{ConstructorTostring(typeof(v),v)})`
						riched_code..=`\n{string.rep("\t",Layer+1)}{WriteRichText("SetAttribute",ScriptMethod)}({WriteRichText("self",ScriptSelf)}{ss.FuncSeparator}{select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(v),v))})`
					end
				else
					for i,v in Attributes do
						if IncludedAttributes[i]~=nil then continue end
						code..=`\n{string.rep("\t",Layer+1)}self:SetAttribute({ConstructorTostring("string",i)}{ss.FuncSeparator}{ConstructorTostring(typeof(v),v)})`
						riched_code..=`\n{string.rep("\t",Layer+1)}{WriteRichText("self",ScriptSelf)}:{WriteRichText("SetAttribute",ScriptMethod)}({select(2,ConstructorTostring("string",i))}{ss.FuncSeparator}{select(2,ConstructorTostring(typeof(v),v))})`
					end
				end
			end
		end


		code..=`\n{string.rep("\t",Layer)}end{ss._Separator}`
		riched_code..=`\n{string.rep("\t",Layer)}{WriteRichText("end",ScriptLuauKeyword)}{ss._Separator}`
	end

	---_exec---
	if ss._HB_Hierrarchy_TagsAndAttributes=="_exec" and (#ins:GetTags()~=0 or next(ins:GetAttributes())~=nil) then
		if _baseIncludesAllTagsAndAttributes==false then
			code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBrecketsToInit==true and `[{ConstructorTostring("string","_exec")}]`) or "_exec"}{ss._Equal}\{`
			riched_code..=`\n{string.rep("\t",Layer)}{(ss.HB_PropBrecketsToInit==true and `[{select(2,ConstructorTostring("string","_exec"))}]`) or "_exec"}{ss._Equal}\{`
			if #Tags~=0 and IncludesAllTags==false then
				local txt,rich = "",""
				local IncludedTags:{any} = (baseImport~=nil and type((_baseImports[baseImport::string]::any)._exec)=="table" and (type((_baseImports[baseImport]::any)._exec.AddTag)=="table" and (_baseImports[baseImport]::any)._exec.AddTag)) or {}
				for i,v in Tags do
					if table.find(IncludedTags,v)~=nil then continue end
					txt..=`\{{ConstructorTostring("string",v)}\}{ss._Separator}`;rich..=`\{{select(2,ConstructorTostring("string",v))}\}{ss._Separator}`
				end
				code..=`\n{string.rep("\t",Layer+1)}AddTag{ss._Equal}\{{txt}\}{ss._Separator}`
				riched_code..=`\n{string.rep("\t",Layer+1)}AddTag{ss._Equal}\{{rich}\}{ss._Separator}`
			end
			if next(Attributes)~=nil and IncludesAllAttributes==false then
				code..=`\n{string.rep("\t",Layer+1)}SetAttribute{ss._Equal}\{`
				riched_code..=`\n{string.rep("\t",Layer+1)}SetAttribute{ss._Equal}\{`
				local IncludedAttributes:{any} = (baseImport~=nil and type((_baseImports[baseImport::string]::any)._exec)=="table" and (type((_baseImports[baseImport]::any)._exec.SetAttribute)=="table" and (_baseImports[baseImport]::any)._exec.SetAttribute)) or {}
				for i,v in Attributes do
					if IncludedAttributes[i]~=nil then continue end
					code..=`\n{string.rep("\t",Layer+2)}\{{ConstructorTostring("string",i)}{ss._Separator}{ConstructorTostring(typeof(v),v)}\};`
					riched_code..=`\n{string.rep("\t",Layer+2)}\{{select(2,ConstructorTostring("string",i))}{ss._Separator}{select(2,ConstructorTostring(typeof(v),v))}\};`
				end
				code..=`\n{string.rep("\t",Layer+1)}\}{ss._Separator}`
				riched_code..=`\n{string.rep("\t",Layer+1)}\}{ss._Separator}`
			end
			--Closing _exec
			code..=`\n{string.rep("\t",Layer)}\}{ss._Separator}`
			riched_code..=`\n{string.rep("\t",Layer)}\}{ss._Separator}`
		end	
	end
	-------
	--Children----
	local children = ins:GetChildren()
	if #children~=0 then
		if ss.SeparateChildren==true then
			code,riched_code = `{code}\n`,`{riched_code}\n`
		end
		for i,v in children do
			if ss.RespectArchivable==true and v.Archivable==false then continue end
			code,riched_code = HB_BuildProperties(v,code,riched_code,Layer+1)
		end
	end
	-----
	if Initiator~=true then
		--Step out from Type/Name
		if next(properties)~=nil or #children~=0 or #Tags~=0 or next(Attributes)~=nil or IncludeInit==true or baseImport~=nil then
			code..=`\n{string.rep("\t",Layer-1)}`
			riched_code..=`\n{string.rep("\t",Layer-1)}`
		end
		--Step out from instance constructor and close it
		code..=`\}{ss._Separator}`
		riched_code..=`\}{ss._Separator}`
	elseif Initiator==true and ((#children==0 and next(properties)~=nil) or #children>0) then
		code..=`\n`
		riched_code..=`\n`
	end
	-----
	return code,riched_code
end

local function HierarchyBuilder_Convert(ins:Instance):()
	local code:string = ``
	local riched_code:string = ``
	code..=`{ss._local}{ss._HB_HierrarchyName}{ss._Equal}{ss._HierarchyBuilderFunctionName}{(ss._HB_FN_BRACKETS==true and "(") or ""}\{`
	riched_code..=`{WriteRichText(ss._local,ScriptLocal)}{ss._HB_HierrarchyName}{ss._Equal}{WriteRichText(ss._HierarchyBuilderFunctionName,ScriptMethod)}{(ss._HB_FN_BRACKETS==true and "(") or ""}\{`
	code,riched_code=HB_BuildProperties(ins,code,riched_code,1,true)
	code..=`\}{(ss._HB_FN_BRACKETS==true and ")") or ""}`
	riched_code..=`\}{(ss._HB_FN_BRACKETS==true and ")") or ""}`
	Rich.Text = riched_code
	Code.Text = code
end
local function RawLuau_Convert(ins:Instance):()
	Rich.Text = "WIP"
	Code.Text = "WIP"
end

local function BegginConvert():()
	--Mutate variables
	UpdateSS()
	OnConvert:Fire()
	--Configs init
	Rich.TextSize = ss.CodeOutputTextSize
	Code.TextSize = ss.CodeOutputTextSize
	CodeOutput_Title.TextSize=ss.CodeOutputTextSize
	--
	SelectedInstance = Selection:Get()[1]
	if SelectedInstance==nil then warn("Please select any instance to convert") return end
	if CurrentConvertType=="Hierarchy Builder" then
		HierarchyBuilder_Convert(SelectedInstance)
	elseif CurrentConvertType=="Raw Luau" then
		RawLuau_Convert(SelectedInstance)
	else
		error("Something unexpected heppened somehow, This tab converter does not exist")
	end
	local bounds = TextService:GetTextSize(Code.Text,Code.TextSize,Code.Font,Vector2.new(math.huge,math.huge))
	CodeOutput_Scrolling.CanvasSize = UDim2.new(0,bounds.X,0,bounds.Y)
	SelectButtonByName("Converted Code")
end


do
	--Connecting convert stuff
	local ConvertKeybind = plugin:CreatePluginAction("HB_Convert","Convert","Convert","rbxassetid://75358548882112",true)
	ConvertKeybind.Name = "Convert"
	LowerBar_Convert.MouseButton1Click:Connect(BegginConvert)
	ConvertKeybind.Triggered:Connect(BegginConvert)
end















