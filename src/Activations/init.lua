local Activations = {}

for i, v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		Activations[v.Name] = require(v)
	end
end

return Activations
