using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace backend.Migrations
{
    public partial class SeedPashupatinathStories : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
                DO $$
                DECLARE site_id INT;
                BEGIN
                    SELECT ""Id"" INTO site_id FROM ""CulturalSites""
                    WHERE ""Name"" ILIKE '%Pashupatinath%'
                    LIMIT 1;

                    IF site_id IS NOT NULL THEN

                        IF NOT EXISTS (
                            SELECT 1 FROM ""Stories""
                            WHERE ""CulturalSiteId"" = site_id
                            AND ""Title"" = 'The Sacred Origins of Pashupatinath'
                        ) THEN
                            INSERT INTO ""Stories"" (
                                ""CulturalSiteId"", ""Title"", ""StoryType"",
                                ""EstimatedReadTimeMinutes"", ""FullContent"",
                                ""HistoricalContext"", ""CulturalSignificance"",
                                ""ImageUrls"", ""CreatedAt"", ""UpdatedAt""
                            ) VALUES (
                                site_id,
                                'The Sacred Origins of Pashupatinath',
                                'Mythology',
                                6,
                                'Long before the Kathmandu Valley was settled by human civilization, the forest that would one day hold Pashupatinath Temple was said to be the resting place of Lord Shiva and his consort Parvati. According to the Skanda Purana, Shiva descended to the banks of the Bagmati River in the form of a deer to rest in the tranquil forest.

When the gods discovered that Shiva had transformed himself and was wandering among mortal animals, they sought him out. Shiva, wishing to remain undisturbed, leapt across the river. As he jumped, one of his horns broke off and fell to earth — and from that sacred horn, the Jyotirlinga of Pashupatinath emerged, blazing with divine light.

The legend tells that a cowherd first discovered the linga when his cow began spontaneously pouring milk onto a mound in the forest each day. Upon excavation, a blazing, luminous Shivalinga was revealed. A temple was constructed around it, and the site became known as Pashupatinath — Lord of All Living Beings.

The four-faced Chaturmukhi linga inside the inner sanctum represents Shiva in four cardinal directions — Tatpurusha (east), Aghora (south), Vamadeva (north), and Sadyojata (west) — with the fifth invisible face, Ishana, pointing skyward. Each face carries a specific meaning: from grace to ferocity, from creation to dissolution.

Pilgrims believe that dying within sight of this temple guarantees moksha — liberation from the cycle of rebirth. This belief draws hundreds of thousands to Pashupatinath every year, particularly during the festival of Maha Shivaratri when the entire complex glows with oil lamps and the air fills with devotional chanting that echoes across the Bagmati.',
                                'The current temple structure dates to the 15th century, rebuilt by King Shupuspa after an earlier structure was destroyed by termites. However, the site of worship is believed to be over 2,000 years old, with references to Pashupatinath appearing in the Mahabharat and various Hindu Puranas. The temple was granted UNESCO World Heritage status in 1979 as part of the Kathmandu Valley heritage zone.',
                                'Pashupatinath is the most important Hindu temple in Nepal and one of the four most sacred Shiva temples on the Indian subcontinent. It is the spiritual heart of the nation — every Nepali king has been crowned here, and the temple complex serves as the final cremation ground for Hindus across Nepal. The sacred Bagmati River that flows beside it is considered holy enough to merge with the Ganges in spiritual significance.',
                                ARRAY[]::text[],
                                NOW(),
                                NOW()
                            );
                        END IF;

                        IF NOT EXISTS (
                            SELECT 1 FROM ""Stories""
                            WHERE ""CulturalSiteId"" = site_id
                            AND ""Title"" = 'Maha Shivaratri: The Great Night of Shiva'
                        ) THEN
                            INSERT INTO ""Stories"" (
                                ""CulturalSiteId"", ""Title"", ""StoryType"",
                                ""EstimatedReadTimeMinutes"", ""FullContent"",
                                ""HistoricalContext"", ""CulturalSignificance"",
                                ""ImageUrls"", ""CreatedAt"", ""UpdatedAt""
                            ) VALUES (
                                site_id,
                                'Maha Shivaratri: The Great Night of Shiva',
                                'Festival',
                                5,
                                'Every year on the fourteenth night of the dark fortnight in the month of Falgun (February–March), hundreds of thousands of pilgrims pour into Pashupatinath from every corner of Nepal and across India to celebrate Maha Shivaratri — the Great Night of Shiva.

The origins of this festival trace back to the night Shiva performed the Tandava, his cosmic dance of creation and destruction that sustains the universe. It is also considered the night of Shiva and Parvati''s celestial wedding.

By sunset, the ghats along the Bagmati River are packed with sadhus — wandering holy men with ash-smeared bodies, matted hair, and tridents who have walked for weeks to be present at this sacred site. Many come from Varanasi, Rishikesh, and the Indian plains, and their presence transforms Pashupatinath into a living tableau of ancient Shaivite tradition.

Throughout the night, devotees observe a fast, light oil lamps, and keep a vigil chanting Om Namah Shivaya. The inner sanctum remains open all night — a rare occurrence — and long queues of worshippers wait patiently for the chance to pour sacred water, milk, bilva leaves, and flowers onto the Jyotirlinga.

As midnight approaches and the night reaches its peak, the air vibrates with dhak drums, bells, and the collective chant of hundreds of thousands of voices. Fireworks arc over the temple, and the ghats glow orange with the flames of oil diyas reflected in the dark Bagmati below.

By dawn, the festival reaches its close with a final aarti ceremony. Pilgrims carry the memory of this night home as a spiritual blessing that is said to wash away all sins and grant the blessing of Shiva for the year ahead.',
                                'Maha Shivaratri at Pashupatinath has been observed continuously for at least 800 years according to temple records. The event draws an estimated 800,000 to 1 million pilgrims annually, making it one of the largest Hindu religious gatherings in South Asia outside of the Kumbh Mela.',
                                'The festival represents the living continuity of Nepal''s Hindu traditions. It is a national public holiday in Nepal. The presence of sadhus at Pashupatinath during Shivaratri is internationally recognized and photographers and documentary filmmakers come from around the world to capture the event.',
                                ARRAY[]::text[],
                                NOW(),
                                NOW()
                            );
                        END IF;

                        IF NOT EXISTS (
                            SELECT 1 FROM ""Stories""
                            WHERE ""CulturalSiteId"" = site_id
                            AND ""Title"" = 'The Bagmati: River of the Dead and the Divine'
                        ) THEN
                            INSERT INTO ""Stories"" (
                                ""CulturalSiteId"", ""Title"", ""StoryType"",
                                ""EstimatedReadTimeMinutes"", ""FullContent"",
                                ""HistoricalContext"", ""CulturalSignificance"",
                                ""ImageUrls"", ""CreatedAt"", ""UpdatedAt""
                            ) VALUES (
                                site_id,
                                'The Bagmati: River of the Dead and the Divine',
                                'Cultural',
                                4,
                                'The Bagmati River that flows beside Pashupatinath Temple is not merely water — it is considered the sacred boundary between the world of the living and the realm of the gods.

For Hindus, the cremation ghats of Pashupatinath represent the holiest place a person can leave this earth. Bodies wrapped in white shrouds are carried through the streets of Kathmandu on bamboo stretchers by male relatives. At the ghats, after ritual bathing and prayer, the funeral pyre is lit by the eldest son, and the body returns to the five elements while priests chant Vedic mantras.

The smoke rises over the temple, carrying the soul upward. The ashes are immersed in the Bagmati, which will eventually join the Ganges, and from there, the ocean — completing a journey from individual life back to the universal. Dying at Pashupatinath, or having one''s ashes immersed in the Bagmati here, is believed to grant the dying soul direct passage to moksha.

Across the river on the eastern bank, stone terraces called Arya Ghats host the cremations of the royal family and high-caste Hindus. Below, the common ghats are used by ordinary citizens. Visitors who sit quietly on the opposite bank often witness multiple simultaneous cremations alongside sadhus meditating in alcoves carved into the stone — life and death proceeding in complete, unashamed proximity.

The Bagmati is also the site of the Teej festival each monsoon, when thousands of women dressed in red saris come to bathe in the river and pray at the temple for the long life of their husbands, recreating the devotion of Parvati for Shiva.',
                                'The cremation practices at Pashupatinath have been documented since at least the 12th century CE. The Arya Ghat cremation terrace was specifically built for the Nepali royal family and senior nobility. After the royal massacre of 2001, several members of the Shah dynasty were cremated here, drawing massive public mourning.',
                                'The open-air cremation at Pashupatinath is one of the most profound and philosophically meaningful cultural practices visible to respectful visitors anywhere in the world. It reflects the Hindu relationship with mortality as a natural transition rather than a fearful ending, and the role of river and fire as sacred transforming forces.',
                                ARRAY[]::text[],
                                NOW(),
                                NOW()
                            );
                        END IF;

                    END IF;
                END $$;
            ");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
                DELETE FROM ""Stories""
                WHERE ""Title"" IN (
                    'The Sacred Origins of Pashupatinath',
                    'Maha Shivaratri: The Great Night of Shiva',
                    'The Bagmati: River of the Dead and the Divine'
                );
            ");
        }
    }
}
