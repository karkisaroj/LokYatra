import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/core/services/image_proxy.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';
import '../../widgets/Helpers/form_helpers.dart';

const editBrown = Color(0xFF5C4033);
const editBg    = Color(0xFFFAF9F7);
const editInk   = Color(0xFF2D1B10);

double efs(double v, bool wide) => wide ? v : v.sp;
double ew(double v, bool wide)  => wide ? v : v.w;
double eh(double v, bool wide)  => wide ? v : v.h;
double er(double v, bool wide)  => wide ? v : v.r;

class HomestayEditPage extends StatefulWidget {
  final Homestay homestay;
  const HomestayEditPage({super.key, required this.homestay});
  @override
  State<HomestayEditPage> createState() => HomestayEditPageState();
}

class HomestayEditPageState extends State<HomestayEditPage> {
  final formKey       = GlobalKey<FormState>();
  bool isLoading      = false;
  bool sitesLoading   = true;
  double? uploadProgress;

  late final TextEditingController nameCtrl;
  late final TextEditingController locationCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController roomsCtrl;
  late final TextEditingController guestsCtrl;
  late final TextEditingController bathsCtrl;
  late final TextEditingController buildingCtrl;
  late final TextEditingController tradFeatCtrl;
  late final TextEditingController cultExpCtrl;
  late final TextEditingController cultSigCtrl;

  String?       selectedCategory;
  int?          selectedSiteId;
  List<dynamic> sites = [];
  late Set<String> selectedAmenities;

  // existingImages[i] = URL still kept, or '' if user cleared that slot
  late List<String> existingImages;

  // newImages[i] = newly picked file for slot i, or null
  final List<PlatformFile?> newImages = [null, null, null, null];

  late bool isVisible;

  final categories   = ['homestay', 'guest_house', 'traditional'];
  final allAmenities = [
    'WiFi', 'Parking', 'Hot Water', 'Air Conditioning', 'Heating',
    'Kitchen', 'Breakfast Included', 'Laundry', 'Garden', 'Terrace',
    'Mountain View', 'River View', 'TV', 'Bonfire', 'Guided Tours', 'Bicycle Rental',
  ];

  @override
  void initState() {
    super.initState();
    final h          = widget.homestay;
    nameCtrl         = TextEditingController(text: h.name);
    locationCtrl     = TextEditingController(text: h.location);
    descCtrl         = TextEditingController(text: h.description);
    priceCtrl        = TextEditingController(text: h.pricePerNight.toStringAsFixed(0));
    roomsCtrl        = TextEditingController(text: h.numberOfRooms.toString());
    guestsCtrl       = TextEditingController(text: h.maxGuests.toString());
    bathsCtrl        = TextEditingController(text: h.bathrooms.toString());
    buildingCtrl     = TextEditingController(text: h.buildingHistory ?? '');
    tradFeatCtrl     = TextEditingController(text: h.traditionalFeatures ?? '');
    cultExpCtrl      = TextEditingController(text: h.culturalExperiences.join(', '));
    cultSigCtrl      = TextEditingController(text: h.culturalSignificance ?? '');
    selectedCategory = h.category;
    selectedSiteId   = h.nearCulturalSite?.id;
    isVisible        = h.isVisible;
    selectedAmenities = h.amenities
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toSet();

    // Populate all 4 slots; empty string for unused slots
    existingImages = List.filled(4, '');
    for (int i = 0; i < 4 && i < h.imageUrls.length; i++) {
      existingImages[i] = h.imageUrls[i];
    }
    loadSites();
  }

