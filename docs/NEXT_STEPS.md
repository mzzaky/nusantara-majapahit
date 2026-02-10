# 📗 NUSANTARA: MAJAPAHIT — Panduan Development Lanjutan

> *Step-by-step setelah menyelesaikan GETTING_STARTED.md*

---

## 📋 Roadmap Lanjutan

Setelah menyelesaikan GETTING_STARTED.md, kamu sudah punya:
- ✅ Player controller (WASD + mouse)
- ✅ Chunk system dasar (flat terrain)
- ✅ Day/night cycle
- ✅ HUD sederhana

Sekarang kita bangun fitur game yang sesungguhnya:

| Langkah | Fitur | Estimasi |
|---------|-------|----------|
| 8 | World Generation (Noise Terrain) | 1 minggu |
| 9 | Sistem Interaksi Block (Place/Break) | 1 minggu |
| 10 | Inventory System | 1 minggu |
| 11 | Combat System Dasar | 1-2 minggu |
| 12 | NPC & Dialog System | 1-2 minggu |
| 13 | Crafting System | 1 minggu |
| 14 | Quest System | 1-2 minggu |
| 15 | Audio & Polish | 1 minggu |

---

## Langkah 8: World Generation dengan Noise

### 8.1 Konsep

Ganti terrain datar dengan terrain realistis menggunakan **FastNoiseLite** (built-in Godot).

```
Noise Value → Tinggi Terrain → Pilih Block
Tinggi  = noise_2d(x, z) * amplitude + base_height
Block   = RUMPUT (atas), TANAH (tengah), BATU (bawah)
```

### 8.2 Buat World Generator

Buat `res://scripts/world_gen/world_generator.gd`:

```gdscript
class_name WorldGenerator extends Node

var terrain_noise: FastNoiseLite
var cave_noise: FastNoiseLite

@export var world_seed: int = 12345
@export var terrain_amplitude: float = 20.0
@export var terrain_base_height: float = 32.0

func _ready() -> void:
    setup_noise()

func setup_noise() -> void:
    terrain_noise = FastNoiseLite.new()
    terrain_noise.seed = world_seed
    terrain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    terrain_noise.frequency = 0.01        # Semakin kecil = bukit lebih lebar
    terrain_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
    terrain_noise.fractal_octaves = 4     # Detail lapisan noise
    terrain_noise.fractal_lacunarity = 2.0
    terrain_noise.fractal_gain = 0.5

    cave_noise = FastNoiseLite.new()
    cave_noise.seed = world_seed + 100
    cave_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
    cave_noise.frequency = 0.05
    cave_noise.fractal_octaves = 2

func get_height(world_x: float, world_z: float) -> int:
    """Dapatkan tinggi terrain di koordinat dunia"""
    var noise_val = terrain_noise.get_noise_2d(world_x, world_z)
    # noise_val range: -1.0 sampai 1.0
    var height = int(noise_val * terrain_amplitude + terrain_base_height)
    return clampi(height, 1, Chunk.CHUNK_HEIGHT - 1)

func is_cave(world_x: float, world_y: float, world_z: float) -> bool:
    """Cek apakah posisi ini adalah gua"""
    var val = cave_noise.get_noise_3d(world_x, world_y, world_z)
    return val > 0.4  # Threshold gua

func get_block_type(world_x: int, world_y: int, world_z: int) -> int:
    """Tentukan tipe blok berdasarkan posisi"""
    var surface_height = get_height(world_x, world_z)

    if world_y > surface_height:
        return 0  # AIR

    # Cek gua
    if world_y > 2 and world_y < surface_height - 2:
        if is_cave(world_x, world_y, world_z):
            return 0  # AIR (gua)

    if world_y == surface_height:
        if surface_height < 10:
            return 7  # PASIR (pantai)
        return 2      # RUMPUT
    elif world_y > surface_height - 4:
        return 1      # TANAH
    elif world_y <= 2:
        return 3      # BATU (bedrock)
    else:
        # Random ore
        var ore_chance = randf()
        if ore_chance < 0.01:
            return 11 # BESI_ORE
        elif ore_chance < 0.003:
            return 12 # EMAS_ORE
        return 3      # BATU
```

### 8.3 Update Chunk untuk Noise

Tambahkan method baru di `chunk.gd`:

```gdscript
var world_generator: WorldGenerator  # Set dari luar

func generate_terrain() -> void:
    """Generate terrain menggunakan noise"""
    var world_offset_x = chunk_position.x * CHUNK_SIZE
    var world_offset_z = chunk_position.y * CHUNK_SIZE

    for x in CHUNK_SIZE:
        for z in CHUNK_SIZE:
            var wx = world_offset_x + x
            var wz = world_offset_z + z

            for y in CHUNK_HEIGHT:
                blocks[x][y][z] = world_generator.get_block_type(wx, y, wz)

    build_mesh()
```

### 8.4 Update Main World Script

