extends PathfindingEntity
class_name Adventurer

var attack_time := 0.5
var damage := 5.0

var exit
var exit_pos
var treasure_list
var target

var melee : bool

@onready var interaction_timer = $InteractionTimer

func adventurer_pathfind():
	if find_closest_enemy(): ## found closest enemy
		return
	if find_closest_treasure(): ## found closest treasure
		return
	find_exit()
	return

func find_closest_enemy():
	if !targets_on_sight.size() > 0:
		return false
	
	var closest_target = targets_on_sight[0]
	for target in targets_on_sight:
		if target.global_position.distance_to(self.global_position) < closest_target.global_position.distance_to(self.global_position):
			closest_target = target
	target_pos = closest_target.position
	target = closest_target
	return true

func find_closest_treasure():
	
	if !treasure_list.size() > 0:
		return false
		
	var closest_treasure = treasure_list[0]
	for treasure in treasure_list:
		if treasure.global_position.distance_to(self.global_position) < closest_treasure.global_position.distance_to(self.global_position):
			closest_treasure = treasure
	target_pos = closest_treasure.position
	target = closest_treasure
	return true

func find_exit():
	print("EXIT")
	target_pos = exit.position
	target = exit
	
func _on_pathfindtimer_timeout():
	adventurer_pathfind()
	if target_pos:
		nav_agent.target_position = target_pos

func check_interact():
	if !target:
		return
	if target is Chest:
		target.set_open(true)
		treasure_list.erase(target)
	if target is Monster:
		super.check_interact()
	
