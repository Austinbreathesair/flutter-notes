import 'package:flutter/material.dart';
import 'ColourSlider.dart';
import '../Models/Utility.dart';

enum moreOptions { delete, share, copy }

class MoreOptionsSheet extends StatefulWidget {
  final Color colour;
  final DateTime date_last_edited;
  final void Function(Color) callBackColourTapped;
  final void Function(moreOptions) callBackOptionTapped;

  const MoreOptionsSheet(
    {Key key,
    this.colour,
    this.date_last_edited,
    this.callBackColourTapped,
    this.callBackOptionTapped})
    : super(key: key);

  @override 
  _MoreOptionsSheetState createState() => _MoreOptionsSheetState();
}

class _MoreOptionsSheetState extends State<MoreOptionsSheet> {
  var note_colour;

  @override
  void initState() {
    note_colour = widget.colour;
  }

  @override 
  Widget build(BuildContext context) {
    return Container(
      color: this.note_colour,
      child: new Wrap(
        children: <Widget>[
          new ListTile( 
            leading: new Icon(Icons.delete),
            title: new Text('Delete'),
            onTap: () {
              Navigator.of(context).pop();
              widget.callBackOptionTapped(moreOptions.delete);
            }),
          new ListTile(
            leading: new Icon(Icons.content_copy),
            title: new Text('Copy'),
            onTap: () {
              Navigator.of(context).pop();
              widget.callBackOptionTapped(moreOptions.copy);
            }),
          new ListTile(
            leading: new Icon(Icons.share),
            title: new Text('Share'),
            onTap: () {
              Navigator.of(context).pop();
              widget.callBackOptionTapped(moreOptions.share);
            }),
          new Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: SizedBox( 
              height: 44,
              width: MediaQuery.of(context).size.width,
              child: ColourSlider(callBackColourTapped: _changeColour, noteColour: note_colour),
            ),
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 44,
                child: Center( 
                  child: Text(CentralStation.stringForDateTime(
                    widget.date_last_edited))),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
          new ListTile()
        ],
      ),
    );
  }

  void _changeColour(Color colour) {
    setState(() {
      this.note_colour = colour;
      widget.callBackColourTapped(colour);
    });
  }
}