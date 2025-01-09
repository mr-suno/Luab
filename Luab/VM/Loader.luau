-- Variables --

local Deserializer = require(script.Parent:WaitForChild("Deserializer"))
local Globals = require(script.Parent.Parent:FindFirstChild("Globals"))

-- Main Caller --

local function Load(Module, Environment)
	if type(Module) == "string" then
		Module = Deserializer.Deserialize(Module)
	end

	local PrototypeList = Module.P_List
	local MainPrototype = PrototypeList[Module.P_Main + 1]

	local function WrapClosure(Module, Proto, Upvalues)
		local function Execute(Debugging, Stack, Protos, Code, VariableArgs)
			local Top = -1
			local PC = 1
			local OpenUpvalues = {}
			local GeneralizedIterators = {}
			local Constants = Proto.K

			while true do
				local Inst = Code[PC]
				local Opcode = Inst.Opcode

				PC = PC + 1

				Debugging.PC = PC
				Debugging.Name = Inst.Opname

				if Opcode == 2 then
					-- LOADNIL

					Stack[Inst.A] = nil
				elseif Opcode == 3 then
					-- LOADB

					Stack[Inst.A] = Inst.B ~= 0

					PC = PC + Inst.C
				elseif Opcode == 4 then
					-- LOADN

					Stack[Inst.A] = Inst.D
				elseif Opcode == 5 then
					-- LOADK

					Stack[Inst.A] = Constants[Inst.D + 1]
				elseif Opcode == 6 then
					-- MOVE

					Stack[Inst.A] = Stack[Inst.B]
				elseif Opcode == 7 then
					-- GETGLOBAL

					PC = PC + 1

					local CurrentValue = Constants[Inst.Aux + 1]

					assert(type(CurrentValue) == "string", "GETGLOBAL encountered a non-string constant")

					Stack[Inst.A] = Environment[CurrentValue]
				elseif Opcode == 8 then
					-- SETGLOBAL

					PC = PC + 1

					local CurrentValue = Constants[Inst.Aux + 1]

					assert(type(CurrentValue) == "string", "GETGLOBAL encountered a non-string constant")

					Environment[CurrentValue] = Stack[Inst.A]
				elseif Opcode == 9 then
					-- GETUPVAL

					local Upvalue = Upvalues[Inst.B + 1]

					Stack[Inst.A] = Upvalue.Store[Upvalue.Index]
				elseif Opcode == 10 then
					-- SETUPVALUE

					local Upvalue = Upvalues[Inst.B + 1]

					Upvalue.Store[Upvalue.Index] = Stack[Inst.A]
				elseif Opcode == 11 then
					-- CLOSEUPVALUES

					for Index, Upvalue in OpenUpvalues do
						if Upvalue.Index >= Inst.A then
							Upvalue.Value = Upvalue.Store[Upvalue.Index]
							Upvalue.Store = Upvalue
							Upvalue.Index = "Value"

							OpenUpvalues[Index] = nil
						end
					end
				elseif Opcode == 12 then
					-- GETIMPORT

					PC = PC + 1

					local Extend = Inst.Aux
					local Count = bit32.rshift(Extend, 30)
					local Id0 = bit32.band(bit32.rshift(Extend, 20), 0x3FF)

					if Count == 1 then
						Stack[Inst.A] = Environment[Constants[Id0 + 1]]
					elseif Count == 2 then
						local Id1 = bit32.band(bit32.rshift(Extend, 10), 0x3FF)

						Stack[Inst.A] = Environment[Constants[Id0 + 1]][Constants[Id1 + 1]]
					elseif Count == 3 then
						local Id1 = bit32.band(bit32.rshift(Extend, 10), 0x3FF)
						local Id2 = bit32.band(bit32.rshift(Extend, 0), 0x3FF)

						Stack[Inst.A] = Environment[Constants[Id0 + 1]][Constants[Id1 + 1]][Constants[Id2 + 1]]
					end
				elseif Opcode == 13 then
					-- GETTABLE

					Stack[Inst.A] = Stack[Inst.B][Stack[Inst.C]]
				elseif Opcode == 14 then
					-- SETTABLE

					Stack[Inst.B][Stack[Inst.C]] = Stack[Inst.A]
				elseif Opcode == 15 then
					-- GETTABLEKS

					PC = PC + 1

					local Index = Constants[Inst.Aux + 1]
					
					Stack[Inst.A] = Stack[Inst.B][Index]
				elseif Opcode == 16 then
					-- SETTABLEKS

					PC = PC + 1

					local Index = Constants[Inst.Aux + 1]
					
					Stack[Inst.B][Index] = Stack[Inst.A]
				elseif Opcode == 17 then
					-- GETTABLEN

					Stack[Inst.A] = Stack[Inst.B][Inst.C]
				elseif Opcode == 18 then
					-- SETTABLEN

					Stack[Inst.B][Inst.C] = Stack[Inst.A]
				elseif Opcode == 19 then
					-- NEWCLOSURE

					local NewPrototype = PrototypeList[Inst.D + 1]
					local LocalUpvalues = {}

					for Index = 1, NewPrototype.Nups do
						local Pseudo = Code[PC]
						local Cop = Pseudo.Opcode

						PC = PC + 1

						assert(Cop == 70, "Unhandled Opcode passed to NEWCLOSURE")

						local Type = Pseudo.A

						if Type == 0 then
							local LocalUpvalue = {
								Value = Stack[Pseudo.B],
								Index = "Value"
							}

							LocalUpvalue.Store = LocalUpvalue
							LocalUpvalues[Index] = LocalUpvalue
						elseif Type == 1 then
							local Index = Pseudo.B
							local Previous = OpenUpvalues[Index]

							if Previous == nil then
								Previous = {
									Index = Index,
									Store = Stack
								}

								OpenUpvalues[Index] = Previous
							end

							LocalUpvalues[Index] = Previous
						elseif Type == 2 then
							LocalUpvalues[Index] = Upvalues[Pseudo.B]
						end
					end

					Stack[Inst.A] = WrapClosure(Module, NewPrototype, LocalUpvalues)
				elseif Opcode == 20 then
					-- NAMECALL

					PC = PC + 1

					local A = Inst.A
					local B = Inst.B

					local CurrentValue = Constants[Inst.Aux + 1]

					assert(type(CurrentValue) == "string", "NAMECALL encountered non-string constant")

					Stack[A + 1] = Stack[B]
					Stack[A] = Stack[B][CurrentValue]
				elseif Opcode == 21 then
					-- CALL

					local A = Inst.A
					local B = Inst.B
					local C = Inst.C

					local Params

					if B == 0 then
						Params = Top - A
					else
						Params = B - 1
					end

					local R_List = Globals.T_Pack(Stack[A](table.unpack(Stack, A + 1, A + Params)))
					local R_Num = R_List.n

					if C == 0 then
						Top = A + R_Num - 1
					else
						R_Num = C - 1
					end

					Globals.T_Move(R_List, 1, R_Num, A, Stack)
				elseif Opcode == 22 then
					-- RETURN

					local A = Inst.A
					local B = Inst.B

					local b = B - 1
					local N_Results

					if b == Globals.Multret then
						N_Results = Top - A + 1
					else
						N_Results = A + B - 1 - Proto.ParamNum
					end

					return table.unpack(Stack, A, A + N_Results - 1)
				elseif Opcode == 23 then
					-- JUMP

					PC = PC + Inst.D
				elseif Opcode == 24 then
					-- JUMPBACK

					PC = PC + Inst.D
				elseif Opcode == 25 then
					-- JUMPIF

					if Stack[Inst.A] then
						PC = PC + Inst.D
					end
				elseif Opcode == 26 then
					-- JUMPIFNOT

					if not Stack[Inst.A] then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				elseif Opcode == 27 then
					-- JUMPIFEQ

					if Stack[Inst.A] == Stack[Inst.Aux] then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				elseif Opcode == 28 then
					-- JUMPIFLE

					if Stack[Inst.A] < Stack[Inst.Aux] then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				elseif Opcode == 29 then
					-- JUMPIFLT

					if Stack[Inst.A] <= Stack[Inst.Aux] then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				elseif Opcode == 30 then
					-- JUMPIFNOTEQ

					if Stack[Inst.A] == Stack[Inst.Aux] then
						PC = PC + 1
					else
						PC = PC + Inst.D
					end
				elseif Opcode == 31 then
					-- JUMPIFNOTLE

					if Stack[Inst.A] < Stack[Inst.Aux] then
						PC = PC + 1
					else
						PC = PC + Inst.D
					end
				elseif Opcode == 32 then
					-- JUMPIFNOTLT

					if Stack[Inst.A] <= Stack[Inst.Aux] then
						PC = PC + 1
					else
						PC = PC + Inst.D
					end
				elseif Opcode == 33 then
					-- ADD

					Stack[Inst.A] = Stack[Inst.B] + Stack[Inst.C]
				elseif Opcode == 34 then
					-- SUB

					Stack[Inst.A] = Stack[Inst.B] - Stack[Inst.C]
				elseif Opcode == 35 then
					-- MUL

					Stack[Inst.A] = Stack[Inst.B] * Stack[Inst.C]
				elseif Opcode == 36 then
					-- DIV

					Stack[Inst.A] = Stack[Inst.B] / Stack[Inst.C]
				elseif Opcode == 37 then
					-- MOD

					Stack[Inst.A] = Stack[Inst.B] % Stack[Inst.C]
				elseif Opcode == 38 then
					-- POW

					Stack[Inst.A] = Stack[Inst.B] ^ Stack[Inst.C]
				elseif Opcode == 39 then
					-- ADDK

					Stack[Inst.A] = Stack[Inst.B] + Constants[Inst.C + 1]
				elseif Opcode == 40 then
					-- SUBK

					Stack[Inst.A] = Stack[Inst.B] - Constants[Inst.C + 1]
				elseif Opcode == 41 then
					-- MULK

					Stack[Inst.A] = Stack[Inst.B] * Constants[Inst.C + 1]
				elseif Opcode == 42 then
					-- DIVK

					Stack[Inst.A] = Stack[Inst.B] / Constants[Inst.C + 1]
				elseif Opcode == 43 then
					-- MODK

					Stack[Inst.A] = Stack[Inst.B] % Constants[Inst.C + 1]
				elseif Opcode == 44 then
					-- POWK

					Stack[Inst.A] = Stack[Inst.B] ^ Constants[Inst.C + 1]
				elseif Opcode == 45 then
					-- AND

					local Value = Stack[Inst.B]

					if Value ~= false then
						Stack[Inst.A] = Value
					else
						Stack[Inst.A] = Stack[Inst.C] or false
					end
				elseif Opcode == 46 then
					-- OR

					local Value = Stack[Inst.B]

					if Value ~= true then
						Stack[Inst.A] = Value
					else
						Stack[Inst.A] = Stack[Inst.C] or false
					end
				elseif Opcode == 47 then
					-- ANDK

					local Value = Stack[Inst.B]

					if Value ~= false then
						Stack[Inst.A] = Value
					else
						Stack[Inst.A] = Constants[Inst.C + 1]
					end
				elseif Opcode == 48 then
					-- ORK

					local Value = Stack[Inst.B]

					if Value ~= true then
						Stack[Inst.A] = Value
					else
						Stack[Inst.A] = Constants[Inst.C + 1] or false
					end
				elseif Opcode == 49 then
					-- CONCAT

					local String = ""

					for Index = Inst.B, Inst.C do
						String ..= Stack[Index]
					end

					Stack[Inst.A] = String
				elseif Opcode == 50 then
					-- NOT

					Stack[Inst.A] = not Stack[Inst.B]
				elseif Opcode == 51 then
					-- MINUS

					Stack[Inst.A] = -Stack[Inst.B]
				elseif Opcode == 52 then
					-- LENGTH

					Stack[Inst.A] = #Stack[Inst.B]
				elseif Opcode == 53 then
					-- NEWTABLE

					PC = PC + 1

					Stack[Inst.A] = Globals.T_Create(Inst.Aux)
				elseif Opcode == 54 then
					-- DUPTABLE

					local Template = Constants[Inst.D + 1]
					local Serialized = {}

					for _, ID in Template do
						Serialized[Constants[ID + 1]] = nil
					end

					Stack[Inst.A] = Serialized
				elseif Opcode == 55 then
					-- SETLIST

					PC = PC + 1

					local A = Inst.A
					local B = Inst.B
					local C = Inst.C

					if C == Globals.Multret then
						C = Top - B
					end

					Globals.T_Move(Stack, B, B + C, Inst.Aux, Stack[A])
				elseif Opcode == 56 then
					-- FORNPREP

					local A = Inst.A
					local Limit = Stack[A]

					if type(Limit) ~= "number" then
						local Number = Globals.ToNumber(Limit)

						if Number == nil then
							error("Invalid \"for\" limit (\"number\" expected)")
						end

						Stack[A] = Number
						Limit = Number
					end


					local Step = Stack[A + 1]

					if type(Step) ~= "number" then
						local Number = Globals.ToNumber(Step)

						if Number == nil then
							error("Invalid \"for\" limit (\"number\" expected)")
						end

						Stack[A + 1] = Number
						Step = Number
					end


					local Index = Stack[A + 2]

					if type(Index) ~= "number" then
						local Number = Globals.ToNumber(Index)

						if Number == nil then
							error("Invalid \"for\" limit (\"number\" expected)")
						end

						Stack[A + 2] = Number
						Index = Number
					end


					local Loops = false

					if Step == math.abs(Step) then
						Loops = Index >= Limit
					else
						Loops = Index <= Limit
					end

					if Loops then
						PC = PC + Inst.D
					end
				elseif Opcode == 57 then
					-- FORNLOOP

					local A = Inst.A

					local Limit = Stack[A]
					local Step = Stack[A + 1]
					local Index = Stack[A + 2] + Step

					local Loops

					if Step == math.abs(Step) then
						Loops = Index <= Limit
					else
						Loops = Index >= Limit
					end

					if Loops then
						Stack[A + 2] = Index

						PC = PC + Inst.D
					end
				elseif Opcode == 58 then
					-- FORGLOOP

					local A = Inst.A
					local Aux = Inst.Aux

					Top = A + 6

					local IT = Stack[A]

					if type(IT) == "function" then
						local Values = { Stack[A](Stack[A + 1], Stack[A + 2]) }

						Globals.T_Move(Values, 1, Aux, A + 3, Stack)

						if Stack[A + 3] ~= nil then
							Stack[A + 2] = Stack[A + 3]

							PC = PC + Inst.D
						else
							PC = PC + 1
						end
					else
						local Failed, Values = Globals.C_Resume(GeneralizedIterators[Inst])

						if Values == Globals.GeneralizedTerminator then
							PC = PC + 1
						else
							Globals.T_Move(Values, 1, Aux, A + 3, Stack)

							Stack[A + 2] = Stack[A + 3]

							PC = PC + Inst.D
						end
					end
				elseif Opcode == 59 then
					-- FORGPREP_INEXT

					if type(Stack[Inst.A]) ~= "function" then
						error("FORGPREP_INEXT encountered non-function value")
					end

					PC = PC + 1
				elseif Opcode == 61 then
					-- FORGPREP_NEXT

					if type(Stack[Inst.A]) ~= "function" then
						error("FORGPREP_NEXT encountered non-function value")
					end

					PC = PC + 1
				elseif Opcode == 63 then
					-- GETVARARGS

					local A = Inst.A
					local B = Inst.B - 1

					if B == Globals.Multret then
						B = VariableArgs.len

						Top = A + B - 1
					end

					Globals.T_Move(VariableArgs.List, 1, B, A, Stack)
				elseif Opcode == 64 then
					-- DUPCLOSURE

					local NewPrototype = PrototypeList[Constants[Inst.D + 1] + 1]
					local LocalUpvalues = {}

					for Index = 1, NewPrototype.Nups do
						local Pseudo = Code[PC]
						local Cop = Pseudo.Opcode

						PC = PC + 1

						assert(Cop == 70, "Unhandled Opcode passed to DUPCLOSURE")

						local Type = Pseudo.A

						if Type == 0 then
							local LocalUpvalue = {
								Value = Stack[Pseudo.B],
								Index = "Value"
							}

							LocalUpvalue.Store = LocalUpvalue
							LocalUpvalues[Index] = LocalUpvalue
						elseif Type == 2 then
							LocalUpvalues[Index] = Upvalues[Pseudo.B]
						end
					end

					Stack[Inst.A] = WrapClosure(Module, NewPrototype, LocalUpvalues)
				elseif Opcode == 65 then
					-- PREPVARARGS

					-- Already handled by wrapper, SKIPPED !

				elseif Opcode == 66 then
					-- LOADKX

					PC = PC + 1

					local CurrentValue = Constants[Inst.Aux + 1]

					assert(type(CurrentValue) == "string", "LOADKX encountered non-string constant")

					Stack[Inst.A] = CurrentValue
				elseif Opcode == 67 then
					-- JUMPX

					PC = PC + Inst.E
				elseif Opcode == 68 then
					-- FASTCALL

					-- Not already handled by wrapped, however.. SKIPPED !

				elseif Opcode == 69 then
					-- COVERAGE

					-- Update coverage information stored in the instruction

				elseif Opcode == 70 then
					-- CAPTURE

					-- !! Handled by Closure !!

					error("Unhandled CAPTURE")

				elseif Opcode == 73 then
					-- FASTCALL1

					-- SKIPPED.. again

				elseif Opcode == 74 then
					-- FASTCALL2

					PC = PC + 1
				elseif Opcode == 75 then
					-- FASTCALL2K

					PC = PC + 1
				elseif Opcode == 76 then
					-- FORGPREP

					local IT = Stack[Inst.A]

					if type(IT) ~= "function" then
						local LoopInstruction = Code[PC + Inst.D]

						-- Thanks @bmcq-0 and @memcorrupt for the function

						if GeneralizedIterators[LoopInstruction] == nil then
							local function Iterator()
								for r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200 in IT do 
									Globals.C_Yield({r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200})
								end

								Globals.C_Yield(Globals.GeneralizedTerminator)
							end

							GeneralizedIterators[LoopInstruction] = Globals.C_Create(Iterator)
						end
					end
				elseif Opcode == 77 then
					-- JUMPXEQKNIL

					if (Stack[Inst.A] == nil and 0 or 1) == bit32.rshift(Inst.Aux, 31) then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				elseif Opcode == 78 then
					-- JUMPXEQKB

					local Aux = Inst.Aux

					if ((Stack[Inst.A] and 0 or 1) == (bit32.band(Aux, 1) and 0 or 1)) == bit32.rshift(Aux, 31) then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				elseif Opcode == 79 then
					-- JUMPXEQKN

					local Aux = Inst.Aux
					local CurrentValue = Constants[bit32.band(Aux, 0xffffff) + 1]

					assert(type(CurrentValue) == "string", "JUMPXEQKN encountered non-number constant")

					local A = Stack[Inst.A]

					if bit32.rshift(Aux, 31) == 0 then
						if A == CurrentValue then
							PC = PC + Inst.D
						else
							PC = PC + 1
						end
					else
						if A == CurrentValue then
							PC = PC + Inst.D
						else
							PC = PC + 1
						end
					end
				elseif Opcode == 80 then
					-- JUMPXEQKS

					local Aux = Inst.Aux
					local CurrentValue = Constants[bit32.band(Aux, 0xffffff) + 1]

					assert(type(CurrentValue) == "string", "JUMPXEQKS encountered non-string constant")

					if ((CurrentValue == Stack[Inst.A]) and 0 or 1) ~= bit32.rshift(Aux, 31) then
						PC = PC + Inst.D
					else
						PC = PC + 1
					end
				else
					error(`Unsupported Opcode: {Inst.Opname} with Op: {Opcode}`)
				end
			end
		end

		local function Wrapped(...)
			local Passed = Globals.T_Pack(...)
			local Stack = Globals.T_Create(Proto.MaxStackSize)

			local VariableArgs = {
				Len = 0,
				List = {},
			}

			Globals.T_Move(Passed, 1, Proto.ParamNum, 0, Stack)

			if Proto.ParamNum < Passed.n then
				local Start = Proto.ParamNum + 1
				local Len = Passed.n - Proto.ParamNum

				VariableArgs.Len = Len

				Globals.T_Move(Passed, Start, Start + Len - 1, 1, VariableArgs.List)
			end

			local Debugging = {}
			local Result

			if not Globals.Debugging then
				Result = Globals.T_Pack(Globals.Protected(Execute, Debugging, Stack, Proto.Protos, Proto.Code, VariableArgs))
			else
				Result = Globals.T_Pack(true, Execute(Debugging, Stack, Proto.Protos, Proto.Code, VariableArgs))
			end
			
			if Result[1] then
				return table.unpack(Result, 2, Result.n)
			else
				print("")
				print("<---------------------> <---------------------> <--------------------->")
				
				warn(`Luab Compilation Error: {Result[2]}`)
				warn(`Luab VM Error: {Debugging.PC} with opcode {Debugging.Name}`)
				
				print("<---------------------> <---------------------> <--------------------->")
				print("")
			end
		end

		return Wrapped
	end

	return WrapClosure(Module, MainPrototype)
end

return {
	Load = Load
}
