--[[

    !! This is basically just our `init.luau` file !!

    --

    Luab - A reversed Luau scripting language that works exactly the same as Luau.

    Luau (lowercase u) is a Custom Lua Language developed and maintained by Roblox. (Similar to Lua 5.1)

    --

    Update:
            Jan. 9th, 2024:
                - Upload the project and begin on the Luau Virtual Machine

    --

    Thank you vLuau for the stem of the VM, without this project I would not have been able to make this as

    .. quickly as I did with it.

    --

    Luab written and developed with love, by Suno. ❤️

    --

    Usage:
            local Luab = require(Path) -- Change "Path" to the path of Luab

            Luab(<string:(Source of Bytecode)>[, table:Environment, string:Chunk]): function -- Directly execute Luab code, Luau will not be executed !

            Luab.Execute(...) -- Same as directly calling it

            Luab.Compile(<string:Source>[, table:Environment]): string -- Compiles code and returns equivalent bytecode

            Luab.Load(<string:Bytecode>[, tabel:Environment]): function -- Build function (Requires Bytecode)

            
    Example:
              Luab("tnirp('Hello, world from Luab VM !')")() -- OUTPUT: "Hello, world ..."

              Luab("Hey", nil, "MyScript")() -- ERROR: MyScript:1: Incomplete statement: expected assignment or a function call

]]

-- Variables --

local VM = script.Parent:WaitForChild("VM")

local Compiler = require(VM:WaitForChild("Compiler"))
local Loader = require(VM:WaitForChild("Loader"))

-- Functions --

local function isLuauBytecode(Bytecode)
	return string.unpack(">B", Bytecode, 1) == 3
end

local function Compile(Source, Chunk)
	local Success, Bytecode = Compiler.Compile(Source)

	return Success == true and Bytecode or error((Chunk or "Luab") .. Bytecode:sub(2), 0) -- Stack level is 0, for debugging purposes
end

local function Load(Bytecode, Environment)
	assert(isLuauBytecode(Bytecode), "Luab: Param. #1 has invalid bytecode. (V3 Bytecode Expected)")
	assert(type(Environment) == "table" or Environment == nil, `Luab: Param. #2 found "{typeof(Environment)}" ("table" Expected)`)

	return Loader.Load(Bytecode, Environment or getfenv(2))
end

-- Finalizing --

return setmetatable({
	Compile = Compile,
	Load = Load,

	Execute = function(Source, Environment, Chunk)
		if isLuauBytecode(Source) then
			return Load(Source, Environment)
		end

		return Load(Compile(Source, Chunk), Environment or getfenv(2))
	end,

	NewEnvironment = function(Environment)
		local Function = getfenv(2)
		local Local = setmetatable({}, {
			__index = function(self, Value)
				return Environment[Value] or Function[Value]
			end,
		})

		return Local
	end,
}, {
	__call = function(self, Source, Environment, Chunk)
		return self.Execute(Source, Environment or getfenv(2), Chunk)
	end,
})
