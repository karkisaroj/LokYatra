-- ============================================================
-- LokYatra: Homestay Seed Data
-- 8 culturally authentic homestays near Nepal's heritage sites
-- Run this against the lokyatra PostgreSQL database
-- ============================================================

INSERT INTO "Homestays" (
  "OwnerId", "NearCulturalSiteId",
  "Name", "Location", "Description", "Category",
  "PricePerNight",
  "BuildingHistory", "CulturalSignificance", "TraditionalFeatures", "CulturalExperiences",
  "NumberOfRooms", "MaxGuests", "Bathrooms",
  "Amenities", "ImageUrls", "IsVisible", "CreatedAt", "UpdatedAt"
) VALUES

-- ── 1. BHAKTAPUR ─────────────────────────────────────────────
(NULL, 4,
  'Nyatapola Heritage House',
  'Taumadhi Tole, Bhaktapur',
  'A meticulously restored 18th-century Newari merchant house standing directly on the ancient cobblestones of Taumadhi Tole, steps from the iconic five-storey Nyatapola Temple. Original carved peacock windows, hand-cut terracotta floor tiles, and centuries-old timber beam ceilings create an atmosphere that no hotel can replicate. The rooftop terrace looks straight across to Nyatapola''s five ascending plinths at sunrise — a view unchanged for three hundred years. The same family has lived here for seven generations, and their knowledge of the city''s festivals, craftspeople, and hidden temples is yours to draw upon.',
  'Heritage Home',
  4500.00,
  'Constructed around 1760 CE during the reign of the Malla kings, this house was originally the residence of a prominent Newari metal-trading family that supplied ritual objects and temple fittings to the Bhaktapur royal court. The ground floor served as a workshop and storefront; the upper floors housed the family across three generations under one roof. The structure survived the devastating 1934 Nepal–Bihar earthquake with damage that was repaired entirely using traditional methods — lime mortar, hand-fired brick, and salvaged timber — with no concrete introduced. Ownership has remained within the same family continuously for over 260 years.',
  'The house sits within the living heritage core of Bhaktapur, a UNESCO World Heritage City where traditional Newari occupational castes, religious festivals, and building traditions have survived from the medieval period into the present. The Taumadhi neighbourhood is one of the least-altered streetscapes in the valley — waking up here means stepping into an environment that the Malla kings themselves would recognise. Every guest who stays contributes directly to the economic sustainability of heritage conservation in the city, since the income allows the family to maintain the building using traditional materials rather than cheaper modern substitutes.',
  'Hand-carved second-floor peacock window panels in sal wood; steep original Newari staircase — narrow and near-vertical as is traditional; central inner courtyard (chowk) with a working stone water spout (dhunge dhara) fed by the ancient Bhaktapur canal system; exposed timber beam ceilings with original mortise-and-tenon joinery; clay cooking stove (chulo) in the rooftop kitchen; carved wooden window shutters with hand-forged iron fittings throughout.',
  'Morning puja participation with the host family at the nearby Nyatapola Temple; hands-on pottery wheel demonstration at Pottery Square (10-minute walk through medieval alleys); traditional Newari breakfast of bara lentil pancakes, aloo tama bamboo shoot curry with beaten rice, and the famous Bhaktapur juju dhau yoghurt served in an earthenware pot; guided walking tour of the city''s five historic squares led by the host; evening mask-painting workshop with a local Chitrakar artisan family; Bisket Jatra New Year festival packages available in April.',
  5, 10, 3,
  ARRAY['Free WiFi', 'Rooftop terrace', 'Traditional Newari breakfast included', 'Guided heritage walk', 'Inner courtyard', 'Himalayan mountain views on clear days', 'Airport transfer available', 'Bicycle hire', 'Luggage storage'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/4/42/A_brief_view_of_Bhaktapur_Durbar_Square.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/2/2d/Bhaktapur_Durbar_Square_Silhouette.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/9/9f/Bhaktapur_Durbar_Square_041224_155.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/6/69/Historic_Pagoda_Style_Architecture_in_Kathmandu_Durbar_Square-IMG_4069.jpg'
  ],
  TRUE, NOW(), NOW()
),

