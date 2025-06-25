extends Node




func roll_check(dice_code: String, difficulty: int, roll_type: String = "generic") -> Dictionary:
	var dice_parts = dice_code.to_upper().split("D")
	var num_dice = int(dice_parts[0])
	var pip_bonus = 0
	
	if dice_parts.size() > 1 and dice_parts[1] != "":
		pip_bonus = int(dice_parts[1])
	
	var rolls = []
	var wild_die = randi() % 6 + 1
	rolls.append(wild_die)

	# Roll the remaining dice
	for i in range(num_dice - 1):
		rolls.append(randi() % 6 + 1)

	var total = 0
	var critical_success = false
	var critical_failure = false
	
	if wild_die == 6:
		critical_success = true
		var bonus = 6
		while true:
			var extra = randi() % 6 + 1
			bonus += extra
			if extra != 6:
				break
		total = bonus + rolls.slice(1, rolls.size()).reduce((a, b) -> a + b, 0)
	elif wild_die == 1:
		critical_failure = true
		var other_dice = rolls.slice(1, rolls.size())
		if other_dice.size() > 0:
			other_dice.sort()
			other_dice.remove_at(other_dice.size() - 1)  # Remove highest
			total = other_dice.reduce((a, b) -> a + b, 0)
		else:
			total = 0
	else:
		total = rolls.reduce((a, b) -> a + b, 0)

	total += pip_bonus
	var result_points = total - difficulty
	var success = total >= difficulty
	
	return {
		"roll_type": roll_type,
		"total": total,
		"success": success,
		"result_points": result_points,
		"critical_success": critical_success,
		"critical_failure": critical_failure,
		"rolls": rolls,
		"wild_die": wild_die,
		"dice_code": dice_code,
		"difficulty": difficulty,
	}
