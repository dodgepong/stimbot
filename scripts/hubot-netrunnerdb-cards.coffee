# Description:
#   Tools for interacting with the NetrunnerDB API.
#
# Commands:
#   [[card name]] - search for a card with that name in the NetrunnerDB API
#   {{card name}} - fetch the card image for a card
#   !jank (corp|runner) - Choose an identity and three random cards. Break the meta!
#   !find (e|t|s|f|x|p|o|n|d|c|a|i|u|y|g|v)(:|=|>|<|!)<query> - find cards searching by attributes

Fuse = require 'fuse.js'

FACTION_ICONS = {
	'adam': 'https://emoji.slack-edge.com/T0AV68M8C/adam/c9fc2127ea57ab41.png',
	'anarch': 'https://emoji.slack-edge.com/T0AV68M8C/anarch/76e0d2bd50175857.png',
	'apex': 'https://emoji.slack-edge.com/T0AV68M8C/apex/17fdf10b8326daf3.png',
	'criminal': 'https://emoji.slack-edge.com/T0AV68M8C/criminal/9ebb239ab7c5de1c.png',
	'haas-bioroid': 'https://emoji.slack-edge.com/T0AV68M8C/hb/929240a94b055ac4.png',
	'jinteki': 'https://emoji.slack-edge.com/T0AV68M8C/jinteki/5ee8a93180cae42a.png',
	'nbn': 'https://emoji.slack-edge.com/T0AV68M8C/nbn/941383205f0a93b1.png',
	'shaper': 'https://emoji.slack-edge.com/T0AV68M8C/shaper/41994ae80b49af30.png',
	'sunny-lebeau': 'https://emoji.slack-edge.com/T0AV68M8C/sunnylebeau/831b222f07a01e6a.png',
	'weyland-consortium': 'https://emoji.slack-edge.com/T0AV68M8C/weyland/4b6d1be376b3cd52.png'
}