-- ── 2. BOUDHANATH ────────────────────────────────────────────
(NULL, 3,
  'Boudha Kora Guesthouse',
  'Boudha Tole, Boudhanath, Kathmandu',
  'A traditional three-storey brick house on the kora (circumambulation) lane encircling Boudhanath Stupa — one of the most peaceful addresses in all of Kathmandu. From the upper-floor windows, the stupa''s gleaming white dome and the Buddha''s all-seeing painted eyes are in direct view. The building sits among Tibetan monasteries, incense shops, and butter lamp sellers; the low hum of monks chanting morning prayers drifts through the windows at dawn. A rare chance to immerse yourself in active Tibetan Buddhist practice without staying in a formal monastery, within walking distance of the largest stupa in the subcontinent.',
  'Monastery View',
  3800.00,
  'The house was built in the early 1970s by a Tibetan refugee family who settled near Boudhanath following the Tibetan diaspora of the 1950s and 1960s. The family built in the traditional Tibetan courtyard style, with a ground-floor storage area, an enclosed first-floor courtyard open to the sky, and living quarters on the upper floors. The building has been gradually adapted for visitors over the decades, while the original prayer room on the top floor has been maintained as a working family shrine. Prayer flags strung from the rooftop have been continuously replenished since the family first raised them over fifty years ago.',
  'Boudhanath is the most important Tibetan Buddhist shrine outside Tibet and the living heart of Nepal''s Tibetan exile community. The evening kora — the circumambulation walk around the stupa''s base, performed by hundreds of monks and laypeople daily — passes directly outside the guesthouse door. Guests who rise before dawn can join the first morning kora in near-silence, as mist rises from the Kathmandu Valley below and the first light catches the stupa''s gold finial. The surrounding streets contain over fifty Tibetan monasteries and are one of the most concentrated centres of Vajrayana Buddhist practice in the world outside the Tibetan plateau.',
  'Traditional Tibetan-style prayer room on the top floor with thangka paintings, a butter lamp altar, and incense burner; rooftop terrace with an unobstructed view of the stupa dome; exterior walls painted in traditional Tibetan ochre and white; window frames carved and painted in traditional style with Tibetan motifs; a large hand-turned prayer wheel in the entrance courtyard that guests are welcome to spin.',
  'Early morning kora walk with the host around Boudhanath Stupa before the tourist crowds arrive; butter lamp offering ceremony at the stupa base at dusk; guided visit to Shechen or Kopan Monastery for a teaching or puja (subject to monastery schedule); introductory thangka painting lesson with a Boudha master artist (90 minutes); traditional Tibetan breakfast of tsampa porridge, butter tea, and fresh momos; full-moon kora experience during Losar (Tibetan New Year).',
  4, 8, 2,
  ARRAY['Free WiFi', 'Direct stupa view', 'Tibetan breakfast included', 'Prayer room access', 'Daily kora walk with host', 'Airport pickup', 'Bicycle hire', 'Monastery visit arrangements', 'Luggage storage'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/c/c1/Boudhanath_Stupa_1.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/4/43/Majestic_Boudhanath.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/e/e0/Blue_sky_and_Boudhanath_Stupa.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/c/cf/Shechen_Monastery%2C_Nepal.jpg'
  ],
  TRUE, NOW(), NOW()
),

