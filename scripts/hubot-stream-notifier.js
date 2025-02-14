// Description:
//   Tool for notifying a chat room of live Netrunner streams when they go live.
//
// Commands:
//   !streams - Displays a list of all currently-live Netrunner streams.

const TWITCH_REFRESH_FREQUENCY = 120000; // 2 minutes
const TWITCH_NETRUNNER_GAME_ID = 1289748982;
const TWITCH_STREAMS_URL = `https://api.twitch.tv/helix/streams?game_id=${TWITCH_NETRUNNER_GAME_ID}`;
const TWITCH_TOKEN_URL = 'https://id.twitch.tv/oauth2/token';

const YOUTUBE_REFRESH_FREQUENCY = 360000; // 6 min

const YOUTUBE_LIVE_CHANNELS = [
  "UC1_GRSFQILc4KEOUj7G0SXw", // beyoken
  "UCQ7hPuO4R15t0qAKnjFi-Iw", // Metropole Grid
  "UCk3Ylq2jwldNGynR7HLoFbA", // VTTV
  "UCeJXRdVkWl_5Id7UwPvbvpg", // The Hacktivist
  "UCdtsV_b5GRZUDKVjc1KgmOA", // System Outage
  "UCNh1ufhc1xCa26M0nYurpNQ", // Trace 5
  "UCvFq-jHrBul6S56kGkT5OxQ", // Hidden Assets
  "UCwzXbVje3ACE4oM4xa6HaHg"  // ANRNZ
];

const EXCLUDED_TERMS = [
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
  "Darkest Dungeon",
  "Mario",
  "Marvel"
];

