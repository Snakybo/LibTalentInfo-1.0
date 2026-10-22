# LibTalentTome

LibTalentTome is a library for World of Warcraft that provides a simple interface to access information about races, classes, specializations, and talents.

Some of the data provided is accessible using in-game APIs as well, but this provides a (imo) nicer API surface for it. Talent and PvP talent data is not always
available in-game, prior to the `C_Traits` API.

## Supported versions

* Retail (uses `C_Traits` for talents)
* Mists of Pandaria Classic
* The Burning Crusade Anniversary
* Forever (uses `C_Traits` for talents)
* Classic Era

## Limitations

Currently only one limtation is known, the `GetTalentById` API does not work on game versions that use `C_Traits`, as the library doesn't bundle them.

## Getting started

### Dependencies

* [LibStub](https://www.wowace.com/projects/libstub)
* [CallbackHandler-1.0](https://www.wowace.com/projects/callbackhandler)

### Embedding

```yaml
externals:
  Libs/LibStub: https://repos.curseforge.com/wow/libstub/trunk
  Libs/CallbackHandler-1.0: https://repos.curseforge.com/wow/callbackhandler/trunk/CallbackHandler-1.0
  Libs/LibTalentTome:
    url: https://github.com/Snakybo/LibTalentTome

move-folders:
  <ADDON>/Libs/LibTalentTome/LibTalentTome: <ADDON>/Libs/LibTalentTome
```

Replace `<ADDON>` for your addon name, and simply add the libraries to your TOC file.

### Usage

Below is a simple example of what you can do with the library.

```lua
local LibTalentTome = LibStub("LibTalentTome")

for _, class in ipairs(LibTalentTome:GetClasses()) do
	print(class.id, class.fileName, class.name)

	for _, spec in pairs(LibTalentTome:GetSpecializations(class.id)) do
		print(spec.id, spec.name, spec.icon)

		for _, talent in ipairs(LibTalentTome:GetTalents(spec.id)) do
			print(talent.id, talent.spellId, talent.name, talent.icon)
		end
	end
end
```

See [API.md](API.md) for additional documentation.

## Active talents

In addition to static data about talent trees, the library also exposes currently active talents for the player, updated automatically.

There are a few API surfaces available to retrieve this information, or a callback function to receive when they change.

```lua
local LibTalentTome = LibStub("LibTalentTome")

LibTalentTome.RegisterCallback(MyAddon, "ActiveTalentsChanged", function(event, talents)
	for _, talent in ipairs(talents) do
		print(talent.id, talent.spellId, talent.name, talent.icon, talent.rank)
	end
end)

LibTalentTome.RegisterCallback(MyAddon, "ActivePvpTalentsChanged", function(event, talents)
	for _, talent in ipairs(talents) do
		print(talent.id, talent.spellId, talent.name, talent.icon, talent.rank)
	end
end)
```

See [API.md](API.md) for additional documentation.
