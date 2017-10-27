# Description:
#   Tools for interacting with the NetrunnerDB API.
#
# Commands:
#   [[card name]] - search for a card with that name in the NetrunnerDB API
#   {{card name}} - fetch the card image for a card
#   !jank (corp|runner) - Choose an identity and three random cards. Break the meta!
#   !find (e|t|s|f|x|p|o|n|d|c|a|i|u|y|g|v)(:|=|>|<|!)<query> - find cards searching by attributes

Fuse = require 'fuse.js'
yaml = require 'js-yaml'

CLANS = {
    'crab': {
        'name': 'Crab',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/crab_mon/e94ea9c148f8ee8f.png',
        'color': '#001c94',
        'emoji': ':crab_mon:'
    },
    'crane': {
        'name': 'Crane',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/crane_mon/becb9d480917f9be.png',
        'color': '#0089de',
        'emoji': ':crane_mon:'
    },
    'dragon': {
        'name': 'Dragon',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/dragon_mon/52b31accf5175d45.png',
        'color': '#00a472',
        'emoji': ':dragon_mon:'
    },
    'lion': {
        'name': 'Lion',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/lion_mon/ebe2f77890d97e47.png',
        'color': '#cb9d00',
        'emoji': ':lion_mon:'
    },
    'phoenix': {
        'name': 'Phoenix',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/phoenix_mon/529e102a35b2e556.png',
        'color': '#c16400',
        'emoji': ':phoenix_mon:'
    },
    'scorpion': {
        'name': 'Scorpion',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/scorpion_mon/df26e3885c03e101.png',
        'color': '#a61600',
        'emoji': ':scorpion_mon:'
    },
    'unicorn': {
        'name': 'Unicorn',
        'icon': 'https://emoji.slack-edge.com/T0AV68M8C/unicorn_mon/05c980c4c9972752.png',
        'color': '#780098',
        'emoji': ':unicorn_mon:'
    }
    'neutral': {
        'name': 'Neutral',
        'icon': '',
        'color': '#a8a9ab',
        'emoji': 'neutral'
    },
}

SPECIAL_LOCALIZATION = {
    'en': {
        'fate': 'Fate',
        'infinite': 'Infinite',
        'decksize': 'min deck size',
        'strength': 'strength',
        'strength-bonus': 'strength bonus',
        'conflict-deck': 'Conflict Deck',
        'dynasty-deck': 'Dynasty Deck',
        'glory': 'Glory',
        'cycle': 'Cycle',
        'influence': 'Influence',
        'fate-income': 'Fate Income',
        'starting-honor': 'Starting Honor'
    }
}

ABBREVIATIONS = {
    'en': {
        'fgg': 'For Greater Glory',
        'cg': 'Court Games',
        'fs': 'For Shame!',
        'rfb': 'Ready for Battle',
        'ctm': 'Cloud the Mind',
        'gota': 'Guidance of the Ancestors',
        ':bonzi_buddy:': 'Banzai!',
        'utz': 'Banzai!',
        ':utz:': 'Banzai!',
        'fs': 'For Shame!',
        'mf': 'Mirumoto\'s Fury',
        'cr': 'Cavalry Reserves',
        'sok': 'Seeker of Knowledge',
        'dop': 'Display of Power',
        'lg': 'Let Go',
        'sin': 'Strength in Numbers',
        'lpb': 'Lion\'s Pride Brawler'
    }
}

RINGS = {
    'fire': ':fire_ring:',
    'air': ':air_ring:',
    'water': ':water_ring:',
    'earth': ':earth_ring:',
    'void': ':void_ring:'
}

DISPLAY_CYCLES = []

