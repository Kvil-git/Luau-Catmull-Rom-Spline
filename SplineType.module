--!strict
export type CatmullRomSpline = {
	Points: {Vector3},
	IsLooped: boolean,



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
}


return nil
