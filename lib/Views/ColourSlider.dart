import 'package:flutter/material.dart';

class ColourSlider extends StatefulWidget {
  final void Function(Color) callBackColourTapped;
  final Color noteColour;
  ColourSlider({@required this.callBackColourTapped, @required this.noteColour});
  @override
  _ColourSliderState createState() => _ColourSliderState();
}

class _ColourSliderState extends State<ColourSlider> {

  final colours = [
    Color(0xffffffff), // classic white
    Color(0xfff28b81), // light pink
    Color(0xfff7bd02), // yellow
    Color(0xfffbf476), // light yellow
    Color(0xffcdff90), // light green
    Color(0xffa7feeb), // turquoise
    Color(0xffcbf0f8), // light cyan
    Color(0xffafcbfa), // light blue
    Color(0xffd7aefc), // plum
    Color(0xfffbcfe9), // misty rose
    Color(0xffe6c9a9), // light brown
    Color(0xffe9eaee)  // light gray
  ];

  final Color borderColor = Color(0xffd3d3d3);
  final Color foregroundColor = Color(0xff595959);

  final _check = Icon(Icons.check);

  Color noteColour;
  int indexOfCurrentColour;
  @override void initState() {

    super.initState();
    this.noteColour = widget.noteColour;
    indexOfCurrentColour = colours.indexOf(noteColour);
  }




  @override 
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: 
      List.generate(colours.length, (index) {
        return
          GestureDetector(
            onTap: () => _colourChangeTapped(index),
            child: Padding( 
              padding:EdgeInsets.only(left: 6, right: 6),
              child: Container(
                child: new CircleAvatar(
                  child: _checkOrNot(index),
                  foregroundColor: foregroundColor,
                  backgroundColor: colours[index],
                ),
                width: 38.0,
                height: 38.0,
                padding: const EdgeInsets.all(1.0),
                decoration: new BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                )
              )
            )
          );
      })
    ,);
  }

  void _colourChangeTapped(int indexOfColour) {
    setState(() {
      noteColour = colours[indexOfColour];
      indexOfCurrentColour = indexOfColour;
      widget.callBackColourTapped(colours[indexOfColour]);
    });
  }

  Widget _checkOrNot(int index) {
    if (indexOfCurrentColour == index) {
      return _check;
    }
    return null;
  }
}