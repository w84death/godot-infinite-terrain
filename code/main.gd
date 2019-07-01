extends Spatial

# P1X
# Directed by Krzysztof Jankowski
# Music by Mirek Harenda
# SoundFont Reader by Yui Kinomoto @arlez80
#
# Copyright(2019) P1X
# https://p1x.in

export var next_scene_bigfile = "main"

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()

func quit_game():
    get_tree().quit()

func next_scene():
    get_tree().change_scene("scenes/big/"+next_scene_bigfile+".tscn")
