# Description:
#   Tool for choosing generating a random deck name.
#   Courtesy of EmergencyShutdown.net
#
# Commands:
#   !deckname - Generates a random deck name from EmergencyShutdown.net

module.exports = (robot) ->
    robot.hear /!deck\s?name/i, (msg) ->
        robot.http("http://www.emergencyshutdown.net/api.php")
            .get() (err, res, body) ->
                if body
                    msg.send body
