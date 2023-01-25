extends Spatial
	
func _physics_process(delta):
	set_label()
	
func set_label():
	$"%ScoreTxt".set_text(get_score())

func get_score():
	var score = $"Tokens".score
	return "{first} {last}".format({
		"first": int(score / 10), 
		"last": int(score % 10)}
	)
