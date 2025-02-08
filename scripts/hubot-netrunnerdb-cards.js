const Fuse = require('fuse.js');

const FACTION_ICONS = {
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
};

const LOCALIZATION = {
  'en': {
    'influence': 'influence',
    'infinite': 'Infinite',
    'decksize': 'min deck size',
    'strength': 'strength',
    'cycle': 'Cycle',
    'trace': 'trace'
  },
  'kr': {
    'influence': '영향력',
    'infinite': '무한한',
    'decksize': '최소 덱 크기',
    'strength': '힘',
    'cycle': '사이클',
    'trace': '추적'
  }
};

// For reference only (commented out)
// const FACTIONS = {
//   ...
// };

const ABBREVIATIONS = {
  'en': {
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
    'ihw': "I've Had Worse",
    'qt': 'Quality Time',
    'nisei': 'Nisei Mk II',
    'dhpp': "Director Haas' Pet Project",
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
    'toilet': 'Inside Job',
    ':toilet:': 'Inside Job',
    'loo': 'Inside Job',
    'potty': 'Inside Job',
    'restroom': 'Inside Job',
    'bathroom': 'Inside Job',
    'washroom': 'Inside Job',
    'commode': 'Inside Job',
    'wc': 'Inside Job',
    'w.c.': 'Inside Job',
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
    'oycr': "An Offer You Can't Refuse",
    'aoycr': "An Offer You Can't Refuse",
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
    'will o': "Will-o'-the-Wisp",
    'willo': "Will-o'-the-Wisp",
    'will-o': "Will-o'-the-Wisp",
    'wotw': "Will-o'-the-Wisp",
    'fihp': 'Friends in High Places',
    'otl': 'On the Lam',
    'sifr': 'Ṣifr',
    'piot': 'Peace in Our Time',
    'sna': 'Sensor Net Activation',
    'sunya': 'Sūnya',
    'barney': 'Bryan Stinson',
    'hat': 'Hellion Alpha Test',
    'hbt': 'Hellion Beta Test',
    'csm': 'Clone Suffrage Movement',
    'mogo': 'Mother Goddess',
    'uwc': 'Underworld Contacts',
    ':dien:': 'Memstrips',
    'o2': 'O₂ Shortage',
    ':damon:': 'O₂ Shortage',
    ':lukas:': 'Astroscript Pilot Program',
    ':mtgdan:': 'Deuces Wild',
    ':spags:': 'Troll',
    'deuces mild': 'Build Script',
    'sau': 'Sensie Actors Union',
    'sft': 'Shipment from Tennin',
    'moon': 'Estelle Moon',
    'uvc': 'Ultraviolet Clearance',
    'sva': 'Salvaged Vanadis Armory',
    'bob': 'Bug Out Bag',
    'turtle': 'Aumakua',
    'tla': 'Threat Level Alpha',
    'mca': 'MCA Austerity Policy',
    'map': 'MCA Austerity Policy',
    'nanotech': "Na'Not'K",
    'nanotek': "Na'Not'K",
    'bitey boi': 'Gbahali',
    'bitey boy': 'Gbahali',
    'one bitey boi': 'Gbahali',
    'one bitey boy': 'Gbahali',
    'crocodile': 'Gbahali',
    'alligator': 'Gbahali',
    'gator': 'Gbahali',
    ':crocodile:': 'Gbahali',
    ':bitey:': 'Gbahali',
    ':biteyboi:': 'Gbahali',
    'estrike': 'Employee strike',
    'strike': 'Employee Strike',
    'e-strike': 'Employee Strike',
    'doof': 'Diversion of Funds',
    'dof': 'Diversion of Funds',
    'divvy': 'Diversion of Funds',
    'gabe': 'Gabriel Santiago',
    'daddy gabe': 'Gabriel Santiago',
    'ucf': 'Universal Connectivity Fee',
    'mache': 'Mâché',
    'aal': 'Advanced Assembly Lines',
    'lat': 'Lat: Ethical Freelancer',
    'tyr': 'Týr'
  },
  'kr': {
    '미드시즌': '중간 개편',
    '하드히팅': '신랄한 특종',
    '팔라나': '팔라나 식품: 지속가능한 성장',
    '팔라냐': '팔라나 식품: 지속가능한 성장',
    '푸드': '전지구 식량 계획',
    '블랙메일': '협박',
    '보안 방': '보안 결',
    '팬사이트': '팬 사이트',
    '민지': '잭슨 하워드'
  }
};

