class_name TEMP_PARTICLES extends Node2D

@export var free_delay: float = 5.0
@export var chain_delay: float = 0.0

@onready var initial_particles = $Initial_Particles
@onready var chain_particles = $Chain_Particles
@onready var chain_timer: Timer = $Chain_Timer
@onready var free_timer: Timer = $Free_Timer


func _ready():
	for particle in initial_particles.get_children():
		particle.emitting = true
	if chain_delay > 0:
		chain_timer.start(chain_delay)
	free_timer.start(free_delay)


func _on_chain_timer_timeout():
	for particle in chain_particles.get_children():
		particle.emitting = true


func _on_free_timer_timeout():
	queue_free()
