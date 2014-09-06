BLOCKS = {
	blocks.None, 		blocks.None,	 	blocks.None, 		blocks.None, 		blocks.None,
	blocks.None, 		blocks.None, 		blocks.Blue, 		blocks.None, 		blocks.None,
	blocks.None, 		blocks.Blue, 		blocks.LightBlue,	blocks.Blue, 		blocks.None,
	blocks.Red,			blocks.Yellow, 		blocks.None, 		blocks.Orange, 		blocks.Yellow,
	blocks.None,		blocks.None,		blocks.None,		blocks.None, 		blocks.None,
}

function init(enemy)
	enemy:setMaxLife(5)
	enemy:setLife(5)
end

function update(enemy)
	local pos = enemy:getPosition()
	local diff = player.position.y - pos.y

	if pos.x < player.position.x then
		enemy:setSpeedY(0)
		return
	end

	if diff > 8 then
		enemy:setSpeedY(60)
	elseif diff < -8 then
		enemy:setSpeedY(-60)
	else
		enemy:setSpeedY(0)
	end

	if math.abs(diff) < 8 then
		enemy:shoot()
	end
end