-- ── 3. PATAN / LALITPUR ──────────────────────────────────────
(NULL, 5,
  'Patan Artisan Courtyard Homestay',
  'Mangal Bazaar, Lalitpur (Patan)',
  'A beautifully maintained Newar bahal (Buddhist monastery-courtyard residence) in the heart of Patan''s historic quarter, two minutes'' walk from Patan Durbar Square. The house wraps around a private courtyard with a carved stone torana above the entry gate and a stone lotus fountain at the centre — a design unchanged since the 16th century. The family who own and run the homestay are hereditary metalworkers of the Shakya community, whose ancestors cast bronze statues for the royal courts of Nepal, Tibet, and Bhutan. Staying here gives direct access to a living artistic tradition that has produced some of the most revered sacred objects in the Buddhist world.',
  'Heritage Home',
  4200.00,
  'The bahal dates to the 16th century CE and was part of a larger monastic complex associated with the Newar Buddhist community of the Mangal Bazaar neighbourhood. The residential section was adapted by the current family''s ancestors in the 17th century when the Shakya metalworking community expanded along this lane. The courtyard fountain (hiti) was fed by the same underground canal system that supplied Patan''s famous stone water spouts — several still flow today. The carved wooden torana above the entrance gate depicts the Buddhist deity Vajrasattva and was restored by the family in 2018 using traditional lime-wash and linseed oil treatments.',
  'Patan is considered the artistic capital of the Kathmandu Valley and the birthplace of the Himalayan Buddhist metalworking tradition. The Shakya community — hereditary bronze-casters — have produced sacred images used in temples and monasteries from Nepal to Bhutan to Mongolia for over a thousand years. Staying in one of their ancestral homes provides a rare window into a living craft tradition and the daily rituals of Newar Buddhist family life. The morning sound of metal hammers from the adjacent workshop, the smell of incense from the family shrine, and the sight of half-finished deity images in the ground-floor casting room are all part of the experience.',
  'Private courtyard with a 16th-century stone lotus fountain (hiti); carved wooden torana gate with Buddhist iconography; traditional bronze-casting workshop visible from the courtyard (active business — visitors welcome to observe); family Buddhist shrine room on the first floor with daily morning puja; exposed timber beam ceilings; stone-flagged courtyard floor; intricate latticed Newar windows on all upper floors.',
  'Guided bronze-casting demonstration with the family''s master metalsmith — watch the lost-wax (cire perdue) process used to cast sacred images; traditional Newari meal cooked by the host family featuring recipes specific to the Shakya community; private guided tour of Patan Durbar Square and the Patan Museum (admission included); visit to the family''s patron deity shrine in the nearby bahal courtyard; introduction to Newar Buddhist calendar and the festivals the family observes each month.',
  4, 8, 3,
  ARRAY['Free WiFi', 'Private courtyard with fountain', 'Traditional Newari dinner included', 'Bronze-casting demonstration', 'Patan Museum guided visit', 'Heritage architecture', 'Mountain views from roof', 'Airport transfer available', 'Cooking class'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/8/8c/Patan_Durbar_Square_%28136%29.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/5/55/Panoroma_of_Patan_durbar_Square.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/f/ff/Patan_Durbar_Square_01.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/5/55/Patan_Museum.jpg'
  ],
  TRUE, NOW(), NOW()
),

-- ── 4. SWAYAMBHUNATH ─────────────────────────────────────────
(NULL, 2,
  'Swayambhu Hill Retreat',
  'Swayambhu, Kathmandu',
  'A serene hilltop guesthouse set on the forested slopes of Swayambhu hill, a five-minute walk below the ancient Buddhist stupa. The house is surrounded by towering sal trees and the mischievous resident monkeys of Swayambhunath, with a garden terrace that opens to an unobstructed panorama across the entire Kathmandu Valley. From here you can watch the valley fill with morning mist and the city slowly wake below you. The stupa''s painted eyes are visible from the upper terrace — present on the horizon like the watchful gaze they represent. Morning prayer drums and the ringing of temple bells drift down through the trees from first light.',
  'Heritage Home',
  3500.00,
  'The house was built in 1952 by a Newar family from Kirtipur who were given land on the Swayambhu hillside by the local Buddhist temple committee in recognition of their service as stone-carvers working on stupa renovations. The original structure was a simple two-storey farmhouse; subsequent generations added a third storey and the garden terrace in the 1980s. The family have maintained a small private vegetable garden on the hillside since the house was built, and guests are invited to pick fresh herbs and greens for their breakfast. One of the current owners worked as a restoration mason during the post-2015 earthquake repairs to the Swayambhunath complex and can speak with first-hand knowledge of the conservation work.',
  'Swayambhunath is one of the oldest religious sites in Nepal and the hilltop from which it watches over the valley has been sacred for over 2,500 years. The Swayambhu hill is believed in Buddhist cosmology to be the original lotus that rose from the primordial lake that once filled the Kathmandu Valley — the self-arisen (swayambhu) sacred light from which the stupa takes its name. The forest on the hill is a protected zone and home to hundreds of rhesus macaques considered sacred guardians of the site. Staying here places you within the energetic sphere of one of the great pilgrimage sites of Asia, close enough to arrive at the stupa before the first tourist buses and to leave after the last evening prayers.',
  'Garden terrace with panoramic Kathmandu Valley view; traditional Newar-style timber window frames and carved lintels; a private meditation space in the garden under a bodhi sapling (planted by the grandmother of the current owner); kitchen garden with fresh herbs, tomatoes, and seasonal vegetables; stone pathway through the garden leading directly up the hill toward the stupa entry; an original stone hand-press for extracting mustard oil, still used by the family.',
  'Sunrise walk to the Swayambhunath stupa with the host before gates open to the public — arriving at the first morning prayers with the monks; meditation session on the garden terrace at dawn with the valley panorama as backdrop; traditional Newar breakfast of chiura beaten rice with sel roti, pickled vegetables, and black tea; guided walk to the Shreepur hilltop forest for bird-watching (over 80 species recorded within 500 metres); evening lesson in the significance of the 108 prayer wheels on the stupa circuit.',
  3, 6, 2,
  ARRAY['Free WiFi', 'Panoramic Kathmandu Valley view', 'Sunrise stupa walk with host', 'Organic garden breakfast included', 'Meditation space', 'Forest walking trails', 'Bird-watching garden', 'Bicycle hire for city rides'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/3/31/Swayambhunath_Stupa_as_seen_from_Dharahara.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/9/9d/Eyes_of_swayambunath_stupa.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/1/18/Closeup_detail_on_Swayambhunath_with_8_buddhas.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/d/d9/Kathmandu_Durbar_Square%2C_Nepal.JPG'
  ],
  TRUE, NOW(), NOW()
),

