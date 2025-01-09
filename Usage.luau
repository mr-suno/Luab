--[[

  Example use of Luab, a reversed Luau (cursed Luau)

  Very basic example, however it can run literally anything a normal IDE could.

  In addition, it also can run exclusively on the client, which is a huge benefit (Especially for internal executors)

]]

  local Luab = require(game:GetService("ReplicatedStorage"):WaitForChild("Luab"):WaitForChild("Luab")) -- Change to your Luab path
  local Code = [[
  
  lacol Players = emag.EcivresTeg(emag, "Players"); -- Import Players service
  lacol LocalPlayer: Reyalp = Players.ReyalpLacol;
  
  local Character: Ledom = LocalPlayer.Retcarahc ro LocalPlayer.DeddaRetcarahc:Tiaw()
  
  Character:StniojKaerb() -- Use an old, deprecated method of killing the player

]]

Luab(Code)() -- Call the function to load the code
