extends Node2D

var avatar_path = "user://avatar.png"
var original_image: Image
var current_scale = 1.0
var resize_timer: Timer

func _ready():
	$Button.connect("pressed", Callable(self, "_on_button_pressed"))
	
	resize_timer = Timer.new()
	resize_timer.one_shot = true
	resize_timer.connect("timeout", Callable(self, "_on_resize_timer_timeout"))
	add_child(resize_timer)
	
	load_avatar()

func _on_button_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.add_filter("*.png ; PNG files")
	file_dialog.add_filter("*.jpg ; JPG files")
	file_dialog.add_filter("*.jpeg ; JPEG files")
	
	file_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	
	add_child(file_dialog)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_file_selected(path):
	original_image = Image.new()
	original_image.load(path)
	resize_and_display_image()
	save_avatar(original_image)

func resize_and_display_image():
	var resized_image = original_image.duplicate()
	var target_size = $TextureRect.size
	resized_image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	var texture = ImageTexture.create_from_image(resized_image)
	$TextureRect.texture = texture

func save_avatar(image):
	image.save_png(avatar_path)

func load_avatar():
	if FileAccess.file_exists(avatar_path):
		original_image = Image.new()
		original_image.load(avatar_path)
		resize_and_display_image()

func _on_scale_changed(value):
	current_scale = value
	resize_timer.start(0.1)  # Задержка в 0.1 секунды

func _on_resize_timer_timeout():
	if original_image:
		var scaled_image = original_image.duplicate()
		var base_size = $TextureRect.size
		var target_size = base_size * current_scale
		scaled_image.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
		var texture = ImageTexture.create_from_image(scaled_image)
		$TextureRect.texture = texture
