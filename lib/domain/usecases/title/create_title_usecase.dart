// domain/usecases/title/create_title_usecase.dart

import '../../repositories/title_repository.dart';
import '../../entities/title_entity.dart';

class CreateTitleUseCase {
  final TitleRepository repository;

  CreateTitleUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String type,      // 'incomeTitles' or 'expenseTitles'
    required String name,      // 🔥 Name ကို input အဖြစ် တိုက်ရိုက်ယူမည်
    required String categoryId, // 🔥 NEW: categoryId ကို input အဖြစ်ယူမည်
  }) async {
    // 🔥 TitleEntity ကို UseCase အတွင်းမှာ ဖန်တီးသည်
    final newTitle = TitleEntity(
      // ID ကို အသစ်ဖန်တီးမည့်အတွက် '' ဖြင့်ထားပါမည်
      id: '',
      name: name,
      categoryId: categoryId,
      // bookmark သည် default အားဖြင့် false ဖြစ်သည်
      bookmark: false,
    );

    return repository.createTitle(userId, type, newTitle);
  }
}