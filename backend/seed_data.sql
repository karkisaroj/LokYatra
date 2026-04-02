-- ============================================================
-- LokYatra: Fix Cultural Site images + Seed Stories
-- ============================================================

-- ── FIX IMAGES ──────────────────────────────────────────────

-- ID 21: Taleju Temple (was showing generic Kathmandu Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/5/59/05._Taleju_temple.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/ab/A_trip_to_basantaput_durbar_square_04.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/4/4a/Basantapur_Kathmandu_Nepal_%2822%29_%285118973013%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/a6/Kathmandu_Taleju_Temple.jpg'
] WHERE "Id" = 21;

-- ID 22: Patan Museum (was showing generic Patan Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/5/55/Patan_Museum.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/04/Patan_Museum%2C_The_Museum_behind_the_Golden_Door_1.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/d/d2/Patan_Museum%2C_The_Museum_behind_the_Golden_Door.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/4/47/Woman_Sitting_at_the_Entrance_of_the_Patan_Museum-IMG_4106.jpg'
] WHERE "Id" = 22;

-- ID 23: National Museum of Nepal (was showing Pashupatinath images!)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/2/22/Building_of_National_Museum_of_Nepal_%281%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/0d/Building_of_National_Museum_of_Nepal_%282%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/d/da/Artifacts_at_National_Museum_of_Nepal_%281%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/04/Artifacts_at_National_Museum_of_Nepal_%282%29.jpg'
] WHERE "Id" = 23;

-- ID 24: Pasupatinath Temple (duplicate of ID 1 — keep same correct images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/3/3e/Pashupatinath_temple.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/0/01/Old_Building_in_Pashupatinath.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/d/d3/Pashupati_Kshetra_1.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/32/Bagmati_River_and_Pashupatinath.jpg'
] WHERE "Id" = 24;

-- ID 25: Golden Temple Patan / Hiranya Varna Mahavihar (was showing generic Patan Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/f/f6/Hiranya_Varna_Mahavihar_Main_Temple.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/9/93/Golden_Temple_%28Hiranya_Varna_Mahavihar%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/31/Hiranya_Varna_Mahavihar_%28Golden_Temple%29_01.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/a8/Hiranya_Varna_Mahavihar%2C_Patan.jpg'
] WHERE "Id" = 25;

-- ID 26: Mahaboudha Temple (was showing generic Patan Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/0/0a/Mahaboudha_%289651389724%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b5/Mahaboudha_%289648120205%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7e/Mahabouddha_Mandir%2C_Patan%2C_Lalitpur%2C_Nepal_04.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/1/13/Mahabuddha_temple%2C_Patan_IMG_2869_%2818389840460%29.jpg'
] WHERE "Id" = 26;

-- ID 27: Bindabasini Temple Pokhara (was showing Manakamana images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/7/71/Bindabashini_Temple_01.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/9/94/Bindabashini_Temple_02.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/7/7c/Bindabashini_Temple.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/1/14/Bindabasini_temple.jpg'
] WHERE "Id" = 27;

-- ID 28: Tal Barahi Temple (was showing Manakamana images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/d/d4/Barahi_Island_Temple%2C_Phewa_Lake%2C_Pokhara%2C_Nepal.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/4/4f/Tal_Barahi_Temple.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/e/e5/Phewa_Lake_and_Taal_Barahi_Temple.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/3c/Taal_Barahi_Temple_-_Pokhara_-_01.jpg'
] WHERE "Id" = 28;

-- ID 29: Kathesimbhu Stupa (was showing Boudhanath images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/3/39/Buddha%27s_eyes_on_the_Kathesimbhu_stupa_%2817210992643%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/d/db/Buddhist_complex_in_the_old_city_%2812653801864%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/8/88/Buddhist_Complex_In_The_Old_City_%28222708259%29.jpeg',
  'https://upload.wikimedia.org/wikipedia/commons/2/20/A_stoupa_surrounded_by_pigeons.JPG'
] WHERE "Id" = 29;

-- ID 30: Charumati Stupa (was showing Boudhanath images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/4/49/Charumati_Stupa.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/2/27/Charumati_Stupa.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/8/86/Charumati_Stupa_Image_01.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/9/95/Charumati_Stupa_Image_02.jpg'
] WHERE "Id" = 30;

-- ID 31: Indreshwar Mahadev Temple, Panauti (was showing Bhaktapur Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/a/ad/Indreshower_Temple%2C_Panauti.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/7/70/Indreswor_Temple_Panauti_IMG_1155_01.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/b/bf/Indreswor_Temple_Panauti_IMG_1155_04.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/35/Indreswor_Temple_Panauti_IMG_1121_38.jpg'
] WHERE "Id" = 31;

-- ID 32: Gorakhnath Temple, Gorkha Durbar (was showing Manakamana images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/5/58/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%281%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/4/49/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%282%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/0f/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%283%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/73/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%284%29.jpg'
] WHERE "Id" = 32;

-- ID 33: Halesi Mahadev (was showing Pathibhara images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/d/d9/Haleshi_Mahadevsthaan%2CKhotang_%281%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7b/Haleshi_Mahadevsthaan%2CKhotang_%282%29.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/5/5b/Haleshi_Mahadevsthaan%2CKhotang_%283%29.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/f/f8/Khotang_Halesi_Temple_and_Cave.jpg'
] WHERE "Id" = 33;

-- ID 36: Rato Machhindranath Temple (was showing generic Patan Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/f/fe/Rato_Machchhindranath_Mandir%2C_Patan.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/0b/Rato_Machhindranath_Temple%2C_Patan%2C_Lalitpur_01.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/8/83/Rato_Machhindranath_Temple%2C_Patan%2C_Lalitpur_02.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/e/e2/Rato_Machhindranath_Temple%2C_Patan%2C_Lalitpur_03.jpg'
] WHERE "Id" = 36;

-- ID 37: Nuwakot Palace (was showing Manakamana images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/9/91/Nuwakot_Durbar.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/6/62/Nuwakot_Palace.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/e/e6/Nuwakot_Darbar.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/f/f1/Nuwakot_Durbar_before_Earthquake_2015.jpg'
] WHERE "Id" = 37;

-- ID 39: Tribhuvan Museum (was showing Pashupatinath images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/6/69/Historic_Pagoda_Style_Architecture_in_Kathmandu_Durbar_Square-IMG_4069.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/4/48/Basantapurdurbarsquare.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/5/52/Durbar_Square_Kathmandu_2013.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/06/Hanuman_Dhoka_Durbar_Square.jpg'
] WHERE "Id" = 39;

