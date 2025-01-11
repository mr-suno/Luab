--[[

    This is in a separate file from `globals.luau`

    because it's just easier to manage

]]

local OP_List = {
	{ "NOP", 0 },
	{ "BREAK", 0 },
	{ "LOADNIL", 1 },
	{ "LOADB", 3 },
	{ "LOADN", 4 },
	{ "LOADK", 4 },
	{ "MOVE", 2 },
	{ "GETGLOBAL", 1, true },
	{ "SETGLOBAL", 1, true },
	{ "GETUPVAL", 2 },
	{ "SETUPVAL", 2 },
	{ "CLOSEUPVALS", 1 },
	{ "GETIMPORT", 4, true },
	{ "GETTABLE", 3 },
	{ "SETTABLE", 3 },
	{ "GETTABLEKS", 3, true },
	{ "SETTABLEKS", 3, true },
	{ "GETTABLEN", 3 },
	{ "SETTABLEN", 3 },
	{ "NEWCLOSURE", 4 },
	{ "NAMECALL", 3, true },
	{ "CALL", 3 },
	{ "RETURN", 2 },
	{ "JUMP", 4 },
	{ "JUMPBACK", 4 },
	{ "JUMPIF", 4 },
	{ "JUMPIFNOT", 4 },
	{ "JUMPIFEQ", 4, true },
	{ "JUMPIFLE", 4, true },
	{ "JUMPIFLT", 4, true },
	{ "JUMPIFNOTEQ", 4, true },
	{ "JUMPIFNOTLE", 4, true },
	{ "JUMPIFNOTLT", 4, true },
	{ "ADD", 3 },
	{ "SUB", 3 },
	{ "MUL", 3 },
	{ "DIV", 3 },
	{ "MOD", 3 },
	{ "POW", 3 },
	{ "ADDK", 3 },
	{ "SUBK", 3 },
	{ "MULK", 3 },
	{ "DIVK", 3 },
	{ "MODK", 3 },
	{ "POWK", 3 },
	{ "AND", 3 },
	{ "OR", 3 },
	{ "ANDK", 3 },
	{ "ORK", 3 },
	{ "CONCAT", 3 },
	{ "NOT", 2 },
	{ "MINUS", 2 },
	{ "LENGTH", 2 },
	{ "NEWTABLE", 2, true },
	{ "DUPTABLE", 4 },
	{ "SETLIST", 3, true },
	{ "FORNPREP", 4 },
	{ "FORNLOOP", 4 },
	{ "FORGLOOP", 4, true },
	{ "FORGPREP_INEXT", 4 },
	{ "LOP_DEP_FORGLOOP_INEXT", 0 },
	{ "FORGPREP_NEXT", 4 },
	{ "LOP_DEP_FORGLOOP_NEXT", 0 },
	{ "GETVARARGS", 2 },
	{ "DUPCLOSURE", 4 },
	{ "PREPVARARGS", 1 },
	{ "LOADKX", 1, true },
	{ "JUMPX", 5 },
	{ "FASTCALL", 3 },
	{ "COVERAGE", 5 },
	{ "CAPTURE", 2 },
	{ "LOP_DEP_JUMPIFEQK", 0 },
	{ "LOP_DEP_JUMPIFNOTEQK", 0 },
	{ "FASTCALL1", 3 },
	{ "FASTCALL2", 3, true },
	{ "FASTCALL2K", 3, true },
	{ "FORGPREP", 4 },
	{ "JUMPXEQKNIL", 4, true },
	{ "JUMPXEQKB", 4, true },
	{ "JUMPXEQKN", 4, true },
	{ "JUMPXEQKS", 4, true },
}

local Extended_OP_List = {}

-- Assigning Values --

for Index, Value in OP_List do
	if Value[3] then
		table.insert(Extended_OP_List, Index)
	end
end

return {
	OP_List = OP_List,
	Extended_OP_List = Extended_OP_List
}
