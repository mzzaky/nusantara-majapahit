# 🎨 NUSANTARA: MAJAPAHIT — Blockbench Asset Pipeline

> *Panduan lengkap pembuatan dan integrasi aset game menggunakan Blockbench → Godot 4.6*

---

## 1. Overview Pipeline

```
Blockbench (.bbmodel)
    │
    ├── Export: glTF Binary (.glb) ← FORMAT UTAMA
    │
    └── Import ke Godot 4.6
         ├── MeshInstance3D (model statis)
         ├── AnimationPlayer (animasi)
         ├── CollisionShape3D (auto via naming "-col")
         └── MeshLibrary (untuk voxel tileset)
```

> [!IMPORTANT]
> **Semua aset 3D** (karakter, item, blok, lingkungan, prop, dll.) dibuat di **Blockbench** dan diekspor sebagai **glTF Binary (.glb)**. Format ini mendukung textures, animasi, dan hierarki model secara penuh di Godot 4.6.

---

## 2. Tipe Project Blockbench

Gunakan tipe project berikut sesuai kebutuhan aset:

| Tipe Aset | Project Blockbench | Deskripsi |
|-----------|-------------------|-----------|
| **Voxel Blocks** | Generic Model | Blok terrain: bata merah, kayu jati, batu andesit, dll |
| **Karakter** | Generic Model | Player, NPC, musuh — menggunakan bone animation |
| **Item / Senjata** | Generic Model | Keris, tombak, karambit, busur, cetbang, dll |
| **Props / Dekorasi** | Generic Model | Candi, pendopo, furniture, relief, patung |
| **Hewan / Makhluk** | Generic Model | Harimau Jawa, Komodo, Barong, Rangda, dll |
| **Vegetasi** | Generic Model | Pohon jati, bambu, tanaman padi, bunga |

> [!NOTE]
> Selalu gunakan **"Generic Model"** saat membuat project baru di Blockbench agar kompatibel penuh dengan Godot melalui glTF export.

---

## 3. Standar Pembuatan Aset

### 3.1 Konvensi Penamaan

```
Format: [kategori]_[nama]_[varian]

Contoh:
├── block_bata_merah.glb
├── block_kayu_jati.glb
├── char_player_male.glb
├── char_npc_pandai_besi.glb
├── char_enemy_prajurit_kediri.glb
├── item_keris_basic.glb
├── item_tombak_besi.glb
├── prop_candi_panataran.glb
├── prop_pendopo_kecil.glb
├── creature_harimau_jawa.glb
├── creature_barong.glb
├── veg_pohon_jati.glb
└── veg_bambu_clump.glb
```

### 3.2 Konvensi Collision (Auto-Collision di Godot)

Beri suffix pada elemen di Blockbench untuk auto-generate collision di Godot:

| Suffix | Fungsi di Godot |
|--------|-----------------|
| `-col` | Generate CollisionShape3D (convex) |
| `-colonly` | Collision saja, tidak dirender |
| `-convcol` | Convex collision shape |
| `-trimesh` | Trimesh collision (statis saja) |

```
Contoh di Blockbench:
├── body          → rendered mesh
├── body-col      → rendered + collision
├── wall-colonly   → collision only (invisible)
```

### 3.3 Ukuran & Skala Standar

| Aset | Ukuran Blockbench | Skala Godot |
|------|-------------------|-------------|
| **1 Voxel Block** | 16x16x16 pixels | 1.0 unit = 1 blok |
| **Karakter Player** | 16x32x8 pixels (WxHxD) | ~1.8 unit tinggi |
| **NPC** | 16x32x8 pixels | ~1.8 unit tinggi |
| **Item (di tangan)** | 4x16x4 pixels | Proporsional |
| **Pohon Kecil** | 16x48x16 pixels | ~3.0 unit tinggi |
| **Pohon Besar** | 32x80x32 pixels | ~5.0 unit tinggi |
| **Candi Kecil** | 64x64x64 pixels | ~4.0 unit |
| **Hewan Kecil** | 12x12x24 pixels | ~0.75 unit |
| **Hewan Besar** | 24x24x48 pixels | ~1.5 unit |

