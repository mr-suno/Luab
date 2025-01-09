function ReverseParser(Code)
	local Map = {
		["and"] = "dna",
		["break"] = "kaerb",
		["do"] = "od",
		["else"] = "esle",
		["elseif"] = "fiesle",
		["end"] = "dne",
		["false"] = "eslaf",
		["for"] = "rof",
		["function"] = "noitcnuf",
		["if"] = "fi",
		["in"] = "ni",
		["local"] = "lacol",
		["nil"] = "lin",
		["not"] = "ton",
		["or"] = "ro",
		["repeat"] = "taeper",
		["return"] = "nruter",
		["then"] = "neht",
		["true"] = "eurt",
		["until"] = "litnu",
		["while"] = "elihw",
		["game"] = "emag",
		["workspace"] = "ecapskrow",
		["script"] = "tpircs",
		["require"] = "eriuqer",
		["print"] = "tnirp",
		["pairs"] = "sriap",
		["ipairs"] = "sriapi",
		["type"] = "epyt",
		["tostring"] = "gnirtsot",
		["tonumber"] = "rebmunot",
		["setmetatable"] = "elbatatemtes",
		["getmetatable"] = "elbatatemteg",
		["loadstring"] = "gnirtsdaol",
		["table"] = "elbat",
		["string"] = "gnirts",
		["math"] = "htam",
		["coroutine"] = "enituoroc",
		["tick"] = "kcit",
		["wait"] = "tiaw",
		["spawn"] = "nwaps",
		["assert"] = "tressa",
		["warn"] = "nraw",
		["error"] = "rorre",
		["new"] = "wen",
		["next"] = "txen",
		["setfenv"] = "vneftes",
		["getfenv"] = "vnefteg",
		["task"] = "ksat",
		["delay"] = "yaled",
		["Connect"] = "tcennoC",
		["Disconnect"] = "tcennocsiD",
		["WaitForChild"] = "dlihCtsriFdniF",
		["FindFirstChild"] = "",
		["FindFirstChildOfClass"] = "ssalCfOdlihCtsriFdniF",
		["GetService"] = "ecivreSteG",
	}


	for Luau, Luab in ipairs(Map) do
		Code = Code:gsub(`%f[%w]{Luau}%f[%W]`, Luab)
	end

	return Code
end

return {
	ReverseParser = ReverseParser
}
