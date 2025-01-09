# Luab 💦
A reverse-Luau language where everything is programmed in reverse

### Table of Contents
1. **[Luab Rundown](https://github.com/mr-suno/Luab?tab=readme-ov-file#quick-rundown)** ‎ – ‎ Just a _longer introduction_ on what this actually is..
2. **[Sort Order](https://github.com/mr-suno/Luab?tab=readme-ov-file#sort-order)** ‎ – ‎ Explains _what_ is changing, and the difference between Luau and Luab
3. **[Example](https://github.com/mr-suno/Luab?tab=readme-ov-file#luab-vs-luau-)** ‎ – ‎ An actual code example on what Luab would look like compared to Luau
4. **[Installation Guide](https://github.com/mr-suno/Luab?tab=readme-ov-file#installation)** ‎ – ‎ Quick and easy guide on how to setup Luab in your own Roblox Studio environment

---

## Quick Rundown
- Luab is a Luau-based scripting language, identical to Luau, except everything is coded backwards.
- Entirely built in a Luau VM which allows it to be ran in Roblox, or any other Lua environment (Hopefully).
- Luab comes pre-packed with a `.rbxm` _and_ an example file to begin using it in a Roblox environment.

## Sort Order
Luab *reverses* **everything** aside from things you name yourself, like variables, function parameters (and names), etc.
> Strings inside "" (quotes) _stay the same_, however function and callers change.
```lua
game:GetService("Players")  →  emag:Ecivres("Players")
```

## Luab vs. Luau ⚡
```lua
-- An example of defining a function in Luau & Luab

-- Luau --

local function Introduce(Name: string, Age: number): string
  return `Hey! I'm {Name} and I'm {Age} years old.`
end

-- Luab --

lacol noitcnuf Introduce(Name: gnirts, Age: rebmun): gnirts
  nruter `Hey! I'm {Name} and I'm {Age} years old.`
dne
```

## Installation
1. Navigate yourself over to the **[releases page](https://github.com/mr-suno/Luab/releases/latest)** and download the `Luab.rbxm` file.
2. Open **Roblox Studio** and import the `Luab.rbxm` file, then drag it to `ReplicatedStorage` (Preferrably)
3. Create a LocalScript with code similar to **[our example file](https://github.com/mr-suno/Luab/blob/main/Usage.luau)**

And that's it! Luab has been completely set up and is ready to use for production ✅

---

## Extra Credits
Thank you to **[@kosuke14](https://github.com/kosuke14)** and the **[vLuau](https://github.com/kosuke14/vLuau)** project for a stem on virutalizing Luau
