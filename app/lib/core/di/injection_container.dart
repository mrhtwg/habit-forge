import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection_container.config.dart';

/// The app-wide service locator (GetIt).
///
/// Registered once in [configureDependencies] (called at startup) — see
/// `injection_container.config.dart` for the generated registrations.
final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() {
  $initGetIt(getIt);
}
