class_name Chunk extends StaticBody3D

const CHUNK_SIZE := 16
const CHUNK_HEIGHT := 64 # mulai kecil dulu untuk testing

var chunk_position: Vector2i
var blocks: Array = [] # 3D array of block IDs

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
                blocks[x][y][z] = 0 # 0 = AIR

func generate_flat(height: int = 8) -> void:
    """Generate terrain datar sederhana untuk testing"""
    for x in CHUNK_SIZE:
        for z in CHUNK_SIZE:
            for y in height:
                if y == 0:
                    blocks[x][y][z] = 3 # BATU (bedrock)
                elif y < height - 1:
                    blocks[x][y][z] = 1 # TANAH
                else:
                    blocks[x][y][z] = 2 # RUMPUT
    
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
                    continue # Skip AIR
                
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
    material.albedo_color = Color(0.45, 0.65, 0.3) # Hijau rumput
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