`res://scripts/core/main_world.gd`:
```gdscript
extends Node3D

var world_gen: WorldGenerator
var loaded_chunks: Dictionary = {}
@export var render_distance: int = 4

func _ready() -> void:
    world_gen = WorldGenerator.new()
    add_child(world_gen)
    _generate_initial_world()

func _generate_initial_world() -> void:
    for cx in range(-render_distance, render_distance + 1):
        for cz in range(-render_distance, render_distance + 1):
            _create_chunk(Vector2i(cx, cz))
    print("World generated! Chunks: ", loaded_chunks.size())

func _create_chunk(coord: Vector2i) -> void:
    if coord in loaded_chunks:
        return
    var chunk = Chunk.new()
    chunk.chunk_position = coord
    chunk.position = Vector3(coord.x * Chunk.CHUNK_SIZE, 0, coord.y * Chunk.CHUNK_SIZE)
    chunk.world_generator = world_gen
    add_child(chunk)
    chunk.generate_terrain()
    loaded_chunks[coord] = chunk
```

### 8.5 Test!

Tekan **F5** — kamu akan melihat bukit, lembah, dan gua! 🏔️

> [!TIP]
> Coba ubah `frequency` (0.005 = bukit sangat lebar, 0.05 = terrain bergerigi) dan `terrain_amplitude` (10 = agak datar, 40 = sangat berbukit) di WorldGenerator.

---

## Langkah 9: Sistem Interaksi Block (Place/Break)

### 9.1 Raycast untuk Deteksi Block

Tambahkan **RayCast3D** ke Player scene:

```
Player (CharacterBody3D)
├── ... (yang sudah ada)
├── CameraArm
│   └── Camera3D
│       └── BlockRaycast (RayCast3D)  ← BARU
```

**Setup BlockRaycast:**
- `Target Position`: **(0, 0, -5)** (5 meter ke depan)
- `Enabled`: **true**
- `Collision Mask`: Layer 1

### 9.2 Script Interaksi Block

Buat `res://scripts/player/block_interaction.gd`:

```gdscript
class_name BlockInteraction extends Node

@export var player: CharacterBody3D
@export var raycast: RayCast3D
@export var break_time: float = 0.5  # Detik untuk hancurkan block

var is_breaking: bool = false
var break_timer: float = 0.0
var target_chunk: Chunk = null
var target_block_pos: Vector3i = Vector3i.ZERO

# Block yang dipegang pemain (untuk place)
var selected_block_id: int = 4  # BATA_MERAH default

func _process(delta: float) -> void:
    if not raycast.is_colliding():
        is_breaking = false
        break_timer = 0.0
        return

    # --- BREAK BLOCK (klik kiri, tahan) ---
    if Input.is_action_pressed("attack_light"):
        var collider = raycast.get_collider()
        if collider is Chunk:
            var hit_point = raycast.get_collision_point()
            var hit_normal = raycast.get_collision_normal()
            # Geser sedikit ke dalam block yang di-hit
            var block_world = hit_point - hit_normal * 0.5
            var local_pos = _world_to_block(block_world, collider as Chunk)

            if not is_breaking or target_block_pos != local_pos:
                # Target baru
                target_block_pos = local_pos
                target_chunk = collider as Chunk
                break_timer = 0.0
                is_breaking = true

            break_timer += delta
            if break_timer >= break_time:
                _break_block()
                is_breaking = false
                break_timer = 0.0
    else:
        is_breaking = false
        break_timer = 0.0

    # --- PLACE BLOCK (klik kanan, sekali tekan) ---
    if Input.is_action_just_pressed("attack_heavy"):
        var collider = raycast.get_collider()
        if collider is Chunk:
            var hit_point = raycast.get_collision_point()
            var hit_normal = raycast.get_collision_normal()
            # Geser ke sisi berlawanan (tempat block baru)
            var place_world = hit_point + hit_normal * 0.5
            _place_block(place_world)

func _break_block() -> void:
    if target_chunk == null:
        return
    var p = target_block_pos
    if _is_valid_pos(p):
        target_chunk.blocks[p.x][p.y][p.z] = 0  # Jadikan AIR
        target_chunk.rebuild_mesh()
        print("Block broken at: ", p)

func _place_block(world_pos: Vector3) -> void:
    # Tentukan chunk mana yang ditargetkan
    var chunk_x = floori(world_pos.x / Chunk.CHUNK_SIZE)
    var chunk_z = floori(world_pos.z / Chunk.CHUNK_SIZE)
    # Cari chunk (simple: iterate children)
    for child in get_parent().get_parent().get_children():
        if child is Chunk and child.chunk_position == Vector2i(chunk_x, chunk_z):
            var local = _world_to_block(world_pos, child)
            if _is_valid_pos(local) and child.blocks[local.x][local.y][local.z] == 0:
                child.blocks[local.x][local.y][local.z] = selected_block_id
                child.rebuild_mesh()
                print("Block placed at: ", local)
            return

func _world_to_block(world_pos: Vector3, chunk: Chunk) -> Vector3i:
    var local = world_pos - chunk.position
    return Vector3i(
        floori(local.x),
        floori(local.y),
        floori(local.z)
    )

func _is_valid_pos(p: Vector3i) -> bool:
    return (p.x >= 0 and p.x < Chunk.CHUNK_SIZE and
            p.y >= 0 and p.y < Chunk.CHUNK_HEIGHT and
            p.z >= 0 and p.z < Chunk.CHUNK_SIZE)
```

