import 'package:flutter/material.dart';
import '../Models/Note.dart';
import '../Models/SqliteHandler.dart';
import 'dart:async';
import '../Models/Utility.dart';
import '../Views/MoreOptionsSheet.dart';
import 'package:share/share.dart';
import 'package:flutter/services.dart';

class NotePage extends StatefulWidget {
  final Note noteInEditing;

  NotePage(this.noteInEditing);
  @override 
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  var note_colour;
  bool _isNewNote = false;
  final _titleFocus = FocusNode();
  final _contentFocus = FocusNode();

  String _titleFromInitial ;
  String _contentFromInitial ;
  DateTime _lastEditedForUndo ;

  var _editableNote;

  Timer _persistanceTimer;

  final GlobalKey<ScaffoldState> _globalKey = new GlobalKey<ScaffoldState>();

  @override 
  void initState() {
    _editableNote = widget.noteInEditing;
    _titleController.text = _editableNote.title;
    _contentController.text = _editableNote.content;
    note_colour = _editableNote.note_colour;
    _lastEditedForUndo = widget.noteInEditing.date_last_edited;

    _titleFromInitial = widget.noteInEditing.title;
    _contentFromInitial = widget.noteInEditing.content;

    if (widget.noteInEditing.id == -1) {
      _isNewNote = true;
    }
    _persistanceTimer = new Timer.periodic(Duration(seconds: 5), (timer) {
      print("5 seconds passed");
      print("editable note id: ${_editableNote.id}");
      _persistData();
    });
  }

  @override 
  Widget build(BuildContext context) {

    if (_editableNote.id == -1 && _editableNote.title.isEmpty) {
      FocusScope.of(context).requestFocus(_titleFocus);
    }

    return WillPopScope(
      child: Scaffold(
        key: _globalKey,
        appBar: AppBar(brightness: Brightness.light,
          leading: BackButton(
            color: Colors.black,
          ),
          actions: _archiveAction(context),
          elevation: 1,
          backgroundColor: note_colour,
          title: _pageTitle(),
          ),
          body: _body(context),
        ),
      onWillPop: _readyToPop,
      );
  }

  Widget _body(BuildContext ctx) {
    return

      Container(
        color: note_colour,
        padding: EdgeInsets.only(left: 16, right: 16, top: 12),
        child: 
        
        SafeArea(child: 
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: Container(
                padding: EdgeInsets.all(5),
                child: EditableText(
                  onChanged: (str) => {updateNoteObject()},
                  maxLines: null,
                  controller: _titleController,
                  focusNode: _titleFocus,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
                  cursorColor: Colors.blue,
                  backgroundCursorColor: Colors.blue),
                ),
              ),

              Divider(color: CentralStation.borderColour,),

              Flexible(child: Container(
                padding: EdgeInsets.all(5),
                child: EditableText(
                  onChanged: (str) => {updateNoteObject()},
                  maxLines: 300,
                  controller: _contentController,
                  focusNode: _contentFocus,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                  cursorColor: Colors.red,
                  backgroundCursorColor: Colors.blue,
                  )
                )
            )
          ],
        ),
        left: true, right: true, top: false, bottom: false,
        ),
      );
  }

  Widget _pageTitle() {
    return Text(_editableNote.id == -1 ? "New Note" : "Edit Note");
  }

  List<Widget> _archiveAction(BuildContext context) {
    List<Widget> actions = [];
    if (widget.noteInEditing.id != -1) {
      actions.add(Padding(padding: EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        child: GestureDetector(
          onTap: () => _undo(),
          child: Icon(
            Icons.undo,
            color: CentralStation.fontColour,
          ),
        ),
      ),
    ));
  }
  actions += [
    Padding(padding: EdgeInsets.symmetric(horizontal: 12),
            child: InkWell(
              child: GestureDetector(
                onTap: () => _archivePopup(context),
                child: Icon(
                  Icons.archive,
                  color: CentralStation.fontColour,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: GestureDetector(
              onTap: () => bottomSheet(context),
              child: Icon(
                Icons.more_vert,
                color: CentralStation.fontColour,
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 12),
          child: InkWell(
            child: GestureDetector(
              onTap: () => { _saveAndStartNewNote(context) },
              child: Icon(
                Icons.add,
                color: CentralStation.fontColour,
                        ),
                  ),
                ),
              ),
  ];
  return actions;
}

void bottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext ctx) {
      return MoreOptionsSheet(
        colour: note_colour,
        callBackColourTapped: _changeColour,
        callBackOptionTapped: bottomSheetOptionTappedHandler,
        date_last_edited: _editableNote.date_last_edited,
      );
    });
}

void _persistData() {
  updateNoteObject();

  if (_editableNote.content.isNotEmpty) {
    var noteDB = NotesDBHandler();

    if (_editableNote.id == -1) {
      Future<int> autoIncrementId = 
        noteDB.insertNote(_editableNote, true);
      autoIncrementId.then((value) {
        _editableNote.id = value;
      });
    } else {
      noteDB.insertNote(
        _editableNote, false
      );
    }
  }
}

