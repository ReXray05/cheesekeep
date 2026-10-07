extends RefCounted
class_name EconomyManager

var coins: int = 0
var ammo: int = 0
var config: Dictionary = {}

func setup(cfg: Dictionary) -> void:
	config = cfg.duplicate(true)
	coins = maxi(0, int(config.get("start_coins", 10)))
	ammo = maxi(0, int(config.get("start_ammo", 40)))

func earn(amount: int) -> void:
	if amount > 0:
		coins += amount

func spend(amount: int) -> bool:
	if amount < 0 or coins < amount:
		return false
	coins -= amount
	return true

func buy_ammo() -> bool:
	var price: int = int(config.get("ammo_price", 6))
	var pack: int = int(config.get("ammo_pack", 10))
	if pack <= 0 or not spend(price):
		return false
	ammo += pack
	return true

func consume_arrow() -> bool:
	if ammo <= 0:
		return false
	ammo -= 1
	return true
