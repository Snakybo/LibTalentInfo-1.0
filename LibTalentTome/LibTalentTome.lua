-- MIT License
--
-- Copyright (c) 2026 Kevin Krol
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

--- @class LibTalentTome.Provider
--- @field public build integer
--- @field public races table<integer, string>
--- @field public classes table<string, integer>
--- @field public specializations table<integer, table<integer, LibTalentTome.SpecializationId>>
--- @field public talents table<integer, LibTalentTome.TalentId[]>
--- @field public pvpTalents table<integer, LibTalentTome.TalentId[]>

--- @class LibTalentTome.SpecializationId
--- @field public id integer       -- The unique identifier for the specialization.
--- @field public icon integer     -- The icon representing the specialization.
--- @field public initial? boolean -- Whether this specialization is the initial specialization, if applicable.

--- @class LibTalentTome.TalentId
--- @field public id integer      -- The unique identifier for the talent.
--- @field public spellId integer -- The spell ID associated with the talent.
--- @field public icon integer    -- The icon representing the talent.

--- @class LibTalentTome.Race
--- @field public id integer      -- The unique identifier for the race.
--- @field public fileName string -- The `clientFileString` associated with the race.
--- @field public name string     -- The localized name of the race.

--- @class LibTalentTome.Class
--- @field public id integer         -- The unique identifier for the class.
--- @field public name string        -- The localized name of the class.
--- @field public fileName ClassFile -- The `classFileName` associated with the class.

--- @class LibTalentTome.Specialization : LibTalentTome.SpecializationId
--- @field public name string -- The localized name of the specialization.

--- @class LibTalentTome.Talent : LibTalentTome.TalentId
--- @field public name string -- The localized name of the talent.

if LibStub == nil then
	error("LibTalentTome requires LibStub")
end

--- @class LibTalentTome
--- @field private provider LibTalentTome.Provider?
local LibTalentTome = LibStub:NewLibrary("LibTalentTome", 1)
if LibTalentTome == nil then
	return
end

local cache = {
	--- @type integer?
	numClasses = nil,

	--- @type integer?
	numRaces = nil,

	--- @type integer?
	numUniqueRaces = nil,

	--- @type table<integer, integer>
	numSpecializations = {},

	--- @type table<integer, integer>
	numTalents = {},

	--- @type table<integer, LibTalentTome.Race>
	races = {},

	--- @type table<integer, LibTalentTome.Race>
	uniqueRaces = {},

	--- @type LibTalentTome.Class[]
	classes = {},

	--- @type table<integer, LibTalentTome.Specialization[]>
	specializations = {},

	--- @type table<integer, integer>
	specializationClassMap = {},

	--- @type table<integer, LibTalentTome.Talent[]>
	talents = {},

	--- @type table<integer, integer>
	talentSpecializationMap = {},

	--- @type table<integer, LibTalentTome.Talent[]>
	pvpTalents = {},

	--- @type table<integer, integer>
	pvpTalentSpecializationMap = {}
}

local isTraitSystemAvailable = C_ClassTalents ~= nil and C_ClassTalents.InitializeViewLoadout ~= nil

local function ClearCache()
	cache.numClasses = nil
	cache.numRaces = nil
	cache.numUniqueRaces = nil

	wipe(cache.numSpecializations)
	wipe(cache.numTalents)
	wipe(cache.races)
	wipe(cache.uniqueRaces)
	wipe(cache.classes)
	wipe(cache.specializations)
	wipe(cache.specializationClassMap)
	wipe(cache.talents)
	wipe(cache.talentSpecializationMap)
	wipe(cache.pvpTalents)
	wipe(cache.pvpTalentSpecializationMap)
end

--- Set the data provider for the library, generally only used internally by the bundled providers.
---
--- @param provider LibTalentTome.Provider
function LibTalentTome:SetProvider(provider)
	assert(type(provider) == "table", "bad argument #1: expected table, got " .. type(provider))

	if self.provider ~= nil and provider.build <= self.provider.build then
		return
	end

	self.provider = provider
	ClearCache()
end

