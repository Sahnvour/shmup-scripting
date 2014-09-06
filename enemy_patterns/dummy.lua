BLOCKS = {
	blocks.None,	blocks.None,	blocks.None,	blocks.None,	blocks.None,
	blocks.None,	blocks.Blue,	blocks.Blue,	blocks.Blue,	blocks.None,
	blocks.None,	blocks.Blue,	blocks.Blue,	blocks.Blue,	blocks.None,
	blocks.None,	blocks.Blue,	blocks.Blue,	blocks.Blue,	blocks.None,
	blocks.None,	blocks.None,	blocks.None,	blocks.None,	blocks.None
}

local onScreen = false
local start

function init(enemy)
	enemy:setMaxLife(1)
	enemy:setLife(1)
end

function update(enemy)
	if not onScreen then
		start = game.time
		onScreen = true
	end
	local duration = game.time:since(start):asSeconds()
	enemy:setSpeedY(math.cos(2*duration)*60)
end
