extends Node

@onready var SFX := $SFX
@onready var CSFX := $CurseSFX
@onready var Music := $Music

var pitch_offset := 0.0

@export var SelectCardSFX : AudioStream
@export var TrashedSFX : AudioStream
@export var BuySFX : AudioStream
@export var BlockSFX : AudioStream

func _play_sfx(sfx, pitch_range) -> void:
	SFX.stream = sfx
	SFX.pitch_scale = pitch_range
	SFX.play()

func _play_selected_sfx() -> void:
	_play_sfx(SelectCardSFX, randf_range(0.9, 1.8))

func _play_deselected_sfx() -> void:
	_play_sfx(SelectCardSFX, randf_range(0.6, 0.8))

func _play_trashed_sfx() -> void:
	_play_sfx(TrashedSFX, randf_range(0.9, 1.5))

func _play_buy_sfx() -> void:
	_play_sfx(BuySFX, randf_range(1, 1.2))
	
func _play_block_sfx() -> void:
	_play_sfx(BlockSFX, randf_range(1, 1.2))
	
func _play_curse_sfx() -> void:
	CSFX.play()