# FACTIONS = {
# 	'adam': { "name": 'Adam', "color": '#b9b23a', "icon": "Adam" },
# 	'anarch': { "name": 'Anarch', "color": '#ff4500', "icon": "Anarch" },
# 	'apex': { "name": 'Apex', "color": '#9e564e', "icon": "Apex" },
# 	'criminal': { "name": 'Criminal', "color": '#4169e1', "icon": "Criminal" },
# 	'shaper': { "name": 'Shaper', "color": '#32cd32', "icon": "Shaper" },
# 	'sunny-lebeau': { "name": 'Sunny Lebeau', "color": '#715778', "icon": "Sunny LeBeau" },
# 	'neutral': { "name": 'Neutral (runner)', "color": '#808080', "icon": "Neutral" },
# 	'haas-bioroid': { "name": 'Haas-Bioroid', "color": '#8a2be2', "icon": "Haas-Bioroid" },
# 	'jinteki': { "name": 'Jinteki', "color": '#dc143c', "icon": "Jinteki" },
# 	'nbn': { "name": 'NBN', "color": '#ff8c00', "icon": "NBN" },
# 	'weyland-consortium': { "name": 'Weyland Consortium', "color": '#326b5b', "icon": "Weyland" },
# 	'neutral': { "name": 'Neutral (corp)', "color": '#808080', "icon": "Neutral" }
# }

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
	':charizard:': 'Scheherazade',
	'siphon': 'Account Siphon',
	'deja': 'Déjà Vu',
	'deja vu': 'Déjà Vu',
	'gov takeover': 'Government Takeover',
	'gt': 'Government Takeover',
	'baby': 'Symmetrical Visage',
	'pancakes': 'Adjusted Chronotype',
	'dlr': 'Data Leak Reversal',
	'bn': 'Breaking News',
	'rp': 'Replicating Perftion',
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
	'aoycr': 'An Offer You Can\'t Refuse',
	'hok': 'House of Knives',
	'cc': 'Clone Chip',
	'ta': 'Traffic Accident',
	'jesus': 'Jackson Howard',
	'baby bucks': 'Symmetrical Visage',
	'babybucks': 'Symmetrical Visage',
	'mediohxcore': 'Deuces Wild',
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
	'sneakysly': 'Stimhack',
	'eap': 'Explode-a-palooza',
	'wnp': 'Wireless Net Pavilion',
	'mcg': 'Mumbad City Grid',
	'sscg': 'SanSan City Grid',
	'jes': 'Jesminder Sareen',
	'jess': 'Jesminder Sareen',
	'jessie': 'Jesminder Sareen',
	'palana': 'Pālanā Foods',
	'palana foods': 'Pālanā Foods',
	'plop': 'Political Operative',
	'polop': 'Political Operative',
	'pol op': 'Political Operative',
	'poop': 'Political Operative',
	'mcc': 'Mumbad Construction Co.',
	'coco': 'Mumbad Construction Co.',
	'moh': 'Museum of History',
	'cst': 'Corporate Sales Team',
	'panera': 'Panchatantra',
	'pancetta': 'Panchatantra',
	'hhn': 'Hard-Hitting News',
	'adap': 'Another Day, Another Paycheck',
	'maus': 'Mausolus',
	'eoi': 'Exchange of Information',
	'oota': 'Out of the Ashes',
	'tw': 'The Turning Wheel',
	'dnn': 'Dedicated Neural Net',
	'ftm': 'Fear The Masses',
	'ttw': 'The Turning Wheel',
	'tw': 'The Turning Wheel',
	'tbf': 'The Black File',
	'bf': 'The Black File',
	'ips': 'Improved Protien Source',
	'nmcg': 'Navi Mumbai City Grid',
	'tpof': 'The Price of Freedom',
	'pgo': 'Power Grid Overload',
	'am': 'Archived Memories',
	'ro': 'Reclamation Order',
	'mch': 'Mumbad City Hall',
	'nach': 'New Angeles City Hall',
	'dl': 'Dirty Laundry',
	'tr': 'Test Run',
	'itd': 'IT Department',
	'it': 'IT Department',
	'vi': 'Voter Intimidation',
	'fte': 'Freedom Through Equality',
	'vbg': 'Virus Breeding Ground',
	'exploda': 'Explode-a-palooza',
	'ctm': 'NBN: Controlling the Message',
	'hrf': 'Hyouba Research Facility',
	'abr': 'Always Be Running',
	'dan': 'Deuces Wild',
	':dan:': 'Deuces Wild',
	':themtg:': 'Deuces Wild',
	'pornstache': 'Hernando Cortez',
	'porn stache': 'Hernando Cortez',
	'porn-stache': 'Hernando Cortez',
	'vape': 'Deuces Wild',
	'fair1': 'Fairchild 1.0',
	'fc1': 'Fairchild 1.0',
	'fc 1': 'Fairchild 1.0',
	'fair2': 'Fairchild 2.0',
	'fc2': 'Fairchild 2.0',
	'fc 2': 'Fairchild 2.0',
	'fair3': 'Fairchild 3.0',
	'fc3': 'Fairchild 3.0',
	'fc 3': 'Fairchild 3.0',
	'fc4': 'Fairchild',
	'fc 4': 'Fairchild',
	'fcp': 'Fairchild',
	'fcprime': 'Fairchild',
	"fc'": 'Fairchild',
	'psk': 'Rumor Mill',
	'khantract': 'Temüjin Contract',
	'tc': 'Temüjin Contract',
	'clippy': 'Paperclip',
	'clippit': 'Paperclip',
	'crouton': 'Curtain Wall',
	'bon': 'Weyland: Builder of Nations',
	'aot': 'Archtects of Tomorrow',
	'pu': 'Jinteki: Potential Unleashed',
	'smoke': 'Ele "Smoke" Scovak',
	'bl': 'Biotic Labor',
	'ad': 'Accelerated Diagnostics',
	'sfm': 'Shipment from Mirrormorph',
	'sfmm': 'Shipment from Mirrormorph',
	'sfk': 'Shipment from Kaguya',
	'psyfield': 'Psychic Field',
	'psy field': 'Psychic Field',
	'psifield': 'Psychic Field',
	'psi field': 'Psychic Field',
	'mvt': 'Mumbad Virtual Tour',
	'eff comm': 'Efficiency Committee',
	'eff com': 'Efficiency Committee',
	'effcomm': 'Efficiency Committee',
	'effcom': 'Efficiency Committee',
	'ec': 'Efficiency Committee',
	'd1en': 'Memstrips',
	'dien': 'Memstrips',
	'ber': 'Bioroid Efficiency Research',
	'ci fund': 'C.I. Fund',
	'vlc': 'Violet Level Clearance',
	'pv': 'Project Vitruvius',
	'sac con': 'Sacrificial Construct',
	'saccon': 'Sacrificial Construct',
	'sc': 'Sacrificial Construct',
	'willow': "Will-o'-the-Wisp",
	'fihp': 'Friends in High Places',
	'otl': 'On the Lam'
}

