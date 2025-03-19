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

import 'reset_password_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

  void _submit() {
    setState(() => _autovalidateMode = AutovalidateMode.always);

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    ref
        .read(resetPasswordProvider.notifier)
        .resetPassword(email: _emailController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(resetPasswordProvider, (previous, next) {
      next.whenOrNull(
        error: (e, st) => errorDialog(context, e as CustomError),
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password reset email has been sent')),
          );
          showOverlayMessage(
            context,
            '비밀번호 재설정 메일을 ${_emailController.text.trim()}으로 전달했습니다.',
          );
          GoRouter.of(context).goNamed(RouteNames.signin);
        },
      );
    });

    final resetPwdState = ref.watch(resetPasswordProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Reset Password', style: AppTheme.appbarTitleTextStyle),
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
                          fit: BoxFit.scaleDown,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.error,
                              size: 50,
                              color: Colors.orange,
                            );
                          },
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
                        ElevatedButton(
                          onPressed: resetPwdState.maybeWhen(
                            loading: () => null,
                            orElse: () => _submit,
                          ),
                          child: Text(
                            resetPwdState.maybeWhen(
                              loading: () => 'Submitting...',
                              orElse: () => '재설정 메일 보내기',
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: resetPwdState.maybeWhen(
                            loading: () => null,
                            orElse:
                                () => () => context.goNamed(RouteNames.signin),
                          ),

                          child: Text(
                            'Remember password? Sign in!',
                            style: AppTheme.textLabelStyle.copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppTheme.textLabelColor,
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
    );
  }
}
