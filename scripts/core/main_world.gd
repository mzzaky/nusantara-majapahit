extends Node3D

func _ready() -> void:
	# Hapus floor placeholder jika masih ada
	# (comment baris ini jika belum menghapus Floor node)
	
	# Generate beberapa chunk untuk test
	for cx in range(-2, 3):      # 5 chunk X
		for cz in range(-2, 3):  # 5 chunk Z
			var chunk = Chunk.new()
			chunk.chunk_position = Vector2i(cx, cz)
			chunk.position = Vector3(cx * 16, 0, cz * 16)
			add_child(chunk)
			chunk.generate_flat(8)
	
	print("World generated! ", get_child_count(), " chunks loaded.")
