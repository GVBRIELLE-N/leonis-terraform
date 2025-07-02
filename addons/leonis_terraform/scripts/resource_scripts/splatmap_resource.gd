@tool
class_name splatResource extends Resource

@export var splatMap : Texture2D

@export_group("Default Texture")
@export var zeroTexture : Texture2D
@export var zeroUv : Vector2 = Vector2(1,1)

@export_group("Red Channel")
@export var redTexture : Texture2D
@export var redUv : Vector2 = Vector2(1,1)

@export_group("Green Channel")
@export var greenTexture : Texture2D
@export var greenUv : Vector2 = Vector2(1,1)

@export_group("Blue Channel")
@export var blueTexture : Texture2D
@export var blueUv : Vector2 = Vector2(1,1)
