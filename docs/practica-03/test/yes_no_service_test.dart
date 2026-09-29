import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';

void main() {
  group('GetYesNoAnswer', () {
    test('sends one forced request for each selected answer', () async {
      final forces = <String>[];
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final force = options.queryParameters['force']! as String;
              forces.add(force);
              handler.resolve(
                Response<dynamic>(
                  requestOptions: options,
                  data: {
                    'answer': force,
                    'forced': true,
                    'image': 'https://example.com/$force.gif',
                  },
                ),
              );
            },
          ),
        );
      final selectedWeights = [
        const AnswerWeights(yes: 1, no: 0, maybe: 0),
        const AnswerWeights(yes: 0, no: 1, maybe: 0),
        const AnswerWeights(yes: 0, no: 0, maybe: 1),
      ];

      for (final weights in selectedWeights) {
        final answer = await GetYesNoAnswer(dio: dio, weights: weights).call();
        expect(answer.answer, forces.last);
      }

      expect(forces, ['yes', 'no', 'maybe']);
      expect(forces.length, 3);
    });

    test('converts connection failures to a readable YesNoException', () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            ),
          ),
        );

      await expectLater(
        GetYesNoAnswer(dio: dio).call(),
        throwsA(
          isA<YesNoException>().having(
            (error) => error.message,
            'Spanish message',
            contains('conectar'),
          ),
        ),
      );
    });

    test('converts invalid payloads to a readable YesNoException', () async {
      final dio = Dio()
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) => handler.resolve(
              Response<dynamic>(requestOptions: options, data: {'answer': ''}),
            ),
          ),
        );

      await expectLater(
        GetYesNoAnswer(dio: dio).call(),
        throwsA(
          isA<YesNoException>().having(
            (error) => error.message,
            'Spanish message',
            contains('no es válida'),
          ),
        ),
      );
    });
  });
}
