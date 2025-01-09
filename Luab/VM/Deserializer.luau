-- Variables --

local Globals = require(script.Parent.Parent:FindFirstChild("Globals"))
local Opcodes = require(script.Parent.Parent:FindFirstChild("Opcodes"))

-- Main Caller --

local function Deserialize(Bytecode)
	local Position = 1
	local Module = Globals.NewModule()

	local StringList = Module.S_List
	local PrototypeList = Module.P_List

	local function ReadByte()
		local Byte = Globals.S_Unpack(">B", Bytecode, Position)

		Position = Position + 1

		return Byte
	end

	local function ReadInt()
		local Int = Globals.S_Unpack("I4", Bytecode, Position)

		Position = Position + 4

		return Int
	end

	local function ReadVariableInt()
		local Result = 0

		for Index = 0, 7 do
			local Value = ReadByte()

			Result = bit32.bor(Result, bit32.lshift(bit32.band(Value, 0x7F), Index * 7))

			if bit32.band(Value, 0x80) == 0 then
				break
			end
		end

		return Result
	end

	local function ReadString()
		local Size = ReadVariableInt()
		local String

		if Size == 0 then
			return ""
		else
			String = Globals.S_Unpack("c" .. Size, Bytecode, Position)

			Position = Position + Size
		end

		return String
	end

	local function ReadInstruction(Node)
		local Indexes = {}

		local Value = ReadInt()
		local Opcode = bit32.band(Value, 0xFF)

		Indexes.Value = Value
		Indexes.Opcode = Opcode

		local Info = Opcodes.OP_List[Opcode + 1]
		local Optype = Info[2]

		Indexes.Opname = Info[1]
		Indexes.Type = Optype

		local Optype = Indexes.Type

		if Optype == 3 then
			-- ABC

			Indexes.A = bit32.band(bit32.rshift(Value, 8), 0xFF)
			Indexes.B = bit32.band(bit32.rshift(Value, 16), 0xFF)
			Indexes.C = bit32.band(bit32.rshift(Value, 24), 0xFF)
		elseif Optype == 2 then
			-- AB

			Indexes.A = bit32.band(bit32.rshift(Value, 8), 0xFF)
			Indexes.B = bit32.band(bit32.rshift(Value, 16), 0xFF)
		elseif Optype == 1 then
			-- A

			Indexes.A = bit32.band(bit32.rshift(Value, 8), 0xFF)
		elseif Optype == 4 then
			-- AD

			Indexes.A = bit32.band(bit32.rshift(Value, 8), 0xFF)

			local Temporary = bit32.band(bit32.rshift(Value, 16), 0xFFFF)

			-- Do it this way to support lower LuaU versions

			if Temporary < 0x8000 then
				Indexes.D = Temporary
			else
				Indexes.D = Temporary - 0x10000
			end
		elseif Optype == 5 then
			-- AE

			local Temporary = bit32.band(bit32.rshift(Value, 8), 0xFFFFFF)

			if Temporary < 0x800000 then
				Indexes.E = Temporary
			else
				Indexes.E = Temporary - 0x1000000
			end
		end

		if table.find(Opcodes.Extended_OP_List, Opcode + 1) then
			local Aux = ReadInt()

			Indexes.Aux = Aux

			table.insert(Node, Indexes)
			table.insert(Node, {Value = Aux})

			return true
		end

		table.insert(Node, Indexes)

		return false
	end

	local function ReadPrototype()
		local Proto = Globals.NewProto()

		Proto.MaxStackSize = ReadByte()
		Proto.ParamNum = ReadByte()
		Proto.Nups = ReadByte()
		Proto.isVariableArg = ReadByte() ~= 0

		local Node = Proto.Code
		local Size = ReadVariableInt()

		Proto.Size = Size

		local SkipOver = false

		for Index = 1, Size do
			if SkipOver then
				SkipOver = false

				continue
			end

			SkipOver = ReadInstruction(Node)
		end

		local K_List = Proto.K
		local K_Size = ReadVariableInt()

		Proto.K_Size = K_Size

		for Index = 1, K_Size do
			local K_Byte = ReadByte()
			local K

			if K_Byte == 0 then
				K = nil
			elseif K_Byte == 1 then
				K = ReadByte() ~= 0
			elseif K_Byte == 2 then
				local D = Globals.S_Unpack("d", Bytecode, Position)

				Position = Position + 8

				K = D
			elseif K_Byte == 3 then
				K = Module.S_List[ReadVariableInt()]
			elseif K_Byte == 4 then
				K = ReadInt()
			elseif K_Byte == 5 then
				local Data = {}
				local Length = ReadVariableInt()

				for Index = 1, Length do
					table.insert(Data, ReadVariableInt())
				end

				K = Data
			elseif K_Byte == 6 then
				K = ReadVariableInt()
			end

			table.insert(K_List, K)
		end

		local P_Size = ReadVariableInt()
		local ProtoList = Proto.Protos

		Proto.P_Size = P_Size

		for Index = 1, P_Size do
			table.insert(ProtoList, ReadVariableInt())
		end

		ReadVariableInt()
		ReadVariableInt()

		if ReadByte() ~= 0 then
			local Gap = ReadByte()

			for Index = 1, Size do
				ReadByte()
			end

			local Intervals = bit32.rshift(Size - 1, Gap) + 1

			for Index = 1, Intervals do
				ReadInt()
			end
		end

		if ReadByte() ~= 0 then
			local IntSize = ReadVariableInt()

			for Index = 1, IntSize do
				ReadVariableInt()
				ReadVariableInt()
				ReadVariableInt()

				ReadByte()
			end
		end

		return Proto
	end

	local LuauVersion = ReadByte()

	if LuauVersion ~= 3 then
		error("Invalid Bytecode Provided", 0)
	end


	local StringCount = ReadVariableInt()

	for Index = 1, StringCount do
		table.insert(StringList, ReadString())
	end


	local ProtoCount = ReadVariableInt()

	for Index = 1, ProtoCount do
		table.insert(PrototypeList, ReadPrototype())
	end


	Module.P_Main = ReadVariableInt()

	assert(Position == #Bytecode + 1, "Deserializer Invalid Position (Mismatch)")

	return Module
end

return {
	Deserialize = Deserialize
}