preloadData = (robot) ->
    locales = [ "en" ]
    for locale in locales
        do (locale) ->
            robot.http("https://api.fiveringsdb.com/cards?_locale=" + locale)
                .get() (err, res, body) ->
                    cardData = JSON.parse body
                    robot.logger.info "Loaded " + cardData.records.length + " FRDB cards"
                    robot.brain.set 'l5rcards-' + locale, cardData.records.sort(compareCards)

            robot.http("https://api.fiveringsdb.com/packs?_locale=" + locale)
                .get() (err, res, body) ->
                    packData = JSON.parse body
                    mappedPackData = {}
                    for pack in packData.records
                        mappedPackData[pack.id] = pack
                    robot.logger.info "Loaded " + packData.records.length + " FRDB packs"
                    robot.brain.set 'l5rpacks-' + locale, mappedPackData

            robot.http("https://api.fiveringsdb.com/cycles?_locale=" + locale)
                .get() (err, res, body) ->
                    cycleData = JSON.parse body
                    mappedCycleData = {}
                    for cycle in cycleData.records
                        mappedCycleData[cycle.id] = cycle
                    robot.logger.info "Loaded " + cycleData.records.length + " FRDB cycles"
                    robot.brain.set 'l5rcycles-' + locale, mappedCycleData

            # lol i can't believe i have to do this
            robot.http("https://raw.githubusercontent.com/Alsciende/fiveringsdb-ui/master/src/i18n/translation." + locale + ".yml")
                .get() (err, res, body) ->
                    yamlLocalizations = yaml.safeLoad body
                    robot.brain.set 'l5rlocale-' + locale, yamlLocalizations
                    robot.logger.info "Loaded FRDB localizations"


formatCard = (card, packs, cycles, localizations, locale) ->
    title = card.name
    if locale != 'en' and card._locale
        title = card._locale[locale].title
    if card.unicity
        title = "⬤ " + title

    attachment = {
        'fallback': title,
        'title': title,
        'title_link': 'https://fiveringsdb.com/card/' + card.id,
        'mrkdwn_in': [ 'text', 'author_name' ]
    }

    attachment['text'] = ''

    cardType = ''
    if card.type == 'character'
        cardtype = localizations.side[card.side] + ' ' + cardtype = localizations.type.character
    else
        cardtype = localizations.type[card.type]
    typeline = "*#{cardtype}*"
    if card.traits? and card.traits.length > 0
        typeline += ":"
        for trait in card.traits
            typeline += " #{localizations.keyword[trait]}."

    cardCost = card.cost
    if card.cost == null
        cardCost = 'X'

    switch card.type
        when 'holding'
            typeline += " _(#{card.strength_bonus} #{SPECIAL_LOCALIZATION[locale]['strength-bonus']})_"
        when 'character'
            typeline += " _(#{cardCost} #{SPECIAL_LOCALIZATION[locale]['fate']})_\n"
            if card.military?
                milSkill = card.military
            else
                milSkill = '—'
            if card.political?
                polSkill = card.political
            else
                polSkill = '—'
            typeline += "#{milSkill} :military:, #{polSkill} :political:, #{card.glory} #{SPECIAL_LOCALIZATION[locale]['glory']}"
        when 'event'
            typeline += " _(#{cardCost} #{SPECIAL_LOCALIZATION[locale]['fate']})_"
        when 'province'
            typeline += " _(#{RINGS[card.element]}, #{card.strength} #{SPECIAL_LOCALIZATION[locale]['strength']})_"
        when 'stronghold'
            typeline += " _(#{card.fate} #{SPECIAL_LOCALIZATION[locale]['fate-income']}, #{card.honor} #{SPECIAL_LOCALIZATION[locale]['starting-honor']}, #{card.strength_bonus} #{SPECIAL_LOCALIZATION[locale]['strength-bonus']}, #{card.influence_pool} #{SPECIAL_LOCALIZATION[locale]['influence']})_"
        when 'attachment'
            typeline += " _(#{cardCost} #{SPECIAL_LOCALIZATION[locale]['fate']})_\n#{card.military_bonus} :military:, #{card.political_bonus} :political:"

    attachment['text'] += typeline + "\n\n"
    if locale != 'en' && card._locale && card._locale[locale].text
        attachment['text'] += emojifyFRDBText(card._locale[locale].text)
    else if card.text
        attachment['text'] += emojifyFRDBText(card.text)
    else
        attachment['text'] += ''

    clan = CLANS[card.clan]

    if clan?
        pack_id = card.pack_cards[0].pack.id
        cycle_id = packs[pack_id].cycle.id
        authorname = "#{packs[pack_id].name}"
        if locale != 'en' and packs[pack_id]._locale
            authorname = "#{packs[pack_id]._locale[locale].name}"
        if cycles[cycle_id].position in DISPLAY_CYCLES
            if locale != 'en' and cycles[cycle_id]._locale
                authorname = authorname + " / #{cycles[cycle_id]._locale[locale].name} #{SPECIAL_LOCALIZATION[locale]['cycle']}"
            else
                authorname = authorname + " / #{cycles[cycle_id].name} #{SPECIAL_LOCALIZATION[locale]['cycle']}"


        authorname = authorname + " ##{card.pack_cards[0].position} / #{clan.name}"
        influencepips = ""
        if card.influence_cost?
            i = card.influence_cost
            while i--
                influencepips += '●'
        if influencepips != ""
            authorname = authorname + " #{influencepips}"

        attachment['author_name'] = authorname
        attachment['color'] = clan.color
        if clan.icon
            attachment['author_icon'] = clan.icon

    return attachment

