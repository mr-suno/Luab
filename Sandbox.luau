local Sandbox = {}
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if not getgenv or not getrenv then
  LocalPlayer:Kick("\n\nThis file shouldn't be ran in this environment!\n\n-\n\nThis file should be *exclusively* used\nby exploit enviroments\n")
end

Sandbox.__index = Sandbox

-- Define Globals

loadstring(game:HttpGet("https://github.com/mr-suno/Luab/blob/main/Special/LoadModule.luau?raw=true"))()

-- Avoid Lagging --

if not getgenv().Luab then
  getgenv().Luab = LoadModule("https://github.com/mr-suno/Luab/blob/main/Special/Luab/Luab.luau")
  
	return warn("-* Luab Global Protection *- Preventing lag by not allowing executions more than once!")
end

-- Sandbox Work --

function Sandbox.New()
	local Environment = {}
	
	setmetatable(Environment, {
		__index = getgenv(),
		__newindex = function(Table, Key, Value)
			rawset(Table, Key, Value)
		end
	})
	
	function Environment.Load(Code)
		assert(type(Code) == "string", `Code should be in a string format, got: {type(Code)}`)

		local Function, Response = loadstring(Code, "Luab")
		
		if not Function then
			error(`-* Luab Sandbox *- {Response}`)
		end
		
		setfenv(Function, Environment)
		
		local Success, Result = pcall(Function)
		
		if not Success then
			error(`-* Luab Sandbox *- {Result}`)
		end
	end
	
	return Environment
end

return Sandbox.New()
