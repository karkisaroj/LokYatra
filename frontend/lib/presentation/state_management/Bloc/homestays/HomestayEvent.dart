import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lokyatra_frontend/data/models/Homestay.dart';

abstract class HomestayEvent extends Equatable {
  const HomestayEvent();

  @override
  List<Object> get props => [];
}

class LoadMyHomestays extends HomestayEvent {
  const LoadMyHomestays();
}

class UpdateHomestay extends HomestayEvent {
  final int id;
  final Map<String, dynamic> fields;
  final List<PlatformFile> files;

  const UpdateHomestay({
    required this.id,
    required this.fields,
    this.files = const [],
  });

  @override
  List<Object> get props => [id, fields, files];
}