  @override
  void dispose() {
    for (final c in [
      nameCtrl, locationCtrl, descCtrl, priceCtrl, roomsCtrl, guestsCtrl,
      bathsCtrl, buildingCtrl, tradFeatCtrl, cultExpCtrl, cultSigCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  Future<void> loadSites() async {
    try {
      final res = await SitesRemoteDatasource().getSites();
      if (res.statusCode == 200 && mounted) {
        setState(() { sites = res.data as List<dynamic>; sitesLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() => sitesLoading = false);
    }
  }

  Future<void> pickImage(int i) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        newImages[i]      = result.files.first;
        existingImages[i] = '';
      });
    }
  }

  void removeImage(int i) =>
      setState(() { newImages[i] = null; existingImages[i] = ''; });

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() { isLoading = true; uploadProgress = null; });
    try {
      final fields = <String, String>{
        'Name':                 nameCtrl.text.trim(),
        'Location':             locationCtrl.text.trim(),
        'Description':          descCtrl.text.trim(),
        'PricePerNight':        priceCtrl.text.trim(),
        'NumberOfRooms':        roomsCtrl.text.trim(),
        'MaxGuests':            guestsCtrl.text.trim(),
        'Bathrooms':            bathsCtrl.text.trim(),
        'BuildingHistory':      buildingCtrl.text.trim(),
        'TraditionalFeatures':  tradFeatCtrl.text.trim(),
        'CulturalExperiences':  cultExpCtrl.text.trim(),
        'CulturalSignificance': cultSigCtrl.text.trim(),
        'Amenities':            selectedAmenities.join(','),
        'IsVisible':            isVisible.toString(),
        if (selectedCategory != null) 'Category': selectedCategory!,
        if (selectedSiteId   != null) 'NearCulturalSiteId': selectedSiteId.toString(),
        'ExistingImages': existingImages.where((u) => u.isNotEmpty).join(','),
      };

      final res = await HomestaysRemoteDatasource().updateHomestay(
        id:     widget.homestay.id,
        fields: fields,
        files:  newImages.whereType<PlatformFile>().toList(),
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) setState(() => uploadProgress = sent / total);
        },
      );

      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 204) {
        Navigator.pop(context, true);
      } else {
        FormHelpers.showSnack(context, 'Update failed: ${res.statusMessage}');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String msg;
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        msg = 'Upload timed out — check your connection and try again.';
      } else if (e.response != null) {
        msg = 'Status ${e.response!.statusCode}: ${e.response!.statusMessage}';
      } else {
        msg = e.message ?? 'Network error';
      }
      FormHelpers.showSnack(context, msg);
    } catch (e) {
      if (mounted) FormHelpers.showSnack(context, 'Error: $e');
    } finally {
      if (mounted) setState(() { isLoading = false; uploadProgress = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: editBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Edit Homestay',
            style: GoogleFonts.playfairDisplay(
                fontSize: efs(18, wide),
                fontWeight: FontWeight.bold,
                color: editInk)),
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: Colors.grey.shade200)),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 780 : double.infinity),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ew(16, wide)),
              child: wide ? wideLayout(wide) : narrowLayout(wide),
            ),
          ),
        ),
      ),
    );
  }

  Widget narrowLayout(bool wide) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: allSections(wide),
  );

  Widget wideLayout(bool wide) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      visibilityCard(wide),
      SizedBox(height: eh(4, wide)),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(children: [
          buildSection(wide, 'Basic Information',  Icons.home_outlined,
              basicFields(wide)),
          buildSection(wide, 'Pricing & Capacity', Icons.payments_outlined,
              pricingFields(wide)),
          buildSection(wide, 'Near Cultural Site', Icons.temple_hindu_outlined, [
            Text('Tap a site to select it',
                style: GoogleFonts.dmSans(
                    fontSize: efs(12, wide), color: Colors.grey)),
            SizedBox(height: eh(10, wide)),
            siteSelector(wide),
          ]),
        ])),
        SizedBox(width: ew(16, wide)),
        Expanded(child: Column(children: [
          buildSection(wide, 'Cultural Heritage', Icons.auto_stories_outlined,
              heritageFields(wide)),
          buildSection(wide, 'Amenities',         Icons.checklist_outlined,
              [amenityChips(wide)]),
          buildSection(wide, 'Photos',            Icons.photo_library_outlined,
              photoSection(wide)),
        ])),
      ]),
      SizedBox(height: eh(20, wide)),
      SizedBox(
        width: double.infinity, height: eh(58, wide),
        child: isLoading ? uploadButton(wide) : submitButton(wide),
      ),
      SizedBox(height: eh(40, wide)),
    ],
  );

  List<Widget> allSections(bool wide) => [
    visibilityCard(wide),
    SizedBox(height: eh(4, wide)),
    buildSection(wide, 'Basic Information',  Icons.home_outlined,
        basicFields(wide)),
    buildSection(wide, 'Pricing & Capacity', Icons.payments_outlined,
        pricingFields(wide)),
    buildSection(wide, 'Near Cultural Site', Icons.temple_hindu_outlined, [
      Text('Tap a site to select it',
          style: GoogleFonts.dmSans(fontSize: efs(12, wide), color: Colors.grey)),
      SizedBox(height: eh(10, wide)),
      siteSelector(wide),
    ]),
    buildSection(wide, 'Cultural Heritage',  Icons.auto_stories_outlined,
        heritageFields(wide)),
    buildSection(wide, 'Amenities',          Icons.checklist_outlined,
        [amenityChips(wide)]),
    buildSection(wide, 'Photos',             Icons.photo_library_outlined,
        photoSection(wide)),
    SizedBox(height: eh(20, wide)),
    SizedBox(
      width: double.infinity, height: eh(58, wide),
      child: isLoading ? uploadButton(wide) : submitButton(wide),
    ),
    SizedBox(height: eh(40, wide)),
  ];

  List<Widget> basicFields(bool wide) => [
    formField(wide, nameCtrl,     'Name'),
    formField(wide, locationCtrl, 'Location'),
    formField(wide, descCtrl,     'Description', lines: 4),
    categoryDropdown(wide),
  ];

  List<Widget> pricingFields(bool wide) => [
    formField(wide, priceCtrl, 'Price per Night (Rs.)', number: true),
    Row(children: [
      Expanded(child: formField(wide, roomsCtrl,  'Rooms',      number: true)),
      SizedBox(width: ew(10, wide)),
      Expanded(child: formField(wide, guestsCtrl, 'Max Guests', number: true)),
      SizedBox(width: ew(10, wide)),
      Expanded(child: formField(wide, bathsCtrl,  'Bathrooms',  number: true)),
    ]),
  ];

  List<Widget> heritageFields(bool wide) => [
    formField(wide, cultSigCtrl,  'Cultural Significance', lines: 3, required: false),
    formField(wide, buildingCtrl, 'Building History',       lines: 3, required: false),
    formField(wide, tradFeatCtrl, 'Traditional Features',   lines: 3, required: false),
    formField(wide, cultExpCtrl,  'Cultural Experiences',   lines: 3, required: false,
        hint: 'e.g. Thangka painting, Mask dance'),
  ];

  List<Widget> photoSection(bool wide) => [
    Text('Tap a slot to change · Tap ✕ to remove',
        style: GoogleFonts.dmSans(fontSize: efs(12, wide), color: Colors.grey)),
    SizedBox(height: eh(12, wide)),
    Wrap(
      spacing: ew(12, wide),
      runSpacing: eh(12, wide),
      children: List.generate(4, (i) => imageSlot(wide, i)),
    ),
  ];

  Widget visibilityCard(bool wide) => Container(
    margin: EdgeInsets.only(bottom: eh(14, wide)),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(er(16, wide)),
      boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2))],
    ),
    child: SwitchListTile(
      title: Text('Listing Active',
          style: GoogleFonts.dmSans(
              fontSize: efs(14, wide), fontWeight: FontWeight.w600)),
      subtitle: Text(
          isVisible ? 'Visible to guests' : 'Hidden from guests',
          style: GoogleFonts.dmSans(fontSize: efs(12, wide))),
      value: isVisible,
      activeThumbColor: Colors.green,
      onChanged: (val) => setState(() => isVisible = val),
    ),
  );

  Widget buildSection(bool wide, String title, IconData icon,
      List<Widget> children) =>
      Container(
        margin: EdgeInsets.only(bottom: eh(14, wide)),
        padding: EdgeInsets.all(ew(16, wide)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(er(16, wide)),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: efs(18, wide), color: editBrown),
            SizedBox(width: ew(8, wide)),
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: efs(14, wide), fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: eh(14, wide)),
          ...children,
        ]),
      );

  Widget formField(
      bool wide,
      TextEditingController ctrl,
      String label, {
        int lines     = 1,
        bool number   = false,
        bool required = true,
        String? hint,
      }) =>
      Padding(
        padding: EdgeInsets.only(bottom: eh(12, wide)),
        child: TextFormField(
          controller: ctrl,
          maxLines: lines,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true) : null,
          style: GoogleFonts.dmSans(fontSize: efs(14, wide)),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(fontSize: efs(13, wide)),
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                fontSize: efs(12, wide), color: Colors.grey[400]),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(er(10, wide)),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(er(10, wide)),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(er(10, wide)),
                borderSide: BorderSide(color: editBrown, width: 1.5)),
            filled: true,
            fillColor: editBg,
            contentPadding: EdgeInsets.symmetric(
                horizontal: ew(14, wide), vertical: eh(12, wide)),
          ),
          validator: required
              ? (v) => (v?.trim().isEmpty ?? true) ? '$label is required' : null
              : null,
        ),
      );

  Widget categoryDropdown(bool wide) => Padding(
    padding: EdgeInsets.only(bottom: eh(12, wide)),
    child: DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      style: GoogleFonts.dmSans(fontSize: efs(14, wide), color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.dmSans(fontSize: efs(13, wide)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(er(10, wide)),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(er(10, wide)),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(er(10, wide)),
            borderSide: BorderSide(color: editBrown, width: 1.5)),
        filled: true,
        fillColor: editBg,
        contentPadding: EdgeInsets.symmetric(
            horizontal: ew(14, wide), vertical: eh(12, wide)),
      ),
      items: categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (val) => setState(() => selectedCategory = val),
    ),
  );

  Widget siteSelector(bool wide) {
    if (sitesLoading) return const Center(child: CircularProgressIndicator());
    if (sites.isEmpty) {
      return Text('No sites available.',
          style: GoogleFonts.dmSans(fontSize: efs(13, wide), color: Colors.grey));
    }
    return Container(
      height: eh(200, wide),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(er(10, wide)),
        color: editBg,
      ),
      child: ListView.builder(
        itemCount: sites.length,
        itemBuilder: (_, i) {
          final site     = sites[i];
          final id       = site['id'] as int?;
          final name     = site['name']?.toString() ?? 'Unnamed';
          final selected = selectedSiteId == id;
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: er(16, wide),
              backgroundColor: selected ? editBrown : Colors.grey.shade200,
              child: Icon(Icons.temple_hindu,
                  size: efs(14, wide),
                  color: selected ? Colors.white : Colors.grey),
            ),
            title: Text(name,
                style: GoogleFonts.dmSans(
                    fontSize: efs(13, wide),
                    fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal)),
            trailing: selected
                ? Icon(Icons.check_circle, color: editBrown, size: efs(18, wide))
                : null,
            onTap: () => setState(() => selectedSiteId = id),
          );
        },
      ),
    );
  }

  Widget amenityChips(bool wide) => Wrap(
    spacing: ew(8, wide),
    runSpacing: eh(8, wide),
    children: allAmenities.map((a) {
      final selected =
      selectedAmenities.any((s) => s.toLowerCase() == a.toLowerCase());
      return FilterChip(
        label: Text(a, style: GoogleFonts.dmSans(fontSize: efs(12, wide))),
        selected: selected,
        onSelected: (val) => setState(() {
          if (val) {
            selectedAmenities.add(a);
          } else {
            selectedAmenities
                .removeWhere((s) => s.toLowerCase() == a.toLowerCase());
          }
        }),
        selectedColor: editBrown.withValues(alpha: 0.12),
        checkmarkColor: editBrown,
        side: BorderSide(color: selected ? editBrown : Colors.grey.shade300),
        backgroundColor: editBg,
      );
    }).toList(),
  );

  Widget imageSlot(bool wide, int i) {
    final newFile    = newImages[i];
    final existing   = existingImages[i];
    final hasContent = newFile != null || existing.isNotEmpty;
    final boxSz      = wide ? 110.0 : 100.h;

    Widget imageContent;
    if (newFile != null) {
      if (kIsWeb && newFile.bytes != null) {
        imageContent = Image.memory(
          newFile.bytes!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else if (!kIsWeb && newFile.path != null) {
        imageContent = Image.file(
          File(newFile.path!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } else {
        imageContent = Center(
            child: Icon(Icons.broken_image,
                size: efs(28, wide), color: Colors.grey[400]));
      }
    } else if (existing.isNotEmpty) {
      imageContent = ProxyImage(
        imageUrl: existing,
        width: double.infinity,
        height: double.infinity,
        borderRadiusValue: 0,
      );
    } else {
      imageContent = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate,
              size: efs(28, wide), color: Colors.grey[400]),
          SizedBox(height: eh(4, wide)),
          Text('Slot ${i + 1}',
              style: GoogleFonts.dmSans(
                  fontSize: efs(10, wide), color: Colors.grey[400])),
        ],
      );
    }

    return GestureDetector(
      onTap: () => pickImage(i),
      child: Container(
        height: boxSz,
        width: boxSz,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
              color: hasContent ? editBrown : Colors.grey.shade300,
              width: hasContent ? 2 : 1),
          borderRadius: BorderRadius.circular(er(12, wide)),
        ),
        child: Stack(fit: StackFit.expand, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(er(10, wide)),
            child: imageContent,
          ),
          if (hasContent)
            Positioned(
              top: eh(4, wide), right: ew(4, wide),
              child: GestureDetector(
                onTap: () => removeImage(i),
                child: CircleAvatar(
                  radius: er(11, wide),
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close,
                      size: efs(12, wide), color: Colors.white),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  Widget submitButton(bool wide) => ElevatedButton.icon(
    onPressed: submit,
    icon: Icon(Icons.save, size: efs(18, wide)),
    label: Text('Save Changes',
        style: GoogleFonts.dmSans(
            fontSize: efs(15, wide), fontWeight: FontWeight.w600)),
    style: ElevatedButton.styleFrom(
      backgroundColor: editBrown,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(er(12, wide))),
    ),
  );

  Widget uploadButton(bool wide) {
    final hasProgress = uploadProgress != null;
    final pct   = hasProgress
        ? '${(uploadProgress! * 100).toStringAsFixed(0)}%' : '';
    final label = !hasProgress
        ? 'Preparing...'
        : uploadProgress! < 1.0
        ? 'Uploading images  $pct'
        : 'Saving to server...';
    return Container(
      decoration: BoxDecoration(
          color: editBrown,
          borderRadius: BorderRadius.circular(er(12, wide))),
      padding: EdgeInsets.symmetric(horizontal: ew(20, wide)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: ew(14, wide), height: eh(14, wide),
            child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.8)),
          ),
          SizedBox(width: ew(10, wide)),
          Text(label,
              style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: efs(13, wide),
                  fontWeight: FontWeight.w600)),
        ]),
        if (hasProgress) ...[
          SizedBox(height: eh(8, wide)),
          ClipRRect(
            borderRadius: BorderRadius.circular(er(4, wide)),
            child: LinearProgressIndicator(
              value: uploadProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
              minHeight: eh(4, wide),
            ),
          ),
        ],
      ]),
    );
  }
}