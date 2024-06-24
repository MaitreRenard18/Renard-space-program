extends Node

var celestial_bodies: Array[CelestialBody] = []
var movable_bodies: Array[MovableBody] = []


func register_celestial_body(body: CelestialBody) -> void:
    celestial_bodies.append(body)


func register_movable_body(body: MovableBody) -> void:
    movable_bodies.append(body)


func get_celestial_bodies() -> Array[CelestialBody]:
    return celestial_bodies


func get_movable_bodies() -> Array[MovableBody]:
    return movable_bodies