### 3.4 Standar Tekstur

| Parameter | Nilai |
|-----------|-------|
| **Resolusi Tekstur** | 16x16 per face (pixel art style) |
| **Texture Atlas** | Satu atlas per kategori (max 512x512 atau 1024x1024) |
| **Color Mode** | RGBA (mendukung transparansi) |
| **UV Padding** | +1 pixel padding di sekitar UV (cegah bleeding) |
| **Style** | Pixel art konsisten, palet warna terbatas per kategori |

---

## 4. Workflow Pembuatan Aset

### 4.1 Voxel Blocks (Terrain)

```
1. Blockbench → New Generic Model
2. Buat kubus 16x16x16
3. Paint tekstur langsung di Blockbench (16x16 per face)
4. Buat varian jika perlu (rotasi, damage state)
5. Export → File > Export > glTF Model (.glb)
   ✅ Embed textures
   ❌ Export animations (tidak perlu)
6. Simpan ke: assets/models/blocks/
```

**Daftar Blok Prioritas:**

| Kategori | Blok |
|----------|------|
| **Tanah** | Tanah, Rumput, Pasir, Lumpur, Sawah |
| **Batu** | Batu biasa, Andesit, Granit, Bata Merah |
| **Kayu** | Kayu Jati (log & plank), Bambu, Rotan |
| **Alam** | Air, Lava, Daun tropis, Bunga |
| **Bangunan** | Bata merah Majapahit, Ubin, Genteng |
| **Ore** | Besi, Perunggu, Emas, Pamor (meteor) |

### 4.2 Karakter (Player & NPC)

```
1. Blockbench → New Generic Model
2. Modeling:
   ├── Head (group/bone: "head")
   ├── Body (group/bone: "body")
   ├── Right Arm (group/bone: "right_arm")
   ├── Left Arm (group/bone: "left_arm")
   ├── Right Leg (group/bone: "right_leg")
   └── Left Leg (group/bone: "left_leg")
3. Rigging: Atur pivot point setiap bone
4. Texturing: Paint skin, pakaian Majapahit
5. Animation (di tab Animation):
   ├── idle (2s loop)
   ├── walk (1s loop)
   ├── run (0.6s loop)
   ├── attack_light (0.5s)
   ├── attack_heavy (0.8s)
   ├── block (hold)
   ├── dodge (0.4s)
   ├── hit (0.3s)
   └── death (1.5s)
6. Export → glTF (.glb)
   ✅ Embed textures
   ✅ Export animations
7. Simpan ke: assets/models/characters/
```

**Bone Hierarchy Standar:**

```
root
├── body
│   ├── head
│   │   └── hair / mahkota / topi
│   ├── right_arm
│   │   └── right_hand
│   │       └── weapon_anchor  ← attachment point untuk senjata
│   ├── left_arm
│   │   └── left_hand
│   │       └── shield_anchor  ← attachment point untuk perisai
│   ├── right_leg
│   │   └── right_foot
│   └── left_leg
│       └── left_foot
```

### 4.3 Senjata & Item

```
1. Blockbench → New Generic Model
2. Modeling senjata dengan detail pixel art
3. Tentukan grip point (origin) yang tepat untuk attachment
4. Export → glTF (.glb)
   ✅ Embed textures
   ❌ Export animations
5. Simpan ke: assets/models/items/
```

**Daftar Senjata Prioritas:**

| Senjata | File | Varian |
|---------|------|--------|
| Keris | `item_keris_*.glb` | basic, pamor, legendaris |
| Pedang Klewang | `item_klewang_*.glb` | besi, baja, emas |
| Tombak | `item_tombak_*.glb` | bambu, besi, kerajaan |
| Karambit | `item_karambit_*.glb` | basic, baja |
| Gada | `item_gada_*.glb` | kayu, besi, perunggu |
| Busur Bambu | `item_busur_*.glb` | basic, komposit |
| Cetbang | `item_cetbang_*.glb` | kecil, sedang, besar |
| Perisai | `item_perisai_*.glb` | bambu, kayu, besi |

