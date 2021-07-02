local LeakyReLU = {}

function LeakyReLU.a(x)
	return math.max(0, x) - 0.01 * math.max(0, -x)
end

function LeakyReLU.d(x)
	return x > 0 and 1 or 0.01
end

return LeakyReLU
