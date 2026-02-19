import 'package:flutter/material.dart';
import 'package:lokyatra_frontend/core/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';

class HomestayDetailPage extends StatefulWidget {
  final Homestay homestay;

  const HomestayDetailPage({super.key, required this.homestay});

  @override
  State<HomestayDetailPage> createState() => _HomestayDetailPageState();
}

class _HomestayDetailPageState extends State<HomestayDetailPage> {
  int _currentImage = 0;
  late final PageController _pageController;
  late bool _isVisible;
  bool _togglingVisibility = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _isVisible = widget.homestay.isVisible;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _toggleVisibility() async {
    final newValue = !_isVisible;

    // Optimistic update
    setState(() {
      _isVisible = newValue;
      _togglingVisibility = true;
    });

    try {
      final response = await HomestaysRemoteDatasource()
          .toggleVisibility(widget.homestay.id, newValue);

      if (response.statusCode != 200 && response.statusCode != 204) {
        setState(() => _isVisible = !newValue);
        _showSnack('Failed to update visibility');
      } else {
        _showSnack(
          newValue ? 'Homestay is now Active' : 'Homestay is now Inactive',
          isError: false,
        );
      }
    } catch (e) {
      setState(() => _isVisible = !newValue);
      _showSnack('Error: $e');
    } finally {
      if (mounted) setState(() => _togglingVisibility = false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.homestay;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Homestay Details',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image Carousel
            SizedBox(
              height: 260,
              child: h.imageUrls.isEmpty
                  ? Container(
                color: Colors.grey[300],
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported,
                    size: 60, color: Colors.grey),
              )
                  : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: h.imageUrls.length,
                    onPageChanged: (i) =>
                        setState(() => _currentImage = i),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImage + 1} / ${h.imageUrls.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Thumbnail Strip
            if (h.imageUrls.length > 1)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: SizedBox(
                  height: 64,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: h.imageUrls.length,
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _pageController.animateToPage(i,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _currentImage == i
                                ? Colors.blueGrey
                                : Colors.transparent,
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

            // Name row with tappable status badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(h.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: _togglingVisibility ? null : _toggleVisibility,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isVisible
                            ? Colors.green
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _togglingVisibility
                          ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isVisible ? 'Active' : 'Inactive',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Visibility control card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isVisible
                      ? Colors.green.withValues(alpha:0.07)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isVisible
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isVisible
                          ? Icons.check_circle_outline
                          : Icons.pause_circle_outline,
                      color: _isVisible ? Colors.green : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isVisible
                                ? 'Listing is Active'
                                : 'Listing is Inactive',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _isVisible
                                  ? Colors.green
                                  : Colors.grey[600],
                            ),
                          ),
                          Text(
                            _isVisible
                                ? 'Guests can find and book this homestay'
                                : 'Hidden from guests — no new bookings',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _togglingVisibility
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                        : Switch(
                      value: _isVisible,
                      activeThumbColor: Colors.green,
                      onChanged: (_) => _toggleVisibility(),
                    ),
                  ],
                ),
              ),
            ),

            // Category badge
            if (h.category != null && h.category!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.black.withValues(alpha: 0.4)),
                  ),
                  child: Text(h.category!,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600)),
                ),
              ),

            // Location
            if (h.location.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(h.location,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black)),
                    ),
                  ],
                ),
              ),

            // Near Cultural Site
            if (h.nearCulturalSite != null &&
                h.nearCulturalSite!.name.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Row(
                  children: [
                    const Icon(Icons.temple_hindu,
                        size: 16, color: Colors.black),
                    const SizedBox(width: 4),
                    Text('Near ${h.nearCulturalSite!.name}',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black)),
                  ],
                ),
              ),

            // Price
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Rs. ${h.pricePerNight.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                  ),
                  const Text(' / night',
                      style: TextStyle(color: Colors.black87, fontSize: 14)),
                ],
              ),
            ),

            // Capacity chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  _infoChip(Icons.bed, '${h.numberOfRooms} Rooms'),
                  const SizedBox(width: 8),
                  _infoChip(Icons.people, '${h.maxGuests} Guests'),
                  const SizedBox(width: 8),
                  _infoChip(
                      Icons.bathtub_outlined, '${h.bathrooms} Baths'),
                ],
              ),
            ),

            const Divider(height: 32, indent: 16, endIndent: 16),

            // Performance
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

            // About
            _sectionTitle('About This Homestay'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(h.description,
                  style: const TextStyle(fontSize: 14, height: 1.6)),
            ),

            // Cultural Significance
            if (h.culturalSignificance != null &&
                h.culturalSignificance!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Cultural Significance'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(h.culturalSignificance!,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],

            // Building History
            if (h.buildingHistory != null &&
                h.buildingHistory!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Building History'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(h.buildingHistory!,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],

            // Traditional Features
            if (h.traditionalFeatures != null &&
                h.traditionalFeatures!.isNotEmpty) ...[
              const SizedBox(height: 20),
              _sectionTitle('Traditional Features'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(h.traditionalFeatures!,
                    style: const TextStyle(fontSize: 14, height: 1.6)),
              ),
            ],

            const Divider(height: 32, indent: 16, endIndent: 16),

            // Cultural Experiences
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
                      .map((exp) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                  ))
                      .toList(),
                ),
              ),

            const SizedBox(height: 8),
            const Divider(height: 32, indent: 16, endIndent: 16),

            // Amenities
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
                      .map((a) => Chip(
                    avatar: const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.orange),
                    label: Text(a,
                        style:
                        const TextStyle(fontSize: 13)),
                    backgroundColor:
                    Colors.orange.withValues(alpha: 0.08),
                    side: const BorderSide(
                        color: Colors.orange, width: 0.5),
                  ))
                      .toList(),
                ),
              ),

            // Timestamps
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
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                    if (h.updatedAt != null)
                      Text(
                        'Last updated ${_formatDate(h.updatedAt!)}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
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
      color: Colors.grey.withValues(alpha: 0.07),
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