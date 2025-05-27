extends Control

@onready var RPSHpanel: Panel = %RPSHpanel
@onready var rock: Button = $RockPaperScissorShoe/rock
@onready var paper: Button = $RockPaperScissorShoe/paper
@onready var scissor: Button = $RockPaperScissorShoe/scissor
@onready var opponentmove: RichTextLabel = $RockPaperScissorShoe/opponentmove
@onready var helper: RichTextLabel = $RockPaperScissorShoe/helper
@onready var won: RichTextLabel = $RockPaperScissorShoe/won
@onready var max_hand_num: RichTextLabel = $MaxHandNum
@onready var wins: RichTextLabel = $MaxHandNum/wins
@onready var CALCpanel: Panel = %CALCpanel
@onready var PL: RichTextLabel = $hands/PL
@onready var OR: RichTextLabel = $hands/OR
@onready var PR: RichTextLabel = $hands/PR
@onready var OL: RichTextLabel = $hands/OL
@onready var intro: RichTextLabel = $Intro
@onready var bump: Button = $bump
@onready var keypad: GridContainer = $keypad


#create lists for hands and postions that the panels move to
var hands: Dictionary = {'PL' : 1, 'OR' : 1, 'PR' : 1, 'OL' : 1}
#var positions: Dictionary = {'PL' : Vector2(-233, -177), 'OR' : Vector2(126, -177), 'PR' : Vector2(-233, 50), 'OL' : Vector2(126, 47)}
#var rpsh_positions: Dictionary = {'rock' : 488, 'paper' : 560, 'scissor' : 632}

#create varibles for saving turns
var turn: String = 'pick_hand_num'
var player_hand_picked: String = 'N/A'
var current: String = 'PL'

#create varible to track when the round is ending
var ending: bool = false

#create varible that saves the maxinum number to bunp
var max_to_bump: int = 0

#runs when the program is reset
func _ready() -> void:
	if Saved.hand_num_set:
		turn = 'player_rpsh'
	else:
		intro.show()
		keypad.show()
		await get_tree().create_timer(2).timeout
		intro.hide()
	
	for button: Button in keypad.get_children():
		button.pressed.connect(func() -> void: num_input(keypad.get_children().find(button)))

#This part of the code contains the function to bump and the function to pick the hand max number
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var num: int = get_key_num(event.keycode)
		if num != 0:
			num_input(num)

func num_input(num : int) -> void:
	if not Saved.hand_num_set:
		if turn == 'pick_hand_num':
			Saved.max_hand_num = num + 1
			await get_tree().create_timer(0.5).timeout
			Saved.hand_num_set = true
			keypad.hide()
			turn = 'player_rpsh'
	elif turn == 'player_bumping':
		if num <= max_to_bump:
			turn = 'bumped'
			var combined: int = hands['PL'] + hands['PR']
			hands['PL'] = num
			hands['PR'] = combined - num
			await get_tree().create_timer(0.5).timeout
			remove_problems(Saved.max_hand_num)
			keypad.hide()
			turn = 'player_rpsh'

#returns the number that the user is pressing on by getting the event key
func get_key_num(event: int) -> int:
	var keys: Array = [-1, 49, 50, 51, 52, 53, 54, 55, 56, 57]
	for key: int in keys:
		if event == key:
			return keys.find(key)
	return 0

#runs on every frame
func _process(_delta: float) -> void:
	
	max_hand_num.visible = Saved.hand_num_set
	max_hand_num.text = '[right]Max Num: ' + str(Saved.max_hand_num - 1)
	wins.text = '[right]Player wins: ' + str(Saved.player_wins) + '\nOpponent wins: ' + str(Saved.opponent_wins)
	
	PL.text = str('[center]', hands['PL'])
	OR.text = str('[center]', hands['OR'])
	PR.text = str('[center]', hands['PR'])
	OL.text = str('[center]', hands['OL'])
	
	CALCpanel.global_position = {'PL' : PL, 'OR' : OR, 'PR' : PR, 'OL' : OL}[current].global_position
	CALCpanel.position += Vector2(-50, 24)
	
	#sets the instructional text based on the turn
	if not ending:
		if turn == 'player_rpsh':
			helper.text = '[center]' + 'Pick rock, paper, or scissor'
		elif turn == 'rpsh_proccessing':
			helper.text = '[center]' + "Opponent's turn"
		elif turn == 'player_hand_pick':
			helper.text = '[center]' + 'You won; pick one of your numbers or bump (redistributes numbers)'
		elif turn == 'oppoent_hand_pick':
			helper.text = '[center]' + 'Now pick a opponent number to attack'
		elif turn == 'opponent_attk':
			helper.text = '[center]' + 'Opponent won; they are making their move'
		elif turn == 'pick_hand_num':
			helper.text = '[center]' + 'Press a number from 1 to 9 to choose your max number amount'
		elif turn == 'player_bumping':
			max_to_bump = clamp(hands['PL'] + hands['PR'], 0, Saved.max_hand_num)
			helper.text = '[center]' + 'Press a number from 1 to ' + str(max_to_bump) + ' to set the top number'
		elif turn == 'bumped':
			helper.text = '[center]' + 'Bumped!'
		elif turn == 'opponent_bump':
			helper.text = '[center]' + 'Opponent bumped!'

