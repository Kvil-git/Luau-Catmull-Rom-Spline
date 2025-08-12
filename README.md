If you are writing in plain lua, you can ignore the type file completely.
(You will have to remove all the type annotations of course because lua has none :/ )

The interface and the api is described in the SplineType file. 
I separated the type and the class itself because this gives more flexibility, for example with such structure i can make other interfaces depend on the spline one, this structure saved me some pain with cyclic dependencies before.

I will write the methods again just so you dont have to check the SpineType file and to get more characters written in here.

```luau
	NewFromSetOfPoints: (pointSet: {Vector3}, isLooped: boolean?) -> CatmullRomSpline, --constructor

	GetPointAtTValue: (self: CatmullRomSpline, t: number) -> Vector3,
	GetGradientAtTValue: (self: CatmullRomSpline, t: number) -> Vector3,

	GetNPointsAcrossTheSpline: (self: CatmullRomSpline, n: number) -> {Vector3},
	GetNGradientsAcrossTheSpline: (self: CatmullRomSpline, n: number) -> {Vector3},


	GetLength: (self: CatmullRomSpline) -> number,
	GetTAtDistance: (self: CatmullRomSpline, distance: number) -> number,

	InsertPoint: (self: CatmullRomSpline, index: number, point: Vector3) -> (),
	RemovePoint: (self: CatmullRomSpline, index: number) -> (),
	SetPoint: (self: CatmullRomSpline, index: number, point: Vector3) -> (),
	Clone: (self: CatmullRomSpline) -> CatmullRomSpline,

	SplinePointClosestToPoint: (self: CatmullRomSpline, pos: Vector3) -> (Vector3, number), -- point position and t value
	SplineNodeClosestToPoint: (self: CatmullRomSpline, pos: Vector3) -> (Vector3, number), -- node position and index

	GetFrenetFrameAtT: (self: CatmullRomSpline, t: number) -> (Vector3, Vector3, Vector3), -- returns: position, tangent (unit), normal (unit)
```

the way to use this class in luau:
```luau
local SplineClass = require("some path")
local mySpline = SplineClass.NewFromSetOfPoints { Vector3.new(5, 5, 5), Vector3.new(1, -2.23156, 3), Vector3.new(-6, -2, 3.21345), Vector3.one * 4 }
local splinePoints = mySpline:GetNPointsAcrossTheSpline(100)
for key, point in ipairs(splinePoints) do
  DrawThePointOrWhateverElseIdk(point)
end
```
