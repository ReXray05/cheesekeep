extends RefCounted
class_name TowerGeometry

const ARENA_RADIUS: float = 320.0
# North edge includes clearance for the raised cheese sprite.
const TOWER_RECT: Rect2 = Rect2(-29.0, -35.0, 58.0, 62.0)
const SAFETY: float = 0.05

static func accessible_point(point: Vector2, actor_radius: float = 0.0, tower_enabled: bool = true) -> Vector2:
	var result: Vector2 = point.limit_length(maxf(1.0, ARENA_RADIUS - actor_radius))
	if not tower_enabled:
		return result
	var rect: Rect2 = TOWER_RECT.grow(maxf(0.0, actor_radius) + SAFETY)
	if rect.has_point(result):
		var distances: Array[float] = [result.x - rect.position.x, rect.end.x - result.x, result.y - rect.position.y, rect.end.y - result.y]
		var edge: int = 0
		for i in range(1, 4):
			if distances[i] < distances[edge]:
				edge = i
		match edge:
			0: result.x = rect.position.x - SAFETY
			1: result.x = rect.end.x + SAFETY
			2: result.y = rect.position.y - SAFETY
			3: result.y = rect.end.y + SAFETY
	return result

static func constrain_motion(from: Vector2, to: Vector2, actor_radius: float, tower_enabled: bool = true) -> Vector2:
	var start: Vector2 = accessible_point(from, actor_radius, tower_enabled)
	# A circle is convex: clipping the endpoint also clips its entire segment.
	var end: Vector2 = to.limit_length(maxf(1.0, ARENA_RADIUS - actor_radius))
	if not tower_enabled:
		return end
	var rect: Rect2 = TOWER_RECT.grow(maxf(0.0, actor_radius))
	var travel: Vector2 = end - start
	var entry: float = 0.0
	var exit: float = 1.0
	for axis in range(2):
		if absf(travel[axis]) < 0.000001:
			if start[axis] < rect.position[axis] or start[axis] > rect.end[axis]:
				return end
		else:
			var a: float = (rect.position[axis] - start[axis]) / travel[axis]
			var b: float = (rect.end[axis] - start[axis]) / travel[axis]
			entry = maxf(entry, minf(a, b))
			exit = minf(exit, maxf(a, b))
			if entry > exit:
				return end
	if entry > 1.0 or exit < 0.0:
		return end
	return start + travel * maxf(0.0, entry - SAFETY / maxf(travel.length(), SAFETY))

static func tower_contact(point: Vector2, actor_radius: float) -> bool:
	var closest: Vector2 = point.clamp(TOWER_RECT.position, TOWER_RECT.end)
	return point.distance_to(closest) <= maxf(0.0, actor_radius) + 1.0
