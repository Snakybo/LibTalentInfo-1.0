# LibTalentTome

A library that can retrieve PvP talent info for any specialization.

## Examples

### Get PvP talent info for a spec

```lua
local LibTalentTome = LibStub("LibTalentTome")

local specs = LibTalentTome:GetClassSpecIDs("WARRIOR")

for i = 1, #specs do
	local specID = specs[i]
	local numTalents = LibTalentTome:GetNumPvPTalentsForSpec(specID, 1)

	for j = 1, numTalents do
		local _, name = LibTalentTome:GetPvPTalentInfo(specID, 1, j)

		print(specID .. ": " .. name)
	end
end
```
