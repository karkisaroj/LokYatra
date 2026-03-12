import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lokyatra_frontend/data/datasources/homestays_remote_datasource.dart';
import 'package:lokyatra_frontend/data/datasources/sites_remote_datasource.dart';
import '../../widgets/Helpers/form_helpers.dart';

const formBrown = Color(0xFF5C4033);
const formBg    = Color(0xFFFAF9F7);
const formInk   = Color(0xFF2D1B10);

double ffs(double v, bool wide) => wide ? v : v.sp;
double ffw(double v, bool wide) => wide ? v : v.w;
double ffh(double v, bool wide) => wide ? v : v.h;
double ffr(double v, bool wide) => wide ? v : v.r;

class HomestayAddPage extends StatefulWidget {
  const HomestayAddPage({super.key});
  @override
  State<HomestayAddPage> createState() => HomestayAddPageState();
}

class HomestayAddPageState extends State<HomestayAddPage> {
  final formKey           = GlobalKey<FormState>();
  bool isLoading          = false;
  bool sitesLoading       = true;
  double? uploadProgress;

  final nameCtrl          = TextEditingController();
  final locationCtrl      = TextEditingController();
  final descCtrl          = TextEditingController();
  final buildingCtrl      = TextEditingController();
  final tradFeatCtrl      = TextEditingController();
  final cultExpCtrl       = TextEditingController();
  final cultSigCtrl       = TextEditingController();
  final priceCtrl         = TextEditingController();
  final roomsCtrl         = TextEditingController();
  final guestsCtrl        = TextEditingController();
  final bathsCtrl         = TextEditingController();

  String?       selectedCategory;
  int?          selectedSiteId;
  List<dynamic> sites     = [];
  final List<PlatformFile?> images = [null, null, null, null];

  final categories   = ['homestay', 'guest_house', 'traditional'];
  final allAmenities = [
    'WiFi', 'Parking', 'Hot Water', 'Air Conditioning', 'Heating',
    'Kitchen', 'Breakfast Included', 'Laundry', 'Garden', 'Terrace',
    'Mountain View', 'River View', 'TV', 'Bonfire', 'Guided Tours',
    'Bicycle Rental',
  ];
  final Set<String> selectedAmenities = {};

  @override
  void initState() {
    super.initState();
    loadSites();
  }

