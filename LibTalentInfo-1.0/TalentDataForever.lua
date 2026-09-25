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

local LibTalentInfo = LibStub and LibStub("LibTalentInfo-1.0", true)

local interfaceVersion = select(4, GetBuildInfo())

if LibTalentInfo == nil or interfaceVersion < 16000 or interfaceVersion >= 20000 then
	return
end

--- @type LibTalentInfo-1.0.Provider
LibTalentInfo:SetProvider({
	build = 70009,
	classes = {
		"DRUID",
		"HUNTER",
		"PALADIN",
		"PRIEST",
		"ROGUE",
		"SHAMAN",
		"WARLOCK",
		"WARRIOR",
	},
	specializations = {
		["DRUID"] = {
		},
		["HUNTER"] = {
		},
		["PALADIN"] = {
		},
		["PRIEST"] = {
		},
		["ROGUE"] = {
		},
		["SHAMAN"] = {
		},
		["WARLOCK"] = {
		},
		["WARRIOR"] = {
		},
	},
	talents = {
		["DRUID"] = {
		},
		["HUNTER"] = {
		},
		["PALADIN"] = {
		},
		["PRIEST"] = {
		},
		["ROGUE"] = {
		},
		["SHAMAN"] = {
		},
		["WARLOCK"] = {
		},
		["WARRIOR"] = {
		},
	},
	pvpTalents = {
		["DRUID"] = {
		},
		["HUNTER"] = {
		},
		["PALADIN"] = {
		},
		["PRIEST"] = {
		},
		["ROGUE"] = {
		},
		["SHAMAN"] = {
		},
		["WARLOCK"] = {
		},
		["WARRIOR"] = {
		},
	}
})
