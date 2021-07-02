type ActivationFunction = "LeakyRELU" | "ReLU" | "Sigmoid" | "Tanh";

interface NeuralNetwork<T> {
	Predict(input: number[]): number[];
	Train(inputs: number[], outputs: number[]): void;
}

interface NeuralNetworkConstructor {
	new <
		T extends {
			InputNodes: number;
			HiddenNodes: number;
			OutputNodes: number;
			HiddenLayers: number;
			LearningRate: number;
			HiddenActivation: ActivationFunction;
			OutputActivation: ActivationFunction;
		}
	>(
		settings: T
	): NeuralNetwork<T>;
}
