local Score = {}

Score.score = 0
Score.level = 0

function addScore(s)
	Score.score = Score.score + s
end

return Score
