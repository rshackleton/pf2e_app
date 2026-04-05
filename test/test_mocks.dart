import 'package:mockito/annotations.dart';
import 'package:pf2e_app/features/adventures/services/adventure_service.dart';
import 'package:pf2e_app/features/auth/services/auth_service.dart';

@GenerateNiceMocks([MockSpec<AuthService>(), MockSpec<AdventureService>()])
void main() {}
