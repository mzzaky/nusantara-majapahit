# 📘 NUSANTARA: MAJAPAHIT — Panduan Memulai Development

> *Step-by-step guide untuk pemula Godot Engine 4.6*

---

## 📋 Daftar Isi

1. [Persiapan Tools](#1-persiapan-tools)
2. [Setup Project](#2-setup-project)
3. [Memahami Godot Editor](#3-memahami-godot-editor)
4. [Langkah 1: Membuat Dunia Voxel Pertama](#4-langkah-1-membuat-dunia-voxel-pertama)
5. [Langkah 2: Player Controller](#5-langkah-2-player-controller)
6. [Langkah 3: Kamera Third-Person](#6-langkah-3-kamera-third-person)
7. [Langkah 4: Sistem Block](#7-langkah-4-sistem-block)
8. [Langkah 5: Import Model Blockbench](#8-langkah-5-import-model-blockbench)
9. [Langkah 6: Day/Night Cycle](#9-langkah-6-daynight-cycle)
10. [Langkah 7: UI Dasar (HUD)](#10-langkah-7-ui-dasar-hud)
11. [Tips & Troubleshooting](#11-tips--troubleshooting)
12. [Referensi Belajar](#12-referensi-belajar)

---

## 1. Persiapan Tools

### 1.1 Install Godot Engine 4.6

1. Buka [godotengine.org/download](https://godotengine.org/download)
2. Download **Godot 4.6 - Standard** (64-bit)
3. Extract ZIP ke folder yang mudah diakses, contoh: `C:\Godot\`
4. Jalankan `Godot_v4.6-stable_win64.exe`

> [!TIP]
> Godot TIDAK perlu diinstall — cukup extract dan jalankan langsung. Simpan di lokasi permanen agar tidak hilang.

### 1.2 Install Blockbench

1. Buka [blockbench.net](https://www.blockbench.net/)
2. Download versi Desktop (Windows)
3. Install seperti aplikasi biasa
4. Atau gunakan versi web di browser: [web.blockbench.net](https://web.blockbench.net/)

### 1.3 Install Git (Version Control)

1. Download dari [git-scm.com](https://git-scm.com/)
2. Install dengan setting default
3. Buka terminal, cek instalasi:
   ```
   git --version
   ```

### 1.4 Install Visual Studio Code (Opsional — Editor Tambahan)

1. Download dari [code.visualstudio.com](https://code.visualstudio.com/)
2. Install extension **"godot-tools"** untuk GDScript support
3. Di Godot: `Editor > Editor Settings > Text Editor > External`
   - Centang **Use External Editor**
   - Exec Path: path ke `Code.exe`
   - Exec Flags: `{project} --goto {file}:{line}:{col}`

### 1.5 Spesifikasi Komputer

| Komponen | Minimum | Rekomendasi |
|----------|---------|-------------|
| **OS** | Windows 10 64-bit | Windows 11 |
| **CPU** | Intel i5-6400 / Ryzen 3 | Intel i7-8700 / Ryzen 5 |
| **RAM** | 8 GB | 16 GB |
| **GPU** | GTX 1050 / RX 560 | GTX 1660 / RX 5600 XT |
| **Storage** | 10 GB SSD | 50 GB SSD |

---

## 2. Setup Project

### 2.1 Membuka Project yang Sudah Ada

Project Godot sudah dibuat di `e:\majapahit\nusantara-majapahit\`.

1. Buka Godot Engine
2. Klik **"Import"**
3. Browse ke `e:\majapahit\nusantara-majapahit\`
4. Pilih file `project.godot`
5. Klik **"Import & Edit"**

### 2.2 Membuat Folder Structure

Buka tab **FileSystem** (kiri bawah di Godot Editor), lalu buat folder-folder ini:

```
res://
├── assets/
│   ├── models/
│   │   ├── blocks/
│   │   ├── characters/
│   │   ├── items/
│   │   ├── creatures/
│   │   ├── props/
│   │   ├── buildings/
│   │   └── vegetation/
│   ├── textures/
│   │   ├── blocks/
│   │   ├── characters/
│   │   ├── ui/
│   │   └── particles/
│   ├── audio/
│   │   ├── music/
│   │   └── sfx/
│   ├── fonts/
│   ├── shaders/
│   └── blockbench/          ← file sumber .bbmodel
├── scenes/
│   ├── world/
│   ├── characters/
│   ├── ui/
│   ├── vfx/
│   └── levels/
├── scripts/
│   ├── core/
│   ├── player/
│   ├── npc/
│   ├── combat/
│   ├── crafting/
│   ├── quest/
│   ├── ui/
│   ├── world_gen/
│   └── utils/
├── data/
│   ├── items/
│   ├── quests/
│   ├── dialogs/
│   └── recipes/
└── docs/                    ← dokumentasi (sudah ada)
```

**Cara membuat folder di Godot:**
1. Klik kanan di FileSystem panel
2. Pilih **"New Folder..."**
3. Ketik nama folder
4. Atau buat langsung via File Explorer Windows di folder project

### 2.3 Setup Git Repository

Buka terminal di folder project:

```bash
# Masuk ke folder project
# (jangan pakai cd di Godot, gunakan terminal terpisah)

# Inisialisasi Git
git init

# Buat commit pertama
git add .
git commit -m "Initial project setup - Nusantara Majapahit"
```

> [!IMPORTANT]
> File `.gitignore` sudah ada di project. Pastikan folder `.godot/` (cache Godot) sudah di-ignore agar tidak masuk Git.

---

## 3. Memahami Godot Editor

### 3.1 Layout Editor

Saat membuka Godot, kamu akan melihat tampilan ini:

```
┌─────────────────────────────────────────────────────────────┐
│  Menu Bar (Scene, Project, Debug, Editor, Help)             │
├──────────┬──────────────────────────────┬───────────────────┤
│          │                              │                   │
│  Scene   │      3D/2D Viewport          │    Inspector      │
│  Tree    │                              │    (properti      │
│          │      (preview game)          │     node          │
│          │                              │     terpilih)     │
│          │                              │                   │
├──────────┴──────────────────────────────┼───────────────────┤
│  FileSystem        │  Output / Debugger │   Node / Signals  │
│  (file & folder)   │  (log & error)     │                   │
└────────────────────┴────────────────────┴───────────────────┘
```

### 3.2 Konsep Dasar Godot

| Konsep | Penjelasan | Analogi |
|--------|------------|---------|
| **Node** | Unit terkecil dalam game (seperti LEGO brick) | Sebuah komponen |
| **Scene** | Kumpulan node yang membentuk sesuatu | Sebuah prefab / objek jadi |
| **Script** | Kode GDScript yang mengontrol behavior node | Otak / logic |
| **Signal** | Event system — node mengirim notifikasi | Seperti "event listener" |
| **Resource** | Data yang bisa dibagikan antar node | File data |
| **Inspector** | Panel untuk mengubah properti node | Panel settings |

### 3.3 Node Penting untuk Game 3D

| Node | Fungsi | Kapan Dipakai |
|------|--------|---------------|
| `Node3D` | Node 3D dasar (posisi, rotasi, skala) | Container / parent |
| `CharacterBody3D` | Karakter dengan physics | Player, NPC |
| `StaticBody3D` | Objek statis (tidak bergerak) | Lantai, dinding, candi |
| `RigidBody3D` | Objek dengan simulasi fisika | Batu jatuh, item drop |
| `MeshInstance3D` | Menampilkan model 3D | Render model Blockbench |
| `CollisionShape3D` | Area collision (tabrakan) | Hit detection |
| `Camera3D` | Kamera pemain | Viewport kamera |
| `DirectionalLight3D` | Cahaya matahari | Sinar matahari / bulan |
| `WorldEnvironment` | Pengaturan langit, fog, dll | Atmosfer game |
| `AnimationPlayer` | Memutar animasi | Animasi karakter |
| `AudioStreamPlayer3D` | Suara 3D | SFX di dunia game |

### 3.4 Shortcut Penting

| Shortcut | Fungsi |
|----------|--------|
| `F5` | Jalankan game (Play) |
| `F6` | Jalankan scene saat ini |
| `F8` | Stop game |
| `Ctrl + S` | Simpan scene |
| `Ctrl + Shift + S` | Simpan semua |
| `Q` | Select mode |
| `W` | Move mode (geser objek) |
| `E` | Rotate mode (putar objek) |
| `R` | Scale mode (ubah ukuran) |
| `Ctrl + Z` | Undo |
| `Ctrl + A` | Tambah node baru |
| `Scroll Wheel` | Zoom in/out di viewport |
| `Middle Mouse` | Orbit kamera editor |
| `Shift + Middle Mouse` | Pan kamera editor |

---

## 4. Langkah 1: Membuat Dunia Voxel Pertama

### 4.1 Buat Scene Utama

1. **File > New Scene**
2. Klik **"3D Scene"** (otomatis membuat root `Node3D`)
3. Rename root node menjadi **"Main"**
4. **Ctrl + S** → Simpan sebagai `res://scenes/world/main.tscn`

### 4.2 Tambahkan Pencahayaan & Lingkungan

1. Klik node **Main**, lalu **Ctrl + A** (Add Node)
2. Cari dan tambahkan: **DirectionalLight3D**
3. Di Inspector, atur:
   - `Rotation X`: **-45°** (miring seperti matahari sore)
   - `Rotation Y`: **-30°**
   - `Light > Energy`: **1.0**
   - `Shadow > Enabled`: ✅ **true**

4. Tambahkan lagi: **WorldEnvironment**
5. Di Inspector:
   - Klik `Environment` > **"New Environment"**
   - `Background > Mode`: **Sky**
   - `Sky > Sky Material`: **New ProceduralSkyMaterial**
   - `Ambient Light > Source`: **Sky**
   - `Tonemap > Mode`: **ACES**

### 4.3 Buat Floor Sederhana (Test)

1. Tambahkan node: **StaticBody3D** (child dari Main)
2. Rename: **"Floor"**
3. Tambahkan child ke Floor: **MeshInstance3D**
   - Di Inspector > `Mesh`: **New BoxMesh**
   - Klik BoxMesh, atur `Size`: **x:50, y:0.5, z:50**
4. Tambahkan child ke Floor: **CollisionShape3D**
   - Di Inspector > `Shape`: **New BoxShape3D**
   - Atur sama dengan mesh: **x:50, y:0.5, z:50**

### 4.4 Set Scene Utama

1. **Project > Project Settings > General > Application > Run**
2. Set **"Main Scene"** ke `res://scenes/world/main.tscn`
3. Sekarang tekan **F5** untuk test — kamu akan melihat lantai dengan langit!

---

## 5. Langkah 2: Player Controller

### 5.1 Buat Scene Player

1. **File > New Scene**
2. Pilih **"Other Node"** → cari **CharacterBody3D**
3. Rename root: **"Player"**
4. Simpan: `res://scenes/characters/player.tscn`

### 5.2 Tambahkan Komponen Player

Buat hierarki node seperti ini:

```
Player (CharacterBody3D)
├── CollisionShape3D         ← hitbox pemain
├── PlayerModel (Node3D)     ← container untuk model 3D
│   └── MeshInstance3D       ← sementara pakai capsule
├── CameraArm (Node3D)       ← pivot kamera
│   └── Camera3D             ← kamera game
```

**Setup CollisionShape3D:**
- `Shape`: **New CapsuleShape3D**
- `Radius`: **0.4**
- `Height`: **1.8**

**Setup MeshInstance3D (sementara):**
- `Mesh`: **New CapsuleMesh**
- `Radius`: **0.4**, `Height`: **1.8**
- Ini placeholder sampai model Blockbench siap

**Setup CameraArm:**
- `Position Y`: **1.5** (setinggi kepala)
- `Position Z`: **3.0** (di belakang karakter)

**Setup Camera3D:**
- `Position`: **(0, 0.5, 0)** (sedikit di atas pivot)

### 5.3 Tulis Script Player

1. Klik node **Player**
2. Klik ikon scroll (📜) di atas Scene Tree → **"Attach Script"**
3. Path: `res://scripts/player/player_controller.gd`
4. Tulis kode berikut:

```gdscript
extends CharacterBody3D

# === PENGATURAN ===
@export_group("Movement")
@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_force: float = 8.0
@export var gravity: float = 20.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.003
@export var camera_min_angle: float = -80.0
@export var camera_max_angle: float = 50.0

# === REFERENSI NODE ===
@onready var camera_arm: Node3D = $CameraArm
@onready var camera: Camera3D = $CameraArm/Camera3D
@onready var player_model: Node3D = $PlayerModel

# === VARIABEL ===
var is_sprinting: bool = false

func _ready() -> void:
    # Kunci mouse ke tengah layar
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
    # Rotasi kamera dengan mouse
    if event is InputEventMouseMotion:
        # Rotasi horizontal (kiri-kanan) → putar seluruh player
        rotate_y(-event.relative.x * mouse_sensitivity)
        
        # Rotasi vertikal (atas-bawah) → putar camera arm
        camera_arm.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_arm.rotation.x = clamp(
            camera_arm.rotation.x,
            deg_to_rad(camera_min_angle),
            deg_to_rad(camera_max_angle)
        )
    
    # Tekan ESC untuk lepas mouse (debug)
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
    # === GRAVITY ===
    if not is_on_floor():
        velocity.y -= gravity * delta
    
    # === JUMP ===
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_force
    
    # === MOVEMENT ===
    # Ambil input WASD
    var input_dir := Input.get_vector(
        "move_left", "move_right",  # A, D
        "move_forward", "move_back" # W, S
    )
    
    # Hitung arah gerakan berdasarkan rotasi player
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    
    # Sprint
    is_sprinting = Input.is_action_pressed("sprint")
    var current_speed = sprint_speed if is_sprinting else move_speed
    
    # Terapkan gerakan
    if direction:
        velocity.x = direction.x * current_speed
        velocity.z = direction.z * current_speed
        
        # Putar model ke arah gerakan
        player_model.look_at(global_position + direction, Vector3.UP)
    else:
        # Perlambatan saat berhenti
        velocity.x = move_toward(velocity.x, 0, current_speed * delta * 10)
        velocity.z = move_toward(velocity.z, 0, current_speed * delta * 10)
    
    # Jalankan physics
    move_and_slide()
```

### 5.4 Setup Input Map

1. **Project > Project Settings > Input Map**
2. Tambahkan action baru (ketik nama, tekan "Add"):

| Action Name | Key Binding |
|-------------|-------------|
| `move_forward` | W |
| `move_back` | S |
| `move_left` | A |
| `move_right` | D |
| `sprint` | Shift |
| `jump` | Space |
| `attack_light` | Left Mouse Button |
| `attack_heavy` | Right Mouse Button |
| `interact` | E |
| `inventory` | I |
| `dodge` | Left Ctrl |

**Cara menambah binding:**
1. Ketik nama action di kolom "Add New Action"
2. Klik **"Add"**
3. Klik **"+"** di samping action
4. Tekan tombol keyboard yang diinginkan
5. Klik **"OK"**

### 5.5 Masukkan Player ke Scene Utama

1. Buka kembali `main.tscn`
2. Klik ikon 🔗 di atas Scene Tree → **"Instantiate Child Scene"**
3. Pilih `res://scenes/characters/player.tscn`
4. Atur posisi Player: `Position Y`: **2.0** (di atas floor)
5. Tekan **F5** → Kamu bisa berjalan dengan WASD dan melihat sekitar dengan mouse! 🎮

---

## 6. Langkah 3: Kamera Third-Person

Kamera sudah ada di script Player di atas. Berikut cara memperbaiki agar lebih smooth:

### 6.1 Tambah Spring Arm (Anti-Clipping)

Ganti setup kamera di scene Player:

```
Player (CharacterBody3D)
├── ...
├── CameraArm (SpringArm3D)    ← ganti dari Node3D ke SpringArm3D
│   └── Camera3D
```

**Setup SpringArm3D:**
- `Spring Length`: **4.0** (jarak kamera dari player)
- `Position Y`: **1.5**
- `Margin`: **0.2**
- `Shape`: **New SphereShape3D** (radius: 0.1)

> [!NOTE]
> **SpringArm3D** secara otomatis mendekatkan kamera jika ada dinding di belakang player, sehingga kamera tidak "tembus" dinding.

### 6.2 Update Script untuk SpringArm3D

Ganti baris referensi di script:
```gdscript
# Ganti ini:
@onready var camera_arm: Node3D = $CameraArm

# Menjadi ini:
@onready var camera_arm: SpringArm3D = $CameraArm
```

---

## 7. Langkah 4: Sistem Block

### 7.1 Buat Block Resource

Buat file baru: `res://scripts/core/block_data.gd`

```gdscript
class_name BlockData extends Resource

@export var block_id: int = 0
@export var block_name: String = ""
@export var texture_top: Texture2D
@export var texture_side: Texture2D
@export var texture_bottom: Texture2D
@export var is_solid: bool = true
@export var is_transparent: bool = false
@export var hardness: float = 1.0  # Waktu untuk menghancurkan

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
```

### 7.2 Buat Simple Chunk

Buat file: `res://scripts/core/chunk.gd`

```gdscript
class_name Chunk extends StaticBody3D

const CHUNK_SIZE := 16
const CHUNK_HEIGHT := 64  # mulai kecil dulu untuk testing

var chunk_position: Vector2i
var blocks: Array = []  # 3D array of block IDs

func _ready() -> void:
    # Inisialisasi array blok
    blocks.resize(CHUNK_SIZE)
    for x in CHUNK_SIZE:
        blocks[x] = []
        blocks[x].resize(CHUNK_HEIGHT)
        for y in CHUNK_HEIGHT:
            blocks[x][y] = []
            blocks[x][y].resize(CHUNK_SIZE)
            for z in CHUNK_SIZE:
                blocks[x][y][z] = 0  # 0 = AIR

func generate_flat(height: int = 8) -> void:
    """Generate terrain datar sederhana untuk testing"""
    for x in CHUNK_SIZE:
        for z in CHUNK_SIZE:
            for y in height:
                if y == 0:
                    blocks[x][y][z] = 3  # BATU (bedrock)
                elif y < height - 1:
                    blocks[x][y][z] = 1  # TANAH
                else:
                    blocks[x][y][z] = 2  # RUMPUT
    
    # Setelah generate, buat mesh
    build_mesh()

func build_mesh() -> void:
    """Bangun mesh dari data blok (simple naive meshing)"""
    var surface_tool := SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    for x in CHUNK_SIZE:
        for y in CHUNK_HEIGHT:
            for z in CHUNK_SIZE:
                if blocks[x][y][z] == 0:
                    continue  # Skip AIR
                
                var block_pos := Vector3(x, y, z)
                
                # Cek setiap face — hanya render jika neighbor = AIR
                # Top face (Y+)
                if y + 1 >= CHUNK_HEIGHT or blocks[x][y + 1][z] == 0:
                    _add_face(surface_tool, block_pos, "top")
                # Bottom face (Y-)
                if y - 1 < 0 or blocks[x][y - 1][z] == 0:
                    _add_face(surface_tool, block_pos, "bottom")
                # Front face (Z+)
                if z + 1 >= CHUNK_SIZE or blocks[x][y][z + 1] == 0:
                    _add_face(surface_tool, block_pos, "front")
                # Back face (Z-)
                if z - 1 < 0 or blocks[x][y][z - 1] == 0:
                    _add_face(surface_tool, block_pos, "back")
                # Right face (X+)
                if x + 1 >= CHUNK_SIZE or blocks[x + 1][y][z] == 0:
                    _add_face(surface_tool, block_pos, "right")
                # Left face (X-)
                if x - 1 < 0 or blocks[x - 1][y][z] == 0:
                    _add_face(surface_tool, block_pos, "left")
    
    surface_tool.generate_normals()
    
    # Buat mesh instance
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.mesh = surface_tool.commit()
    
    # Beri warna sementara (nanti diganti texture)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.45, 0.65, 0.3)  # Hijau rumput
    material.roughness = 0.9
    mesh_instance.material_override = material
    
    add_child(mesh_instance)
    
    # Generate collision
    mesh_instance.create_trimesh_collision()

func _add_face(st: SurfaceTool, pos: Vector3, face: String) -> void:
    """Tambahkan satu face (2 triangle) ke surface tool"""
    match face:
        "top":
            st.add_vertex(pos + Vector3(0, 1, 0))
            st.add_vertex(pos + Vector3(1, 1, 0))
            st.add_vertex(pos + Vector3(1, 1, 1))
            st.add_vertex(pos + Vector3(0, 1, 0))
            st.add_vertex(pos + Vector3(1, 1, 1))
            st.add_vertex(pos + Vector3(0, 1, 1))
        "bottom":
            st.add_vertex(pos + Vector3(0, 0, 1))
            st.add_vertex(pos + Vector3(1, 0, 1))
            st.add_vertex(pos + Vector3(1, 0, 0))
            st.add_vertex(pos + Vector3(0, 0, 1))
            st.add_vertex(pos + Vector3(1, 0, 0))
            st.add_vertex(pos + Vector3(0, 0, 0))
        "front":
            st.add_vertex(pos + Vector3(0, 0, 1))
            st.add_vertex(pos + Vector3(0, 1, 1))
            st.add_vertex(pos + Vector3(1, 1, 1))
            st.add_vertex(pos + Vector3(0, 0, 1))
            st.add_vertex(pos + Vector3(1, 1, 1))
            st.add_vertex(pos + Vector3(1, 0, 1))
        "back":
            st.add_vertex(pos + Vector3(1, 0, 0))
            st.add_vertex(pos + Vector3(1, 1, 0))
            st.add_vertex(pos + Vector3(0, 1, 0))
            st.add_vertex(pos + Vector3(1, 0, 0))
            st.add_vertex(pos + Vector3(0, 1, 0))
            st.add_vertex(pos + Vector3(0, 0, 0))
        "right":
            st.add_vertex(pos + Vector3(1, 0, 1))
            st.add_vertex(pos + Vector3(1, 1, 1))
            st.add_vertex(pos + Vector3(1, 1, 0))
            st.add_vertex(pos + Vector3(1, 0, 1))
            st.add_vertex(pos + Vector3(1, 1, 0))
            st.add_vertex(pos + Vector3(1, 0, 0))
        "left":
            st.add_vertex(pos + Vector3(0, 0, 0))
            st.add_vertex(pos + Vector3(0, 1, 0))
            st.add_vertex(pos + Vector3(0, 1, 1))
            st.add_vertex(pos + Vector3(0, 0, 0))
            st.add_vertex(pos + Vector3(0, 1, 1))
            st.add_vertex(pos + Vector3(0, 0, 1))
```

### 7.3 Test Chunk di Scene

Tambahkan script test di `main.tscn`. Buat script pada node Main:

`res://scripts/core/main_world.gd`
```gdscript
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
```

> [!TIP]
> Tekan **F5** dan kamu akan melihat terrain voxel datar berwarna hijau! Player bisa berjalan di atasnya.

---

## 8. Langkah 5: Import Model Blockbench

### 8.1 Membuat Model Pertama di Blockbench

1. Buka **Blockbench**
2. Klik **"New" > "Generic Model"**
3. Buat kubus sederhana 16×16×16 (1 blok)
4. **Paint** tekstur pixel art di permukaan kubus
5. **File > Export > Export glTF Model**
   - Format: **glTF Binary (.glb)**
   - ✅ **Embed Textures**
   - Simpan ke: `e:\majapahit\nusantara-majapahit\assets\models\blocks\block_bata_merah.glb`

### 8.2 Import ke Godot

1. Kembali ke Godot Editor
2. Model otomatis muncul di FileSystem panel
3. **Klik model** → buka tab **Import** (di atas Inspector)
4. Atur import settings:

```
Meshes:
  └── Ensure Tangents: true

Animation:
  └── Import: false (untuk blok statis)

Materials:
  └── Storage: Built-In
```

5. Klik **"Reimport"**

### 8.3 Perbaiki Tekstur Blur

⚠️ **Ini langkah PALING PENTING untuk voxel art:**

1. Di FileSystem, cari file texture (biasanya di dalam `.glb`)
2. Klik texture → tab **Import**
3. Ubah settings:

| Setting | Nilai |
|---------|-------|
| **Filter** | **Nearest** |
| **Mipmaps** | **Generate: OFF** |
| **Compress > Mode** | **Lossless** |

4. Klik **"Reimport"**

> Atau set secara global: **Project > Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter** → **Nearest**

### 8.4 Gunakan Model di Scene

```gdscript
# Cara memuat dan menampilkan model Blockbench via script:
var model_scene = preload("res://assets/models/blocks/block_bata_merah.glb")
var instance = model_scene.instantiate()
add_child(instance)
instance.position = Vector3(5, 10, 5)
```

Atau drag langsung dari FileSystem ke Scene viewport!

---

## 9. Langkah 6: Day/Night Cycle

### 9.1 Buat Script

Buat `res://scripts/core/day_night_cycle.gd`:

```gdscript
extends Node3D

@export var day_duration_minutes: float = 10.0  # 10 menit real-time = 1 hari game
@export var sun_light: DirectionalLight3D
@export var moon_light: DirectionalLight3D

# Waktu: 0.0 = tengah malam, 0.25 = sunrise, 0.5 = siang, 0.75 = sunset
var time_of_day: float = 0.3  # Mulai pagi hari

# Warna langit
var sunrise_color := Color(1.0, 0.6, 0.3)   # Oranye sunrise
var noon_color := Color(0.5, 0.7, 1.0)       # Biru cerah
var sunset_color := Color(1.0, 0.4, 0.2)     # Merah sunset
var night_color := Color(0.05, 0.05, 0.15)   # Biru gelap malam

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
    """Kembalikan waktu dalam format jam:menit"""
    var hours = int(time_of_day * 24.0)
    var minutes = int((time_of_day * 24.0 - hours) * 60.0)
    return "%02d:%02d" % [hours, minutes]

func is_night() -> bool:
    return time_of_day < 0.25 or time_of_day > 0.75
```

### 9.2 Setup di Scene

1. Buka `main.tscn`
2. Tambahkan node **Node3D**, rename: **"DayNightCycle"**
3. Attach script `day_night_cycle.gd`
4. Tambahkan **DirectionalLight3D** baru sebagai "MoonLight" (redup, warna biru pucat)
5. Di Inspector DayNightCycle:
   - Drag **DirectionalLight3D** (matahari) ke slot `Sun Light`
   - Drag **MoonLight** ke slot `Moon Light`

---

## 10. Langkah 7: UI Dasar (HUD)

### 10.1 Buat Scene HUD

1. **File > New Scene** → **User Interface** (root: Control)
2. Rename root: **"HUD"**
3. Simpan: `res://scenes/ui/hud.tscn`

### 10.2 Tambahkan Elemen UI

```
HUD (Control)
├── HealthBar (ProgressBar)       ← HP bar
├── StaminaBar (ProgressBar)      ← Stamina bar
├── TimeLabel (Label)             ← Waktu in-game
├── Crosshair (TextureRect)       ← Crosshair tengah layar
└── DebugInfo (Label)             ← Info debug (FPS, posisi)
```

**Setup HealthBar:**
- Anchor: Top-Left
- Position: **(20, 20)**
- Size: **(200, 25)**
- `Min Value`: **0**, `Max Value`: **100**, `Value`: **100**
- `Theme Override > Styles > Fill`: Buat **StyleBoxFlat** warna **merah**

**Setup StaminaBar:**
- Position: **(20, 50)**
- Size: **(200, 20)**
- Warna: **kuning/hijau**

**Setup TimeLabel:**
- Anchor: Top-Center
- `Text`: "12:00"
- Font size: **24**

**Setup Crosshair:**
- Anchor: Center
- Size: **(16, 16)**
- Buat gambar crosshair kecil atau gunakan **Label** dengan teks "+"

### 10.3 Script HUD

`res://scripts/ui/hud.gd`
```gdscript
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
```

### 10.4 Tambahkan HUD ke Scene Utama

1. Buka `main.tscn`
2. Tambahkan **CanvasLayer** sebagai child Main
3. Instantiate `hud.tscn` sebagai child CanvasLayer

---

## 11. Tips & Troubleshooting

### Masalah Umum

| Masalah | Solusi |
|---------|--------|
| **Tekstur blur / blurry** | Project Settings > Rendering > Textures > Default Texture Filter → **Nearest** |
| **Player jatuh tembus lantai** | Pastikan ada `CollisionShape3D` di Floor / Chunk |
| **Kamera tembus dinding** | Gunakan `SpringArm3D` bukan `Node3D` untuk camera arm |
| **Game terlalu gelap** | Tambahkan `WorldEnvironment` dengan ambient light |
| **Model Blockbench kebalik** | Rotate Y 180° di Godot, atau centang "Use Model Front" saat import |
| **Script error: "Node not found"** | Pastikan path `$NodeName` sesuai nama node di Scene Tree |
| **FPS rendah** | Kurangi jumlah chunk, gunakan LOD, cek thread blocking |
| **Mouse terkunci** | Tekan **ESC** untuk lepas mouse (sesuai script di atas) |

### Kebiasaan Baik

1. ✅ **Simpan sering** — `Ctrl + S` setiap selesai satu perubahan
2. ✅ **Commit Git teratur** — Minimal sekali per sesi coding
3. ✅ **Test sering** — Tekan `F5` / `F6` setelah setiap perubahan kecil
4. ✅ **Penamaan konsisten** — Ikuti konvensi di ASSET_PIPELINE.md
5. ✅ **Komentar kode** — Tulis komentar dalam Bahasa Indonesia agar mudah dimengerti
6. ✅ **Scene kecil** — Pecah fitur ke scene terpisah, jangan satu scene raksasa
7. ✅ **Baca error** — Output panel (bawah) menunjukkan error & warning

### Urutan Belajar yang Direkomendasikan

```
Minggu 1: ✅ Setup project, lighting, floor
          ✅ Player controller (WASD + mouse look)
          
Minggu 2: 🔨 Chunk system (generate & render blok)
          🔨 Block placement & destruction
          
Minggu 3: 🔨 Import model Blockbench pertama
          🔨 Texture pipeline (Nearest filter)
          
Minggu 4: 🔨 Day/night cycle
          🔨 HUD dasar

Minggu 5+: 🔨 Combat system dasar
           🔨 NPC spawn & dialog
           🔨 Inventory system
```

---

## 12. Referensi Belajar

### Dokumentasi Resmi
- 📖 [Godot 4 Docs](https://docs.godotengine.org/en/stable/) — Dokumentasi resmi lengkap
- 📖 [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) — Referensi bahasa GDScript
- 📖 [Blockbench Wiki](https://www.blockbench.net/wiki/) — Panduan Blockbench

### Video Tutorial (YouTube)
- 🎥 **Brackeys** — Godot 4 beginner tutorial series
- 🎥 **GDQuest** — Tutorial Godot berbahasa Inggris berkualitas
- 🎥 **HeartBeast** — RPG Action tutorial di Godot
- 🎥 **StayAtHomeDev** — Voxel terrain tutorial di Godot

### Komunitas
- 💬 [Godot Discord](https://discord.gg/godotengine) — Komunitas resmi
- 💬 [r/godot](https://reddit.com/r/godot) — Subreddit Godot
- 💬 [Godot Forum](https://forum.godotengine.org/) — Forum diskusi

### Resource Packs
- 🎨 [Kenney.nl](https://kenney.nl/) — Aset game gratis (untuk placeholder)
- 🎵 [OpenGameArt.org](https://opengameart.org/) — Musik & SFX gratis
- 🎵 [Freesound.org](https://freesound.org/) — Efek suara gratis

---

> [!TIP]
> **Prinsip utama:** Jangan langsung buat semuanya! Fokus satu fitur kecil, test sampai bekerja, baru lanjut ke fitur berikutnya. Ini disebut **iterative development**. 🚀

---

*Panduan ini akan diperbarui seiring perkembangan project dan pertanyaan yang muncul.*
