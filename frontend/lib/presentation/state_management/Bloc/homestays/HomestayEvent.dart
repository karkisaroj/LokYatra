import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class HomestayEvent extends Equatable {
  const HomestayEvent();

  @override
  List<Object> get props => [];
}

// Owner events
class OwnerLoadMyHomestays extends HomestayEvent {
  const OwnerLoadMyHomestays();
}

class OwnerUpdateHomestay extends HomestayEvent {
  final int id;
  final Map<String, dynamic> fields;
  final List<PlatformFile> files;

  const OwnerUpdateHomestay({
    required this.id,
    required this.fields,
    this.files = const [],
  });

  @override
  List<Object> get props => [id, fields, files];
}

// Tourist events
class TouristLoadAllHomestays extends HomestayEvent {
  const TouristLoadAllHomestays();
}

class TouristLoadHomestaysNearSite extends HomestayEvent {
  final String siteName;
  const TouristLoadHomestaysNearSite(this.siteName);

  @override
  List<Object> get props => [siteName];
}

class ResetHomestayState extends HomestayEvent {
  const ResetHomestayState();
}

// ── NEW ADMIN EVENTS ──
class AdminDeleteHomestay extends HomestayEvent {
  final int id;
  const AdminDeleteHomestay(this.id);

  @override
  List<Object> get props => [id];
}

class AdminToggleHomestayVisibility extends HomestayEvent {
  final int id;
  final bool isVisible;
  const AdminToggleHomestayVisibility(this.id, this.isVisible);

  @override
  List<Object> get props => [id, isVisible];
}