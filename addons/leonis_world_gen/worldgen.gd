@tool
extends EditorPlugin

var heightgen_menu_controls
var terraingen_menu_controls
var obj

func _enter_tree():
#	Controls and options for HeightmapGen
	heightgen_menu_controls = MenuButton.new()
	heightgen_menu_controls.text = "Heightmap Generator"
	
	var heightgen_pop = heightgen_menu_controls.get_popup()
	heightgen_pop.add_item("Create Preview", 1)
	heightgen_pop.add_item("Remove Preview", 2)
	heightgen_pop.add_item("Export Heightmap", 3)
	
	heightgen_pop.connect("id_pressed", _on_heightmap_option_pressed)
	
#	Controls and options for Terrain Gen
	terraingen_menu_controls = MenuButton.new()
	terraingen_menu_controls.text = "Terrain Generator"
	
	var terraingen_pop = terraingen_menu_controls.get_popup()
	terraingen_pop.add_item("Create Terrain Cell", 1)
	terraingen_pop.add_item("Scatter Objects", 2)
	terraingen_pop.add_item("Set Collision Shape", 3)
	
	terraingen_pop.connect("id_pressed", _on_terrain_option_pressed)
	
#	Create custom nodes
	add_custom_type("TerrainGenerationNode", "Node3D", preload("res://addons/leonis_world_gen/scripts/terrain_generator.gd"), null)
	add_custom_type("HeightMapGenerationNode", "Node3D", preload("res://addons/leonis_world_gen/subtools/heightgen.gd"), null)
	
# Handle pressing a popup option
# Terrain Menu
func _on_terrain_option_pressed(id : int):
	print(id)

#HeightMap Menu
func _on_heightmap_option_pressed(id : int):
	pass
	
func _edit(object : Object):
	
	if object is EditorTerrainNode:
#		Ensure the other control is removed
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, heightgen_menu_controls)
		obj = object
		if terraingen_menu_controls.get_parent():
			terraingen_menu_controls.get_parent().remove_child(terraingen_menu_controls)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, terraingen_menu_controls)
	elif object is EditorHeightGenNode:
	#		Ensure the other control is removed
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, terraingen_menu_controls)
		obj = object
		if heightgen_menu_controls.get_parent():
			heightgen_menu_controls.get_parent().remove_child(heightgen_menu_controls)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, heightgen_menu_controls)
	else:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, heightgen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, terraingen_menu_controls)

func _handles(object):
	return object is EditorTerrainNode || object is EditorHeightGenNode

func _exit_tree():
	terraingen_menu_controls.get_parent().remove_child(terraingen_menu_controls)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, terraingen_menu_controls)