-- ID 41: Doleshwar Mahadev (was showing Bhaktapur Durbar Square)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/8/89/Doleshwar_Mahadev.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/1/15/Doleshor_Mahadev.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/2/22/Doleshor.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/3b/Doleshwor_mahadev_%28Nepal%29_23_53_05_793000.jpeg'
] WHERE "Id" = 41;

-- ID 42: Kumari Ghar (now shows specific Kumari Bahal images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/d/da/Kathmandu-14-Haus_der_Kumari-1976-gje.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/a3/Architectural_Detail_-_Kumari_Bahal_-_Durbar_Square_-_Kathmandu_-_Nepal_%2813443741985%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7b/Napatsingh_Devta_Kumari_Ghar_Basantapur_Kathmandu_Nepal_Rajesh_Dhungana.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/8/81/Napatsingh_Devta_Kumari_Ghar_Basantapur_Kathmandu_Nepal_Rajesh_Dhungana1.jpg'
] WHERE "Id" = 42;

-- ID 43: Kopan Monastery (was showing Namobuddha images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/f/f3/Kopan_Monastery.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/5/5c/Kopan_Monastery%2C_Kathmandu.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/c/cb/Kopan_Monastery_Main_Gompa.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/33/Kopan_Monastery_-nepal_%2832000024301%29.jpg'
] WHERE "Id" = 43;

-- ID 44: Shechen Monastery (was showing Boudhanath images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/c/cf/Shechen_Monastery%2C_Nepal.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b1/Shechen_Monastery_4-May-2016.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Boudhanath_Stupa_1.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/e/e0/Blue_sky_and_Boudhanath_Stupa.jpg'
] WHERE "Id" = 44;

-- ID 45: Phewa Lake Barahi Temple (was showing Manakamana images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/d/d4/Barahi_Island_Temple%2C_Phewa_Lake%2C_Pokhara%2C_Nepal.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/a/a0/Barahi_mandir_Pokhara.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7b/Barahi_island_Temple.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/f/fb/Barahi_Temple.jpg'
] WHERE "Id" = 45;

-- ID 47: Lumbini Museum (was showing mixed wrong images)
UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/9/97/Lumbini_Museum.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/c/c3/Maya_Devi_temple-Nepal.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/9/96/Maya_Devi_Temple_with_Monks.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/08/World_Peace_Pagoda_Lumbini%2C_Nepal.jpg'
] WHERE "Id" = 47;


-- ── SEED STORIES ────────────────────────────────────────────

INSERT INTO "Stories" ("CulturalSiteId","Title","StoryType","EstimatedReadTimeMinutes","FullContent","HistoricalContext","CulturalSignificance","ImageUrls","CreatedAt","UpdatedAt") VALUES

-- 1: Pashupatinath
(1, 'The Sacred Lord of All Living Beings', 'Legend', 5,
'Pashupatinath Temple is one of the most sacred Hindu temples in the world and the holiest shrine of the Hindu god Shiva in Nepal. Situated on the banks of the Bagmati River, the main temple was built in the 5th century CE in the Nepalese pagoda style, though the site itself is believed to be far older. The name Pashupatinath means "Lord of all Animals" — Pashupati being one of the most revered forms of Shiva. Every year, hundreds of thousands of Hindu pilgrims travel from across Nepal, India, and the world to bathe in the Bagmati, pray at the main shrine, and witness the sacred cremation ghats that line the river. The eternal flame at the inner sanctum has reportedly burned without interruption for centuries. During the Shivaratri festival, the temple grounds fill with sadhus and devotees, transforming the entire complex into a pulsing centre of devotion.',
'The site dates back at least to the 5th century CE. The main temple was built by King Prachanda Dev in 400 CE, though the Pashupati Kshetra (sacred zone) is believed to have been a place of worship for thousands of years before that. In 1979, UNESCO inscribed Pashupatinath and the Kathmandu Valley on the World Heritage List.',
'Pashupatinath is the spiritual heart of Nepal. It is believed that any Hindu who dies in the Pashupati Kshetra achieves moksha — liberation from the cycle of rebirth. The sacred Bagmati ghats are where generations of Nepali royalty were cremated. The temple is also home to hundreds of resident sadhus — holy men who have renounced worldly life.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/3e/Pashupatinath_temple.JPG','https://upload.wikimedia.org/wikipedia/commons/d/d3/Pashupati_Kshetra_1.jpg','https://upload.wikimedia.org/wikipedia/commons/3/32/Bagmati_River_and_Pashupatinath.jpg'],
NOW(), NOW()),

-- 2: Swayambhunath
(2, 'The Self-Arisen Stupa on the Hill of Eternal Light', 'Legend', 4,
'Swayambhunath, popularly known as the Monkey Temple, rises dramatically from a hill in the western part of Kathmandu Valley. According to the Swayambhu Purana, the entire valley was once a primordial lake, and the lotus that grew from its centre miraculously transformed into a blazing hill — the self-arisen (Swayambhu) sacred light. It is one of the oldest religious sites in Nepal, with a history stretching back over 2,500 years. The all-seeing eyes of the Buddha painted on all four sides of the main stupa gaze outward across the valley, a quintessential symbol of Nepali Buddhist art. The site is sacred to both Buddhists and Hindus, with numerous smaller shrines, chapels, and vajra symbols surrounding the main stupa. A long staircase of 365 steps — one for each day of the year — leads up the forested hill, lined with carved stone animals and prayer wheels that worshippers spin as they climb.',
'The site is believed to have been founded by the grandfather of Emperor Ashoka in the 3rd century BCE. The great stupa was enlarged and renovated by various rulers including King Vrsadeva in the 5th century CE. It received special attention and endowments from the Licchavi rulers of the valley and later from the Malla kings.',
'Swayambhunath is one of the most sacred pilgrimage sites for Tibetan and Newar Buddhists. The stupa is circumambulated clockwise by devotees who spin the 108 prayer wheels as they walk. The site brings together diverse Buddhist traditions and is also revered by Hindus who worship at shrines to Saraswati and other deities within the complex.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/3/31/Swayambhunath_Stupa_as_seen_from_Dharahara.JPG','https://upload.wikimedia.org/wikipedia/commons/9/9d/Eyes_of_swayambunath_stupa.jpg','https://upload.wikimedia.org/wikipedia/commons/1/18/Closeup_detail_on_Swayambhunath_with_8_buddhas.jpg'],
NOW(), NOW()),

