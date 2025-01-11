getgenv().LoadModule = function(ModuleScript)
    assert(type(ModuleScript) == "string", "ModuleScript should be the script's URL")

    if string.find(ModuleScript, "github.com") then
        ModuleScript = ModuleScript .. "?raw=true"
    end

    local Success, Response = pcall(function()
        game:HttpGet(ModuleScript)
    end)

    if not Success then
        return warn(`Failure loading ModuleScript, Response : {Response}`)
    end

    print(Success, Response, ModuleScript)

    return loadstring(game:HttpGet(ModuleScript))()
end
