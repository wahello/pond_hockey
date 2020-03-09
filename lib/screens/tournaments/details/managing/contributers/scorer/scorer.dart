import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pond_hockey/models/tournament.dart';

class ManageScorers extends StatelessWidget {
  ManageScorers({this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("tournaments")
          .document(tournamentId)
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
            return buildView(snapshot,context);
          case ConnectionState.done:
            return buildView(snapshot,context);
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
      var _tournament = Tournament.fromDocument(snapshot.data);
      if (_tournament.scorers == null) {
        return ListView(
          children: <Widget>[
            _newScorer(context),
            SizedBox(
              height: 50.0,
            ),
            Center(child: Text("There are no scorers.")),
          ],
        );
      }
      return Column(
        children: <Widget>[
          ListView.builder(
            shrinkWrap: true,
            itemCount: _tournament.scorers.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(Icons.person),
                  radius: 30.0,
                ),
                title: Text(_tournament.name),
                subtitle: Text(_tournament.scorers[index]['email']),
                trailing: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.delete,
                      color: Color(0xFF167F67),
                    ),
                  ),
                  onTap: () {},
                ),
                onTap: () {
                  showDialog(context: context,builder: (_){
                    return ScorerDialog(isEdit: true,);
                  });
                },
              );
            },
          ),
          Divider(),
          _newScorer(context)
        ],
      );
    } else {
      return Center(
        child: Text("Uh oh! Something went wrong"),
      );
    }
  }

  Widget _newScorer(BuildContext context) {
    return ListTile(
      title: Text("New scorer"),
      subtitle: Text("Tap here to add new scorer"),
      leading: CircleAvatar(
        child: Icon(Icons.add),
        radius: 30.0,
      ),
      onTap: () {
        showDialog(context: context,builder: (_){
          return ScorerDialog(isEdit: false,);
        });
      },
    );
  }
}

class ScorerDialog extends StatefulWidget {
  ScorerDialog({this.isEdit});
  final bool isEdit;
  @override
  State<StatefulWidget> createState() {
    return _ScorerDialogState();
  }

}

class _ScorerDialogState extends State<ScorerDialog> {
  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isEdit ? 'Edit detail!': 'Add Scorer'),
      content: Wrap(
        children: <Widget>[
          TextField(
            controller: _emailController,
            decoration: InputDecoration(hintText: "Email"),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {},
          child: Text(widget.isEdit ? "Edit" : "Add"),
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