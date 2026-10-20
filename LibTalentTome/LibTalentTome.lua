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

if LibStub == nil then
	error("LibTalentTome requires LibStub")
end

--- @class LibTalentTome
local LibTalentTome = LibStub:NewLibrary("LibTalentTome", 1)
if LibTalentTome == nil then
	return
end

--- @class LibTalentTome.Provider
--- @field public build integer
--- @field public classes string[]
--- @field public specializations { [string]: { [integer]: LibTalentTome.Specialization } }
--- @field public talents { [unknown]: LibTalentTome.Talent[] }
--- @field public pvpTalents { [unknown]: LibTalentTome.Talent[] }

--- @class LibTalentTome.Specialization
--- @field public id integer
--- @field public name? string
--- @field public icon? integer

--- @class LibTalentTome.Talent
--- @field public id integer
--- @field public name string
--- @field public icon integer

--- @param provider LibTalentTome.Provider
function LibTalentTome:SetProvider(provider)
	assert(type(provider) == "table", "bad argument #1: expected table, got " .. type(provider))

	if self.provider ~= nil and provider.build <= self.provider.build then
		return
	end

	self.provider = provider
end

--- Get the number of classes available in the game.
---
--- @return integer
function LibTalentTome:GetNumClasses()
	return #self:GetClassesInternal()
end

--- Get the unique identifier of all available classes.
---
--- @return string[]
function LibTalentTome:GetClasses()
	return CopyTable(self:GetClassesInternal())
end

--- Get the number of specializations available for the given class.
---
--- @param classFileName string
--- @return integer
function LibTalentTome:GetNumSpecializations(classFileName)
	local specializations = self:GetSpecializationsInternal(classFileName)
	local result = 0

	for _ in pairs(specializations) do
		result = result + 1
	end

	return result
end

--- Get all available specializations for the given class.
---
--- @param classFileName string
--- @return { [integer]: LibTalentTome.Specialization }
function LibTalentTome:GetSpecializations(classFileName)
	return CopyTable(self:GetSpecializationsInternal(classFileName))
end

--- Get the specialization at the given index, for the given class.
---
--- @param classFileName string
--- @return LibTalentTome.Specialization
function LibTalentTome:GetSpecializationAt(classFileName, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	local specializations = self:GetSpecializationsInternal(classFileName)
	local specialization = specializations[index]
	if specialization == nil then
		error("Cannot get unknown specialization at index " .. index)
	end

	return CopyTable(specialization)
end

--- Get the specialization with the given ID, for the given class.
---
--- @param classFileName string
--- @return LibTalentTome.Specialization
function LibTalentTome:GetSpecializationById(classFileName, id)
	assert(type(id) == "number", "bad argument #2: expected number, got " .. type(id))

	local specializations = self:GetSpecializationsInternal(classFileName)

	for _, specialization in ipairs(specializations) do
		if specialization.id == id then
			return CopyTable(specialization)
		end
	end

	error("Cannot get unknown specialization with ID " .. id)
end

--- Get the number of talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return integer
function LibTalentTome:GetNumTalents(key)
	return #self:GetTalentsInternal(key)
end

--- Get all available talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentTome.Talent[]
function LibTalentTome:GetTalents(key)
	return CopyTable(self:GetTalentsInternal(key))
end

--- Get the talent at the given index for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentTome.Talent
function LibTalentTome:GetTalentAt(key, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	local talents = self:GetTalentsInternal(key)
	local talent = talents[index]
	if talent == nil then
		error("Cannot get unknown talent at index " .. index)
	end

	return CopyTable(talent)
end

--- Get the talent with the given ID for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentTome.Talent
function LibTalentTome:GetTalentById(key, id)
	assert(type(id) == "number", "bad argument #2: expected number, got " .. type(id))

	local talents = self:GetTalentsInternal(key)

	for _, talent in ipairs(talents) do
		if talent.id == id then
			return CopyTable(talent)
		end
	end

	error("Cannot get unknown talent with ID " .. id)
end

--- Get the number of PvP talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return integer
function LibTalentTome:GetNumPvpTalents(key)
	return #self:GetPvpTalentsInternal(key)
end

--- Get all available PvP talents available for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentTome.Talent[]
function LibTalentTome:GetPvpTalents(key)
	return CopyTable(self:GetPvpTalentsInternal(key))
end

--- Get the PvP talent at the given index for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentTome.Talent
function LibTalentTome:GetPvpTalentAt(key, index)
	assert(type(index) == "number", "bad argument #2: expected number, got " .. type(index))

	local talents = self:GetPvpTalentsInternal(key)
	local talent = talents[index]
	if talent == nil then
		error("Cannot get unknown talent at index " .. index)
	end

	return CopyTable(talent)
end

--- Get the PvP talent with the given ID for the given key.
---
--- The key can either be a class ID, or specialization ID, depending on the game version. If specializations exist in the game version, the key should be the
--- specialization ID, otherwise (read: Classic Era), the key should be a class ID.
---
--- @param key integer|string
--- @return LibTalentTome.Talent
function LibTalentTome:GetPvpTalentById(key, id)
	assert(type(id) == "number", "bad argument #2: expected number, got " .. type(id))

	local talents = self:GetPvpTalentsInternal(key)

	for _, talent in ipairs(talents) do
		if talent.id == id then
			return CopyTable(talent)
		end
	end

	error("Cannot get unknown talent with ID " .. id)
end

--- @private
--- @return string[]
function LibTalentTome:GetClassesInternal()
	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	return self.provider.classes
end

--- @private
--- @param classFileName string
--- @return { [integer]: LibTalentTome.Specialization }
function LibTalentTome:GetSpecializationsInternal(classFileName)
	assert(type(classFileName) == "string", "bad argument #1: expected string, got " .. type(classFileName))

	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	local specializations = self.provider.specializations[classFileName]
	if specializations == nil then
		return {}
	end

	return specializations
end

--- @private
--- @param specIdOrClassFileName integer|string
--- @return LibTalentTome.Talent[]
function LibTalentTome:GetTalentsInternal(specIdOrClassFileName)
	assert(tContains({"number", "string"}, type(specIdOrClassFileName)), "bad argument #1: expected number or string, got " .. type(specIdOrClassFileName))

	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	local talents = self.provider.talents[specIdOrClassFileName]
	if talents == nil then
		return {}
	end

	return talents
end

--- @private
--- @param specIdOrClassFileName integer|string
--- @return LibTalentTome.Talent[]
function LibTalentTome:GetPvpTalentsInternal(specIdOrClassFileName)
	assert(tContains({"number", "string"}, type(specIdOrClassFileName)), "bad argument #1: expected number or string, got " .. type(specIdOrClassFileName))

	if self.provider == nil then
		error("No talent provider registered, register one first using 'SetProvider'.")
	end

	local talents = self.provider.pvpTalents[specIdOrClassFileName]
	if talents == nil then
		return {}
	end

	return talents
end
