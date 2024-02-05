extends NavigationRegion2D

var grid_size := 12
var tile_size := 16
# Called when the node enters the scene tree for the first time.
func _ready():
	generate_navregion_mesh()

 

func generate_navregion_mesh():
	var new_navigation_mesh = NavigationPolygon.new()
	var bounding_outline = PackedVector2Array([Vector2(0, 0), Vector2(0, grid_size * tile_size), Vector2(grid_size * tile_size, grid_size * tile_size), Vector2(grid_size * tile_size, 0)])
	new_navigation_mesh.add_outline(bounding_outline)
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	navigation_polygon = new_navigation_mesh