emojifyFRDBText = (text) ->
    text = text.replace /\[conflict-military\]/ig, ":military:"
    text = text.replace /\[conflict-political\]/ig, ":political:"
    text = text.replace /<sup>/ig, " "
    text = text.replace /<\/sup>/ig, ""
    text = text.replace /&ndash/ig, "–"
    text = text.replace /<strong>/ig, "*"
    text = text.replace /<\/strong>/ig, "*"
    text = text.replace /<b>/ig, "*"
    text = text.replace /<\/b>/ig, "*"
    text = text.replace /<em>/ig, "_"
    text = text.replace /<\/em>/ig, "_"
    text = text.replace /<i>/ig, "_"
    text = text.replace /<\/i>/ig, "_"
    text = text.replace /\[clan-crab\]/ig, CLANS['crab']['emoji']
    text = text.replace /\[clan-crane\]/ig, CLANS['crane']['emoji']
    text = text.replace /\[clan-dragon\]/ig, CLANS['dragon']['emoji']
    text = text.replace /\[clan-lion\]/ig, CLANS['lion']['emoji']
    text = text.replace /\[clan-phoenix\]/ig, CLANS['phoenix']['emoji']
    text = text.replace /\[clan-scorpion\]/ig, CLANS['scorpion']['emoji']
    text = text.replace /\[clan-unicorn\]/ig, CLANS['unicorn']['emoji']
    text = text.replace /\[element-air\]/ig, RINGS['air']
    text = text.replace /\[element-earth\]/ig, RINGS['earth']
    text = text.replace /\[element-water\]/ig, RINGS['water']
    text = text.replace /\[element-fire\]/ig, RINGS['fire']
    text = text.replace /\[element-void\]/ig, RINGS['void']
    text = text.replace /\<ul>/ig, "\n"
    text = text.replace /\<\/ul>/ig, ""
    text = text.replace /\<li>/ig, "• "
    text = text.replace /\<\/li>/ig, "\n"
    text = text.replace /\<errata>/ig, "_"
    text = text.replace /\<\/errata>/ig, "_"

    return text

compareCards = (card1, card2) ->
    if card1.name < card2.name
        return -1
    else if card1.name > card2.name
        return 1
    else
        return 0

# cardMatches = (card, cond, packs, cycles) ->
#     return false if cond.key == 'p' && typeof(card.strength) == 'undefined'
#     return false if cond.key == 'o' && typeof(card.cost) == 'undefined'
#     return false if cond.key == 'n' && typeof(card.faction_cost) == 'undefined'
#     return false if cond.key == 'y' && typeof(card.quantity) == 'undefined'
#     return false if cond.key == 'g' && typeof(card.advancement_cost) == 'undefined'
#     return false if cond.key == 'v' && typeof(card.agenda_points) == 'undefined'

