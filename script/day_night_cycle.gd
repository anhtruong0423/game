extends Node3D

@export var cycle_duration: float = 60.0  ## 1 phút = 1 ngày đêm (test mode)
@export var start_time: float = 0.25  ## Bắt đầu lúc 6h sáng

@onready var sun: DirectionalLight3D = $"../DirectionalLight3D"
@onready var world_env: WorldEnvironment = $"../WorldEnvironment"

var time_of_day: float = 0.0
var night_lights: Array[Light3D] = []

func _ready():
	time_of_day = start_time
	_collect_night_lights(get_parent())
	_update_cycle()


func _process(delta: float):
	time_of_day += delta / cycle_duration
	if time_of_day >= 1.0:
		time_of_day -= 1.0
	_update_cycle()


func _update_cycle():
	if not sun or not world_env:
		return

	var sun_angle = time_of_day * TAU - PI / 2.0
	sun.rotation_degrees.x = rad_to_deg(sun_angle)

	var sun_height = sin(sun_angle + PI / 2.0)

	## === MẶT TRỜI ===
	if sun_height <= 0.0:
		sun.light_energy = 0.0
		sun.light_color = Color(0.05, 0.05, 0.1)
	elif sun_height < 0.15:
		var t = sun_height / 0.15
		sun.light_energy = t * 0.8
		sun.light_color = Color(1.0, 0.5, 0.25).lerp(Color(1.0, 0.96, 0.9), t)
	else:
		sun.light_energy = lerp(0.8, 1.5, clamp((sun_height - 0.15) / 0.5, 0.0, 1.0))
		sun.light_color = Color(1.0, 0.96, 0.9)

	## === ENVIRONMENT ===
	var env = world_env.environment
	if not env:
		return

	if sun_height > 0.3:
		env.ambient_light_energy = 0.4
		env.ambient_light_color = Color(0.75, 0.75, 0.78)
		env.background_energy_multiplier = 1.8
	elif sun_height > 0.0:
		var t = sun_height / 0.3
		env.ambient_light_energy = t * 0.4
		env.ambient_light_color = Color(0.4, 0.3, 0.25).lerp(Color(0.75, 0.75, 0.78), t)
		env.background_energy_multiplier = lerp(0.1, 1.8, t)
	else:
		## ĐÊM — tối thật sự
		var night_depth = clamp(-sun_height * 4.0, 0.0, 1.0)
		env.ambient_light_energy = lerp(0.02, 0.0, night_depth)
		env.ambient_light_color = Color(0.05, 0.05, 0.08)
		env.background_energy_multiplier = lerp(0.1, 0.005, night_depth)

	## === BẦU TRỜI ===
	var sky = env.sky if env else null
	if sky and sky.sky_material is ProceduralSkyMaterial:
		var sky_mat: ProceduralSkyMaterial = sky.sky_material

		if sun_height > 0.3:
			sky_mat.sky_top_color = Color(0.35, 0.55, 0.78)
			sky_mat.sky_horizon_color = Color(0.7, 0.78, 0.85)
			sky_mat.ground_horizon_color = Color(0.65, 0.68, 0.7)
		elif sun_height > 0.1:
			var t = (sun_height - 0.1) / 0.2
			sky_mat.sky_top_color = Color(0.15, 0.18, 0.35).lerp(Color(0.35, 0.55, 0.78), t)
			sky_mat.sky_horizon_color = Color(0.8, 0.4, 0.18).lerp(Color(0.7, 0.78, 0.85), t)
			sky_mat.ground_horizon_color = Color(0.5, 0.3, 0.15).lerp(Color(0.65, 0.68, 0.7), t)
		elif sun_height > 0.0:
			var t = sun_height / 0.1
			sky_mat.sky_top_color = Color(0.05, 0.04, 0.1).lerp(Color(0.15, 0.18, 0.35), t)
			sky_mat.sky_horizon_color = Color(0.3, 0.12, 0.05).lerp(Color(0.8, 0.4, 0.18), t)
			sky_mat.ground_horizon_color = Color(0.1, 0.06, 0.03).lerp(Color(0.5, 0.3, 0.15), t)
		else:
			## ĐÊM — gần như đen hoàn toàn
			var t = clamp(-sun_height * 4.0, 0.0, 1.0)
			sky_mat.sky_top_color = Color(0.05, 0.04, 0.1).lerp(Color(0.01, 0.01, 0.02), t)
			sky_mat.sky_horizon_color = Color(0.3, 0.12, 0.05).lerp(Color(0.01, 0.01, 0.02), t)
			sky_mat.ground_horizon_color = Color(0.1, 0.06, 0.03).lerp(Color(0.005, 0.005, 0.01), t)

	## === ĐÈN BAN ĐÊM ===
	var lights_on = sun_height < 0.05
	for light in night_lights:
		if is_instance_valid(light):
			light.visible = lights_on


func _collect_night_lights(node: Node):
	if node is Light3D and node != sun:
		var parent_name = node.get_parent().name if node.get_parent() else ""
		var in_light_group = (
			"StreetLamp" in parent_name or
			"StreetLight" in parent_name or
			"HouseLight" in node.name or
			"NightLight" in node.name or
			node.is_in_group("night_light")
		)
		if in_light_group:
			night_lights.append(node)
	for child in node.get_children():
		_collect_night_lights(child)
