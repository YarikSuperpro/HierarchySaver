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
--!strict
--!optimize 2
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local Heartbeat = RunService.Heartbeat
--[[
Inverse Lerp Interpolation
Example:
(5,0,100) <strong>-></strong> 0.05
Takes <strong>value</strong> and interpets it between <strong>minimum</strong> and <strong>maximum</strong> and then returns a number from 0 to 1 representing procentage of <strong>value</strong> to reaching <strong>maximum</strong>
]]
local function iLerp(value:number, minimum:number, maximum:number):number
	return (value - minimum) / (maximum - minimum)
end

if RunService:IsRunMode() then return end


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
type SecurityMethods = "None"|"LocalUserSecurity"|"NotAccessibleSecurity"|"PluginSecurity"|"RobloxScriptSecurity"|"RobloxSecurity"
type Class_Tags = {
	[number]:"CanYield"|"CustomLuaState"|"Deprecated"|"Hidden"|"NoYield"|"NotBrowsable"|"NotCreatable"|"NotReplicated"|"NotScriptable"|"PlayerReplicated"|"ReadOnly"|"Service"|"Settings"|"UserSettings"|"Yields"
}
type Thread_Safety = "ReadSafe"|"Safe"|"Unsafe"
type Capabilities = "Animation"|"Assistant"|"Audio"|"Avatar"|"Basic"|"CSG"|"CapabilityControl"|"Chat"|"CreateInstances"|"DataStore"|"Environment"|"Input"|"InternalTest"|"LegacySound"|"Network"|"Physics"|"Players"|"PluginOrOpenCloud"|"RemoteEvent"|"UI"
local Selection = game:GetService("Selection")

--------^^^^^^ is basically Enum.SecurityCapability

type Value_Type = {
	["Name"]:string;
	["Category"]:string;
}
type AllRobloxClasses = {
	[number]:{
		["Tags"]: Class_Tags?;
		["Superclass"]:string;
		["Name"]:string;
		["MemoryCategory"]:"Animation"|"GraphicsTexture"|"Gui"|"Instances"|"Internal"|"PhysicsParts"|"Script"; 
		["Members"]:{
			[number]:{
				["Capabilities"]:{
					[number]:{
						[number]:Capabilities
					}|{
						["Read"]:{
							[number]:Capabilities
						};
						["Write"]:{
							[number]:Capabilities
						}
					}	
				}?;
				["Category"]:string?;
				["MemberType"]:"Callback"|"Event"|"Function"|"Property";
				["Name"]:string;
				["Parameters"]:{
					[number]:{
						["Name"]:string;
						["Type"]:Value_Type
					}
				}?;
				["ReturnType"]:Value_Type?;
				["Security"]:SecurityMethods|{
					["Read"]:SecurityMethods|{SecurityMethods};
					["Write"]:SecurityMethods|{SecurityMethods}
				};
				["Serialization"]:{
					["CanLoad"]:boolean;
					["CanSave"]:boolean
				}?;
				["Tags"]:Class_Tags?;
				["ThreadSafety"]:Thread_Safety;
				["ValueType"]:{
					["Category"]:"Class"|"DataType"|"Enum"|"Primitive";
					["Name"]:string;
				}?;
			}
		};
	}
}
type AllRobloxEnums = {
	[number]:{
		Name:string;
		Items:{
			[number]:{Name:string;Value:number}
		};
		Tags:Class_Tags?
	}
}
type API_Dump = {
	Classes:AllRobloxClasses;
	Enums:AllRobloxEnums;
	Version:number
}

