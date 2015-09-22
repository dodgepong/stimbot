module.exports = (robot) ->
	robot.hear /bot snack/i, (res) ->
		res.send "Yum!"