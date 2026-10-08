class_name Bank

var money: ObservableInt


func _init(starting_money: int) -> void:
	money = ObservableInt.new()
	money.value = starting_money


func earn(count: int) -> void:
	money.value += count


func has_enough(count: int) -> bool:
	return money.value >= count


func spend(count: int) -> bool:
	if money.value >= count:
		money.value -= count
		return true
	return false
