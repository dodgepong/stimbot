# Description:
#   Tools for interacting with the KeyForge LibraryAccess.net API. Only works in #keyforge room on Stimslack.
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

    typeline = "*#{card.type}*"
    if card.traits? and card.traits.length > 0
        typeline += ": " + card.traits.join(" • ")

    typeline += " "
    for house in card.houses
        typeline += ":kf-" + house + ":"

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
        for num in [1..aember]
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

    attachment['author_name'] = expansionFull + " #" + number + " / " + card.houses.join(", ") + " / " + card.rarity

    return attachment

formatDeck = (deckData, cards, deckLink) ->
    title = deckData.name

    emojifiedHouses = deckData._links.houses.map ((house) -> ":kf-" + house + ": " + house)
    pretext = "*" + title + "* - " + emojifiedHouses.join(" • ")

    attachment = {
        'fallback': title,
        'title': "Click here for full deck info",
        'title_link': deckLink,
        'pretext': pretext,
        'mrkdwn_in': [ 'text', 'author_name', 'pretext' ]
    }

    deckStats = {
        typeCounts: {
            artifact: 0,
            creature: 0,
            upgrade: 0,
            action: 0
        },
        rarityCounts: {
            common: 0
            uncommon: 0
            rare: 0
            special: 0
        }
    }

    for card in cards
        switch card.card_type
            when "Creature" then deckStats.typeCounts.creature += 1
            when "Action" then deckStats.typeCounts.action += 1
            when "Upgrade" then deckStats.typeCounts.upgrade += 1
            when "Artifact" then deckStats.typeCounts.artifact += 1

        switch card.rarity
            when "Common" then deckStats.rarityCounts.common += 1
            when "Uncommon" then deckStats.rarityCounts.uncommon += 1
            when "Rare" then deckStats.rarityCounts.rare += 1
            else deckStats.rarityCounts.special += 1

    attachment['text'] = ""
    attachment['text'] += "*Actions:* " + deckStats.typeCounts.action + "\n"
    attachment['text'] += "*Artifacts:* " + deckStats.typeCounts.artifact + "\n"
    attachment['text'] += "*Creatures:* " + deckStats.typeCounts.creature + "\n"
    attachment['text'] += "*Upgrades:* " + deckStats.typeCounts.upgrade + "\n\n"

    attachment['text'] += deckStats.rarityCounts.common + " Commons, " + deckStats.rarityCounts.uncommon + " Uncommons, " + deckStats.rarityCounts.rare + " Rares, " + deckStats.rarityCounts.special + " Special"

    return attachment

emojifyLAText = (text) ->
    text = text.replace /\[D\]/g, ":boom:"
    text = text.replace /\[AE\]/g, ":aember:"
    text = text.replace /Action:/g, "*Action:*"
    text = text.replace /Play:/g, "*Play:*"
    text = text.replace /Fight:/g, "*Fight:*"
    text = text.replace /Reap:/g, "*Reap:*"
    text = text.replace /Fight\/\*Reap:\*/g, "*Fight/Reap:*"
    text = text.replace /Play\/\*Reap:\*/g, "*Play/Reap:*"
    text = text.replace /Play\/\*Fight:\*/g, "*Play/Fight:*"
    text = text.replace /Play\/\*Fight\/Reap:\*/g, "*Play/Fight/Reap:*"
    text = text.replace /Leaves \*Play:\*/g, "*Leaves Play:*"
    text = text.replace /Omni:/g, "*Omni:*"
    text = text.replace /Destroyed:/g, "*Destroyed:*"
    text = text.replace /Before \*Fight:\*/g, "*Before Fight:*"
    text = text.replace /Before \*Reap:\*/g, "*Before Reap:*"

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
        if res.message.room != 'CC0S7SXGQ'
            return

        query = res.match[1].replace /^\s+|\s+$/g, ""

        card = lookupCard(query, robot.brain.get('kfcards'))
        robot.logger.info "Searching LibraryAccess for card #{query} (from #{res.message.user.name})"

        if card
            expansionAbbr = ''
            expansionFull = ''
            if card['expansions'].length > 0
                expansionAbbr = card['expansions'][0]['abbreviation']
                expansionFull = card['expansions'][0]['name']
            number = ''
            if card['expansions'].length > 0
                number = card['expansions'][0]['number']
            image = ''
            if card['imageNames'].length > 0
                image = "http://libraryaccess.net/images/cards/" + card['imageNames'][0] + ".jpg"

            robot.http("http://api.libraryaccess.net:7001/cards/" + expansionAbbr + "/" + number)
                .get() (err, response, body) ->
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

    robot.hear /{{([^}\|]+)}}/, (res) ->
        # only respond in #keyforge room
        if res.message.room != 'CC0S7SXGQ'
            return

        query = res.match[1].replace /^\s+|\s+$/g, ""

        card = lookupCard(query, robot.brain.get('kfcards'))
        robot.logger.info "Searching LibraryAccess for card image #{query} (from #{res.message.user.name})"

        if card
            if card['imageNames'].length > 0
                res.send "http://libraryaccess.net/images/cards/" + card['imageNames'][0] + ".jpg"
            else
                res.send "No Keyforge card image result found for \"" + match + "\"."
        else
            res.send "No Keyforge card image result found for \"" + match + "\"."

    robot.hear /https?:\/\/(www\.)?keyforgegame\.com\/deck-details\/([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})/, (res) ->
        # only respond in #keyforge room
        if res.message.room != 'CC0S7SXGQ'
            return

        deckLink = res.match[0]
        deckId = res.match[2]

        robot.http("https://www.keyforgegame.com/api/decks/" + deckId + "/?links=cards")
            .get() (err, response, body) ->
                if err
                    res.send "There was an error loading data for that deck."
                else
                    responseData = JSON.parse body
                    formattedDeck = formatDeck(responseData.data, responseData._linked.cards, deckLink)

                    res.send
                        as_user: true
                        attachments: [formattedDeck]
                        username: res.robot.name

