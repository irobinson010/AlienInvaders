extends Node

const MUSIC_FARM_DEFENSE_LOOP := preload("res://assets/audio/music/music_farm_defense_loop.ogg")
const MUSIC_WAVE_WARNING_STING := preload("res://assets/audio/music/music_wave_warning_sting.ogg")
const SFX_WEAPON_LASER_PEW := preload("res://assets/audio/sfx/sfx_weapon_laser_pew.wav")
const SFX_WEAPON_HEAVY_BLAST := preload("res://assets/audio/sfx/sfx_weapon_heavy_blast.wav")
const SFX_WEAPON_ROCKET_LAUNCH := preload("res://assets/audio/sfx/sfx_weapon_rocket_launch.wav")
const SFX_DOG_BARK_ALERT := preload("res://assets/audio/sfx/sfx_dog_bark_alert.wav")
const SFX_DOG_GROWL_GUARD := preload("res://assets/audio/sfx/sfx_dog_growl_guard.wav")
const SFX_ALIEN_CHITTER_IDLE := preload("res://assets/audio/sfx/sfx_alien_chitter_idle.wav")
const SFX_ALIEN_HURT := preload("res://assets/audio/sfx/sfx_alien_hurt.wav")
const SFX_ALIEN_DEATH := preload("res://assets/audio/sfx/sfx_alien_death.wav")
const SFX_ALIEN_BRUTE_ROAR := preload("res://assets/audio/sfx/sfx_alien_brute_roar.wav")
const MUSIC_LOOP_BASE_DB := -14.0
const MUSIC_STING_BASE_DB := -9.0

var music_player: AudioStreamPlayer
var music_sting_player: AudioStreamPlayer
var audio_started := false
var music_volume_level := 1.0
var sfx_volume_level := 1.0
var combat_intensity := 0.0
var target_intensity := 0.0


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.stream = MUSIC_FARM_DEFENSE_LOOP
	music_player.volume_db = MUSIC_LOOP_BASE_DB
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.finished.connect(_on_music_player_finished)
	add_child(music_player)

	music_sting_player = AudioStreamPlayer.new()
	music_sting_player.stream = MUSIC_WAVE_WARNING_STING
	music_sting_player.volume_db = MUSIC_STING_BASE_DB
	music_sting_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_sting_player)

	if DisplayServer.get_name() != "headless" and not OS.has_feature("web"):
		music_player.play()
		audio_started = true
	apply_audio_levels()


func _process(delta: float) -> void:
	combat_intensity = lerpf(combat_intensity, target_intensity, delta * 1.5)
	_apply_intensity()


func _on_music_player_finished() -> void:
	if music_player != null and is_instance_valid(music_player):
		music_player.play()


func ensure_started() -> void:
	if audio_started or DisplayServer.get_name() == "headless":
		return
	if music_player == null or not is_instance_valid(music_player):
		return

	audio_started = true
	if not music_player.playing:
		music_player.play()


func play_sting() -> void:
	if music_sting_player != null and is_instance_valid(music_sting_player):
		music_sting_player.play()


func get_music_volume() -> float:
	return music_volume_level


func set_music_volume(level: float) -> void:
	music_volume_level = clampf(level, 0.0, 1.0)
	apply_audio_levels()


func get_sfx_volume() -> float:
	return sfx_volume_level


func set_sfx_volume(level: float) -> void:
	sfx_volume_level = clampf(level, 0.0, 1.0)


func set_combat_intensity(threat_count: int, max_threats: int) -> void:
	if max_threats <= 0:
		target_intensity = 0.0
	else:
		target_intensity = clampf(float(threat_count) / float(max_threats), 0.0, 1.0)


func pulse_intensity(amount: float = 0.3) -> void:
	combat_intensity = minf(1.0, combat_intensity + amount)


func apply_audio_levels() -> void:
	var music_offset := _volume_level_to_offset_db(music_volume_level)
	if music_player != null and is_instance_valid(music_player):
		music_player.volume_db = MUSIC_LOOP_BASE_DB + music_offset
	if music_sting_player != null and is_instance_valid(music_sting_player):
		music_sting_player.volume_db = MUSIC_STING_BASE_DB + music_offset
	_apply_intensity()


func _apply_intensity() -> void:
	if music_player == null or not is_instance_valid(music_player):
		return
	# Boost volume slightly at high intensity (up to +3db)
	var intensity_db := combat_intensity * 3.0
	var music_offset := _volume_level_to_offset_db(music_volume_level)
	music_player.volume_db = MUSIC_LOOP_BASE_DB + music_offset + intensity_db
	# Speed up pitch slightly at high intensity (1.0 to 1.08)
	music_player.pitch_scale = lerpf(1.0, 1.08, combat_intensity)


func play_positional_sfx(stream: AudioStream, world_position: Vector2, volume_db: float = -3.0, pitch_min: float = 0.97, pitch_max: float = 1.03) -> void:
	if stream == null:
		return
	if sfx_volume_level <= 0.001:
		return

	var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	sfx_player.stream = stream
	sfx_player.global_position = world_position
	sfx_player.volume_db = volume_db + _volume_level_to_offset_db(sfx_volume_level)
	sfx_player.pitch_scale = randf_range(pitch_min, pitch_max)
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
	sfx_player.finished.connect(sfx_player.queue_free)
	add_child(sfx_player)
	sfx_player.play()


func _volume_level_to_offset_db(level: float) -> float:
	if level <= 0.001:
		return -80.0
	return linear_to_db(level)
