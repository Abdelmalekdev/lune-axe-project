extends Parallax2D


func _ready():
	# 1. نحفظ المكان الذي وضعت فيه الخلفية يدويًا في المحرك
	var manual_position = global_position
	
	# 2. نصفر الـ Position الفعلي للعقدة لأن Parallax2D 
	# تعتمد على الـ Offset في حساباتها وليس الـ Position العالمي
	global_position = Vector2.ZERO
	
	# 3. نضع المكان اليدوي داخل الـ Screen Offset
	# هذا سيجعلها تظهر في مكانها الأصلي وتتحرك بالسرعة (Factor) المحددة
	screen_offset = manual_position
