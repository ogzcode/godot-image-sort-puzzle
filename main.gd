extends Node2D

@export var source_image: Texture2D

var grid_size = 4
var first_selected_piece = null
var is_swapping = false

@onready var grid_container = $CanvasLayer/GridContainer

@onready var win_label = $CanvasLayer/Label

const piece_scene = preload("res://piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_game(grid_size)
	grid_container.add_theme_constant_override("h_separation", 0)
	grid_container.add_theme_constant_override("v_separation", 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func start_game(n: int) -> void:
	
	for child in grid_container.get_children():
		child.queue_free()

	
	grid_container.columns = n
	var image_size = source_image.get_size()
	var piece_size = image_size / n

	var pieces_list = []

	for i in range(n):
		for j in range(n):
			var piece = piece_scene.instantiate()
			var current_index = i * n + j
			piece.set_meta("correct_id", current_index)

			var label = piece.get_node("Label")
			label.text = str(current_index)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.set_anchors_preset(Control.PRESET_FULL_RECT)

			var atlas = AtlasTexture.new()
			atlas.atlas = source_image
			atlas.region = Rect2(j * piece_size.x, i * piece_size.y, piece_size.x, piece_size.y)

			piece.icon = atlas
			piece.custom_minimum_size = Vector2(150, 150)
			piece.pressed.connect(_on_piece_pressed.bind(piece))

			pieces_list.append(piece)
	
	pieces_list.shuffle()
	for piece in pieces_list:
		grid_container.add_child(piece)

func _on_piece_pressed(piece) -> void:
	if is_swapping:
		return

	if first_selected_piece == null:
		first_selected_piece = piece
		piece.modulate = Color(1, 1, 1, 0.5) # Highlight the selected piece
	else:
		if first_selected_piece == piece:
			piece.modulate = Color(1, 1, 1, 1)
			first_selected_piece = null
			return

		var first_position = first_selected_piece.global_position
		var second_position = piece.global_position

		is_swapping = true
		first_selected_piece.set_as_top_level(true)
		piece.set_as_top_level(true)
		first_selected_piece.z_index = 100
		piece.z_index = 100

		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(first_selected_piece, "global_position", second_position, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(piece, "global_position", first_position, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished

		swap_piece_nodes(first_selected_piece, piece)

		first_selected_piece.set_as_top_level(false)
		piece.set_as_top_level(false)
		first_selected_piece.z_index = 0
		piece.z_index = 0

		first_selected_piece.modulate = Color(1, 1, 1, 1) # Reset the highlight
		first_selected_piece = null
		is_swapping = false

		check_win()

func swap_piece_nodes(piece_a, piece_b) -> void:
	var all_pieces = grid_container.get_children()
	var index_a = all_pieces.find(piece_a)
	var index_b = all_pieces.find(piece_b)

	if index_a == -1 or index_b == -1:
		return

	all_pieces[index_a] = piece_b
	all_pieces[index_b] = piece_a

	for child in all_pieces:
		grid_container.remove_child(child)

	for child in all_pieces:
		grid_container.add_child(child)

func check_win():
	var all_pieces = grid_container.get_children()
	var is_won = true
	
	for i in range(all_pieces.size()):
		var piece = all_pieces[i]
		# Parçanın içindeki kayıtlı 'correct_id' ile şu anki 'i' indeksi tutuyor mu?
		if piece.get_meta("correct_id") != i:
			is_won = false
			break
	
	if is_won:
		print("Tebrikler! Resim tamamlandı.")
		win_label.text = "Tebrikler! Resim tamamlandı."
		# Buraya seviye atlatma veya bir kutlama paneli ekleyebilirsin
		# next_level()
