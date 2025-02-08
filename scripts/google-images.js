// Description:
//   A way to interact with the Google Images API.
//
// Configuration
//   HUBOT_GOOGLE_CSE_KEY - Your Google developer API key
//   HUBOT_GOOGLE_CSE_ID - The ID of your Custom Search Engine
//   HUBOT_MUSTACHIFY_URL - Optional. Allow you to use your own mustachify instance.
//   HUBOT_GOOGLE_IMAGES_HEAR - Optional. If set, bot will respond to any line that begins with "image me" or "animate me" without needing to address the bot directly
//   HUBOT_GOOGLE_SAFE_SEARCH - Optional. Search safety level.
//   HUBOT_BING_API_KEY - Optional. Your Bing API key if you want to use that as a fallback.
//
// Commands:
//   hubot image me <query> - The Original. Queries Google Images for <query> and returns a random top result.
//   hubot animate me <query> - The same thing as `image me`, except adds a few parameters to try to return an animated GIF instead.

module.exports = (robot) => {

  robot.respond(/(image|img)( me)? (.+)/i, (msg) => {
    imageMe(msg, msg.match[3], (url) => {
      msg.send(url);
    });
  });

  robot.respond(/animate( me)? (.+)/i, (msg) => {
    imageMe(msg, msg.match[2], true, (url) => {
      msg.send(url);
    });
  });

  if (process.env.HUBOT_GOOGLE_IMAGES_HEAR) {
    robot.hear(/^(image|img) me (.+)/i, (msg) => {
      imageMe(msg, msg.match[2], (url) => {
        msg.send(url);
      });
    });

    robot.hear(/^animate me (.+)/i, (msg) => {
      imageMe(msg, msg.match[1], true, (url) => {
        msg.send(url);
      });
    });
  }
};

const imageMe = (msg, query, animated, faces, cb) => {
  if (typeof animated === 'function') cb = animated;
  if (typeof faces === 'function') cb = faces;
  googleImageSearch(msg, query, animated, faces, cb, process.env.HUBOT_GOOGLE_CSE_KEY);
};

const googleImageSearch = (msg, query, animated, faces, cb, apiKey) => {
  const googleCseId = process.env.HUBOT_GOOGLE_CSE_ID;
  if (googleCseId) {
    const googleApiKey = apiKey;
    if (!googleApiKey) {
      msg.robot.logger.error("Missing environment variable HUBOT_GOOGLE_CSE_KEY");
      msg.send("Missing server environment variable HUBOT_GOOGLE_CSE_KEY.");
      return;
    }
    const q = {
      q: query,
      searchType: 'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      cx: googleCseId,
      key: googleApiKey,
      siteSearchFilter: 'e',
      siteSearch: 'orig00.deviantart.net'
    };
    if (animated === true) {
      q.fileType = 'gif';
      q.hq = 'animated';
      q.tbs = 'itp:animated';
    }
    if (faces === true) {
      q.imgType = 'face';
    }
    const url = 'https://www.googleapis.com/customsearch/v1';
    msg.http(url)
      .query(q)
      .get()((err, res, body) => {
        if (err) {
          msg.send(`Encountered an error :( ${err}`);
          return false;
        }
        if (res.statusCode === 403) {
          return backupGoogleImageSearch(msg, query, animated, faces, cb, process.env.HUBOT_GOOGLE_CSE_KEY_BACKUP);
        }
        if (res.statusCode !== 200) {
          msg.send(`Bad HTTP response :( ${res.statusCode}`);
          return false;
        }
        const response = JSON.parse(body);
        if (response?.items) {
          const image = msg.random(response.items);
          cb(ensureResult(image.link, animated));
          return true;
        } else {
          msg.send(`Oops. I had trouble searching '${query}'. Try later.`);
          if (response.error?.errors) {
            response.error.errors.forEach((error) => {
              msg.robot.logger.error(error.message);
              if (error.extendedHelp) {
                msg.robot.logger.error(`(see ${error.extendedHelp})`);
              }
            });
          }
          return false;
        }
      });
  } else {
    return false;
  }
};