-- 3: Boudhanath
(3, 'The Great Mandala That Anchors the Valley', 'History', 5,
'Boudhanath Stupa is one of the largest stupas in the world and the focal point of Tibetan Buddhism in Nepal. Its massive white dome rises 36 metres above the flat Kathmandu Valley floor, visible from miles away. The stupa is built on an ancient trade route from Tibet to India, and for centuries it served as a resting and prayer stop for Tibetan merchants and pilgrims making the long journey south. After the Chinese occupation of Tibet in 1950, thousands of Tibetan refugees settled in the area around Boudhanath, and today more than 50 Tibetan monasteries (gompas) line the streets surrounding the stupa. Every evening at dusk, monks and laypeople alike walk the kora — the circular circumambulation route — spinning prayer wheels and chanting, creating a continuous river of devotion around the massive mandala of the stupa. The eyes of the Buddha painted on all four faces of the spire are said to see in all directions simultaneously, watching over the valley and its people.',
'Boudhanath was built around the 5th century CE, though some Tibetan texts place its origin even earlier. The stupa underwent major reconstructions, particularly after damage from the 2015 Gorkha earthquake, which dislodged the upper spire. Restoration was completed in 2016, and the rebuilt stupa was consecrated in a ceremony attended by thousands of Tibetan Buddhist monks.',
'Boudhanath is inscribed as a UNESCO World Heritage Site and is the most important Tibetan Buddhist shrine outside Tibet. It is not just a monument but a living community — the surrounding streets are full of monasteries, thangka painting workshops, and meditation centres. The full moon days and Tibetan New Year (Losar) bring enormous gatherings of worshippers to the kora.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/c/c1/Boudhanath_Stupa_1.JPG','https://upload.wikimedia.org/wikipedia/commons/4/43/Majestic_Boudhanath.JPG','https://upload.wikimedia.org/wikipedia/commons/e/e0/Blue_sky_and_Boudhanath_Stupa.jpg'],
NOW(), NOW()),

-- 4: Bhaktapur Durbar Square
(4, 'The City of Devotees Frozen in Time', 'Architecture', 6,
'Bhaktapur Durbar Square is perhaps the best preserved of the three historic Durbar Squares in the Kathmandu Valley, often described as an open-air museum of medieval Newar architecture. The city of Bhaktapur — whose name means "City of Devotees" — reached its greatest artistic and architectural peak during the Malla period (12th to 18th centuries), and the Square bears testament to that golden age with its extraordinary collection of palaces, temples, courtyards, and sculptures. The centrepiece is the 55-Window Palace, a royal residence whose intricately carved peacock window is considered one of the finest examples of wood carving in the world. The Nyatapola Temple, standing five stories at 30 metres, is the tallest pagoda temple in Nepal and has stood without serious damage through multiple earthquakes. Bhaktapur was devastated by the 2015 earthquake, but the city rallied in a remarkable restoration effort that has preserved much of the historic fabric.',
'Bhaktapur was founded in the 12th century CE by King Ananda Malla and served as the capital of the unified Malla kingdom before the valley split into three city-states. From 1482 to 1769, it was the capital of its own independent Malla principality. After the conquest by Prithvi Narayan Shah in 1769, Bhaktapur declined in political importance but retained its cultural and religious vitality.',
'Bhaktapur is a living city rather than a dead monument — the streets are still inhabited by Newars who follow ancient occupational and religious traditions. The city is famous for its pottery quarter, its thangka paintings, and its own unique yoghurt (Juju Dhau — the King of Yoghurts). Bisket Jatra, the Bhaktapur New Year festival, is one of the most spectacular festivals in Nepal.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/4/42/A_brief_view_of_Bhaktapur_Durbar_Square.JPG','https://upload.wikimedia.org/wikipedia/commons/2/2d/Bhaktapur_Durbar_Square_Silhouette.JPG','https://upload.wikimedia.org/wikipedia/commons/9/9f/Bhaktapur_Durbar_Square_041224_155.jpg'],
NOW(), NOW()),

-- 5: Patan Durbar Square
(5, 'The City of Fine Arts and a Thousand Courtyards', 'Architecture', 5,
'Patan — also known as Lalitpur, the City of Fine Arts — contains one of the most refined concentrations of Newar art and architecture anywhere in the world. Its Durbar Square is a masterpiece of medieval civic planning, with temples, palaces, and public fountains arranged around a central courtyard with an elegance that speaks of centuries of artistic refinement. The Royal Palace of the Malla kings occupies the eastern side of the square, fronted by the ornate Golden Gate (Sun Dhoka) — a gilded torana considered the supreme example of metal work in Nepal. Patan is home to more courtyards (bahals) than any other city in Nepal, each one a neighbourhood temple complex maintained by the Newar Buddhist community. The city is also the centre of the living goddess tradition, with its own Kumari residing near the Durbar Square.',
'Patan is one of the oldest cities in Nepal, with some legends placing its founding in the 3rd century BCE by Emperor Ashoka, who is said to have built the four Ashoka Stupas that still stand at the four cardinal points of the old city. During the Malla period, Patan was the capital of its own principality and a major centre of Buddhist scholarship and art. Craftsmen from Patan were sent to Tibet and China to build temples and cast statues.',
'Patan''s Newar craftsmen are renowned throughout the Himalayan Buddhist world for their skills in bronze casting, repoussé metalwork, stone carving, and wood carving. The Patan Museum, housed in the old Royal Palace, is considered one of the finest museums in South Asia for the quality and presentation of its Hindu and Buddhist artefacts.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/8/8c/Patan_Durbar_Square_%28136%29.JPG','https://upload.wikimedia.org/wikipedia/commons/5/55/Panoroma_of_Patan_durbar_Square.jpg','https://upload.wikimedia.org/wikipedia/commons/f/ff/Patan_Durbar_Square_01.jpg'],
NOW(), NOW()),

-- 6: Kathmandu Durbar Square
(6, 'The Ancient Heart of the Kingdom', 'History', 5,
'Kathmandu Durbar Square — also called Hanuman Dhoka Durbar Square — was the royal palace complex of the Malla kings and later the early Shah kings who unified Nepal. At its centre stands the Hanuman Dhoka Palace, named after the stone statue of the monkey god Hanuman that guards the main gate, draped in a red cloak and an umbrella to protect him from the elements. The square is an extraordinary layering of history: temples and statues built across a span of five centuries crowd together, some leaning at odd angles from earthquake damage, others freshly restored, creating a living palimpsest of the city''s royal and religious past. The Taleju Temple, the tallest structure in the old city, was built in 1564 and was so sacred that only the king and a few priests were permitted to enter. The square suffered serious damage in the 2015 earthquake but has been extensively repaired.',
'The palace complex was built progressively from the 12th to the 18th centuries by the Malla kings. After Prithvi Narayan Shah conquered Kathmandu in 1769, he continued to use Hanuman Dhoka as his seat until the new Narayanhiti Palace was built in the 19th century. The old palace buildings are now a museum complex.',
'Kathmandu Durbar Square remains the ceremonial and spiritual centre of the capital. The living goddess Kumari resides in the adjacent Kumari Ghar and makes rare public appearances during festivals. The square is the main gathering point for major national festivals including Indra Jatra, when the Kumari is taken out in a chariot procession through the old city.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/d9/Kathmandu_Durbar_Square%2C_Nepal.JPG','https://upload.wikimedia.org/wikipedia/commons/c/c9/Kathmandu_Durbar_Square20180908_110033.jpg','https://upload.wikimedia.org/wikipedia/commons/0/06/Hanuman_Dhoka_Durbar_Square.jpg'],
NOW(), NOW()),

