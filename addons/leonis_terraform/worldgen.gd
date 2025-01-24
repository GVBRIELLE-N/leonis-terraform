@tool
extends EditorPlugin

var _heightgen_menu_controls
var _terraingen_menu_controls
var _obj

func _enter_tree():
#	Controls and options for HeightmapGen
	_heightgen_menu_controls = MenuButton.new()
	_heightgen_menu_controls.text = "Heightmap Generator"
	
	var _heightgen_pop = _heightgen_menu_controls.get_popup()
	_heightgen_pop.add_item("Create Preview", 1)
	_heightgen_pop.add_item("Remove Preview", 2)
	_heightgen_pop.add_item("Export Heightmap", 3)
	
	_heightgen_pop.connect("id_pressed", _on_heightmap_option_pressed)
	
#	Controls and options for Terrain Gen
	_terraingen_menu_controls = MenuButton.new()
	_terraingen_menu_controls.text = "Terrain Generator"
	
	var _terraingen_pop = _terraingen_menu_controls.get_popup()
	_terraingen_pop.add_item("Create Terrain Cell", 1)
	_terraingen_pop.add_item("Scatter Objects", 2)
	_terraingen_pop.add_item("Set Collision Shape", 3)
	
	_terraingen_pop.connect("id_pressed", _on_terrain_option_pressed)
	
#	Create custom nodes
	add_custom_type("TerraformCell", "Node3D", preload("res://addons/leonis_world_gen/scripts/terrain_generator.gd"), null)
	add_custom_type("LeonisHeightMap3D", "Node3D", preload("res://addons/leonis_world_gen/subtools/heightgen.gd"), null)
	
# Handle pressing a popup option
# Terrain Menu
func _on_terrain_option_pressed(id : int):
	match id:
		1:
			if _obj and _obj.has_method("generate_terrain_mesh"):
				_obj.call("generate_terrain_mesh")
		2:
			if _obj and _obj.has_method("scatter_objects"):
				_obj.call("scatter_objects")
		3:
			if _obj and _obj.has_method("generate_collider"):
				_obj.call("generate_collider")

#HeightMap Menu
func _on_heightmap_option_pressed(id : int):
	pass
	
func remove_control(control):
	if control and control.get_parent():
		control.get_parent().remove_child(control)

func _edit(object : Object):
	
	if object is EditorTerrainNode:
#		Ensure the other control is removed
		remove_control(_terraingen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _heightgen_menu_controls)
		
		_obj = object                         
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
	elif object is EditorHeightGenNode:
	#		Ensure the other control is removed
		remove_control(_heightgen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
		
		_obj = object
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _heightgen_menu_controls)
	else:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _heightgen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)

func _handles(object):
	return object is EditorTerrainNode || object is EditorHeightGenNode

func _exit_tree():
	if _terraingen_menu_controls.get_parent():
		remove_control(_terraingen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
	
	if _heightgen_menu_controls.get_parent():
		remove_control(_heightgen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _heightgen_menu_controls)