const SKIP_PACKS = ['urbp'];

function preloadData(robot) {
  const locales = ["en", "kr"];
  locales.forEach((locale) => {
    // Cards
    robot.http(`https://netrunnerdb.com/api/2.0/public/cards?_locale=${locale}`)
      .get()((err, res, body) => {
        if (err) {
          robot.logger.error(err);
          return;
        }
        const cardData = JSON.parse(body);
        const cards = cardData.data.sort(compareCards);
        robot.logger.info(`Loaded ${cardData.data.length} NRDB cards`);
        robot.brain.set(`cards-${locale}`, cards);
        robot.brain.set(`imageUrlTemplate-${locale}`, cardData.imageUrlTemplate);

        // MWL
        robot.http(`https://netrunnerdb.com/api/2.0/public/mwl?_locale=${locale}`)
          .get()((err2, res2, body2) => {
            if (err2) {
              robot.logger.error(err2);
              return;
            }
            const mwlData = JSON.parse(body2);
            let currentMwl = {};
            for (let i = 0; i < mwlData.data.length; i++) {
              const mwl = mwlData.data[i];
              if (mwl.active) {
                currentMwl = mwl;
                break;
              }
            }
            robot.brain.set(`mwl-${locale}`, currentMwl);

            const restrictedCards = [];
            const bannedCards = [];
            const mwlCards = cards.filter((c) => {
              // Return true if c.code in currentMwl.cards
              return currentMwl.cards && Object.prototype.hasOwnProperty.call(currentMwl.cards, c.code);
            });

            mwlCards.forEach((card) => {
              const mwlInfo = currentMwl.cards[card.code];
              if (mwlInfo.is_restricted === 1) {
                restrictedCards.push(card.title);
              }
              if (mwlInfo.deck_limit === 0) {
                bannedCards.push(card.title);
              }
            });

            robot.logger.info(`Loaded ${mwlCards.length} NRDB MWL cards`);
            robot.brain.set(`restrictedCards-${locale}`, restrictedCards);
            robot.brain.set(`bannedCards-${locale}`, bannedCards);
          });
      });

    // Packs
    robot.http(`https://netrunnerdb.com/api/2.0/public/packs?_locale=${locale}`)
      .get()((err, res, body) => {
        if (err) {
          robot.logger.error(err);
          return;
        }
        const packData = JSON.parse(body);
        const mappedPackData = {};
        packData.data.forEach((pack) => {
          mappedPackData[pack.code] = pack;
        });
        robot.logger.info(`Loaded ${packData.data.length} NRDB packs`);
        robot.brain.set(`packs-${locale}`, mappedPackData);
      });

    // Cycles
    robot.http(`https://netrunnerdb.com/api/2.0/public/cycles?_locale=${locale}`)
      .get()((err, res, body) => {
        if (err) {
          robot.logger.error(err);
          return;
        }
        const cycleData = JSON.parse(body);
        const mappedCycleData = {};
        cycleData.data.forEach((cycle) => {
          mappedCycleData[cycle.code] = cycle;
        });
        robot.logger.info(`Loaded ${cycleData.data.length} NRDB cycles`);
        robot.brain.set(`cycles-${locale}`, mappedCycleData);
      });

    // Types
    robot.http(`https://netrunnerdb.com/api/2.0/public/types?_locale=${locale}`)
      .get()((err, res, body) => {
        if (err) {
          robot.logger.error(err);
          return;
        }
        const typeData = JSON.parse(body);
        const mappedTypeData = {};
        typeData.data.forEach((type) => {
          mappedTypeData[type.code] = type;
        });
        robot.logger.info(`Loaded ${typeData.data.length} NRDB types`);
        robot.brain.set(`types-${locale}`, mappedTypeData);
      });

    // Factions
    robot.http(`https://netrunnerdb.com/api/2.0/public/factions?_locale=${locale}`)
      .get()((err, res, body) => {
        if (err) {
          robot.logger.error(err);
          return;
        }
        const factionData = JSON.parse(body);
        const mappedFactionData = {};
        factionData.data.forEach((faction) => {
          mappedFactionData[faction.code] = faction;
        });
        robot.logger.info(`Loaded ${factionData.data.length} NRDB factions`);
        robot.brain.set(`factions-${locale}`, mappedFactionData);
      });
  });
}