-- ── 5. POKHARA / PHEWA LAKE ──────────────────────────────────
(NULL, 45,
  'Phewa Lakeside Heritage Home',
  'Lakeside (Baidam), Pokhara',
  'A traditional Gurung-style stone house on the quiet northern shore of Phewa Lake, with a private garden running to the water''s edge and a timber viewing deck over the lake. The Annapurna and Machhapuchhre (Fishtail) peaks rise directly above, reflected in the lake on still mornings in a scene that has become synonymous with Nepal. The Barahi Island Temple is visible from the deck — a five-minute rowboat journey away. This is the Pokhara that existed before the tourist strip was built: the garden smells of woodsmoke and rice straw, the lake fishermen launch their boats at four in the morning, and the mountains turn pink at first light.',
  'Lakeside Traditional',
  5000.00,
  'The house was built in 1938 by a Gurung family from the Lamjung district who settled on the Phewa lakeside following the elder son''s service in the British Indian Army. It was built in the traditional Gurung stone-and-timber construction style, with thick walls for insulation and a wide overhanging roof to shed the heavy monsoon rains. The garden was planted by the founding family and contains several fruit trees — lemon, guava, and persimmon — estimated to be over 70 years old. The family added the lake-facing timber deck and boat mooring in the 1990s when Pokhara began to develop as a trekking base, and have maintained the traditional character of the house despite increasing pressure from neighbouring hotel developments.',
  'Phewa Lake and the Barahi Island Temple at its centre are the spiritual and visual heart of Pokhara. The goddess Barahi — a tantric form of Durga — is the principal protective deity of the Pokhara valley, and the boat journey to her island temple is a pilgrimage that virtually every local family undertakes at significant moments in life. The Gurung community, whose homeland is the hills above Pokhara, have a deep connection to the lake and the Annapurna range beyond it — the mountains they lived in the shadow of, whose rivers watered their fields, and whose trails their men walked as soldiers for two centuries. Staying with a Gurung family provides access to a culture quite different from the Newari culture of Kathmandu — more austere, more closely tied to the land and the military tradition.',
  'Private garden extending to the lakeside with wooden mooring for the family rowing boat; wide overhanging roof typical of Gurung traditional construction; stone-flagged kitchen and dining area with a traditional clay stove; handwoven Gurung dhaka textile cushions and wall hangings throughout; timber viewing deck over the water with mountain panorama; hand-built stone garden boundary wall with flowering bougainvillea; a small shrine to the household deity at the garden''s edge.',
  'Early morning rowing boat trip across Phewa Lake to the Barahi Island Temple — arrive before dawn for the morning puja; guided kayak or canoe tour of the quieter lake margins with the host''s son (a certified guide); traditional Gurung breakfast of dhido buckwheat porridge with nettle soup, fermented vegetables, and buffalo milk tea; guided nature walk on the Annapurna foothills above the house with views of Machhapuchhre; evening Gurung cultural performance and storytelling about the family''s military history; arrangement of short treks or the Annapurna circuit connection from the host.',
  6, 12, 4,
  ARRAY['Free WiFi', 'Private lakeside garden', 'Rowing boat for guest use', 'Annapurna mountain view', 'Traditional Gurung breakfast included', 'Kayak hire', 'Airport/bus transfer', 'Trek arrangements', 'Evening cultural programme'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/d/d4/Barahi_Island_Temple%2C_Phewa_Lake%2C_Pokhara%2C_Nepal.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/e/e5/Phewa_Lake_and_Taal_Barahi_Temple.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/a/a0/Barahi_mandir_Pokhara.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/7/7b/Barahi_island_Temple.jpg'
  ],
  TRUE, NOW(), NOW()
),

