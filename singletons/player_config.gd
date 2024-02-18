extends Node



func get_player_name():
	var config = ConfigFile.new()
	config.load("user://paintball_playersettings.cfg")
	return config.get_value("player", "player_name", "")

func set_player_name(new_name):
	var config = ConfigFile.new()
	config.set_value("player", "player_name", new_name)
	config.save("user://paintball_playersettings.cfg")