### 9.3 Tambahkan ke Chunk: rebuild_mesh()

Tambahkan method ini di `chunk.gd`:

```gdscript
func rebuild_mesh() -> void:
    """Hapus mesh lama, bangun ulang"""
    # Hapus semua child (mesh & collision)
    for child in get_children():
        child.queue_free()
    # Bangun ulang
    build_mesh()
```

### 9.4 Wiring

1. Tambahkan `BlockInteraction` sebagai node child di Player
2. Attach script `block_interaction.gd`
3. Di Inspector, assign `player` dan `raycast`

---

## Langkah 10: Inventory System

### 10.1 Item Database

Buat `res://scripts/core/item_database.gd`:

```gdscript
class_name ItemDatabase extends Node

# Singleton — akses via: ItemDatabase.get_item(id)
static var items: Dictionary = {}

static func _static_init() -> void:
    _register_items()

static func _register_items() -> void:
    # Format: id, nama, tipe, stack_max, icon_path
    _add("tanah", "Tanah", "block", 64, 1)
    _add("rumput", "Blok Rumput", "block", 64, 2)
    _add("batu", "Batu", "block", 64, 3)
    _add("bata_merah", "Bata Merah", "block", 64, 4)
    _add("kayu_jati", "Kayu Jati", "block", 64, 5)
    _add("bambu", "Bambu", "block", 64, 6)
    _add("besi_ore", "Bijih Besi", "material", 32, 10)
    _add("emas_ore", "Bijih Emas", "material", 16, 11)
    _add("keris_basic", "Keris Sederhana", "weapon", 1, 100)
    _add("tombak_bambu", "Tombak Bambu", "weapon", 1, 101)
    _add("roti_beras", "Roti Beras", "consumable", 16, 200)
    _add("jamu_merah", "Jamu Merah", "consumable", 8, 201)

static func _add(id: String, nama: String, tipe: String,
                  max_stack: int, block_id: int = -1) -> void:
    items[id] = {
        "id": id,
        "name": nama,
        "type": tipe,
        "max_stack": max_stack,
        "block_id": block_id
    }

static func get_item(id: String) -> Dictionary:
    return items.get(id, {})
```

### 10.2 Inventory Core

Buat `res://scripts/player/inventory.gd`:

```gdscript
class_name Inventory extends Node

signal inventory_changed()

const MAX_SLOTS: int = 36
const HOTBAR_SIZE: int = 9

var slots: Array = []  # Array of { "item_id": String, "amount": int }
var selected_hotbar: int = 0

func _ready() -> void:
    # Inisialisasi slot kosong
    slots.resize(MAX_SLOTS)
    for i in MAX_SLOTS:
        slots[i] = { "item_id": "", "amount": 0 }

    # Beri item awal untuk testing
    add_item("bata_merah", 32)
    add_item("kayu_jati", 16)
    add_item("keris_basic", 1)

func add_item(item_id: String, amount: int = 1) -> int:
    """Tambah item. Return sisa yang tidak muat."""
    var item_data = ItemDatabase.get_item(item_id)
    if item_data.is_empty():
        return amount

    var remaining = amount
    var max_stack = item_data.get("max_stack", 64)

    # Cari slot existing yang belum penuh
    for i in MAX_SLOTS:
        if remaining <= 0:
            break
        if slots[i].item_id == item_id and slots[i].amount < max_stack:
            var can_add = mini(remaining, max_stack - slots[i].amount)
            slots[i].amount += can_add
            remaining -= can_add

    # Cari slot kosong
    for i in MAX_SLOTS:
        if remaining <= 0:
            break
        if slots[i].item_id == "" or slots[i].amount <= 0:
            var can_add = mini(remaining, max_stack)
            slots[i] = { "item_id": item_id, "amount": can_add }
            remaining -= can_add

    inventory_changed.emit()
    return remaining  # 0 = semua masuk

func remove_item(item_id: String, amount: int = 1) -> bool:
    """Hapus item. Return true jika berhasil."""
    if count_item(item_id) < amount:
        return false

    var to_remove = amount
    for i in range(MAX_SLOTS - 1, -1, -1):  # Dari belakang
        if to_remove <= 0:
            break
        if slots[i].item_id == item_id:
            var take = mini(to_remove, slots[i].amount)
            slots[i].amount -= take
            to_remove -= take
            if slots[i].amount <= 0:
                slots[i] = { "item_id": "", "amount": 0 }

    inventory_changed.emit()
    return true

func count_item(item_id: String) -> int:
    var total = 0
    for slot in slots:
        if slot.item_id == item_id:
            total += slot.amount
    return total

func get_selected_item() -> Dictionary:
    """Item yang aktif di hotbar"""
    return slots[selected_hotbar]

func _unhandled_input(event: InputEvent) -> void:
    # Scroll wheel untuk ganti hotbar slot
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            selected_hotbar = (selected_hotbar - 1 + HOTBAR_SIZE) % HOTBAR_SIZE
            inventory_changed.emit()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            selected_hotbar = (selected_hotbar + 1) % HOTBAR_SIZE
            inventory_changed.emit()

    # Tombol angka 1-9 untuk pilih slot
    if event is InputEventKey and event.pressed:
        var key = event.keycode
        if key >= KEY_1 and key <= KEY_9:
            selected_hotbar = key - KEY_1
            inventory_changed.emit()
```

