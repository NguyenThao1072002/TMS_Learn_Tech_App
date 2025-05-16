import 'package:tms_app/data/models/account/overview_my_account_model.dart';
import 'package:tms_app/domain/repositories/account_repository.dart';

class OverviewMyAccountUseCase {
  final AccountRepository _accountRepository;

  OverviewMyAccountUseCase(this._accountRepository);

  Future<AccountOverviewModel> execute(String userId) async {
    return await _accountRepository.getAccountOverview(userId);
  }
}
