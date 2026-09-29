import 'dart:math';

import 'package:dio/dio.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

class AnswerWeights {
  const AnswerWeights({this.yes = 40, this.no = 40, this.maybe = 20})
    : assert(yes >= 0 && no >= 0 && maybe >= 0),
      assert(yes + no + maybe > 0);

  final int yes;
  final int no;
  final int maybe;

  int get total => yes + no + maybe;

  String choose(Random random) {
    final selected = random.nextInt(total);
    if (selected < yes) return 'yes';
    if (selected < yes + no) return 'no';
    return 'maybe';
  }
}

class YesNoException implements Exception {
  const YesNoException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GetYesNoAnswer {
  GetYesNoAnswer({
    Dio? dio,
    Random? random,
    this.weights = const AnswerWeights(),
  }) : _dio = dio ?? _createDio(),
       _random = random ?? Random();

  final Dio _dio;
  final Random _random;
  final AnswerWeights weights;

  static Dio _createDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<YesNoModel> call() async {
    final force = weights.choose(_random);
    try {
      final response = await _dio.get<dynamic>(
        'https://yesno.wtf/api',
        queryParameters: {'force': force},
      );
      final data = response.data;
      if (data is! Map) {
        throw const FormatException('El servidor envió datos inesperados.');
      }
      return YesNoModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw YesNoException(_messageForDioError(error));
    } on FormatException catch (error) {
      throw YesNoException(error.message);
    } on YesNoException {
      rethrow;
    } catch (_) {
      throw const YesNoException(
        'Ocurrió un error inesperado al consultar la respuesta.',
      );
    }
  }

  String _messageForDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        'La solicitud agotó el tiempo de espera.',
      DioExceptionType.badCertificate =>
        'No se pudo validar el certificado de seguridad del servidor.',
      DioExceptionType.cancel => 'La solicitud fue cancelada.',
      DioExceptionType.connectionError =>
        'No se pudo conectar. Revisa tu conexión a internet.',
      DioExceptionType.badResponse =>
        'El servidor respondió con un error (${error.response?.statusCode ?? 'HTTP'}).',
      DioExceptionType.unknown =>
        'Ocurrió un error de red al consultar la respuesta.',
    };
  }
}