### 10.3 UI Inventory — Hotbar

Buat scene `res://scenes/ui/hotbar.tscn` (Control node):

```
Hotbar (HBoxContainer)
├── Slot0 (Panel)  ├── Slot1 (Panel) ... ├── Slot8 (Panel)
```

Script `res://scripts/ui/hotbar_ui.gd`:

```gdscript
extends HBoxContainer

@export var inventory: Inventory
var slot_panels: Array = []

func _ready() -> void:
    # Buat 9 slot UI
    for i in Inventory.HOTBAR_SIZE:
        var panel = Panel.new()
        panel.custom_minimum_size = Vector2(50, 50)
        var label = Label.new()
        label.name = "ItemLabel"
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        panel.add_child(label)
        add_child(panel)
        slot_panels.append(panel)

    if inventory:
        inventory.inventory_changed.connect(_update_display)
        _update_display()

func _update_display() -> void:
    for i in slot_panels.size():
        var slot = inventory.slots[i]
        var label = slot_panels[i].get_node("ItemLabel") as Label
        if slot.item_id != "":
            var data = ItemDatabase.get_item(slot.item_id)
            label.text = "%s\n%d" % [data.get("name", "?"), slot.amount]
        else:
            label.text = ""

        # Highlight slot terpilih
        var style = StyleBoxFlat.new()
        if i == inventory.selected_hotbar:
            style.bg_color = Color(1.0, 0.85, 0.3, 0.8)  # Emas
        else:
            style.bg_color = Color(0.2, 0.15, 0.1, 0.7)   # Coklat gelap
        style.border_color = Color(0.6, 0.5, 0.3)
        style.set_border_width_all(2)
        style.set_corner_radius_all(4)
        slot_panels[i].add_theme_stylebox_override("panel", style)
```

---

## Langkah 11: Combat System Dasar

### 11.1 Stats System

Buat `res://scripts/core/stats.gd`:

```gdscript
class_name Stats extends Node

signal health_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal died()

@export var max_health: float = 100.0
@export var max_stamina: float = 100.0
@export var stamina_regen: float = 15.0  # Per detik
@export var defense: float = 5.0

var health: float
var stamina: float
var is_dead: bool = false

func _ready() -> void:
    health = max_health
    stamina = max_stamina

func _process(delta: float) -> void:
    # Regenerasi stamina
    if stamina < max_stamina:
        stamina = minf(stamina + stamina_regen * delta, max_stamina)
        stamina_changed.emit(stamina, max_stamina)

func take_damage(amount: float) -> void:
    if is_dead:
        return
    var actual_damage = maxf(amount - defense, 1.0)
    health -= actual_damage
    health_changed.emit(health, max_health)
    if health <= 0:
        health = 0
        is_dead = true
        died.emit()

func heal(amount: float) -> void:
    health = minf(health + amount, max_health)
    health_changed.emit(health, max_health)

func use_stamina(amount: float) -> bool:
    """Gunakan stamina. Return false jika tidak cukup."""
    if stamina < amount:
        return false
    stamina -= amount
    stamina_changed.emit(stamina, max_stamina)
    return true
```

### 11.2 Weapon Data

Buat `res://scripts/combat/weapon_data.gd`:

```gdscript
class_name WeaponData extends Resource

@export var weapon_name: String = ""
@export var damage: float = 10.0
@export var attack_speed: float = 1.0     # Serangan per detik
@export var stamina_cost: float = 10.0
@export var range_distance: float = 2.0
@export var knockback: float = 3.0
@export var combo_max: int = 3

enum WeaponType { KERIS, KLEWANG, TOMBAK, KARAMBIT, GADA, BUSUR }
@export var weapon_type: WeaponType = WeaponType.KERIS
```

### 11.3 Combat Controller

Buat `res://scripts/combat/combat_controller.gd`:

```gdscript
class_name CombatController extends Node

@export var stats: Stats
@export var weapon_raycast: RayCast3D  # Deteksi musuh di depan

enum CombatState { IDLE, ATTACKING, BLOCKING, DODGING, STAGGERED }
var state: CombatState = CombatState.IDLE

var current_weapon: WeaponData
var combo_counter: int = 0
var attack_cooldown: float = 0.0
var combo_reset_timer: float = 0.0

func _ready() -> void:
    # Weapon default
    current_weapon = WeaponData.new()
    current_weapon.weapon_name = "Keris Sederhana"
    current_weapon.damage = 15.0
    current_weapon.attack_speed = 1.5
    current_weapon.stamina_cost = 8.0
    current_weapon.combo_max = 3

func _process(delta: float) -> void:
    # Cooldown
    if attack_cooldown > 0:
        attack_cooldown -= delta

    if combo_reset_timer > 0:
        combo_reset_timer -= delta
        if combo_reset_timer <= 0:
            combo_counter = 0

    # Input
    if state == CombatState.IDLE or state == CombatState.ATTACKING:
        if Input.is_action_just_pressed("attack_light"):
            _light_attack()
        elif Input.is_action_just_pressed("attack_heavy"):
            _heavy_attack()
        elif Input.is_action_pressed("block"):
            state = CombatState.BLOCKING
    
    if Input.is_action_just_released("block"):
        if state == CombatState.BLOCKING:
            state = CombatState.IDLE

    if Input.is_action_just_pressed("dodge"):
        _dodge()

func _light_attack() -> void:
    if attack_cooldown > 0:
        return
    if not stats.use_stamina(current_weapon.stamina_cost):
        return  # Stamina habis

    state = CombatState.ATTACKING
    combo_counter = (combo_counter + 1) % (current_weapon.combo_max + 1)
    if combo_counter == 0:
        combo_counter = 1

    var damage = current_weapon.damage * (1.0 + combo_counter * 0.15)
    _apply_damage_to_target(damage)

    attack_cooldown = 1.0 / current_weapon.attack_speed
    combo_reset_timer = 1.5  # Reset combo setelah 1.5 detik idle
    
    # Kembali ke idle setelah animasi
    await get_tree().create_timer(0.3).timeout
    state = CombatState.IDLE

func _heavy_attack() -> void:
    if attack_cooldown > 0:
        return
    if not stats.use_stamina(current_weapon.stamina_cost * 2.0):
        return

    state = CombatState.ATTACKING
    var damage = current_weapon.damage * 2.5
    _apply_damage_to_target(damage)
    combo_counter = 0  # Heavy attack reset combo

    attack_cooldown = 1.5 / current_weapon.attack_speed
    
    await get_tree().create_timer(0.6).timeout
    state = CombatState.IDLE

func _dodge() -> void:
    if not stats.use_stamina(15.0):
        return
    state = CombatState.DODGING
    # Dodge movement ditangani di player controller
    await get_tree().create_timer(0.4).timeout
    state = CombatState.IDLE

func _apply_damage_to_target(damage: float) -> void:
    if weapon_raycast and weapon_raycast.is_colliding():
        var target = weapon_raycast.get_collider()
        if target.has_method("take_damage"):
            target.take_damage(damage)
            print("Hit! Damage: ", damage, " Combo: ", combo_counter)
```

### 11.4 Enemy Sederhana

Buat `res://scripts/npc/enemy_basic.gd`:

```gdscript
extends CharacterBody3D

@export var move_speed: float = 3.0
@export var detection_range: float = 15.0
@export var attack_range: float = 2.0
@export var attack_damage: float = 10.0
@export var attack_cooldown: float = 1.5

@onready var stats: Stats = $Stats
var player: Node3D = null
var attack_timer: float = 0.0

enum State { IDLE, CHASE, ATTACK, DEAD }
var state: State = State.IDLE

func _ready() -> void:
    # Stats node harus ada sebagai child
    stats.died.connect(_on_died)
    # Cari player
    await get_tree().process_frame
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    if state == State.DEAD:
        return

    if player == null:
        return

    var dist = global_position.distance_to(player.global_position)

    match state:
        State.IDLE:
            if dist < detection_range:
                state = State.CHASE
        State.CHASE:
            if dist > detection_range * 1.5:
                state = State.IDLE
            elif dist < attack_range:
                state = State.ATTACK
            else:
                # Jalan ke player
                var dir = (player.global_position - global_position).normalized()
                dir.y = 0
                velocity = dir * move_speed
                velocity.y -= 20.0 * delta  # Gravity
                move_and_slide()
                look_at(player.global_position)
        State.ATTACK:
            if dist > attack_range * 1.5:
                state = State.CHASE
            else:
                attack_timer -= delta
                if attack_timer <= 0:
                    _do_attack()
                    attack_timer = attack_cooldown

func take_damage(amount: float) -> void:
    stats.take_damage(amount)
    state = State.CHASE  # Aggro jika di-hit

func _do_attack() -> void:
    if player and player.has_node("Stats"):
        var player_stats = player.get_node("Stats") as Stats
        player_stats.take_damage(attack_damage)
        print("Enemy attacks player! Damage: ", attack_damage)

func _on_died() -> void:
    state = State.DEAD
    print("Enemy defeated!")
    # Drop item, animasi mati, dll
    await get_tree().create_timer(2.0).timeout
    queue_free()
```

> [!TIP]
> Jangan lupa tambahkan Player ke group **"player"**: pilih node Player → tab Node → Groups → ketik "player" → Add.

---

## Langkah 12: NPC & Dialog System

### 12.1 Dialog Data (JSON)

Buat `res://data/dialogs/npc_pandai_besi.json`:

```json
{
    "npc_name": "Empu Darmaji",
    "npc_title": "Pandai Besi Trowulan",
    "dialogs": {
        "greeting": {
            "text": "Selamat datang, anak muda! Aku Empu Darmaji, pandai besi terbaik di Trowulan.",
            "options": [
                { "text": "Saya ingin menempa senjata.", "next": "crafting_intro" },
                { "text": "Ceritakan tentang Keris.", "next": "keris_lore" },
                { "text": "Selamat tinggal.", "next": null }
            ]
        },
        "crafting_intro": {
            "text": "Kau butuh bahan: bijih besi dan kayu jati. Bawa kemari dan aku akan membuatkan keris untukmu.",
            "options": [
                { "text": "Baik, saya akan mencarinya.", "next": null },
                { "text": "Berapa banyak yang dibutuhkan?", "next": "crafting_detail" }
            ]
        },
        "keris_lore": {
            "text": "Keris bukan sekadar senjata. Ia memiliki jiwa. Setiap lekukan bilahnya menyimpan kekuatan leluhur.",
            "options": [
                { "text": "Menarik! Terima kasih.", "next": null }
            ]
        },
        "crafting_detail": {
            "text": "Untuk satu Keris Sederhana, aku butuh 5 Bijih Besi dan 2 Kayu Jati. Bawa dan aku mulai menempa.",
            "options": [
                { "text": "Saya mengerti.", "next": null }
            ]
        }
    }
}
```

### 12.2 Dialog Manager

Buat `res://scripts/core/dialog_manager.gd` (Autoload Singleton):

```gdscript
extends Node

signal dialog_started(npc_name: String)
signal dialog_text(text: String, options: Array)
signal dialog_ended()

var current_dialog_data: Dictionary = {}
var current_node_id: String = ""
var is_active: bool = false

func start_dialog(dialog_path: String) -> void:
    var file = FileAccess.open(dialog_path, FileAccess.READ)
    if file == null:
        push_error("Dialog file not found: " + dialog_path)
        return

    current_dialog_data = JSON.parse_string(file.get_as_text())
    current_node_id = "greeting"
    is_active = true

    # Kunci player movement
    Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
    dialog_started.emit(current_dialog_data.get("npc_name", "???"))
    _show_current_node()

func select_option(index: int) -> void:
    if not is_active:
        return

    var dialogs = current_dialog_data.get("dialogs", {})
    var node = dialogs.get(current_node_id, {})
    var options = node.get("options", [])

    if index >= options.size():
        return

    var next = options[index].get("next")
    if next == null:
        end_dialog()
    else:
        current_node_id = next
        _show_current_node()

func end_dialog() -> void:
    is_active = false
    current_dialog_data = {}
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    dialog_ended.emit()

func _show_current_node() -> void:
    var dialogs = current_dialog_data.get("dialogs", {})
    var node = dialogs.get(current_node_id, {})
    var text = node.get("text", "...")
    var options = node.get("options", [])
    dialog_text.emit(text, options)
```

**Setup Autoload:** Project > Project Settings > Autoload → tambahkan `dialog_manager.gd` dengan nama `DialogManager`.

### 12.3 Dialog UI

Buat `res://scripts/ui/dialog_ui.gd`:

```gdscript
extends PanelContainer

@onready var npc_name_label: Label = $VBox/NPCName
@onready var text_label: Label = $VBox/DialogText
@onready var options_container: VBoxContainer = $VBox/Options

func _ready() -> void:
    visible = false
    DialogManager.dialog_started.connect(_on_started)
    DialogManager.dialog_text.connect(_on_text)
    DialogManager.dialog_ended.connect(_on_ended)

func _on_started(npc_name: String) -> void:
    npc_name_label.text = npc_name
    visible = true

func _on_text(text: String, options: Array) -> void:
    text_label.text = text
    # Hapus tombol lama
    for child in options_container.get_children():
        child.queue_free()
    # Buat tombol baru
    for i in options.size():
        var btn = Button.new()
        btn.text = options[i].get("text", "...")
        btn.pressed.connect(func(): DialogManager.select_option(i))
        options_container.add_child(btn)

func _on_ended() -> void:
    visible = false
```

### 12.4 NPC Interactable

Buat `res://scripts/npc/npc_interactable.gd`:

```gdscript
extends CharacterBody3D

@export var npc_name: String = "NPC"
@export var dialog_file: String = "res://data/dialogs/npc_pandai_besi.json"
@export var interaction_range: float = 3.0

func interact() -> void:
    """Dipanggil saat pemain tekan E di dekat NPC"""
    DialogManager.start_dialog(dialog_file)
```

Tambahkan di player controller — deteksi tekan **E** di dekat NPC:

```gdscript
# Tambahkan di player_controller.gd _physics_process()
if Input.is_action_just_pressed("interact"):
    _try_interact()

func _try_interact() -> void:
    # Cek NPC terdekat
    for body in get_tree().get_nodes_in_group("npc"):
        if global_position.distance_to(body.global_position) < 3.0:
            if body.has_method("interact"):
                body.interact()
                return
```