#     switch cond.op
#         when ":", "="
#             switch cond.key
#                 when "e" then return card.pack_code == cond.value
#                 when "t" then return card.type_code == cond.value
#                 when "s" then return card.keywords && cond.value in card.keywords.toLowerCase().split(" - ")
#                 when "f" then return card.faction_code.substr(0, cond.value.length) == cond.value
#                 when "x" then return card.text && ~(card.text.toLowerCase().indexOf(cond.value))
#                 when "d" then return cond.value == card.side_code.substr(0, cond.value.length)
#                 when "a" then return card.flavor && ~(card.flavor.toLowerCase().indexOf(cond.value))
#                 when "i" then return card.illustrator && ~(card.illustrator.toLowerCase().indexOf(cond.value))
#                 when "u" then return !card.uniqueness == !parseInt(cond.value)
#                 when "p" then return card.strength == parseInt(cond.value)
#                 when "o" then return card.cost == parseInt(cond.value)
#                 when "n" then return card.faction_cost == parseInt(cond.value)
#                 when "y" then return card.quantity == parseInt(cond.value)
#                 when "g" then return card.advancement_cost == parseInt(cond.value)
#                 when "v" then return card.agenda_points == parseInt(cond.value)
#                 when "c" then return cycles[packs[card.pack_code].cycle_code].position == parseInt(cond.value)
#         when "<"
#             switch cond.key
#                 when "p" then return card.strength < parseInt(cond.value)
#                 when "o" then return card.cost < parseInt(cond.value)
#                 when "n" then return card.faction_cost < parseInt(cond.value)
#                 when "y" then return card.quantity < parseInt(cond.value)
#                 when "g" then return card.advancement_cost < parseInt(cond.value)
#                 when "v" then return card.agenda_points < parseInt(cond.value)
#                 when "c" then return cycles[packs[card.pack_code].cycle_code].position < parseInt(cond.value)
#         when ">" then return !cardMatches(card, { key: cond.key, op: "<", value: parseInt(cond.value) + 1 }, packs, cycles)
#         when "!" then	return !cardMatches(card, { key: cond.key, op: ":", value: cond.value }, packs, cycles)
#     true

lookupCard = (query, cards, locale) ->
    query = query.toLowerCase()

    if query of ABBREVIATIONS[locale]
        query = ABBREVIATIONS[locale][query]

    if locale in ["kr"]
        # fuzzy search won't work, do naive string-matching
        results_exact = cards.filter((card) -> card._locale && card._locale[locale].name == query)
        results_includes = cards.filter((card) -> card._locale && card._locale[locale].name.includes(query))

        if results_exact.length > 0
            return results_exact[0]

        if results_includes.length > 0
            sortedResults = results_includes.sort((c1, c2) -> c1._locale[locale].name.length - c2._locale[locale].name.length)
            return sortedResults[0]
        return false
    else
        keys = ['name']
        if locale != 'en'
            keys.push('_locale["' + locale + '"].name')

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
            filteredResults = results.filter((c) -> c.score == results[0].score)
            sortedResults = []
            if locale is 'en'
                sortedResults = filteredResults.sort((c1, c2) -> c1.item.name.length - c2.item.name.length)
            else
                # favor localized results over non-localized results when showing matches
                sortedResults = filteredResults.sort((c1, c2) ->
                    if c1.item._locale and c2.item._locale
                        return c1.item._locale[locale].name.length - c2.item._locale[locale].name.length
                    if c1.item._locale and not c2.item._locale
                        return -1
                    if c2.item._locale and not c1.item._locale
                        return 1
                    return c1.item.name.length - c2.item.name.length
                )
            return sortedResults[0].item
        else
            return false

# createNRDBSearchLink = (conditions) ->
#     start = "https://netrunnerdb.com/find/?q="
#     cond_array = []
#     for cond in conditions
#         cond.op = ":" if cond.op == "="
#         cond_array.push (cond.key + cond.op + cond.value)
#     return start + cond_array.join "+"


