extends Control


func _on_paintgun_button_pressed():
	PlayerData.set_player_loadout.rpc(multiplayer.get_unique_id(), "res://scenes/weapons/paintgun.tscn")


func _on_minigun_button_pressed():
	PlayerData.set_player_loadout.rpc(multiplayer.get_unique_id(), "res://scenes/weapons/minigun.tscn")


func _on_sniper_button_pressed():
	PlayerData.set_player_loadout.rpc(multiplayer.get_unique_id(), "res://scenes/weapons/sniper.tscn")