--- Get the number of races available.
---
--- This includes all races, which can include duplicates, e.g. Pandaren has a neutral, Horde, and Alliance variant, represented as three distinct races.
--- To only count unique races, use `GetNumUniqueRaces`.
---
--- @return integer
function LibTalentTome:GetNumRaces()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")


	if cache.numRaces ~= nil then
		return cache.numRaces
	end

	local races = self:GetRacesInternal(false)
	local result = 0

	for _ in pairs(races) do
		result = result + 1
	end

	cache.numRaces = result
	return result
end

--- Get the number of unique races available.
---
--- Unlike `GetNumRaces`, this counts only unique race entries, filtering by the `clientFileString` property.
---
--- @return integer
function LibTalentTome:GetNumUniqueRaces()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if cache.numUniqueRaces ~= nil then
		return cache.numUniqueRaces
	end

	local races = self:GetRacesInternal(true)
	local result = 0

	for _ in pairs(races) do
		result = result + 1
	end

	cache.numUniqueRaces = result
	return result
end

--- Get all available races in the game.
---
--- This includes all races, which can include duplicates, e.g. Pandaren has a neutral, Horde, and Alliance variant, represented as three distinct races.
--- To only get unique races, use `GetUniqueRaces`.
---
--- @return LibTalentTome.Race[]
function LibTalentTome:GetRaces()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	return CopyTable(self:GetRacesInternal(false))
end

--- Get all unique races in the game.
---
--- Unlike `GetRaces`, this retrieves only unique race entries, filtering by the `clientFileString` property.
---
--- @return LibTalentTome.Race[]
function LibTalentTome:GetUniqueRaces()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	return CopyTable(self:GetRacesInternal(true))
end

--- Get the number of classes available in the game.
---
--- @return integer
function LibTalentTome:GetNumClasses()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if cache.numClasses ~= nil then
		return cache.numClasses
	end

	local classes = self:GetClassesInternal()
	local result = 0

	for _ in pairs(classes) do
		result = result + 1
	end

	cache.numClasses = result
	return result
end

--- Get all classes available in the game.
---
--- @return LibTalentTome.Class[]
function LibTalentTome:GetClasses()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	return CopyTable(self:GetClassesInternal())
end

--- Get a class by its `classFileName`.
---
--- @param classFileName ClassFile
--- @return LibTalentTome.Class?
function LibTalentTome:GetClassByName(classFileName)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	local classes = self:GetClassesInternal()

	for i = 1, #classes do
		if classes[i].fileName == classFileName then
			return CopyTable(classes[i])
		end
	end

	return nil
end