DISPLAY_CYCLES = [ 2, 4, 6, 8, 10, 11 ]

formatCard = (card, packs, cycles, types, factions, mwl) ->
	title = card.title
	if card.uniqueness
		title = "◆ " + title

	attachment = {
		'fallback': title,
		'title': title,
		'title_link': 'https://netrunnerdb.com/en/card/' + card.code,
		'mrkdwn_in': [ 'text', 'author_name' ]
	}

	attachment['text'] = ''

	typeline = ''
	if card.keywords? and card.keywords != ''
		typeline += "*#{types[card.type_code].name}*: #{card.keywords}"
	else
		typeline += "*#{types[card.type_code].name}*"

	cardCost = card.cost
	if card.cost == null
		cardCost = 'X'

	switch card.type_code
		when 'agenda'
			typeline += " _(#{card.advancement_cost}:rez:, #{card.agenda_points}:agenda:)_"
		when 'asset', 'upgrade'
			typeline += " _(#{cardCost}:credit:, #{card.trash_cost}:trash:)_"
		when 'event', 'operation', 'hardware', 'resource'
			typeline += " _(#{cardCost}:credit:"
			if card.trash_cost?
				typeline += ", #{card.trash_cost}:trash:"
			typeline += ")_"
		when 'ice'
			cardStrength = card.strength
			if card.strength == null
				cardStrength = 'X'
			typeline += " _(#{cardCost}:credit:, #{cardStrength} strength"
			if card.trash_cost?
				typeline += ", #{card.trash_cost}:trash:"
			typeline += ")_"
		when 'identity'
			if card.side_code == 'runner'
				typeline += " _(#{card.base_link}:baselink:, #{card.minimum_deck_size} min deck size, #{card.influence_limit || 'Infinite'} influence)_"
			else if card.side_code == 'corp'
				typeline += " _(#{card.minimum_deck_size} min deck size, #{card.influence_limit || 'Infinite'} influence)_"
		when 'program'
			if /Icebreaker/.test(card.keywords)
				cardStrength = card.strength
				if card.strength == null
					cardStrength = 'X'
				typeline += " _(#{cardCost}:credit:, #{card.memory_cost}:mu:, #{cardStrength} strength)_"
			else
				typeline += " _(#{cardCost}:credit:, #{card.memory_cost}:mu:)_"

	attachment['text'] += typeline + "\n\n"
	if card.text?
		attachment['text'] += emojifyNRDBText card.text
	else
		attachment['text'] += ''

	faction = factions[card.faction_code]

	if faction?
		authorname = "#{packs[card.pack_code].name}"
		if cycles[packs[card.pack_code].cycle_code].position in DISPLAY_CYCLES
			authorname = authorname + " / #{cycles[packs[card.pack_code].cycle_code].name} Cycle"
		authorname = authorname + " ##{card.position} / #{faction.name}"
		influencepips = ""
		if card.faction_cost?
			i = card.faction_cost
			while i--
				influencepips += '●'
		if card.code of mwl.cards
			i = mwl.cards[card.code]
			while i--
				influencepips += '★'
		if influencepips != ""
			authorname = authorname + " #{influencepips}"

		attachment['author_name'] = authorname
		attachment['color'] = '#' + faction.color
		if faction.code of FACTION_ICONS
			attachment['author_icon'] = FACTION_ICONS[faction.code]

	if card.code of mwl.cards
		attachment['footer'] = mwl.name

	return attachment

superscriptify = (num) ->
	superscripts = {
		'0': '⁰',
		'1': '¹',
		'2': '²',
		'3': '³',
		'4': '⁴',
		'5': '⁵',
		'6': '⁶',
		'7': '⁷',
		'8': '⁸',
		'9': '⁹',
		'X': 'ˣ',
		'x': 'ˣ'
	}

	sup = ''
	for digit in [0..(num.length-1)]
		sup = sup + superscripts[num[digit]]
	return sup