#runs when the bump button is pressed
func _on_bump_pressed() -> void:
	if turn == 'player_hand_pick':
		turn = 'player_bumping'
		keypad.show()
		bump.hide()

#runs when the player's bottom number is pressed
func _on_player_right_pressed() -> void:
	if hands['PR'] != 0:
		if turn == 'player_hand_pick':
			turn = 'oppoent_hand_pick'
			player_hand_picked = 'PR'
			bump.hide()
			CALCpanel.show()
			current = 'PR'

#runs when the player's top button is pressed
func _on_player_left_pressed() -> void:
	if hands['PL'] != 0:
		if turn == 'player_hand_pick':
			turn = 'oppoent_hand_pick'
			player_hand_picked = 'PL'
			bump.hide()
			CALCpanel.show()
			current = 'PL'

#runs when the opponent's bottom number is pressed
func _on_opponent_left_pressed() -> void:
	if hands['OL'] != 0:
		if turn == 'oppoent_hand_pick':
			turn = 'player_attk_proccessing'
			CALCpanel.show()
			current = 'OL'
			player_attk(player_hand_picked, 'OL')

#runs when the opponent's top number is pressed
func _on_opponent_right_pressed() -> void:
	if hands['OR'] != 0:
		if turn == 'oppoent_hand_pick':
			turn = 'player_attk_proccessing'
			CALCpanel.show()
			current = 'OR'
			player_attk(player_hand_picked, 'OR')

#This is the function for the player to attack the opponent with its moves.
func player_attk(player: String, opponent: String) -> void:
	var player_num: int = hands[player]
	hands[opponent] += player_num
	await get_tree().create_timer(0.5).timeout
	remove_problems(Saved.max_hand_num)
	turn = 'player_rpsh'
	CALCpanel.hide()

#the function for the opponent to attack to player
func opponent_attk() -> void:
	await get_tree().create_timer(0.5).timeout
	if opponent_calculations() == 'bumped':
		turn = 'opponent_bump'
		await get_tree().create_timer(1).timeout
		remove_problems(Saved.max_hand_num)
		turn = 'player_rpsh'
	else:
		#opponent bumping code
		var split: Array = split_dict(opponent_calculations())
		current = split[0]
		CALCpanel.show()
		await get_tree().create_timer(0.5).timeout
		hands[split[1]] += hands[split[0]]
		current = split[1]
		await get_tree().create_timer(0.5).timeout
		remove_problems(Saved.max_hand_num)
		turn = 'player_rpsh'
		CALCpanel.hide()

# These are all the functions that occur when the user presses the rock, paper, and scissors.
func _on_rock_pressed() -> void:
	if turn == 'player_rpsh':
		rpsh('rock')

func _on_paper_pressed() -> void:
	if turn == 'player_rpsh':
		rpsh('paper')

func _on_scissor_pressed() -> void:
	if turn == 'player_rpsh':
		rpsh('scissor')

#function that runs for after the player chooses a option for rock paper scissor shoe
func rpsh(player_move: String) -> void:
	RPSHpanel.global_position = {'rock' : rock, 'paper' : paper, 'scissor' : scissor}[player_move].global_position
	RPSHpanel.show()
	turn = 'rpsh_proccessing'
	await get_tree().create_timer(0.5).timeout
	var opponent_move: String = ['rock', 'paper', 'scissor'][randi_range(0, 2)]
	opponentmove.text = '[right]' + opponent_move.capitalize() + ' [/right]'
	
	#determines who won based on the player and opponent moves
	var win: String = 'tie'
	if player_move == 'rock':
		if opponent_move == 'rock':
			win = 'tie'
		elif opponent_move == 'paper':
			win = 'opponent'
		elif opponent_move == 'scissor':
			win = 'player'
	elif player_move == 'paper':
		if opponent_move == 'rock':
			win = 'player'
		elif opponent_move == 'paper':
			win = 'tie'
		elif opponent_move == 'scissor':
			win = 'opponent'
	elif player_move == 'scissor':
		if opponent_move == 'rock':
			win = 'opponent'
		elif opponent_move == 'paper':
			win = 'player'
		elif opponent_move == 'scissor':
			win = 'tie'
	
	#continues the program based on who won
	won.show()
	await get_tree().create_timer(0.5).timeout
	if win == 'tie':
		turn = 'player_rpsh'
		won.text = '[right]TIE'
		post_rpsh()
	elif win == 'player':
		turn = 'player_hand_pick'
		bump.show()
		won.text = '[right]PLAYER WIN'
		post_rpsh()
	elif win == 'opponent':
		turn = 'opponent_attk'
		won.text = '[right]OPPONENT WIN'
		post_rpsh()
		opponent_attk()

