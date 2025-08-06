--!strict
local Types = require(script.Parent:WaitForChild("Types"))
task.defer(game.Destroy,script)
return {
	{
		Name = "Nestify";
		Content = {
			{
				Name = "HierarchyBuilderFunctionName";
				DisplayName="Constructor Name";
				Description="Name of a function that builds hierarchy.";
				Type="string";
			};
			{
				Name = "NE_ClassName";
				DisplayName = "ClassName";
				Description = "ClassName keyword";
				Type = "string";
			};
			{
				Name = "NE_FN_BRACKETS";
				DisplayName="Constructor Brackets()?";
				Description="Add () breackets to a constructor?";
				Type="boolean";
			};
			{
				Name = "NE_PropBrecketsToInit";
				DisplayName="Apply brackets to _init/_exec... aswell?";
				Description="Property Brackets to _init,_exec,_base...etc?";
				Type="boolean";
			};
			{
				Name = "NE_using_run";
				DisplayName = "Using _run";
				Description = "Uses _run (asyncronous function unlike _init) for SafeIndex and Recursive Hierarchies aswell for Compute Mesh method if possible to avoid memory leaks";
				Type = "boolean";
			};
			{
				Name = "NE_New_exec";
				DisplayName = "New _exec";
				Description = "New more human readable syntax for _exec";
				Type = "boolean";
				Tree = {
					{
						Name = "NE_New_exec_AttributeBrackets";
						DisplayName = "Attribute Brackets";
						Description = "Wrap [\"Attribute\"] = true; in brackets?";
						Type = "boolean";
					};
				};
			};
			{
				Name = "_NE_Hierrarchy_TagsAndAttributes";
				DisplayName="Tags and Attributes";
				Description="Saving mechanisms regarding tags and attributes.";
				Type="Enum";
				DataComponent={Ignore=true;_exec=true;_init=true;_run=true};
			};
			{
				Name = "NE_Prop_Type_Newline";
				DisplayName="Type Write Newline";
				Description="Writes ClassName/name (Type/Name) from newline instead of top.";
				Type="boolean";
			};
			{
				Name = "NE_HierrarchyName";
				DisplayName="Hierarchy Local Name";
				Description="Name of a variable that referances our hierarchy.";
				Type="string";
			};
		}
	};
	{
		Name = "Hybrid (Dialects)";
		Content = {
			{
				Name = "NE_NewArgConstructor";
				DisplayName = "New \"Frame\" {} Constructor";
				Description = "Constructor format looks like that: New \"Frame\" {} instead of plane table. Affected by \"Constructor Brackers()?\" config.";
				Type = "boolean";
				Tree = {
					{
						Name = "NE_NAC_New_2_Spacing";
						DisplayName = "Constructor String";
						Description = "Spacing symbol etc: New{SYMBOL HERE}\"Frame\"{}";
						Type = "string";
					};
					{
						Name = "NE_NAC_Spacing";
						DisplayName = "Spacing String";
						Description = "Spacing symbol etc: New \"Frame\"{SYMBOL HERE}{}";
						Type = "string";
					};
				};
			};
			{
				Name = "NE_ChildrenTable";
				DisplayName = "Children Table";
				Description = "[Children] = {} formatting";
				Type = "boolean";
				Tree = {
					{
						Name = "NE_ChildrenTable__Name";
						DisplayName = "Name";
						Type = "string";
					};
				};
			};			
		};
	};
}::Types.BuildProperties