function formatCard(card, packs, cycles, types, factions, mwl, imageUrlTemplate, locale) {
  let title = card.title;
  if (locale !== 'en' && card._locale && card._locale[locale] && card._locale[locale].title) {
    title = card._locale[locale].title;
  }
  if (card.uniqueness) {
    title = "◆ " + title;
  }

  let cardImageUrl = card.image_url;
  if (!cardImageUrl) {
    cardImageUrl = imageUrlTemplate.replace(/\{code\}/, card.code);
  } else {
    // Convert https to http
    cardImageUrl = cardImageUrl.replace('https', 'http');
  }

  const attachment = {
    fallback: title,
    title: title,
    title_link: `https://netrunnerdb.com/${locale}/card/${card.code}`,
    mrkdwn_in: ['text', 'author_name'],
    thumb_url: cardImageUrl
  };

  attachment.text = '';

  let typeline = '';
  if (locale !== 'en' && card._locale && card._locale[locale] && card._locale[locale].name) {
    typeline = `*${types[card.type_code]._locale[locale].name}*`;
    if (card._locale[locale].keywords && card._locale[locale].keywords !== '') {
      typeline += `: ${card._locale[locale].keywords}`;
    } else if (card.keywords && card.keywords !== '') {
      typeline += `: ${card.keywords}`;
    }
  } else {
    typeline = `*${types[card.type_code].name}*`;
    if (card.keywords && card.keywords !== '') {
      typeline += `: ${card.keywords}`;
    }
  }

  let cardCost = card.cost;
  if (card.cost == null) {
    cardCost = 'X';
  }

  switch (card.type_code) {
    case 'agenda':
      typeline += ` _(${card.advancement_cost}:rez:, ${card.agenda_points}:agenda:)_`;
      break;
    case 'asset':
    case 'upgrade':
      typeline += ` _(${cardCost}:credit:, ${card.trash_cost}:trash:)_`;
      break;
    case 'event':
    case 'operation':
    case 'hardware':
    case 'resource':
      typeline += ` _(${cardCost}:credit:`;
      if (card.trash_cost) {
        typeline += `, ${card.trash_cost}:trash:`;
      }
      typeline += `)_`;
      break;
    case 'ice': {
      let cardStrength = card.strength;
      if (cardStrength == null) {
        cardStrength = 'X';
      }
      typeline += ` _(${cardCost}:credit:, ${cardStrength} ${LOCALIZATION[locale].strength}`;
      if (card.trash_cost) {
        typeline += `, ${card.trash_cost}:trash:`;
      }
      typeline += `)_`;
      break;
    }
    case 'identity':
      if (card.side_code === 'runner') {
        typeline += ` _(${card.base_link}:baselink:, ${card.minimum_deck_size} ${LOCALIZATION[locale].decksize}, ${card.influence_limit || LOCALIZATION[locale].infinite} ${LOCALIZATION[locale].influence})_`;
      } else if (card.side_code === 'corp') {
        typeline += ` _(${card.minimum_deck_size} ${LOCALIZATION[locale].decksize}, ${card.influence_limit || LOCALIZATION[locale].infinite} ${LOCALIZATION[locale].influence})_`;
      }
      break;
    case 'program':
      if (/Icebreaker/.test(card.keywords)) {
        let cardStrength = card.strength;
        if (cardStrength == null) {
          cardStrength = 'X';
        }
        typeline += ` _(${cardCost}:credit:, ${card.memory_cost}:mu:, ${cardStrength} ${LOCALIZATION[locale].strength})_`;
      } else {
        typeline += ` _(${cardCost}:credit:, ${card.memory_cost}:mu:)_`;
      }
      break;
    default:
      break;
  }

  attachment.text += typeline + "\n\n";

  if (locale !== 'en' && card._locale && card._locale[locale] && card._locale[locale].text) {
    attachment.text += emojifyNRDBText(card._locale[locale].text);
  } else if (card.text) {
    attachment.text += emojifyNRDBText(card.text);
  } else {
    attachment.text += '';
  }

  const faction = factions[card.faction_code];
  if (faction) {
    let authorName = packs[card.pack_code].name;
    if (
      locale !== 'en' &&
      packs[card.pack_code]._locale &&
      packs[card.pack_code]._locale[locale] &&
      packs[card.pack_code]._locale[locale].name
    ) {
      authorName = `${packs[card.pack_code]._locale[locale].name}`;
    }

    if (
      locale !== 'en' &&
      cycles[packs[card.pack_code].cycle_code]._locale &&
      cycles[packs[card.pack_code].cycle_code]._locale[locale] &&
      cycles[packs[card.pack_code].cycle_code]._locale[locale].name
    ) {
      authorName += ` / ${cycles[packs[card.pack_code].cycle_code]._locale[locale].name} ${LOCALIZATION[locale].cycle}`;
    } else {
      authorName += ` / ${cycles[packs[card.pack_code].cycle_code].name} ${LOCALIZATION[locale].cycle}`;
    }

    if (locale !== 'en' && faction._locale && faction._locale[locale] && faction._locale[locale].name) {
      authorName += ` #${card.position} / ${faction._locale[locale].name}`;
    } else {
      authorName += ` #${card.position} / ${faction.name}`;
    }
    let influencepips = "";
    if (card.faction_cost) {
      for (let i = 0; i < card.faction_cost; i++) {
        influencepips += '●';
      }
    }
    if (influencepips !== "") {
      authorName += ` ${influencepips}`;
    }

    attachment.author_name = authorName;
    attachment.color = `#${faction.color}`;
    if (FACTION_ICONS.hasOwnProperty(faction.code)) {
      attachment.author_icon = FACTION_ICONS[faction.code];
    }
  }

  if (mwl.cards && mwl.cards[card.code]) {
    attachment.footer = mwl.name;
    if (mwl.cards[card.code].is_restricted === 1) {
      attachment.footer += ' Restricted';
    }
    if (mwl.cards[card.code].deck_limit === 0) {
      attachment.footer += ' Banned';
    }
  }

  return attachment;
}

