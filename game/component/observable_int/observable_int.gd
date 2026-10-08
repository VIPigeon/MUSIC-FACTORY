class_name ObservableInt

signal changed(new_value: int)

var value: int:
	set(new_value):
		value = new_value
		changed.emit(value)
