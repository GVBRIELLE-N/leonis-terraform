@tool
class_name EditorTerrainNode 
extends Node3D

## 3D Terrain Node for generating terrain meshes

@export_category("Terrain Configuration")
@export var height_map_texture 	: Texture2D
@export var height_offset 		: float = 10
@export var seamless 			: bool
@export var clear_stored_meshes	: bool

@export_group("Collision")
@export var enable_collision : bool = true

@export_category("Cell Configuration")
@export_range(512, 1024, 128) var cell_size : int = 1024
var subdivision_steps : int

@export_category("Texture Slots")
@export var splat_0 : splatResource
@export var splat_1 : splatResource
@export var splat_2 : splatResource

@export_category("Scattering Objects")
# TODO:
# Create list for meshes
# Add variable for exported scatter templates
@export var scatter_on_generate : bool = false
@export var mesh_templates 		: Array[ScatterObject] = []
@export var scatter_offset 		: float = 0.0

# Terrain Meshes for exporting
var _terrain_lod_0_mesh : Mesh
var _terrain_lod_1_mesh : Mesh
var _terrain_lod_2_mesh : Mesh
var _terrain_lod_3_mesh : Mesh

# Terrain Mesh instances for instancing
var _terrain_lod_0 : MeshInstance3D
var _terrain_lod_1 : MeshInstance3D
var _terrain_lod_2 : MeshInstance3D
var _terrain_lod_3 : MeshInstance3D

var _terrain_material 		: ShaderMaterial
var _terrain_static_body 	: StaticBody3D

var _export_location = "res://content/terraform/"

# SplatMaps and color channels for edit mode
var _currentSplat	= 0
var _currentChannel = 0
var _active_colour : Color

func _ready():
	await get_tree().process_frame
#	Only generate a mesh if the node has no children
	if get_child_count() == 0:
		generate_terrain_mesh()

func generateSplatMap(splatRes : splatResource):
	var splat_img = Image.new()
	splat_img = splat_img.create(128, 128, false, Image.FORMAT_RGBA8)
	splat_img.fill(Color.BLACK)
	var splat_tex = ImageTexture.new()
	splat_tex = splat_tex.create_from_image(splat_img)
	splatRes.splatMap = splat_tex

func _handleSplatMaps():
	if splat_0 != null && splat_0.splatMap == null:
		generateSplatMap(splat_0)
	if splat_1 != null && splat_1.splatMap == null:
		generateSplatMap(splat_1)
	if splat_2 != null && splat_2.splatMap == null:
		generateSplatMap(splat_2)

func generate_terrain_mesh():
	subdivision_steps = cell_size/128
	if get_child_count() > 0:
		for child in get_children():
			child.free()
	if height_map_texture == null:
		push_warning("Unable to generate mesh without a heightmap texture.")
		return
	_handleSplatMaps()
	_configure_material()
	_generate_terrain_meshses()
	_load_terrain_configs()
	_add_children_and_reposition()
	
func generate_collider():
	print("TODO")
	
func _load_scatter_presets():
#	TODO: Replace
	clear_scattered_objects()
	for e in mesh_templates:
		handle_scatter_objects(e.object_mesh, e.scatter_count, height_map_texture.get_image(), true)
		
func clear_scattered_objects():
	for child in get_children():
		if child is MultiMeshInstance3D:
			child.free()
		
func _add_children_and_reposition():
	var lod_0_root = StaticBody3D.new()
	lod_0_root.add_child(_terrain_lod_0)
	add_child(lod_0_root)
	add_child(_terrain_lod_1)
	add_child(_terrain_lod_2)
	add_child(_terrain_lod_3)
	if scatter_on_generate:
		scatter_objects()
	
func scatter_objects():
	clear_scattered_objects()
	for e in mesh_templates:
		handle_scatter_objects(e.object_mesh, e.scatter_count, height_map_texture.get_image(), false)
	
func handle_scatter_objects(object_mesh: Mesh, count: int, height_map_image: Image,
 load_from_file: bool) -> void:
	# TODO: Save scatter data to file
	# Fix scattering position calculations
	pass

func _updateSplatMaps():
	_terrain_material.set_shader_parameter("splat_0", splat_0.splatMap)
	_terrain_material.set_shader_parameter("spat_1", splat_1.splatMap)
	_terrain_material.set_shader_parameter("splat_2", splat_2.splatMap)

