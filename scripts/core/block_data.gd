class_name BlockData extends Resource

@export var block_id: int = 0
@export var block_name: String = ""
@export var texture_top: Texture2D
@export var texture_side: Texture2D
@export var texture_bottom: Texture2D
@export var is_solid: bool = true
@export var is_transparent: bool = false
@export var hardness: float = 1.0 # Waktu untuk menghancurkan

# Tipe blok Majapahit
enum BlockType {
    AIR,
    TANAH,
    RUMPUT,
    BATU,
    BATA_MERAH,
    KAYU_JATI,
    BAMBU,
    PASIR,
    AIR_BLOCK,
    ANDESIT,
    BESI_ORE,
    EMAS_ORE,
    DAUN,
}