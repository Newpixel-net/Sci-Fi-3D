extends Node
## Object Pool - Generic object pooling system
##
## Reuses objects instead of instantiating/freeing for better performance.

class_name ObjectPool

var pool_scene: PackedScene
var pool: Array = []
var active_objects: Array = []
var pool_size: int = 20
var parent_node: Node = null

## Initialize pool
func initialize(scene: PackedScene, initial_size: int = 20, parent: Node = null) -> void:
	pool_scene = scene
	pool_size = initial_size
	parent_node = parent if parent else self

	# Pre-instantiate objects
	for i in range(pool_size):
		var obj = pool_scene.instantiate()
		obj.process_mode = Node.PROCESS_MODE_DISABLED
		parent_node.add_child(obj)
		obj.visible = false
		pool.append(obj)

	print("Object pool initialized with %d objects" % pool_size)

## Get object from pool
func get_object() -> Node:
	var obj: Node

	if pool.is_empty():
		# Pool exhausted, create new object
		obj = pool_scene.instantiate()
		parent_node.add_child(obj)
		print("Pool exhausted, creating new object")
	else:
		# Get from pool
		obj = pool.pop_back()

	# Activate object
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	obj.visible = true
	active_objects.append(obj)

	return obj

## Return object to pool
func return_object(obj: Node) -> void:
	if obj not in active_objects:
		return

	active_objects.erase(obj)

	# Deactivate object
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	obj.visible = false

	# Reset position/rotation
	if obj is Node3D:
		obj.global_position = Vector3.ZERO
		obj.global_rotation = Vector3.ZERO

	pool.append(obj)

## Return all active objects
func return_all() -> void:
	var objects_to_return = active_objects.duplicate()
	for obj in objects_to_return:
		return_object(obj)

## Get pool stats
func get_stats() -> Dictionary:
	return {
		"pool_size": pool.size(),
		"active_count": active_objects.size(),
		"total": pool.size() + active_objects.size()
	}

## Clear pool
func clear_pool() -> void:
	return_all()
	for obj in pool:
		obj.queue_free()
	pool.clear()
