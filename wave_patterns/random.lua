-- random.lua


function generate()
	local wave = {}
	wave.name = "random"
	wave.enemies = {}

	local enemyCount = math.floor(game.difficulty * 10)
	enemyCount = rand.int(enemyCount, enemyCount * 2)

	for i = 1, enemyCount do
		local enemy =
		{
			pattern = rand.enemyPattern(),
			x = rand.int(800, 2400),
			y = rand.int(0, 440)
		}
		table.insert(wave.enemies, enemy)
	end

	return wave
end