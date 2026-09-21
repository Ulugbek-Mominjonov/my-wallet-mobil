import 'package:test/test.dart';
import 'package:wallet_domain/wallet_domain.dart';

import 'fakes.dart';

void main() {
  late FakeStore store;
  late DomainDeps deps;

  setUp(() {
    store = FakeStore();
    deps = store.deps;
  });

  test(
    'BR-035: yangi kategoriya — nom trim qilinadi, turi saqlanadi',
    () async {
      final result = await CreateCategory(deps)(
        kind: CategoryKind.expense,
        name: '  Sport zali ',
      );
      final category = (result as Ok<Category>).value;
      expect(
        (category.name, category.kind),
        ('Sport zali', CategoryKind.expense),
      );
      expect(store.categories[category.id], category);
    },
  );

  test("BR-003: shu nom bor bo'lsa — o'sha qaytadi (registrsiz)", () async {
    final first = await CreateCategory(deps)(
      kind: CategoryKind.expense,
      name: 'Sport',
    );
    final second = await CreateCategory(deps)(
      kind: CategoryKind.expense,
      name: ' sport ',
    );
    expect((second as Ok<Category>).value.id, (first as Ok<Category>).value.id);

    // Boshqa turda — alohida kategoriya (serverdagi indeks: tur bilan).
    final income = await CreateCategory(deps)(
      kind: CategoryKind.income,
      name: 'Sport',
    );
    expect((income as Ok<Category>).value.id, isNot(first.value.id));
  });

  test("bo'sh yoki 60 belgidan uzun nom — rad", () async {
    for (final name in ['   ', 'x' * 61]) {
      expect(
        await CreateCategory(deps)(kind: CategoryKind.expense, name: name),
        isA<Err<Category>>().having(
          (e) => e.failure,
          'failure',
          const ValidationFailure('name', 'invalid_name'),
        ),
      );
    }
    expect(normalizeName(' Oziq-Ovqat '), 'oziq-ovqat');
  });
}
