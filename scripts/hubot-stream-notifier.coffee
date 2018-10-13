# Description:
#   Tool for notifying a chat room of live Netrunner streams when they go live.
#
# Commands:
#	!streams - Displays a list of all currently-live Netrunner streams.

TWITCH_REFRESH_FREQUENCY = 120000 # 2 min (1 min would cause false positives when going offline due to caching)
YOUTUBE_REFRESH_FREQUENCY = 300000 # 5 min

YOUTUBE_LIVE_CHANNELS = [
	"UCrcjou2_8t7wFun9m68Ufyg", # ANRBlackHats
	"UCT0_zqao2b2kJBe-bmF_0og", # Team Covenant
	"UC1_GRSFQILc4KEOUj7G0SXw", # beyoken
	"UCQ7hPuO4R15t0qAKnjFi-Iw", # Metropole Grid
	"UCvPgKhNkF-axufSCv8KpxGA", # Bad Publicity
	"UCqTSZqzsRJsXzeXWDc1YTFA", # PeachHack
	"UCk3Ylq2jwldNGynR7HLoFbA", # VTTV
	"UCjwH6sQzmrlsc43YTTTQTOA", # Zeromus
	"UCeJXRdVkWl_5Id7UwPvbvpg", # The Hacktivist
	"UCdtsV_b5GRZUDKVjc1KgmOA", # System Outage
	"UCNh1ufhc1xCa26M0nYurpNQ", # Trace 5
	"UCvFq-jHrBul6S56kGkT5OxQ", # Hidden Assets
	"UCwzXbVje3ACE4oM4xa6HaHg"  # ANRNZ
]

EXCLUDED_TERMS = [
	"Destiny",
	"Conquest",
	"L5R",
	"Legend of the Five Rings",
	"Legend of the 5 Rings",
	"Imperial Assault",
	"X-wing",
	"Xwing",
	"X wing",
	"Armada",
	"Star Wars",
	"Magic",
	"MTG",
	"Arkham",
	"LOTR",
	"Lord of the Rings",
	"TumbleSeed",
	"Warhammer",
	"KeyForge",
	"Lightseekers",
	"Transformers",
	"Darkest Dungeon"
]

