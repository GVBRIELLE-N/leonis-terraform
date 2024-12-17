@tool
extends EditorPlugin

var heightgen_menu_controls
var terraingen_menu_controls

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

func _on_terrain_option_pressed(id : int):
	pass

func _on_heightmap_option_pressed(id : int):
	pass

func _exit_tree():
	# Clean-up of the plugin goes here.
	pass