---

## Langkah 13: Crafting System

### 13.1 Recipe Data

Buat `res://data/recipes/recipes.json`:

```json
{
    "recipes": [
        {
            "id": "keris_basic",
            "name": "Keris Sederhana",
            "station": "anvil",
            "ingredients": [
                { "item_id": "besi_ore", "amount": 5 },
                { "item_id": "kayu_jati", "amount": 2 }
            ],
            "result": { "item_id": "keris_basic", "amount": 1 },
            "craft_time": 3.0
        },
        {
            "id": "tombak_bambu",
            "name": "Tombak Bambu",
            "station": "workbench",
            "ingredients": [
                { "item_id": "bambu", "amount": 3 },
                { "item_id": "batu", "amount": 1 }
            ],
            "result": { "item_id": "tombak_bambu", "amount": 1 },
            "craft_time": 2.0
        },
        {
            "id": "bata_merah",
            "name": "Bata Merah",
            "station": "none",
            "ingredients": [
                { "item_id": "tanah", "amount": 4 }
            ],
            "result": { "item_id": "bata_merah", "amount": 4 },
            "craft_time": 1.0
        }
    ]
}
```

### 13.2 Crafting Manager

Buat `res://scripts/crafting/crafting_manager.gd`:

```gdscript
extends Node

var recipes: Array = []

func _ready() -> void:
    _load_recipes()

func _load_recipes() -> void:
    var file = FileAccess.open("res://data/recipes/recipes.json", FileAccess.READ)
    if file:
        var data = JSON.parse_string(file.get_as_text())
        recipes = data.get("recipes", [])
        print("Loaded ", recipes.size(), " recipes")

func can_craft(recipe_id: String, inventory: Inventory) -> bool:
    """Cek apakah bahan cukup"""
    var recipe = _find_recipe(recipe_id)
    if recipe.is_empty():
        return false
    for ingredient in recipe.get("ingredients", []):
        if inventory.count_item(ingredient.item_id) < ingredient.amount:
            return false
    return true

func craft(recipe_id: String, inventory: Inventory) -> bool:
    """Lakukan crafting. Return true jika berhasil."""
    if not can_craft(recipe_id, inventory):
        return false
    var recipe = _find_recipe(recipe_id)
    # Kurangi bahan
    for ingredient in recipe.get("ingredients", []):
        inventory.remove_item(ingredient.item_id, ingredient.amount)
    # Tambah hasil
    var result = recipe.get("result", {})
    inventory.add_item(result.item_id, result.amount)
    print("Crafted: ", recipe.get("name", "?"))
    return true

func get_available_recipes(inventory: Inventory, station: String = "none") -> Array:
    """Daftar recipe yang bisa dibuat sekarang"""
    var available = []
    for recipe in recipes:
        if recipe.get("station", "none") == station or station == "all":
            available.append({
                "recipe": recipe,
                "can_craft": can_craft(recipe.id, inventory)
            })
    return available

func _find_recipe(recipe_id: String) -> Dictionary:
    for recipe in recipes:
        if recipe.get("id", "") == recipe_id:
            return recipe
    return {}
```

**Setup Autoload:** tambahkan `crafting_manager.gd` sebagai `CraftingManager`.

---

## Langkah 14: Quest System

### 14.1 Quest Data

Buat `res://data/quests/quest_act1_01.json`:

```json
{
    "quest_id": "act1_melarikan_diri",
    "title": "Melarikan Diri dari Kediri",
    "description": "Prajurit Jayakatwang menyerang! Larilah ke hutan dan temukan tempat aman.",
    "act": 1,
    "type": "main",
    "objectives": [
        {
            "id": "obj_1",
            "type": "reach_location",
            "description": "Lari ke tepi hutan",
            "target": "forest_edge_marker",
            "completed": false
        },
        {
            "id": "obj_2",
            "type": "talk_to",
            "description": "Bicara dengan Raden Wijaya",
            "target": "npc_raden_wijaya",
            "completed": false
        },
        {
            "id": "obj_3",
            "type": "collect",
            "description": "Kumpulkan 10 Bambu untuk membuat shelter",
            "target": "bambu",
            "amount": 10,
            "current": 0,
            "completed": false
        }
    ],
    "rewards": {
        "xp": 100,
        "items": [
            { "item_id": "keris_basic", "amount": 1 }
        ]
    },
    "next_quest": "act1_bertemu_wiraraja"
}
```

### 14.2 Quest Manager

Buat `res://scripts/quest/quest_manager.gd` (Autoload):

