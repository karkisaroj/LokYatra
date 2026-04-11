using backend.Models;
using Microsoft.EntityFrameworkCore;

namespace backend.Database
{
    public static class DataSeeder
    {
        public static async Task SeedHomestaysAsync(AppDbContext context)
        {
            if (await context.Homestays.CountAsync() >= 10)
                return;

            var owners = await context.Users
                .Where(u => u.Role == "owner")
                .ToListAsync();

            if (owners.Count == 0)
                return;

            var culturalSiteIds = await context.CulturalSites
                .Select(s => (int?)s.Id)
                .ToListAsync();

            int? SiteId(int index) =>
                culturalSiteIds.Count > 0 ? culturalSiteIds[index % culturalSiteIds.Count] : null;

            int Owner(int index) => owners[index % owners.Count].UserId;

            var homestays = new List<Homestay>
            {
                new() {
                    OwnerId = Owner(0),
                    NearCulturalSiteId = SiteId(0),
                    Name = "Boudha Heritage Home",
                    Location = "Boudhanath, Kathmandu",
                    Description = "A traditional Newari-style home steps away from the Boudhanath Stupa. Guests enjoy morning chanting, butter tea ceremonies, and rooftop views of the stupa dome.",
                    Category = "Cultural",
                    PricePerNight = 2500,
                    BuildingHistory = "Built in the early 1970s by a Tibetan-influenced Newari family who settled near the stupa after the Great Earthquake restoration period.",
                    CulturalSignificance = "Adjacent to one of the largest Buddhist stupas in the world and a UNESCO World Heritage Site.",
                    TraditionalFeatures = "Carved wooden windows, traditional clay floors, hand-woven thangka decorations, and a private shrine room.",
                    CulturalExperiences = "Morning kora (circumambulation) around the stupa, butter lamp offering ceremony, Tibetan singing bowl meditation, thangka painting workshop.",
                    NumberOfRooms = 4,
                    MaxGuests = 8,
                    Bathrooms = 2,
                    Amenities = ["WiFi", "Hot Water", "Breakfast Included", "Rooftop Terrace", "Prayer Room", "Airport Pickup"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(1),
                    NearCulturalSiteId = SiteId(1),
                    Name = "Pashupatinath Riverside Stay",
                    Location = "Gaurighat, Kathmandu",
                    Description = "A peaceful riverside guesthouse beside the Bagmati river with direct walking access to Pashupatinath Temple. Wake up to the sounds of temple bells and river flow.",
                    Category = "Heritage",
                    PricePerNight = 3000,
                    BuildingHistory = "A 60-year-old restored Brahmin family home that has hosted pilgrims for three generations.",
                    CulturalSignificance = "Located within walking distance of Pashupatinath, the holiest Hindu temple in Nepal.",
                    TraditionalFeatures = "Brick and timber construction, inner courtyard with tulsi plant, traditional brass utensils, and handwoven dhaka fabrics.",
                    CulturalExperiences = "Evening aarti ceremony viewing at the ghats, Sanskrit shloka recitation, traditional Brahmin cooking class, yogic morning routine.",
                    NumberOfRooms = 3,
                    MaxGuests = 6,
                    Bathrooms = 2,
                    Amenities = ["WiFi", "Hot Water", "Breakfast Included", "Garden", "Parking", "Temple Guide"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(0),
                    NearCulturalSiteId = SiteId(2),
                    Name = "Bhaktapur Potter's Quarter Lodge",
                    Location = "Pottery Square, Bhaktapur",
                    Description = "Stay in the heart of Bhaktapur's famous Pottery Square, where artisans have shaped clay for centuries. Wake up to potters at work and explore the medieval city on foot.",
                    Category = "Artisan",
                    PricePerNight = 2200,
                    BuildingHistory = "A 150-year-old brick townhouse restored after the 2015 earthquake with traditional Newari craftsmanship maintained throughout.",
                    CulturalSignificance = "Bhaktapur Durbar Square is a UNESCO World Heritage Site and one of the best-preserved medieval cities in Asia.",
                    TraditionalFeatures = "Original peacock window replica, hand-painted mandala ceilings, traditional wooden balconies overlooking the square.",
                    CulturalExperiences = "Pottery-making class with local masters, Newari feast (Samay Baji), Bisket Jatra festival participation, city heritage walking tour.",
                    NumberOfRooms = 5,
                    MaxGuests = 10,
                    Bathrooms = 3,
                    Amenities = ["WiFi", "Hot Water", "Breakfast Included", "Rooftop", "Pottery Workshop", "Heritage Tour"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(1),
                    NearCulturalSiteId = SiteId(3),
                    Name = "Pokhara Lakeside Mountain Retreat",
                    Location = "Lakeside, Pokhara",
                    Description = "A serene lakeside home with unobstructed views of the Annapurna range. Perfect for trekkers preparing for or returning from the trails.",
                    Category = "Mountain",
                    PricePerNight = 2800,
                    BuildingHistory = "Built by a Gurung family in 1985, the property has expanded over the years while maintaining its traditional mountain architecture.",
                    CulturalSignificance = "Gateway to the Annapurna Circuit and close to the International Mountain Museum.",
                    TraditionalFeatures = "Stone walls, sloped timber roof, traditional Gurung weaving looms, and local stone fireplace.",
                    CulturalExperiences = "Gurung cultural dance performance, traditional raksi brewing demonstration, sunrise Himalaya viewing, paragliding arrangement.",
                    NumberOfRooms = 6,
                    MaxGuests = 12,
                    Bathrooms = 3,
                    Amenities = ["WiFi", "Hot Water", "Breakfast Included", "Lake View", "Mountain View", "Trekking Guide", "Kayak Rental"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(0),
                    NearCulturalSiteId = SiteId(0),
                    Name = "Bandipur Hilltop Thakali House",
                    Location = "Bandipur Bazaar, Tanahun",
                    Description = "A beautifully preserved Newar merchant house on the ridgeline bazaar of Bandipur, one of Nepal's most charming hilltop towns with panoramic Himalaya views.",
                    Category = "Heritage",
                    PricePerNight = 1800,
                    BuildingHistory = "Once a prosperous trading post of a Thakali merchant family dating back to the Rana era, now lovingly converted into a heritage homestay.",
                    CulturalSignificance = "Bandipur is on Nepal's National Heritage Trail and was recently declared a protected heritage zone.",
                    TraditionalFeatures = "Original carved Newari doorways, brass oil lamps, hand-stitched patan dhaka bedspreads, and a traditional storeroom turned reading room.",
                    CulturalExperiences = "Thakali dal-bhat cooking class, mountain sunrise yoga, local bazaar walk with host, Siddha Cave exploration.",
                    NumberOfRooms = 4,
                    MaxGuests = 8,
                    Bathrooms = 2,
                    Amenities = ["WiFi", "Hot Water", "All Meals Included", "Mountain View", "Guided Walks", "Library"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(1),
                    NearCulturalSiteId = SiteId(1),
                    Name = "Kirtipur Village Farmstay",
                    Location = "Kirtipur, Kathmandu Valley",
                    Description = "Experience authentic Newar village life in the ancient hilltop town of Kirtipur. Help with daily farming, explore the town's ancient temples, and enjoy home-cooked Newari meals.",
                    Category = "Farm",
                    PricePerNight = 1500,
                    BuildingHistory = "A working farm passed through five generations of the Maharjan farming family, preserving traditional Newar agricultural practices.",
                    CulturalSignificance = "Kirtipur was one of the last towns to resist Prithvi Narayan Shah's unification campaign and retains a strong independent cultural identity.",
                    TraditionalFeatures = "Mud-plastered walls, communal courtyard with grain drying platforms, traditional granary, and an ancient family shrine.",
                    CulturalExperiences = "Seasonal farming participation, traditional Newari feast preparation, Uma Maheshwar temple visit, handicraft market tour.",
                    NumberOfRooms = 3,
                    MaxGuests = 6,
                    Bathrooms = 1,
                    Amenities = ["Hot Water", "All Meals Included", "Farm Activities", "Temple Visits", "Cultural Dress"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(0),
                    NearCulturalSiteId = SiteId(2),
                    Name = "Nagarkot Sunrise Villa",
                    Location = "Nagarkot, Bhaktapur",
                    Description = "Perched at 2,175m with a 180-degree panoramic view of the Himalayas, this cozy mountain lodge offers the finest sunrise over Everest visible from the Kathmandu Valley.",
                    Category = "Mountain",
                    PricePerNight = 3500,
                    BuildingHistory = "Originally a seasonal farmhouse built in the 1990s, expanded into a full guesthouse after the tourism boom in the early 2000s.",
                    CulturalSignificance = "Nagarkot has been a royal retreat since the Shah dynasty and offers one of the widest Himalayan panoramas in the valley.",
                    TraditionalFeatures = "Stone and timber construction, hand-knitted wool blankets, local stone hearth, and traditional Tamang wall art.",
                    CulturalExperiences = "Pre-dawn Himalaya sunrise trek, Tamang heritage trail hike, traditional Tamang lunch, star-gazing night program.",
                    NumberOfRooms = 5,
                    MaxGuests = 10,
                    Bathrooms = 3,
                    Amenities = ["WiFi", "Hot Water", "Breakfast Included", "Himalaya View", "Bonfire", "Sunrise Trek", "Parking"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
                new() {
                    OwnerId = Owner(1),
                    NearCulturalSiteId = SiteId(3),
                    Name = "Lumbini Peace Guesthouse",
                    Location = "Lumbini, Rupandehi",
                    Description = "A tranquil guesthouse within cycling distance of the Maya Devi Temple, the birthplace of Lord Buddha. Ideal for pilgrims and peace-seekers.",
                    Category = "Spiritual",
                    PricePerNight = 1600,
                    BuildingHistory = "Established by a local Buddhist family in 2005 to accommodate international pilgrims visiting Lumbini's sacred zone.",
                    CulturalSignificance = "Lumbini is the birthplace of Gautama Buddha and a UNESCO World Heritage Site visited by millions of pilgrims annually.",
                    TraditionalFeatures = "Meditation garden with bodhi tree sapling, prayer flags lining the courtyard, traditional butter lamp shrine, and Dharma library.",
                    CulturalExperiences = "Guided Lumbini sacred garden tour, morning meditation session, Buddhist monastery visits, bicycle ride through the pilgrimage circuit.",
                    NumberOfRooms = 6,
                    MaxGuests = 12,
                    Bathrooms = 3,
                    Amenities = ["WiFi", "Hot Water", "Breakfast Included", "Meditation Garden", "Bicycle Rental", "Monastery Tour", "Peaceful Environment"],
                    ImageUrls = [],
                    IsVisible = true,
                    CreatedAt = DateTimeOffset.UtcNow,
                    UpdatedAt = DateTimeOffset.UtcNow,
                },
            };

            await context.Homestays.AddRangeAsync(homestays);
            await context.SaveChangesAsync();
            Console.WriteLine($"[SEEDER] Added {homestays.Count} homestays.");
        }
    }
}
