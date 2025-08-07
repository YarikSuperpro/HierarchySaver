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

--[[Ammount of matches with pattern]]
local function CountChars(str:string,pattern:string):number
	local i:number=0
	for _,v in string.gmatch(str,pattern) do
		i+=1
	end
	return i
end
local Patterns:{[string]:string} = {
	["^[%[%]{}(),;=%+%-%*%/]"]="Symbol";
	["^true"]="boolean";
	["^false"]="boolean";
	["^nil"]="nil";
	["^%s"]="\0";
	["^[-+]?0?[xX]?[%da-fA-F_]+%.?[%da-fA-F_]*[eE]?[%d_%.]*"] = "number";
	--["^%-?%d+%.?%d*"] = "number";
	[`^["'\`][^"^'^\`]*["'\`]`]="string";
	["^%.?[%a_][%w_%.:]*"]="Identifier";
}
local CharEscapes:{[string]:string}={
	["n"]="\n";
	["t"]="\t";
	["\""]="\"";
	["\\"]="\\";
	["'"]="'";
	["`"]="`";
	["r"]="\r";
	["b"]="\b";
	["f"]="\f";
	["v"]="\v";	
}

--local alloc:number = (#YSFFLUAU_TABLE-CountChars(YSFFLUAU_TABLE,"%s"))/2
type Context = "Symbol"|"Identifier"|"string"|"number"|"boolean"|"nil"
type Token = {Context:Context;Value:string}
type Tokens = {[number]:Token}
--[[
<strong>YSFFLUAU_TABLE</strong>:
returns: tokens that can be parsed.
]]
local function Tokenize(YSFFLUAU_TABLE:string):Tokens
	local Tokens:Tokens = table.create(CountChars(YSFFLUAU_TABLE,"%S"))::Tokens
	local i:number = 1
	while i <= #YSFFLUAU_TABLE do
		local found:boolean = false
		for pattern, value in Patterns do
			local match:string = string.match(YSFFLUAU_TABLE,pattern,i)
			if not match then continue end
			if value=="\0" then 
				i += #match
				found = true
				break
			end
			if value=="Symbol" then
				if match=="-" and (Tokens[#Tokens]==nil or Tokens[#Tokens].Context=="Symbol") and string.match(YSFFLUAU_TABLE,"^[%-][%.%d_]+",i) then continue end
			end
			if value=="number" then
				if string.match(match,"^[-+]?[%.?%d_]*")=="" then continue end
			end
			if value=="string" then
				if string.find(match,"\\") then--Character escaping
					local _i:number = i+1
					local newstr:string = ""
					while _i<#YSFFLUAU_TABLE do
						local char = string.sub(YSFFLUAU_TABLE,_i,_i)
						if char=="\\" then
							local peek = string.sub(YSFFLUAU_TABLE,_i+1,_i+1)
							local escape:string = CharEscapes[peek] or ""
							if escape~="" then
								newstr..=escape
								_i+=2
								continue
							end
						end
						if char=="\"" or char=="'" or char=="`" then
							_i+=1
							break
						end
						newstr..=char
						_i+=1
					end
					table.insert(Tokens, {Context = value;Value = newstr}::Token)
					i = _i
					found = true
					break
				end
				table.insert(Tokens, {Context = value;Value = string.sub(match,2,-2)}::Token)
				i += #match
				found = true
				break
			end
			if value=="Identifier" then
				if match=="nil" then
					table.insert(Tokens, {Context = "nil";Value = match}::Token)
					i += #match
					found = true
					break
				elseif string.sub(match,1,1)=="." then
					local splt:{string} = string.split(match,".")
					table.remove(splt,1)
					for i,v in splt do
						table.insert(Tokens, {Context = "string";Value = v}::Token)
					end
					i += #match
					found = true
					break
				end
			end
			table.insert(Tokens, {Context = value;Value = match}::Token)
			i += #match
			found = true
			break
		end
		if not found then
			error(`Unexpected character at position #{i}: {string.sub(YSFFLUAU_TABLE,i,i)}`)
		end
	end
	return Tokens
end

--Accesible libraries to parsing YSFFLUAU_TABLE
local Constructors:{[string]:any} = {
	Vector3 = Vector3;
	Color3 = Color3;
	CFrame = CFrame;
	UDim2 = UDim2;
	UDim = UDim;
	NumberSequenceKeypoint = NumberSequenceKeypoint;
	NumberSequence = NumberSequence;
	NumberRange = NumberRange;
	Enum = Enum;
	ColorSequenceKeypoint = ColorSequenceKeypoint;
	ColorSequence = ColorSequence;
	BrickColor = BrickColor;
	Rect = Rect;
	Vector2 = Vector2;
	vector=vector;
	Vector2int16=Vector2int16;
	Vector3int16=Vector3int16;
	tostring=tostring;
	tonumber=tonumber;
	Random=Random;
	math=math;
	string=string;
	workspace = workspace;
	game = game;
	Axes=Axes;
	Faces=Faces;
	FloatCurveKey=FloatCurveKey;
	Font=Font;
	SecurityCapabilities=SecurityCapabilities;
	Instance=Instance;
	Path2DControlPoint=Path2DControlPoint;
	PhysicalProperties=PhysicalProperties;
	Ray=Ray;
	Region3=Region3;
	Region3int16=Region3int16;
	RotationCurveKey=RotationCurveKey;
	SharedTable=SharedTable;
}

local Operators:{[string]:(arg1:any,arg2:any)->any} = {
	["*"] = function(arg1:any,arg2:any):any
		return arg1*arg2
	end;
	["/"] = function(arg1:any,arg2:any):any
		return arg1/arg2
	end;
	["-"] = function(arg1:any,arg2:any):any
		return arg1-arg2
	end;
	["+"] = function(arg1:any,arg2:any):any
		return arg1+arg2
	end;
}
local Operators_StrPattern:string = "[%*%/%+%-]"

--Referances
local Parse_Table:(tokens:Tokens,Index:number)->({[any]:any},number)
local Parse_Expression:(tokens:Tokens,Index:number,Value:any)->(any,number)

--[[
Parse value:
<strong>tokens:</strong> list of tokens.
<strong>Index:</strong> index of the token that should be parsed.
<strong>returns:</strong> value, index, SetTo?]]
local function Parse_Value(tokens:Tokens,Index:number,SetTo:boolean?):(any,number,boolean?)
	local token:Token? = tokens[Index]
	if token==nil then return nil,Index,false end
	local context = token.Context
	local value = token.Value
	if context=="string" then
		return value,Index+1,SetTo
	elseif context=="number" then
		local vl,ind =  Parse_Expression(tokens,Index+1,tonumber(value) or 0)
		return vl,ind,SetTo
	elseif context=="boolean" then
		return value=="true",Index+1,SetTo
	elseif context=="nil" then
		return nil,Index+1,SetTo
	elseif context=="Symbol" then
		if value=="{" then
			local vl,ind = Parse_Table(tokens,Index)
			return vl,ind,SetTo
		elseif value=="[" then
			local vl,ind = Parse_Value(tokens,Index+1)
			return vl,ind,SetTo
		elseif value=="]" then
			local vl,ind,SetTo = Parse_Value(tokens,Index+1)
			return vl,ind,SetTo
		elseif value=="(" then
			local tuple:{any} = {}
			local endArgs:number = 0
			local Uncloded:number = 0
			for i,v in tokens do
				if i<Index then continue end
				if v.Context=="Symbol" then
					if v.Value=="(" then 
						Uncloded+=1
					elseif v.Value==")" then 
						Uncloded-=1
						if Uncloded==0 then
							endArgs=i 
							break 
						end
					end
				end	
			end
			if endArgs==0 then error(`Unable to close Args (Tuple)? at: {Index}`) end
			local i:number = Index+1
			while i<endArgs do
				local separatorToken:Token = tokens[i]
				if separatorToken.Context=="Symbol" and separatorToken.Value=="," then
					i+=1
				end
				local peek,ind = Parse_Value(tokens,i)
				table.insert(tuple,peek)
				i=ind
			end
			return tuple,endArgs+1,SetTo
		elseif value==";" or value=="," then
			local vl,ind,SetTo = Parse_Value(tokens,Index+1,false)
			return vl,ind,SetTo
		elseif value=="=" then--SET TO
			return Parse_Value(tokens,Index+1,true)
		else
			local vl,ind = Parse_Value(tokens,Index+1)
			return vl,ind,SetTo
		end
	elseif context=="Identifier" then
		if SetTo==false then
			return value,Index+1
		end
		local splt = string.split(value,".")
		local library:({[string]:any}|(...any)->(...any))? = Constructors[splt[1]]
		if library==nil then
			local vl,ind = Parse_Expression(tokens,Index+1,value)
			return vl,ind,SetTo 
		end
		if type(library)~="function" then
			for i,v in splt do
				if i==1 then continue end
				library=library[v::string]
			end
		end
		local args:{any}?
		local i:number=Index+1
		while i<#tokens do
			local peek,ind,Set = Parse_Value(tokens,i)
			if Set~=nil then break end
			if type(peek)=="string" then
				if library[peek]==nil then break end
				library=library[peek]
				i=ind
			elseif type(peek)=="table" then
				args=peek::{any}
				i=ind
				break
			else
				break
			end
			i=ind
		end
		if library==nil then
			error(`Unable to index nil library at: {Index}, Non existen key`)
		end
		if type(library)=="function" then
			if (args::any)==nil then
				local vl,ind = Parse_Expression(tokens,i,library)
				return vl,ind,SetTo
			end
			local ret:any = (library::(...any)->(...any))(table.unpack(args or {}))
			local vl,ind = Parse_Expression(tokens,i,ret)
			return vl,ind,SetTo
		end
		local vl,ind = Parse_Expression(tokens,i,library)
		return vl,ind,SetTo
	else
		error(`Something went wrong: {value} ::{context}`)
	end
end

Parse_Expression = function(tokens:Tokens,Index:number,Value:any):(any,number)
	local Operator:Token = tokens[Index]
	if Operator==nil or Operator.Context~="Symbol" or not string.match(Operator.Value,Operators_StrPattern) then return Value,Index end
	local vl2,ind2 = Parse_Value(tokens,Index)
	return Operators[string.match(Operator.Value,Operators_StrPattern)](Value,vl2),ind2
end
Parse_Table = function(tokens:Tokens,Index:number):({[any]:any},number)
	local tab:{[any]:any}&{any} = {}--It gets angry if i don't add &{any}
	local endTable:number = 0
	local Uncloded:number = 0
	for i,v in tokens do
		if i<Index then continue end
		if v.Context=="Symbol" then 
			if v.Value=="{" then
				Uncloded+=1
			elseif v.Value=="}" then
				Uncloded-=1
				if Uncloded==0 then
					endTable=i break
				end
			end

		end
	end
	if endTable==0 then error(`Unable to close the table at: {Index}`) end
	local i:number = Index+1
	while i<endTable do
		if i==endTable-1 and tokens[i].Context=="Symbol" and (tokens[i].Value==";" or tokens[i].Value==",") then
			break--Don't parse last semicolon
		end
		local val,ind = Parse_Value(tokens,i,if i==Index+1 then false else nil)
		local val2,ind2,SetTo = Parse_Value(tokens,ind)
		if SetTo==true then
			tab[val]=val2
			i=ind2
		else
			table.insert(tab,val)
			i=ind
		end
	end
	return tab::{[any]:any},endTable+1
end

--[[
<strong>YSFFLUAU_TABLE</strong> format needed in a string.
returns: deserialized Luau datatype
⚠has to be pcall wrapped⚠
]]
local function Parse(YSFFLUAU_TABLE:string):any
	local tokens:Tokens = Tokenize(YSFFLUAU_TABLE)
	local value,index = Parse_Value(tokens,1)
	return value
end

return Parse
