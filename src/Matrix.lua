local Matrix = {}

do
	Matrix.__index = Matrix
	Matrix.__sub = function(self, n)
		local newMatrix = Matrix.new(self.rows, self.columns)
		if type(n) == "number" then
			newMatrix:Map(function(value, row, column)
				return self.data[row][column] - n
			end)
		elseif getmetatable(n) == Matrix then
			assert(self.rows == n.rows and self.columns == n.columns, string.format("sub: [%s, %s] does not match with [%s, %s]", self.rows, self.columns, n.rows, n.columns))
			newMatrix:Map(function(value, row, column)
				return self.data[row][column] - n.data[row][column]
			end)
		end

		return newMatrix
	end
	Matrix.__add = function(self, n)
		local newMatrix = Matrix.new(self.rows, self.columns)
		if type(n) == "number" then
			newMatrix:Map(function(value, row, column)
				return self.data[row][column] + n
			end)
		elseif getmetatable(n) == Matrix then
			assert(self.rows == n.rows and self.columns == n.columns, string.format("add: [%s, %s] does not match with [%s, %s]", self.rows, self.columns, n.rows, n.columns))
			newMatrix:Map(function(value, row, column)
				return self.data[row][column] + n.data[row][column]
			end)
		end

		return newMatrix
	end
	Matrix.__mul = function(self, n)
		local newMatrix = Matrix.new(self.rows, self.columns)
		if type(n) == "number" then
			newMatrix:Map(function(value, row, column)
				return self.data[row][column] * n
			end)
		elseif getmetatable(n) == Matrix then
			assert(self.rows == n.rows and self.columns == n.columns, string.format("mul: [%s, %s] does not match with [%s, %s]", self.rows, self.columns, n.rows, n.columns))
			newMatrix:Map(function(value, row, column)
				return self.data[row][column] * n.data[row][column]
			end)
		end

		return newMatrix
	end
end

do
	function Matrix.new(rows, columns)
		local self = setmetatable({}, Matrix)
		self.rows = rows
		self.columns = columns
		self.data = {}

		for row = 1, self.rows do
			self.data[row] = {}
			for column = 1, self.columns do
				self.data[row][column] = 0
			end
		end

		return self
	end

	function Matrix.map(m, callback)
		local newMatrix = Matrix.new(m.rows, m.columns)
		for row = 1, newMatrix.rows do
			for column = 1, newMatrix.columns do
				newMatrix.data[row][column] = callback(m.data[row][column])
			end
		end
		return newMatrix
	end

	function Matrix.FromArray(array)
		local newMatrix = Matrix.new(#array, 1)
		for i = 1, #array do
			newMatrix.data[i][1] = array[i]
		end
		return newMatrix
	end

	function Matrix.FromObject(object)
		local self = setmetatable({}, Matrix)

		self.rows = #object
		self.columns = #object[1]

		for _, v in pairs(object) do
			if #v ~= self.columns then
				return error("Rows must have the same length")
			end
		end

		self.data = object

		return self
	end

	function Matrix:Randomize()
		for row = 1, self.rows do
			self.data[row] = {}
			for column = 1, self.columns do
				self.data[row][column] = math.random() * 2 - 1
			end
		end
	end

	function Matrix:Dot(m)
		assert(getmetatable(m) == Matrix, "Must be a matrix")
		assert(self.columns == m.rows, string.format("[%s, %s] does not match with [%s, %s]", self.rows, self.columns, m.rows, m.columns))

		local newMatrix = Matrix.new(self.rows, m.columns)
		for row = 1, newMatrix.rows do
			for column = 1, newMatrix.columns do
				local sum = 0
				for i = 1, self.columns do
					sum += self.data[row][i] * m.data[i][column]
				end
				newMatrix.data[row][column] = sum
			end
		end
		return newMatrix
	end

	function Matrix:Map(callback)
		for row = 1, self.rows do
			for column = 1, self.columns do
				self.data[row][column] = callback(self.data[row][column], row, column)
			end
		end
	end

	function Matrix:ToArray()
		local array = {}
		for i, v in pairs(self.data) do
			array[i] = v[1]
		end
		return array
	end

	function Matrix:Clone()
		local newMatrix = Matrix.new(self.rows, self.columns)
		for i = 1, self.rows do
			for j = 1, self.columns do
				newMatrix.data[i][j] = self.data[i][j]
			end
		end

		return newMatrix
	end

	function Matrix:Transpose()
		local transposed = Matrix.new(self.columns, self.rows)
		for i = 1, self.rows do
			for j = 1, self.columns do
				transposed.data[j][i] = self.data[i][j]
			end
		end
		return transposed
	end
end

return Matrix
