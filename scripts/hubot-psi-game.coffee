# Description:
#   Play a psi game.
#
# Commands:
#   !psi [0, 1, or 2] - play a psi game against stimbot

module.exports = (robot) ->
	robot.hear /^!psi (\d+)\s*$/i, (res) ->
		bid = parseInt(res.match[1])
		if bid in [0, 1, 2]
			myBid = Math.floor(Math.random() * 3)
			win = "I win!"
			if bid == myBid
				win = "you win!"
			res.send ":psi: Your bid: " + bid + ":credit:, my bid: " + myBid + ":credit:, " + win
		else
			res.send ":psi: Hey, that's an illegal bid! Judge!"