-- 7: Lumbini
(7, 'The Garden Where the Buddha Was Born', 'History', 6,
'Lumbini is the birthplace of Siddhartha Gautama, who became the historical Buddha — the awakened one whose teachings of compassion and the middle path gave rise to one of the world''s great religions. The sacred garden in what is now southern Nepal has been a pilgrimage destination for Buddhists for over 2,500 years. At its centre stands the Maya Devi Temple, built over the exact spot where Queen Maya Devi is said to have given birth to the prince while grasping the branch of a sal tree. Inside the temple, an ancient stone relief depicting the nativity scene and the Marker Stone, bearing an Ashokan inscription confirming this as the birthplace, are among the most sacred objects in the Buddhist world. Emperor Ashoka visited Lumbini in 249 BCE and erected a pillar inscribed with a record of his visit — the pillar still stands today, cracked by a lightning strike in the 14th century. Surrounding the Maya Devi Temple is a vast sacred garden being developed into an international pilgrimage and peace site, with monasteries built by Buddhist nations from around the world.',
'The site was identified by the Nepali and German archaeologists in 1896 through the discovery of the Ashokan pillar with its clearly legible inscription marking Lumbini as the birth site. Excavations beneath the Maya Devi Temple have revealed foundations of earlier structures dating back to the 3rd century BCE and possibly earlier. UNESCO inscribed Lumbini as a World Heritage Site in 1997.',
'For 500 million Buddhists worldwide, Lumbini holds a significance equivalent to Bethlehem for Christians and Mecca for Muslims. Pilgrims from Sri Lanka, Japan, China, Korea, Thailand, Myanmar, and Tibet all maintain monasteries within the Lumbini development zone. The Eternal Peace Flame near the Maya Devi Temple was lit in 1986 and has not been extinguished since.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/c/c3/Maya_Devi_temple-Nepal.JPG','https://upload.wikimedia.org/wikipedia/commons/9/96/Maya_Devi_Temple_with_Monks.jpg','https://upload.wikimedia.org/wikipedia/commons/0/08/World_Peace_Pagoda_Lumbini%2C_Nepal.jpg'],
NOW(), NOW()),

-- 8: Changu Narayan
(8, 'Nepal''s Oldest Standing Temple', 'Architecture', 4,
'Changu Narayan Temple, perched atop a wooded hilltop east of Bhaktapur, holds the distinction of being the oldest surviving temple in Nepal. Dedicated to Vishnu in his manifestation as Narayan, the temple site dates back to at least the 4th century CE, making it a living witness to fifteen centuries of Nepali art and religious life. The complex is extraordinary for the density and quality of its stone sculptures — carved figures of Vishnu in his ten avatars, the dual-image Vishnu Vikrantha striding across the three worlds, and a magnificent 5th-century Vishnu as Vishwaroopa are among the finest pieces of early Nepalese sculpture in existence. The temple''s double-roofed pagoda structure is typical of Newar architecture, but the woodwork, metalwork, and stone carvings here represent the absolute peak of the form. The site also preserves the oldest stone inscription in Nepal, dating to 464 CE, recording the deeds of King Manadeva.',
'The temple was built in the 4th century CE, possibly earlier, and has been expanded and renovated by successive rulers. The oldest inscription on the site records that King Manadeva had victories over neighbouring kingdoms. The temple was damaged in the 2015 earthquake and underwent significant restoration.',
'Changu Narayan is a UNESCO World Heritage Site and a pilgrimage destination for Vaishnavas (devotees of Vishnu) across Nepal. The hilltop location gives it a commanding view across the valley and a sense of serene remoteness despite its proximity to Bhaktapur. The surrounding village of Changu maintains traditional Newar life with pottery, thangka painting, and farming.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/6/68/Changunarayan_Temple%2C_Bhaktapur.JPG','https://upload.wikimedia.org/wikipedia/commons/1/14/Gate_at_Changu_Narayan.jpg','https://upload.wikimedia.org/wikipedia/commons/4/49/Stone_statue_at_Changunarayan_temple.jpg'],
NOW(), NOW()),

-- 9: Manakamana
(9, 'The Goddess Who Grants the Wishes of the Heart', 'Legend', 4,
'Manakamana Temple is one of the most beloved pilgrimage sites in Nepal, dedicated to the goddess Bhagwati — an incarnation of Parvati, consort of Shiva — who is believed to grant the heartfelt wishes (mana kamana, literally "wish of the heart") of all who come to her. The temple sits at an elevation of 1,302 metres on a ridge in Gorkha district, commanding sweeping views across the Marsyangdi valley and the Himalayan peaks beyond. For most of its history, reaching the goddess required a strenuous three-hour climb on foot. Since 1998, a cable car has connected the temple to the valley floor below, making it accessible to hundreds of thousands of pilgrims each year. The sacrifice of goats and chickens before the goddess remains a central part of the pilgrimage ritual — the blood offering is an ancient practice of devotion and petition that continues largely unchanged. New couples, new parents, and people seeking good fortune in new endeavours are the most common pilgrims.',
'The temple was established in the 17th century CE. Legend holds that a holy man named Lakhan Thapa Magar discovered the power of the goddess here after she appeared to him in a vision. The temple was built by the royal family of Gorkha. The site gained further significance when the Shah dynasty — who later unified Nepal — were from Gorkha and considered Manakamana one of their protective goddesses.',
'Manakamana is one of the most visited religious sites in Nepal outside the Kathmandu Valley. The cable car, the first in Nepal, was built specifically to serve the pilgrimage. On auspicious days and during Dashain festival, queues of hundreds of devotees line up for the 10-minute cable car ride to the goddess. The views of the Himalaya from the temple courtyard — including Manaslu and the Annapurna massif — add a transcendent backdrop to the act of worship.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/e/e6/Gorkha_Manakamana_Temple.jpg','https://upload.wikimedia.org/wikipedia/commons/c/c7/Manakamana_Cablecar_IMG_1593.jpg','https://upload.wikimedia.org/wikipedia/commons/a/aa/Manakamana_Temple_Mankamana_Gorkha_Nepal_Rajesh_Dhungana_%282%29.jpg'],
NOW(), NOW()),