func _configure_material():
	_terrain_material = ShaderMaterial.new()
	_terrain_material.shader = preload("res://addons/leonis_terraform/shaders/terrain_shader.gdshader")
	_terrain_material.set_shader_parameter("heightMapTexture", height_map_texture)
	_terrain_material.set_shader_parameter("heightOffset", height_offset)
	_terrain_material.set_shader_parameter("splat_0", splat_0.splatMap)
	_terrain_material.set_shader_parameter("spat_1", splat_1.splatMap)
	_terrain_material.set_shader_parameter("splat_2", splat_2.splatMap)
	
	_terrain_material.set_shader_parameter("splat_0_0", splat_0.zeroTexture)
	_terrain_material.set_shader_parameter("splat_0_0_uv", splat_0.zeroUv)
	_terrain_material.set_shader_parameter("splat_0_r", splat_0.redTexture)
	_terrain_material.set_shader_parameter("splat_0_r_uv", splat_0.redUv)
	_terrain_material.set_shader_parameter("splat_0_g", splat_0.greenTexture)
	_terrain_material.set_shader_parameter("splat_0_g_uv", splat_0.greenUv)
	_terrain_material.set_shader_parameter("splat_0_b", splat_0.blueTexture)
	_terrain_material.set_shader_parameter("splat_0_b_uv", splat_0.blueUv)
	
	_terrain_material.set_shader_parameter("splat_1_0", splat_1.zeroTexture)
	_terrain_material.set_shader_parameter("splat_1_0_uv", splat_1.zeroUv)
	_terrain_material.set_shader_parameter("splat_1_r", splat_1.redTexture)
	_terrain_material.set_shader_parameter("splat_1_r_uv", splat_1.redUv)
	_terrain_material.set_shader_parameter("splat_1_g", splat_1.greenTexture)
	_terrain_material.set_shader_parameter("splat_1_g_uv", splat_1.greenUv)
	_terrain_material.set_shader_parameter("splat_1_b", splat_1.blueTexture)
	_terrain_material.set_shader_parameter("splat_1_b_uv", splat_1.blueUv)
	
	_terrain_material.set_shader_parameter("splat_2_0", splat_2.zeroTexture)
	_terrain_material.set_shader_parameter("splat_2_0_uv", splat_2.zeroUv)
	_terrain_material.set_shader_parameter("splat_2_r", splat_2.redTexture)
	_terrain_material.set_shader_parameter("splat_2_r_uv", splat_2.redUv)
	_terrain_material.set_shader_parameter("splat_2_g", splat_2.greenTexture)
	_terrain_material.set_shader_parameter("splat_2_g_uv", splat_2.greenUv)
	_terrain_material.set_shader_parameter("splat_2_b", splat_2.blueTexture)
	_terrain_material.set_shader_parameter("splat_2_b_uv", splat_2.blueUv)

func _generate_lod_mesh(verts : int, height_map_tex : Texture2D) -> ArrayMesh:
	# TODO: Change mesh generation approach:
	# Save generated mesh somewhere?
	var arr_mesh : ArrayMesh = ArrayMesh.new()
	var surf = SurfaceTool.new()
	var original_img = height_map_tex.get_image()
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(verts + 1):
		for x in range(verts + 1):
			
			var uv = Vector2(
				float(x if x != verts else 0) / verts, 
				float(z if z != verts else 0) / verts
			)
			var base_uv = Vector2(
				float(x) / verts,
				float(z) / verts
			)
			if !seamless:
				uv = base_uv
			var img_x = original_img.get_width() - 1
			var img_y = original_img.get_height() - 1
			var pix_x = clamp(int(uv.x * img_x), 0.0, img_x)
			var pix_y = clamp(int(uv.y * img_y), 0.0, img_y)
			var y = original_img.get_pixel(pix_x, pix_y).r * height_offset * 4
			surf.set_uv(base_uv)
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
	
func _generate_terrain_meshses():
	if _terrain_lod_0_mesh == null or clear_stored_meshes:
		_terrain_lod_0_mesh = _generate_lod_mesh(128, height_map_texture)
	if _terrain_lod_1_mesh == null or clear_stored_meshes:
		_terrain_lod_1_mesh = _generate_lod_mesh(64, height_map_texture)
	if _terrain_lod_2_mesh == null or clear_stored_meshes:
		_terrain_lod_2_mesh = _generate_lod_mesh(32, height_map_texture)
	if _terrain_lod_3_mesh == null or clear_stored_meshes:
		_terrain_lod_3_mesh = _generate_lod_mesh(16, height_map_texture)