emojifyNRDBText = (text) ->
	text = text.replace /\[Credits?\]/ig, ":credit:"
	text = text.replace /\[Click\]/ig, ":click:"
	text = text.replace /\[Trash\]/ig, ":trash:"
	text = text.replace /\[Recurring( |-)Credits?\]/ig, ":recurring:"
	text = text.replace /\[Subroutine\]/gi, ":subroutine:"
	text = text.replace /\[(Memory Unit|mu)\]/ig, " :mu:"
	text = text.replace /\[Link\]/ig, ":baselink:"
	text = text.replace /<sup>/ig, " "
	text = text.replace /<\/sup>/ig, ""
	text = text.replace /&ndash/ig, "–"
	text = text.replace /<strong>/ig, "*"
	text = text.replace /<\/strong>/ig, "*"
	text = text.replace /\[jinteki\]/ig, ":jinteki:"
	text = text.replace /\[weyland-consortium\]/ig, ":weyland:"
	text = text.replace /\[nbn\]/ig, ":nbn:"
	text = text.replace /\[haas-bioroid\]/ig, ":hb:"
	text = text.replace /\[shaper\]/ig, ":shaper:"
	text = text.replace /\[criminal\]/ig, ":criminal:"
	text = text.replace /\[anarch\]/ig, ":anarch:"
	text = text.replace /\[adam\]/ig, ":adam:"
	text = text.replace /\[sunny\]/ig, ":sunnylebeau:"
	text = text.replace /\[apex\]/ig, ":apex:"
	text = text.replace /\<ul>/ig, "\n"
	text = text.replace /\<\/ul>/ig, ""
	text = text.replace /\<li>/ig, "• "
	text = text.replace /\<\/li>/ig, "\n"
	text = text.replace /\<errata>/ig, "_"
	text = text.replace /\<\/errata>/ig, "_"
	text = text.replace /<trace>(trace) (\d+|X)<\/trace>/ig, (match, traceText, strength, offset, string) ->
		traceStrength = superscriptify strength
		return "*" + traceText + traceStrength + "*—"

	return text

compareCards = (card1, card2) ->
	if card1.title < card2.title
		return -1
	else if card1.title > card2.title
		return 1
	else
		return 0

cardMatches = (card, cond, packs, cycles) ->
	return false if cond.key == 'p' && typeof(card.strength) == 'undefined'
	return false if cond.key == 'o' && typeof(card.cost) == 'undefined'
	return false if cond.key == 'n' && typeof(card.faction_cost) == 'undefined'
	return false if cond.key == 'y' && typeof(card.quantity) == 'undefined'
	return false if cond.key == 'g' && typeof(card.advancement_cost) == 'undefined'
	return false if cond.key == 'v' && typeof(card.agenda_points) == 'undefined'

	switch cond.op
		when ":", "="
			switch cond.key
				when "e" then return card.pack_code == cond.value
				when "t" then return card.type_code == cond.value
				when "s" then return card.keywords && cond.value in card.keywords.toLowerCase().split(" - ")
				when "f" then return card.faction_code.substr(0, cond.value.length) == cond.value
				when "x" then return card.text && ~(card.text.toLowerCase().indexOf(cond.value))
				when "d" then return cond.value == card.side_code.substr(0, cond.value.length)
				when "a" then return card.flavor && ~(card.flavor.toLowerCase().indexOf(cond.value))
				when "i" then return card.illustrator && ~(card.illustrator.toLowerCase().indexOf(cond.value))
				when "u" then return !card.uniqueness == !parseInt(cond.value)
				when "p" then return card.strength == parseInt(cond.value)
				when "o" then return card.cost == parseInt(cond.value)
				when "n" then return card.faction_cost == parseInt(cond.value)
				when "y" then return card.quantity == parseInt(cond.value)
				when "g" then return card.advancement_cost == parseInt(cond.value)
				when "v" then return card.agenda_points == parseInt(cond.value)
				when "c" then return cycles[packs[card.pack_code].cycle_code].position == parseInt(cond.value)
		when "<"
			switch cond.key
				when "p" then return card.strength < parseInt(cond.value)
				when "o" then return card.cost < parseInt(cond.value)
				when "n" then return card.faction_cost < parseInt(cond.value)
				when "y" then return card.quantity < parseInt(cond.value)
				when "g" then return card.advancement_cost < parseInt(cond.value)
				when "v" then return card.agenda_points < parseInt(cond.value)
				when "c" then return cycles[packs[card.pack_code].cycle_code].position < parseInt(cond.value)
		when ">" then return !cardMatches(card, { key: cond.key, op: "<", value: parseInt(cond.value) + 1 }, packs, cycles)
		when "!" then	return !cardMatches(card, { key: cond.key, op: ":", value: cond.value }, packs, cycles)
	true

