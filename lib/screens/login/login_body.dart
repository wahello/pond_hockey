import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:pond_hockey/bloc/login/login_bloc.dart';
import 'package:pond_hockey/bloc/login/login_events.dart';
import 'package:pond_hockey/bloc/login/login_state.dart';
import 'package:pond_hockey/screens/login/create_account_body.dart';
import 'package:pond_hockey/screens/login/forget.dart';
import 'package:pond_hockey/screens/login/login_form.dart';
import 'package:pond_hockey/screens/login/verification.dart';
import 'package:pond_hockey/screens/login/widgets/auth_buttons.dart';
import 'package:pond_hockey/services/apple/apple_available.dart';
import 'package:sealed_flutter_bloc/sealed_flutter_bloc.dart';

class LoginBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return SealedBlocBuilder4<LoginBloc, LoginState, LoginInitial, LoginLoading,
        LoginFailure, LoginUnverified>(
      builder: (blocContext, states) {
        var _loginUi = _LoginUI();
        var _signUp = CreateAccountBody();
        return states(
          (initial) => initial.isSignUp ? _signUp : _loginUi,
          (loading) => Center(child: CircularProgressIndicator()),
          (failure) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(failure.error),
                  duration: Duration(seconds: 2),
                ),
              );
            });

            return failure.isSignUp ? _signUp : _loginUi;
          },
          (unverified) => EmailVerification(unverified.user),
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
                          FlatButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ForgetPassword(context),
                                    fullscreenDialog: true),
                              );
                            },
                            child: Text(
                              'Forgot password?',
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              BlocProvider.of<LoginBloc>(context).add(
                                ToggleUiButtonPressed(isSignUp: true),
                              );
                            },
                            child: Text(
                              "Create Account",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
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
                            onPressed: () async {
                              final appleSignInAvailable =
                                  await AppleSignInAvailable.check();
                              if (appleSignInAvailable.isAvailable) {
                                await BlocProvider.of<LoginBloc>(context)
                                    .signInWithApple()
                                    .catchError((error) {
                                  Scaffold.of(context).hideCurrentSnackBar();
                                  Scaffold.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error.toString()),
                                      duration: Duration(seconds: 5),
                                    ),
                                  );
                                });
                              }
                            },
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
                        onPressed: () async {
                          await BlocProvider.of<LoginBloc>(context)
                              .signInWithGoogle()
                              .catchError((error) {
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('An error occured'),
                                duration: Duration(seconds: 5),
                              ),
                            );
                          });
                        },
                      ),
                      AppleSignInButton(
                        onPressed: () async {
                          final appleSignInAvailable =
                              await AppleSignInAvailable.check();
                          if (appleSignInAvailable.isAvailable) {
                            await BlocProvider.of<LoginBloc>(context)
                                .signInWithApple()
                                .catchError((error) {
                              Scaffold.of(context).hideCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.toString()),
                                  duration: Duration(seconds: 5),
                                ),
                              );
                            });
                          }
                        },
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
