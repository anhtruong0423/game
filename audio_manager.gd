extends Node

## AudioManager - Autoload quản lý âm thanh tập trung
## Nhạc nền xuyên suốt game + SFX cho các sự kiện

# Preload âm thanh
var bg_music_stream: AudioStream = preload("res://assets/sounds/nhac_nen_vui_nhon_hoat_hinh_ngan-www_tiengdong_com.mp3")
var pick_sfx_stream: AudioStream = preload("res://assets/sounds/pick_sound.mp3")
var upgrade_sfx_stream: AudioStream = preload("res://assets/sounds/buy_1.mp3")
var gameover_sfx_stream: AudioStream = preload("res://assets/sounds/gameover.mp3")
var levelup_sfx_stream: AudioStream = preload("res://assets/sounds/levelup.mp3")
var dog_bark_stream: AudioStream = preload("res://assets/sounds/tieng_con_cho_sua_ngan_3_tieng-www_tiengdong_com.mp3")
var click_sfx_stream: AudioStream = preload("res://assets/sounds/tieng_click_con_tro_hoat_hinh-www_tiengdong_com.mp3")

# AudioStreamPlayer nodes
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var dog_bark_player: AudioStreamPlayer
var click_player: AudioStreamPlayer


func _ready() -> void:
	# Tạo music player (nhạc nền, loop, bus Music)
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	music_player.volume_db = -10.0
	add_child(music_player)

	# Tạo SFX player (hiệu ứng âm thanh, bus SFX)
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"
	add_child(sfx_player)

	# Tạo dog bark player (riêng để không bị SFX khác ghi đè)
	dog_bark_player = AudioStreamPlayer.new()
	dog_bark_player.name = "DogBarkPlayer"
	dog_bark_player.bus = "SFX"
	dog_bark_player.stream = dog_bark_stream
	add_child(dog_bark_player)

	# Tạo click player (riêng để không bị ghi đè)
	click_player = AudioStreamPlayer.new()
	click_player.name = "ClickPlayer"
	click_player.bus = "SFX"
	click_player.stream = click_sfx_stream
	add_child(click_player)

	# Phát nhạc nền ngay khi game khởi động
	play_music()


## Bắt sự kiện click chuột toàn cục
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		click_player.play()


## Phát nhạc nền (loop)
func play_music() -> void:
	if music_player.playing:
		return
	music_player.stream = bg_music_stream
	music_player.play()
	if not music_player.finished.is_connected(_on_music_finished):
		music_player.finished.connect(_on_music_finished)


## Dừng nhạc nền
func stop_music() -> void:
	music_player.stop()


## Loop nhạc nền khi phát xong
func _on_music_finished() -> void:
	music_player.play()


## Phát SFX nhặt đồ (fruit hoặc milk)
func play_pick_sfx() -> void:
	_play_sfx(pick_sfx_stream)


## Phát SFX nâng cấp / mua vật phẩm
func play_upgrade_sfx() -> void:
	_play_sfx(upgrade_sfx_stream)


## Phát SFX game over
func play_gameover_sfx() -> void:
	_play_sfx(gameover_sfx_stream)


## Phát SFX hoàn thành level
func play_levelup_sfx() -> void:
	_play_sfx(levelup_sfx_stream)


## Phát tiếng chó sủa (dùng player riêng, loop khi đang đuổi)
func play_dog_bark() -> void:
	if dog_bark_player.playing:
		return
	dog_bark_player.play()
	if not dog_bark_player.finished.is_connected(_on_dog_bark_finished):
		dog_bark_player.finished.connect(_on_dog_bark_finished)

## Loop tiếng chó sủa
func _on_dog_bark_finished() -> void:
	# Chỉ loop nếu vẫn đang được gọi (sẽ bị stop khi hết chase)
	if dog_bark_player.playing:
		dog_bark_player.play()

## Dừng tiếng chó sủa
func stop_dog_bark() -> void:
	dog_bark_player.stop()


## Helper: phát một SFX (dừng SFX trước nếu đang phát)
func _play_sfx(stream: AudioStream) -> void:
	sfx_player.stream = stream
	sfx_player.play()
