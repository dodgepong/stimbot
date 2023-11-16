# Description:
#   A way to interact with the Google Images API.
#
# Configuration
#   HUBOT_GOOGLE_CSE_KEY - Your Google developer API key
#   HUBOT_GOOGLE_CSE_ID - The ID of your Custom Search Engine
#   HUBOT_MUSTACHIFY_URL - Optional. Allow you to use your own mustachify instance.
#   HUBOT_GOOGLE_IMAGES_HEAR - Optional. If set, bot will respond to any line that begins with "image me" or "animate me" without needing to address the bot directly
#   HUBOT_GOOGLE_SAFE_SEARCH - Optional. Search safety level.
#   HUBOT_BING_API_KEY - Optional. Your Bing API key if you want to use that as a fallback.
#
# Commands:
#   hubot image me <query> - The Original. Queries Google Images for <query> and returns a random top result.
#   hubot animate me <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.

module.exports = (robot) ->

  robot.respond /(image|img)( me)? (.+)/i, (msg) ->
    !/(soup|tube)/i.test(msg.match[3]) && imageMe msg, msg.match[3], (url) ->
      msg.send url

  robot.respond /animate( me)? (.+)/i, (msg) ->
    imageMe msg, msg.match[2], true, (url) ->
      msg.send url

  # pro feature, not added to docs since you can't conditionally document commands
  if process.env.HUBOT_GOOGLE_IMAGES_HEAR?
    robot.hear /^(image|img) me (.+)/i, (msg) ->
      !/(soup|tube)/i.test(msg.match[2]) && imageMe msg, msg.match[2], (url) ->
        msg.send url

    robot.hear /^animate me (.+)/i, (msg) ->
      imageMe msg, msg.match[1], true, (url) ->
        msg.send url

  # robot.respond /(?:mo?u)?sta(?:s|c)h(?:e|ify)?(?: me)? (.+)/i, (msg) ->
  #   mustacheBaseUrl =
  #     process.env.HUBOT_MUSTACHIFY_URL?.replace(/\/$/, '') or
  #     "http://mustachify.me"
  #   mustachify = "#{mustacheBaseUrl}/rand?src="
  #   imagery = msg.match[1]
  #
  #   if imagery.match /^https?:\/\//i
  #     encodedUrl = encodeURIComponent imagery
  #     msg.send "#{mustachify}#{encodedUrl}"
  #   else
  #     imageMe msg, imagery, false, true, (url) ->
  #       encodedUrl = encodeURIComponent url
  #       msg.send "#{mustachify}#{encodedUrl}"

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  googleImageSearch(msg, query, animated, faces, cb, process.env.HUBOT_GOOGLE_CSE_KEY)

googleImageSearch = (msg, query, animated, faces, cb, apiKey) ->
  googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
  if googleCseId
    # Using Google Custom Search API
    googleApiKey = apiKey
    if !googleApiKey
      msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
      msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
      return
    q =
      q: query,
      searchType:'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      cx: googleCseId,
      key: googleApiKey,
      siteSearchFilter:'e',
      siteSearch:'orig00.deviantart.net'
    if animated is true
      q.fileType = 'gif'
      q.hq = 'animated'
      q.tbs = 'itp:animated'
    if faces is true
      q.imgType = 'face'
    url = 'https://www.googleapis.com/customsearch/v1'
    msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return false
        if res.statusCode is 403
          return backupGoogleImageSearch(msg, query, animated, faces, cb, process.env.HUBOT_GOOGLE_CSE_KEY_BACKUP)
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return false
        response = JSON.parse(body)
        if response?.items
          image = msg.random response.items
          cb ensureResult(image.link, animated)
          return true
        else
          msg.send "Oops. I had trouble searching '#{query}'. Try later."
          ((error) ->
            msg.robot.logger.error error.message
            msg.robot.logger
              .error "(see #{error.extendedHelp})" if error.extendedHelp
          ) error for error in response.error.errors if response.error?.errors
          return false
  else
    return false
  