  @override
  void dispose() {
    for (final c in [
      nameCtrl, locationCtrl, descCtrl, buildingCtrl,
      tradFeatCtrl, cultExpCtrl, cultSigCtrl,
      priceCtrl, roomsCtrl, guestsCtrl, bathsCtrl,
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
      withData: true, // required for web: loads bytes into memory
    );
    if (result != null && mounted) setState(() => images[i] = result.files.first);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCategory == null) {
      FormHelpers.showSnack(context, 'Please select a category'); return;
    }
    final price  = double.tryParse(priceCtrl.text.trim());
    final rooms  = int.tryParse(roomsCtrl.text.trim());
    final guests = int.tryParse(guestsCtrl.text.trim());
    final baths  = int.tryParse(bathsCtrl.text.trim());
    if (price == null || price <= 0)  { FormHelpers.showSnack(context, 'Enter a valid price'); return; }
    if (rooms == null || rooms <= 0)  { FormHelpers.showSnack(context, 'Enter valid number of rooms'); return; }
    if (guests == null || guests <= 0){ FormHelpers.showSnack(context, 'Enter valid max guests'); return; }
    if (baths == null || baths < 0)   { FormHelpers.showSnack(context, 'Enter valid number of bathrooms'); return; }

    setState(() { isLoading = true; uploadProgress = null; });

    try {
      final fields = <String, dynamic>{
        'Name':                nameCtrl.text.trim(),
        'Location':            locationCtrl.text.trim(),
        'Description':         descCtrl.text.trim(),
        'Category':            selectedCategory!,
        'PricePerNight':       price.toString(),
        'NumberOfRooms':       rooms.toString(),
        'MaxGuests':           guests.toString(),
        'Bathrooms':           baths.toString(),
        'Amenities':           selectedAmenities.join(','),
        'BuildingHistory':     buildingCtrl.text.trim(),
        'TraditionalFeatures': tradFeatCtrl.text.trim(),
        'CulturalExperiences': cultExpCtrl.text.trim(),
      };
      if (selectedSiteId != null) fields['NearCulturalSiteId'] = selectedSiteId.toString();
      if (cultSigCtrl.text.trim().isNotEmpty) fields['CulturalSignificance'] = cultSigCtrl.text.trim();

      final res = await HomestaysRemoteDatasource().createHomestay(
        fields: fields,
        files: images.whereType<PlatformFile>().toList(),
        onSendProgress: (sent, total) {
          if (total > 0 && mounted) setState(() => uploadProgress = sent / total);
        },
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        FormHelpers.showSnack(context, 'Server error: ${res.statusCode}');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      String msg;
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        msg = 'Upload timed out — check your connection and try again.';
      } else if (e.response != null) {
        final data = e.response!.data;
        if (data is Map) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            msg = errors.values.expand((v) => v is List ? v : [v]).join('\n');
          } else {
            msg = data['title']?.toString() ?? data['message']?.toString() ?? 'Status ${e.response!.statusCode}';
          }
        } else {
          msg = data?.toString() ?? 'Status ${e.response!.statusCode}';
        }
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
      backgroundColor: formBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Add Homestay',
            style: GoogleFonts.playfairDisplay(
                fontSize: ffs(18, wide), fontWeight: FontWeight.bold, color: formInk)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: ffw(12, wide)),
            child: isLoading
                ? SizedBox(
                width: ffw(20, wide), height: ffh(20, wide),
                child: CircularProgressIndicator(strokeWidth: 2, color: formBrown))
                : TextButton.icon(
              onPressed: submit,
              icon: Icon(Icons.check, color: Colors.green, size: ffs(18, wide)),
              label: Text('Upload',
                  style: GoogleFonts.dmSans(
                      color: formBrown,
                      fontWeight: FontWeight.bold,
                      fontSize: ffs(14, wide))),
            ),
          ),
        ],
        bottom: isLoading
            ? PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: Colors.grey.shade200,
                color: formBrown))
            : PreferredSize(
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
              padding: EdgeInsets.all(ffw(16, wide)),
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
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(children: [
          buildSection(wide, 'Basic Information',              Icons.home_outlined,          basicFields(wide)),
          buildSection(wide, 'Pricing & Capacity',             Icons.payments_outlined,      pricingFields(wide)),
          buildSection(wide, 'Near Cultural Site (Optional)',  Icons.temple_hindu_outlined,  [siteSelector(wide)]),
        ])),
        SizedBox(width: ffw(16, wide)),
        Expanded(child: Column(children: [
          buildSection(wide, 'Cultural Heritage',  Icons.auto_stories_outlined,  heritageFields(wide)),
          buildSection(wide, 'Amenities',          Icons.checklist_outlined,     amenitySection(wide)),
          buildSection(wide, 'Photos',             Icons.photo_library_outlined, photoSection(wide)),
        ])),
      ]),
      SizedBox(height: ffh(20, wide)),
      SizedBox(
        width: double.infinity,
        height: ffh(58, wide),
        child: isLoading ? uploadButton(wide) : submitButton(wide),
      ),
      SizedBox(height: ffh(40, wide)),
    ],
  );

  List<Widget> allSections(bool wide) => [
    buildSection(wide, 'Basic Information',             Icons.home_outlined,          basicFields(wide)),
    buildSection(wide, 'Pricing & Capacity',            Icons.payments_outlined,      pricingFields(wide)),
    buildSection(wide, 'Near Cultural Site (Optional)', Icons.temple_hindu_outlined,  [siteSelector(wide)]),
    buildSection(wide, 'Cultural Heritage',             Icons.auto_stories_outlined,  heritageFields(wide)),
    buildSection(wide, 'Amenities',                     Icons.checklist_outlined,     amenitySection(wide)),
    buildSection(wide, 'Photos',                        Icons.photo_library_outlined, photoSection(wide)),
    SizedBox(height: ffh(20, wide)),
    SizedBox(
      width: double.infinity,
      height: ffh(58, wide),
      child: isLoading ? uploadButton(wide) : submitButton(wide),
    ),
    SizedBox(height: ffh(40, wide)),
  ];

  List<Widget> basicFields(bool wide) => [
    formField(wide, nameCtrl,     'Homestay Name'),
    formField(wide, locationCtrl, 'Location', hint: 'e.g. Bhaktapur, Kathmandu Valley'),
    formField(wide, descCtrl,     'Description', lines: 4, maxLength: 500),
    categoryDropdown(wide),
  ];

  List<Widget> pricingFields(bool wide) => [
    formField(wide, priceCtrl, 'Price per Night (Rs.)', number: true, hint: 'e.g. 2500'),
    Row(children: [
      Expanded(child: formField(wide, roomsCtrl,  'Rooms',      number: true, hint: '1')),
      SizedBox(width: ffw(10, wide)),
      Expanded(child: formField(wide, guestsCtrl, 'Max Guests', number: true, hint: '2')),
      SizedBox(width: ffw(10, wide)),
      Expanded(child: formField(wide, bathsCtrl,  'Baths',      number: true, hint: '1')),
    ]),
  ];

  List<Widget> heritageFields(bool wide) => [
    formField(wide, cultSigCtrl,  'Cultural Significance', lines: 3, required: false, maxLength: 1600,
        hint: 'e.g. Spiritual importance of the location'),
    formField(wide, buildingCtrl, 'Building History',       lines: 4, maxLength: 1800,
        hint: 'e.g. Built in 1890 by the Newar community'),
    formField(wide, tradFeatCtrl, 'Traditional Features',   lines: 4, maxLength: 1500,
        hint: 'e.g. Carved wood windows, clay courtyard'),
    formField(wide, cultExpCtrl,  'Cultural Experiences',   lines: 4, maxLength: 1500,
        hint: 'e.g. Thangka painting, Mask dance'),
  ];

  List<Widget> amenitySection(bool wide) => [
    Text('Select everything your homestay offers',
        style: GoogleFonts.dmSans(fontSize: ffs(12, wide), color: Colors.grey)),
    SizedBox(height: ffh(12, wide)),
    amenityChips(wide),
  ];

  List<Widget> photoSection(bool wide) => [
    Text('Add up to 4 photos · Tap a slot to upload',
        style: GoogleFonts.dmSans(fontSize: ffs(12, wide), color: Colors.grey)),
    SizedBox(height: ffh(12, wide)),
    Wrap(
      spacing: ffw(12, wide),
      runSpacing: ffh(12, wide),
      children: List.generate(4, (i) => imageBox(wide, i)),
    ),
  ];

  Widget buildSection(bool wide, String title, IconData icon, List<Widget> children) =>
      Container(
        margin: EdgeInsets.only(bottom: ffh(14, wide)),
        padding: EdgeInsets.all(ffw(16, wide)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ffr(16, wide)),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: ffs(18, wide), color: formBrown),
            SizedBox(width: ffw(8, wide)),
            Text(title,
                style: GoogleFonts.dmSans(
                    fontSize: ffs(14, wide), fontWeight: FontWeight.bold)),
          ]),
          SizedBox(height: ffh(14, wide)),
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
        int? maxLength,
      }) =>
      Padding(
        padding: EdgeInsets.only(bottom: ffh(12, wide)),
        child: TextFormField(
          controller: ctrl,
          maxLines: lines,
          maxLength: maxLength,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true) : null,
          style: GoogleFonts.dmSans(fontSize: ffs(14, wide)),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(fontSize: ffs(13, wide)),
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(fontSize: ffs(12, wide), color: Colors.grey[400]),
            counterStyle: GoogleFonts.dmSans(fontSize: ffs(10, wide), color: Colors.grey[400]),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ffr(10, wide)),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ffr(10, wide)),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(ffr(10, wide)),
                borderSide: BorderSide(color: formBrown, width: 1.5)),
            filled: true,
            fillColor: formBg,
            contentPadding: EdgeInsets.symmetric(
                horizontal: ffw(14, wide), vertical: ffh(12, wide)),
          ),
          validator: (v) {
            final val = v?.trim() ?? '';
            if (required && val.isEmpty) return '$label is required';
            if (maxLength != null && val.length > maxLength) {
              return '$label must be $maxLength characters or less';
            }
            return null;
          },
        ),
      );

  Widget categoryDropdown(bool wide) => Padding(
    padding: EdgeInsets.only(bottom: ffh(12, wide)),
    child: DropdownButtonFormField<String>(
      initialValue: selectedCategory,
      style: GoogleFonts.dmSans(fontSize: ffs(14, wide), color: Colors.black87),
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.dmSans(fontSize: ffs(13, wide)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ffr(10, wide)),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ffr(10, wide)),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ffr(10, wide)),
            borderSide: BorderSide(color: formBrown, width: 1.5)),
        filled: true,
        fillColor: formBg,
        contentPadding: EdgeInsets.symmetric(
            horizontal: ffw(14, wide), vertical: ffh(12, wide)),
      ),
      items: categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (val) => setState(() => selectedCategory = val),
    ),
  );

  Widget siteSelector(bool wide) {
    if (sitesLoading) {
      return const Center(child: Padding(
          padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
    }
    if (sites.isEmpty) {
      return Text('No cultural sites available.',
          style: GoogleFonts.dmSans(fontSize: ffs(13, wide), color: Colors.grey));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (selectedSiteId != null)
        Container(
          margin: EdgeInsets.only(bottom: ffh(8, wide)),
          padding: EdgeInsets.symmetric(
              horizontal: ffw(12, wide), vertical: ffh(6, wide)),
          decoration: BoxDecoration(
            color: formBrown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(ffr(8, wide)),
            border: Border.all(color: formBrown.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Icon(Icons.check_circle, color: formBrown, size: ffs(14, wide)),
            SizedBox(width: ffw(6, wide)),
            Text(
              sites.firstWhere((s) => s['id'] == selectedSiteId,
                  orElse: () => {'name': 'Selected'})['name'],
              style: GoogleFonts.dmSans(
                  fontSize: ffs(13, wide),
                  fontWeight: FontWeight.w600,
                  color: formBrown),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => selectedSiteId = null),
              child: Icon(Icons.close, size: ffs(14, wide), color: formBrown),
            ),
          ]),
        ),
      Container(
        height: ffh(180, wide),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(ffr(10, wide)),
          color: formBg,
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
                radius: ffr(16, wide),
                backgroundColor: selected ? formBrown : Colors.grey.shade200,
                child: Icon(Icons.temple_hindu,
                    size: ffs(14, wide),
                    color: selected ? Colors.white : Colors.grey),
              ),
              title: Text(name,
                  style: GoogleFonts.dmSans(
                      fontSize: ffs(13, wide),
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              trailing: selected
                  ? Icon(Icons.check_circle, color: formBrown, size: ffs(18, wide))
                  : null,
              onTap: () => setState(() => selectedSiteId = id),
            );
          },
        ),
      ),
    ]);
  }

  Widget amenityChips(bool wide) => Wrap(
    spacing: ffw(8, wide),
    runSpacing: ffh(8, wide),
    children: allAmenities.map((a) {
      final selected = selectedAmenities.contains(a);
      return FilterChip(
        label: Text(a, style: GoogleFonts.dmSans(fontSize: ffs(12, wide))),
        selected: selected,
        onSelected: (val) => setState(
                () => val ? selectedAmenities.add(a) : selectedAmenities.remove(a)),
        selectedColor: formBrown.withValues(alpha: 0.12),
        checkmarkColor: formBrown,
        side: BorderSide(color: selected ? formBrown : Colors.grey.shade300),
        backgroundColor: formBg,
      );
    }).toList(),
  );

  Widget imageBox(bool wide, int i) {
    final file  = images[i];
    final boxSz = wide ? 110.0 : 100.h;
    return GestureDetector(
      onTap: isLoading ? null : () => pickImage(i),
      child: Container(
        height: boxSz, width: boxSz,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(
              color: file != null ? formBrown : Colors.grey.shade300,
              width: file != null ? 2 : 1),
          borderRadius: BorderRadius.circular(ffr(12, wide)),
        ),
        child: file != null
            ? Stack(fit: StackFit.expand, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(ffr(10, wide)),
            // web uses bytes, mobile/desktop uses file path
            child: kIsWeb
                ? (file.bytes != null
                ? Image.memory(file.bytes!, fit: BoxFit.cover)
                : Container(color: Colors.grey[200]))
                : (file.path != null
                ? Image.file(File(file.path!), fit: BoxFit.cover)
                : Container(color: Colors.grey[200])),
          ),
          if (!isLoading)
            Positioned(
              top: ffh(4, wide), right: ffw(4, wide),
              child: GestureDetector(
                onTap: () => setState(() => images[i] = null),
                child: CircleAvatar(
                  radius: ffr(11, wide),
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close,
                      size: ffs(12, wide), color: Colors.white),
                ),
              ),
            ),
        ])
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add_photo_alternate,
              size: ffs(28, wide), color: Colors.grey[400]),
          SizedBox(height: ffh(4, wide)),
          Text('Photo ${i + 1}',
              style: GoogleFonts.dmSans(
                  fontSize: ffs(10, wide), color: Colors.grey[400])),
        ]),
      ),
    );
  }

  Widget submitButton(bool wide) => ElevatedButton.icon(
    onPressed: submit,
    icon: Icon(Icons.publish, size: ffs(18, wide)),
    label: Text('Upload Homestay',
        style: GoogleFonts.dmSans(
            fontSize: ffs(15, wide), fontWeight: FontWeight.w600)),
    style: ElevatedButton.styleFrom(
      backgroundColor: formBrown,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ffr(12, wide))),
    ),
  );

  Widget uploadButton(bool wide) {
    final hasProgress = uploadProgress != null;
    final pct   = hasProgress ? '${(uploadProgress! * 100).toStringAsFixed(0)}%' : '';
    final label = !hasProgress
        ? 'Preparing...'
        : uploadProgress! < 1.0 ? 'Uploading images  $pct' : 'Saving to server...';
    return Container(
      decoration: BoxDecoration(
          color: formBrown,
          borderRadius: BorderRadius.circular(ffr(12, wide))),
      padding: EdgeInsets.symmetric(horizontal: ffw(20, wide)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            width: ffw(14, wide), height: ffh(14, wide),
            child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white.withValues(alpha: 0.8)),
          ),
          SizedBox(width: ffw(10, wide)),
          Text(label,
              style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontSize: ffs(13, wide),
                  fontWeight: FontWeight.w600)),
        ]),
        if (hasProgress) ...[
          SizedBox(height: ffh(8, wide)),
          ClipRRect(
            borderRadius: BorderRadius.circular(ffr(4, wide)),
            child: LinearProgressIndicator(
              value: uploadProgress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
              minHeight: ffh(4, wide),
            ),
          ),
        ],
      ]),
    );
  }
}