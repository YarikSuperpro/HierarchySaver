--!strict

export type SecurityMethods = "None"|"LocalUserSecurity"|"NotAccessibleSecurity"|"PluginSecurity"|"RobloxScriptSecurity"|"RobloxSecurity"
export type Class_Tags = {
	[number]:"CanYield"|"CustomLuaState"|"Deprecated"|"Hidden"|"NoYield"|"NotBrowsable"|"NotCreatable"|"NotReplicated"|"NotScriptable"|"PlayerReplicated"|"ReadOnly"|"Service"|"Settings"|"UserSettings"|"Yields"
}
export type Thread_Safety = "ReadSafe"|"Safe"|"Unsafe"
export type Capabilities = "Animation"|"Assistant"|"Audio"|"Avatar"|"Basic"|"CSG"|"CapabilityControl"|"Chat"|"CreateInstances"|"DataStore"|"Environment"|"Input"|"InternalTest"|"LegacySound"|"Network"|"Physics"|"Players"|"PluginOrOpenCloud"|"RemoteEvent"|"UI"


--------^^^^^^ is basically Enum.SecurityCapability

type Value_Type = {
	["Name"]:string;
	["Category"]:string;
}
export type AllRobloxClasses = {
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
export type AllRobloxEnums = {
	[number]:{
		Name:string;
		Items:{
			[number]:{Name:string;Value:number}
		};
		Tags:Class_Tags?
	}
}
export type API_Dump = {
	Classes:AllRobloxClasses;
	Enums:AllRobloxEnums;
	Version:number
}

export type FormattedClass = {
	[string]:string
}
export type FormattedClasses = {
	[string]:FormattedClass
}

export type RecursiveRoot = {
	[number]:RecursiveTree
}
export type PropertyTypes = "string"|"number"|"boolean"|"NumberRange"|"Enum"|"None"

export type RecursiveTree = {
	Name:string;
	Type:PropertyTypes;
	DisplayName:string?;
	Description:string?;
	DataComponent:{[string]:any}?;
	Tree:RecursiveRoot?
}
export type BuildProperties = {
	[number]:{Name:string;Content:RecursiveRoot}
}
return {}::{}
