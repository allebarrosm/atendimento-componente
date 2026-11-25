/// Formatação usada nas telas de atendimento.
///
/// Fica no núcleo (sem `intl`, sem Flutter) para os testes serem puros e para o
/// resultado continuar idêntico ao dos apps.
library;

/// `dd/MM/yyyy HH:mm` no fuso local — igual a `customToStringWithHour`.
String formatDateTime(DateTime value) {
  final local = value.toLocal();
  return '${_two(local.day)}/${_two(local.month)}/${local.year} '
      '${_two(local.hour)}:${_two(local.minute)}';
}

/// `HH:mm` ou `mm:ss`, omitindo a hora zerada — igual a `Duration.toCustom`.
String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final secs = duration.inSeconds.remainder(60);
  if (hours > 0) return '${_two(hours)}:${_two(minutes)}';
  return '${_two(minutes)}:${_two(secs)}';
}

/// Duração por extenso usada no popup: `2hora(s)`, `35min`, `12seg`.
String formatDurationLong(int seconds) {
  final duration = Duration(seconds: seconds);
  if (duration.inHours > 24) return '${duration.inHours}dia(s)';
  if (duration.inMinutes > 60) return '${duration.inHours}hora(s)';
  if (seconds > 60) return '${duration.inMinutes}min';
  return '${seconds}seg';
}

/// `00.000.000/0000-00` (CNPJ) e `000.000.000-00` (CPF).
String formatDocument(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.length == 14) {
    return '${digits.substring(0, 2)}.${digits.substring(2, 5)}.'
        '${digits.substring(5, 8)}/${digits.substring(8, 12)}-'
        '${digits.substring(12)}';
  }
  if (digits.length == 11) {
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.'
        '${digits.substring(6, 9)}-${digits.substring(9)}';
  }
  return value ?? '';
}

/// Separa milhar com ponto — igual a `int.toNumber` dos apps.
String formatCount(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write('.');
  }
  return negative ? '-$buffer' : buffer.toString();
}

String _two(int value) => value.toString().padLeft(2, '0');