func _load_terrain_configs():
	_config_lod_0()
	_config_lod_1()
	_config_lod_2()
	_config_lod_3()

func _config_lod_0():
	_terrain_lod_0 = MeshInstance3D.new()
	_terrain_lod_0.name = "TerrainCellLOD0"
	
	_terrain_lod_0.visibility_range_end = cell_size/2 + 128
	_terrain_lod_0.mesh = _terrain_lod_0_mesh
	_terrain_lod_0.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
	if enable_collision:
		_terrain_lod_0.create_trimesh_collision()
	_terrain_lod_0.material_override = _terrain_material
	_terrain_static_body = _terrain_lod_0.get_child(0)

func _config_lod_1():
	_terrain_lod_1 = MeshInstance3D.new()
	_terrain_lod_1.name = "TerrainCellLOD1"
	_terrain_lod_1.visibility_range_begin = cell_size/2 + 128
	_terrain_lod_1.visibility_range_end = cell_size * 2
	_terrain_lod_1.mesh = _terrain_lod_1_mesh
	_terrain_lod_1.material_override = _terrain_material
	
func _config_lod_2():
	_terrain_lod_2 = MeshInstance3D.new()
	_terrain_lod_2.name = "TerrainCellLOD2"
	_terrain_lod_2.visibility_range_begin = cell_size * 2
	_terrain_lod_2.visibility_range_end = cell_size * 3
	_terrain_lod_2.mesh = _terrain_lod_2_mesh
	_terrain_lod_2.material_override = _terrain_material

func _config_lod_3():
	_terrain_lod_3 = MeshInstance3D.new()
	_terrain_lod_3.name = "TerrainCellLOD3"
	_terrain_lod_3.visibility_range_begin = cell_size * 3
	_terrain_lod_3.visibility_range_end = cell_size * 6
	_terrain_lod_3.mesh = _terrain_lod_3_mesh
	_terrain_lod_3.material_override = _terrain_material

func export_terrain_mesh():
	var _export_mesh_instance = MeshInstance3D.new()
	_export_mesh_instance.name = "ExportedTerraformCell"
	_export_mesh_instance.mesh = _terrain_lod_0_mesh
	var _temp_export_scene = PackedScene.new()
	var _scene = _temp_export_scene.pack(_export_mesh_instance)
	if _scene == OK:
		print("Scene setup complete!")
		var _location = "res://content/terraform/"+ name +"_export.tscn"
		var err = ResourceSaver.save(_temp_export_scene, _location)
		if err == OK:
			print("Scene exported successfully!")
		else:
			print(err)
	

func _toggle_collision():
	if _terrain_static_body != null:
		if visible == false:
			_terrain_static_body.collision_layer = 0
			_terrain_static_body.collision_mask = 0
		else:
			_terrain_static_body.collision_layer = 1
			_terrain_static_body.collision_mask = 1

func _edit_splatmap(edit_active:bool):
	if edit_active:
	#	Ensure SplatMaps exist before editing
		_handleSplatMaps()
		print("Edit Mode on")
	else:
		print("Edit Mode off")
		
func _paint_texture(mouse_position:Vector3, erase_mode : bool):
#	Ensure SplatMaps exist before editing
	_handleSplatMaps()
	var _splatMaps = {0:splat_0, 1:splat_1, 2:splat_2}
	var uv_coords = Vector2(mouse_position.x/cell_size, mouse_position.z/cell_size)
	var splat_coords = Vector2(uv_coords.x * 128, uv_coords.y * 128)
	var active_splat : splatResource = _splatMaps[_currentSplat]
	var img = active_splat.splatMap.get_image()
	var new_img = img.duplicate()
	if erase_mode:
		new_img.set_pixel(splat_coords.x, splat_coords.y, Color.BLACK)
	else:
		new_img.set_pixel(splat_coords.x, splat_coords.y, _active_colour)
	active_splat.splatMap = ImageTexture.new().create_from_image(new_img)
	_updateSplatMaps()

func _setCurrentChannel(new_channel:int):
	var _colourChannels = {0:Color.RED, 1:Color.GREEN, 2:Color.BLUE}
	_currentChannel = new_channel
	_active_colour = _colourChannels[_currentChannel]

func _setCurrentSplat(new_splat:int):
	var _splatMaps = {0:splat_0, 1:splat_1, 2:splat_2}
	_currentSplat = new_splat
