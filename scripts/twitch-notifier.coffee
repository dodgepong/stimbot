# Description:
#   Tool for notifying a chat room of live Netrunner streams when they go live.

REFRESH_FREQUENCY = 300000 # 5 minutes
ROOM = '#testing'

module.exports = (robot) ->
	setInterval () ->
		url = 'https://api.twitch.tv/kraken/streams?game=Android:%20Netrunner'
		known_streams = robot.brain.get('streams')
		if !known_streams?
			known_streams = {}
		robot.logger.info known_streams
		new_streams = {}
		robot.http(url)
			.header('Accept', 'application/json')
			.get() (err, res, body) ->
				if err
					robot.logger.error 'Error retrieving stream list from Twitch'
					return
				if res.statusCode isnt 200 and res.statusCode isnt 304
					robot.logger.error 'Received bad status code #{res.statusCode} while trying to retrieve stream list from Twitch'
				response = JSON.parse(body)
				if response?.streams
					for stream in response.streams
						if stream.channel.name not of known_streams
							robot.messageRoom ROOM, "#{stream.channel.name} just went live playing Android: Netrunner on Twitch with the title #{stream.channel.status} - http://twitch.tv/#{stream.channel.name}" 
						new_streams[stream.channel.name] = stream.channel.status
					robot.brain.set 'streams', new_streams
					return
				robot.logger.info "Finished checking for Twitch streams"
	, REFRESH_FREQUENCY

	robot.hear /!streams/, (msg) ->
		known_streams = robot.brain.get('streams')
		if !known_streams?
			known_streams = {}
			msg.send known_streams