-- 10: Muktinath
(10, 'Where Fire Burns From Water and Earth', 'Legend', 5,
'Muktinath is one of the most extraordinary religious sites in the Himalayan world — a high-altitude temple complex at 3,710 metres in the Mustang district where both Hindus and Tibetan Buddhists venerate the same sacred place, each in their own tradition. Hindus know it as Muktinath, the place of liberation (mukti), one of the 108 Divya Desams of Vishnu. Buddhists call it Chumig Gyatsa (Hundred Waters), a holy Dakini site. What makes Muktinath truly miraculous in the religious sense is the presence of natural eternal flames — fires that burn from the rock fed by natural gas seeps — alongside springs of water and earthen ground, representing the conjunction of fire, water, and earth in one location. A famous Jwala Mai (Flame Mother) shrine marks the point where a small eternal flame has burned for centuries beside a spring. The 108 stone water spouts shaped like bull heads, arranged in a semi-circle, pour sacred water over pilgrims seeking purification and liberation.',
'Muktinath has been a sacred site for thousands of years, situated on the ancient salt trade route between Nepal and Tibet. The Vishnu temple was given royal patronage by the Shah kings, and the site was visited by important Hindu saints. For Tibetan Buddhists, the Saligram fossils (ammonites) found in the Kali Gandaki river bed nearby are sacred objects associated with Vishnu.',
'The pilgrimage to Muktinath is considered one of the most meritorious in the Hindu tradition. Bathing in the 108 spouts is believed to wash away all sin and bring the soul closer to moksha. The site''s altitude, remoteness, and the extraordinary natural phenomena of eternal flame and sacred water create a sense of otherworldly holiness that draws pilgrims willing to travel days to reach it.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/2/27/Muktinath_Temple%2C_Mustang%2C_Nepal.JPG','https://upload.wikimedia.org/wikipedia/commons/0/02/Vishnu_temple_at_Muktinath_%28Chumig_Gyatsa%29_%284523384084%29.jpg','https://upload.wikimedia.org/wikipedia/commons/5/5e/Stupa_in_muktinath.jpg'],
NOW(), NOW()),

-- 21: Taleju Temple
(21, 'The Goddess Who Spoke Only to Kings', 'Legend', 4,
'Taleju Bhawani is the royal deity of the Malla kings, a goddess so sacred that entry to her main temple within Kathmandu Durbar Square was forbidden to everyone except the reigning king and a small number of priests for most of its history. The temple was built in 1564 CE by King Mahendra Malla and at the time of its construction was the tallest structure in the valley — a deliberate statement of royal devotion and power. Standing at the northeast corner of Hanuman Dhoka Palace, the three-storey pagoda rises dramatically above the surrounding roofline. According to legend, Taleju originally took the form of a beautiful woman who appeared nightly to the king to teach him statecraft and spiritual wisdom, demanding absolute secrecy. When the king broke this vow by boasting of her visits, the goddess departed — but relented when the king begged her forgiveness, agreeing to return only in the form of the young Kumari, the living goddess who now resides in the adjacent Kumari Ghar.',
'The Taleju cult was brought to Nepal from South India by the Malla kings in the 14th century and became the state deity across all three Malla city-states. The Taleju temple in Bhaktapur was built in 1553, the one in Patan in 1667, and the one in Kathmandu in 1564. The goddess''s connection to the Kumari tradition shows the syncretic nature of Newar religion, blending Hindu and Buddhist elements.',
'Taleju temple is open to the general public only once a year during the Dashain festival — specifically on the day of Phulpati, when thousands of worshippers line up for a brief glimpse inside. For the rest of the year, only the hereditary priests may enter the inner sanctum to perform daily rites.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/59/05._Taleju_temple.jpg','https://upload.wikimedia.org/wikipedia/commons/a/ab/A_trip_to_basantaput_durbar_square_04.jpg','https://upload.wikimedia.org/wikipedia/commons/a/a6/Kathmandu_Taleju_Temple.jpg'],
NOW(), NOW()),

-- 25: Golden Temple Patan
(25, 'The Hidden Gold of Patan''s Buddhist Heart', 'Architecture', 4,
'The Golden Temple — Hiranya Varna Mahavihar, meaning "Golden Coloured Monastery" in Sanskrit — is a three-storey gilded Buddhist monastery tucked into a narrow street north of Patan Durbar Square. From the outside, its golden facade is invisible; visitors pass through an inconspicuous doorway into a courtyard that suddenly reveals itself as one of the most ornate sacred spaces in Nepal. The entire front of the main shrine building is covered in gleaming gold repoussé metalwork — intricate panels depicting the life of the Buddha, guardian deities, and sacred symbols layered over every surface. In the centre of the courtyard stands a small shrine to Sakyamuni Buddha, and a living rat who scurries freely through the temple complex is revered as a sacred creature. The monastery, still an active religious institution, is maintained by the Shaky community — the hereditary craftsmen who have been its custodians for a thousand years.',
'The Golden Temple was founded by King Bhaskar Varma in the 12th century CE. A continuous programme of ritual use and artistic embellishment over nine centuries has produced the extraordinary density of decoration visible today. The metal artisans who created the gold work were from the Shakya community — the same caste group to which the historical Buddha Siddhartha Gautama belonged.',
'The Golden Temple is a functioning Buddhist monastery, not merely a museum piece. Morning and evening rituals are performed daily. Boys from the Shakya community are required to spend a period in residence as novice monks — a tradition that has continued for generations. The courtyard''s atmosphere, caught between mundane city life outside and intense sacredness within, is characteristic of Patan''s living Buddhist culture.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/f/f6/Hiranya_Varna_Mahavihar_Main_Temple.jpg','https://upload.wikimedia.org/wikipedia/commons/9/93/Golden_Temple_%28Hiranya_Varna_Mahavihar%29.jpg','https://upload.wikimedia.org/wikipedia/commons/a/a8/Hiranya_Varna_Mahavihar%2C_Patan.jpg'],
NOW(), NOW()),

