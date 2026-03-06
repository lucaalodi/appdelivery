import 'dart:convert';
import 'package:http/http.dart' as http;

class TimeService {
  static DateTime? _serverTime;
  static DateTime? _localTimeAtFetch;

  static Future<void> fetchServerTime() async {
    // Tenta múltiplas APIs em ordem
    final apis = [
      'https://timeapi.io/api/time/current/zone?timeZone=America/Sao_Paulo',
      'https://worldtimeapi.org/api/timezone/America/Sao_Paulo',
    ];

    for (final url in apis) {
      try {
        print('[TimeService] Tentando: $url');
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 5));

        print('[TimeService] Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // timeapi.io retorna campo "dateTime", worldtimeapi retorna "datetime"
          final raw = data['dateTime'] ?? data['datetime'];
          _serverTime = DateTime.parse(raw);
          _localTimeAtFetch = DateTime.now();
          print('[TimeService] Sincronizado: $_serverTime');
          return; // sucesso, para aqui
        }
      } catch (e) {
        print('[TimeService] Erro em $url: $e');
      }
    }

    print('[TimeService] Todas as APIs falharam, usando relógio local.');
    _serverTime = null;
    _localTimeAtFetch = null;
  }

  static DateTime now() {
    if (_serverTime != null && _localTimeAtFetch != null) {
      final elapsed = DateTime.now().difference(_localTimeAtFetch!);
      return _serverTime!.add(elapsed);
    }
    return DateTime.now();
  }

  static bool get hasSyncedTime => _serverTime != null;
}
