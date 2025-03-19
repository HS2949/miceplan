import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mice_plan/constants/styles.dart';
import 'package:mice_plan/utils/widget_help.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import '../../../config/router/route_names.dart';
import '../../../models/custom_error.dart';
import '../../../utils/error_dialog.dart';
import 'signup_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  _SignupPageState(
    // {
    // required this._formKey,
    // required this._autovalidateMode,
    // required this._nameController,
    // required this._emailController,
    // required this._positionController,
    // required this._passwordController1,
    // required this._passwordController2,
    // }
  );
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _positionController = TextEditingController();
  final _passwordController1 = TextEditingController();
  final _passwordController2 = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _positionController.dispose();
    _passwordController1.dispose();
    _passwordController2.dispose();
    super.dispose();
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
  }

  void _submit() {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    ref
        .read(signupProvider.notifier)
        .signup(
          name: _nameController.text.trim(),
          position: _positionController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController1.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(signupProvider, (prev, next) {
      next.whenOrNull(
        data: (_) async {
          await _saveEmail(_emailController.text.trim()); // 이메일 저장
        },
        error: (e, st) => errorDialog(context, (e as CustomError)),
      );
    });

    final signupState = ref.watch(signupProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Sign Up'),
          centerTitle: true,
        ),
        body: Center(
          child: SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: ListView(
                  shrinkWrap: true,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  children:
                      [
                        SizedBox(height: 50.0),
                        Image.asset(
                          'assets/images/miceplan_font.png',
                          width: 250,
                          height: 60,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 10.0),
                        Center(
                          child: Text(
                            '사용자 등록',
                            style: AppTheme.titleMediumTextStyle,
                          ),
                        ),
                        SizedBox(height: 50.0),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Email',
                            hintText: '이메일을 입력해 주세요.',
                            prefixIcon: Icon(Icons.email_outlined),
                            suffixIcon: ClearButton(
                              controller: _emailController,
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return '이메일 주소가 필요합니다';
                            }
                            if (!isEmail(value.trim())) {
                              return '유효한 이메일 주소를 입력하세요';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                            hintText: '성함을 입력하세요.',
                            prefixIcon: Icon(Icons.people_alt),
                            suffixIcon: ClearButton(
                              controller: _nameController,
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return '성함을 입력하세요.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: _positionController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Position',
                            hintText: '예) 부장, 차장, 매니저 등 .. ',
                            prefixIcon: Icon(Icons.people_alt),
                            suffixIcon: ClearButton(
                              controller: _positionController,
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return '직급을 입력하세요.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20.0),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController1,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            labelText: 'Password',
                            hintText: '비밀번호를 입력해 주세요',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: ClearButton(
                              controller: _passwordController1,
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.trim().isEmpty) {
                              return '비밀번호를 입력하세요';
                            }
                            if (value.trim().length < 6) {
                              return '비밀번호는 최소 6자 이상이어야 합니다';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          obscureText: true,
                          controller: _passwordController2,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: ClearButton(
                              controller: _passwordController2,
                            ),
                          ),
                          validator: (String? value) {
                            if (_passwordController1.text != value) {
                              return '비밀번호가 일치하지 않습니다.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30.0),
                        ElevatedButton(
                          onPressed: signupState.maybeWhen(
                            loading: () => null,
                            orElse: () => _submit,
                          ),
                          child: Text(
                            signupState.maybeWhen(
                              loading: () => 'Loading...',
                              orElse: () => 'Sign UP',
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        TextButton(
                          onPressed: signupState.maybeWhen(
                            loading: () => null,
                            orElse:
                                () =>
                                    () => GoRouter.of(
                                      context,
                                    ).goNamed(RouteNames.signin),
                          ),
                          child: Text(
                            'Already a member? Sign in!',
                            style: AppTheme.textLabelStyle.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.textLabelColor,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ].reversed.toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
