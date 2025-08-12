--!strict
local Metatable = require(script.Parent.Metatable)
local CatmullRomSplineType = require(script.Parent.SplineType)
local CatmullRomSpline = Metatable() :: CatmullRomSplineType.CatmullRomSpline


function CatmullRomSpline.NewFromSetOfPoints(pointSet: {Vector3}, isLooped: boolean?)
	local self = Metatable(CatmullRomSpline) :: CatmullRomSplineType.CatmullRomSpline
	self.Points = pointSet
	self.IsLooped = isLooped or false

	if self.IsLooped == false then  
		local lastPointIndex = #self.Points
		self.Points[lastPointIndex + 1] = self.Points[lastPointIndex]

		table.insert(self.Points, self.Points[1])
	end

	return self
end
local function MapValue(value: number, inMin: number, inMax: number, outMin: number, outMax: number): number
	return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

local function GetControlPointIndex(index: number, count: number, isLooped: boolean): number
	if isLooped then
		return (index - 1) % count + 1
	else
		return math.clamp(index, 1, count)
	end
end

local function EvaluateCatmullRom(qFunc: (i: number, t: number) -> number, t: number, spline: CatmullRomSplineType.CatmullRomSpline): Vector3
	local numPoints = #spline.Points
	local mappedT = if not spline.IsLooped then MapValue(t, 0, 1, 0, numPoints - 3)
		else MapValue(t, 0, 1, 0, numPoints)

	local segment = math.floor(mappedT)
	local localT = mappedT - segment

	-- Determine control point indices
	local p1 = GetControlPointIndex(segment,     numPoints, spline.IsLooped)
	local p2 = GetControlPointIndex(segment + 1, numPoints, spline.IsLooped)
	local p3 = GetControlPointIndex(segment + 2, numPoints, spline.IsLooped)
	local p4 = GetControlPointIndex(segment + 3, numPoints, spline.IsLooped)

	local x, y, z = 0, 0, 0

	for i, idx in ipairs({p1, p2, p3, p4}) do
		local coeff = qFunc(i, localT)
		local pt = spline.Points[idx]
		x += pt.X * coeff
		y += pt.Y * coeff
		z += pt.Z * coeff
	end

	return Vector3.new(x, y, z)
end

function CatmullRomSpline:GetPointAtTValue(t: number): Vector3
	local function q(i: number, t: number): number
		local t2, t3 = t * t, t * t * t
		local basis = {
			-t3 + 2*t2 - t,
			3*t3 - 5*t2 + 2,
			-3*t3 + 4*t2 + t,
			t3 - t2
		}
		return 0.5 * basis[i]
	end
	return EvaluateCatmullRom(q, t, self)
end

function CatmullRomSpline:GetGradientAtTValue(t: number): Vector3
	local function qDerivative(i: number, t: number): number
		local t2 = t * t
		local basis = {
			-3*t2 + 4*t - 1,
			9*t2 - 10*t,
			-9*t2 + 8*t + 1,
			3*t2 - 2*t
		}
		return 0.5 * basis[i]
	end
	return EvaluateCatmullRom(qDerivative, t, self)
end




function CatmullRomSpline:GetNPointsAcrossTheSpline(n: number): {Vector3}
	local output = {}
	for i = 0, n - 1 do
		local t = i / (n - 1)
		local currentPoint = self:GetPointAtTValue(t)
		table.insert(output, currentPoint)
	end

	return output
end

function CatmullRomSpline:GetNGradientsAcrossTheSpline(n: number): {Vector3}
	local output = {}
	for i = 0, n - 1 do
		local t = i / (n - 1)
		local currentPoint = self:GetGradientAtTValue(t)
		table.insert(output, currentPoint)
	end

	return output
end


function CatmullRomSpline:GetLength(): number
	local length = 0
	local segments = self:GetNPointsAcrossTheSpline(100)
	for i = 1, #segments - 1 do
		length += (segments[i+1] - segments[i]).Magnitude
	end
	return length
end

function CatmullRomSpline:GetTAtDistance(distance: number): number
	local totalLength = self:GetLength()
	local targetDist = math.clamp(distance, 0, totalLength)

	local accumulated = 0
	local prev = self:GetPointAtTValue(0)
	for i = 1, 100 do
		local t = i / 100
		local pos = self:GetPointAtTValue(t)
		local segLength = (pos - prev).Magnitude
		accumulated += segLength
		if accumulated >= targetDist then
			return t
		end
		prev = pos
	end
	return 1
end

function CatmullRomSpline:InsertPoint(index: number, point: Vector3)
	table.insert(self.Points, index, point)
end

function CatmullRomSpline:RemovePoint(index: number)
	table.remove(self.Points, index)
end

function CatmullRomSpline:SetPoint(index: number, point: Vector3)
	self.Points[index] = point
end

function CatmullRomSpline:Clone(): CatmullRomSplineType.CatmullRomSpline
	local copy = {}
	for i, pt in ipairs(self.Points) do
		copy[i] = pt
	end
	return CatmullRomSpline.NewFromSetOfPoints(copy, self.IsLooped)
end

function CatmullRomSpline:SplinePointClosestToPoint(pos: Vector3): (Vector3, number)
	local bestDist = math.huge
	local bestPoint = self.Points[1]
	local bestT = 0
	for i = 0, 100 do
		local t = i / 100
		local pt = self:GetPointAtTValue(t)
		local dist = (pt - pos).Magnitude
		if dist < bestDist then
			bestDist = dist
			bestPoint = pt
			bestT = t
		end
	end
	return bestPoint, bestT
end

function CatmullRomSpline:SplineNodeClosestToPoint(point: Vector3): (Vector3, number)
	local bestDistance = math.huge
	local bestPoint = self.Points[1]
	local bestPointIndex = 1

	for i=1, #self.Points do 
		local distance = (self.Points[i] - point).Magnitude
		if distance < bestDistance then 
			bestDistance = distance
			bestPoint = self.Points[i]
			bestPointIndex = i
		end
	end

	return bestPoint, bestPointIndex
end

function CatmullRomSpline:GetFrenetFrameAtT(t: number): (Vector3, Vector3, Vector3)
	local epsilon = 1e-4

	-- Central difference for smooth gradient estimation
	local p1 = self:GetPointAtTValue(math.max(0, t - epsilon))
	local p2 = self:GetPointAtTValue(math.min(1, t + epsilon))

	local tangent = (p2 - p1).Unit
	local position = self:GetPointAtTValue(t)

	-- Default up vector for cross product reference
	local worldUp = Vector3.new(0, 1, 0)

	-- Avoid degenerate normal if tangent is nearly vertical
	local right = tangent:Cross(worldUp)
	if right.Magnitude < 1e-5 then
		worldUp = Vector3.new(1, 0, 0) -- fallback axis
		right = tangent:Cross(worldUp)
	end

	local normal = right:Cross(tangent).Unit

	return position, tangent, normal
end

return CatmullRomSpline
