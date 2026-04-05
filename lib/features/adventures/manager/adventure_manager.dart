import 'package:command_it/command_it.dart';
import 'package:flutter/foundation.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/locator.dart';

class AdventureManager extends ChangeNotifier {
  final _adventureService = di<AdventureService>();

  final _adventure = ValueNotifier<Adventure?>(null);
  final _adventures = ValueNotifier<List<Adventure>>([]);

  ValueListenable<Adventure?> get adventure => _adventure;

  ValueListenable<List<Adventure>> get adventures => _adventures;

  late final getAdventuresCommand = Command.createAsyncNoParamNoResult(
    _getAdventures,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final getAdventureCommand = Command.createAsyncNoResult<int>(
    _getAdventure,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final createAdventureCommand = Command.createAsyncNoResult<String>(
    _createAdventure,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  late final deleteAdventureCommand = Command.createAsyncNoResult<int>(
    _deleteAdventure,
    errorFilter: const GlobalIfNoLocalErrorFilter(),
  );

  Future<void> _getAdventures() async {
    try {
      final adventures = await _adventureService.getAdventures();
      _adventures.value = adventures;
    } catch (e) {
      debugPrint('Failed to fetch adventures: $e');
    }
  }

  Future<void> _getAdventure(int id) async {
    try {
      final adventure = await _adventureService.getAdventure(id);
      _adventure.value = adventure;
    } catch (e) {
      debugPrint('Failed to fetch adventure: $e');
    }
  }

  Future<void> _createAdventure(String name) async {
    try {
      final adventure = await _adventureService.createAdventure(name);
      _adventures.value = [adventure, ..._adventures.value];
    } catch (e) {
      debugPrint('Failed to create adventure: $e');
    }
  }

  Future<void> _deleteAdventure(int id) async {
    final previousState = _adventures.value;
    _adventures.value = _adventures.value.where((a) => a.id != id).toList();

    try {
      await _adventureService.deleteAdventure(id);
    } catch (e) {
      debugPrint('Failed to delete adventure: $e');
      _adventures.value = previousState;
    }
  }

  @override
  void dispose() {
    _adventures.dispose();
    createAdventureCommand.dispose();
    getAdventuresCommand.dispose();
    super.dispose();
  }
}