module.exports = (robot) => {
  if (process.env.ENABLE_TWITCH_NOTIFIER === 'true') {
    robot.logger.info("Enabling Twitch Notifier");
    setInterval(() => {
      let known_streams = robot.brain.get('twitch-streams');
      if (!known_streams) {
        known_streams = {};
      }

      // I don't feel like maintaining an access token and dynamically refreshing it based on 401 responses
      // So I'm going to be an asshole and request a new app token on every goddamn check
      const body = `client_id=${process.env.TWITCH_CLIENT_ID}&client_secret=${process.env.TWITCH_CLIENT_SECRET}&grant_type=client_credentials`;
      robot.http(TWITCH_TOKEN_URL)
        .header('Content-Type', 'application/x-www-form-urlencoded')
        .post(body)((err, res, body) => {
          if (err) {
            if (body) {
              const response = JSON.parse(body);
              robot.logger.error(`Error retrieving stream list from Twitch: HTTP ${res.statusCode} - ${response.message}`);
            } else {
              robot.logger.error(`Error retrieving stream list from Twitch: HTTP ${res.statusCode}`);
            }
            return;
          }
          robot.logger.info("Got Twitch app auth token");
          const token = JSON.parse(body);

          robot.http(TWITCH_STREAMS_URL)
            .header('Authorization', `Bearer ${token.access_token}`)
            .header('Client-Id', process.env.TWITCH_CLIENT_ID)
            .get()((err, res, body) => {
              const new_streams = {};
              if (err) {
                robot.logger.error('Error retrieving stream list from Twitch');
                return;
              }
              if (res.statusCode !== 200 && res.statusCode !== 304) {
                robot.logger.error(`Received bad status code ${res.statusCode} while trying to retrieve stream list from Twitch`);
                return;
              }
              const response = JSON.parse(body);
              robot.logger.info("known streams: " + JSON.stringify(known_streams));
              robot.logger.info("response: " + JSON.stringify(response));
              for (const stream of response.data) {
                robot.logger.info("checking stream " + stream.user_name);
                // if the channel isn't in our known list of live streams, notify the channel of it
                if (!(stream.user_name in known_streams)) {
                  robot.logger.info(`Notifying of new live channel ${stream.user_name}`);
                  for (const room of process.env.STREAM_NOTIFIER_ROOMS.split(',')) {
                    robot.messageRoom(room, `${stream.user_name} just went live playing Netrunner on Twitch with the title "${stream.title}" - https://twitch.tv/${stream.user_login}`);
                  }
                }
                // add stream to new brain data
                new_streams[stream.user_name] = stream.title;
              }
              // overwrite previous data with new data of all currently-live streams
              robot.brain.set('twitch-streams', new_streams);
            });
        });
    }, TWITCH_REFRESH_FREQUENCY);
  } else {
    robot.logger.info("Disabling Twitch Notifier");
  }

  if (process.env.ENABLE_YOUTUBE_NOTIFIER === 'true') {
    robot.logger.info("Enabling YouTube Notifier");
    setInterval(() => {
      for (const youtube_channel of YOUTUBE_LIVE_CHANNELS) {
        // use a closure to keep youtube_channel local
        ((youtube_channel) => {
          const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${youtube_channel}&eventType=live&type=video&key=${process.env.YOUTUBE_API_KEY}`;
          robot.http(url)
            .get()((err, res, body) => {
              if (err) {
                robot.logger.error('Error retrieving stream list from YouTube');
                return;
              }
              if (res.statusCode !== 200 && res.statusCode !== 304) {
                robot.logger.error(`Received bad status code ${res.statusCode} while trying to retrieve stream list from YouTube`);
                return;
              }
              const response = JSON.parse(body);
              let known_streams = robot.brain.get('youtube-streams');
              if (!known_streams) {
                known_streams = {};
              }
              if (response?.items && response.items.length > 0) {
                // since we're getting one channel at a time, assume there is only one live stream at a time
                const stream = response.items[0];
                if (response.items.length > 1) {
                  robot.logger.info(`Stream listing for YouTube channel ${youtube_channel} had more than 1 search result. Using first...`);
                }

                let contains_excluded_term = false;
                for (const term of EXCLUDED_TERMS) {
                  const termRegex = new RegExp(term, "i");
                  if (stream.snippet.title.match(termRegex)) {
                    contains_excluded_term = true;
                  }
                }

                // if the channel isn't in our known list of live streams, notify the channel of it
                if (!(youtube_channel in known_streams) && !contains_excluded_term) {
                  robot.logger.info(`Notifying of new live channel ${stream.snippet.channelTitle}`);
                  for (const room of process.env.STREAM_NOTIFIER_ROOMS.split(',')) {
                    robot.messageRoom(room, `${stream.snippet.channelTitle} just went live on YouTube with the title "${stream.snippet.title}" - https://gaming.youtube.com/watch?v=${stream.id.videoId}`);
                  }
                  // add stream to new brain data
                  known_streams[youtube_channel] = { channelTitle: stream.snippet.channelTitle, streamTitle: stream.snippet.title, videoId: stream.id.videoId };
                } else if (youtube_channel in known_streams && contains_excluded_term) {
                  robot.logger.info(`YouTube channel ${youtube_channel} no longer broadcasting relevant content, deleting...`);
                  delete known_streams[youtube_channel];
                }
              } else if (known_streams[youtube_channel]) {
                robot.logger.info(`YouTube channel ${youtube_channel} no longer live, deleting...`);
                delete known_streams[youtube_channel];
              }
              // overwrite previous data with new data of all currently-live streams
              robot.brain.set('youtube-streams', known_streams);
            });
        })(youtube_channel);
      }
    }, YOUTUBE_REFRESH_FREQUENCY);
  } else {
    robot.logger.info("Disabling YouTube Notifier");
  }

  robot.hear(/!(stream|dream|meme|scream|cream|creme|crème|beam|steam|scheme|team|theme|bream|seam|gleam)(s)?/i, (msg) => {
    const command = msg.match[1];
    if (process.env.ENABLE_TWITCH_NOTIFIER !== 'true' && process.env.ENABLE_YOUTUBE_NOTIFIER !== 'true') {
      msg.send("The Stream Notifier bot is offline right now. You can see all live Android: Netrunner Twitch streams here: https://www.twitch.tv/directory/game/Android%3A%20Netrunner");
    } else {
      let twitch_streams = robot.brain.get('twitch-streams');
      if (!twitch_streams) {
        twitch_streams = {};
      }
      let youtube_streams = robot.brain.get('youtube-streams');
      if (!youtube_streams) {
        youtube_streams = {};
      }
      let live = "live";
      if (command === "meme") {
        live = "dank";
      }
      if (command === "beam") {
        live = "charging";
      }
      if (command === "theme") {
        live = "developing";
      }
      if (command === "scheme") {
        live = "plotting";
      }
      const num_live_streams = Object.keys(twitch_streams).length + Object.keys(youtube_streams).length;
      if (num_live_streams === 0) {
        msg.send(`No ${command}s are ${live} right now. :(`);
      } else {
        let plural = command + "s";
        let are = "are";
        if (num_live_streams === 1) {
          plural = command;
          are = "is";
        }
        let message = `${num_live_streams} ${plural} ${are} ${live} right now:`;
        for (const [stream, title] of Object.entries(twitch_streams)) {
          message += `\n:twitch: ${title} (${stream}) - https://twitch.tv/${stream}`;
        }
        for (const [channelId, yt_stream] of Object.entries(youtube_streams)) {
          message += `\n:youtube: ${yt_stream.streamTitle} (${yt_stream.channelTitle}) - https://gaming.youtube.com/watch?v=${yt_stream.videoId}`;
        }
        msg.send(message);
      }
    }
  });
};