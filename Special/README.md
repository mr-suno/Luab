# Luab for Executors 💦
A version of Luab modified to be explicitly for Roblox script executors

### Table of Contents
1. **[Luab Rundown](https://github.com/mr-suno/Luab?tab=readme-ov-file#quick-rundown)** ‎ – ‎ Just a _longer introduction_ on what this actually is..
2. **[Example](https://github.com/mr-suno/Luab?tab=readme-ov-file#luab-vs-luau-)** ‎ – ‎ An actual code example on what Luab would look like compared to Luau

Refer to the extended guide in [our main README file](https://github.com/mr-suno/Luab?tab=readme-ov-file#luab-)

---

## Quick Rundown
- Luab is a Luau-based scripting language, identical to Luau, except everything is coded backwards.
- Entirely built in a Luau VM which allows it to be ran in Roblox, or any other Lua environment (Hopefully).
- This directory is exclusive to running the Luab environment in an executor, NOT in Roblox Studio.

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
