# LibTalentTome API

```lua
local LibTalentTome = LibStub("LibTalentTome")
```

* All functions are called with `:` syntax.
* Returned tables are copies, so they are safe to modify.
* Names (race, class, specialization, talent) are localized to the client's locale.

## Contents

* [Data availability](#data-availability)
* [Types](#types)
* [Races](#races)
* [Classes](#classes)
* [Specializations](#specializations)
* [Talents](#talents)
* [PvP talents](#pvp-talents)
* [Providers](#providers)

## Data availability

| Game version                    | Races | Classes | Specializations | Talents | PvP talents | `C_Traits` API |
| ------------------------------- | :---: | :-----: | :-------------: | :-----: | :---------: | :------------: |
| Retail                          | Yes   | Yes     | Yes             | Yes     | Yes         | Yes            |
| Mists of Pandaria Classic       | Yes   | Yes     | Yes             | Yes     |             |                |
| The Burning Crusade Anniversary | Yes   | Yes     | Yes             | Yes     |             |                |
| Forever                         | Yes   | Yes     | Yes             | Yes     |             |                |
| Classic Era                     | Yes   | Yes     | Yes             | Yes     |             |                |

On game versions that use `C_Traits`, talents are read from the game at runtime instead of being bundled with the library. This has two consequences:

* [`GetTalentById`](#gettalentbyid) is not supported and raises an error.
* The talent `id` is the talent's spell ID.

## Types

### LibTalentTome.Race

| Field      | Type      | Description                                          |
| ---------- | --------- | ---------------------------------------------------- |
| `id`       | `integer` | The unique identifier for the race.                  |
| `fileName` | `string`  | The `clientFileString` associated with the race.     |
| `name`     | `string`  | The localized name of the race.                      |

### LibTalentTome.Class

| Field      | Type        | Description                                       |
| ---------- | ----------- | ------------------------------------------------- |
| `id`       | `integer`   | The unique identifier for the class.              |
| `name`     | `string`    | The localized name of the class.                  |
| `fileName` | `ClassFile` | The `classFileName` associated with the class.    |

### LibTalentTome.Specialization

| Field      | Type       | Description                                                                                            |
| ---------- | ---------- | ------------------------------------------------------------------------------------------------------ |
| `id`       | `integer`  | The unique identifier for the specialization.                                                          |
| `icon`     | `integer`  | The icon representing the specialization.                                                              |
| `initial`  | `boolean?` | Whether this specialization is the [initial specialization](#getinitialspecialization), if applicable. |
| `name`     | `string`   | The localized name of the specialization.                                                              |

The initial spec indicates the default specialization for a class, when the player hasn't unlocked the talent tree yet and is unable to select a talent specialization.

### LibTalentTome.Talent

Used for both talents and PvP talents.

| Field     | Type      | Description                                   |
| --------- | --------- | --------------------------------------------- |
| `id`      | `integer` | The unique identifier for the talent.         |
| `spellId` | `integer` | The spell ID associated with the talent.      |
| `icon`    | `integer` | The icon representing the talent.             |
| `name`    | `string`  | The localized name of the talent.             |

## Races

### GetNumRaces

```lua
LibTalentTome:GetNumRaces(): integer
```

Get the number of races available.

This includes all races, which can include duplicates, e.g. Pandaren has a neutral, Horde, and Alliance variant, represented as three distinct races. To only count unique races, use [`GetNumUniqueRaces`](#getnumuniqueraces).

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local numRaces = LibTalentTome:GetNumRaces()
```

### GetNumUniqueRaces

```lua
LibTalentTome:GetNumUniqueRaces(): integer
```

Get the number of unique races available.

Unlike [`GetNumRaces`](#getnumraces), this counts only unique race entries, filtering by the `clientFileString` property.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local numUniqueRaces = LibTalentTome:GetNumUniqueRaces()
```

### GetRaces

```lua
LibTalentTome:GetRaces(): LibTalentTome.Race[]
```

Get all available races in the game.

This includes all races, which can include duplicates, e.g. Pandaren has a neutral, Horde, and Alliance variant, represented as three distinct races. To only get unique races, use [`GetUniqueRaces`](#getuniqueraces).

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
for _, race in ipairs(LibTalentTome:GetRaces()) do
	print(race.id, race.fileName, race.name)
end
```

### GetUniqueRaces

```lua
LibTalentTome:GetUniqueRaces(): LibTalentTome.Race[]
```

Get all unique races in the game.

Unlike [`GetRaces`](#getraces), this retrieves only unique race entries, filtering by the `clientFileString` property.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
for _, race in ipairs(LibTalentTome:GetUniqueRaces()) do
	print(race.fileName, race.name)
end
```

## Classes

### GetNumClasses

```lua
LibTalentTome:GetNumClasses(): integer
```

Get the number of classes available in the game.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local numClasses = LibTalentTome:GetNumClasses()
```

### GetClasses

```lua
LibTalentTome:GetClasses(): LibTalentTome.Class[]
```

Get all classes available in the game, sorted by class ID.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
for _, class in ipairs(LibTalentTome:GetClasses()) do
	print(class.id, class.fileName, class.name)
end
```

### GetClassByName

```lua
LibTalentTome:GetClassByName(classFileName: ClassFile): LibTalentTome.Class?
```

Get a class by its `classFileName`, e.g. `"WARRIOR"`. Returns `nil` if the class does not exist.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local class = LibTalentTome:GetClassByName("WARRIOR")
print(class.id, class.name)
```

### GetClassById

```lua
LibTalentTome:GetClassById(classId: integer): LibTalentTome.Class?
```

Get a class by its unique identifier. Returns `nil` if the class does not exist.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local class = LibTalentTome:GetClassById(1)
print(class.fileName, class.name)
```

## Specializations

Functions that take a `classId` also accept a `classFileName` (e.g. `"WARRIOR"`) or a [`LibTalentTome.Class`](#libtalenttomeclass) in its place.

### GetNumSpecializations

```lua
LibTalentTome:GetNumSpecializations(classId: integer): integer
LibTalentTome:GetNumSpecializations(classFileName: string): integer
LibTalentTome:GetNumSpecializations(class: LibTalentTome.Class): integer
```

Get the number of specializations available for the given class. Returns `0` if the class does not exist.

This excludes the [initial specialization](#getinitialspecialization).

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local numSpecializations = LibTalentTome:GetNumSpecializations("WARRIOR")
```

### GetSpecializations

```lua
LibTalentTome:GetSpecializations(classId: integer): LibTalentTome.Specialization[]
LibTalentTome:GetSpecializations(classFileName: string): LibTalentTome.Specialization[]
LibTalentTome:GetSpecializations(class: LibTalentTome.Class): LibTalentTome.Specialization[]
```

Get all available specializations for the given class. Returns an empty table if the class does not exist.

This excludes the [initial specialization](#getinitialspecialization).

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local class = LibTalentTome:GetClassByName("WARRIOR")

for _, spec in ipairs(LibTalentTome:GetSpecializations(class)) do
	print(spec.id, spec.name)
end
```

### GetSpecializationAt

```lua
LibTalentTome:GetSpecializationAt(classId: integer, index: integer): LibTalentTome.Specialization?
LibTalentTome:GetSpecializationAt(classFileName: string, index: integer): LibTalentTome.Specialization?
LibTalentTome:GetSpecializationAt(class: LibTalentTome.Class, index: integer): LibTalentTome.Specialization?
```

Get the specialization at the given index, for the given class. Returns `nil` if there is no specialization at that index.

The index matches the game's specialization index. On game versions that have an [initial specialization](#getinitialspecialization), it is located at index `5`.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)
print(spec.id, spec.name)
```

### GetSpecializationById

```lua
LibTalentTome:GetSpecializationById(id: integer): LibTalentTome.Specialization?
```

Get the specialization with the given ID. Returns `nil` if the specialization does not exist.

This includes the [initial specialization](#getinitialspecialization).

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationById(71)
print(spec.name)
```

### GetInitialSpecialization

```lua
LibTalentTome:GetInitialSpecialization(classId: integer): LibTalentTome.Specialization?
LibTalentTome:GetInitialSpecialization(classFileName: string): LibTalentTome.Specialization?
LibTalentTome:GetInitialSpecialization(class: LibTalentTome.Class): LibTalentTome.Specialization?
```

Get the initial specialization for the given class. The initial specialization is the one a character starts as before they unlock talents.

Only Retail and Mists of Pandaria Classic have initial specializations. Returns `nil` on other game versions, or if the class does not exist.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetInitialSpecialization("WARRIOR")
print(spec.id, spec.name)
```

## Talents

Functions that take a `specId` also accept a [`LibTalentTome.Specialization`](#libtalenttomespecialization) in its place.

### GetNumTalents

```lua
LibTalentTome:GetNumTalents(specId: integer): integer
LibTalentTome:GetNumTalents(spec: LibTalentTome.Specialization): integer
```

Get the number of talents available for the given specialization.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)
local numTalents = LibTalentTome:GetNumTalents(spec)
```

### GetTalents

```lua
LibTalentTome:GetTalents(specId: integer): LibTalentTome.Talent[]
LibTalentTome:GetTalents(spec: LibTalentTome.Specialization): LibTalentTome.Talent[]
```

Get all talents available for the given specialization. Returns an empty table if the specialization has no talents.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)

for _, talent in ipairs(LibTalentTome:GetTalents(spec)) do
	print(talent.id, talent.name)
end
```

### GetTalentAt

```lua
LibTalentTome:GetTalentAt(specId: integer, index: integer): LibTalentTome.Talent?
LibTalentTome:GetTalentAt(spec: LibTalentTome.Specialization, index: integer): LibTalentTome.Talent?
```

Get the talent at the given index for the given specialization. Returns `nil` if there is no talent at that index.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)
local talent = LibTalentTome:GetTalentAt(spec, 1)
print(talent.id, talent.name)
```

### GetTalentById

```lua
LibTalentTome:GetTalentById(id: integer): LibTalentTome.Talent?
```

Get the talent with the given ID. Returns `nil` if the talent does not exist.

> [!WARNING]
> This function does not work on game versions that use `C_Traits` (see [Data availability](#data-availability)). Talents are not bundled with the library on those versions, so they cannot be looked up by ID. Calling it there raises an error.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local talent = LibTalentTome:GetTalentById(23)
print(talent.spellId, talent.name)
```

## PvP talents

PvP talents are currently only available on Retail. On other game versions these functions return `0`, an empty table, or `nil`.

Functions that take a `specId` also accept a [`LibTalentTome.Specialization`](#libtalenttomespecialization) in its place.

### GetNumPvpTalents

```lua
LibTalentTome:GetNumPvpTalents(specId: integer): integer
LibTalentTome:GetNumPvpTalents(spec: LibTalentTome.Specialization): integer
```

Get the number of PvP talents available for the given specialization.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)
local numPvpTalents = LibTalentTome:GetNumPvpTalents(spec)
```

### GetPvpTalents

```lua
LibTalentTome:GetPvpTalents(specId: integer): LibTalentTome.Talent[]
LibTalentTome:GetPvpTalents(spec: LibTalentTome.Specialization): LibTalentTome.Talent[]
```

Get all PvP talents available for the given specialization. Returns an empty table if the specialization has no PvP talents.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)

for _, talent in ipairs(LibTalentTome:GetPvpTalents(spec)) do
	print(talent.id, talent.name)
end
```

### GetPvpTalentAt

```lua
LibTalentTome:GetPvpTalentAt(specId: integer, index: integer): LibTalentTome.Talent?
LibTalentTome:GetPvpTalentAt(spec: LibTalentTome.Specialization, index: integer): LibTalentTome.Talent?
```

Get the PvP talent at the given index for the given specialization. Returns `nil` if there is no PvP talent at that index.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local spec = LibTalentTome:GetSpecializationAt("WARRIOR", 1)
local talent = LibTalentTome:GetPvpTalentAt(spec, 1)
print(talent.id, talent.name)
```

### GetPvpTalentById

```lua
LibTalentTome:GetPvpTalentById(id: integer): LibTalentTome.Talent?
```

Get the PvP talent with the given ID. Returns `nil` if the PvP talent does not exist.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
local talent = LibTalentTome:GetPvpTalentById(3529)
print(talent.spellId, talent.name)
```

## Providers

The data for each game version is supplied by a provider. The bundled providers register themselves automatically, so you generally don't need to use this.

### SetProvider

```lua
LibTalentTome:SetProvider(provider: LibTalentTome.Provider)
```

Set the data provider for the library, generally only used internally by the bundled providers.

The provider is only replaced if `provider.build` is greater than the build of the current provider. Replacing the provider clears all cached data.

#### Example

```lua
local LibTalentTome = LibStub("LibTalentTome")
LibTalentTome:SetProvider({
	-- Must be higher than the build of the currently registered provider, or this call is ignored.
	build = 80000,
	races = { [1] = "Human" },
	classes = { ["WARRIOR"] = 1 },
	specializations = {
		[1] = {
			[1] = { id = 71, icon = 132355 },
		},
	},
	talents = {},
	pvpTalents = {},
})
```

### LibTalentTome.Provider

| Field             | Type                                                                | Description                                                                          |
| ----------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `build`           | `integer`                                                           | The data build. A provider with a higher build replaces one with a lower build.      |
| `races`           | `table<integer, string>`                                            | Race ID to `clientFileString`.                                                       |
| `classes`         | `table<string, integer>`                                            | `classFileName` to class ID.                                                         |
| `specializations` | `table<integer, table<integer, LibTalentTome.SpecializationId>>`    | Class ID to specializations, keyed by specialization index.                          |
| `talents`         | `table<integer, LibTalentTome.TalentId[]>`                          | Specialization ID to talents. Unused on game versions that use `C_Traits`.           |
| `pvpTalents`      | `table<integer, LibTalentTome.TalentId[]>`                          | Specialization ID to PvP talents.                                                    |

`LibTalentTome.SpecializationId` and `LibTalentTome.TalentId` are the same as [`LibTalentTome.Specialization`](#libtalenttomespecialization) and [`LibTalentTome.Talent`](#libtalenttometalent), without the localized `name` field.
