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

local LibTalentTome = LibStub and LibStub("LibTalentTome", true)
local _, _, _, interfaceVersion = GetBuildInfo()

if LibTalentTome == nil or interfaceVersion < 16000 or interfaceVersion >= 20000 then
	return
end

--- @type LibTalentTome.Provider
LibTalentTome:SetProvider({
	build = 70532,
	races = {
		[1] = "Human",
		[2] = "Orc",
		[3] = "Dwarf",
		[4] = "NightElf",
		[5] = "Scourge",
		[6] = "Tauren",
		[7] = "Gnome",
		[8] = "Troll",
		[95] = "Skyborne",
		[96] = "Skyborne",
	},
	classes = {
		["WARRIOR"] = 1,
		["PALADIN"] = 2,
		["HUNTER"] = 3,
		["ROGUE"] = 4,
		["PRIEST"] = 5,
		["SHAMAN"] = 7,
		["MAGE"] = 8,
		["WARLOCK"] = 9,
		["DRUID"] = 11,
	},
	specializations = {
		[1] = {
			[1] = { id = 1491, icon = 626008 },
		},
		[2] = {
			[1] = { id = 1486, icon = 626003 },
		},
		[3] = {
			[1] = { id = 1485, icon = 626000 },
		},
		[4] = {
			[1] = { id = 1488, icon = 626005 },
		},
		[5] = {
			[1] = { id = 1487, icon = 626004 },
		},
		[7] = {
			[1] = { id = 1489, icon = 626006 },
		},
		[8] = {
			[1] = { id = 1482, icon = 626001 },
		},
		[9] = {
			[1] = { id = 1490, icon = 626007 },
		},
		[11] = {
			[1] = { id = 1484, icon = 625999 },
		},
	},
	talents = {
	},
	pvpTalents = {
	}
})
