import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:pond_hockey/components/appbar/appbar.dart';
import 'package:pond_hockey/components/buttons/big_circle_btn.dart';
import 'package:pond_hockey/components/form/background.dart';
import 'package:pond_hockey/enums/game_status.dart';
import 'package:pond_hockey/models/tournament.dart';
import 'package:pond_hockey/router/router.gr.dart';
import 'package:pond_hockey/services/databases/tournaments_repository.dart';
import 'package:pond_hockey/services/databases/user_repository.dart';
import 'package:pond_hockey/utils/date_utils.dart';
import 'package:uuid/uuid.dart';

class AddTournamentScreen extends StatelessWidget {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Tournament',
        transparentBackground: true,
      ),
      extendBodyBehindAppBar: true,
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6464), Color(0xFFFFACAC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: ListView(
                primary: false,
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  SvgPicture.asset(
                    'assets/svg/create_tournament.svg',
                    height: MediaQuery.of(context).size.width * 0.35,
                  ),
                  _AddTournamentForm(
                    orientation: orientation,
                    formKey: _formKey,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddTournamentForm extends StatefulWidget {
  const _AddTournamentForm({this.orientation, this.formKey});

  final Orientation orientation;
  final GlobalKey<FormBuilderState> formKey;

  @override
  _AddTournamentFormState createState() => _AddTournamentFormState();
}

class _AddTournamentFormState extends State<_AddTournamentForm> {
  final TextEditingController _nameController = TextEditingController(text: '');
  final TextEditingController _detailsController =
      TextEditingController(text: '');
  final TextEditingController _locationController =
      TextEditingController(text: '');

  @override
  void dispose() {
    _nameController.dispose();
    _detailsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void submitForm() async {
    final name = _nameController.text.trim();
    final details = _detailsController.text.trim();
    final location = _locationController.text.trim();
    final dates = widget.formKey.currentState.fields['tournament-dates']
        .currentState.value as List<DateTime>;

    final tournament = Tournament(
      details: details,
      name: name,
      location: location,
      startDate: dates[0].onlyDate,
      endDate: dates.length == 2 ? dates[1].onlyDate : dates[0].onlyDate,
      id: Uuid().v4(),
      status: GameStatus.notStarted,
      year: dates[0].year,
      owner: (await FirebaseAuth.instance.currentUser()).uid,
      scorers: null,
    );
    TournamentsRepository().addTournament(tournament);
    await UserRepository().spendCredit();
    Router.navigator.pushReplacementNamed(Routes.tournaments);
  }

  @override
  Widget build(BuildContext context) {
    const defaultDecoration = InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 0,
      ),
    );

    final fieldHeight = MediaQuery.of(context).size.height * 0.1;
    final landscapeFieldHeight = MediaQuery.of(context).size.height * 0.13;

    double getFieldHeight() {
      if (widget.orientation == Orientation.portrait) {
        return fieldHeight;
      } else {
        return landscapeFieldHeight;
      }
    }

    return SizedBox(
      width: widget.orientation == Orientation.portrait
          ? MediaQuery.of(context).size.width * 0.75
          : null,
      child: FormBuilder(
        key: widget.formKey,
        child: Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            FormFieldBackground(
              height: getFieldHeight(),
              field: FormBuilderTextField(
                attribute: 'tournament-name',
                controller: _nameController,
                style: Theme.of(context).textTheme.subtitle1,
                decoration: defaultDecoration.copyWith(
                  hintText: 'Name',
                ),
                validators: [
                  FormBuilderValidators.required(),
                ],
              ),
            ),
            FormFieldBackground(
              height: getFieldHeight(),
              field: FormBuilderTextField(
                attribute: 'tournament-location',
                controller: _locationController,
                style: Theme.of(context).textTheme.subtitle1,
                decoration: defaultDecoration.copyWith(
                  hintText: 'Location',
                ),
                validators: [
                  FormBuilderValidators.required(),
                ],
              ),
            ),
            FormFieldBackground(
              height: getFieldHeight(),
              field: FormBuilderDateRangePicker(
                attribute: 'tournament-dates',
                decoration: defaultDecoration.copyWith(
                  hintText: 'Dates',
                ),
                firstDate: DateTime.now().onlyDate,
                lastDate: DateTime.now().onlyDate.add(Duration(days: 365)),
                format: DateFormat.yMMMd(),
                validators: [
                  FormBuilderValidators.required(),
                ],
              ),
            ),
            FormFieldBackground(
              height: MediaQuery.of(context).size.height * 0.17,
              bottom: true,
              field: TextFormField(
                controller: _detailsController,
                maxLines: null,
                expands: true,
                style: Theme.of(context).textTheme.subtitle1,
                decoration: defaultDecoration.copyWith(
                  hintText: 'Details',
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text('This will deduct one credit from your account.'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            BigCircleButton(
              text: 'Create',
              onTap: () {
                if (widget.formKey.currentState.validate()) {
                  FocusScope.of(context).unfocus();
                  submitForm();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
