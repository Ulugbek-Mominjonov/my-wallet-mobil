import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_firebase/data_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sahifalash kursori', () {
    test("kodlash va o'qish", () {
      final date = DateTime(2026, 9, 15);
      final cursor = Cursor.encode(date, 'e42');
      expect(cursor, '${date.millisecondsSinceEpoch}|e42');

      final decoded = Cursor.decode(cursor)!;
      expect(decoded.length, 2);
      expect((decoded.first as Timestamp).toDate(), date);
      expect(decoded.last, 'e42');
    });

    test("buzuq kursor null beradi (so'rov boshidan boshlanadi)", () {
      expect(Cursor.decode(null), isNull);
      expect(Cursor.decode(''), isNull);
      expect(Cursor.decode('buzuq'), isNull);
      expect(Cursor.decode('abc|e1'), isNull);
    });
  });
}
