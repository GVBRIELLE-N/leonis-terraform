@tool
class_name EditorTerrainNode extends Node3D

@export var HeightMapTexture : Texture2D

var terrain_lod_0 : MeshInstance3D
var terrain_lod_1 : MeshInstance3D
var terrain_lod_2 : MeshInstance3D

func _ready():
	generate_terrain_mesh()

func generate_terrain_mesh():
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	generate_lod_0()
	add_child(terrain_lod_0)
	
func generate_lod_0():
	terrain_lod_0 = MeshInstance3D.new()
	
	var lod_0_mesh = PlaneMesh.new()
	lod_0_mesh.subdivide_depth = 8
	lod_0_mesh.subdivide_width = 8
	
	terrain_lod_0.mesh = lod_0_mesh
