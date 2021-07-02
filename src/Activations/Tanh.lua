local Tanh = {}

function Tanh.a(x)
	return math.tanh(x)
end

function Tanh.d(x)
	return 1 - (Tanh.a(x) ^ 2)
end

return Tanh