backupGoogleImageSearch = (msg, query, animated, faces, cb, apiKey) ->
  googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
  if googleCseId
    # Using Google Custom Search API
    googleApiKey = apiKey
    if !googleApiKey
      msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
      msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
      return
    q =
      q: query,
      searchType:'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      cx: googleCseId,
      key: googleApiKey,
      siteSearchFilter:'e',
      siteSearch:'deviantart.net'
    if animated is true
      q.fileType = 'gif'
      q.hq = 'animated'
      q.tbs = 'itp:animated'
    if faces is true
      q.imgType = 'face'
    url = 'https://www.googleapis.com/customsearch/v1'
    msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return false
        if res.statusCode is 403
          msg.send "Daily Google API usage exceeded. Sorry :("
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return false
        response = JSON.parse(body)
        if response?.items
          image = msg.random response.items
          cb ensureResult(image.link, animated)
          return true
        else
          msg.send "Oops. I had trouble searching '#{query}'. Try later."
          ((error) ->
            msg.robot.logger.error error.message
            msg.robot.logger
              .error "(see #{error.extendedHelp})" if error.extendedHelp
          ) error for error in response.error.errors if response.error?.errors
          return false
  else
    return false

deprecatedImage = (msg, query, animated, faces, cb) ->
  # Using deprecated Google image search API
  q =
    v: '1.0'
    rsz: '8'
    q: query
    safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'active'
  if animated is true
    q.as_filetype = 'gif'
    q.q += ' animated'
  if faces is true
    q.as_filetype = 'jpg'
    q.imgtype = 'face'
  msg.http('https://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get() (err, res, body) ->
      if err
        msg.send "Encountered an error :( #{err}"
        return
      if res.statusCode isnt 200
        msg.send "Bad HTTP response :( #{res.statusCode}"
        return
      images = JSON.parse(body)
      images = images.responseData?.results
      if images?.length > 0
        image = msg.random images
        cb ensureResult(image.unescapedUrl, animated)
      else
        msg.send "Sorry, I found no results for '#{query}'."

bingImageSearch = (msg, query, animated, faces, cb) ->
  # Using Bing Search API for images
  bingApiKey = process.env.HUBOT_BING_API_KEY
  if !bingApiKey
    msg.robot.logger.error "Missing environment variable HUBOT_BING_API_KEY"
    msg.send "Missing server environment variable HUBOT_BING_API_KEY"
    return
  q =
    $format: 'json',
    Query: "'#{query}'",
    Adult: "'Strict'"

  encoded_key = new Buffer("#{bingApiKey}:#{bingApiKey}").toString("base64")
  url = "https://api.datamarket.azure.com/Bing/Search/Image"
  msg.http(url)
    .query(q)
    .header("Authorization", "Basic #{encoded_key}")
    .get() (err, res, body) ->
      if err
        msg.send "Encountered an error :( #{err}"
        return
      if res.statusCode is 403
        msg.send "Bing Image API quota exceeded, too. That's actually impressive. Your reward is waiting another hour or so before you can search for more images."
        return
      if res.statusCode isnt 200
        msg.send "Bad HTTP response :( #{res.statusCode}"
        return
      response = JSON.parse(body)
      if response?.d && response.d.results
        image = msg.random response.d.results
        cb ensureResult(image.MediaUrl, animated)
      else
        msg.send "Oops. I had trouble searching '#{query}'. Try later."

# Forces giphy result to use animated version
ensureResult = (url, animated) ->
  if animated is true
    ensureImageExtension url.replace(
      /(giphy\.com\/.*)\/.+_s.gif$/,
      '$1/giphy.gif')
  else
    ensureImageExtension url

# Forces the URL look like an image URL by adding `#.png`
ensureImageExtension = (url) ->
  if /(png|jpe?g|gif)$/i.test(url)
    url
  else
    "#{url}#.png"