function superscriptify(num) {
  const superscripts = {
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
  };
  let sup = '';
  for (let i = 0; i < num.length; i++) {
    sup += superscripts[num[i]] || num[i];
  }
  return sup;
}

function emojifyNRDBText(text) {
  let out = text;
  out = out.replace(/\[Credits?\]/ig, ":credit:");
  out = out.replace(/\[Click\]/ig, ":click:");
  out = out.replace(/\[Trash\]/ig, ":trash:");
  out = out.replace(/\[Recurring( |-)Credits?\]/ig, ":recurring:");
  out = out.replace(/\[Subroutine\]/gi, ":subroutine:");
  out = out.replace(/\[(Memory Unit|mu)\]/ig, " :mu:");
  out = out.replace(/\[Link\]/ig, ":baselink:");
  out = out.replace(/<sup>/ig, " ");
  out = out.replace(/<\/sup>/ig, "");
  out = out.replace(/&ndash/ig, "–");
  out = out.replace(/<strong>/ig, "*");
  out = out.replace(/<\/strong>/ig, "*");
  out = out.replace(/\[jinteki\]/ig, ":jinteki:");
  out = out.replace(/\[weyland-consortium\]/ig, ":weyland:");
  out = out.replace(/\[nbn\]/ig, ":nbn:");
  out = out.replace(/\[haas-bioroid\]/ig, ":hb:");
  out = out.replace(/\[shaper\]/ig, ":shaper:");
  out = out.replace(/\[criminal\]/ig, ":criminal:");
  out = out.replace(/\[anarch\]/ig, ":anarch:");
  out = out.replace(/\[adam\]/ig, ":adam:");
  out = out.replace(/\[sunny\]/ig, ":sunnylebeau:");
  out = out.replace(/\[apex\]/ig, ":apex:");
  out = out.replace(/<ul>/ig, "\n");
  out = out.replace(/<\/ul>/ig, "");
  out = out.replace(/<li>/ig, "• ");
  out = out.replace(/<\/li>/ig, "\n");
  out = out.replace(/<errata>/ig, "_");
  out = out.replace(/<\/errata>/ig, "_");
  out = out.replace(/<i>/ig, "_");
  out = out.replace(/<\/i>/ig, "_");
  out = out.replace(/<em>/ig, "_");
  out = out.replace(/<\/em>/ig, "_");

  // Build a regex for <trace>(Trace Word) (digit|X)</trace>
  const traceWords = Object.keys(LOCALIZATION).map((language) => LOCALIZATION[language].trace).join('|');
  const traceRegex = new RegExp(`<trace>(${traceWords}) (\\d+|X)<\\/trace>`, "ig");
  out = out.replace(traceRegex, (match, traceText, strength) => {
    return `*${traceText} [${strength}]*—`;
  });

  return out;
}

