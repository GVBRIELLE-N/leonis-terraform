@tool
class_name EditorTerrainNode extends Node3D

@export_category("Terrain Configuration")
@export var HeightMapTexture : Texture2D
@export var HeightOffset : float = 10

@export_category("Cell Configuration")
@export_range(512, 1024, 128) var CellSize : int = 1024
@export_range(1,6) var subdivisionSteps : int = 6

@export_category("Terrain Layers")
@export var topLayer 	: TerrainLayer
@export var middleLayer : TerrainLayer
@export var bottomLayer : TerrainLayer

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
	#generate_lod_1()
	#generate_lod_2()
	terrain_lod_0.scale.y = HeightOffset/4
	#terrain_lod_1.scale.y = HeightOffset/4
	#terrain_lod_2.scale.y = HeightOffset/4
	add_child(terrain_lod_0)
	#add_child(terrain_lod_1)
	#add_child(terrain_lod_2)
	print("Cell generated successfully")
	
	
func configure_material():
	terrain_material = ShaderMaterial.new()
	terrain_material.shader = preload("res://addons/leonis_world_gen/shaders/terrain_shader.gdshader")
	terrain_material.set_shader_parameter("heightMapTexture", HeightMapTexture)
	terrain_material.set_shader_parameter("heightOffset", HeightOffset)
#	Top Layer
	terrain_material.set_shader_parameter("topColour", topLayer.albedo)
	terrain_material.set_shader_parameter("topTexture", topLayer.albedoTexture)
	terrain_material.set_shader_parameter("topNormalMap", topLayer.normalMap)
	terrain_material.set_shader_parameter("topTiling", topLayer.uvTiling)
#	MiddleLayer
	terrain_material.set_shader_parameter("middleColour", middleLayer.albedo)
	terrain_material.set_shader_parameter("middleTexture", middleLayer.albedoTexture)
	terrain_material.set_shader_parameter("middleNormalMap", middleLayer.normalMap)
	terrain_material.set_shader_parameter("middleTiling", middleLayer.uvTiling)
#	BottomLayer
	terrain_material.set_shader_parameter("bottomColour", bottomLayer.albedo)
	terrain_material.set_shader_parameter("bottomTexture", bottomLayer.albedoTexture)
	terrain_material.set_shader_parameter("bottomNormalMap", bottomLayer.normalMap)
	terrain_material.set_shader_parameter("bottomTiling", bottomLayer.uvTiling)
	
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
	terrain_lod_0.mesh = generate_lod_mesh(32)
	terrain_lod_0.material_override = terrain_material

func generate_lod_mesh(verts : int) -> ArrayMesh:
	var arr_mesh : ArrayMesh = ArrayMesh.new()
	var surf = SurfaceTool.new()
	var i = HeightMapTexture.get_image()
	i.resize(verts + 1, verts + 1, Image.INTERPOLATE_BILINEAR) # Ensure the heightmap matches the grid resolution.
	
	surf.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Add vertices and UVs
	for z in range(verts + 1):
		for x in range(verts + 1):
			var y = i.get_pixel(x, z).r * HeightOffset * 4 # Scale height by 10 (adjust as needed)
			# UV mapping (normalized coordinates)
			var uv = Vector2(float(x) / verts, float(z) / verts)
			surf.set_uv(uv)
			surf.add_vertex(Vector3(x * (CellSize / verts), y, z * (CellSize / verts))) # Scale x and z by 10 (adjust as needed)
	
	# Generate indices for the grid
	for z in range(verts): # Loop over quads
		for x in range(verts):
			var top_left = z * (verts+1) + x
			var top_right = top_left + 1
			var bottom_left = (z + 1) * (verts+1) + x
			var bottom_right = bottom_left + 1
			
			# First triangle
			surf.add_index(top_left)
			surf.add_index(top_right)
			surf.add_index(bottom_left)
			
			
			# Second triangle
			surf.add_index(top_right)
			surf.add_index(bottom_right)
			surf.add_index(bottom_left)
			
	
	# Generate normals and commit mesh
	surf.generate_normals()
	arr_mesh = surf.commit()
	return arr_mesh


func generate_lod_1():
	var subd = 8
	if subdivisionSteps > 4:
		subd = 4
	terrain_lod_1 = MeshInstance3D.new()
	terrain_lod_1.name = "TerrainCellLOD1"

	terrain_lod_1.visibility_range_begin = CellSize + 128
	terrain_lod_1.visibility_range_end = CellSize * 2
	terrain_lod_1.mesh = generate_lod_mesh(16)
	
func generate_lod_2():
	var subd = 4
	if subdivisionSteps > 4:
		subd = 2
	terrain_lod_2 = MeshInstance3D.new()
	terrain_lod_2.name = "TerrainCellLOD2"
	
	terrain_lod_2.visibility_range_begin = CellSize * 2
	terrain_lod_2.visibility_range_end = CellSize * 4
	terrain_lod_2.mesh = generate_lod_mesh(8)

func generate_collider():
	print("TODO")

func scatter_objects():
	print("TODO")