-- 26: Mahaboudha Temple
(26, 'Ten Thousand Buddhas in One Tower', 'Architecture', 3,
'The Mahabouddha Temple in Patan is unlike any other temple in Nepal: a soaring single tower built entirely of terracotta bricks, every brick bearing the image of the Buddha, so that the entire structure is a single continuous act of devotion multiplied ten thousand times. Inspired by the Mahabodhi Temple in Bodh Gaya, India — the site of the Buddha''s enlightenment — this Patan replica was built in the 16th century by a local architect-pilgrim who spent years in India studying the original before returning to recreate it in his home city. The tower is squeezed into a narrow courtyard in the old city, surrounded so tightly by the walls of neighbouring buildings that to photograph the full height you must press yourself against the far wall and tilt the camera. The 2015 earthquake badly damaged the structure, but it was carefully restored using the original bricks, with the leftover bricks used to build a smaller shrine to Maya Devi beside it.',
'Built in the 16th century CE by Abhaya Raj, a Patan resident who had made a pilgrimage to Bodh Gaya in India, the temple is a rare example of a North Indian shikhara-style tower within the otherwise pagoda-dominated Newar architectural landscape. The restoration after the 2015 earthquake was led by heritage architects who catalogued and numbered each brick before disassembly.',
'Mahabouddha represents the tradition of religious pilgrimage and replication common in the Buddhist world — the idea that recreating a sacred site enables those who cannot travel far to gain merit from proximity to the form of the original. It stands as testimony to the depth of Buddhist devotion in the Patan craftsman community.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/0/0a/Mahaboudha_%289651389724%29.jpg','https://upload.wikimedia.org/wikipedia/commons/7/7e/Mahabouddha_Mandir%2C_Patan%2C_Lalitpur%2C_Nepal_04.jpg','https://upload.wikimedia.org/wikipedia/commons/1/13/Mahabuddha_temple%2C_Patan_IMG_2869_%2818389840460%29.jpg'],
NOW(), NOW()),

-- 27: Bindabasini Temple
(27, 'The Mountain Goddess Above the Lake City', 'Cultural', 3,
'Bindabasini Temple is the most important Hindu temple in Pokhara, dedicated to Bhagwati — a fierce form of the goddess Durga. Situated on a hill in the old Pokhara bazaar, the temple offers panoramic views of the Pokhara valley, Phewa Lake, and the Annapurna Himalayan range on clear days. The goddess Bindabasini is believed to be the protective deity of Pokhara and its surrounding region. Every day, local devotees climb the hill to offer flowers, incense, and prayers, and the temple courtyard fills with the sound of bells and drums during religious festivals. During the major Hindu festivals of Dashain and Tihar, the temple is the spiritual centre of the entire city, drawing thousands of worshippers from across the region. The temple complex includes shrines to other deities and a series of smaller temples on the approach path.',
'The temple is believed to have been established several centuries ago, though the current structure dates to the 19th century. Pokhara was a significant trading post on the Tibetan salt trade route, and the goddess Bindabasini was venerated by the merchant communities who sought her protection for their journeys across the Himalayan passes.',
'Bindabasini is not merely a landmark but an active centre of community religious life. The weekly market day and major festivals are oriented around the temple. For the Gurung, Magar, and Brahmin communities of the region, the goddess is a living presence in daily life rather than a historical artifact.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/7/71/Bindabashini_Temple_01.JPG','https://upload.wikimedia.org/wikipedia/commons/9/94/Bindabashini_Temple_02.JPG','https://upload.wikimedia.org/wikipedia/commons/1/14/Bindabasini_temple.jpg'],
NOW(), NOW()),

-- 28: Tal Barahi Temple
(28, 'The Island Temple on the Sacred Lake', 'Legend', 3,
'Tal Barahi Temple sits on a small island in the middle of Phewa Lake, Pokhara''s iconic lake with the Annapurna Himalaya as its backdrop. Dedicated to Barahi — a two-armed goddess holding a lotus and a cup, a tantric form of Durga — the small two-storey pagoda temple is reached only by wooden rowing boats from the lakeside. The combination of the island setting, the mirror reflection of the Himalaya in the lake, and the sound of temple bells drifting across the water makes the approach to Tal Barahi one of the most evocative religious experiences in Nepal. Devotees come to make offerings and petitions to the goddess, particularly on Saturdays when the temple is busiest. The waters of Phewa Lake are considered sacred, and many pilgrims take the boat trip to the temple as both an act of devotion and a moment of contemplation in one of Nepal''s most beautiful natural settings.',
'The temple was established by the ruler of Kaski kingdom, of which Pokhara was the principal city before the unification of Nepal. The Barahi goddess is the principal deity of the former Kaski kingdom and continues to be venerated as the protector of the Pokhara region.',
'Tal Barahi is unique in Nepal for being an actively worshipped island temple accessible only by boat. The setting on Phewa Lake has made it one of the most photographed temples in the country, but it remains first and foremost a place of active religious practice rather than a tourist attraction.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/d4/Barahi_Island_Temple%2C_Phewa_Lake%2C_Pokhara%2C_Nepal.JPG','https://upload.wikimedia.org/wikipedia/commons/4/4f/Tal_Barahi_Temple.jpg','https://upload.wikimedia.org/wikipedia/commons/e/e5/Phewa_Lake_and_Taal_Barahi_Temple.jpg'],
NOW(), NOW()),

-- 31: Indreshwar Mahadev
(31, 'The Three-Roofed Guardian of the Confluence Town', 'Architecture', 4,
'Indreshwar Mahadev Temple in Panauti is believed to be the oldest surviving triple-roofed pagoda temple in Nepal, standing as it has for seven centuries at the sacred confluence (trisuli) of the Roshi and Punyamati rivers. Panauti is a small medieval town in Kavrepalanchok district, less visited than the Kathmandu Valley Durbar Squares but arguably more atmospheric — its streets, bahal courtyards, and ghats retain an authenticity that the more famous sites have sometimes lost to tourism. The Indreshwar temple, dedicated to Shiva in his form as the lord of the gods (Indreshwar — lord of Indra), rises three stories to a height of around 20 metres and is considered an architectural masterpiece. The carved wooden struts, doorways, and window screens are among the finest examples of medieval Newar woodwork, depicting deities, erotic carvings (believed to ward off lightning), and guardian figures in extraordinary detail. The festival of Makar Mela, held every 12 years at the Panauti confluence, draws hundreds of thousands of pilgrims.',
'The temple was built in 1294 CE — the oldest verifiable date for any standing pagoda temple in Nepal. It survived the devastating earthquake of 1988, which destroyed much of Panauti, largely intact. The 2015 earthquake also spared the main structure, although some subsidiary shrines were damaged. The temple has been the subject of extensive conservation work by international heritage organisations.',
'Panauti''s trisuli (triple river confluence) is considered especially sacred in the Hindu tradition, and bathing at the confluence is believed to cleanse sins. The town''s preservation of medieval urban form, with its stone-paved lanes, stepped water spouts (dhunge dhara), and intact bahal courtyards, makes it one of the most valuable heritage townscapes in Nepal.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/a/ad/Indreshower_Temple%2C_Panauti.JPG','https://upload.wikimedia.org/wikipedia/commons/7/70/Indreswor_Temple_Panauti_IMG_1155_01.jpg','https://upload.wikimedia.org/wikipedia/commons/b/bf/Indreswor_Temple_Panauti_IMG_1155_04.jpg'],
NOW(), NOW()),

