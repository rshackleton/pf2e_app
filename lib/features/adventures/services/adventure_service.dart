import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Adventure {
  final int id;
  final String name;
  final DateTime createdAt;
  final String createdBy;

  Adventure({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.createdBy,
  });

  factory Adventure.fromJson(Map<String, dynamic> json) {
    return Adventure(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      createdBy: json['created_by'],
      name: json['name'],
    );
  }
}

class AdventureService {
  Future<List<Adventure>> getAdventures() async {
    try {
      final adventures = await Supabase.instance.client
          .from('adventures')
          .select()
          .order('created_at', ascending: false)
          .withConverter(
            (adventures) => adventures.map(Adventure.fromJson).toList(),
          );

      return adventures;
    } catch (e, s) {
      debugPrint('Error fetching adventures: $e $s');
      return [];
    }
  }

  Future<Adventure?> getAdventure(int id) async {
    try {
      final adventure = await Supabase.instance.client
          .from('adventures')
          .select()
          .eq('id', id)
          .single()
          .withConverter(Adventure.fromJson);

      return adventure;
    } catch (e, s) {
      debugPrint('Error fetching adventures: $e $s');
      return null;
    }
  }

  Future<Adventure> createAdventure(String name) async {
    try {
      final adventure = await Supabase.instance.client
          .from('adventures')
          .insert({'name': name})
          .select()
          .single()
          .withConverter((adventure) => Adventure.fromJson(adventure));

      return adventure;
    } catch (e, s) {
      debugPrint('Error creating adventure: $e $s');
      rethrow;
    }
  }

  Future<void> deleteAdventure(int id) async {
    try {
      await Supabase.instance.client.from('adventures').delete().eq('id', id);
    } catch (e, s) {
      debugPrint('Error deleting adventure: $e $s');
      rethrow;
    }
  }
}
