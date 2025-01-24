@tool
class_name EditorTerrainNode 
extends Node3D

## 3D Terrain Node for generating terrain meshes

@export_category("Terrain Configuration")
@export var height_map_texture : Texture2D
@export var height_offset : float = 10

@export_group("Collision")
@export var enable_collision : bool = true

@export_category("Cell Configuration")
@export_range(512, 1024, 128) var cell_size : int = 1024
@export_range(1,6) var subdivision_steps : int = 6

@export_category("Terrain Layers")
@export var rock_layer 	: TerrainLayer
@export var ground_layer : TerrainLayer
@export var detail_layer : TerrainLayer

var _terrain_lod_0 : MeshInstance3D
var _terrain_lod_1 : MeshInstance3D
var _terrain_lod_2 : MeshInstance3D
var _terrain_lod_3 : MeshInstance3D

var _terrain_material : ShaderMaterial

func _ready():
	await get_tree().process_frame
#	Only generate a mesh if the node has no children
	if get_child_count() == 0:
		generate_terrain_mesh()

func generate_terrain_mesh():
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	if height_map_texture == null:
		push_warning("Unable to generate mesh without a heightmap texture.")
		return
	_configure_material()
	_generate_lod_0()
	_generate_lod_1()
	_generate_lod_2()
	_generate_lod_3()
	_terrain_lod_0.scale.y = height_offset/4
	_terrain_lod_1.scale.y = height_offset/4
	_terrain_lod_2.scale.y = height_offset/4
	_terrain_lod_3.scale.y = height_offset/4
#	Create a static body for the cell
	_add_children_and_reposition()
	
func generate_collider():
	print("TODO")

func scatter_objects():
	print("TODO")
		
func _add_children_and_reposition():
	var lod_0_root = StaticBody3D.new()
	lod_0_root.add_child(_terrain_lod_0)
	lod_0_root.position.x = -(cell_size / 2)
	lod_0_root.position.z = -(cell_size / 2)
	add_child(lod_0_root)
	_terrain_lod_1.position.x = -(cell_size / 2)
	_terrain_lod_1.position.z = -(cell_size / 2)
	add_child(_terrain_lod_1)
	_terrain_lod_2.position.x = -(cell_size / 2)
	_terrain_lod_2.position.z = -(cell_size / 2)
	add_child(_terrain_lod_2)
	_terrain_lod_3.position.x = -(cell_size / 2)
	_terrain_lod_3.position.z = -(cell_size / 2)
	add_child(_terrain_lod_3)
	
func _configure_material():
	_terrain_material = ShaderMaterial.new()
	_terrain_material.shader = preload("res://addons/leonis_terraform/shaders/terrain_shader.gdshader")
	_terrain_material.set_shader_parameter("heightMapTexture", height_map_texture)
	_terrain_material.set_shader_parameter("heightOffset", height_offset)
#	Top Layer
	_terrain_material.set_shader_parameter("rockColour", rock_layer.albedo)
	_terrain_material.set_shader_parameter("rockTexture", rock_layer.albedoTexture)
	_terrain_material.set_shader_parameter("rockNormalMap", rock_layer.normalMap)
	_terrain_material.set_shader_parameter("rockTiling", rock_layer.uvTiling)
#	ground_layer
	_terrain_material.set_shader_parameter("groundColour", ground_layer.albedo)
	_terrain_material.set_shader_parameter("groundTexture", ground_layer.albedoTexture)
	_terrain_material.set_shader_parameter("groundNormalMap", ground_layer.normalMap)
	_terrain_material.set_shader_parameter("groundTiling", ground_layer.uvTiling)
#	detail_layer
	_terrain_material.set_shader_parameter("detailColour", detail_layer.albedo)
	_terrain_material.set_shader_parameter("detailTexture", detail_layer.albedoTexture)
	_terrain_material.set_shader_parameter("detailNormalMap", detail_layer.normalMap)
	_terrain_material.set_shader_parameter("detailTiling", detail_layer.uvTiling)

func _generate_lod_mesh(verts : int) -> ArrayMesh:
	var arr_mesh : ArrayMesh = ArrayMesh.new()
	var surf = SurfaceTool.new()
	var original_img = height_map_texture.get_image()
	var image = original_img.duplicate()
	image.resize(verts + 1, verts + 1, Image.INTERPOLATE_BILINEAR)
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(verts + 1):
		for x in range(verts + 1):
			var y = image.get_pixel(x, z).r * height_offset * 4
			var uv = Vector2(float(x) / verts, float(z) / verts)
			surf.set_uv(uv)
			surf.add_vertex(Vector3(x * (cell_size / verts), y, z * (cell_size / verts)))
	
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
	
func _generate_lod_0():
	_terrain_lod_0 = MeshInstance3D.new()
	_terrain_lod_0.name = "TerrainCellLOD0"
	
	_terrain_lod_0.visibility_range_end = cell_size/2 + 128
	_terrain_lod_0.mesh = _generate_lod_mesh(128)
	_terrain_lod_0.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	if enable_collision:
		_terrain_lod_0.create_trimesh_collision()
	_terrain_lod_0.material_override = _terrain_material

func _generate_lod_1():
	_terrain_lod_1 = MeshInstance3D.new()
	_terrain_lod_1.name = "TerrainCellLOD1"
	_terrain_lod_1.visibility_range_begin = cell_size/2 + 128
	_terrain_lod_1.visibility_range_end = cell_size * 2
	_terrain_lod_1.mesh = _generate_lod_mesh(32)
	_terrain_lod_1.material_override = _terrain_material
	
func _generate_lod_2():
	_terrain_lod_2 = MeshInstance3D.new()
	_terrain_lod_2.name = "TerrainCellLOD2"
	_terrain_lod_2.visibility_range_begin = cell_size * 2
	_terrain_lod_2.visibility_range_end = cell_size * 3
	_terrain_lod_2.mesh = _generate_lod_mesh(16)
	_terrain_lod_2.material_override = _terrain_material

func _generate_lod_3():
	_terrain_lod_3 = MeshInstance3D.new()
	_terrain_lod_3.name = "TerrainCellLOD3"
	_terrain_lod_3.visibility_range_begin = cell_size * 3
	_terrain_lod_3.visibility_range_end = cell_size * 6
	_terrain_lod_3.mesh = _generate_lod_mesh(8)
	_terrain_lod_3.material_override = _terrain_material
	
	
