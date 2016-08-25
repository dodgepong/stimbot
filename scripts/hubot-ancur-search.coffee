# Description:
#   Tool for searching ANCUR's archives
#
# Commands:
#   !ancur <search term> - search ANCUR for pages related to <search term>

module.exports = (robot) ->
    robot.hear /!ancur (.+)/i, (msg) ->
        query = msg.match[1]
        robot.http("http://ancur.wikia.com/api/v1/Search/List?query=" + query)
            .get() (err, res, body) ->
                if body
                    response = JSON.parse body
                    if response.total is 0
                        msg.send 'No matches found on ANCUR for "' + query + '."'
                    else
                        title = response.items[0].title
                        url = response.items[0].url
                        msg.send title + ": " + url
