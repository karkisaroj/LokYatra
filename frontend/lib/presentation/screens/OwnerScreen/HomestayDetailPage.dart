import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';

class HomestayDetailPage extends StatelessWidget {
  final Map<String, dynamic> homestay;

  const HomestayDetailPage({super.key, required this.homestay});

  @override
  Widget build(BuildContext context) {
    List<dynamic> imageUrls = homestay["imageUrls"] ?? [];

    String name = (homestay['name'] ?? '').toString();
    String location = (homestay['location'] ?? '').toString();
    String description = (homestay['description'] ?? 'No description provided').toString();
    double price = (homestay['pricePerNight'] ?? 0).toDouble();
    int rooms = homestay['numberOfRooms'] ?? 0;
    int guests = homestay['maxGuests'] ?? 0;
    bool isVisible = homestay['isVisible'] ?? true;
    int? nearSiteId = homestay['nearCulturalSiteId'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Homestay Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ─── Image Section ─────────────────────
            if (imageUrls.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return ProxyImage(
                      imageUrl: imageUrls[index].toString(),
                      width: double.infinity,
                      height: 250,
                      borderRadiusValue: 0,
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Name
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  /// Location
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// Active / Paused Badge
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                      isVisible ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isVisible ? "Active" : "Paused",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Price Box
                  _buildInfoTile(
                      Icons.currency_rupee,
                      "Price Per Night",
                      "Rs. ${price.toStringAsFixed(0)}"),

                  _buildInfoTile(
                      Icons.bed,
                      "Rooms",
                      "$rooms rooms"),

                  _buildInfoTile(
                      Icons.people,
                      "Max Guests",
                      "$guests guests"),

                  if (nearSiteId != null)
                    _buildInfoTile(
                        Icons.temple_hindu,
                        "Near Cultural Site",
                        "Site ID: $nearSiteId"),

                  const SizedBox(height: 20),

                  /// Description
                  const Text(
                    "Description",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    description,
                    style: const TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, color: Colors.brown),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}