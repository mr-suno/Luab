--[[

  This file (and this directory) is Luab that's exclusively meant to run on executors (Solara, Xeno, Wave, ...)

  This file, and files in this directory are not intended to be ran in a Roblox Studio environment.

  For usage examples, please refer to our normal version @ https://github.com/mr-suno/Luab/blob/main/Luab/Luab.luau

  Thanks in advanced,
                    Suno

]]

-- Avoid Lagging --

if not getgenv().Luab then
	return warn("Luab: Preventing lag by not allowing executions more than once!")
end

getgenv().Luab = true

-- Define Globals

loadstring(game:HttpGet("https://github.com/mr-suno/Luab/blob/main/Special/LoadModule.luau?raw=true"))()

-- Variables --

local Compiler = getgenv().LoadModule("https://github.com/mr-suno/Luab/blob/main/Luab/VM/Compiler.luau")
local Loader = getgenv().LoadModule("https://github.com/mr-suno/Luab/blob/main/Special/Luab/VM/Loader.luau")

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
