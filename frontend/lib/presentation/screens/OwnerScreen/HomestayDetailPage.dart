import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';

class HomestayDetailPage extends StatefulWidget {
  // ✅ Accept typed Homestay, not raw Map
  final Homestay homestay;

  const HomestayDetailPage({super.key, required this.homestay});

  @override
  State<HomestayDetailPage> createState() => _HomestayDetailPageState();
}

class _HomestayDetailPageState extends State<HomestayDetailPage> {
  int _currentImage = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.homestay; // shorthand

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Homestay Details', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image Carousel ──────────────────────────────────────────
            SizedBox(
              height: 260,
              child: h.imageUrls.isEmpty
                  ? Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              )
                  : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: h.imageUrls.length,
                    onPageChanged: (i) => setState(() => _currentImage = i),
                    itemBuilder: (_, i) => ProxyImage(
                      imageUrl: h.imageUrls[i],
                      width: double.infinity,
                      height: 260,
                      borderRadiusValue: 0,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImage + 1} / ${h.imageUrls.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Thumbnail Strip ─────────────────────────────────────────
            if (h.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: h.imageUrls.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _currentImage == i ? Colors.orange : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: ProxyImage(
                            imageUrl: h.imageUrls[i],
                            width: 60,
                            height: 60,
                            borderRadiusValue: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ── Name & Status ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      h.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (h.isVisible)
                    const Chip(
                      label: Text('Active', style: TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),

            // ── Category badge ──────────────────────────────────────────
            if (h.category != null && h.category!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.4)),
                  ),
                  child: Text(
                    h.category!,
                    style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            // ── Location ────────────────────────────────────────────────
            if (h.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(h.location,
                          style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ),
                  ],
                ),
              ),

            // ── Near Cultural Site ──────────────────────────────────────
            if (h.nearCulturalSite != null && h.nearCulturalSite!.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.temple_hindu, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Near ${h.nearCulturalSite!.name}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // ── Price ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Rs. ${h.pricePerNight.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const Text(' / night', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),

            // ── Capacity chips ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _infoChip(Icons.bed, '${h.numberOfRooms} Rooms'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.people, '${h.maxGuests} Guests'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.bathtub_outlined, '${h.bathrooms} Baths'),
                ],
              ),
            ),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // ── Performance ─────────────────────────────────────────────
            _sectionTitle('Performance'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _statCard('12', 'Total\nBookings'),
                  const SizedBox(width: 8),
                  _statCard('3', 'This\nMonth'),
                  const SizedBox(width: 8),
                  _statCard('4.8 ★', 'Avg.\nRating'),
                  const SizedBox(width: 8),
                  _statCard('67%', 'Occupancy'),
                ],
              ),
            ),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // ── About ───────────────────────────────────────────────────
            _sectionTitle('About This Homestay'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(h.description, style: const TextStyle(fontSize: 14, height: 1.6)),
            ),

            // ── Cultural Significance ───────────────────────────────────
            if (h.culturalSignificance != null && h.culturalSignificance!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Cultural Significance'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(h.culturalSignificance!,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],

            // ── Building History ────────────────────────────────────────
            if (h.buildingHistory != null && h.buildingHistory!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Building History'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(h.buildingHistory!,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],

            // ── Traditional Features ────────────────────────────────────
            if (h.traditionalFeatures != null && h.traditionalFeatures!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Traditional Features'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(h.traditionalFeatures!,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],

            const Divider(height: 32, indent: 16, endIndent: 16),

            // ── Cultural Experiences ────────────────────────────────────
            _sectionTitle('Cultural Experiences'),
            if (h.culturalExperiences.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('No cultural experiences listed.',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: h.culturalExperiences
                      .map(
                        (exp) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎭  ',
                              style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(exp,
                                style: const TextStyle(
                                    fontSize: 14, height: 1.5)),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),

            const SizedBox(height: 8),
            const Divider(height: 32, indent: 16, endIndent: 16),

            // ── Amenities ───────────────────────────────────────────────
            _sectionTitle('Amenities'),
            if (h.amenities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('No amenities listed.',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: h.amenities
                      .map(
                        (a) => Chip(
                      avatar: const Icon(Icons.check_circle_outline,
                          size: 16, color: Colors.orange),
                      label: Text(a,
                          style: const TextStyle(fontSize: 13)),
                      backgroundColor: Colors.orange.withOpacity(0.08),
                      side: const BorderSide(
                          color: Colors.orange, width: 0.5),
                    ),
                  )
                      .toList(),
                ),
              ),

            // ── Timestamps ──────────────────────────────────────────────
            if (h.createdAt != null || h.updatedAt != null) ...[
              const Divider(height: 32, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (h.createdAt != null)
                      Text(
                        'Listed on ${_formatDate(h.createdAt!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    if (h.updatedAt != null)
                      Text(
                        'Last updated ${_formatDate(h.updatedAt!)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Balance'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    child: Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold)),
  );

  Widget _infoChip(IconData icon, String label) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: Colors.grey[700])),
      ],
    ),
  );

  Widget _statCard(String value, String label) => Expanded(
    child: Card(
      elevation: 0,
      color: Colors.orange.withOpacity(0.07),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    ),
  );
}