-- 33: Halesi Mahadev
(33, 'The Himalayan Cave Revered by Three Faiths', 'Legend', 5,
'Halesi Mahadev — also known as Maratika — is a complex of sacred caves in the Khotang district of eastern Nepal, revered simultaneously by Hindus as one of the jyotirlinga sites of Shiva, by Tibetan Buddhists as a sacred cave where Guru Rinpoche (Padmasambhava) achieved immortality, and by local Rai and Limbu communities as an ancestral sacred place. This convergence of three distinct religious traditions at a single site is extraordinary and speaks to the deep antiquity of the location''s spiritual power. The main cave is large enough to hold hundreds of worshippers and is entered through a natural rock arch. Inside, a Shivalinga is the central object of Hindu veneration, while Tibetan Buddhist pilgrims circumambulate specific formations within the cave believed to represent the deity Amitayus (Boundless Life). The surrounding landscape is deeply forested and the approach, which was historically a difficult mountain journey, adds to the sense of pilgrimage.',
'Buddhist tradition holds that Guru Rinpoche came to the Halesi caves in the 8th century CE and performed the longevity practice that allowed him to transcend death. Hindu tradition identifies the site with one of the sacred jyotirlingas — the self-manifested light forms of Shiva — though it is not among the 12 canonical jyotirlingas of India. Local Rai shamanistic traditions have their own narratives of the cave as a place of ancestral spirits.',
'Halesi exemplifies the religious syncretism characteristic of Nepali culture, where the same physical space is inhabited by multiple faith traditions without conflict. Major pilgrimage seasons draw Hindus at Hindu festival dates and Tibetan Buddhist pilgrims at Tibetan calendar dates, with the cave hosting both communities in turn.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/d9/Haleshi_Mahadevsthaan%2CKhotang_%281%29.jpg','https://upload.wikimedia.org/wikipedia/commons/7/7b/Haleshi_Mahadevsthaan%2CKhotang_%282%29.JPG','https://upload.wikimedia.org/wikipedia/commons/f/f8/Khotang_Halesi_Temple_and_Cave.jpg'],
NOW(), NOW()),

-- 36: Rato Machhindranath
(36, 'The Rain-Bringer and the Longest Festival in the World', 'Festival', 5,
'Rato Machhindranath is the rain god and harvest deity most revered in the Kathmandu Valley, particularly among the Newar community of Patan. His annual chariot festival — the Rato Machhindranath Jatra — is believed to be the longest chariot festival in the world, lasting for months as a towering four-wheeled chariot built fresh each year is dragged through the streets of Patan by hundreds of devotees. The chariot, which stands around 18 metres tall and is constructed entirely of wood, bamboo, and sacred materials without a single nail, is a feat of traditional engineering rebuilt entirely from scratch each year by hereditary craftsmen. On the final day, the Bhoto Jatra ceremony reveals a jewelled vest of unknown origin, a ceremony once witnessed by the king of Nepal and now presided over by the President. The festival is not merely spectacle but a deeply held act of collective petition: Rato Machhindranath must be appeased and honoured to ensure adequate monsoon rains and a good harvest.',
'Rato Machhindranath is a syncretic deity combining the Hindu Machhindranath with the Buddhist bodhisattva Avalokitesvara (Karunamaya). The tradition of the chariot festival is believed to date back to the reign of the Licchavi king Narendra Deva in the 7th century CE. Historians identify Machhindranath with Gorakhnath''s guru in the tantric tradition.',
'The Jatra is a community festival in the fullest sense — every neighbourhood in Patan has a designated role in the festival''s organisation, preparation, and execution. The temple at Lagankhel is the god''s permanent residence, and on non-festival days it serves as a neighbourhood shrine for daily puja. The deity is also worshipped as the protector of the entire Bagmati valley from drought.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/f/fe/Rato_Machchhindranath_Mandir%2C_Patan.jpg','https://upload.wikimedia.org/wikipedia/commons/0/0b/Rato_Machhindranath_Temple%2C_Patan%2C_Lalitpur_01.jpg','https://upload.wikimedia.org/wikipedia/commons/8/83/Rato_Machhindranath_Temple%2C_Patan%2C_Lalitpur_02.jpg'],
NOW(), NOW()),

-- 42: Kumari Ghar
(42, 'The Living Goddess Who Is Always a Child', 'Cultural', 5,
'The Kumari Ghar in Kathmandu Durbar Square is the residence of the Royal Kumari — a pre-pubescent girl from the Shakya Buddhist community who is selected through an elaborate series of rituals to be the living incarnation of the goddess Taleju. The selection process involves testing 32 physical attributes, observing the girl''s calm in the presence of frightening stimuli including buffalo heads and masked dances, and consulting astrological charts. Once selected, the girl lives in the Kumari Ghar, a richly carved three-storey palace built in 1757, attended by caretakers. She appears at her carved wooden window on special occasions, and devotees — including the President of Nepal — come to receive her blessing (prasad) in the form of a tika (red mark on the forehead). The Kumari''s feet must never touch the ground outside the palace, and she is carried in a palanquin or a golden chariot during the annual Indra Jatra festival when she is taken through the old city in a public procession.',
'The Kumari tradition in Kathmandu is believed to date to the Malla period (15th–18th centuries), when the king required a living divine presence to legitimise his rule. The tradition survived the Shah conquest and continues today as a living religious custom despite Nepal''s transition to a republic in 2008. The Royal Kumari now blesses the head of state rather than the king.',
'The Kumari tradition is one of the most extraordinary living religious practices in the world — a deity who is simultaneously fully divine and fully human, revered and then retired when she reaches puberty and a new Kumari is selected. Former Kumaris return to ordinary life but carry a special social status. The practice has attracted both admiration for its preservation of ancient tradition and debate around the childhood of the girls involved.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/d/da/Kathmandu-14-Haus_der_Kumari-1976-gje.jpg','https://upload.wikimedia.org/wikipedia/commons/a/a3/Architectural_Detail_-_Kumari_Bahal_-_Durbar_Square_-_Kathmandu_-_Nepal_%2813443741985%29.jpg','https://upload.wikimedia.org/wikipedia/commons/7/7b/Napatsingh_Devta_Kumari_Ghar_Basantapur_Kathmandu_Nepal_Rajesh_Dhungana.jpg'],
NOW(), NOW()),

