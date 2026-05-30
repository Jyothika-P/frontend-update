import 'package:flutter/material.dart';
import 'package:psychesail/components/text.dart';
import 'package:psychesail/components/vertical_scroll.dart';
import 'package:psychesail/model/places.dart';

class ActivityMapsWidget extends StatefulWidget {
  final double sizeWidth;
  final double sizeHeight;
  final bool constr;
  final List<dynamic> pos;
  final dynamic con;
  final String activityString;
  final String currentUserId;
  final dynamic arr;

  const ActivityMapsWidget(
      {Key? key,
      required this.sizeWidth,
      required this.sizeHeight,
      required this.constr,
      required this.pos,
      required this.con,
      required this.activityString,
      required this.currentUserId,
      required this.arr})
      : super(key: key);

  @override
  State<ActivityMapsWidget> createState() => _ActivityMapsWidgetState();
}

class _ActivityMapsWidgetState extends State<ActivityMapsWidget> {
  String? _selectedHeading;
  String? _selectedImagestring;
  Map<String, dynamic>? _selectedPlaces;
  bool _loading = false;

  Future<void> _selectCategory(String heading, String imagestring) async {
    setState(() {
      _selectedHeading = heading;
      _selectedImagestring = imagestring;
      _loading = true;
    });

    final placeHelper = Places();
    final categories = placeHelper.getCategoriesFor(heading);
    final result = await searchNearbyPlaces(categories, widget.pos);

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedPlaces = result is Map<String, dynamic>
          ? result
          : <String, dynamic>{'features': []};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        activityscroll(
          widget.con,
          widget.sizeWidth,
          widget.sizeHeight,
          widget.constr,
          widget.activityString,
          widget.arr,
          widget.pos,
          onCategoryTap: _selectCategory,
          selectedHeading: _selectedHeading,
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
        if (_selectedPlaces != null)
          activitymaps(
            widget.sizeWidth,
            widget.sizeHeight,
            widget.constr,
            _selectedPlaces,
            _selectedImagestring ?? '',
          ),
      ],
    );
  }
}
