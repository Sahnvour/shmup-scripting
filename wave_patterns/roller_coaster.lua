-- roller_coaster.lua

function generate()
	local wave = {}
	wave.name = "roller_coaster"
	wave.enemies = {}

	local enemyCount = math.floor(game.difficulty * 10)
	enemyCount = rand.int(enemyCount, enemyCount * 2)
	
	local y = rand.int(0, 4)
	local delta = 1

	for i = 1, enemyCount do
		local enemy =
		{
			pattern = rand.enemyPattern(),
			x = 800 + i*80,
			y = y*100 + 20
		}

		if y == 4 then
			delta = -1
		elseif y == 0 then
			delta = 1
		end
		y = y + delta
		table.insert(wave.enemies, enemy)
	end

	return wave
end