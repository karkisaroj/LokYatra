-- ============================================================
-- LokYatra: Fix Homestay Images
-- Replace cultural site photos with actual building/house images
-- ============================================================

-- ID 4: Nyatapola Heritage House (Bhaktapur)
-- Traditional Newari brick street and residential architecture
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/f/f9/The_beautiful_streets_of_Bhaktapur%2C_Nepal.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/4/46/Street_of_Bhaktapur.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/3/3d/Bhaktapur_Alley.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7b/Bhaktapur_street_01.JPG'
] WHERE "Id" = 4;

-- ID 5: Boudha Kora Guesthouse (Boudhanath)
-- Newari residential houses around the Boudha area
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/1/1d/Typical_Newari_house_around_Bodhaunath_Stupa.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/79/Traditional_Newari_houses_%2812679274433%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/0/0c/Newari_Dolakhali_House.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/a5/Dharma_man_tuladhar_house.jpg'
] WHERE "Id" = 5;

-- ID 6: Patan Artisan Courtyard Homestay
-- Traditional Newar bahal courtyard and residential buildings
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/a/a0/Janbahal%2C_Kathmandu.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/d/d6/20110726_Jana_Bahal_Temple_Kathmandu_Nepal_5.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/a6/An_old_traditional_House_near_Dattatreya_Temple%2C_Bhaktapur_Durbar_Square%2C_NEPAL_06.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/1/1f/Pati_near_Dattatreya_Temple%2C_Bhaktapur_Durbar_Square%2C_NEPAL_11.jpg'
] WHERE "Id" = 6;

-- ID 7: Swayambhu Hill Retreat
-- Traditional hillside house and Newar village architecture
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/7/70/Traditional_House_in_Nepal.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7a/Traditional_house_in_Charikot.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/e/ea/Nepali_Village_house.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/79/Traditional_Newari_houses_%2812679274433%29.jpg'
] WHERE "Id" = 7;

-- ID 8: Phewa Lakeside Heritage Home (Pokhara)
-- Traditional stone houses and Himalayan highland dwellings
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/f/fc/An_old_women_sitting_at_her_traditional_house_in_Nepal.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/b/b1/Sherpa_House.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/7/70/Traditional_House_in_Nepal.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/4/4d/Tradition_houses_located_at_Mustang%2CNepal.jpg'
] WHERE "Id" = 8;

-- ID 9: Lumbini Sacred Garden Cottage
-- Tharu traditional earthen houses (correct for Lumbini/Terai region)
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/9/9d/Rana_Tharu_House.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/7/7f/Tharu_village.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/e/ea/Nepali_Village_house.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/c/cc/Old_house_seen_in_parbat.JPG'
] WHERE "Id" = 9;

-- ID 10: Changu Village Heritage Stay
-- Traditional Newar rural farmhouse and Nepal village houses
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/c/cc/Old_house_seen_in_parbat.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/7/7a/Traditional_house_in_Charikot.JPG',
  'https://upload.wikimedia.org/wikipedia/commons/7/79/Traditional_Newari_houses_%2812679274433%29.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/e/ea/Nepali_Village_house.jpg'
] WHERE "Id" = 10;

-- ID 11: Bagmati Riverside Heritage Homestay (Pashupatinath)
-- Traditional Newari heritage buildings and old brick houses
UPDATE "Homestays" SET "ImageUrls" = ARRAY[
  'https://upload.wikimedia.org/wikipedia/commons/a/a6/An_old_traditional_House_near_Dattatreya_Temple%2C_Bhaktapur_Durbar_Square%2C_NEPAL_06.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/1/1f/Pati_near_Dattatreya_Temple%2C_Bhaktapur_Durbar_Square%2C_NEPAL_11.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/a/a5/Dharma_man_tuladhar_house.jpg',
  'https://upload.wikimedia.org/wikipedia/commons/f/f9/The_beautiful_streets_of_Bhaktapur%2C_Nepal.jpg'
] WHERE "Id" = 11;
