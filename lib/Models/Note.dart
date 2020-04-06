import 'dart:convert';
import 'package:flutter/material.dart';

class Note {
  int id;
  String title;
  String content;
  String category;
  DateTime date_created;
  DateTime date_last_edited;
  Color note_colour;
  int is_archived = 0;

  Note(this.id, this.title, this.content, this.category, this.date_created, this.date_last_edited, this.note_colour);

  Map<String, dynamic> toMap(bool forUpdate) {
    var data = {
      // 'id': id,
      'title': utf8.encode(title),
      'content': utf8.encode(content),
      'category': utf8.encode(category),
      'date_created': epochFromDate(date_created),
      'date_last_edited': epochFromDate(date_last_edited),
      'note-color': note_colour.value,
      'is_archived': is_archived
      };
      if(forUpdate){
        data["id"] = this.id;
      }
      return data;
  }

  int epochFromDate(DateTime dt) {
    return dt.millisecondsSinceEpoch ~/ 1000;
  }

  void archiveThisNote() {
    is_archived = 1;
  }

  @override String toString() {
    // TODO: implement toString
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'date_created': date_created,
      'date_last_edited': date_last_edited,
      'note_colour': note_colour,
      'is_archived': is_archived
    }.toString();
  }
}
