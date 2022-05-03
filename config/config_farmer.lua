Keys = {
    ['ESC'] = 322, ['F1'] = 288, ['F2'] = 289, ['F3'] = 170, ['F5'] = 166, ['F6'] = 167, ['F7'] = 168, ['F8'] = 169, ['F9'] = 56, ['F10'] = 57,
    ['~'] = 243, ['1'] = 157, ['2'] = 158, ['3'] = 160, ['4'] = 164, ['5'] = 165, ['6'] = 159, ['7'] = 161, ['8'] = 162, ['9'] = 163, ['-'] = 84, ['='] = 83, ['BACKSPACE'] = 177,
    ['TAB'] = 37, ['Q'] = 44, ['W'] = 32, ['E'] = 38, ['R'] = 45, ['T'] = 245, ['Y'] = 246, ['U'] = 303, ['P'] = 199, ['['] = 39, [']'] = 40, ['ENTER'] = 18,
    ['CAPS'] = 137, ['A'] = 34, ['S'] = 8, ['D'] = 9, ['F'] = 23, ['G'] = 47, ['H'] = 74, ['K'] = 311, ['L'] = 182,
    ['LEFTSHIFT'] = 21, ['Z'] = 20, ['X'] = 73, ['C'] = 26, ['V'] = 0, ['B'] = 29, ['N'] = 249, ['M'] = 244, [','] = 82, ['.'] = 81,
    ['LEFTCTRL'] = 36, ['LEFTALT'] = 19, ['SPACE'] = 22, ['RIGHTCTRL'] = 70,
    ['HOME'] = 213, ['PAGEUP'] = 10, ['PAGEDOWN'] = 11, ['DEL'] = 178,
    ['LEFT'] = 174, ['RIGHT'] = 175, ['TOP'] = 27, ['DOWN'] = 173,
}

Farmer = {}

Farmer.Job = "farmer"

Farmer.Payout = 50
Farmer.Tractor = "tractor2"

Farmer.Farmer = {
	JobStart = {
		Pos   = vector3(1709.9458007813,4728.3022460938,41.1501121521),
		Size  = {x = 1.2, y = 1.2, z = 1.0},
		Color = {r = 78, g = 2453, b = 175},
		Type  = 25,
	},
	Cloakroom = {
		Pos   = {x = 1722.65, y = 4734.96, z = 41.17},
		Size  = {x = 1.2, y = 1.2, z = 1.0},
		Color = {r = 78, g = 2453, b = 175},
		Type  = 25,
	},
	Container = {
		Pos   = {x = 1729.48, y = 4715.24, z = 41.07},
		Size  = {x = 1.2, y = 1.2, z = 1.0},
		Color = {r = 78, g = 2453, b = 175},
		Type  = 25,
	},
	Payout = {
		Pos   = {x = 1710.06, y = 4728.43, z = 41.15},
		Size  = {x = 1.2, y = 1.2, z = 1.0},
		Color = {r = 78, g = 2453, b = 175},
		Type  = 25,
	},
	Vehicle = {
		Pos     = vector3(1726.5637207031,4705.474609375,42.470218658447),
		Heading = 289.21,
		Deleter = vector3(1720.4591064453,4704.2358398438,42.586845397949),
	},
}

Farmer.Farms = {
	{x= 1857.9, y = 4817.91, z = 44.76, FarmName="Pepinos"},
	{x= 1920.75, y = 4754.7, z = 42.56, FarmName="Lechugas"},
	{x= 1967.93, y = 4867.74, z = 45.5, FarmName="Patatas"},
}

Farmer.CucumbersPositions = {
	{ x = 1843.27, y = 4809.40, z = 44.02, planted = false, blip},
	{ x = 1851.57, y = 4817.29, z = 44.49, planted = false, blip},
	{ x = 1861.49, y = 4826.83, z = 44.85, planted = false, blip},
	{ x = 1871.59, y = 4836.84, z = 44.79, planted = false, blip},
}

Farmer.LettucePositions = {
	{ x = 1916.23, y = 4745.35, z = 42.37, planted = false, blip},
	{ x = 1922.65, y = 4750.74, z = 42.50, planted = false, blip},
	{ x = 1929.72, y = 4756.98, z = 42.46, planted = false, blip},
	{ x = 1938.18, y = 4764.46, z = 42.51, planted = false, blip},
}

Farmer.PotatoesPositions = {
	{ x = 1975.07, y = 4861.65, z = 45.54, planted = false, blip},
	{ x = 1971.39, y = 4865.58, z = 45.45, planted = false, blip},
	{ x = 1965.76, y = 4871.35, z = 45.46, planted = false, blip},
	{ x = 1960.43, y = 4876.49, z = 45.53, planted = false, blip},
}

Farmer.Clothes = {
    male = {
        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
        ['torso_1'] = 42,   ['torso_2'] = 1,
        ['decals_1'] = 0,   ['decals_2'] = 0,
        ['arms'] = 41,
        ['pants_1'] = 123,   ['pants_2'] = 20,
        ['shoes_1'] = 39,   ['shoes_2'] = 0,
        ['chain_1'] = 0,    ['chain_2'] = 0,
        ['helmet_1'] = 109,  ['helmet_2'] = 20,
        ['ears_1'] = -1,     ['ears_2'] = 0,
        ['bproof_1'] = 0,  ['bproof_2'] = 0
    },
    female = {
        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
        ['torso_1'] = 55,   ['torso_2'] = 4,
        ['decals_1'] = 0,   ['decals_2'] = 0,
        ['arms'] = 34,
        ['pants_1'] = 128,   ['pants_2'] = 20,
        ['shoes_1'] = 59,   ['shoes_2'] = 1,
        ['chain_1'] = -1,    ['chain_2'] = 0,
        ['helmet_1'] = 110,  ['helmet_2'] = 20,
        ['bproof_1'] = 0,  ['bproof_2'] = 0
    }
}
