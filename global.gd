extends Node

var coin := 0
var best_score := 0
var last_score := 0


func save_game_result(score: int):
	last_score = score
	if score > best_score:
		best_score = score
