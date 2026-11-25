#!/usr/bin/env godot -s
# Run this script in Godot to generate placeholder sprites
# Usage: godot -s scripts/create_placeholder_sprites.gd

@tool
extends Node

func _init():
	create_player_sprites()
	create_enemy_sprites()
	print("Placeholder sprites created!")

func create_player_sprites() -> void:
	var dir = "assets/sprites/player"
	DirAccess.make_dir_recursive_absolute(dir)

	var colors = {
		"idle_down": Color(0.2, 0.6, 1.0),   # Blue
		"idle_up": Color(0.2, 0.6, 1.0),
		"idle_left": Color(0.2, 0.6, 1.0),
		"idle_right": Color(0.2, 0.6, 1.0),
		"walk_down": Color(0.3, 0.7, 1.0),
		"walk_up": Color(0.3, 0.7, 1.0),
		"walk_left": Color(0.3, 0.7, 1.0),
		"walk_right": Color(0.3, 0.7, 1.0),
		"dash_down": Color(0.5, 0.8, 1.0),
		"dash_up": Color(0.5, 0.8, 1.0),
		"dash_left": Color(0.5, 0.8, 1.0),
		"dash_right": Color(0.5, 0.8, 1.0),
	}

	for anim_name in colors:
		var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))

		var base_color = colors[anim_name]
		var is_walk = anim_name.begins_with("walk")
		var is_dash = anim_name.begins_with("dash")

		# Draw body (circle)
		for y in range(64):
			for x in range(64):
				var dx = x - 32
				var dy = y - 32
				var dist = sqrt(dx * dx + dy * dy)

				if dist < 24:
					var color = base_color
					if is_walk:
						color = base_color.lerp(Color(1, 1, 1), 0.2 * sin(Time.get_ticks_msec() * 0.01))
					elif is_dash:
						color = Color(1, 1, 1, 0.8)

					# Add direction indicator
					var dir = anim_name.get_slice("_", 1)
					if dir == "up" and dy < -10:
						color = Color(1, 1, 0.5)
					elif dir == "down" and dy > 10:
						color = Color(1, 0.5, 0.5)
					elif dir == "left" and dx < -10:
						color = Color(0.5, 1, 0.5)
					elif dir == "right" and dx > 10:
						color = Color(0.5, 0.5, 1)

					img.set_pixel(x, y, color)

		# Draw eyes
		var eye_offset = 0
		match anim_name.get_slice("_", 1):
			"up": eye_offset = -6
			"down": eye_offset = 6
			"left": eye_offset = -6
			"right": eye_offset = 6

		var eye_x = 32 + (anim_name.get_slice("_", 1) == "left" ? -8 : 8)
		var eye_y = 32 + eye_offset
		img.set_pixel(eye_x, eye_y, Color(0, 0, 0))
		img.set_pixel(eye_x + 1, eye_y, Color(0, 0, 0))

		img.save_png("%s/%s.png" % [dir, anim_name])

	# Create sprite frames resource
	var sprite_frames = SpriteFrames.new()
	for anim_name in colors:
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 8 if anim_name.begins_with("walk") else 1)
		sprite_frames.add_frame(anim_name, load("%s/%s.png" % [dir, anim_name]))

	ResourceSaver.save(sprite_frames, "%s/player_sprites.tres" % dir)

func create_enemy_sprites() -> void:
	var enemy_types = ["basic", "ranged", "charger"]
	var enemy_colors = {
		"basic": Color(1.0, 0.3, 0.3),
		"ranged": Color(1.0, 0.6, 0.2),
		"charger": Color(0.8, 0.2, 0.8),
	}

	for enemy_type in enemy_types:
		var dir = "assets/sprites/enemies/%s" % enemy_type
		DirAccess.make_dir_recursive_absolute(dir)

		var base_color = enemy_colors[enemy_type]
		var size = 48 if enemy_type != "charger" else 56

		var anims = ["idle_down", "idle_up", "idle_left", "idle_right",
		             "walk_down", "walk_up", "walk_left", "walk_right",
		             "attack_down", "attack_up", "attack_left", "attack_right"]

		for anim_name in anims:
			var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
			img.fill(Color(0, 0, 0, 0))

			# Draw body
			for y in range(64):
				for x in range(64):
					var dx = x - 32
					var dy = y - 32
					var dist = sqrt(dx * dx + dy * dy)

					if dist < size / 2:
						var color = base_color
						if anim_name.begins_with("attack"):
							color = Color(1, 1, 0.2)  # Yellow flash
						elif anim_name.begins_with("walk"):
							color = base_color.lerp(Color(1, 1, 1), 0.1)

						# Direction indicator
						var dir_name = anim_name.get_slice("_", 1)
						if dir_name == "up" and dy < -size/4:
							color = Color(1, 1, 0)
						elif dir_name == "down" and dy > size/4:
							color = Color(1, 0.5, 0.5)
						elif dir_name == "left" and dx < -size/4:
							color = Color(0.5, 1, 0.5)
						elif dir_name == "right" and dx > size/4:
							color = Color(0.5, 0.5, 1)

						img.set_pixel(x, y, color)

			img.save_png("%s/%s.png" % [dir, anim_name])

		var sprite_frames = SpriteFrames.new()
		for anim_name in anims:
			sprite_frames.add_animation(anim_name)
			sprite_frames.set_animation_speed(anim_name, 8 if anim_name.begins_with("walk") else 1)
			sprite_frames.add_frame(anim_name, load("%s/%s.png" % [dir, anim_name]))

		ResourceSaver.save(sprite_frames, "%s/%s_sprites.tres" % [dir, enemy_type])