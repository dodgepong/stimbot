# Description:
#	Spin the Netrunner Wheel of Fortune
#
# Commands:
#	!spin - have stimbot spin the wheel

WHEEL_SECTIONS = [
	"ONR Rules",
	"Gain 1 Credit",
	"Free Mushin!",
	"Lose 1 Click",
	"DANCE",
	"Draw 2 Cards",
	"Breaking News is legal",
	"Trash an installed card",
	"Reroll all dice used as counters",
	"Double Damage",
	"Token eating contest!",
	"Swap sides"
]

module.exports = (robot) ->
	robot.hear /!spin/, (res) ->
		position = Math.floor(Math.random() * WHEEL_SECTIONS.length);
		selection = WHEEL_SECTIONS[position];

		res.send "Spinning the wheel! Whrrr....."
		res.send selection
