--!strict
local Types = require(script.Parent:WaitForChild("Types"))
task.defer(game.Destroy,script)
return {
	{
		Name = "Luau";
		Content = {
			{
				Name = "RL_WrapPropDoEnd";
				DisplayName = "Wrap Prop in Do End";
				Description = "Wraps property construction inside do end (should not affect bytecode in most cases so its safe to use)";
				Type = "boolean";
				Tree = {
					{
						Name = "RL_WrapSafeIndexDoEnd";
						DisplayName = "SafeIndex in do end";
						Description = "Wraps safeindex variables inside do end";
						Type = "boolean";
					};
				};
			};
			{
				Name = "RL_RecursionWrite";
				DisplayName = "Write Recursion";
				Description = "Instant = assigns recursion referance after initiation of it. InTheEnd = assigns recursion referance in the end of code after everything is initiated. Hybrid = assigns values if they exist in the code below/and or are referancing itself otherwise acts like InTheEnd.";
				Type = "Enum";
				DataComponent = {Instant=true;InTheEnd=true;Hybrid=true;}
			};
			{
				Name = "RegisterLimit";
				DisplayName = "Register Limit";
				Description = "Ammount of local variables allowed; If runs out of local variables in stack then it will create a closure (function() end)()";
				Type = "number";
				Tree = {
					{
						Name = "StartRegisterCount";
						DisplayName = "Register Count On Start";
						Description = "Ammount of registers you get on start.";
						Type = "number";
					};
					{
						Name = "ClosureSeparator";
						DisplayName = "Closure Separator";
						Description = "Closure Separator symbol to prevent linting. (supports \\n and \\t parsing)";
						Type = "string";
					};
				};
			};
			{
				Name = "RL_Compile_baseFunctions";
				DisplayName = "Compile _base functions";
				Description = "Requires base imports to be enabled.";
				Type = "boolean";
			};
			{
				Name = "RL_Deffered_Fn_Mesh";
				DisplayName = "Deffered Mesh Function Name";
				Description = "Name of a function used in defered mesh creation mode.";
				Type = "string";
				Tree = {
					{
						Name = "RL_DFM_Include";
						DisplayName = "Include?";
						Description = "Defines function on top.";
						Type = "boolean";
					};
				};
			};
			{
				Name = "RL_Referanceless";
				DisplayName = "Referanceless ,Parent";
				Description = "Ability to create Instance.new() without referance and ability to use 2nd argument";
				Type = "boolean";
			};
			{
				Name = "RL_AttributesTags";
				DisplayName = "Attributes & Tags";
				Description = "Should save attributes and tags?";
				Type = "boolean";
			};
		}
	};
}::Types.BuildProperties