-- 43: Kopan Monastery
(43, 'Where Westerners Came to Find the Dharma', 'History', 4,
'Kopan Monastery, perched on a forested hill north of Kathmandu and Boudhanath, became in the 1970s an unexpected bridge between Tibetan Buddhism and the Western world. Founded by Lama Thubten Yeshe and Lama Zopa Rinpoche, both Tibetan monks who had fled into exile from Chinese-occupied Tibet, Kopan began offering month-long meditation courses that attracted spiritual seekers from Europe, America, and Australia at a time when interest in Eastern philosophy was surging in the West. The monastery was the birthplace of the Foundation for the Preservation of the Mahayana Tradition (FPMT), now one of the largest Tibetan Buddhist organisations in the world with centres in 40 countries. The hilltop location gives sweeping views across the valley to the Boudhanath Stupa and the mountains beyond, and the monastery''s gardens are filled with prayer flags and small shrines. Today it houses around 350 resident monks and continues to offer intensive meditation and study programmes to students from around the world.',
'Kopan was established in 1969 on land donated by a Tibetan nobleman. The first public meditation course was offered in 1971 with just a handful of Western participants — subsequent years saw hundreds of applications. The monastery''s growth reflected the broader Tibetan Buddhist diaspora''s successful transmission of the tradition to a global audience.',
'Kopan represents a remarkable cultural exchange — traditional Tibetan monastic Buddhism transplanted to a hilltop outside Kathmandu and then transmitted outward to students from dozens of countries. The monastery maintains both a full traditional monastic curriculum for Tibetan and Nepali monks and an international programme for lay practitioners.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/f/f3/Kopan_Monastery.jpg','https://upload.wikimedia.org/wikipedia/commons/5/5c/Kopan_Monastery%2C_Kathmandu.JPG','https://upload.wikimedia.org/wikipedia/commons/c/cb/Kopan_Monastery_Main_Gompa.jpg'],
NOW(), NOW()),

-- 9 stories for the remaining sites
-- 34: Kalinchowk
(34, 'The Winter Goddess Above the Clouds', 'Legend', 3,
'Kalinchowk Bhagwati Temple sits at 3,842 metres on the ridge of Kalinchowk mountain in Dolakha district, making it one of the highest Hindu temples in Nepal accessible by road. The goddess Kalinchowk Bhagwati is an aspect of Durga — fierce, powerful, and protective — and her remote high-altitude temple is approached by a chairlift or a steep one-hour hike from the road head. In winter, the mountain is blanketed in snow and the temple surrounded by ice, giving it an atmosphere of extreme sacredness that pilgrims find deeply moving. The views of the Langtang and Rolwaling Himalayan ranges from the summit are extraordinary on clear days. The festival season in winter attracts thousands of devotees who trek through snow to offer prayers to the goddess, their colourful clothing bright against the white landscape.',
'The temple has been a pilgrimage destination for communities of Dolakha and the adjoining districts for centuries. The 2015 earthquake significantly damaged Charikot town below but the mountain temple itself escaped major structural damage. A chairlift installed in 2016 has made the site more accessible.',
'The combination of extreme high altitude, winter snowfields, and the fierce goddess creates a pilgrimage experience felt to be proportionally powerful — the effort and cold of the journey are themselves acts of devotion. Local communities from Dolakha have maintained the temple traditions across generations.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/b/b2/A_view_from_Kalinchok_mountain_Dolakha.jpg','https://upload.wikimedia.org/wikipedia/commons/0/01/Gosaikunda_Lake.jpg','https://upload.wikimedia.org/wikipedia/commons/7/75/Gosainkunda_Nepal.jpg'],
NOW(), NOW()),

-- 37: Nuwakot Palace
(37, 'The Fort That Launched a Kingdom', 'History', 4,
'Nuwakot Palace — Nuwakot Durbar — was one of the most strategically important palaces in Nepali history. Built on a fortified hilltop in Nuwakot district north of Kathmandu, the seven-storey tower palace was captured by Prithvi Narayan Shah in 1744 in his first major military victory on the road to unifying Nepal. The capture of Nuwakot gave him control of the Trisuli valley trade route and access to the resources needed to continue his campaign. The palace became one of his principal residences and he spent many years there directing the unification campaign. The palace''s seven storeys represent an unusual height for Newar architecture, rising from the hillside with views across the Trisuli valley and toward the distant Himalaya. Each storey served a different function — residential, administrative, worship — and the building is decorated with the carved windows and woodwork typical of the finest Malla-period architecture.',
'Nuwakot was captured by Prithvi Narayan Shah in 1744, his first territorial conquest. He issued his famous Dibya Upadesh (Divine Advice) — a political and moral treatise for the governance of Nepal — from Nuwakot. The palace survived centuries of weathering and was badly damaged in the 2015 earthquake but is being restored.',
'Nuwakot represents a less-visited but historically crucial site in the narrative of Nepal''s unification. For students of Nepali history, the palace is directly connected to the founding of the modern Nepali state.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/9/91/Nuwakot_Durbar.jpg','https://upload.wikimedia.org/wikipedia/commons/6/62/Nuwakot_Palace.jpg','https://upload.wikimedia.org/wikipedia/commons/e/e6/Nuwakot_Darbar.jpg'],
NOW(), NOW()),

-- 32: Gorakhnath Temple
(32, 'The Yogi''s Temple at the Heart of the Gorkha Fort', 'Legend', 4,
'Gorakhnath Temple within the Gorkha Durbar complex occupies a position of supreme symbolic importance in the history of Nepal. Gorakhnath is the legendary yogi and guru of the Nath tradition, and the Shah dynasty — the royal family that unified Nepal — considered him their patron deity and founding spiritual ancestor. Prithvi Narayan Shah, before launching his unification campaign, is said to have received the blessing of Gorakhnath in a vision, cementing the connection between the yogi and the kingdom that would bear his name (Gorkha from Gorakhnath). The temple sits within the dramatically situated Gorkha Durbar, a palace and temple complex perched on a steep ridge above Gorkha town. The footprint of the yogi — believed to be supernaturally impressed in rock within the temple — is one of the most sacred objects in the complex.',
'The Gorkha Durbar and its Gorakhnath temple were the ancestral seat of the Shah dynasty before Prithvi Narayan Shah began the conquest of the Kathmandu Valley in 1743. The temple''s connection to the Nath yogi tradition runs deep — Gorkha district takes its name from Gorakhnath, and the Nepali Army''s Gorkhali soldiers worldwide trace their identity partly to this heritage.',
'The Gorakhnath shrine is one of the most important pilgrimage destinations for devotees of the Nath tradition from across South Asia. The Gorkha Durbar offers one of the most evocative views in Nepal — looking south across the Himalayan foothills toward the plains on clear days.',
ARRAY['https://upload.wikimedia.org/wikipedia/commons/5/58/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%281%29.jpg','https://upload.wikimedia.org/wikipedia/commons/4/49/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%282%29.jpg','https://upload.wikimedia.org/wikipedia/commons/0/0f/Gorakhnath_temple_Gorkha_Durbar_Gorkha_Gorkha_District_Nepal_Rajesh_Dhungana_%283%29.jpg'],
NOW(), NOW());
