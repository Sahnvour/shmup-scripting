BLOCKS = {
	blocks.None,	blocks.None,	blocks.None,	blocks.None,	blocks.None,
	blocks.None,	blocks.None,	blocks.Blue,	blocks.None,	blocks.None,
	blocks.None,	blocks.Red,		blocks.Blue,	blocks.Blue,	blocks.None,
	blocks.None,	blocks.None,	blocks.Blue,	blocks.None,	blocks.None,
	blocks.None,	blocks.None,	blocks.None,	blocks.None,	blocks.None
}

local enterOnScreen
local speed

function isOffScreen (enemy)
	local pos = enemy:getPosition()
	if pos.y > 480-32 or pos.y < -8 then
		return true
	elseif pos.x < 0 or pos.x > 800 then
		return true
	end
	return false
end

function init(enemy)
	enemy:setMaxLife(5)
	enemy:setLife(5)
	enterOnScreen = false;
	speed = enemy:getSpeed()
end

function update(enemy)
	local now = game.time

	if not enterOnScreen then
		enterOnScreen = true
		lastMove = now
		return
	end

	if not isOffScreen(enemy) and now:since(lastMove):asSeconds() < 1 then
		return
	else
		local pos = enemy:getPosition()
		local move = rand.int(0,2)
		if pos.y >= 480-32 or move == 0 then
			enemy:setSpeed(Vec2(0, -60)) -- go up
			enemy:shoot()
		elseif pos.y <= -8 or move == 1 then
			enemy:setSpeed(Vec2(0, 60)) -- go down
			enemy:shoot()
		else
			enemy:setSpeed(Vec2(-120, 0))
		end

		lastMove = now
	end
end