### 4.4 Makhluk & Hewan

```
1. Blockbench → New Generic Model
2. Modeling dengan bone system:
   ├── body (main bone)
   ├── head
   ├── legs (×4 untuk quadruped, ×2 untuk biped)
   ├── tail (jika ada)
   └── wings / special parts
3. Animation:
   ├── idle (loop)
   ├── walk (loop)
   ├── run (loop)
   ├── attack_1
   ├── attack_2
   ├── hit
   └── death
4. Export → glTF (.glb)
   ✅ Embed textures  
   ✅ Export animations
5. Simpan ke: assets/models/creatures/
```

### 4.5 Props & Bangunan

```
1. Blockbench → New Generic Model
2. Modeling bangunan/prop
3. Tambahkan collision:
   - Beri suffix "-col" pada elemen yang perlu collision
   - Buat simplified collision box jika bentuk kompleks
4. Export → glTF (.glb)
   ✅ Embed textures
   ❌ Export animations (kecuali ada bagian bergerak)
5. Simpan ke: assets/models/props/ atau assets/models/buildings/
```

---

## 5. Import Settings di Godot

### 5.1 Konfigurasi Import glTF

Setelah drag file `.glb` ke Godot FileSystem:

```
Import Settings (double-click file):
├── Root Type       → Node3D (default untuk prop)
│                   → CharacterBody3D (untuk karakter)
│                   → StaticBody3D (untuk environment)
├── Root Name       → [sesuai nama aset]
├── Apply Root Scale → checked (jika perlu adjust skala)
│
├── Meshes
│   └── Light Baking → Disabled (kita pakai realtime)
│
├── Animation
│   └── Import       → true (jika ada animasi)
│   └── Save Path    → res://assets/animations/[kategori]/
│
└── Material
    └── Storage      → External (untuk reuse material)
```

### 5.2 Texture Import Settings (Penting!)

Untuk menjaga gaya **pixel art/voxel** agar tidak blur:

```
Texture Import Settings:
├── Filter         → Nearest (BUKAN Linear!)
├── Mipmaps        → Disabled
├── Format         → RGBA 32bit (atau Lossless)
└── Repeat         → Disabled
```

> [!CAUTION]
> Jika texture terlihat blur/blurry di Godot, pastikan **Filter = Nearest** dan **Mipmaps = Disabled**. Ini WAJIB untuk semua aset voxel/pixel art.

### 5.3 Coordinate System

```
Blockbench:     Y-up, Z-forward
Godot:          Y-up, -Z forward

Solusi: Pada import di Godot, centang "Use Model Front" 
        atau rotate model 180° di Y-axis saat export.
```

---

## 6. Folder Structure Aset

```
nusantara-majapahit/
└── assets/
    ├── models/
    │   ├── blocks/              # Voxel terrain blocks
    │   │   ├── block_tanah.glb
    │   │   ├── block_rumput.glb
    │   │   ├── block_bata_merah.glb
    │   │   └── ...
    │   ├── characters/          # Player, NPC, enemies
    │   │   ├── char_player_male.glb
    │   │   ├── char_player_female.glb
    │   │   ├── char_npc_pandai_besi.glb
    │   │   ├── char_enemy_prajurit.glb
    │   │   └── ...
    │   ├── items/               # Senjata, armor, consumables
    │   │   ├── item_keris_basic.glb
    │   │   ├── item_tombak_besi.glb
    │   │   └── ...
    │   ├── creatures/           # Hewan & makhluk mitos
    │   │   ├── creature_harimau.glb
    │   │   ├── creature_barong.glb
    │   │   └── ...
    │   ├── props/               # Dekorasi, furnitur, interactables
    │   │   ├── prop_prasasti.glb
    │   │   ├── prop_tungku_pandai.glb
    │   │   └── ...
    │   ├── buildings/           # Bangunan & struktur besar
    │   │   ├── building_pendopo.glb
    │   │   ├── building_candi_kecil.glb
    │   │   └── ...
    │   └── vegetation/          # Pohon, tanaman, vegetasi
    │       ├── veg_pohon_jati.glb
    │       ├── veg_bambu_clump.glb
    │       └── ...
    ├── textures/
    │   ├── blocks/              # Texture atlas blok
    │   ├── characters/          # Texture skin karakter
    │   ├── items/               # Texture item
    │   ├── ui/                  # Texture UI
    │   └── particles/           # Texture partikel
    ├── animations/              # Animasi yang diekstrak dari glTF
    │   ├── player/
    │   ├── npc/
    │   ├── enemies/
    │   └── creatures/
    ├── blockbench/              # File sumber Blockbench (.bbmodel)
    │   ├── blocks/
    │   ├── characters/
    │   ├── items/
    │   ├── creatures/
    │   ├── props/
    │   └── buildings/
    └── audio/
        ├── music/
        └── sfx/
```

