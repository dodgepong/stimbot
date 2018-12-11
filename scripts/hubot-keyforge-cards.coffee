# Description:
#   Tools for interacting with the KeyForge LibraryAccess.net API.
#

Fuse = require 'fuse.js'
yaml = require 'js-yaml'

ABBREVIATIONS = {}

preloadData = (robot) ->
    robot.http("http://api.libraryaccess.net:7001/cards")
        .get() (err, res, body) ->
            cardData = JSON.parse body
            robot.logger.info "Loaded " + cardData.length + " KeyForge cards (from LibraryAccess.net)"
            robot.brain.set 'kfcards', cardData.sort(compareCards)

formatCard = (card, expansionAbbr, expansionFull, number, image) ->
    title = card.name

    attachment = {
        'fallback': title,
        'title': title,
        'title_link': "http://libraryaccess.net/cards/" + expansionAbbr + "/" + number,
        'mrkdwn_in': [ 'text', 'author_name' ]
    }

    if image != ''
        attachment['thumb_url'] = image

    attachment['text'] = ''

    typeline = ""

    for house in card.houses
        typeline += ":kf-" + house + ":"

    typeline += " *#{card.type}*"
    if card.traits? and card.traits.length > 0
        typeline += ": " + card.traits.join(" • ")

    if card.type == 'Creature'
        power = "~"
        if card.power?
            power = card.power
        armor = "~"
        if card.armor?
            armor = card.armor
        typeline += "\nPower: " + power + " / Armor: " + armor

    if card.aember?
        typeline += "\n"
        aember = parseInt(card.aember)
        for num in [0..aember]
            typeline += ":aember:"

    attachment['text'] += typeline + "\n\n"

    if card.keywords? && card.keywords.length > 0
        for keyword in card.keywords
            attachment['text'] += keyword + ". "
        attachment['text'] += "\n\n"

    if card.text
        attachment['text'] += emojifyLAText(card.text)
    else
        attachment['text'] += ''

    attachment['author_name'] = expansionFull + " #" + number + " / " + card.rarity + " / " + card.artist

    return attachment

emojifyLAText = (text) ->
    text = text.replace /\[D\]/g, ":boom:"
    text = text.replace /\[AE\]/g, ":aember:"
    text = text.replace /Action:/g, "*Action:*"
    text = text.replace /Play:/g, "*Play:*"
    text = text.replace /Reap:/g, "*Reap:*"
    text = text.replace /Omni:/g, "*Omni:*"
    text = text.replace /Fight:/g, "*Fight:*"
    text = text.replace /Destroyed:/g, "*Destroyed:*"
    text = text.replace /Fight\/Reap:/g, "*Fight/Reap:*"
    text = text.replace /Play\/Reap:/g, "*Play/Reap:*"
    text = text.replace /Play\/Fight:/g, "*Play/Fight:*"
    text = text.replace /Play\/Fight\/Reap:/g, "*Play/Fight/Reap:*"
    text = text.replace /Before Fight:/g, "*Before Fight:*"
    text = text.replace /Before Reap:/g, "*Before Reap:*"

    return text

compareCards = (card1, card2) ->
    if card1.name < card2.name
        return -1
    else if card1.name > card2.name
        return 1
    else
        return 0

lookupCard = (query, cards) ->
    query = query.toLowerCase()

    if query of ABBREVIATIONS
        query = ABBREVIATIONS[query]

    keys = ['name']

    fuseOptions =
        caseSensitive: false
        include: ['score']
        shouldSort: true
        threshold: 0.6
        location: 0
        distance: 100
        maxPatternLength: 32
        keys: keys

    fuse = new Fuse cards, fuseOptions
    results = fuse.search(query)

    if results? and results.length > 0
        # get all the cards with the highest score
        filteredResults = results.filter((c) -> c.score == results[0].score)

        # sort all cards that tied for highest score by length (shorter is more accurate)
        sortedResults = filteredResults.sort((c1, c2) -> c1.item.name.length - c2.item.name.length)

        return sortedResults[0].item
    else
        return false


module.exports = (robot) ->
    # delay preload to give the app time to connect to redis
    setTimeout ( ->
        preloadData(robot)
    ), 1000

    robot.hear /\[\[([^\]\|]+)\]\]/, (res) ->
        # only respond in #keyforge room
        #if res.message.room != 'CC0S7SXGQ'
        if res.message.room != 'C0CSRP3RC'
            return

        query = res.match[1].replace /^\s+|\s+$/g, ""

        card = lookupCard(query, robot.brain.get('kfcards'))
        robot.logger.info "Searching LibraryAccess for card #{query} (from #{res.message.user.name})"

        if card
            expansionAbbr = ''
            expansionFull = ''
            if card['expansions'].length > 0
                expansionAbbr = card['expansion'][0]['abbreviation']
                expansionFull = card['expansion'][0]['name']
            number = ''
            if card['expansions'].length > 0
                number = card['expansion'][0]['number']
            image = ''
            if card['imageNames'].length > 0
                image = "http://libraryaccess.net/images/cards/" + card['imageNames'][0] + ".jpg"

            robot.http("http://api.libraryaccess.net:7001/cards/" + expansionAbbr + "/" + number)
                .get() (err, res, body) ->
                    if err
                        if image != ''
                            res.send image
                    else
                        cardData = JSON.parse body
                        formattedCard = formatCard(cardData, expansionAbbr, expansionFull, number, image)
                        # robot.logger.info formattedCard
                        res.send
                            as_user: true
                            attachments: [formattedCard]
                            username: res.robot.name
        else
            res.send "No KeyForge card result found for \"" + match + "\"."

    # robot.hear /{{l5r\|([^}]+)}}|{{([^}]+\|l5r)}}|!l5rima?ge? (.+)/, (res) ->
    #     match = ''
    #     if res.match[1]
    #         match = res.match[1]
    #     else if res.match[2]
    #         match = res.match[2]
    #     else if res.match[3]
    #         match = res.match[3]
    #     query = match.replace /^\s+|\s+$/g, ""

    #     locale = "en"
    #     hangul = new RegExp("[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]");
    #     if hangul.test(query)
    #         locale = "kr"

    #     card = lookupCard(query, robot.brain.get('l5rcards-' + locale), locale)
    #     robot.logger.info "Searching FRDB for card image #{query} (from #{res.message.user.name} in #{res.message.room})"
    #     robot.logger.info "Locale: " + locale

    #     if card and card.pack_cards.length > 0
    #         for pack_card in card.pack_cards
    #             if pack_card.image_url
    #                 res.send pack_card.image_url
    #                 break
    #     else
    #         res.send "No Keyforge card image result found for \"" + match + "\"."