-- ── 6. LUMBINI ───────────────────────────────────────────────
(NULL, 7,
  'Lumbini Sacred Garden Cottage',
  'Lumbini Development Zone, Rupandehi',
  'A peaceful mud-plastered cottage within a walled garden on the edge of the Lumbini sacred zone, walking distance from the Maya Devi Temple — the precise birthplace of Siddhartha Gautama. The cottage is surrounded by sal trees, the same species beneath which the Buddha was born, and the garden is planted with medicinal herbs and lotus-edged ponds as described in the Jataka tales. From the garden at dawn, you can hear the chanting of monks from the dozens of monasteries nearby, as pilgrims from across the Buddhist world arrive at first light. This is one of the rarest addresses in Asia — the immediate neighbourhood of one of humanity''s most sacred spots.',
  'Sacred Garden',
  2800.00,
  'The cottage was built in 2009 by a local Tharu family who had farmed this land for generations before the Lumbini Development Zone was established in the 1990s. Rather than relocate, the family converted their traditional thatched farmhouse into a guesthouse while preserving the organic construction style — walls of compressed earth and rice-straw plaster, a thatched roof, and hand-carved wooden doors and window frames. The family participated in the replanting of the sacred garden buffer zone and have maintained a small medicinal herb garden since the house was built. The current generation runs the cottage with a commitment to low-impact hosting: rainwater collected from the roof, solar power for lighting, and composting of all organic waste.',
  'Lumbini holds a significance for the world''s 500 million Buddhists equivalent to Bethlehem for Christians. The Maya Devi Temple marks the spot where Queen Maya Devi stood, grasping the branch of a sal tree, and gave birth to the prince who would become the Buddha. The Ashokan Pillar, which still stands in the sacred garden and bears an inscription from 249 BCE confirming this as the birthplace, is one of the most important historical documents in South Asia. The lotus pond where the infant Siddhartha was first bathed and the Marker Stone beneath the Maya Devi Temple are among the most revered objects in the Buddhist world. Staying in the immediate vicinity — waking with the monks, walking to the temple before the buses arrive — is a profoundly different experience from visiting as a day-tripper.',
  'Traditional Tharu earth-plastered walls with natural ochre pigment decoration; thatched roof in the style of the Terai lowland tradition; hand-carved wooden door frames with geometric Tharu patterns; lotus pond in the walled garden; medicinal herb garden with plants used in traditional Tharu healing practice; hammock area beneath a sal tree canopy; solar-powered lighting throughout; outdoor cooking area with a traditional Tharu clay hearth.',
  'Pre-dawn walk to the Maya Devi Temple for the opening of the gates at first light — arriving before the crowds in the silence of the sacred garden; guided tour of the Lumbini monastic zone covering the Japanese, Chinese, Korean, Sri Lankan, and Tibetan monasteries — each a distinct architectural tradition; traditional Tharu breakfast of rice porridge with buffalo ghee, wild honey, and seasonal Terai fruits; evening visit to the Eternal Peace Flame and the Ashokan Pillar with the host as guide; bird-watching walk in the Lumbini buffer zone forest (over 250 species recorded in the area); arranged participation in a meditation session at one of the resident monasteries.',
  3, 6, 2,
  ARRAY['Free WiFi', 'Sacred garden setting', 'Pre-dawn temple walk with host', 'Traditional Tharu breakfast included', 'Monastic zone guided tour', 'Solar-powered eco cottage', 'Bird-watching', 'Meditation session arrangement', 'Bicycle hire for monastery zone'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/c/c3/Maya_Devi_temple-Nepal.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/9/96/Maya_Devi_Temple_with_Monks.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/0/08/World_Peace_Pagoda_Lumbini%2C_Nepal.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/9/97/Lumbini_Museum.jpg'
  ],
  TRUE, NOW(), NOW()
),

