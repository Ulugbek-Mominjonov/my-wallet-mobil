/// Hujjat identifikatorlarini yaratuvchi.
///
/// Offline yozuv uchun ID KLIENTDA beriladi — serverga borib kelish shart
/// emas, shuning uchun aviarejimda ham yozuv darhol ishlaydi.
abstract interface class IdGenerator {
  String next();
}