--- Get a class by its unique identifier.
---
--- @param classId integer
--- @return LibTalentTome.Class?
function LibTalentTome:GetClassById(classId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	local classes = self:GetClassesInternal()

	for i = 1, #classes do
		if classes[i].id == classId then
			return CopyTable(classes[i])
		end
	end

	return nil
end

--- Get the number of specializations available for the given class.
---
--- This excludes the initial specialization.
---
--- @param classId integer
--- @return integer
--- @overload fun(classFileName: string): integer
--- @overload fun(class: LibTalentTome.Class): integer
function LibTalentTome:GetNumSpecializations(classId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	classId = self:ResolveClassId(classId)

	if classId == nil then
		return 0
	end

	if cache.numSpecializations[classId] ~= nil then
		return cache.numSpecializations[classId]
	end

	local specializations = self:GetSpecializationsInternal(classId)
	local result = 0

	for _, spec in pairs(specializations) do
		if not spec.initial then
			result = result + 1
		end
	end

	cache.numSpecializations[classId] = result
	return result
end

--- Get all available specializations for the given class.
---
--- This excludes the initial specialization.
---
--- @param classId integer
--- @return LibTalentTome.Specialization[]
--- @overload fun(classFileName: string): LibTalentTome.Specialization[]
--- @overload fun(class: LibTalentTome.Class): LibTalentTome.Specialization[]
function LibTalentTome:GetSpecializations(classId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	classId = self:ResolveClassId(classId)

	if classId == nil then
		return {}
	end

	local specializations = self:GetSpecializationsInternal(classId)

	--- @type LibTalentTome.Specialization[]
	local result = {}

	for i, spec in pairs(specializations) do
		if not spec.initial then
			result[i] = CopyTable(spec)
		end
	end

	return result
end

--- Get the specialization at the given index, for the given class.
---
--- @param classId integer
--- @param index integer
--- @return LibTalentTome.Specialization?
--- @overload fun(classFileName: string, index: integer): LibTalentTome.Specialization?
--- @overload fun(class: LibTalentTome.Class, index: integer): LibTalentTome.Specialization?
function LibTalentTome:GetSpecializationAt(classId, index)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	classId = self:ResolveClassId(classId)

	if classId == nil then
		return nil
	end

	local specializations = self:GetSpecializationsInternal(classId)

	local specialization = specializations[index]
	if specialization == nil then
		return nil
	end

	return CopyTable(specialization)
end

--- Get the specialization with the given ID.
---
--- @param id integer
--- @return LibTalentTome.Specialization?
function LibTalentTome:GetSpecializationById(id)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	local classId = cache.specializationClassMap[id]

	if classId == nil then
		for class, specs in pairs(self.provider.specializations) do
			for _, spec in pairs(specs) do
				if spec.id == id then
					classId = class
					cache.specializationClassMap[id] = classId
					break
				end
			end
		end
	end

	if classId == nil then
		return nil
	end

	local specializations = self:GetSpecializationsInternal(classId)

	for _, specialization in pairs(specializations) do
		if specialization.id == id then
			return CopyTable(specialization)
		end
	end

	return nil
end

--- Get the initial specialization for the given class.
---
--- @param classId integer
--- @return LibTalentTome.Specialization?
--- @overload fun(classFileName: string): LibTalentTome.Specialization?
--- @overload fun(class: LibTalentTome.Class): LibTalentTome.Specialization?
function LibTalentTome:GetInitialSpecialization(classId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	classId = self:ResolveClassId(classId)

	if classId == nil then
		return nil
	end

	local specializations = self:GetSpecializationsInternal(classId)

	for _, spec in pairs(specializations) do
		if spec.initial then
			return CopyTable(spec)
		end
	end

	return nil
end

--- Get the number of talents available for the given specialization.
---
--- @param specId integer
--- @return integer
--- @overload fun(spec: LibTalentTome.Specialization): integer
function LibTalentTome:GetNumTalents(specId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	specId = self:ResolveSpecializationId(specId)

	return #self:GetTalentsInternal(specId)
end

--- Get all available talents available for the given specialization.
---
--- @param specId integer
--- @return LibTalentTome.Talent[]
--- @overload fun(spec: LibTalentTome.Specialization): LibTalentTome.Talent[]
function LibTalentTome:GetTalents(specId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	specId = self:ResolveSpecializationId(specId)

	return CopyTable(self:GetTalentsInternal(specId))
end

--- Get the talent at the given index for the given specialization.
---
--- @param specId integer
--- @param index integer
--- @return LibTalentTome.Talent?
--- @overload fun(spec: LibTalentTome.Specialization, index: integer): LibTalentTome.Talent?
function LibTalentTome:GetTalentAt(specId, index)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	specId = self:ResolveSpecializationId(specId)

	local talents = self:GetTalentsInternal(specId)

	local talent = talents[index]
	if talent ~= nil then
		return CopyTable(talent)
	end

	return nil
end

--- Get the talent with the given ID.
---
--- This method does not work when the trait system is available, as there isn't a way to reliably map these without pre-populating a cache.
---
--- @param id integer
--- @return LibTalentTome.Talent?
function LibTalentTome:GetTalentById(id)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if isTraitSystemAvailable then
		error("Cannot get talents by ID when the trait system is available.")
	end

	local specId = cache.talentSpecializationMap[id]

	if specId == nil then
		for spec, talents in pairs(self.provider.talents) do
			for _, talent in pairs(talents) do
				if talent.id == id then
					specId = spec
					cache.talentSpecializationMap[id] = specId
					break
				end
			end
		end
	end

	if specId == nil then
		return nil
	end

	local talents = self:GetTalentsInternal(specId)

	for _, talent in ipairs(talents) do
		if talent.id == id then
			return CopyTable(talent)
		end
	end

	return nil
end

--- Get the number of PvP talents available for the given specialization.
---
--- @param specId integer
--- @return integer
--- @overload fun(spec: LibTalentTome.Specialization): integer
function LibTalentTome:GetNumPvpTalents(specId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	specId = self:ResolveSpecializationId(specId)

	return #self:GetPvpTalentsInternal(specId)
end

--- Get all available PvP talents available for the given specialization.
---
--- @param specId integer
--- @return LibTalentTome.Talent[]
--- @overload fun(spec: LibTalentTome.Specialization): LibTalentTome.Talent[]
function LibTalentTome:GetPvpTalents(specId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	specId = self:ResolveSpecializationId(specId)

	return CopyTable(self:GetPvpTalentsInternal(specId))
end

--- Get the PvP talent at the given index for the given specialization.
---
--- @param specId integer
--- @param index integer
--- @return LibTalentTome.Talent?
--- @overload fun(spec: LibTalentTome.Specialization, index: integer): LibTalentTome.Talent?
function LibTalentTome:GetPvpTalentAt(specId, index)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	specId = self:ResolveSpecializationId(specId)

	local talents = self:GetPvpTalentsInternal(specId)

	local talent = talents[index]
	if talent == nil then
		return nil
	end

	return CopyTable(talent)
end

--- Get the PvP talent with the given ID.
---
--- @param id integer
--- @return LibTalentTome.Talent?
function LibTalentTome:GetPvpTalentById(id)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	local specId = cache.pvpTalentSpecializationMap[id]

	if specId == nil then
		for spec, talents in pairs(self.provider.pvpTalents) do
			for _, talent in pairs(talents) do
				if talent.id == id then
					specId = spec
					cache.pvpTalentSpecializationMap[id] = specId
					break
				end
			end
		end
	end

	if specId == nil then
		return nil
	end

	local talents = self:GetPvpTalentsInternal(specId)

	for _, talent in ipairs(talents) do
		if talent.id == id then
			return CopyTable(talent)
		end
	end

	return nil
end

--- @private
--- @param classId integer|string|LibTalentTome.Class
--- @return integer?
function LibTalentTome:ResolveClassId(classId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if type(classId) == "string" then
		return self.provider.classes[classId]
	elseif type(classId) == "table" then
		return classId.id
	end

	return classId
end

--- @private
--- @param specId integer|LibTalentTome.Specialization
--- @return integer?
function LibTalentTome:ResolveSpecializationId(specId)
	if type(specId) == "table" then
		return specId.id
	end

	return specId
end

--- @private
--- @param uniqueOnly boolean
--- @return LibTalentTome.Race[]
function LibTalentTome:GetRacesInternal(uniqueOnly)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if uniqueOnly and #cache.uniqueRaces > 0 then
		return cache.uniqueRaces
	elseif not uniqueOnly and #cache.races > 0 then
		return cache.races
	end

	--- @type LibTalentTome.Race[]
	local result = {}

	--- @type LibTalentTome.Race[]
	local uniqueResult = {}

	--- @type table<string, boolean>
	local seen = {}

	for id, fileName in pairs(self.provider.races) do
		local raceInfo = C_CreatureInfo.GetRaceInfo(id)

		if raceInfo ~= nil then
			table.insert(result, {
				id = id,
				fileName = fileName,
				name = raceInfo.raceName,
			})

			if not seen[fileName] then
				seen[fileName] = true

				table.insert(uniqueResult, {
					id = id,
					fileName = fileName,
					name = raceInfo.raceName,
				})
			end
		end
	end

	cache.uniqueRaces = uniqueResult
	cache.races = result

	if uniqueOnly then
		return uniqueResult
	end

	return result
end

--- @private
--- @return LibTalentTome.Class[]
function LibTalentTome:GetClassesInternal()
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if #cache.classes > 0 then
		return cache.classes
	end

	--- @type LibTalentTome.Class[]
	local result = {}

	for fileName, id in pairs(self.provider.classes) do
		table.insert(result, {
			fileName = fileName,
			name = LOCALIZED_CLASS_NAMES_MALE[fileName],
			id = id,
		})
	end

	table.sort(result, function(a, b) return a.id < b.id end)

	cache.classes = result
	return result
end

--- @private
--- @param classId integer
--- @return table<integer, LibTalentTome.Specialization>
function LibTalentTome:GetSpecializationsInternal(classId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if cache.specializations[classId] ~= nil then
		return cache.specializations[classId]
	end

	local all = self.provider.specializations[classId]
	if all == nil then
		return {}
	end

	--- @type table<integer, LibTalentTome.Specialization>
	local result = {}

	for i, specialization in pairs(all) do
		local _, name = GetSpecializationInfoByID(specialization.id)

		result[i] = {
			id = specialization.id,
			icon = specialization.icon,
			initial = specialization.initial,
			name = name,
		}
	end

	cache.specializations[classId] = result
	return result
end

--- @private
--- @param specId integer
--- @return LibTalentTome.Talent[]
function LibTalentTome:GetTalentsInternal(specId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if cache.talents[specId] ~= nil then
		return cache.talents[specId]
	end

	--- @type LibTalentTome.Talent[]
	local result = {}

	if isTraitSystemAvailable then
		C_ClassTalents.InitializeViewLoadout(specId, GetMaxLevelForLatestExpansion())
		C_ClassTalents.ViewLoadout({})

		local configId = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID
		local configInfo = C_Traits.GetConfigInfo(configId)

		if configInfo ~= nil then
			for _, treeId in ipairs(configInfo.treeIDs) do
				local nodes = C_Traits.GetTreeNodes(treeId)

				for _, nodeId in ipairs(nodes) do
					local node = C_Traits.GetNodeInfo(configId, nodeId)

					if node.isVisible then
						for _, talentId in ipairs(node.entryIDs) do
							local entryInfo = C_Traits.GetEntryInfo(configId, talentId)
							local definitionId = entryInfo.definitionID

							if definitionId ~= nil then
								local definitionInfo = C_Traits.GetDefinitionInfo(definitionId)
								local spellId = definitionInfo.spellID

								if spellId ~= nil then
									local name = TalentUtil.GetTalentNameFromInfo(definitionInfo)

									if name ~= "" then
										table.insert(result, {
											id = spellId,
											spellId = spellId,
											name = self:StripColorCodes(name),
											icon = TalentButtonUtil.CalculateIconTexture(definitionInfo),
										})
									end
								end
							end
						end
					end
				end
			end
		end
	else
		local all = self.provider.talents[specId]
		if all == nil then
			return {}
		end

		for i, talent in ipairs(all) do
			result[i] = {
				id = talent.id,
				icon = talent.icon,
				spellId = talent.spellId,
				name = TalentUtil.GetTalentName(nil, talent.spellId),
			}
		end
	end

	cache.talents[specId] = result
	return result
end

--- @private
--- @param specId integer
--- @return LibTalentTome.Talent[]
function LibTalentTome:GetPvpTalentsInternal(specId)
	assert(self.provider ~= nil, "No provider registered, register one first using 'SetProvider'.")

	if cache.pvpTalents[specId] ~= nil then
		return cache.pvpTalents[specId]
	end

	local all = self.provider.pvpTalents[specId]
	if all == nil then
		return {}
	end

	--- @type LibTalentTome.Talent[]
	local result = {}

	for i, talent in ipairs(all) do
		result[i] = {
			id = talent.id,
			icon = talent.icon,
			spellId = talent.spellId,
			name = TalentUtil.GetTalentName(nil, talent.spellId),
		}
	end

	cache.pvpTalents[specId] = result
	return result
end

--- @private
--- @param str string
--- @return string
function LibTalentTome:StripColorCodes(str)
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
	str = string.gsub(str, "|r", "")

	return str
end
