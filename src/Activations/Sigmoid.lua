local Sigmoid = {}

function Sigmoid.a(x)
	return 1 / (1 + math.exp(-x))
end

function Sigmoid.d(x)
	return Sigmoid.a(x) * (1 - Sigmoid.a(x))
end

return Sigmoid
