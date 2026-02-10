extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var stamina_bar: ProgressBar = $StaminaBar
@onready var time_label: Label = $TimeLabel
@onready var debug_info: Label = $DebugInfo

func update_health(value: float, max_value: float) -> void:
    health_bar.max_value = max_value
    health_bar.value = value

func update_stamina(value: float, max_value: float) -> void:
    stamina_bar.max_value = max_value
    stamina_bar.value = value

func update_time(time_string: String) -> void:
    time_label.text = time_string

func _process(_delta: float) -> void:
    # Debug info: tampilkan FPS dan posisi player
    var fps = Engine.get_frames_per_second()
    debug_info.text = "FPS: %d" % fps