module.exports = (robot) ->
    # delay preload to give the app time to connect to redis
    setTimeout ( ->
        preloadData(robot)
    ), 1000

    robot.hear /\[\[l5r\|([^\]]+)\]\]|\[\[([^\]]+)\|l5r\]\]|^!l5rcard (.+)$|^!l5r (.+)$/, (res) ->
        match = ''
        if res.match[1]
            match = res.match[1]
        else if res.match[2]
            match = res.match[2]
        else if res.match[3]
            match = res.match[3]
        else if res.match[4]
            match = res.match[4]
        query = match.replace /^\s+|\s+$/g, ""

        locale = "en"
        hangul = new RegExp("[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]");
        if hangul.test(query)
            locale = "kr"

        card = lookupCard(query, robot.brain.get('l5rcards-' + locale), locale)
        robot.logger.info "Searching FRDB for card #{query} (from #{res.message.user.name} in #{res.message.room})"
        robot.logger.info "Locale: " + locale

        if card
            formattedCard = formatCard(card, robot.brain.get('l5rpacks-' + locale), robot.brain.get('l5rcycles-' + locale), robot.brain.get('l5rlocale-' + locale), locale)
            # robot.logger.info formattedCard
            res.send
                as_user: true
                attachments: [formattedCard]
                username: res.robot.name
        else
            res.send "No L5R card result found for \"" + match + "\"."

    robot.hear /{{l5r\|([^}]+)}}|{{([^}]+\|l5r)}}/, (res) ->
        match = ''
        if res.match[1]
            match = res.match[1]
        else if res.match[2]
            match = res.match[2]
        query = match.replace /^\s+|\s+$/g, ""

        locale = "en"
        hangul = new RegExp("[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]");
        if hangul.test(query)
            locale = "kr"

        card = lookupCard(query, robot.brain.get('l5rcards-' + locale), locale)
        robot.logger.info "Searching FRDB for card image #{query} (from #{res.message.user.name} in #{res.message.room})"
        robot.logger.info "Locale: " + locale

        if card
            res.send card.pack_cards[0].image_url
        else
            res.send "No L5R card result found for \"" + match + "\"."

    # robot.hear /^!jank\s?(runner|corp)?$/i, (res) ->
    #     side = res.match[1]
    #     cards = robot.brain.get('l5rcards')
    #     packs = robot.brain.get('l5rpacks')
    #     cycles = robot.brain.get('l5rcycles')

    #     if !side?
    #         randomside = Math.floor(Math.random() * 2)
    #         if randomside is 0
    #             side = "runner"
    #         else
    #             side = "corp"
    #     else
    #         side = side.toLowerCase()

    #     sidecards = cards.filter((card) ->
    #         return card.side_code == side
    #     )
    #     identities = sidecards.filter((card) ->
    #         return card.type_code == "identity" && cycles[packs[card.pack_code].cycle_code].position != 0
    #     )
    #     sideNonIDCards = sidecards.filter((card) ->
    #         return card.type_code != "identity" && cycles[packs[card.pack_code].cycle_code].position != 0
    #     )

    #     randomIdentity = Math.floor(Math.random() * identities.length)
    #     identityCard = identities[randomIdentity]

    #     numberOfCards = 3
    #     cardString = identityCard.title

    #     for num in [1..numberOfCards]
    #         do (num) ->
    #             randomCard = {}
    #             while true
    #                 randomCard = sideNonIDCards[Math.floor(Math.random() * sideNonIDCards.length)]
    #                 break if (randomCard.type_code != "agenda" || (randomCard.type_code == "agenda" && (randomCard.faction_code == identityCard.faction_code || randomCard.faction_code == "neutral"))) && (identityCard.code != "03002" || (identityCard.code == "03002" && randomCard.faction_code != "jinteki"))
    #             cardString += " + " + randomCard.title

    #     res.send cardString

    # robot.hear /^!find (.*)/, (res) ->
    #     conditions = []
    #     for part in res.match[1].toLowerCase().match(/(([etsfxpondaiuygvc])([:=<>!])([-\w]+|\".+?\"))+/g)
    #         if out = part.match(/([etsfxpondaiuygvc])([:=<>!])(.+)/)
    #             if out[2] in ":=!".split("") || out[1] in "ponygvc".split("")
    #                 conditions.push({ key: out[1], op: out[2], value: out[3].replace(/\"/g, "") })

    #     return res.send("Sorry, I didn't understand :(") if !conditions || conditions.length < 1

    #     results = []
    #     packs = robot.brain.get('l5rpacks')
    #     cycles = robot.brain.get('l5rcycles')
    #     for card in robot.brain.get('l5rcards')
    #         valid = true
    #         for cond in conditions
    #             valid = valid && cardMatches(card, cond, packs, cycles)
    #         results.push(card.title) if valid

    #     total = results.length
    #     if total > 10
    #         res.send("Found #{results[0..9].join(", ")} and <" + createNRDBSearchLink(conditions) + "|#{total - 10} more>")
    #     else if total < 1
    #         res.send("Couldn't find anything :|")
    #     else
    #         res.send("Found #{results.join(", ")}")
