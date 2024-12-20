@tool
class_name EditorTerrainNode extends Node3D

@export_category("Terrain Configuration")
@export var HeightMapTexture : Texture2D
@export var HeightOffset : float = 10

@export_group("Collision")
@export var EnableCollision : bool = true

@export_category("Cell Configuration")
@export_range(512, 1024, 128) var CellSize : int = 1024
@export_range(1,6) var subdivisionSteps : int = 6

@export_category("Terrain Layers")
@export var rockLayer 	: TerrainLayer
@export var groundLayer : TerrainLayer
@export var detailLayer : TerrainLayer

var terrain_lod_0 : MeshInstance3D
var terrain_lod_1 : MeshInstance3D
var terrain_lod_2 : MeshInstance3D
var terrain_lod_3 : MeshInstance3D

var terrain_material : ShaderMaterial

func _ready():
	await get_tree().process_frame
#	Only generate a mesh if the node has no children
	if get_child_count() == 0:
		generate_terrain_mesh()

func generate_terrain_mesh():
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	if HeightMapTexture == null:
		push_warning("Unable to generate mesh without a heightmap texture.")
		return
	configure_material()
	generate_lod_0()
	generate_lod_1()
	generate_lod_2()
	generate_lod_3()
	terrain_lod_0.scale.y = HeightOffset/4
	terrain_lod_1.scale.y = HeightOffset/4
	terrain_lod_2.scale.y = HeightOffset/4
	terrain_lod_3.scale.y = HeightOffset/4
#	Create a static body for the cell
	add_children_and_reposition()
	
func add_children_and_reposition():
	var lod_0_root = StaticBody3D.new()
	lod_0_root.add_child(terrain_lod_0)
	lod_0_root.position.x = -(CellSize / 2)
	lod_0_root.position.z = -(CellSize / 2)
	add_child(lod_0_root)
	terrain_lod_1.position.x = -(CellSize / 2)
	terrain_lod_1.position.z = -(CellSize / 2)
	add_child(terrain_lod_1)
	terrain_lod_2.position.x = -(CellSize / 2)
	terrain_lod_2.position.z = -(CellSize / 2)
	add_child(terrain_lod_2)
	terrain_lod_3.position.x = -(CellSize / 2)
	terrain_lod_3.position.z = -(CellSize / 2)
	add_child(terrain_lod_3)
	
func configure_material():
	terrain_material = ShaderMaterial.new()
	terrain_material.shader = preload("res://addons/leonis_world_gen/shaders/terrain_shader.gdshader")
	terrain_material.set_shader_parameter("heightMapTexture", HeightMapTexture)
	terrain_material.set_shader_parameter("heightOffset", HeightOffset)
#	Top Layer
	terrain_material.set_shader_parameter("rockColour", rockLayer.albedo)
	terrain_material.set_shader_parameter("rockTexture", rockLayer.albedoTexture)
	terrain_material.set_shader_parameter("rockNormalMap", rockLayer.normalMap)
	terrain_material.set_shader_parameter("rockTiling", rockLayer.uvTiling)
#	groundLayer
	terrain_material.set_shader_parameter("groundColour", groundLayer.albedo)
	terrain_material.set_shader_parameter("groundTexture", groundLayer.albedoTexture)
	terrain_material.set_shader_parameter("groundNormalMap", groundLayer.normalMap)
	terrain_material.set_shader_parameter("groundTiling", groundLayer.uvTiling)
#	detailLayer
	terrain_material.set_shader_parameter("detailColour", detailLayer.albedo)
	terrain_material.set_shader_parameter("detailTexture", detailLayer.albedoTexture)
	terrain_material.set_shader_parameter("detailNormalMap", detailLayer.normalMap)
	terrain_material.set_shader_parameter("detailTiling", detailLayer.uvTiling)
	
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
	
	terrain_lod_0.visibility_range_end = CellSize/2 + 128
	terrain_lod_0.mesh = generate_lod_mesh(64)
	if EnableCollision:
		terrain_lod_0.create_trimesh_collision()
	terrain_lod_0.material_override = terrain_material

func generate_lod_mesh(verts : int) -> ArrayMesh:
	var arr_mesh : ArrayMesh = ArrayMesh.new()
	var surf = SurfaceTool.new()
	var original_img = HeightMapTexture.get_image()
	var image = original_img.duplicate()
	image.resize(verts + 1, verts + 1, Image.INTERPOLATE_BILINEAR)
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(verts + 1):
		for x in range(verts + 1):
			var y = image.get_pixel(x, z).r * HeightOffset * 4
			var uv = Vector2(float(x) / verts, float(z) / verts)
			surf.set_uv(uv)
			surf.add_vertex(Vector3(x * (CellSize / verts), y, z * (CellSize / verts)))
	
	for z in range(verts):
		for x in range(verts):
			var top_left = z * (verts+1) + x
			var top_right = top_left + 1
			var bottom_left = (z + 1) * (verts+1) + x
			var bottom_right = bottom_left + 1
			surf.add_index(top_left)
			surf.add_index(top_right)
			surf.add_index(bottom_left)
			surf.add_index(top_right)
			surf.add_index(bottom_right)
			surf.add_index(bottom_left)
	surf.generate_normals()
	arr_mesh = surf.commit()
	return arr_mesh


func generate_lod_1():
	terrain_lod_1 = MeshInstance3D.new()
	terrain_lod_1.name = "TerrainCellLOD1"
	terrain_lod_1.visibility_range_begin = CellSize/2 + 128
	terrain_lod_1.visibility_range_end = CellSize * 2
	terrain_lod_1.mesh = generate_lod_mesh(32)
	terrain_lod_1.material_override = terrain_material
	
func generate_lod_2():
	terrain_lod_2 = MeshInstance3D.new()
	terrain_lod_2.name = "TerrainCellLOD2"
	terrain_lod_2.visibility_range_begin = CellSize * 2
	terrain_lod_2.visibility_range_end = CellSize * 3
	terrain_lod_2.mesh = generate_lod_mesh(16)
	terrain_lod_2.material_override = terrain_material

func generate_lod_3():
	terrain_lod_3 = MeshInstance3D.new()
	terrain_lod_3.name = "TerrainCellLOD3"
	terrain_lod_3.visibility_range_begin = CellSize * 3
	terrain_lod_3.visibility_range_end = CellSize * 6
	terrain_lod_3.mesh = generate_lod_mesh(8)
	terrain_lod_3.material_override = terrain_material
	
	
func generate_collider():
	print("TODO")

func scatter_objects():
	print("TODO")
