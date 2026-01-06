extends Node
class_name AssetCatalog

@export var asset_base_url := "https://raw.githubusercontent.com/kenneyNL/kenney-assets/master/"

var resources := {
	"readme": "Kenney assets are CC0. Download manually for production use."
}

func get_attribution() -> String:
	return "Kenney assets are CC0. See https://kenney.nl/assets for downloads."
