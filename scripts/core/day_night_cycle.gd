extends Node3D

@export var day_duration_minutes: float = 10.0 # 10 menit real-time = 1 hari game
@export var sun_light: DirectionalLight3D
@export var moon_light: DirectionalLight3D

# Waktu: 0.0 = tengah malam, 0.25 = sunrise, 0.5 = siang, 0.75 = sunset
var time_of_day: float = 0.3 # Mulai pagi hari

# Warna langit
var sunrise_color := Color(1.0, 0.6, 0.3) # Oranye sunrise
var noon_color := Color(0.5, 0.7, 1.0) # Biru cerah
var sunset_color := Color(1.0, 0.4, 0.2) # Merah sunset
var night_color := Color(0.05, 0.05, 0.15) # Biru gelap malam

func _process(delta: float) -> void:
	# Update waktu
	time_of_day += delta / (day_duration_minutes * 60.0)
	if time_of_day >= 1.0:
		time_of_day -= 1.0
	
	# Rotasi matahari
	if sun_light:
		sun_light.rotation_degrees.x = (time_of_day * 360.0) - 90.0
		
		# Intensitas matahari (hidup saat siang)
		var sun_intensity = clamp(sin(time_of_day * TAU), 0.0, 1.0)
		sun_light.light_energy = sun_intensity * 1.2
		sun_light.visible = sun_intensity > 0.05
	
	# Bulan (berlawanan dengan matahari)
	if moon_light:
		moon_light.rotation_degrees.x = (time_of_day * 360.0) + 90.0
		var moon_intensity = clamp(-sin(time_of_day * TAU), 0.0, 1.0)
		moon_light.light_energy = moon_intensity * 0.3
		moon_light.visible = moon_intensity > 0.05

func get_time_string() -> String:
	# Kembalikan waktu dalam format jam:menit
	var hours = int(time_of_day * 24.0)
	var minutes = int((time_of_day * 24.0 - hours) * 60.0)
	return "%02d:%02d" % [hours, minutes]

func is_night() -> bool:
	return time_of_day < 0.25 or time_of_day > 0.75
