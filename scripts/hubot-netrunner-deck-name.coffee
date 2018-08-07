# Description:
#   Tool for choosing generating a random deck name.
#   Courtesy of EmergencyShutdown.net
#
# Commands:
#   !deckname - Generates a random deck name from EmergencyShutdown.net

module.exports = (robot) ->
    robot.hear /!deck\s?name/i, (msg) ->
        robot.http("https://www.emergencyshutdown.net/api/deckname")
            .get() (err, res, body) ->
                if body
                    msg.send body
