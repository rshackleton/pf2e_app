import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/auth/services/adventure_service.dart';
import 'package:pf2e_app/locator.dart';

class AdventureManager extends ChangeNotifier {
  final _adventureService = di<AdventureService>();

  final _adventures = ValueNotifier<List<Adventure>>([]);

  ValueListenable<List<Adventure>> get adventures => _adventures;

  late final getAdventuresCommand = Command.createAsyncNoParamNoResult(
    _getAdventures,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final createAdventureCommand = Command.createAsyncNoParamNoResult(
    _createAdventure,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  Future<void> _getAdventures() async {
    final adventures = await _adventureService.getAdventures();
    _adventures.value = adventures;
  }

  Future<void> _createAdventure() async {
    final adventure = await _adventureService.createAdventure('New Adventure');
    _adventures.value = [adventure, ..._adventures.value];
  }

  @override
  void dispose() {
    _adventures.dispose();
    createAdventureCommand.dispose();
    getAdventuresCommand.dispose();
    super.dispose();
  }
}
