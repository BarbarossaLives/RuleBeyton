
@tool
extends EditorScript

func _run():
	var path := "res://Asset/TavernSceneAssets/Tavern_firstfloor_barStools"  # 🔁 Change this to your GLB file path

	var importer := ResourceImporter.get_importer_by_name("scene")
	if not importer:
		push_error("❌ Could not get scene importer.")
		return

	var preset := importer.get_import_preset(path)
	if not preset:
		push_error("❌ Could not load import settings for: " + path)
		return

	var mesh_settings := preset.get("meshes/individual_settings")
	if not mesh_settings:
		push_warning("⚠ No mesh instances found in: " + path)
		return

	# Loop through each mesh and enable physics generation
	for mesh_name in mesh_settings.keys():
		var settings = mesh_settings[mesh_name]
		settings["generate/physics"] = true
		mesh_settings[mesh_name] = settings
		print("✔ Enabled physics on:", mesh_name)

	# Save changes
	preset.set("meshes/individual_settings", mesh_settings)
	importer.reimport(path)
	print("✅ Reimport complete:", path)
