--!strict
local Types = require(script.Parent:WaitForChild("Types"))
task.defer(game.Destroy,script)
return {
	{
		Name = "Shared Settings";
		Content = {
			{
				Name = "Instance_PropGrab";
				DisplayName = "Grab Properties";
				Description = "Grab all properties of selected instance";
				Type = "boolean";
			};
			{
				Name = "BuffSize";
				DisplayName = "Buffer Size";
				Description = "Maximum size for output (Don't put too high number 100K-1M is already a lot).Note: this data will be allocated for richtext part aswell if richtext is enabled.If content is over 200K characters then richtext will not be displayed.";
				Type = "number";
			};
			{
				Name = "RespectArchivable";
				DisplayName = "Respect Archivable";
				Description = "If true: will not copy archivable descendants and descendants of archivable.";
				Type = "boolean";
			};
			{
				Name = "DisplaySource";
				DisplayName = "Display @Source";
				Description = "Show @Source in the comment ontop of a code?";
				Type = "boolean";
				Tree = {
					{
						Name = "DisplayDate";
						DisplayName = "Display Date";
						Description = "Displays Date and Source.";
						Type = "boolean";
					};
				};
			};
			{
				Name = "NameOnTop";
				DisplayName = "Name On Top";
				Description = "Write Name property on top.";
				Type = "boolean";
			};
			{
				Name = "IndexingBy";
				DisplayName = "Indexing By";
				Description = "The way indexing will work \"[]\" or by dots; That applies to functions/data types/libraries only and not Instances!";
				Type = "Enum";
				DataComponent = {Brackets=true,Dots=true};
			};
			{
				Name = "Indexing_Instances_By";
				DisplayName = "Indexing Instances By";
				Description = "The way indexing of instances will work: \"[]\" or by dots; That applies to Instances only!";
				Type = "Enum";
				DataComponent = {Brackets=true,Dots=true};
			};
			{
				Name = "NE_PropBreckets";
				DisplayName="Property Brackets [\"\"]?";
				Description="Add [] Brackets to a properties?";
				Type="boolean";
			};
			{
				Name = "VectorLibUse";
				DisplayName = "Vector library";
				Description = "Use of Vector3 or vector library.";
				Type = "Enum";
				DataComponent = {Vector3=true,vector=true};
			};
			{
				Name = "Color3Format";
				DisplayName = "Color3 Format";
				Description = "Format to create constructor of Color3..";
				Type = "Enum";
				DataComponent = {Color3_new=true,Color3_fromRGB=true,Color3_fromHEX=true,Color3_fromHSV=true};
			};
			{
				Name = "CountEnabled";
				DisplayName = "Count (Identical instances)";
				Description = "Depending on code you are converting to will use for loop or _count macro. Instance has to be fully identical!";
				Type = "boolean";
			};
			{
				Name = "Rounding";
				DisplayName = "Rounding";
				Description = "Round number's Precision (CFrame and Vectors)/Numbers (expand tab)";
				Type = "boolean";
				Tree={
					{
						Name = "FuzzyCFrame";
						DisplayName = "FuzzyCFrame";
						Description = "Claiming CFrame to be equal to other but set (10^fraction) aka fraction 5 == 0.00001. Used for compiler in _count and _base.";
						Type = "NumberRange";
						DataComponent = {Min=0,Max=20};
					};
					{
						Name = "Precision";
						DisplayName = "Float Precision Vectors/CFrame";
						Description = "Ammount of floats that may stay.";
						Type = "NumberRange";
						DataComponent = {Min=0,Max=20};
					};
					{
						Name = "All_NumbersRound";
						DisplayName = "Global Number Rounding";
						Description = "Round ALL parsed numbers through constructor.";
						Type = "NumberRange";
						DataComponent = {Min=0,Max=20};
					};
				};
			};
			{
				Name = "CFrameFormatting";
				DisplayName = "CFrame Formatting";
				Description = "Formatting CFrame constructor.";
				Type = "Enum";
				DataComponent = {RawCFrameNew=true,CFrameNewPlusAngles=true,CFrameNewYXZRotation=true;Quaternions=true};
				Tree = {
					{
						Name = "MatrixCFrameMeasurements";
						DisplayName = "Matrix Measurements";
						Description = "Using radians or degrees?";
						Type = "Enum";
						DataComponent = {Radians=true;Degrees=true;Balance=true;Raw=true;};
					};

				};
			};
			{
				Name = "PreferVectorForEmptyRotCFrame";
				DisplayName = "Vector for empty cframe rotation";
				Description = "Use Position if rotation matrix is empty in CFrame.That does ignore \"Ignore properties\" list.";
				Type = "boolean";
			};
			{
				Name = "CodeOutputTextSize";
				DisplayName = "Code Size";
				Description = "Size of text outputed inside Converted Code Tab.";
				Type = "NumberRange";
				DataComponent = {Min=0,Max=150};
			};
			{
				Name="SeparateChildren";
				DisplayName="Separate Children";
				Description="Puts ammount of provided lines to separate children";
				Type="number";
				Tree = {
					{
						Name = "Separate_Advanced";
						DisplayName = "Advanced Separation";
						Description = "Advanced separation. \\t and \\n gets parsed here (\\\\) aswell.";
						Type = "string";
					};
					{
						Name = "SeparatePost_Advanced";
						DisplayName = "Advanced Post Separation";
						Description = "Advanced separation after block with children. \\t and \\n gets parsed here (\\\\) aswell.";
						Type = "string";
					};
				};
			};
			{
				Name="NanConstant";
				DisplayName="Nan constant";
				Description="Nan number (0/0) constant";
				Type="boolean";
				Tree = {
					{
						Name="NanConstant_Name";
						DisplayName="Nan constant Name";
						Description="Nan number (0/0) constant name";
						Type="string";
					};
				};
			};
			{
				Name="ReplacementInstance";
				DisplayName="Replacement Instance";
				Description="Replaces instance class to that if it's classname is not creatable.";
				Type="string";
			};
			{
				Name="OutsideHierarchyInstances";
				DisplayName="Outside hierarchy instances";
				Description="Determines the way we will index instances outside of hierarchy.";
				Type="Enum";
				DataComponent = {
					Index=true;WaitForChild=true;SafeIndex=true;	
				};
				Tree = {
					{
						Name = "SafeIndexNaming";
						DisplayName = "SafeIndexNaming";
						Type="Enum";
						DataComponent = {
							SubtagPlusInstanceNamePlusNumber=true;SubtagPlusNumber=true;
						};
						Tree = {
							{
								Name = "SafeIndexSubtag";
								DisplayName = "SafeIndexSubtag";
								Type = "string";
							};
						};
					};
					
				};
			};
			{
				Name = "Use_Base_Imports";
				DisplayName="_base Imports";
				Description="Should converter use _base Imports?";
				Type="boolean";
				Tree = {
					{
						Name = "Base_Imports_FN_subName";
						DisplayName = "_base Function SubName";
						Description = "For LUAU!";
						Type="string";
					};
					{
						Name = "Use_Base_Properties_MatchPersentage";
						DisplayName="Match Percentage";
						Description="Percentage on ammount that instance should match _base";
						Type="NumberRange";
						DataComponent={Min=0;Max=100;};
					};
				};
			};
			{
				Name="SaveMeshes";
				DisplayName="Save MeshId";
				Description="Determines will MeshId for meshparts gets compiled";
				Type="boolean";
				Tree={
					{
						Name = "MeshPartCreationMode";
						DisplayName = "MeshPart Creation";
						Description="Defered - Returns instance and applies MeshId later.Compute (ClassName/Type/Class field) - Takes more time to create but returns ready product (could be instant if already computed via function)";
						Type = "Enum";
						DataComponent  = {Defered = true;Compute = true;};
						Tree = {
							{
								Name = "AvoiddoubleTextureID";
								DisplayName = "Avoid double TextureID";
								Description = "Avoids setting TextureID 2 times?";
								Type = "boolean";
							};
						};
					};
					{
						Name = "CMPAsyncService";
						DisplayName = "Create MeshPart through:";
						Description="Use AssetService (safer) or InserService?";
						Type = "Enum";
						DataComponent  = {AssetService = true;InsertService = true;};
						Tree = {
							{
								Name = "CMPAsyncService_PassFuildFidility";
								DisplayName = "InsertService FluidFidelity";
								Type = "boolean";
							};
						};
					};
					{
						Name = "UseMeshFunction";
						DisplayName = "Use Mesh Function";
						Description = "Use Mesh function to create MeshId?";
						Type = "boolean";
					};
					{
						Name = "localMeshVariableName";
						DisplayName = "Local Mesh Variable Name";
						Description = "Local Mesh Variable Name - Temporally mesh used to apply MeshId (Not used in RawLuau)";
						Type = "string";
					};
					{
						Name = "SaveMeshes_IncludeFN";
						DisplayName = "Include Function";
						Description="Should converted code contain a function for that to cache MeshId?";
						Type="boolean";
						Tree = {
							{
								Name = "SaveMeshes_FN_Name";
								DisplayName = "Function Name";
								Description="Name of a function.";
								Type="string";
							};
							{
								Name = "SaveMeshes_Cache";
								DisplayName = "Cache meshes";
								Description="Makes table to cache MeshParts.";
								Type="boolean";
								Tree = {
									{
										Name = "CacheTableType";
										DisplayName = "Cache Type";
										Description = "Array or Hash (Enums) type of cache table?";
										Type = "Enum";
										DataComponent  = {Array = true;Hash = true;};
										Tree = {
											{
												Name = "CacheHashTableSpacing";
												DisplayName = "Hash Table Spacing";
												Description = "Format Hash Table?";
												Type = "boolean";
											};
										};
									};
									{
										Name = "SaveMeshes_CacheTableName";
										DisplayName="Cache Table Name";
										Description="Name of hash table that stores cached meshparts.";
										Type = "string";
									};
								};
							};
							
						};
					};	
				};
			};
			{
				Name = "Typechecking";
				DisplayName = "Typechecking";
				Description = "Option to add typecheck where it is possible.";
				Type = "boolean";
				Tree = {
					{
						Name = "TC_Type";
						DisplayName = "SetType";
						Type = "string";
					};
					{
						Name = "TC_Casting";
						DisplayName = "Type Casting";
						Type = "string";
					};
					
				};
			};
			{
				Name="HexademicalString";
				DisplayName="Hex String";
				Description="Mom can we get a string type? No honey we have a string type at home.String type at home:";
				Type="boolean";
			};
			{
				Name = "UnderscoreNumbers";
				DisplayName = "Underscore Numbers";
				Description = "Add _ symbol each x symbols to a number?";
				Type = "boolean";
				Tree = {
					{
						Name = "UnderscoreNumbers_IgnoreFloats";
						DisplayName = "Ignore Floats";
						Description = "Doesn't put \"_\" between floating numbers.";
						Type = "boolean";
					};
					{
						Name = "UnderscoreNumbers_Count";
						DisplayName = "Count";
						Description = "Add \"_\" symbol every x ammount of characters.";
						Type = "NumberRange";
						DataComponent = {Min=1,Max=50};
					};
				};
			};
			{
				Name = "HexNumbers";
				DisplayName = "Hex Numbers";
				Description = "Dude.... WHY!?";
				Type = "boolean";
			};
			{
				Name = "ScientificNotations";
				DisplayName = "Scientific Number Notations";
				Description = "Helps reduce number lengh for example: 0.000001 = 1e-6\nNote that this only applies for \"clear\" numbers to preserve readability.";
				Type = "boolean";
				Tree = {
					{
						Name = "SN_Integer";
						DisplayName = "Integer Exponent";
						Description = "Minimal power of Integer exponent to attempt scientific notation.";
						Type="NumberRange";
						DataComponent={Min=1;Max=100;};
					};
					{
						Name = "SN_Float";
						DisplayName = "Float Exponent";
						Description = "Minimal power of Float exponent to attempt scientific notation.";
						Type="NumberRange";
						DataComponent={Min=1;Max=100;};
					};
				};
			};
			{
				Name = "FriendlyFraction";
				DisplayName = "Friendly Fraction";
				Description = "Turns complex numbers like: 0.333333 into just 1/3";
				Type = "boolean";
				Tree = {
					{
						Name = "Fraction";
						DisplayName = "Fraction Max Force";
						Description = "If its 100 then for example 1/100 is the limit. (expensive and not recomended to put it over 100)";
						Type="NumberRange";
						DataComponent={Min=0;Max=10000000;};
					};
					{
						Name = "FractionMaxInt";
						DisplayName = "Fraction Integer";
						Description = "Basically if number is bigger than x it won't even attempt to create a fraction.";
						Type="NumberRange";
						DataComponent={Min=1;Max=10000000;};
					};
					{
						Name = "FractionThreshold";
						DisplayName = "Fraction Threshold";
						Description = "Ammount of decimals needed to trigger scan. (Make sure it doesnt go higher than Rounding)";
						Type="NumberRange";
						DataComponent={Min=1;Max=10000000;};
					};
				};
			};
			{
				Name="FastNamecall";
				DisplayName="FastNamecalls";
				Description="Option to use cached instance methods and Faster Read/Write techniques.\nMore info: https://devforum.roblox.com/t/3516622";
				Type="boolean";
				Tree = {
					{
						Name = "FNC_SolidModeling";
						DisplayName = "FastNamecall Solid Modeling";
						Description = "Use cached methods with solid modeling?";
						Type = "boolean";
					};
					{
						Name = "FNC_Mesh";
						DisplayName = "FastNamecall Mesh";
						Description = "Use cached methods with mesh creation?";
						Type = "boolean";
					};
					{
						Name = "FNC_Properties";
						DisplayName = "FastNamecall Properties";
						Description = "Dirrectly call propertie's metamethod for Set/Get(Property)?";
						Type = "boolean";
					};
					{
						Name = "FNC_UserData";
						DisplayName = "FastNamecall UserData";
						Description = "Dirrectly call propertie's metamethod for UserData (like cframe mult etc)?";
						Type = "boolean";
					};
					{
						Name = "NC_InsIndex";
						DisplayName = "Instance Index";
						Type = "string";
					};
					{
						Name = "NC_InsSetProperty";
						DisplayName = "Instance Newindex";
						Type = "string";
					};
					{
						Name = "NC_CfrMul";
						DisplayName = "CFrame Multiply";
						Type = "string";
					};
				};
			};
			{
				Name = "UDIM2_MoreConstructors";
				DisplayName = "More UDim2 Constructors";
				Description = "Uses UDim2.fromOffset/fromScale if possible.Strongly recomend to keep this option disabled \n- Yarik_superpro";
				Type = "boolean";
			};
			{
				Name = "t";
				DisplayName = "Tab";
				Description = "Spacing symbol.";
				Type = "Enum";
				DataComponent = {Tab=true;Space=true;Void=true;};
			};
			{
				Name = "WriteRichText";
				DisplayName = "Rich Text";
				Description = "Returns output with color highlightning. If you are serializing a bunch of data 100% worth disabling it.";
				Type = "boolean";
			};
		}
	};
	{
		Name = "Keywords & Operators";
		Content = {
			{
				Name="local";
				DisplayName="local keyword";
				Description="Determines local keyword replacement.";
				Type="string";
			};
			{
				Name="Equal";
				DisplayName="equal keyword";
				Description="Determines \"=\" keyword replacement.";
				Type="string";
			};
			{
				Name="Mult";
				DisplayName="Multiply";
				Description="Determines \"*\" keyword replacement.";
				Type="string";
			};
			{
				Name="Div";
				DisplayName="Divide";
				Description="Determines \"/\" keyword replacement.";
				Type="string";
			};
			{
				Name="FuncSeparator";
				DisplayName="Func Arg Separator";
				Description="Function arguments separator.";
				Type="string";
			};
			{
				Name="TupleSeparator";
				DisplayName="Tuple Separator";
				Description="Tuple separator.";
				Type="string";
			};
			{
				Name="Separator";
				DisplayName="Table Separator";
				Description="Separator for arguments inside tables.";
				Type="string";
			};
			{
				Name = "then";
				DisplayName = "then";
				Description = "then keyword";
				Type = "string";
			};
			{
				Name = "for";
				DisplayName = "for";
				Description = "for keyword";
				Type = "string";
			};
			{
				Name = "in";
				DisplayName = "in";
				Description = "in keyword";
				Type = "string";
			};
			{
				Name = "do";
				DisplayName = "do";
				Description = "do keyword";
				Type = "string";
			};
			{
				Name = "if";
				DisplayName = "if";
				Description = "if keyword";
				Type = "string";
			};
			{
				Name = "end";
				DisplayName = "end";
				Description = "end keyword";
				Type = "string";
			};
			{
				Name = "fbend";
				DisplayName = "function block end";
				Description = "function block end etc: function()--Here";
				Type = "string";
			};
			{
				Name = "or";
				DisplayName = "or";
				Description = "or operator";
				Type = "string";
			};
			{
				Name = "and";
				DisplayName = "and";
				Description = "and operator";
				Type = "string";
			};
			{
				Name = "==";
				DisplayName = "Equal operator";
				Description = "Equal operator";
				Type = "string";
			};
			{
				Name = "break";
				DisplayName = "break";
				Description = "break keyword";
				Type = "string";
			};
			{
				Name = "return";
				DisplayName = "return";
				Description = "return keyword";
				Type = "string";
			};
			{
				Name = "--";
				DisplayName = "--Comment";
				Description = "-- keyword";
				Type = "string";
			};
			{
				Name = "s";
				DisplayName = "Keyword Separator";
				Description = "Spacing symbol to prevent creation of \"returnend\"";
				Type = "string";
			};
		}
	}
}::Types.BuildProperties