function compareCards(card1, card2) {
  if (card1.title < card2.title) {
    return -1;
  } else if (card1.title > card2.title) {
    return 1;
  }
  return 0;
}

function cardMatches(card, cond, packs, cycles) {
  const conditionValue = cond.value.replace(/\"/g, "");

  if (cond.key === 'p' && typeof card.strength === 'undefined') return false;
  if (cond.key === 'o' && typeof card.cost === 'undefined') return false;
  if (cond.key === 'n' && typeof card.faction_cost === 'undefined') return false;
  if (cond.key === 'y' && typeof card.quantity === 'undefined') return false;
  if (cond.key === 'g' && typeof card.advancement_cost === 'undefined') return false;
  if (cond.key === 'v' && typeof card.agenda_points === 'undefined') return false;

  switch (cond.op) {
    case ":":
    case "=":
      switch (cond.key) {
        case "e":
          return card.pack_code === conditionValue;
        case "t":
          return card.type_code === conditionValue;
        case "s":
          return card.keywords && card.keywords.toLowerCase().split(" - ").indexOf(conditionValue) !== -1;
        case "f":
          return card.faction_code.substr(0, conditionValue.length) === conditionValue;
        case "x":
          return card.text && card.text.toLowerCase().indexOf(conditionValue) !== -1;
        case "d":
          return card.side_code.substr(0, conditionValue.length) === conditionValue;
        case "a":
          return card.flavor && card.flavor.toLowerCase().indexOf(conditionValue) !== -1;
        case "i":
          return card.illustrator && card.illustrator.toLowerCase().indexOf(conditionValue) !== -1;
        case "u":
          return !card.uniqueness === !parseInt(conditionValue, 10);
        case "p":
          return card.strength === parseInt(conditionValue, 10);
        case "o":
          return card.cost === parseInt(conditionValue, 10);
        case "n":
          return card.faction_cost === parseInt(conditionValue, 10);
        case "y":
          return card.quantity === parseInt(conditionValue, 10);
        case "g":
          return card.advancement_cost === parseInt(conditionValue, 10);
        case "v":
          return card.agenda_points === parseInt(conditionValue, 10);
        case "c":
          return cycles[packs[card.pack_code].cycle_code].position === parseInt(conditionValue, 10);
        default:
          return true;
      }
    case "<":
      switch (cond.key) {
        case "p":
          return card.strength < parseInt(conditionValue, 10);
        case "o":
          return card.cost < parseInt(conditionValue, 10);
        case "n":
          return card.faction_cost < parseInt(conditionValue, 10);
        case "y":
          return card.quantity < parseInt(conditionValue, 10);
        case "g":
          return card.advancement_cost < parseInt(conditionValue, 10);
        case "v":
          return card.agenda_points < parseInt(conditionValue, 10);
        case "c":
          return cycles[packs[card.pack_code].cycle_code].position < parseInt(conditionValue, 10);
        default:
          return false;
      }
    case ">":
      // same as "not < parseInt(conditionValue, 10) + 1"
      return !cardMatches(card, {
        key: cond.key,
        op: "<",
        value: parseInt(conditionValue, 10) + 1 + ""
      }, packs, cycles);
    case "!":
      // negation
      return !cardMatches(card, {
        key: cond.key,
        op: ":",
        value: conditionValue
      }, packs, cycles);
    default:
      return true;
  }
}

function lookupCard(query, cards, locale) {
  let q = query.toLowerCase();
  if (ABBREVIATIONS[locale] && ABBREVIATIONS[locale].hasOwnProperty(q)) {
    q = ABBREVIATIONS[locale][q];
  }

  // For Korean, naive matching
  if (locale === 'kr') {
    const resultsExact = cards.filter((card) => (
      card._locale &&
      card._locale[locale] &&
      card._locale[locale].title.toLowerCase() === q
    ));
    const resultsIncludes = cards.filter((card) => (
      card._locale &&
      card._locale[locale] &&
      card._locale[locale].title.toLowerCase().includes(q)
    ));

    if (resultsExact.length > 0) {
      return resultsExact[0];
    }
    if (resultsIncludes.length > 0) {
      const sortedResults = resultsIncludes.sort((c1, c2) =>
        c1._locale[locale].title.length - c2._locale[locale].title.length
      );
      return sortedResults[0];
    }
    return false;
  } else {
    const keys = ['title'];
    if (locale !== 'en') {
      // In CoffeeScript it did: keys.push('_locale["' + locale + '"].title')
      // Typically, fuse.js with nested keys can be done with dot-notation
      keys.push(`_locale.${locale}.title`);
    }

    const fuseOptions = {
      caseSensitive: false,
      include: ['score'],
      shouldSort: true,
      threshold: 0.6,
      location: 0,
      distance: 100,
      maxPatternLength: 32,
      keys: keys
    };

    const fuse = new Fuse(cards, fuseOptions);
    const results = fuse.search(q);
    if (results && results.length > 0) {
      // Filter out excluded packs
      const resultsWithoutExcluded = results.filter((c) => SKIP_PACKS.indexOf(c.item.pack_code) === -1);
      if (resultsWithoutExcluded.length > 0) {
        // Filter by best score
        const bestScore = resultsWithoutExcluded[0].score;
        const filteredResults = resultsWithoutExcluded.filter((c) => c.score === bestScore);
        let sortedResults = [];
        if (locale === 'en') {
          sortedResults = filteredResults.sort((c1, c2) =>
            c1.item.title.length - c2.item.title.length
          );
        } else {
          // favor localized results
          sortedResults = filteredResults.sort((c1, c2) => {
            const c1HasLocale = c1.item._locale && c1.item._locale[locale];
            const c2HasLocale = c2.item._locale && c2.item._locale[locale];
            if (c1HasLocale && c2HasLocale) {
              return c1.item._locale[locale].title.length - c2.item._locale[locale].title.length;
            }
            if (c1HasLocale && !c2HasLocale) return -1;
            if (c2HasLocale && !c1HasLocale) return 1;
            return c1.item.title.length - c2.item.title.length;
          });
        }
        return sortedResults[0].item;
      }
      return false;
    }
    return false;
  }
}

function createNRDBSearchLink(conditions) {
  const start = "https://netrunnerdb.com/find/?q=";
  const condArray = [];
  conditions.forEach((cond) => {
    if (cond.op === "=") {
      cond.op = ":";
    }
    condArray.push(encodeURIComponent(cond.key + cond.op + cond.value));
  });
  return start + condArray.join("+");
}

module.exports = function(robot) {
  // Delay preload to give the app time to connect to Redis (etc.)
  setTimeout(() => {
    preloadData(robot);
  }, 1000);

  robot.hear(/\[\[([^\]\|]+)\]\]/, function(res) {
    // ignore card searches in #keyforge
    if (res.message.room === 'CC0S7SXGQ') {
      return;
    }
    let query = res.match[1].replace(/^\s+|\s+$/g, "");
    let locale = "en";

    const hangul = /[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]/;
    if (hangul.test(query)) {
      locale = "kr";
    }

    const card = lookupCard(query, robot.brain.get(`cards-${locale}`), locale);
    if (card) {
      const formattedCard = formatCard(
        card,
        robot.brain.get(`packs-${locale}`),
        robot.brain.get(`cycles-${locale}`),
        robot.brain.get(`types-${locale}`),
        robot.brain.get(`factions-${locale}`),
        robot.brain.get(`mwl-${locale}`),
        robot.brain.get(`imageUrlTemplate-${locale}`),
        locale
      );
      res.send({
        as_user: true,
        attachments: [formattedCard],
        username: robot.name
      });
    } else {
      res.send(`No Netrunner card result found for "${res.match[1]}".`);
    }
  });

  robot.hear(/{{([^}\|]+)}}/, function(res) {
    // ignore card searches in #keyforge
    if (res.message.room === 'CC0S7SXGQ') {
      return;
    }
    let query = res.match[1].replace(/^\s+|\s+$/g, "");
    let locale = "en";

    const hangul = /[\u1100-\u11FF|\u3130-\u318F|\uA960-\uA97F|\uAC00-\uD7AF|\uD7B0-\uD7FF]/;
    if (hangul.test(query)) {
      locale = "kr";
    }

    const card = lookupCard(query, robot.brain.get(`cards-${locale}`), locale);
    robot.logger.info(`Searching NRDB for card image ${query} (from ${res.message.user.name} in ${res.message.room})`);
    robot.logger.info(`Locale: ${locale}`);

    if (card) {
      if (card.image_url) {
        // Return the card's own image URL (converted to http)
        res.send(card.image_url.replace('https', 'http'));
      } else {
        res.send(robot.brain.get(`imageUrlTemplate-${locale}`).replace(/\{code\}/, card.code));
      }
    } else {
      res.send(`No Netrunner card result found for "${res.match[1]}".`);
    }
  });

  robot.hear(/^!jank\s?(runner|corp)?$/i, function(res) {
    let side = res.match[1];
    const cards = robot.brain.get('cards-en');
    const packs = robot.brain.get('packs-en');
    const cycles = robot.brain.get('cycles-en');
    const bannedCards = robot.brain.get('bannedCards-en');

    if (!side) {
      const randomSide = Math.floor(Math.random() * 2);
      side = (randomSide === 0) ? "runner" : "corp";
    } else {
      side = side.toLowerCase();
    }

    const sidecards = cards.filter((card) => {
      return (
        card.side_code === side &&
        cycles[packs[card.pack_code].cycle_code].position !== 0 &&
        !cycles[packs[card.pack_code].cycle_code].rotated &&
        bannedCards.indexOf(card.title) === -1 &&
        packs[card.pack_code].date_release != null
      );
    });

    const identities = sidecards.filter((card) => card.type_code === "identity");
    const sideNonIDCards = sidecards.filter((card) => card.type_code !== "identity");

    const randomIdentityIndex = Math.floor(Math.random() * identities.length);
    const identityCard = identities[randomIdentityIndex];

    const numberOfCards = 3;
    let cardString = identityCard.title;

    for (let i = 0; i < numberOfCards; i++) {
      let randomCard;
      while (true) {
        randomCard = sideNonIDCards[Math.floor(Math.random() * sideNonIDCards.length)];
        // Make sure e.g. no illegal agendas if runner ID, etc.
        // The check in CoffeeScript was:
        // (randomCard.type_code != "agenda" ||
        //   (randomCard.type_code == "agenda" &&
        //    (randomCard.faction_code == identityCard.faction_code ||
        //     randomCard.faction_code == "neutral"))) &&
        //  (identityCard.code != "03002" ||
        //   (identityCard.code == "03002" && randomCard.faction_code != "jinteki"))
        //
        // We'll replicate that logic:
        if (
          (randomCard.type_code !== "agenda" ||
            (
              randomCard.type_code === "agenda" &&
              (randomCard.faction_code === identityCard.faction_code || randomCard.faction_code === "neutral")
            )
          ) &&
          (identityCard.code !== "03002" ||
            (identityCard.code === "03002" && randomCard.faction_code !== "jinteki"))
        ) {
          break;
        }
      }
      cardString += " + " + randomCard.title;
    }

    res.send(cardString);
  });

  robot.hear(/^!rngkey (\d+)$/i, function(res) {
    const guess = parseInt(res.match[1], 10);
    const packs = robot.brain.get('packs-en');
    const cycles = robot.brain.get('cycles-en');
    const bannedCards = robot.brain.get('bannedCards-en');
    const allCards = robot.brain.get('cards-en');

    // Filter corp cards that are not ID, not banned, not rotated, etc.
    const cards = allCards.filter((card) => {
      return (
        card.side_code === "corp" &&
        cycles[packs[card.pack_code].cycle_code].position !== 0 &&
        !cycles[packs[card.pack_code].cycle_code].rotated &&
        bannedCards.indexOf(card.title) === -1 &&
        packs[card.pack_code].date_release != null &&
        card.type_code !== "identity"
      );
    });

    // pick the random access
    const access = cards[Math.floor(Math.random() * cards.length)];
    let cost, emoji, result;

    if (access.type_code === "agenda") {
      cost = access.advancement_cost;
      emoji = ":rez:";
    } else if (["asset", "operation", "ice", "upgrade"].indexOf(access.type_code) >= 0) {
      cost = access.cost;
      emoji = ":credit:";
    }

    if (cost === guess) {
      result = "you win!";
    } else {
      result = "you lose!";
    }

    res.send(`You guessed: ${guess}. You accessed ${access.title}! That's ${cost}${emoji}, ${result}`);
  });

  // Example of an MWL display command (commented out in the original)
  // robot.hear(/^!mwl$/i, function(res) {
  //   const mwl = robot.brain.get('mwl-en');
  //   const restrictedCards = robot.brain.get('restrictedCards-en');
  //   const bannedCards = robot.brain.get('bannedCards-en');
  //
  //   let message = `Current MWL: ${mwl.name}\n`;
  //   message += "Restricted Cards:\n";
  //   restrictedCards.forEach((card) => {
  //     message += `● ${card}\n`;
  //   });
  //   message += "Banned Cards:\n";
  //   bannedCards.forEach((card) => {
  //     message += `● ${card}\n`;
  //   });
  //   res.send(message);
  // });

  robot.hear(/^!find (.*)/, function(res) {
    // parse conditions
    const condRegex = /(([etsfxpondaiuygvc])([:=<>!])([-\w]+|\".+?\"))+/g;
    const parts = res.match[1].toLowerCase().match(condRegex);
    if (!parts || parts.length < 1) {
      res.send("Sorry, I didn't understand :(");
      return;
    }
    const conditions = [];
    parts.forEach((part) => {
      const out = part.match(/([etsfxpondaiuygvc])([:=<>!])(.+)/);
      if (out) {
        // if out[2] in ":=!".split("") || out[1] in "ponygvc".split("")
        // We'll just push it directly as the original code did
        if (out[2] === ':' || out[2] === '=' || out[2] === '!' || 'ponygvc'.includes(out[1])) {
          conditions.push({
            key: out[1],
            op: out[2],
            value: out[3]
          });
        }
      }
    });

    if (conditions.length < 1) {
      res.send("Sorry, I didn't understand :(");
      return;
    }

    const cards = robot.brain.get('cards-en');
    const packs = robot.brain.get('packs-en');
    const cycles = robot.brain.get('cycles-en');
    const results = [];

    cards.forEach((card) => {
      let valid = true;
      conditions.forEach((cond) => {
        if (!cardMatches(card, cond, packs, cycles)) {
          valid = false;
        }
      });
      if (valid) {
        results.push(card.title);
      }
    });

    const total = results.length;
    if (total > 10) {
      res.send(`Found ${results.slice(0, 10).join(", ")} and <${createNRDBSearchLink(conditions)}|${total - 10} more>`);
    } else if (total < 1) {
      res.send("Couldn't find anything :|");
    } else {
      res.send(`Found ${results.join(", ")}`);
    }
  });
};
