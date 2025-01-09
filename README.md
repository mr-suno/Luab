# Luab 💦
A reverse-Luau language where everything is programmed in reverse

### Table of Contents
1. **[Luab Rundown](https://github.com/mr-suno/Luab?tab=readme-ov-file#quick-rundown)** ‎ – ‎ Just a _longer introduction_ on what this actually is..
2. **[Example](https://github.com/mr-suno/Luab?tab=readme-ov-file#example)** ‎ – ‎ View the difference between pure Luau and Luab

---

## Quick Rundown
- Luab is a Luau-based scripting language, identical to Luau, except everything is coded backwards.
- Entirely built in a Luau VM which allows it to be ran in Roblox, or any other Lua environment (Hopefully).
- Luab comes pre-packed with a `.rbxm` _and_ an example file to begin using it in a Roblox environment.

## Sort Order
Luab *reverses* **everything** aside from things you name yourself, like variables, function parameters (and names), etc.
<br>Example: **game**:**GetService**("Players") → **emag**:**Ecivres**("Players") ← Strings inside "" (quotes) _stay the same_, however function and callers change.

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

---

## Extra Credits
Thank you to **[@kosuke14](https://github.com/kosuke14)** and the **[vLuau](https://github.com/kosuke14/vLuau)** project for a stem on virutalizing Luau
