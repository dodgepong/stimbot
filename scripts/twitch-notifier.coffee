# Description:
#   Tool for notifying a chat room of live Netrunner streams when they go live.
#
# Commands:
#	!streams - Displays a list of all currently-live Netrunner streams.

REFRESH_FREQUENCY = 300000 # 5 min

module.exports = (robot) ->
	if process.env.TWITCH_NOTIFIER_ROOM == 'true'
		robot.logger.info "Enabling Twitch Notifier"
		setInterval () ->
			robot.logger.info 'Fetching new Twitch stream listings'
			url = 'https://api.twitch.tv/kraken/streams?game=Android:%20Netrunner
			known_streams = robot.brain.get('streams')
			if !known_streams?
				known_streams = {}
			new_streams = {}
			robot.http(url)
				.header('Accept', 'application/json')
				.header('Client-ID', process.env.TWITCH_CLIENT_ID)
				.get() (err, res, body) ->
					if err
						robot.logger.error 'Error retrieving stream list from Twitch'
						return
					if res.statusCode isnt 200 and res.statusCode isnt 304
						robot.logger.error 'Received bad status code #{res.statusCode} while trying to retrieve stream list from Twitch'
					response = JSON.parse(body)
					if response?.streams
						for stream in response.streams

							# if the channel isn't in our known list of live streams, notify the channel of it
							if stream.channel.name not of known_streams
								robot.logger.info "Notifying of new live channel #{stream.channel.name}"
								robot.messageRoom process.env.TWITCH_NOTIFIER_ROOM, "#{stream.channel.name} just went live playing Android: Netrunner on Twitch with the title \"#{stream.channel.status}\" - http://twitch.tv/#{stream.channel.name}" 

							# add stream to new brain data
							new_streams[stream.channel.name] = stream.channel.status

						# overwrite previous data with new data of all currently-live streams
						robot.brain.set 'streams', new_streams
					robot.logger.info 'Finished checking for new Twitch streams'
		, REFRESH_FREQUENCY
	else
		robot.logger.info "Disabling Twitch Notifier"

	robot.hear /!stream(s)?/i, (msg) ->
		streams = robot.brain.get('streams')
		if !streams?
			streams = {}

		num_live_streams = Object.keys(streams).length
		if num_live_streams is 0
			msg.send "No streams are live right now. :("
		else
			plural = "streams"
			if num_live_streams is 1
				plural = "stream"
			msg.send "#{Object.keys(streams).length} #{plural} live right now:"
			for stream, title of streams
				msg.send "#{title} - http://twitch.tv/#{stream}"