-- ── 7. CHANGU NARAYAN ────────────────────────────────────────
(NULL, 8,
  'Changu Village Heritage Stay',
  'Changu Village, Bhaktapur District',
  'A traditional Newar farmhouse in the hilltop village of Changu, perched above the Kathmandu Valley with panoramic views across to the Himalayan range. The house is a ten-minute walk from Changu Narayan Temple — Nepal''s oldest standing temple and a UNESCO World Heritage Site — along a stone-paved path through terraced barley fields. The village itself is rarely visited by tourists and maintains the traditional Newar agricultural and craft life that has largely disappeared from the valley floor. Local residents still farm the terraces below the temple hill, sell pottery and thangka paintings from home workshops, and observe the seasonal festival cycle of the Changu Narayan temple complex.',
  'Village Heritage',
  3200.00,
  'The house was built in the 1880s by a Newar farming family whose land surrounds the western slope of the Changu hill. The original structure was extended in the 1950s with an additional storey constructed from the same hand-fired Newar brick that characterises all traditional buildings in this area. Unlike the heavily restored houses in the tourist zones of Bhaktapur, this property has never been commercially developed — the walls are genuine lime-plastered brick, the floors are polished clay, and the roof is the original hand-laid terracotta tile. The family have farmed mustard, wheat, and vegetables on their terraces continuously for four generations.',
  'Changu Narayan is Nepal''s oldest surviving temple and houses some of the finest 4th-to-9th-century CE stone sculptures in existence. The hilltop location gives the temple complex — and the village surrounding it — a commanding presence above the valley. Unlike Bhaktapur and Patan, which have become major tourist destinations, Changu village remains largely as it has been for centuries: a working agricultural community living in the shadow of one of Nepal''s greatest monuments. The farmers who tend the terraces below the temple use methods that have changed little since the Licchavi period. Staying here is an immersion in the pre-modern Newar rural world that urban restoration cannot recreate.',
  'Traditional clay-plastered walls in original Newar farmhouse style; polished clay floors maintained with mustard oil in the traditional method; open roof terrace with views across the Kathmandu Valley and Himalayan range; hand-turned pottery wheel in the adjoining workshop (the family''s secondary occupation); stone-paved courtyard with a traditional hand-pump well; wooden-shuttered windows with original hand-forged iron hinges; storage room containing the family''s traditional farming tools — available to handle and photograph.',
  'Guided visit to Changu Narayan Temple at opening time — the host''s family has worshipped here for generations and knows every sculpture and inscription; hands-on introduction to Newar pottery-making on the traditional foot-powered wheel; traditional farm breakfast of fresh-ground stone-milled wheat bread, scrambled eggs from the house chickens, and seasonal pickled vegetables; guided walk along the ancient trade route between Changu and Bhaktapur through terraced fields; evening lesson in reading the temple''s Licchavi-era stone inscriptions with the host''s translation; participation in seasonal agricultural work (wheat threshing, mustard harvest) when visiting during the appropriate season.',
  3, 6, 2,
  ARRAY['Free WiFi', 'Himalayan panorama', 'Temple guided visit included', 'Traditional breakfast', 'Pottery workshop', 'Village farm walk', 'Authentic non-tourist village', 'Bhaktapur day trip arrangement'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/6/68/Changunarayan_Temple%2C_Bhaktapur.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/1/14/Gate_at_Changu_Narayan.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/4/49/Stone_statue_at_Changunarayan_temple.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/4/42/A_brief_view_of_Bhaktapur_Durbar_Square.JPG'
  ],
  TRUE, NOW(), NOW()
),

