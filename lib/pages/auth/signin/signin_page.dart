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
import 'signin_provider.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email') ?? '';
    setState(() {
      _emailController.text = savedEmail;
    });

    if (savedEmail.isNotEmpty) {
      // FocusScope.of(context).requestFocus(_passwordFocusNode);
    }
  }

  Future<void> _saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    await ref
        .read(signinProvider.notifier)
        .signin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(signinProvider, (prev, next) {
      next.whenOrNull(
        data: (_) async {
          await _saveEmail(_emailController.text.trim()); // 이메일 저장
        },
        error: (e, st) => errorDialog(context, (e as CustomError)),
      );
    });

    final signinState = ref.watch(signinProvider);

    return PopScope(
      canPop: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Sign In', style: AppTheme.appbarTitleTextStyle),
            centerTitle: true,
          ),
          body: Center(
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
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
                            'assets/images/miceplan_logo.png',
                            width: 250,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: 50.0),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              labelText: 'Email',
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
                            obscureText: true,
                            controller: _passwordController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: ClearButton(
                                controller: _passwordController,
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
                            onFieldSubmitted: (value) {
                              if (signinState.maybeWhen(
                                loading: () => true,
                                orElse: () => false,
                              )) {
                                return; // 로딩 중이면 아무것도 하지 않음
                              }
                              _submit(); // 로그인 요청 실행
                            },
                          ),
                          SizedBox(height: 30.0),
                          ElevatedButton(
                            onPressed: signinState.maybeWhen(
                              loading: () => null,
                              orElse: () => _submit,
                            ),
                            child: Text(
                              signinState.maybeWhen(
                                loading: () => 'Loading...',
                                orElse: () => 'Sign In',
                              ),
                            ),
                          ),

                          SizedBox(height: 10.0),
                          TextButton(
                            onPressed: signinState.maybeWhen(
                              loading: () => null,
                              orElse:
                                  () =>
                                      () => context.goNamed(RouteNames.signup),
                            ),

                            child: Text(
                              'Not a member? Sign up!',
                              style: AppTheme.textLabelStyle.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.textLabelColor,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          TextButton(
                            onPressed: signinState.maybeWhen(
                              loading: () => null,
                              orElse:
                                  () =>
                                      () => context.goNamed(
                                        RouteNames.resetPassword,
                                      ),
                            ),

                            child: Text(
                              'Forgot Password?',
                              style: AppTheme.textHintTextStyle.copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.textHintColor,
                              ),
                            ),
                          ),
                        ].reversed.toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
