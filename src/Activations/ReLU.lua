local ReLU = {}

function ReLU.a(x)
	return math.max(0, x)
end

function ReLU.d(x)
	return x > 0 and 1 or 0
end

return ReLU