type FormattedClass = {
	[string]:string
}
type FormattedClasses = {
	[string]:FormattedClass
}
--*********************Voodoo C++ data types into Luau types
local TranslateProperties:FormattedClass = {
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
local Data:API_Dump? = nil
local Classes:FormattedClasses = {}
local WaitForData = coroutine.running()

local LasestCache:number = tonumber(plugin:GetSetting("HierarchySaver_LatestCache_Valid")) or 0
local GET_SAVE:string? = plugin:GetSetting("HierarchySaver_CLASSES")

local function SuccessResult(ret:string):()
	Data = HttpService:JSONDecode(ret)
	local raw_Classes:AllRobloxClasses = Data.Classes
	local Enums:AllRobloxEnums = Data.Enums
	for i,v in raw_Classes do
		--if v.MemoryCategory~="Instances" then continue end
		if v.Tags~=nil and (table.find(v.Tags,"NotCreatable")~=nil or table.find(v.Tags,"NotScriptable")~=nil) then continue end
		local tab:FormattedClass = {}
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
				if vv.Tags~=nil and (table.find(vv.Tags,"ReadOnly")~=nil or table.find(vv.Tags,"NotScriptable")~=nil or table.find(vv.Tags,"Deprecated")~=nil or table.find(vv.Tags,"Hidden")~=nil or table.find(vv.Tags,"Not Replicated")~=nil) then continue end
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
--Display
local Main = script:WaitForChild("Main")
local LowerBar = Main:WaitForChild("LowerBar")
local UpperBar = Main:WaitForChild("UpperBar")
local ViewTabs = Main:WaitForChild("ViewTabs")
--Lists
local TabViewports:{Frame} = {}

--*********************CONSTANTS
local Thickness = 16--In pixels
local SliderResponsivenessTime = 1
local ScrollSpeed = 5.5
local Button_SlideBy_Y = Vector2.new(0,15)
local Button_SlideBy_X = Vector2.new(15,0)
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
			object=object.Parent
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
local TextButtons_Theme:{TextLabel|TextBox|TextButton} = table.create(20)::{TextLabel|TextBox|TextButton}
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

	local Mid:Color3 = StudioTheme:GetColor(Enum.StudioStyleGuideColor.Mid)
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



local function RemoveSelectionButton():()
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
		for i,v in TabViewports do
			if v==Tab then continue end
			v.Visible = false
		end
		for i,v in UpperBar:GetChildren() do
			if v==Tab_Button then continue end
			if not v:IsA("Frame") then continue end
			v:SetAttribute("Enabled",false)
			v.BackgroundColor3=ItemColor
		end
		Tab.Visible = true
		Tab_Button:SetAttribute("Enabled",true)
		Tab_Button.BackgroundColor3=ViewPortBackground
		RemoveSelectionButton()
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
	local List = Tab_Scroll.List
	local List_Layout = List.UIListLayout
	local Bottom_Outline = Tab.Bottom_Outline
	local Right_Outline = Tab.Right_Outline
	Bottom_Outline.Size = UDim2.new(1,0,0.0000001,Thickness)--Hack to make it draw over scrollbar
	table.insert(UI_Strokes,Bottom_Outline:WaitForChild("UIStroke")::UIStroke)
	Right_Outline.Size = UDim2.new(0.0000001,Thickness,1,0)--Hack to make it draw over scrollbar
	table.insert(UI_Strokes,Right_Outline:WaitForChild("UIStroke")::UIStroke)
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

		for i,v in List:GetChildren() do
			if not v:IsA("GuiObject") or not v:IsA("GuiBase2d") or v.Visible==false then continue end
			sumY+=v.AbsoluteSize.Y
			local MaxSize:number? = (tonumber(v:GetAttribute("MaxSize")::number?) and (tonumber(v:GetAttribute("MaxSize")::number?)::number)+(Size.X.Offset*0.5)) or nil
			local v_Content = v:FindFirstChild("Content")::Frame?
			if MaxSize==nil or v_Content~=nil and v_Content.Size.X.Offset>=(MaxSize or 0) then
				
				if v_Content==nil then continue end
				MaxSize=v_Content.Size.X.Offset	
			end
			if MaxSize::number>highestX then highestX=MaxSize::number end
		end
		highestX=math.min(highestX,10_000)--10k pixels limit
		local Size_X_Offset = Size.X.Offset
		List:SetAttribute("Offset_True_X",Size_X_Offset)
		List:SetAttribute("HighestX",highestX)
		local scaled = UDim2.new(0,highestX-(Size_X_Offset/2)+((Size_X_Offset<highestX and 5) or 0),1,0)
		for i,v in List:GetChildren() do
			if not v:IsA("GuiObject") then continue end
			local v_Content = v:FindFirstChild("Content")::Frame?
			if v_Content==nil then continue end
			local value = v_Content:FindFirstChild("Value")::Frame?
			if value==nil then continue end
			value.Size=scaled

		end
		Tab_Scroll.CanvasSize=UDim2.new(0,highestX+2+((Size.X.Offset<highestX and 6) or 0),0,sumY+2)
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
		run = RunService.Heartbeat:Connect(function(delta:number):()
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
		run = RunService.Heartbeat:Connect(function(delta:number):()
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
		run = RunService.Heartbeat:Connect(function(delta:number):()
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
		run = RunService.Heartbeat:Connect(function(delta:number):()
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
	Tab_Button.Parent = UpperBar
	Tab.Parent=ViewTabs
	ScaleCanvas()
	return Tab,List
end

--*********************Obtaining classes
if LasestCache>workspace:GetServerTimeNow() and type(GET_SAVE)=="string" then
	Classes = HttpService:JSONDecode(GET_SAVE)::FormattedClasses
	if WaitForData then coroutine.resume(WaitForData) end
else
	local success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
	if success then
		SuccessResult(ret)
	else
		-- No perms but has a backup
		if type(GET_SAVE)=="string" then
			Classes = HttpService:JSONDecode(GET_SAVE)::FormattedClasses
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
		if instance[i]==cache_prop[i] then continue end
		prop[i]=instance[i]
	end
	return prop
end

local PropertiesThatExist:{[string]:string|number|boolean} = {
	HB_SaveMeshes = true;
	HB_CyclicProperties = true;
	HB_NamingSubtag = "";
	TestIdk=0;

}

local SessionData = HttpService:JSONDecode(plugin:GetSetting("HierarchySaver_Settings") or "{}")::typeof(PropertiesThatExist)
for i,v in PropertiesThatExist do
	if SessionData[i]==nil then
		SessionData[i]=v
	end
end
plugin.Unloading:Once(function()
	plugin:SetSetting("HierarchySaver_Settings",HttpService:JSONEncode(SessionData))
end)



local Types = require(script:WaitForChild("Types"))

local OffsetBy:number = 16

local function BlankPropertyCreate(Name:string,DisplayName:string?,Description:string?,OffsetLevel:number?):(TextButton,Frame,Frame)
	local Property = Property:Clone()::TextButton
	local Property_Content = Property:WaitForChild("Content")::Frame
	local LabelFrame = Property_Content:WaitForChild("LabelFrame")::Frame
	--[[Content offset]]
	if OffsetLevel~=nil then
		LabelFrame.Size=UDim2.new(0.5,-(OffsetBy*OffsetLevel),1, 0)
	end
	---

	local Label = LabelFrame:WaitForChild("Label")::TextLabel
	local Gap = LabelFrame:WaitForChild("Gap")::Frame
	table.insert(UI_Strokes,Property:WaitForChild("UIStroke")::UIStroke)
	table.insert(Properties_ItemColor,Property)
	table.insert(TextButtons_Theme,Label)
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
			Property:SetAttribute("MaxSize",sz)
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
			Property:SetAttribute("MaxSize",sz)
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

local function TreeRecursive(Parent:GuiObject,Data:Types.RecursiveRoot,Updater:BindableEvent,Layer:number,TrueParent:GuiObject):()
	local ParentProperty_Content = Parent.Parent::Frame
	local ParentPropertyBox = ParentProperty_Content.Parent::Frame
	for _,Tree in Data do
		local Property,Property_Content,Gap = BlankPropertyCreate(Tree.Name,Tree.DisplayName,Tree.Description,Layer)
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
			TreeRecursive(Box_Nest,Tree.Tree,Updater,Layer+1,TrueParent)
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

local function BuildPropertiesList(Parent:Instance,Data:Types.BuildProperties)
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
		Category.MouseButton1Click:Connect(function()
			local state = not Expanded
			Expanded = state
			if state==true then
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
			local Property,Property_Content,Gap = BlankPropertyCreate(i,v.DisplayName,v.Description)
			PropertyTypeInitiator(Property,Property_Content,v.Type,i,Updater,nil,v)
			if v.Tree==nil then
				table.insert(CategoryDescendants,Property)
				Property.LayoutOrder=Index
				Property.Visible=true
				Property.Parent=Parent
			else
				Property.Size=Y_height23_SUBSTRACTED--Hacky to fix weird roblox scaling glitch
				local Box = PropertyBox:Clone()
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
				TreeRecursive(Box_Nest,v.Tree,Updater,1,Box)
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


local Hierarchy_Builder,Hierarchy_Builder_Content = CreateTab("Hierarchy Builder","rbxassetid://72069099688057")
local Raw_Luau,Raw_Luau_Content = CreateTab("Raw Luau","rbxassetid://18606791059")
local Converted_Code,Converted_Code_Content = CreateTab("Converted Code","rbxassetid://46342657")
Hierarchy_Builder.Visible=true
BuildPropertiesList(Hierarchy_Builder_Content,require(script:WaitForChild("Properties_HierarchyBuilder")))
BuildPropertiesList(Raw_Luau_Content,require(script:WaitForChild("Properties_RawLuau")))



warn("YAY",Classes,Data)
for i,v in ViewTabs:GetChildren()::{Frame} do
	if v.Visible==true then
		local Button = UpperBar:FindFirstChild(v.Name)
		if Button==nil then continue end
		Button:SetAttribute("Enabled",true)
	end
end
ThemeChanged()



LowerBar_Convert.MouseButton1Click:Connect(function()
	for i,v in ViewTabs:GetChildren() do
		if not v:IsA("GuiObject") then continue end
		v.Visible=false
		local Button = UpperBar:FindFirstChild(v.Name)::Frame?
		if Button==nil then continue end
		Button:SetAttribute("Enabled",false)
		Button.BackgroundColor3=ItemColor
	end
	Converted_Code.Visible=true
	local Button = UpperBar:FindFirstChild(Converted_Code.Name)::Frame?
	if Button~=nil then
		Button:SetAttribute("Enabled",true)
		Button.BackgroundColor3=ViewPortBackground
	end
	print("Converting")
	
	
end)


