void updateNoteObject() {
  _editableNote.content = _contentController.text;
  _editableNote.title = _titleController.text;
  _editableNote.note_colour = note_colour;
  print("new content: ${_editableNote.content}");
  print(widget.noteInEditing);
  print(_editableNote);

  print("same title? ${_editableNote.title == _titleFromInitial}");
  print("same content? ${_editableNote.content == _contentFromInitial}");

  if (!(_editableNote.title == _titleFromInitial &&
          _editableNote.content == _contentFromInitial) || 
          (_isNewNote)) {
            _editableNote.date_last_edited = DateTime.now();
            print("Updateing date_last_edited");
            CentralStation.updateNeeded = true;
          }
}

void bottomSheetOptionTappedHandler(moreOptions tappedOption) {
  print("option tapped: $tappedOption");
  switch (tappedOption) {
    case moreOptions.delete:
    {
      if (_editableNote.id != -1) {
        _deleteNote(_globalKey.currentContext);
      } else {
        _exitWithoutSaving(context);
      }
      break;
    }
    case moreOptions.share: {
      if (_editableNote.content.isNotEmpty) {
        Share.share("${_editableNote.title}\n${_editableNote.content}");
      }
      break;
    }
    case moreOptions.copy : {
      _copy();
      break;
    }
  }
}

void _deleteNote(BuildContext context) {
  if (_editableNote.id != -1) {
    showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm?"),
                  content: Text("This note will be permanently deleted!"),
                  actions: <Widget>[
                    FlatButton( 
                      onPressed: () {
                        _persistanceTimer.cancel();
                        var noteDB = NotesDBHandler();
                        Navigator.of(context).pop();
                        noteDB.deleteNote(_editableNote);
                        CentralStation.updateNeeded = true;

                        Navigator.of(context).pop();
                      },
                      child: Text("Yes")),
                      FlatButton(onPressed: () => {Navigator.of(context).pop()},
                      child: Text("No"))
                  ],
                );
              }); 
  }
}

void _changeColour(Color newColourSelected) {
  print("Note colour changed!");
  setState(() {
    note_colour = newColourSelected;
    _editableNote.note_colour = newColourSelected;
  });
  _persistColourChange();
  CentralStation.updateNeeded = true;
}

void _persistColourChange() {
  if (_editableNote.id != -1) {
    var noteDB = NotesDBHandler();
    _editableNote.note_colour = note_colour;
    noteDB.insertNote(_editableNote, false);
  }
}

void _saveAndStartNewNote(BuildContext context) {
  _persistanceTimer.cancel();
  var emptyNote = new Note(-1, "", "", "", DateTime.now(), DateTime.now(), Colors.white);
  Navigator.of(context).pop();
  Navigator.push(context, MaterialPageRoute(builder: (ctx) => NotePage(emptyNote)));
}

Future<bool> _readyToPop() async {
  _persistanceTimer.cancel();
  // show saved toast after calling function

  _persistData();
  return true;
}

void _archivePopup(BuildContext context) {
  if (_editableNote.id != -1) {
    showDialog(context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Confirm?"),
                  content: Text("This note will be archived!"),
                  actions: <Widget> [
                    FlatButton( 
                      onPressed: () => _archiveThisNote(context),
                      child: Text("Yes")),
                      FlatButton(
                        onPressed: () => {Navigator.of(context).pop()},
                        child: Text("No"))
                  ],
                );
              });         
  } else {
    _exitWithoutSaving(context);
  }
}

void _exitWithoutSaving(BuildContext context) {
  _persistanceTimer.cancel();
  CentralStation.updateNeeded = false;
  Navigator.of(context).pop();
}

void _archiveThisNote(BuildContext context) {
  Navigator.of(context).pop();
  // set flag to true and send entire obj to db to update
  _editableNote.is_archived = 1;
  var noteDB = NotesDBHandler();
  noteDB.archiveNote(_editableNote);
  // update required to remove note from view
  CentralStation.updateNeeded = true;
  _persistanceTimer.cancel(); // shutdown timer

  Navigator.of(context).pop();
  // TODO: Show toast of deletion
  Scaffold.of(context).showSnackBar(new SnackBar(content: Text("Deleted")));
}

void _copy() {
  var noteDB = NotesDBHandler();
  Note copy = Note(-1, _editableNote.title, _editableNote.content, _editableNote.category, DateTime.now(), DateTime.now(), _editableNote.note_colour);

  var status = noteDB.copyNote(copy);
  status.then((query_success) {
    if (query_success) {
      CentralStation.updateNeeded = true;
      Navigator.of(_globalKey.currentContext).pop();
    }
  });
}

void _undo() {
  _titleController.text = _titleFromInitial;
  _contentController.text = _contentFromInitial;
  _editableNote.date_last_edited = _lastEditedForUndo;
}
}