lookupCard = (query, cards) ->
	query = query.toLowerCase()

	if query of ABBREVIATIONS
		query = ABBREVIATIONS[query]

	fuseOptions =
		caseSensitive: false
		include: ['score']
		shouldSort: true
		threshold: 0.6
		location: 0
		distance: 100
		maxPatternLength: 32
		keys: ['title']

	fuse = new Fuse cards, fuseOptions
	results = fuse.search(query)

	if results? and results.length > 0
		filteredResults = results.filter((c) -> c.score == results[0].score).sort((c1, c2) -> c1.item.title.length - c2.item.title.length)
		return filteredResults[0].item
	else
		return false

createNRDBSearchLink = (conditions) ->
	start = "https://netrunnerdb.com/find/?q="
	cond_array = []
	for cond in conditions
		cond.op = ":" if cond.op == "="
		cond_array.push (cond.key + cond.op + cond.value)
	return start + cond_array.join "+"


module.exports = (robot) ->
	robot.http("https://netrunnerdb.com/api/2.0/public/cards")
		.get() (err, res, body) ->
			cardData = JSON.parse body
			robot.brain.set 'cards', cardData.data.sort(compareCards)
			robot.brain.set 'imageUrlTemplate', cardData.imageUrlTemplate

	robot.http("https://netrunnerdb.com/api/2.0/public/packs")
		.get() (err, res, body) ->
			packData = JSON.parse body
			mappedPackData = {}
			for pack in packData.data
				mappedPackData[pack.code] = pack
			robot.brain.set 'packs', mappedPackData

	robot.http("https://netrunnerdb.com/api/2.0/public/cycles")
		.get() (err, res, body) ->
			cycleData = JSON.parse body
			mappedCycleData = {}
			for cycle in cycleData.data
				mappedCycleData[cycle.code] = cycle
			robot.brain.set 'cycles', mappedCycleData

	robot.http("https://netrunnerdb.com/api/2.0/public/types")
		.get() (err, res, body) ->
			typeData = JSON.parse body
			mappedTypeData = {}
			for type in typeData.data
				mappedTypeData[type.code] = type
			robot.brain.set 'types', mappedTypeData

	robot.http("https://netrunnerdb.com/api/2.0/public/factions")
		.get() (err, res, body) ->
			factionData = JSON.parse body
			mappedFactionData = {}
			for faction in factionData.data
				mappedFactionData[faction.code] = faction
			robot.brain.set 'factions', mappedFactionData

	robot.http("https://netrunnerdb.com/api/2.0/public/mwl")
		.get() (err, res, body) ->
			mwlData = JSON.parse body
			currentMwl = {}
			for mwl in mwlData.data
				if mwl.active
					currentMwl = mwl
					break
			robot.brain.set 'mwl', currentMwl

	robot.hear /\[\[([^\]]+)\]\]/, (res) ->
		query = res.match[1].replace /^\s+|\s+$/g, ""
		card = lookupCard(query, robot.brain.get('cards'))

		if card
			formattedCard = formatCard(card, robot.brain.get('packs'), robot.brain.get('cycles'), robot.brain.get('types'), robot.brain.get('factions'), robot.brain.get('mwl'))
			# robot.logger.info formattedCard
			res.send
				as_user: true
				attachments: [formattedCard]
				username: res.robot.name
		else
			res.send "No card result found for \"" + res.match[1] + "\"."

	robot.hear /{{([^}]+)}}/, (res) ->
		query = res.match[1].replace /^\s+|\s+$/g, ""
		card = lookupCard(query, robot.brain.get('cards'))

		if card
			res.send robot.brain.get('imageUrlTemplate').replace /\{code\}/, card.code
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

	robot.hear /^!find (.*)/, (res) ->
		conditions = []
		for part in res.match[1].toLowerCase().match(/(([etsfxpondaiuygvc])([:=<>!])([-\w]+|\".+?\"))+/g)
			if out = part.match(/([etsfxpondaiuygvc])([:=<>!])(.+)/)
				if out[2] in ":=!".split("") || out[1] in "ponygvc".split("")
					conditions.push({ key: out[1], op: out[2], value: out[3].replace(/\"/g, "") })

		return res.send("Sorry, I didn't understand :(") if !conditions || conditions.length < 1

		results = []
		packs = robot.brain.get('packs')
		cycles = robot.brain.get('cycles')
		for card in robot.brain.get('cards')
			valid = true
			for cond in conditions
				valid = valid && cardMatches(card, cond, packs, cycles)
			results.push(card.title) if valid

		total = results.length
		if total > 10
			res.send("Found #{results[0..9].join(", ")} and <" + createNRDBSearchLink(conditions) + "|#{total - 10} more>")
		else if total < 1
			res.send("Couldn't find anything :|")
		else
			res.send("Found #{results.join(", ")}")
