import 'package:firebase_auth/firebase_auth.dart';
import '../models/custom_error.dart';

CustomError handleException(e) {
  try {
    throw e;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        throw CustomError(code: 'ID', message: '아이디가 존재하지 않습니다.');
      case 'wrong-password':
        throw CustomError(code: 'Password', message: '비밀번호가 잘못되었습니다.');
      case 'email-already-in-use':
        throw CustomError(code: 'ID', message: '이미 등록된 사용자 (메일 주소) 입니다.');
      default:
        throw CustomError(
          code: e.code,
          message: e.message ?? '알 수 없는 오류가 발생했습니다.',
        );
    }
  }
}
