local HttpService = game:GetService("HttpService")

local Activations = require(script.Activations)

local Layer = require(script.Layer)
local Matrix = require(script.Matrix)
local NeuralNetwork = {}

local function CopyTable(t)
	assert(type(t) == "table", "First argument must be a table")
	local function Copy(tbl)
		local tCopy = table.create(#tbl)
		for k,v in pairs(tbl) do
			if (type(v) == "table") then
				tCopy[k] = Copy(v)
			else
				tCopy[k] = v
			end
		end
		return tCopy
	end
	return Copy(t)
end

NeuralNetwork.__index = NeuralNetwork

function NeuralNetwork.new(settings)
	settings.HiddenActivation = settings.HiddenActivation or "LeakyReLU"
	settings.OutputActivation = settings.OutputActivation or "Sigmoid"
	settings.HiddenNodes = settings.HiddenNodes or 2
	settings.HiddenLayers = settings.HiddenLayers or 1
	settings.LearningRate = settings.LearningRate or 0.1

	local self = setmetatable({}, NeuralNetwork)

	self.Settings = settings
	self.Layers = {}
	self.Activation = {
		Hidden = Activations[settings.HiddenActivation].a,
		Output = Activations[settings.OutputActivation].a
	}

	self.Derivative = {
		Hidden = Activations[settings.HiddenActivation].d,
		Output = Activations[settings.OutputActivation].d
	}

	self.Layers[settings.HiddenLayers + 2] = Layer.new({
		Nodes = settings.OutputNodes,
		Index = settings.HiddenLayers + 2
	})

	for i = settings.HiddenLayers + 1, 2, -1 do
		self.Layers[i] = Layer.new({
			Next = self.Layers[i + 1],
			Nodes = settings.HiddenNodes,
			Index = i
		})
	end

	self.Layers[1] = Layer.new({
		Next = self.Layers[2],
		Nodes = settings.InputNodes,
		Index = 1
	})

	for i, v in pairs(self.Layers) do
		v.Previous = self.Layers[i - 1]
	end

	self.LearningRate = settings.LearningRate

	return self
end

function NeuralNetwork:Clone()
	local this = setmetatable({}, NeuralNetwork)

	this.Settings = CopyTable(self.Settings)
	this.Layers = {}
	this.Activation = CopyTable(self.Activation)
	this.Derivative = CopyTable(self.Derivative)
	this.LearningRate = this.Settings.LearningRate

	this.Layers[#self.Layers] = Layer.new({
		Nodes = this.Settings.OutputNodes,
		Index = #self.Layers
	})

	for i = #self.Layers - 1, 2, -1 do
		this.Layers[i] = Layer.new({
			Next = this.Layers[i + 1],
			Nodes = this.Settings.HiddenNodes,
			Index = i
		})
	end

	this.Layers[1] = Layer.new({
		Next = this.Layers[2],
		Nodes = this.Settings.InputNodes,
		Index = 1
	})

	for i, v in pairs(this.Layers) do
		v.Previous = this.Layers[i - 1]

		if v.Weights and v.Biases then
			v.Weights = Matrix.FromObject(CopyTable(self.Layers[i].Weights.data))
			v.Biases = Matrix.FromObject(CopyTable(self.Layers[i].Biases.data))
		end
	end

	return this
end

function NeuralNetwork.Load(data)
	data = HttpService:JSONDecode(data)
	local self = setmetatable({}, NeuralNetwork)

	local settings = data.Settings

	self.Settings = settings
	self.Layers = {}

	self.Activation = {
		Hidden = Activations[settings.HiddenActivation].a,
		Output = Activations[settings.OutputActivation].a
	}

	self.Derivative = {
		Hidden = Activations[settings.HiddenActivation].d,
		Output = Activations[settings.OutputActivation].d
	}

	self.Layers[settings.HiddenLayers + 2] = Layer.new({
		Nodes = settings.OutputNodes,
		Index = settings.HiddenLayers + 2
	})

	for i = settings.HiddenLayers + 1, 2, -1 do
		self.Layers[i] = Layer.new({
			Next = self.Layers[i + 1],
			Nodes = settings.HiddenNodes,
			Index = i
		})
	end

	self.Layers[1] = Layer.new({
		Next = self.Layers[2],
		Nodes = settings.InputNodes,
		Index = 1
	})

	for i, v in pairs(self.Layers) do
		v.Previous = self.Layers[i - 1]

		if v.Weights and v.Biases then
			v.Weights = Matrix.FromObject(data.Layers[i].Weights)
			v.Biases = Matrix.FromObject(data.Layers[i].Biases)
		end
	end

	self.LearningRate = settings.LearningRate

	return self
end

function NeuralNetwork:Save()
	local save = {
		Settings = self.Settings,
		Layers = {}
	}

	for i, v in pairs(self.Layers) do
		save.Layers[i] = {}
		if v.Weights and v.Biases then
			save.Layers[i].Weights = v.Weights.data
			save.Layers[i].Biases = v.Biases.data
		end
	end

	return HttpService:JSONEncode(save)
end

function NeuralNetwork:Predict(input)
	local inputs = Matrix.FromArray(input)
	local outputs = self.Layers[1]:FeedForward(inputs, self.Activation, {})

	return outputs:ToArray()
end

function NeuralNetwork:Train(input, target)
	assert(#input == self.Settings.InputNodes, "Input size does not match")
	assert(#target == self.Settings.OutputNodes, "Output size does not match")

	local inputs = Matrix.FromArray(input)

	local predictions, orderedResults = self.Layers[1]:FeedForward(inputs, self.Activation, {})
	local targets = Matrix.FromArray(target)

	local outputErrors = targets - predictions
	local outputGradient = Matrix.map(predictions, self.Derivative.Output) * outputErrors * self.LearningRate

	self.Layers[#self.Layers - 1]:BackPropagate({
		Gradient = outputGradient,
		Errors = outputErrors
	}, orderedResults, self.Derivative.Hidden)
end

function NeuralNetwork:Mutate(callback)
	for i, v in pairs(self.Layers) do
		if v.Weights and v.Biases then
			v.Weights:Map(callback)
			v.Biases:Map(callback)
		end
	end
end

return NeuralNetwork