-- ── 8. PASHUPATINATH ─────────────────────────────────────────
(NULL, 1,
  'Bagmati Riverside Heritage Homestay',
  'Gaushala, Pashupatinath, Kathmandu',
  'A traditional two-storey Newar house on the east bank of the Bagmati River, looking across to the golden-roofed towers of the Pashupatinath Temple complex. The house is set within a narrow lane of the Gaushala neighbourhood — the area that has served pilgrims visiting the Pashupatinath sacred zone for centuries. The ground-floor room opens directly to a riverside terrace from which the temple''s main shikhara (spire) is visible above the tree line, and the sound of temple bells, chanting, and the flowing river provide the constant background of daily life here. Non-Hindu guests cannot enter the inner temple compound, but from this terrace the full ceremonial life of the complex — the sadhus, the cremations, the pilgrims'' bathing, the evening aarti light ceremony — unfolds directly across the river.',
  'Temple Heritage',
  3800.00,
  'The house was built in the early 1900s as a pilgrim rest-house (dharamsala) serving visitors to the Pashupatinath Temple from outside the valley. It was managed by a brahmin family from Bhaktapur who were given custodial rights to the property by the Pashupatinath Temple Trust in exchange for providing free accommodation to indigent pilgrims. The commercial use of pilgrim hostels along the Bagmati corridor intensified during the 20th century as the road network improved, and the current family began hosting paying guests in the 1990s while continuing to offer free meals to any brahmin pilgrim who presented themselves at the door — a practice the host still maintains on the full moon day of each month.',
  'Pashupatinath is Nepal''s most sacred temple and one of the four most important Shiva shrines in South Asia. The Bagmati River bank is among the holiest places in the Hindu world — dying within the Pashupati Kshetra (sacred zone) is believed to guarantee moksha, liberation from the cycle of rebirth, regardless of one''s karma. The cremation ghats on the riverside are not sombre or hidden but open and communal — an honest, unmediated encounter with death and the cycle of life that Hinduism integrates into daily existence in a way that modern secular culture rarely allows. Watching the evening aarti ceremony from across the river, with its oil lamps and conch shells and drums echoing between the temple towers, is one of the most powerful experiences available to a visitor in Nepal.',
  'Riverside terrace with direct view of the Pashupatinath temple spire and cremation ghats; traditional Newar courtyard house layout with a central open area; family shrine room with a continuously burning oil lamp maintained without interruption; original terracotta tile roof; carved wooden doorframes and window lattices in the Newar tradition; stone staircase with original carved handrails; kitchen maintained in the traditional style with a clay hearth (chulo) alongside modern facilities.',
  'Pre-dawn walk to the Pashupatinath ghats for the opening ceremony, accompanied by the host who can explain the significance of what you are witnessing; visit to the Mrigasthali deer park on the wooded hill opposite the temple for morning meditation among the resident sadhus; traditional brahmin breakfast of sel roti fried rice-bread, black lentil soup, and spiced milk tea; guided walk through the Pashupatinath precinct with the host explaining the 518 subsidiary temples and the significance of each area; evening aarti ceremony at the river''s edge — the most atmospheric time of day at the temple; arranged visit to the resident sadhus'' ashrams for conversation and portrait photography.',
  4, 8, 3,
  ARRAY['Free WiFi', 'Riverside terrace with temple view', 'Traditional brahmin breakfast included', 'Pre-dawn ghat walk with host', 'Sadhu ashram visit', 'Evening aarti experience', 'Airport transfer available', 'Thamel proximity (15 min)'],
  ARRAY[
    'https://upload.wikimedia.org/wikipedia/commons/3/3e/Pashupatinath_temple.JPG',
    'https://upload.wikimedia.org/wikipedia/commons/d/d3/Pashupati_Kshetra_1.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/3/32/Bagmati_River_and_Pashupatinath.jpg',
    'https://upload.wikimedia.org/wikipedia/commons/0/01/Old_Building_in_Pashupatinath.jpg'
  ],
  TRUE, NOW(), NOW()
);
