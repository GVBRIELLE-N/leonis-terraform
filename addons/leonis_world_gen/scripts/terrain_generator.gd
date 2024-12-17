@tool
class_name EditorTerrainNode extends Node3D

@export var HeightMapTexture : Texture2D
@export var HeightOffset : float = 5
@export_range(128, 1024, 128) var CellSize : int = 128
@export_range(1,6) var subdivisionSteps : int = 1

var terrain_lod_0 : MeshInstance3D
var terrain_lod_1 : MeshInstance3D
var terrain_lod_2 : MeshInstance3D

var terrain_material : ShaderMaterial

func _ready():
	generate_terrain_mesh()

func generate_terrain_mesh():
	print("Generating Terrain Cell at position: " + str(position))
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	configure_material()
	generate_lod_0()
	generate_lod_1()
	generate_lod_2()
	add_child(terrain_lod_0)
	add_child(terrain_lod_1)
	add_child(terrain_lod_2)
	print("Cell generated successfully")
	
	
func configure_material():
	terrain_material = ShaderMaterial.new()
	terrain_material.shader = preload("res://addons/leonis_world_gen/shaders/terrain_shader.gdshader")
	terrain_material.set_shader_parameter("heightMapTexture", HeightMapTexture)
	terrain_material.set_shader_parameter("heightOffset", HeightOffset)
	
func generate_mesh(subdivision : int) -> PlaneMesh:
		var mesh = PlaneMesh.new()
		mesh.size = Vector2(CellSize, CellSize)
		mesh.subdivide_depth = subdivisionSteps * subdivision
		mesh.subdivide_width = subdivisionSteps * subdivision
		mesh.material = terrain_material
		
		return mesh

func generate_lod_0():
	terrain_lod_0 = MeshInstance3D.new()
	terrain_lod_0.name = "TerrainCellLOD0"
	
	terrain_lod_0.visibility_range_end = CellSize + 128
	terrain_lod_0.mesh = generate_mesh(16)

func generate_lod_1():
	var subd = 8
	if subdivisionSteps > 4:
		subd = 4
	terrain_lod_1 = MeshInstance3D.new()
	terrain_lod_1.name = "TerrainCellLOD1"

	terrain_lod_1.visibility_range_begin = CellSize + 128
	terrain_lod_1.visibility_range_end = CellSize * 2
	terrain_lod_1.mesh = generate_mesh(subd)
	
func generate_lod_2():
	var subd = 4
	if subdivisionSteps > 4:
		subd = 2
	terrain_lod_2 = MeshInstance3D.new()
	terrain_lod_2.name = "TerrainCellLOD2"
	
	terrain_lod_2.visibility_range_begin = CellSize * 2
	terrain_lod_2.visibility_range_end = CellSize * 4
	terrain_lod_2.mesh = generate_mesh(subd)
