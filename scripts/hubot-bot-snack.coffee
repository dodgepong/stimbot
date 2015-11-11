# Description:
#   Give stimbot a snack.
#
# Commands:
#   stimbot bot snack - Give stimbot a snack

module.exports = (robot) ->
	robot.hear /bot snack/i, (res) ->
		res.send "Yum!"