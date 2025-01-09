local Debugging = false

-- S_... variables are for Strings
-- T_... variables are for Tables
-- C_... variables are for Coroutines

local S_Unpack = string.unpack

local T_Pack = table.pack
local T_Create = table.create
local T_Move = table.move

local C_Create = coroutine.create
local C_Yield = coroutine.yield
local C_Resume = coroutine.resume

local ToNumber = tonumber
local Protected = pcall

local Multret = -1
local GeneralizedTerminator = -2

function NewModule()
	return {
		S_List = {},
		P_List = {}
	}
end

function NewProto()
	return {
		Code = {},
		K = {},
		Protos = {}
	}
end

return {

	-- Variables

	Debugging = Debugging,

	Multret = Multret,
	GeneralizedTerminator = GeneralizedTerminator,

	-- VM functions

	NewModule = NewModule,
	NewProto = NewProto,

	-- String functions

	S_Unpack = S_Unpack,

	-- Table functions

	T_Pack = T_Pack,
	T_Create = T_Create,
	T_Move = T_Move,

	-- Coroutine functions

	C_Create = C_Create,
	C_Yield = C_Yield,
	C_Resume = C_Resume,

	-- Miscellaneous functions

	Protected = Protected,
	ToNumber = ToNumber

}