#removes the rock paper scissor shoe UI after a round
func post_rpsh() -> void:
	await get_tree().create_timer(1.5).timeout
	if turn != 'rpsh_proccessing':
		won.hide()
		opponentmove.text = ''
		RPSHpanel.hide()

#returns the 2 hands that the opponent uses to move with
func split_dict(combined : String) -> Array:
	return [combined[0] + combined[1], combined[3] + combined[4]]

#calculates what the opponent should do next
func opponent_calculations() -> String:
	var calculations: Dictionary = {'OR/PL' : 0, 'OR/PR' : 0, 'OL/PL' : 0, 'OL/PR' : 0}
	if hands['OR'] != 0:
		if hands['PL'] != 0:
			calculations['OR/PL'] = hands['OR'] + hands['PL']
		if hands['PR'] != 0:
			calculations['OR/PR'] = hands['OR'] + hands['PR']
	if hands['OL'] != 0:
		if hands['PL'] != 0:
			calculations['OL/PL'] = hands['OL'] + hands['PL']
		if hands['PR'] != 0:
			calculations['OL/PR'] = hands['OL'] + hands['PR']
	
	#determines whether the opponent should move or bump
	if immediate_removal(calculations, Saved.max_hand_num):
		return get_closest(calculations, Saved.max_hand_num)
	elif (hands['OR'] == 0 or hands['OL'] == 0) and hands['OR'] + hands['OL'] > 1:
		var combined: int = hands['OR'] + hands['OL']
		var top: int = 0
		while true:
			top = randi_range(1, clamp(combined, 1, Saved.max_hand_num - 1))
			if combined - top > 0:
				break
		hands['OR'] = top
		hands['OL'] = combined - top
		return 'bumped'
	else:
		return get_closest(calculations, Saved.max_hand_num)

#determines if the opponent can immediatly remove a player hand after the move they make
func immediate_removal(calcs: Dictionary, closest_to: float) -> bool:
	for calc: String in calcs:
		if calcs[calc] != 0:
			var distance: int = abs(closest_to - calcs[calc])
			if distance == 0:
				return true
	return false

#gets closest number in calcs to closest_to
func get_closest(calcs: Dictionary, closest_to: float) -> String:
	var closest: int = 1000
	var closest_move: String = 'n/a'
	for calc: String in calcs:
		if calcs[calc] != 0:
			var distance: int = abs(closest_to - calcs[calc])
			if distance < closest:
				closest = distance
				closest_move = calc
	return closest_move

#subtracts the max number from each of the hands if the hand is equal to or over the max number
func remove_problems(maxd: int) -> void:
	for h: String in hands:
		if hands[h] >= maxd:
			hands[h] -= maxd
	
	if hands['PL'] == 0 and hands['PR'] == 0:
		endgame('opponent')
	elif hands['OL'] == 0 and hands['OR'] == 0:
		endgame('player')

#runs when the player or opponent loses
func endgame(wongame: String) -> void:
	ending = true
	if wongame == 'player':
		#tell the player they won and reset if they won
		helper.text = '[center]' + 'You won!'
		Saved.player_wins += 1
		restart()
	if wongame == 'opponent':
		#tell the player they lost and reset if the opponent won
		helper.text = '[center]' + 'You lost!'
		Saved.opponent_wins += 1
		restart()

#reloads the game
func restart() -> void:
	await get_tree().create_timer(2).timeout
	helper.text = '[center]' + 'Next round loading...'
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()

#restarts the whole game
func _on_restart_pressed() -> void:
	Saved.hand_num_set = false
	Saved.player_wins = 0
	Saved.opponent_wins = 0
	get_tree().reload_current_scene()
