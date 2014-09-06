BLOCKS = {
	blocks.None,	blocks.None,		blocks.None,		blocks.None,		blocks.None,
	blocks.None,	blocks.Yellow,		blocks.Orange,		blocks.Yellow,		blocks.None,
	blocks.None,	blocks.Orange,		blocks.Purple,		blocks.Orange,		blocks.None,
	blocks.None,	blocks.Yellow,		blocks.Orange,		blocks.Yellow,		blocks.None,
	blocks.None,	blocks.None,		blocks.None,		blocks.None,		blocks.None
}

function init(enemy)
	enemy:setMaxLife(4)
	enemy:setLife(4)
	enemy:setSpeedY(60)
end

function update(enemy)
	local y = enemy:getPosition().y
	if y >= game.world.height - 32 then
		enemy:setSpeedY(-60)
	elseif y <= 0 then
		enemy:setSpeedY(60)
	end

	if enemy:getLife() < 2 then
		enemy:heal()
	end
	enemy:shoot()
end
