--!strict
local ssData = require(script.Parent:WaitForChild("ss"))
local ss = ssData.ss
local strMaxSize:number = 199_999;

local function Extract(self:class):{string}
	local buff:buffer = self.b
	local len:number = self.len
	local n:number = math.ceil(len/strMaxSize)
	local res:{string} = table.create(n)::{string}
	for i = 0,n - 1 do
		local offset = i * strMaxSize
		local size = math.min(strMaxSize,len-offset)
		res[i+1] = buffer.readstring(buff,offset,size)
	end
	return res
end

type classData = {
	b:buffer;
	len:number;
	Extract:typeof(Extract);
}
local metatable = {
	__concat = function(self:class,str:string):class
		buffer.writestring(self.b,self.len,str)
		self.len+=#str
		return self
	end;
}

local FakeMetatable = {
	__concat = function(self:class,str:string):class
		return self
	end;
}

export type class = typeof(setmetatable({}::classData, metatable))

--returns a long string
return function(fake:boolean?):class
	if fake==true then
		return setmetatable({
			b = buffer.create(0);
			len = 0;
			Extract = Extract;
		}::classData,FakeMetatable)::class
	end
	return setmetatable({
		b = buffer.create(ss.BuffSize::number);
		len = 0;
		Extract = Extract;
	}::classData,metatable)::class
end








