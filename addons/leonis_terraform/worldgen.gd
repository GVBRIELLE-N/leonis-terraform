@tool
extends EditorPlugin

var _terraingen_menu_controls
var _terraingen_edit_splat
var _splatedit_menu_controls
var _splatchannel_options

var _edit_mode := false
var _mouse_drag := false
var _erase := false
var current_cam
var _curren_mouse_pos

var _obj

func _enter_tree():
	
#	Controls and options for Terrain Gen
	_terraingen_menu_controls = MenuButton.new()
	_terraingen_menu_controls.text = "Terrain Generator"
	
	_terraingen_edit_splat = CheckButton.new()
	_terraingen_edit_splat.text = "Edit Splat"
	
	_splatedit_menu_controls = OptionButton.new()
	_splatedit_menu_controls.text = "Current Splat"
	
	_splatchannel_options = OptionButton.new()
	_splatchannel_options.text = "Channel"
	
	var _terraingen_pop = _terraingen_menu_controls.get_popup()
	_terraingen_pop.add_item("Create Terrain Cell", 1)
	_terraingen_pop.add_item("Scatter Objects", 2)
	_terraingen_pop.add_item("Clear Objects", 3)
	_terraingen_pop.add_item("Set Collision Shape", 4)
	_terraingen_pop.add_item("Export Mesh", 5)
	
	var _splatedit_pop = _splatedit_menu_controls.get_popup()
	_splatedit_pop.add_item("Splat 0", 0)
	_splatedit_pop.add_item("Splat 1", 1)
	_splatedit_pop.add_item("Splat 2", 2)
	
	var _channel_pop = _splatchannel_options.get_popup()
	_channel_pop.add_item("Red", 0)
	_channel_pop.add_item("Green", 1)
	_channel_pop.add_item("Blue", 2)
	
	_terraingen_pop.connect("id_pressed", _on_terrain_option_pressed)
	_terraingen_edit_splat.connect("toggled", _on_edit_toggled)
	_splatedit_pop.connect("id_pressed", _on_splat_map_pressed)
	_channel_pop.connect("id_pressed", _on_channel_selected)
	
#	Create custom nodes
	add_custom_type("TerraformCell", "Node3D", preload("res://addons/leonis_terraform/scripts/terrain_generator.gd"), null)
	
func _on_edit_toggled(pressed: bool):
	if _obj and _obj.has_method("_edit_splatmap"):
		_obj.call("_edit_splatmap", pressed)
	_edit_mode = pressed

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if _edit_mode and _obj:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var m_event := event as InputEventMouseButton
			_erase = m_event.ctrl_pressed
			if event.is_pressed():
				current_cam = viewport_camera
				_mouse_drag = true
				_curren_mouse_pos = event.position
				_handle_gui_paint(viewport_camera, event)
				return EditorPlugin.AFTER_GUI_INPUT_STOP
			else:
				current_cam = null
				_mouse_drag = false
		elif event is InputEventMouseMotion and _mouse_drag:
			_curren_mouse_pos = event.position
			_handle_gui_paint(viewport_camera, event)
			return EditorPlugin.AFTER_GUI_INPUT_STOP
	return EditorPlugin.AFTER_GUI_INPUT_PASS

func _handle_gui_paint(viewport_camera: Camera3D, event: InputEvent) -> void:
	var mouse_coords = event.position
	var from = viewport_camera.project_ray_origin(event.position)
	var to = from + viewport_camera.project_ray_normal(event.position) * 1000
	var sp_state = get_tree().get_root().world_3d.direct_space_state
	var params := PhysicsRayQueryParameters3D.create(from, to)
	var result = sp_state.intersect_ray(params)
	
	if result:
		_obj.call("_paint_texture", result.position, _erase)

func _on_splat_map_pressed(id: int):
	if _obj and _obj.has_method("_setCurrentSplat"):
		_obj.call("_setCurrentSplat", id)
	
func _on_channel_selected(id: int):
	if _obj and _obj.has_method("_setCurrentChannel"):
		_obj.call("_setCurrentChannel", id)

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
			if _obj and _obj.has_method("clear_scattered_objects"):
				_obj.call("clear_scattered_objects")
		4:
			if _obj and _obj.has_method("generate_collider"):
				_obj.call("generate_collider")
		5:
			if _obj and _obj.has_method("export_terrain_mesh"):
				_obj.call("export_terrain_mesh")

func remove_control(control):
	if control and control.get_parent():
		control.get_parent().remove_child(control)

func _edit(object : Object):
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_edit_splat)    
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls) 
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatedit_menu_controls)
	remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
	if object is EditorTerrainNode:               
		remove_control(_terraingen_edit_splat)
		remove_control(_terraingen_menu_controls)
		remove_control(_splatedit_menu_controls)
		remove_control(_splatchannel_options)
		_obj = object
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_edit_splat)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatedit_menu_controls)
		add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
	else:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_edit_splat)    
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatedit_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)

func _handles(object):
	return object is EditorTerrainNode || object is EditorHeightGenNode
	
func _process(delta: float) -> void:
	if _mouse_drag and current_cam:
		var motion_event := InputEventMouseMotion.new()
		motion_event.position = _curren_mouse_pos
		_handle_gui_paint(current_cam, motion_event)

func _exit_tree():
	if _terraingen_menu_controls.get_parent():
		remove_control(_terraingen_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_menu_controls)
	if _terraingen_edit_splat.get_parent():
		remove_control(_terraingen_edit_splat)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _terraingen_edit_splat)
	if _splatedit_menu_controls.get_parent():
		remove_control(_splatedit_menu_controls)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatedit_menu_controls)
	if _splatchannel_options.get_parent():
		remove_control(_splatchannel_options)
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _splatchannel_options)
