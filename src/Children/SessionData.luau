--!strict
local HttpService = game:GetService("HttpService")
local plugin = script:FindFirstAncestorOfClass("Plugin")::Plugin

local PropertiesThatExist:{[string]:string|number|boolean} = {
	--Shared
	["Equal"] = " = ";
	["NE_SaveMeshes"] = true;
	["CodeOutputTextSize"] = 33;
	["local"] = "local ";
	["ReplacementInstance"] = "Configuration";
	["Separator"] = ";";
	["SaveMeshes"] = true;
	["SaveMeshes_IncludeFN"] = true;
	["SaveMeshes_FN_Name"] = "ApplyMeshFunc";
	["SaveMeshes_Cache"] = true;
	["SaveMeshes_ClearCache"] = true;
	["SaveMeshes_CacheTableName"] = "Cached_MeshParts";
	["OutsideHierarchyInstances"] = "WaitForChild";
	["IndexingBy"] = "Dots";
	["Indexing_Instances_By"]="Dots";
	["Use_Base_Imports"]=true;
	["Use_Base_Properties_MatchPersentage"]=100;
	["Base_Imports_FN_subName"] = "_base";
	["VectorLibUse"] = "vector";
	["CFrameFormatting"] = "CFrameNewYXZRotation";
	["MatrixCFrameMeasurements"] = "Balance";
	["PreferVectorForEmptyRotCFrame"] = true;
	["RespectArchivable"] = true;
	["FuncSeparator"] = ",";
	["Color3Format"] = "Color3_new";
	["Rounding"] = true;
	["Precision"] = 3;
	["Mult"] = "*";
	["Div"] = "/";
	["Typechecking"] = true;
	["FastNamecall"] = false;
	["NC_InsIndex"] = "instance_index";
	["NC_InsSetProperty"] = "instance_newindex";
	["NC_CfrMul"] = "cframe_mul";
	["HexademicalString"] = false;
	["TC_Type"] = ":";
	["TC_Casting"] = "::";
	["NanConstant"] = false;
	["NanConstant_Name"] = "nan";
	["SeparateChildren"] = 1;
	["SafeIndexSubtag"] = "var_";
	["SafeIndexNaming"] = "SubtagPlusInstanceNamePlusNumber";
	["MeshPartCreationMode"] = "Compute";
	["Instance_PropGrab"] = false;
	["RL_WrapPropDoEnd"] = true;
	["UDIM2_MoreConstructors"] = false;
	["All_NumbersRound"] = 3;
	["UnderscoreNumbers"] = true;
	["UnderscoreNumbers_Count"] = 3;
	["HexNumbers"] = false;
	["ScientificNotations"] = true;
	["SN_Float"] = 4;
	["SN_Integer"] = 6;
	["UseMeshFunction"] = true;
	["AvoiddoubleTextureID"] = true;
	["localMeshVariableName"] = "mesh";
	["DisplaySource"] = false;
	["DisplayDate"] = true;
	["WriteRichText"] = true;
	["UnderscoreNumbers_IgnoreFloats"] = true;
	["CacheTableType"] = "Array";
	["CacheHashTableSpacing"] = true;
	["then"] = " then";
	["do"] = " do";
	["if"] = "if ";
	["end"] = "end";
	["for"] = "for ";
	["fbend"] = "";
	["or"] =" or ";
	["and"] =" and ";
	["TupleSeparator"] = ",";
	["break"] = "break";
	["return"] = "return";
	["=="] = " == ";
	["in"] = " in ";
	["--"] = "--";
	["RegisterLimit"] = 175;
	["FriendlyFraction"] = true;
	["Fraction"] = 100;
	["FractionMaxInt"] = 10;
	["FractionThreshold"] = 4;
	["t"] = "Tab";
	["BuffSize"] = 600_000;
	["CMPAsyncService"] = "AssetService";
	["CountEnabled"] = true;
	["s"] = " ";
	["CMPAsyncService_PassFuildFidility"] = false;
	["FuzzyCFrame"] = 5;
	["NE_using_run"] = true;
	["NE_NewArgConstructor"] = false;
	["NE_ChildrenTable"] = false;
	["NE_ChildrenTable__Name"] = "Children";
	["NameOnTop"] = true;
	["NE_NAC_Spacing"] = " ";
	["NE_NAC_New_2_Spacing"] = " ";
	["RL_RecursionWrite"] = "Instant";
	["RL_Compile_baseFunctions"] = true;
	["RL_Referanceless"] = true;
	["SeparatePost_Advanced"] = "";
	["Separate_Advanced"] = "";
	["___CurrentConvertType"] = "Nestify";
	["___CurrentTab"] = "Nestify";
	["RL_AttributesTags"] = true;
	["RL_Deffered_Fn_Mesh"] = "DefferedMeshCreate";
	["RL_DFM_Include"] = true;
	["NE_New_exec"] = true;
	["NE_New_exec_AttributeBrackets"] = true;
	["RL_WrapSafeIndexDoEnd"] = true;
	["StartRegisterCount"] = 0;
	
	----Hierarchy builder
	HierarchyBuilderFunctionName="Nestify";

	NE_Instance_Recursive_Behavior = "_init";
	NE_Instance_Recursive_Behavior_IndexMethod="Index";
	NE_Instance_Recursive_Behavior_IncludeFunction=true;
	NE_Instance_Recursive_Behavior_FN_NAME="HierarchyRecursive";
	NE_FN_BRACKETS=false;
	NE_Prop_Type_Newline=false;
	NE_HierrarchyName="Hierarchy";
	_NE_Hierrarchy_TagsAndAttributes="_exec";
	NE_PropBreckets = false;
	NE_PropBrecketsToInit = false;
	NE_ClassName = "Class";

}
local SessionData = HttpService:JSONDecode(plugin:GetSetting("HierarchySaver_Settings") or "{}"::any)::typeof(PropertiesThatExist)
for i,v in PropertiesThatExist do
	if SessionData[i]==nil then
		SessionData[i]=v
	end
end


return SessionData