module.exports = (robot) ->
	if process.env.ENABLE_TWITCH_NOTIFIER is 'true'
		robot.logger.info "Enabling Twitch Notifier"
		setInterval () ->
			url = 'https://api.twitch.tv/kraken/streams?game=Android%3A%20Netrunner'
			known_streams = robot.brain.get('twitch-streams')
			if !known_streams?
				known_streams = {}
			new_streams = {}
			robot.http(url)
				.header('Accept', 'application/vnd.twitchtv.v5+json')
				.header('Client-ID', process.env.TWITCH_CLIENT_ID)
				.get() (err, res, body) ->
					if err
						robot.logger.error 'Error retrieving stream list from Twitch'
						return
					if res.statusCode isnt 200 and res.statusCode isnt 304
						robot.logger.error "Received bad status code #{res.statusCode} while trying to retrieve stream list from Twitch"
						return
					response = JSON.parse(body)
					if response?.streams
						for stream in response.streams

							# if the channel isn't in our known list of live streams, notify the channel of it
							# include game sanity check, sometimes the Twitch API is dumb and returns all streams regardless of game
							if stream.channel.name not of known_streams and stream.channel.game is 'Android: Netrunner'
								robot.logger.info "Notifying of new live channel #{stream.channel.name}"
								for room in process.env.STREAM_NOTIFIER_ROOMS.split(',')
									robot.messageRoom room, "#{stream.channel.name} just went live playing Android: Netrunner on Twitch with the title \"#{stream.channel.status}\" - https://twitch.tv/#{stream.channel.name}"

							# add stream to new brain data
							new_streams[stream.channel.name] = stream.channel.status

						# overwrite previous data with new data of all currently-live streams
						robot.brain.set 'twitch-streams', new_streams
		, TWITCH_REFRESH_FREQUENCY
	else
		robot.logger.info "Disabling Twitch Notifier"

	if process.env.ENABLE_YOUTUBE_NOTIFIER is 'true'
		robot.logger.info "Enabling YouTube Notifier"
		setInterval () ->
			for youtube_channel in YOUTUBE_LIVE_CHANNELS
				# use do() to keep youtube_channel local
				do (youtube_channel) ->
					url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=" + youtube_channel + "&eventType=live&type=video&key=" + process.env.YOUTUBE_API_KEY
					robot.http(url)
						.get() (err, res, body) ->
							if err
								robot.logger.error 'Error retrieving stream list from YouTube'
								return
							if res.statusCode isnt 200 and res.statusCode isnt 304
								robot.logger.error "Received bad status code #{res.statusCode} while trying to retrieve stream list from YouTube"
								return
							response = JSON.parse(body)
							known_streams = robot.brain.get('youtube-streams')
							if !known_streams?
								known_streams = {}
							if response?.items and response.items.length > 0
								# since we're getting one channel at a time, assume there is only one live stream at a time
								stream = response.items[0]
								if response.items.length > 1
									robot.logger.info 'Stream listing for YouTube channel ' + youtube_channel + ' had more than 1 search result. Using first...'

								contains_excluded_term = false
								for term in EXCLUDED_TERMS
									termRegex = new RegExp(term, "i")
									if stream.snippet.title.match termRegex
										contains_excluded_term = true

								# if the channel isn't in our known list of live streams, notify the channel of it
								if youtube_channel not of known_streams and not contains_excluded_term
									robot.logger.info "Notifying of new live channel #{stream.snippet.channelTitle}"
									for room in process.env.STREAM_NOTIFIER_ROOMS.split(',')
										robot.messageRoom room, "#{stream.snippet.channelTitle} just went live on YouTube with the title \"#{stream.snippet.title}\" - https://gaming.youtube.com/watch?v=#{stream.id.videoId}"

									# add stream to new brain data
									known_streams[youtube_channel] = { channelTitle: stream.snippet.channelTitle, streamTitle: stream.snippet.title, videoId: stream.id.videoId }
								else if youtube_channel of known_streams and contains_excluded_term
									robot.logger.info 'YouTube channel ' + youtube_channel + ' no longer broadcasting relevant content, deleting...'
									delete known_streams[youtube_channel]
							else if known_streams[youtube_channel]?
								robot.logger.info 'YouTube channel ' + youtube_channel + ' no longer live, deleting...'
								delete known_streams[youtube_channel]

							# overwrite previous data with new data of all currently-live streams
							robot.brain.set 'youtube-streams', known_streams
		, YOUTUBE_REFRESH_FREQUENCY
	else
		robot.logger.info "Disabling YouTube Notifier"

	robot.hear /!(stream|dream|meme|scream|cream|creme|crème|beam|steam|scheme|team|theme|bream|seam|gleam)(s)?/i, (msg) ->
		command = msg.match[1]
		if process.env.ENABLE_TWITCH_NOTIFIER isnt 'true' and process.env.ENABLE_YOUTUBE_NOTIFIER isnt 'true'
			msg.send "The Stream Notifier bot is offline right now. You can see all live Android: Netrunner Twitch streams here: https://www.twitch.tv/directory/game/Android%3A%20Netrunner"
		else
			twitch_streams = robot.brain.get('twitch-streams')
			if !twitch_streams?
				twitch_streams = {}
			youtube_streams = robot.brain.get('youtube-streams')
			if !youtube_streams?
				youtube_streams = {}
			live = "live"
			if command == "meme"
				live = "dank"
			if command == "beam"
				live = "charging"
			if command == "theme"
				live = "developing"
			if command == "scheme"
				live = "plotting"
			num_live_streams = Object.keys(twitch_streams).length + Object.keys(youtube_streams).length
			if num_live_streams is 0
				msg.send "No #{command}s are #{live} right now. :("
			else
				plural = command + "s"
				are = "are"
				if num_live_streams is 1
					plural = command
					are = "is"
				message = "#{num_live_streams} #{plural} #{are} #{live} right now:"
				for stream, title of twitch_streams
					message += "\n:twitch: #{title} (#{stream}) - https://twitch.tv/#{stream}"
				for channelId, yt_stream of youtube_streams
					message += "\n:youtube: #{yt_stream.streamTitle} (#{yt_stream.channelTitle}) - https://gaming.youtube.com/watch?v=#{yt_stream.videoId}"
				msg.send message
