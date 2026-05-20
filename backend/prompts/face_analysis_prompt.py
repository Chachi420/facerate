FACE_ANALYSIS_PROMPT = """
FIRST: Check if this image contains a clearly visible human face.
If there is NO human face in the image, look at what IS actually in the image and return exactly this JSON and nothing else:
{"error": "no_face", "pun": "<write a short, witty, funny pun (1-2 sentences) that references the SPECIFIC subject of this image and explains why you can't rate it — e.g. if it's a mountain: 'Even Everest can't peak our interest — we need cheekbones, not summits. Drop a selfie!', if it's a dog: 'Your dog is a 10/10 but FaceRate is humans-only... for now 🐾 Show us YOUR face!', if it's pizza: 'We tried rating this pizza\\'s jawline — 10/10 crust definition — but we need your face, not your dinner!'. Be creative, warm, and funny. Keep it under 2 sentences.>"}

If a human face IS present, analyze it carefully and return ONLY a valid JSON object with these exact fields.
Be honest, editorial, and grounded — not flattering, not harsh.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PERSONALIZATION MANDATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Every single recommendation MUST reference THIS person's specific features:
- haircut_recommendations → must name the detected face_shape explicitly
- skincare_routine → must be built around the detected skin_type
- beard_tips → for masculine faces: specific beard style that enhances THIS face shape; for feminine/androgynous faces: eyebrow shaping, brow lamination, or facial massage tips instead
- glasses_frames → must name the face_shape when explaining why each frame works
- feature_tips → must reference the actual score and what was observed in each feature
- strengths/areas_to_improve → must cite specific features, not generic statements

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ANIMAL SELECTION RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BANNED animals (too overused — never pick these):
Lion, Tiger, Wolf, Eagle, Domestic Cat, Dog, Labrador, Bear, Fox, Dolphin, Owl, Shark, Hawk, Panther, Cheetah (unless King Cheetah specifically)

SCORE-TO-RARITY GUIDE:
- Score 0.0–5.9  → Common (40%)
- Score 6.0–7.4  → Uncommon (30%)
- Score 7.5–8.4  → Rare (20%)
- Score 8.5–9.2  → Epic (8%)
- Score 9.3–10.0 → Legendary (2%)
- Occasionally a truly unique or unusual face at any score may be bumped one tier higher

FACE-TO-ANIMAL MATCHING:
- Strong angular jaw + sharp cheekbones → apex predators (felids, raptors, mustelids)
- Soft round features + large eyes → gentle/nocturnal creatures (slow loris, tarsier, axolotl)
- Long elegant proportions → ungulates, wading birds, sighthounds
- Wide forehead + narrow jaw → heart-faced animals (red panda, sugar glider, kinkajou)
- Deep-set intense eyes → ambush predators or deep-sea creatures
- Prominent nose bridge → anteaters, tapirs, proboscis animals
- Very symmetrical balanced features → bilateral-symmetry animals (mandarinfish, morpho butterfly)
- High golden ratio → birds-of-paradise, peacocks, or jewel animals
- Warm skin tones + earthy features → savanna, desert, or grassland animals
- Cool pale skin + sharp features → arctic, alpine, or aquatic animals
- Dark rich skin + strong structure → African megafauna, tropical birds
- Olive/Mediterranean features → Mediterranean and Middle Eastern fauna
- Androgynous features → gender-fluid animals (clownfish, parrotfish, wrasse)
- Unusual or asymmetric uniqueness → cryptic species or camouflage masters

ANIMAL POOL — pick from this curated list OR any fitting animal from your training knowledge:

COMMON tier (well-known, expected):
Capybara, Common Wombat, Quokka, Beagle, Dachshund, Pug, Corgi, Shiba Inu, Bichon Frise, Samoyed,
Flamingo, Pelican, Toucan, King Penguin, Rockhopper Penguin, Macaroni Penguin, Gentoo Penguin,
Common Raccoon, Eastern Grey Squirrel, Western Hedgehog, Virginia Opossum, Armadillo,
Fallow Deer, Roe Deer, Reindeer, White-tailed Deer, Domestic Goat, Alpaca,
Red-crowned Crane, Common Crane, Great Blue Heron, Grey Heron, Purple Heron,
Song Thrush, European Robin, Common Kingfisher, Atlantic Puffin, Tufted Puffin, Common Loon

UNCOMMON tier (less expected, specific breed or species):
Arctic Fox, Fennec Fox, Tibetan Sand Fox, Bat-eared Fox, Corsac Fox, Swift Fox,
Meerkat, Mongoose, Binturong, Kinkajou, Coati, Cacomistle, Ring-tailed Cat,
Sugar Glider, Feathertail Glider, Pygmy Glider, Greater Glider,
Moose, Caribou, Pronghorn, Gemsbok, Springbok, Impala, Klipspringer,
Mantis, Praying Mantis, Orchid Mantis, Dead Leaf Mantis, Ghost Mantis, Bark Mantis,
Shoebill Stork, Secretary Bird, Hamerkop, Marabou Stork, Saddle-billed Stork,
Hoatzin, Sunbittern, Sun Bear, Spectacled Bear, Sloth Bear, Polar Bear (for very cool features),
African Wild Dog, Dhole, Maned Wolf, Bush Dog, Short-eared Dog,
Red Panda, Giant Panda (rare within uncommon), Golden Snub-nosed Monkey, Proboscis Monkey,
De Brazza's Monkey, Mandrill, Gelada Baboon, Hamadryas Baboon, Patas Monkey,
Wolverine, Honey Badger, Tayra, Grison, Zorilla, Striped Polecat,
Walrus, Elephant Seal, Leopard Seal, Crabeater Seal, Ross Seal,
Amazon River Dolphin, Spinner Dolphin, Dusky Dolphin, Bottlenose Dolphin

RARE tier (genuinely unexpected, science-level knowledge):
Okapi, Malayan Tapir, South American Tapir, Baird's Tapir, Mountain Tapir,
Babirusa, Sulawesi Warty Pig, Pygmy Hippopotamus, Forest Buffalo, Lowland Anoa,
Fossa, Aye-aye, Indri, Sifaka (Verreaux's, Coquerel's, Milne-Edwards's), Ring-tailed Lemur, Red Ruffed Lemur,
Philippine Tarsier, Spectral Tarsier, Pygmy Tarsier, Horsfield's Tarsier,
Pygmy Marmoset, Golden Lion Tamarin, Emperor Tamarin, Cotton-top Tamarin, Goeldi's Monkey,
Clouded Leopard, Sunda Clouded Leopard, Serval, Caracal, Sand Cat, Pallas's Cat,
Ocelot, Margay, Oncilla, Kodkod, Pampas Cat, Andean Mountain Cat, Bay Cat,
Flat-headed Cat, Fishing Cat, Rusty-spotted Cat, Marbled Cat,
Jaguarundi, Chinese Mountain Cat, African Golden Cat, Temminck's Cat,
Saiga Antelope, Gerenuk, Dibatag, Addax, Hirola, Dik-dik (Kirk's, Günther's),
Irrawaddy Dolphin, Hector's Dolphin, Maui Dolphin, Tucuxi, Boto,
Narwhal, Beluga Whale, Dwarf Sperm Whale, Pygmy Sperm Whale,
Leafy Sea Dragon, Weedy Sea Dragon, Robust Ghost Pipefish, Ornate Ghost Pipefish,
Axolotl, Olm, Mudpuppy, Hellbender, Giant Salamander (Chinese/Japanese),
Gila Monster, Mexican Beaded Lizard, Thorny Devil, Moloch, Frilled-neck Lizard,
Mata Mata Turtle, Alligator Snapping Turtle, Indian Star Tortoise, Radiated Tortoise,
Mimic Octopus, Coconut Octopus, Wunderpus, Blue-ringed Octopus (for rare, not epic),
Mantis Shrimp (Peacock, Zebra, Harlequin), Banded Coral Shrimp, Pistol Shrimp,
Flamboyant Cuttlefish, Paintpot Cuttlefish, Bobtail Squid, Firefly Squid,
Dumbo Octopus, Glass Octopus, Vampire Squid, Bigfin Reef Squid

EPIC tier (very rare, highly specific, scientifically obscure):
Snow Leopard, White Bengal Tiger, Black (melanistic) Jaguar, King Cheetah, Clouded Leopard (Epic variant),
Resplendent Quetzal, Splendid Cotinga, Cotinga Maynana, Purple-breasted Cotinga,
Victoria Crowned Pigeon, Nicobar Pigeon, Luzon Bleeding-heart Pigeon, Victoria's Riflebird,
Kakapo, Kea, Kokako, Takahe, Huia (if extinct animals are valid),
Superb Bird-of-Paradise, Vogelkop Superb Bird-of-Paradise, King Bird-of-Paradise,
Ribbon-tailed Astrapia, Princess Stephanie's Astrapia, Splendid Astrapia,
Raggiana Bird-of-Paradise, Blue Bird-of-Paradise, Goldie's Bird-of-Paradise,
Magnificent Riflebird, Twelve-wired Bird-of-Paradise, Standardwing Bird-of-Paradise,
Lilac-breasted Roller, Dollarbird, Indian Roller, Broad-billed Roller,
Mandarin Duck, Baikal Teal, Cotton Pygmy Goose, Brazilian Merganser,
Lyrebird (Superb or Albert's), Spotted Bowerbird, MacGregor's Bowerbird, Regent Bowerbird,
Peacock Spider (Maratus volans and variants), Orchid Mantis (epic variant), Jewel Beetle (Buprestidae),
Wallace's Golden Birdwing, Rajah Brooke's Birdwing, Queen Alexandra's Birdwing,
Goliath Birdwing, Ornithoptera Priamus, Blue Morpho Butterfly, Ulysses Butterfly,
Atlas Moth, Hercules Moth, Sunset Moth, Moon Moth (Luna Moth),
Philippine Eagle, Harpy Eagle, Martial Eagle, Crowned Eagle (African),
Bearded Vulture (Lammergeier), California Condor (epic variant),
Saola, Giant Ibis, Forest Owlet, Siberian Crane (Epic variant)

LEGENDARY tier (critically endangered, mythologically rare, or extinction-edge):
Vaquita, Javan Rhinoceros, Sumatran Rhinoceros, Northern White Rhinoceros,
Tapanuli Orangutan, Hainan Gibbon, Cao Vit Gibbon, Cross River Gorilla,
Spix's Macaw, Regent Honeyeater, Stresemann's Bristlefront, Cebu Flowerpecker,
Whooping Crane (Legendary variant), Red-crowned Crane (Legendary rarity),
Philippine Eagle (Legendary variant — for near-perfect symmetry + intensity),
Amur Leopard, Amur Tiger (Siberian Tiger), Sumatran Tiger, Malayan Tiger,
Solenodon (Cuban or Hispaniolan), Pygmy Three-toed Sloth, Silky Anteater,
Platypus, Short-beaked Echidna (for truly unusual unique faces),
Pygmy Hippopotamus (Legendary variant), Forest Elephant (Legendary),
Yangtze Finless Porpoise, Baiji River Dolphin, Ganges River Dolphin,
Saiga Antelope (Legendary-edge subspecies), Hirola (Endangered antelope),
Chinese Paddlefish, Coelacanth, Lungfish (Australian or African),
Okapi (Legendary variant — for near-impossible unique beauty),
Tibetan Antelope (Chiru), Pronghorn (Legendary variant),
Gharial, Philippine Crocodile, Chinese Alligator, Orinoco Crocodile,
Kakapo (Legendary variant — for extraordinary rarity of beauty)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SKIN TYPE DETECTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Detect from the image:
- oily: visible shine, enlarged pores, possibly congested T-zone
- dry: matte or flaky texture, possibly tight-looking skin, fine lines visible
- combination: oily T-zone (forehead/nose/chin) with normal or dry cheeks
- normal: even texture, no extreme shine or dryness, small pores
- sensitive: visible redness, rosacea, easily reactive-looking skin, thin skin appearance
- acne_prone: active breakouts, post-inflammatory marks, congested pores

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SKINCARE ROUTINE PERSONALIZATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Build 5 steps around the detected skin_type:
- oily → gentle foaming/gel cleanser, 2% BHA/salicylic acid toner, niacinamide 10% serum, oil-free gel moisturizer, SPF 50 mattifying sunscreen
- dry → cream/milk cleanser, hyaluronic acid serum (layered), ceramide-rich moisturizer, facial oil at night (rosehip/squalane), SPF 30+ moisturizing sunscreen
- combination → micellar or balanced cleanser, AHA/BHA hybrid toner (2-3x/week), vitamin C serum, lightweight moisturizer (gel-cream hybrid), SPF 50 broad-spectrum
- normal → gentle pH-balanced cleanser, vitamin C or niacinamide serum, balanced moisturizer, SPF 50 daily, weekly exfoliant (lactic acid)
- sensitive → fragrance-free cream cleanser, centella asiatica or azelaic acid serum, barrier repair moisturizer (with ceramides + fatty acids), mineral SPF 30-50, no actives during flares
- acne_prone → 2% salicylic acid cleanser, benzoyl peroxide 2.5-5% (spot or all-over), oil-free non-comedogenic moisturizer, azelaic acid or retinoid at night, SPF 50 non-comedogenic

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Return this JSON (all fields required):

{
  "score": <float 0-10, one decimal>,
  "percentile": <int, estimated % of people this score beats>,
  "face_shape": <"oval"|"round"|"square"|"heart"|"diamond"|"oblong">,
  "archetype": <"Dark Ethereal"|"Bold Classic"|"Soft Golden"|"Wild Rugged"|"Sharp Defined"|"Fresh Youthful"|"Delicate Refined"|"Rare Exotic">,
  "archetype_description": <2 sentence editorial description of this specific archetype energy for this face>,
  "features": {
    "jawline": {"score": <float>, "description": <specific 1-sentence observation about THIS jawline>},
    "eyes": {"score": <float>, "description": <specific 1-sentence observation about THIS eyes>},
    "nose": {"score": <float>, "description": <specific 1-sentence observation about THIS nose>},
    "lips": {"score": <float>, "description": <specific 1-sentence observation about THIS lips>},
    "forehead": {"score": <float>, "description": <specific 1-sentence observation about THIS forehead>},
    "skin": {"score": <float>, "description": <specific 1-sentence observation about THIS skin>}
  },
  "golden_ratio_score": <float>,
  "skin_tone": <string, descriptive e.g. "warm medium-brown", "cool fair", "deep rich ebony", "olive Mediterranean", "neutral golden">,
  "skin_type": <"oily"|"dry"|"combination"|"normal"|"sensitive"|"acne_prone">,
  "strengths": [<3 strengths citing specific features observed — never generic>],
  "areas_to_improve": [<2 areas — honest but constructive, naming specific features>],
  "haircut_recommendations": [<3 cuts explicitly suited to the detected face_shape — name the shape in each>],
  "beard_tips": <for masculine faces: specific beard style enhancing this face shape; for feminine faces: brow shaping, face yoga, or facial massage tip instead>,
  "skincare_routine": [<5 steps tailored to the detected skin_type — follow the personalization guide above>],
  "glasses_frames": [<2 frame styles — explain why each suits this face_shape>],
  "collar_tips": <1 specific styling tip matching this archetype and skin tone>,
  "feature_tips": {
    "jawline": [<tip 1 — specific actionable technique: mewing, gua sha, beard shaping, face exercises, contouring>, <tip 2>],
    "eyes": [<tip 1 — specific: sleep quality, caffeine eye patches, gua sha under-eye, lash serum, eye drops, colour-match liner>, <tip 2>],
    "nose": [<tip 1 — contouring technique, highlight placement, non-surgical tip>, <tip 2>],
    "lips": [<tip 1 — sugar scrub, lip mask, overline technique, plumping serum, SPF lip balm>, <tip 2>],
    "forehead": [<tip 1 — fringe recommendation for face shape, SPF for forehead lines, retinol, Botox-alternative>, <tip 2>],
    "skin": [<tip 1 — tailored to detected skin_type>, <tip 2>, <tip 3>]
  },
  "celebrity_lookalike": {
    "name": <string>,
    "match_percentage": <int 60-95>,
    "reason": <specific visual reason referencing features>
  },
  "fictional_character": {
    "name": <string>,
    "franchise": <string>,
    "match_percentage": <int 60-95>,
    "reason": <specific visual reason>
  },
  "perceived_age": <int>,
  "vibe": <2-sentence editorial face energy description — poetic but grounded>,
  "animal": {
    "name": <pick from the ANIMAL POOL above or any other fitting animal — NEVER pick the banned list>,
    "emoji": <single emoji best representing this animal>,
    "rarity": <"Common"|"Uncommon"|"Rare"|"Epic"|"Legendary">,
    "reason": <one line why this animal matches — reference specific face features>,
    "vibe_description": <2 editorial sentences, poetic and shareable — something the person will WANT to post>
  }
}

Return ONLY the JSON object. No explanation. No markdown. No code blocks.
"""
