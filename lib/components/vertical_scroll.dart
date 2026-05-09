import 'dart:math';

import 'package:flutter/material.dart';
import 'package:psychesail/components/crud.dart';
import 'package:psychesail/components/text.dart';
import 'package:psychesail/components/video.dart';
import 'package:psychesail/model/emoji.dart';
import 'package:psychesail/pages/join_room.dart';
import 'package:psychesail/pages/room_screen.dart';

Widget communityscroll(
    sizeWidth, sizeHeight, constr, title, arr, currentid, context) {
  print(arr);
  print(currentid);
  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.000067,
                fontWeight: FontWeight.bold),
          ),
          Text("See All", style: TextStyle(color: Colors.black)),
        ],
      ),
      SizedBox(
        height: sizeHeight * 0.01,
      ),
      SizedBox(
        height: sizeHeight * 0.27,
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: arr.length - 1,
          itemBuilder: (context, index) {
            return communityContainer(
                sizeWidth,
                sizeHeight,
                constr,
                arr[arr.length - 2 - index].id,
                arr[arr.length - 2 - index]['description'],
                arr[arr.length - 2 - index]['url'],
                currentid,
                context);
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}

Widget youtubescroll(
    sizeWidth, sizeHeight, constr, title, arr, currentid, context) {
  print(arr);
  print(currentid);
  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.white,
                fontSize: sizeWidth * sizeHeight * 0.000067,
                fontWeight: FontWeight.bold),
          ),
          Text("See All", style: TextStyle(color: Colors.white)),
        ],
      ),
      SizedBox(
        height: sizeHeight * 0.01,
      ),
      Container(
        constraints: BoxConstraints(
          maxHeight: sizeHeight * 0.5,
        ),
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: arr.length,
          itemBuilder: (context, index) {
            return youtubeContainer(
              sizeWidth,
              sizeHeight,
              constr,
              arr[arr.length - 1 - index].title,
              arr[arr.length - 1 - index].views,
              arr[arr.length - 1 - index].thumbnails.first.url,
              arr[arr.length - 1 - index].videoId,
            );
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}

Widget bookscroll(
    sizeWidth, sizeHeight, constr, title, arr, currentid, context) {
  print(arr);
  print(currentid);
  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: sizeWidth * sizeHeight * 0.000067,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text("See All",
              style: TextStyle(
                color: Colors.white,
              )),
        ],
      ),
      SizedBox(
        height: sizeHeight * 0.01,
      ),
      Container(
        constraints: BoxConstraints(
          maxHeight: sizeHeight * 0.5,
        ),
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: arr.length,
          itemBuilder: (context, index) {
            return bookContainer(
                sizeWidth,
                sizeHeight,
                constr,
                arr[arr.length - 1 - index].title,
                arr[arr.length - 1 - index].description,
                arr[arr.length - 1 - index].imageLinks.isNotEmpty
                    ? arr[arr.length - 1 - index].imageLinks.first.url
                    : '',
                '');
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}

Widget callingscroll(sizeWidth, sizeHeight, constr, title, arr, user) {
  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.000067,
                fontWeight: FontWeight.bold),
          ),
          Text("See All", style: TextStyle(color: Colors.black)),
        ],
      ),
      SizedBox(
        height: sizeHeight * 0.01,
      ),
      SizedBox(
        height: sizeHeight * 0.27,
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: arr.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomScreen(
                      roomId: arr[arr.length - 1 - index][1],
                      token: token,
                      leaveRoom: () => {},
                      currentId: user,
                      userId: arr[arr.length - 1 - index][0]),
                ),
              ),
              child: callingContainer(sizeWidth, sizeHeight, constr,
                  arr[arr.length - 1 - index][0]),
            );
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}

Widget activityscroll(context, sizeWidth, sizeHeight, constr, title, arr, pos,
    currentUserId, place) {
  print(pos);

  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.000067,
                fontWeight: FontWeight.bold),
          ),
          Text("See All", style: TextStyle(color: Colors.black)),
        ],
      ),
      SizedBox(
        height: sizeHeight * 0.01,
      ),
      SizedBox(
        height: sizeHeight * 0.15,
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: arr.length,
          itemBuilder: (context, index) {
            return activityContainer(
                context,
                sizeWidth,
                sizeHeight,
                constr,
                arr[arr.length - 1 - index].id,
                arr[arr.length - 1 - index]['url'],
                pos,
                currentUserId,
                place);
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}

Widget historyscroll(
    sizeWidth, sizeHeight, constr, title, arr, context, currentUser) {
  Emoji stressEmoji = Emoji();

  return Wrap(
    spacing: 20,
    runSpacing: min(20, sizeWidth * 0.0006),
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.black,
                fontSize: sizeWidth * sizeHeight * 0.000067,
                fontWeight: FontWeight.bold),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/progress', arguments: {
              'currentuser': currentUser,
              'historycollection': arr
            }),
            child: Text("See All", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      Container(
        constraints: BoxConstraints(
          maxHeight: sizeHeight * 0.2,
        ),
        child: ListView.separated(
          reverse: false,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemCount: arr.length,
          itemBuilder: (context, index) {
            return (arr[index].length == 0)
                ? Container(
                    width: sizeWidth,
                    child: Center(
                        child: Text(
                      "Start Journey with Serenity....",
                      style: TextStyle(color: Colors.black),
                    )))
                : historyContainer(
                    sizeWidth,
                    sizeHeight,
                    true,
                    arr[index][0],
                    arr[index][1],
                    stressEmoji.stressEmoji((index + 1).toString()),
                    false);
          },
          separatorBuilder: ((context, index) => SizedBox(
                width: min(sizeWidth * 0.05, 30),
              )),
        ),
      )
    ],
  );
}
