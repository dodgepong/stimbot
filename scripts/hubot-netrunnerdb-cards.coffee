# Description:
#   Tools for interacting with the NetrunnerDB API.
#
# Commands:
#   [card name] - search for a card with that name in the NetrunnerDB API (braces necessary)
#   !jank (corp|runner) - Choose an identity and three random cards. Break the meta!

Fuse = require 'fuse.js'

FACTIONS = {
	'adam': { "name": 'Adam', "color": '#b9b23a', "icon": "Adam" },
	'anarch': { "name": 'Anarch', "color": '#ff4500', "icon": "Anarch" },
	'apex': { "name": 'Apex', "color": '#9e564e', "icon": "Apex" },
	'criminal': { "name": 'Criminal', "color": '#4169e1', "icon": "Criminal" },
	'shaper': { "name": 'Shaper', "color": '#32cd32', "icon": "Shaper" },
	'sunny-lebeau': { "name": 'Sunny Lebeau', "color": '#715778', "icon": "Sunny LeBeau" },
	'neutral': { "name": 'Neutral (runner)', "color": '#808080', "icon": "Neutral" },
	'haas-bioroid': { "name": 'Haas-Bioroid', "color": '#8a2be2', "icon": "Haas-Bioroid" },
	'jinteki': { "name": 'Jinteki', "color": '#dc143c', "icon": "Jinteki" },
	'nbn': { "name": 'NBN', "color": '#ff8c00', "icon": "NBN" },
	'weyland-consortium': { "name": 'Weyland Consortium', "color": '#326b5b', "icon": "Weyland" },
	'neutral': { "name": 'Neutral (corp)', "color": '#808080', "icon": "Neutral" }
}

