import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:pond_hockey/bloc/login/login_bloc.dart';
import 'package:pond_hockey/bloc/login/login_events.dart';
import 'package:pond_hockey/bloc/login/login_state.dart';
import 'package:pond_hockey/screens/login/create_account.dart';
import 'package:pond_hockey/screens/login/create_account_body.dart';
import 'package:pond_hockey/screens/login/login_form.dart';
import 'package:pond_hockey/screens/login/widgets/auth_buttons.dart';
import 'package:sealed_flutter_bloc/sealed_flutter_bloc.dart';

//class LoginBody extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
//
//    return
//    SealedBlocBuilder3<LoginBloc, LoginState, LoginInitial, LoginLoading,
//        LoginFailure>(
//      builder: (blocContext, states) {
//        return states(
//          (initial) => _LoginUI(),
//          (loading) => Center(child: CircularProgressIndicator()),
//          (failure) {
//            return Container(
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Text(
//                    'Uh oh!',
//                    style: Theme.of(context).textTheme.display2,
//                  ),
//                  Text(
//                    'Something went wrong, try again later.',
//                    style: Theme.of(context).textTheme.display1,
//                  ),
//                ],
//              ),
//            );
//          },
//        );
//      },
//    );
//  }
//}

class LoginBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return SealedBlocBuilder3<LoginBloc, LoginState, LoginInitial, LoginLoading,
        LoginFailure>(
      builder: (blocContext, states) {
        var _loginUi = _LoginUI();
        return states(
          (initial) => initial.isSignUp ? CreateAccountBody() : _loginUi,
          (loading) => Center(child: CircularProgressIndicator()),
          (failure) {
            Scaffold.of(context).hideCurrentSnackBar();
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text('An error occured'),
              duration: Duration(seconds: 2),
            ));
            return failure.isSignUp ? CreateAccountBody() : _loginUi;
          },
        );
      },
    );
  }
}

class _LoginUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF757F9A),
                  Color(0xFFD7DDE8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      LoginForm(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Forgot password?',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          FlatButton(
                            onPressed: () {
                              BlocProvider.of<LoginBloc>(context).add(
                                ToggleUiButtonPressed(isSignUp: true),
                              );
                            },
                            child: Text("Create Account"),
                          ),
                        ],
                      ),
                      const Divider(
                        thickness: 2,
                        color: Colors.black,
                        indent: 5,
                        endIndent: 5,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Or sign in with these providers',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GoogleSignInButton(
                            onPressed: () async {
                              await BlocProvider.of<LoginBloc>(context)
                                  .signInWithGoogle()
                                  .catchError((error) {
                                Scaffold.of(context).hideCurrentSnackBar();
                                Scaffold.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Sign in with google failed'),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              });
                            },
                          ),
                          AppleSignInButton(
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF757F9A),
                  Color(0xFFD7DDE8),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        LoginForm(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text(
                              'Forgot password?',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            FlatButton(
                              onPressed: () {
                                BlocProvider.of<LoginBloc>(context).add(
                                  ToggleUiButtonPressed(isSignUp: true),
                                );
                              },
                              child: Text("Create Account"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  indent: 30,
                  endIndent: 30,
                  thickness: 5,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Or sign in with these providers',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      GoogleSignInButton(
                        onPressed: () {
                          try {
                            BlocProvider.of<LoginBloc>(context)
                                .signInWithGoogle();
                          } on Exception {
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An error occured'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        },
                      ),
                      AppleSignInButton(
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
