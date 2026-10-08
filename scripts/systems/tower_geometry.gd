extends RefCounted
class_name TowerGeometry

const ARENA_RADIUS: float = 320.0
# Only the footprint on the floor is solid; the raised sprite is not a wall.
const TOWER_RECT: Rect2 = Rect2(-27.0, -3.0, 54.0, 28.0)
const TOWER_CLICK_RECT: Rect2 = Rect2(-29.0, -35.0, 58.0, 62.0)
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

static func slide_motion(from: Vector2, to: Vector2, actor_radius: float, tower_enabled: bool = true) -> Vector2:
	var stop: Vector2 = constrain_motion(from, to, actor_radius, tower_enabled)
	if stop.distance_to(to) < 0.01:
		return stop
	var horizontal: Vector2 = constrain_motion(stop, Vector2(to.x, stop.y), actor_radius, tower_enabled)
	horizontal = constrain_motion(horizontal, Vector2(horizontal.x, to.y), actor_radius, tower_enabled)
	var vertical: Vector2 = constrain_motion(stop, Vector2(stop.x, to.y), actor_radius, tower_enabled)
	vertical = constrain_motion(vertical, Vector2(to.x, vertical.y), actor_radius, tower_enabled)
	return horizontal if horizontal.distance_squared_to(to) < vertical.distance_squared_to(to) else vertical

static func navigation_target(from: Vector2, destination: Vector2, actor_radius: float) -> Vector2:
	if constrain_motion(from, destination, actor_radius).distance_to(destination) < 0.1:
		return destination
	var rect: Rect2 = TOWER_RECT.grow(actor_radius + 2.0)
	var points: Array[Vector2] = [from, destination, rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	var distances: Array[float] = [0.0, INF, INF, INF, INF, INF]
	var parents: Array[int] = [-1, -1, -1, -1, -1, -1]
	var visited: Array[bool] = [false, false, false, false, false, false]
	for _step in range(points.size()):
		var current: int = -1
		for i in range(points.size()):
			if not visited[i] and (current == -1 or distances[i] < distances[current]): current = i
		if current == -1 or distances[current] == INF: break
		if current == 1: break
		visited[current] = true
		for next in range(points.size()):
			if visited[next] or next == current: continue
			if constrain_motion(points[current], points[next], actor_radius).distance_to(points[next]) > 0.1: continue
			var cost: float = distances[current] + points[current].distance_to(points[next])
			if cost < distances[next]:
				distances[next] = cost
				parents[next] = current
	var waypoint: int = 1
	if parents[waypoint] == -1: return from
	while parents[waypoint] > 0: waypoint = parents[waypoint]
	return points[waypoint]
