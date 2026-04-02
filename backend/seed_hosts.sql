-- ============================================================
-- LokYatra: Host User Seed Data
-- Role: owner | Password for all: Host@1234
-- ============================================================

INSERT INTO "User" ("IsActive","Name","Email","PasswordHash","Role","PhoneNumber","ProfileImage","QuizPoints","CreatedAt","UpdatedAt") VALUES
(TRUE,'Bikash Shrestha','bikash.shrestha@gmail.com','AQAAAAIAAYagAAAAEDTRP/mMmkUXoGncvxm+w7vdkAJBjJbZIVCeRHQbwGJ/mUARQLhdg92Wv0JnnEy6nA==','owner','9841234567','',0,NOW(),NOW()),
(TRUE,'Tenzin Lama','tenzin.lama@gmail.com','AQAAAAIAAYagAAAAECRIRQ3tWfnYeQaYOFuGr8NitngTIfgqC3uCRIogg9j7j+lOL6eaugZoqAVWEX562Q==','owner','9852345678','',0,NOW(),NOW()),
(TRUE,'Sarita Maharjan','sarita.maharjan@gmail.com','AQAAAAIAAYagAAAAELo2tlPyHunj/AnR6o7/hDczW1GmOvSmMbq1KvYWrQsXXZ3Q9dn3MHuJR4B2PDABcw==','owner','9803456789','',0,NOW(),NOW()),
(TRUE,'Dipak Tamang','dipak.tamang@gmail.com','AQAAAAIAAYagAAAAEDHysO42d8ANUsTE92xW6BsMxuXszoIXH1CsFW5iueiI3GgA2f+ZOGh18o79lWjaEw==','owner','9864567890','',0,NOW(),NOW()),
(TRUE,'Sunita Gurung','sunita.gurung@gmail.com','AQAAAAIAAYagAAAAEPbk5oq9f8+mVzDBDpeyVusf10wHub1RvA2Lc1KAoGfmTUWjuH/4bG4JOYjmsteZDg==','owner','9875678901','',0,NOW(),NOW()),
(TRUE,'Ram Prasad Adhikari','ramprasad.adhikari@gmail.com','AQAAAAIAAYagAAAAEJJxk5xZKO1R/ccVUr0sRqIpA3zyso21c8Z3xSMa313G+SMlyFPFNqB1Qv1Idh7oUg==','owner','9816789012','',0,NOW(),NOW()),
(TRUE,'Kamala Neupane','kamala.neupane@gmail.com','AQAAAAIAAYagAAAAEH1FRL6v1xP+6JmZQociv5XO5bvsnmqn4C+OpYG4zohmC9b7TwzgdX+tit8FzvPYAw==','owner','9847890123','',0,NOW(),NOW()),
(TRUE,'Gopal Bajracharya','gopal.bajracharya@gmail.com','AQAAAAIAAYagAAAAEMn2ncfzKHt/4UkC+MwVX83GWXntL/sdKiveT57PWhP0TXsr7z1gdCYE03PfH9/7aQ==','owner','9858901234','',0,NOW(),NOW());

-- ── Link each homestay to its host (by email so IDs always match) ──

-- Homestay 4: Nyatapola Heritage House → Bikash Shrestha
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'bikash.shrestha@gmail.com')
WHERE "Id" = 4;

-- Homestay 5: Boudha Kora Guesthouse → Tenzin Lama
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'tenzin.lama@gmail.com')
WHERE "Id" = 5;

-- Homestay 6: Patan Artisan Courtyard → Sarita Maharjan
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'sarita.maharjan@gmail.com')
WHERE "Id" = 6;

-- Homestay 7: Swayambhu Hill Retreat → Dipak Tamang
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'dipak.tamang@gmail.com')
WHERE "Id" = 7;

-- Homestay 8: Phewa Lakeside Heritage Home → Sunita Gurung
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'sunita.gurung@gmail.com')
WHERE "Id" = 8;

-- Homestay 9: Lumbini Sacred Garden Cottage → Ram Prasad Adhikari
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'ramprasad.adhikari@gmail.com')
WHERE "Id" = 9;

-- Homestay 10: Changu Village Heritage Stay → Kamala Neupane
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'kamala.neupane@gmail.com')
WHERE "Id" = 10;

-- Homestay 11: Bagmati Riverside Heritage Homestay → Gopal Bajracharya
UPDATE "Homestays" SET "OwnerId" = (SELECT "UserId" FROM "User" WHERE "Email" = 'gopal.bajracharya@gmail.com')
WHERE "Id" = 11;