> [!TIP]
> Simpan file **sumber Blockbench (.bbmodel)** di folder `assets/blockbench/` agar bisa diedit ulang kapan saja. File ini TIDAK dipakai game saat runtime, hanya untuk development.

---

## 7. MeshLibrary untuk Voxel Terrain

Untuk blok voxel yang dipakai GridMap/terrain system:

```
Workflow:
1. Buat semua blok di Blockbench
2. Export masing-masing sebagai .glb
3. Di Godot, buat scene baru: voxel_blocks_library.tscn
4. Tambahkan semua blok sebagai child MeshInstance3D
5. Konversi ke MeshLibrary:
   Scene > Convert To > MeshLibrary
6. Simpan sebagai: data/mesh_libraries/voxel_blocks.meshlib

Alternatif: Gunakan plugin GLTF2MeshLib untuk otomatis
```

---

## 8. Aset Priority List (Milestone)

### Phase 1 — Foundation (Bulan 1–3)
- [ ] 20 block dasar (tanah, batu, kayu, air, rumput)
- [ ] 1 player model (male) + animasi dasar (idle, walk, run)
- [ ] 3 senjata basic (keris, tombak, busur)
- [ ] 5 pohon / vegetasi dasar

### Phase 2 — Core Content (Bulan 4–6)
- [ ] 40 block tambahan (ore, bangunan, dekorasi)
- [ ] 1 player model (female)
- [ ] 10 NPC model (pedagang, pandai besi, prajurit, dll)
- [ ] 5 enemy model (prajurit kediri, bandit, dll)
- [ ] Semua senjata (7 tipe × 3 tier = 21 model)
- [ ] 5 set armor

### Phase 3 — World Building (Bulan 7–9)
- [ ] 10 hewan (harimau, komodo, kerbau, burung, dll)
- [ ] 5 makhluk mitos (barong, rangda, leak, buto, naga)
- [ ] 20 prop / furnitur
- [ ] 5 bangunan (pendopo, rumah, warung, tungku, candi kecil)
- [ ] Vegetasi lengkap per biome

### Phase 4 — Polish (Bulan 10–12)
- [ ] NPC dengan kostum unik per faksi
- [ ] Senjata legendaris dan item spesial
- [ ] Bangunan besar (candi panataran, keraton, pelabuhan)
- [ ] Boss model (Jayakatwang, Rangda, Naga Basukih)

---

## 9. Tips & Best Practices

### Blockbench Tips
1. **Gunakan Reference Images** — Import gambar relief candi / pakaian tradisional sebagai referensi
2. **Konsisten dengan Grid** — Selalu snap ke grid untuk menjaga konsistensi voxel
3. **Optimize Mesh** — Gabungkan face yang tidak penting, kurangi cube count
4. **Backup .bbmodel** — Selalu commit file sumber ke Git sebelum export

### Godot Tips
1. **Reimport saat update** — Jika update model di Blockbench, re-export .glb dan Godot auto-reimport
2. **Instancing** — Gunakan scene instancing untuk model yang muncul berulang (hemat memori)
3. **LOD Manual** — Buat versi low-poly di Blockbench untuk jarak jauh
4. **Shader Override** — Terapkan custom shader pada material setelah import jika perlu efek khusus

---

*Dokumen ini akan diperbarui seiring bertambahnya kebutuhan aset.*
