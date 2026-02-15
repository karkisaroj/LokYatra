START TRANSACTION;
UPDATE "Stories" SET "ImageUrls" = ARRAY[]::text[] WHERE "ImageUrls" IS NULL;
ALTER TABLE "Stories" ALTER COLUMN "ImageUrls" SET NOT NULL;
ALTER TABLE "Stories" ALTER COLUMN "ImageUrls" SET DEFAULT ARRAY[]::text[];

UPDATE "CulturalSites" SET "ImageUrls" = ARRAY[]::text[] WHERE "ImageUrls" IS NULL;
ALTER TABLE "CulturalSites" ALTER COLUMN "ImageUrls" SET NOT NULL;
ALTER TABLE "CulturalSites" ALTER COLUMN "ImageUrls" SET DEFAULT ARRAY[]::text[];

ALTER TABLE "CulturalSites" ALTER COLUMN "EntryFeeSAARC" TYPE numeric(18,2);

ALTER TABLE "CulturalSites" ALTER COLUMN "EntryFeeNPR" TYPE numeric(18,2);

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20260215142146_FixDecimalColumns', '9.0.11');

COMMIT;