```gdscript
extends Node

signal quest_accepted(quest_id: String)
signal quest_updated(quest_id: String, objective_id: String)
signal quest_completed(quest_id: String)

var active_quests: Dictionary = {}   # quest_id → quest data
var completed_quests: Array = []

func accept_quest(quest_path: String) -> void:
    var file = FileAccess.open(quest_path, FileAccess.READ)
    if file == null:
        return
    var quest = JSON.parse_string(file.get_as_text())
    var quest_id = quest.get("quest_id", "")
    if quest_id in active_quests or quest_id in completed_quests:
        return  # Sudah aktif atau selesai
    active_quests[quest_id] = quest
    quest_accepted.emit(quest_id)
    print("Quest accepted: ", quest.get("title", ""))

func update_objective(quest_id: String, objective_id: String,
                       progress: int = 1) -> void:
    if quest_id not in active_quests:
        return
    var quest = active_quests[quest_id]
    for obj in quest.get("objectives", []):
        if obj.id == objective_id and not obj.completed:
            match obj.type:
                "collect":
                    obj.current = mini(obj.current + progress, obj.amount)
                    if obj.current >= obj.amount:
                        obj.completed = true
                "reach_location", "talk_to", "kill":
                    obj.completed = true
            quest_updated.emit(quest_id, objective_id)
            break
    _check_completion(quest_id)

func _check_completion(quest_id: String) -> void:
    var quest = active_quests[quest_id]
    var all_done = true
    for obj in quest.get("objectives", []):
        if not obj.completed:
            all_done = false
            break
    if all_done:
        _complete_quest(quest_id)

func _complete_quest(quest_id: String) -> void:
    var quest = active_quests[quest_id]
    completed_quests.append(quest_id)
    active_quests.erase(quest_id)
    quest_completed.emit(quest_id)
    print("Quest completed: ", quest.get("title", ""))
    # TODO: berikan rewards

func get_quest_info(quest_id: String) -> Dictionary:
    return active_quests.get(quest_id, {})
```

---

## Langkah 15: Audio & Sound

### 15.1 Setup Audio Manager

Buat `res://scripts/core/audio_manager.gd` (Autoload):

```gdscript
extends Node

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX: int = 8

func _ready() -> void:
    music_player = AudioStreamPlayer.new()
    music_player.bus = "Music"
    add_child(music_player)

    for i in MAX_SFX:
        var p = AudioStreamPlayer.new()
        p.bus = "SFX"
        add_child(p)
        sfx_players.append(p)

func play_music(stream: AudioStream, fade_in: float = 1.0) -> void:
    music_player.stream = stream
    music_player.volume_db = -40.0
    music_player.play()
    # Fade in
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", 0.0, fade_in)

func stop_music(fade_out: float = 1.0) -> void:
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", -40.0, fade_out)
    tween.tween_callback(music_player.stop)

func play_sfx(stream: AudioStream) -> void:
    for player in sfx_players:
        if not player.playing:
            player.stream = stream
            player.play()
            return
```

### 15.2 Setup Audio Bus

1. Buka **Audio** tab (bawah editor, samping Animation)
2. Klik **"Add Bus"** × 2 untuk membuat:
   - `Music` — untuk musik gamelan
   - `SFX` — untuk sound effects
3. Atur volume masing-masing

### 15.3 Tempat Meletakkan File Audio

```
assets/audio/
├── music/
│   ├── gamelan_main_theme.ogg
│   ├── gamelan_combat.ogg
│   ├── gamelan_trowulan.ogg
│   └── ambient_forest.ogg
└── sfx/
    ├── block_break.wav
    ├── block_place.wav
    ├── sword_swing.wav
    ├── sword_hit.wav
    ├── footstep_grass.wav
    ├── footstep_stone.wav
    └── ui_click.wav
```

> [!TIP]
> Gunakan format **.OGG** untuk musik (kualitas baik, file kecil, loopable) dan **.WAV** untuk SFX pendek (latensi rendah).

---

## ✅ Checklist Progress

Setelah menyelesaikan semua langkah, kamu akan memiliki:

```
[x] Langkah 1-7  : Dasar (dari GETTING_STARTED.md)
[ ] Langkah 8    : World generation dengan noise (bukit, gua)
[ ] Langkah 9    : Place & break blocks
[ ] Langkah 10   : Inventory + hotbar UI
[ ] Langkah 11   : Combat (attack, block, dodge, combo, enemy)
[ ] Langkah 12   : NPC dialog (branching dialog tree)
[ ] Langkah 13   : Crafting (recipe, station, bahan)
[ ] Langkah 14   : Quest system (objectives, progress, rewards)
[ ] Langkah 15   : Audio manager (musik gamelan, SFX)
```

## 🚀 Setelah Ini?

Setelah semua langkah di atas selesai, kamu siap masuk ke **Phase 3 — Content Building**:

| Fitur | Deskripsi |
|-------|-----------|
| **Biome System** | Tambah biome: hutan, pantai, gunung, sawah |
| **Greedy Meshing** | Optimasi performa chunk rendering |
| **Save/Load** | Simpan & muat progress |
| **Lebih Banyak NPC** | NPC dengan jadwal, AI patrol |
| **Dungeon Generator** | Dungeon prosedural di bawah tanah |
| **Skill System** | 4 path: Ksatria, Empu, Dukun, Saudagar |
| **Story Quest Act 1** | Main quest pendirian Majapahit |

---

*Panduan ini melanjutkan dari GETTING_STARTED.md. Ikuti secara berurutan untuk hasil terbaik!*