ABBREVIATIONS = {
	'proco': 'Professional Contacts',
	'procon': 'Professional Contacts',
	'jhow': 'Jackson Howard',
	'smc': 'Self-Modifying Code',
	'kit': 'Rielle "Kit" Peddler',
	'abt': 'Accelerated Beta Test',
	'mopus': 'Magnum Opus',
	'mo': 'Magnum Opus',
	'charizard': 'Scheherazade',
	'siphon': 'Account Siphon',
	'deja': 'Déjà Vu',
	'deja vu': 'Déjà Vu',
	'gov takeover': 'Government Takeover',
	'gt': 'Government Takeover',
	'baby': 'Symmetrical Visage',
	'pancakes': 'Adjusted Chronotype',
	'dlr': 'Data Leak Reversal',
	'bn': 'Breaking News',
	'rp': 'Replicating Perfection',
	'neh': 'Near-Earth Hub',
	'pe': 'Perfecting Evolution',
	'white tree': 'Replicating Perfection',
	'black tree': 'Perfecting Evolution',
	'ci': 'Cerebral Imaging',
	'ppvp': 'Prepaid VoicePAD',
	'pvpp': 'Prepaid VoicePAD',
	'sfss': 'Shipment from SanSan',
	'rdi': 'R&D Interface',
	'hqi': 'HQ Interface',
	'gfi': 'Global Food Initiative',
	'dbs': 'Daily Business Show',
	'nre': 'Net-Ready Eyes',
	'elp': 'Enhanced Login Protocol',
	'levy': 'Levy AR Lab Access',
	'oai': 'Oversight AI',
	'fao': 'Forged Activation Orders',
	'psf': 'Private Security Force',
	'david': 'd4v1d',
	'ihw': 'I\'ve Had Worse',
	'qt': 'Quality Time',
	'nisei': 'Nisei Mk II',
	'dhpp': 'Director Haas\' Pet Project',
	'tfin': 'The Future Is Now',
	'ash': 'Ash 2X3ZB9CY',
	'cvs': 'Cyberdex Virus Suite',
	'otg': 'Off the Grid',
	'ts': 'Team Sponsorship',
	'glc': 'Green Level Clearance',
	'blc': 'Blue Level Clearance',
	'pp': 'Product Placement',
	'asi': 'All-Seeing I',
	'nas': 'New Angeles Sol',
	'bbg': 'Breaker Bay Grid',
	'drt': 'Dedicated Response Team',
	'sot': 'Same Old Thing',
	'stamherk': 'Stimhack',
	'stam herk': 'Stimhack',
	'tempo': 'Professional Contacts',
	'ff': 'Feedback Filter',
	'fis': 'Fisk Investment Seminar',
	'fisk': 'Laramy Fisk',
	'lf': 'Lucky Find',
	'prof': 'The Professor',
	'tol': 'Trick of Light',
	'manup': 'Mandatory Upgrades',
	'ij': 'Inside Job',
	'andy': 'Andromeda',
	'qpm': 'Quantum Predictive Model',
	'smashy dino': 'Shattered Remains',
	'smashy dinosaur': 'Shattered Remains',
	'mhc': 'Mental Health Clinic',
	'etf': 'Engineering the Future',
	'st': 'Stronger Together',
	'babw': 'Building a Better World',
	'bwbi': 'Because We Built It',
	'mn': 'Making News',
	'ct': 'Chaos Theory',
	'oycr': 'An Offer You Can\'t Refuse',
	'hok': 'House of Knives',
	'cc': 'Clone Chip',
	'ta': 'Traffic Accident',
	'jesus': 'Jackson Howard',
	'baby bucks': 'Symmetrical Visage',
	'babybucks': 'Symmetrical Visage',
	'mediohxcore': 'MemStrips',
	'calimsha': 'Kate "Mac" McCaffrey',
	'spags': 'Troll',
	'bs': 'Blue Sun',
	'larla': 'Levy AR Lab Access',
	'ig': 'Industrial Genomics',
	'clone': 'Clone Chip',
	'josh01': 'Professional Contacts',
	'hiro': 'Chairman Hiro',
	'director': 'Director Haas',
	'haas': 'Director Haas',
	'zeromus': 'Mushin no Shin',
	'tldr': 'TL;DR',
	'sportsball': 'Team Sponsorship',
	'sports ball': 'Team Sponsorship',
	'sports': 'Team Sponsorship',
	'crfluency': 'Blue Sun',
	'dodgepong': 'Broadcast Square',
	'cheese potato': 'Data Leak Reversal',
	'cheese potatos': 'Data Leak Reversal',
	'cheese potatoes': 'Data Leak Reversal',
	'cycy': 'Cyber-Cipher',
	'cy cy': 'Cyber-Cipher',
	'cy-cy': 'Cyber-Cipher',
	'expose': 'Exposé',
	'sneakysly': 'Stimhack'
}

formatCard = (card) ->
	title = card.title
	if card.uniqueness
		title = "◆ " + title

	attachment = {
		'fallback': title,
		'title': title,
		'title_link': card.url,
		'mrkdwn_in': [ 'text', 'author_name' ]
	}

	attachment['text'] = ''

	typeline = ''
	if card.subtype? and card.subtype != ''
		typeline += "*#{card.type}*: #{card.subtype}"
	else
		typeline += "*#{card.type}*"

	switch card.type_code
		when 'agenda'
			typeline += " _(#{card.advancementcost}:rez:, #{card.agendapoints}:agenda:)_"
		when 'asset', 'upgrade'
			typeline += " _(#{card.cost}:credit:, #{card.trash}:trash:)_"
		when 'event', 'operation', 'hardware', 'resource'
			typeline += " _(#{card.cost}:credit:)_"
		when 'ice'
			typeline += " _(#{card.cost}:credit:, #{card.strength} strength)_"
		when 'identity'
			if card.side_code == 'runner'
				typeline += " _(#{card.baselink}:baselink:, #{card.minimumdecksize} min deck size, #{card.influencelimit} influence)_"
			else if card.side_code == 'corp'
				typeline += " _(#{card.minimumdecksize} min deck size, #{card.influencelimit} influence)_"
		when 'program'
			if card.strength?
				typeline += " _(#{card.cost}:credit:, #{card.memoryunits}:mu:, #{card.strength} strength)_"
			else
				typeline += " _(#{card.cost}:credit:, #{card.memoryunits}:mu:)_"

	attachment['text'] += typeline + "\n\n"
	if card.text?
		attachment['text'] += emojifyNRDBText card.text
	else
		attachment['text'] += ''

	faction = FACTIONS[card.faction_code]

	if faction?
		if card.factioncost?
			influencepips = ""
			i = card.factioncost
			while i--
				influencepips += '●'
			attachment['author_name'] = "#{card.setname} / #{faction.icon} #{influencepips}"
		else
			attachment['author_name'] = "#{card.setname} / #{faction.icon}"

		attachment['color'] = faction.color

	return attachment