const backupGoogleImageSearch = (msg, query, animated, faces, cb, apiKey) => {
  const googleCseId = process.env.HUBOT_GOOGLE_CSE_ID;
  if (googleCseId) {
    const googleApiKey = apiKey;
    if (!googleApiKey) {
      msg.robot.logger.error("Missing environment variable HUBOT_GOOGLE_CSE_KEY");
      msg.send("Missing server environment variable HUBOT_GOOGLE_CSE_KEY.");
      return;
    }
    const q = {
      q: query,
      searchType: 'image',
      safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'high',
      cx: googleCseId,
      key: googleApiKey,
      siteSearchFilter: 'e',
      siteSearch: 'deviantart.net'
    };
    if (animated === true) {
      q.fileType = 'gif';
      q.hq = 'animated';
      q.tbs = 'itp:animated';
    }
    if (faces === true) {
      q.imgType = 'face';
    }
    const url = 'https://www.googleapis.com/customsearch/v1';
    msg.http(url)
      .query(q)
      .get()((err, res, body) => {
        if (err) {
          msg.send(`Encountered an error :( ${err}`);
          return false;
        }
        if (res.statusCode === 403) {
          msg.send("Daily Google API usage exceeded. Sorry :(");
        }
        if (res.statusCode !== 200) {
          msg.send(`Bad HTTP response :( ${res.statusCode}`);
          return false;
        }
        const response = JSON.parse(body);
        if (response?.items) {
          const image = msg.random(response.items);
          cb(ensureResult(image.link, animated));
          return true;
        } else {
          msg.send(`Oops. I had trouble searching '${query}'. Try later.`);
          if (response.error?.errors) {
            response.error.errors.forEach((error) => {
              msg.robot.logger.error(error.message);
              if (error.extendedHelp) {
                msg.robot.logger.error(`(see ${error.extendedHelp})`);
              }
            });
          }
          return false;
        }
      });
  } else {
    return false;
  }
};

const deprecatedImage = (msg, query, animated, faces, cb) => {
  const q = {
    v: '1.0',
    rsz: '8',
    q: query,
    safe: process.env.HUBOT_GOOGLE_SAFE_SEARCH || 'active'
  };
  if (animated === true) {
    q.as_filetype = 'gif';
    q.q += ' animated';
  }
  if (faces === true) {
    q.as_filetype = 'jpg';
    q.imgtype = 'face';
  }
  msg.http('https://ajax.googleapis.com/ajax/services/search/images')
    .query(q)
    .get()((err, res, body) => {
      if (err) {
        msg.send(`Encountered an error :( ${err}`);
        return;
      }
      if (res.statusCode !== 200) {
        msg.send(`Bad HTTP response :( ${res.statusCode}`);
        return;
      }
      const images = JSON.parse(body).responseData?.results;
      if (images?.length > 0) {
        const image = msg.random(images);
        cb(ensureResult(image.unescapedUrl, animated));
      } else {
        msg.send(`Sorry, I found no results for '${query}'.`);
      }
    });
};

const bingImageSearch = (msg, query, animated, faces, cb) => {
  const bingApiKey = process.env.HUBOT_BING_API_KEY;
  if (!bingApiKey) {
    msg.robot.logger.error("Missing environment variable HUBOT_BING_API_KEY");
    msg.send("Missing server environment variable HUBOT_BING_API_KEY");
    return;
  }
  const q = {
    $format: 'json',
    Query: `'${query}'`,
    Adult: "'Strict'"
  };

  const encoded_key = Buffer.from(`${bingApiKey}:${bingApiKey}`).toString("base64");
  const url = "https://api.datamarket.azure.com/Bing/Search/Image";
  msg.http(url)
    .query(q)
    .header("Authorization", `Basic ${encoded_key}`)
    .get()((err, res, body) => {
      if (err) {
        msg.send(`Encountered an error :( ${err}`);
        return;
      }
      if (res.statusCode === 403) {
        msg.send("Bing Image API quota exceeded, too. That's actually impressive. Your reward is waiting another hour or so before you can search for more images.");
        return;
      }
      if (res.statusCode !== 200) {
        msg.send(`Bad HTTP response :( ${res.statusCode}`);
        return;
      }
      const response = JSON.parse(body);
      if (response?.d && response.d.results) {
        const image = msg.random(response.d.results);
        cb(ensureResult(image.MediaUrl, animated));
      } else {
        msg.send(`Oops. I had trouble searching '${query}'. Try later.`);
      }
    });
};

const ensureResult = (url, animated) => {
  if (animated === true) {
    return ensureImageExtension(url.replace(/(giphy\.com\/.*)\/.+_s.gif$/, '$1/giphy.gif'));
  } else {
    return ensureImageExtension(url);
  }
};

const ensureImageExtension = (url) => {
  if (/(png|jpe?g|gif)$/i.test(url)) {
    return url;
  } else {
    return `${url}#.png`;
  }
};