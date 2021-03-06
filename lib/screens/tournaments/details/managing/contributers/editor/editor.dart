import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:pond_hockey/components/dialog/dialog_buttons.dart';
import 'package:pond_hockey/models/tournament.dart';
import 'package:pond_hockey/router/router.gr.dart';

class ManageEditors extends StatefulWidget {
  ManageEditors({this.tournamentId});
  final String tournamentId;

  @override
  State<StatefulWidget> createState() {
    return _EditorState();
  }
}

class _EditorState extends State<ManageEditors> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("tournaments")
          .document(widget.tournamentId)
          .snapshots(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Center(
              child: Text("Uh oh! Something went wrong"),
            );
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          case ConnectionState.active:
            return buildView(snapshot, context);
          case ConnectionState.done:
            return buildView(snapshot, context);
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('??'),
            Text('How\'d you get here?!'),
          ],
        );
      },
    );
  }

  Widget buildView(AsyncSnapshot snapshot, BuildContext context) {
    if (snapshot.hasData) {
      var tournament = Tournament.fromDocument(snapshot.data);
      if (tournament.editors == null) {
        return ListView(
          children: <Widget>[
            _newEditor(context),
            SizedBox(
              height: 50.0,
            ),
            Align(
              alignment: Alignment.center,
              child: Text("There are no editors."),
            ),
          ],
        );
      }
      return Column(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemCount: tournament.editors.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 30.0,
                ),
                title: Text(tournament.editors[index]['email']),
                trailing: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                      color: Color(0xFF167F67),
                    ),
                  ),
                  onTap: () {
                    _deleteUserDialog(tournament, index);
                  },
                ),
              );
            },
          ),
          Divider(),
          _newEditor(context),
        ],
      );
    } else {
      return Center(
        child: Text("Uh oh! Something went wrong"),
      );
    }
  }

  void _deleteUserDialog(Tournament tournament, int index) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text("Are you sure to remove this user?"),
        actions: <Widget>[
          SecondaryDialogButton(
            text: 'Cancel',
            onPressed: Router.navigator.pop,
          ),
          PrimaryDialogButton(
            text: 'Yes',
            onPressed: () async {
              try {
                await Firestore.instance
                    .collection("tournaments")
                    .document(widget.tournamentId)
                    .setData({
                  'editors': FieldValue.arrayRemove([tournament.editors[index]])
                }, merge: true);

                ///here delete data
                Router.navigator.pop();
                // ignore: avoid_catches_without_on_clauses
              } catch (error) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.code),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _newEditor(BuildContext context) {
    return ListTile(
      title: Text("New editor"),
      subtitle: Text("Tap here to add new editor"),
      leading: CircleAvatar(
        child: Icon(Icons.add),
        radius: 30.0,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return EditorDialog(
              tournamentId: widget.tournamentId,
            );
          },
        );
      },
    );
  }
}

class EditorDialog extends StatefulWidget {
  EditorDialog({@required this.tournamentId});
  final String tournamentId;

  @override
  State<StatefulWidget> createState() {
    return _EditorDialogState();
  }
}

class _EditorDialogState extends State<EditorDialog> {
  var database = Firestore.instance;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var isProcessing = false;
  String errorMessage;

  void _addEditor() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        isProcessing = true;
      });

      try {
        final documents = await database.collection("users").getDocuments();
        String uid;
        for (final doc in documents.documents) {
          if (doc.data["email"] == _emailController.text.trim()) {
            uid = doc["uid"];
          }
        }
        if (uid != null) {
          await database
              .collection("tournaments")
              .document(widget.tournamentId)
              .setData({
            "editors": FieldValue.arrayUnion([
              {"email": _emailController.text, "uid": uid}
            ])
          }, merge: true);
          Navigator.of(context).pop();
        } else {
          setState(() {
            errorMessage = "No account with that email";
            isProcessing = false;
          });
        }
      }
      // ignore: avoid_catches_without_on_clauses
      catch (error) {
        setState(() {
          errorMessage = error.code;
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add editor'),
      scrollable: true,
      content: Column(
        children: <Widget>[
          isProcessing ? LinearProgressIndicator() : SizedBox.shrink(),
          Form(
            key: _formKey,
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                errorText: errorMessage,
                focusedBorder: UnderlineInputBorder(),
              ),
              validator: FormBuilderValidators.email(
                errorText: 'Invalid email',
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: _addEditor,
          child: Text("Add"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
