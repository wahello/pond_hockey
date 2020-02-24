import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pond_hockey/components/appbar/appbar.dart';
import 'package:pond_hockey/router/router.gr.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar(
        title: '',
        transparentBackground: true,
        actions: <Widget>[
          FlatButton(
            color: Colors.white,
            onPressed: () async {
              Router.navigator.pushNamed(Router.account);
            },
            child: Text("Account"),
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/largebg.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/img/pondhockeybrand.png'),
                      const SizedBox(height: 25),
                      const Divider(
                        color: Colors.white,
                        thickness: 15,
                        indent: 20,
                        endIndent: 20,
                      ),
                      const SizedBox(height: 25),
                      _PortraitMenuButton(
                        onPressed: () {
                          Router.navigator.pushNamed(Router.tournaments);
                        },
                        text: 'View Results',
                      ),
                      const SizedBox(height: 30),
                      _PortraitMenuButton(
                        onPressed: () {
                          Router.navigator.pushNamed(
                            Router.tournaments,
                            arguments: TournamentsScreenArguments(
                              scoringMode: true,
                            ),
                          );
                        },
                        text: 'Score Games',
                      ),
                      const SizedBox(height: 30),
                      _PortraitMenuButton(
                        onPressed: () {
                          Router.navigator.pushNamed(
                            Router.tournaments,
                            arguments: TournamentsScreenArguments(
                              editMode: true,
                            ),
                          );
                        },
                        text: 'Manage Tournaments',
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(width: 25),
                      Image.asset('assets/img/pondhockeybrand.png'),
                      const SizedBox(width: 25),
                      const VerticalDivider(
                        color: Colors.white,
                        thickness: 15,
                        indent: 20,
                        endIndent: 20,
                      ),
                      const SizedBox(width: 25),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _LandscapeMenuButton(
                            onPressed: () {
                              Router.navigator.pushNamed(Router.tournaments);
                            },
                            text: 'View Results',
                          ),
                          const SizedBox(height: 30),
                          _LandscapeMenuButton(
                            onPressed: () {
                              Router.navigator.pushNamed(
                                Router.tournaments,
                                arguments: TournamentsScreenArguments(
                                  scoringMode: true,
                                ),
                              );
                            },
                            text: 'Score Games',
                          ),
                          const SizedBox(height: 30),
                          _LandscapeMenuButton(
                            onPressed: () {
                              Router.navigator.pushNamed(
                                Router.tournaments,
                                arguments: TournamentsScreenArguments(
                                  scoringMode: false,
                                  editMode: true,
                                ),
                              );
                            },
                            text: 'Manage Tournaments',
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LandscapeMenuButton extends StatelessWidget {
  const _LandscapeMenuButton({
    Key key,
    this.onPressed,
    this.text,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    var btnSize = MediaQuery.of(context).size.width * 0.35;
    var fontSize = MediaQuery.of(context).size.width * 0.03;

    return Container(
      width: btnSize,
      child: RaisedButton(
        onPressed: onPressed,
        color: Colors.white,
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}

class _PortraitMenuButton extends StatelessWidget {
  const _PortraitMenuButton({
    Key key,
    this.onPressed,
    this.text,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    var btnSize = MediaQuery.of(context).size.width * 0.75;
    var fontSize = MediaQuery.of(context).size.width * 0.06;

    return Container(
      width: btnSize,
      child: RaisedButton(
        onPressed: onPressed,
        color: Colors.white,
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