emojifyNRDBText = (text) ->
	text = text.replace /\[Credits\]/g, ":credit:"
	text = text.replace /\[Click\]/g, ":click:"
	text = text.replace /\[Trash\]/g, ":trash:"
	text = text.replace /\[Recurring Credits\]/g, ":recurring:"
	text = text.replace /\[Subroutine\]/g, ":subroutine:"
	text = text.replace /\[Memory Unit\]/g, " :mu:"
	text = text.replace /\[Link\]/g, ":baselink:"
	text = text.replace /<sup>/g, " "
	text = text.replace /<\/sup>/g, ""
	text = text.replace /&ndash/g, "–"
	text = text.replace /<strong>/g, "*"
	text = text.replace /<\/strong>/g, "*"

	return text

compareCards = (card1, card2) ->
	if card1.title < card2.title
		return -1
	else if card1.title > card2.title
		return 1
	else
		return 0

module.exports = (robot) ->
	robot.http("http://netrunnerdb.com/api/cards/")
		.get() (err, res, body) ->
			unsortedCards = JSON.parse body
			robot.brain.set 'cards', unsortedCards.sort(compareCards)

	robot.hear /\[([^\]]+)\]/, (res) ->
		query = res.match[1]
		cards = robot.brain.get('cards')

		query = query.toLowerCase()

		if query of ABBREVIATIONS
			query = ABBREVIATIONS[query]

		fuseOptions =
			caseSensitive: false
			includeScore: false
			shouldSort: true
			threshold: 0.6
			location: 0
			distance: 100
			maxPatternLength: 32
			keys: ['title']

		fuse = new Fuse cards, fuseOptions
		results = fuse.search(query)

		if results? and results.length > 0
			formattedCard = formatCard results[0]
			robot.emit 'slack.attachment',
				message: "Found card:"
				content: formattedCard
				channel: res.message.room
		else
			res.send "No card result found for \"" + res.match[1] + "\"."

	robot.hear /^!jank\s?(runner|corp)?$/i, (res) ->
		side = res.match[1]
		cards = robot.brain.get('cards')

		if !side?
			randomside = Math.floor(Math.random() * 2)
			if randomside is 0
				side = "runner"
			else
				side = "corp"
		else
			side = side.toLowerCase()

		sidecards = cards.filter((card) -> 
			return card.side_code == side
		)
		identities = sidecards.filter((card) ->
			return card.type_code == "identity" && card.cyclenumber != 0
		)
		sideNonIDCards = sidecards.filter((card) ->
			return card.type_code != "identity" && card.cyclenumber != 0
		)

		randomIdentity = Math.floor(Math.random() * identities.length)
		identityCard = identities[randomIdentity]

		numberOfCards = 3
		cardString = identityCard.title

		for num in [1..numberOfCards]
			do (num) ->
				randomCard = {}
				while true
					randomCard = sideNonIDCards[Math.floor(Math.random() * sideNonIDCards.length)]
					break if randomCard.type_code != "agenda" || (randomCard.type_code == "agenda" && (randomCard.faction_code == identityCard.faction_code || randomCard.faction_code == "neutral"))
				cardString += " + " + randomCard.title

		res.send cardString
