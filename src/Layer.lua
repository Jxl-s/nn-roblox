local Matrix = require(script.Parent.Matrix)
local Layer = {}
Layer.__index = Layer

function Layer.new(settings)
	settings = settings or {}
	local self = setmetatable({}, Layer)

	self.Index = settings.Index
	self.Next = settings.Next
	self.Nodes = settings.Nodes

	if self.Next then
		self.Weights = Matrix.new(self.Next.Nodes, self.Nodes)
		self.Biases = Matrix.new(self.Next.Nodes, 1)

		self.Weights:Randomize()
		self.Biases:Randomize()
	end

	return self
end

function Layer:FeedForward(inputs, activation, resultsArray)
	resultsArray = resultsArray or {}
	if not self.Weights or not self.Biases then
		return inputs, resultsArray
	end

	local layerResults = self.Weights:Dot(inputs) + self.Biases
	layerResults:Map(self.Next.Weights and activation.Hidden or activation.Output)

	table.insert(resultsArray, layerResults)

	return self.Next:FeedForward(layerResults, activation, resultsArray)
end

function Layer:BackPropagate(parameters, results, derivative)
	if not results[self.Index - 1] then
		return
	end

	self.Weights += parameters.Gradient:Dot(results[self.Index - 1]:Transpose())
	self.Biases += parameters.Gradient

	local layerErrors = self.Weights:Transpose():Dot(parameters.Errors)

	self.Previous:BackPropagate({
		Gradient = Matrix.map(results[self.Index - 1], derivative) * layerErrors * parameters.LearningRate,
		Errors = layerErrors,
		LearningRate = parameters.LearningRate
	}, results, derivative)
end

return Layer
