class QrCryptoService {
  // ← ЗМІНИ ЦЕ СЛОВО якщо треба інше; перегенеруй QR в додатку після зміни
  static const secretWord = 'BRAXORZONE26';

  /// Повертає true якщо QR містить саме [secretWord]
  static bool validate(String rawQrValue) => rawQrValue.trim() == secretWord;

  /// Дані для генерації QR-коду (просто саме слово)
  static String get encryptedWord => secretWord;
}
