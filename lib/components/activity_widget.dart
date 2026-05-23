import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    Places place = Provider.of<Places>(context);
    // print(place.getPlace());
    return Consumer<Places>(builder: (context, place, child) {
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
              widget.currentUserId,
              place),
          if (place.getremove())
            activitymaps(widget.sizeWidth, widget.sizeHeight, widget.constr,
                place.getObject(), place.getImagestring()),
        ],
      );
    });
  }
}
