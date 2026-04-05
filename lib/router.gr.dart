// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:flutter/material.dart' as _i8;
import 'package:pf2e_app/features/adventures/adventure_detail_home_page.dart'
    as _i1;
import 'package:pf2e_app/features/adventures/adventure_detail_root_page.dart'
    as _i2;
import 'package:pf2e_app/features/adventures/adventures_page.dart' as _i3;
import 'package:pf2e_app/features/home/home_page.dart' as _i4;
import 'package:pf2e_app/features/login/login_page.dart' as _i5;
import 'package:pf2e_app/features/profile/profile_page.dart' as _i6;

/// generated route for
/// [_i1.AdventureDetailHomePage]
class AdventureDetailHomeRoute
    extends _i7.PageRouteInfo<AdventureDetailHomeRouteArgs> {
  AdventureDetailHomeRoute({_i8.Key? key, List<_i7.PageRouteInfo>? children})
    : super(
        AdventureDetailHomeRoute.name,
        args: AdventureDetailHomeRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'AdventureDetailHomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AdventureDetailHomeRouteArgs>(
        orElse: () => AdventureDetailHomeRouteArgs(),
      );
      return _i1.AdventureDetailHomePage(
        key: args.key,
        adventureId: pathParams.getInt('adventureId'),
      );
    },
  );
}

class AdventureDetailHomeRouteArgs {
  const AdventureDetailHomeRouteArgs({this.key});

  final _i8.Key? key;

  @override
  String toString() {
    return 'AdventureDetailHomeRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdventureDetailHomeRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i2.AdventureDetailRootPage]
class AdventureDetailRootRoute
    extends _i7.PageRouteInfo<AdventureDetailRootRouteArgs> {
  AdventureDetailRootRoute({
    _i8.Key? key,
    required int adventureId,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         AdventureDetailRootRoute.name,
         args: AdventureDetailRootRouteArgs(key: key, adventureId: adventureId),
         rawPathParams: {'adventureId': adventureId},
         initialChildren: children,
       );

  static const String name = 'AdventureDetailRootRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<AdventureDetailRootRouteArgs>(
        orElse: () => AdventureDetailRootRouteArgs(
          adventureId: pathParams.getInt('adventureId'),
        ),
      );
      return _i2.AdventureDetailRootPage(
        key: args.key,
        adventureId: args.adventureId,
      );
    },
  );
}

class AdventureDetailRootRouteArgs {
  const AdventureDetailRootRouteArgs({this.key, required this.adventureId});

  final _i8.Key? key;

  final int adventureId;

  @override
  String toString() {
    return 'AdventureDetailRootRouteArgs{key: $key, adventureId: $adventureId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdventureDetailRootRouteArgs) return false;
    return key == other.key && adventureId == other.adventureId;
  }

  @override
  int get hashCode => key.hashCode ^ adventureId.hashCode;
}

/// generated route for
/// [_i3.AdventuresPage]
class AdventuresRoute extends _i7.PageRouteInfo<void> {
  const AdventuresRoute({List<_i7.PageRouteInfo>? children})
    : super(AdventuresRoute.name, initialChildren: children);

  static const String name = 'AdventuresRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.AdventuresPage();
    },
  );
}

/// generated route for
/// [_i4.HomePage]
class HomeRoute extends _i7.PageRouteInfo<void> {
  const HomeRoute({List<_i7.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.HomePage();
    },
  );
}

/// generated route for
/// [_i5.LoginPage]
class LoginRoute extends _i7.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i8.Key? key,
    required void Function() onLogin,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onLogin: onLogin),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>();
      return _i5.LoginPage(key: args.key, onLogin: args.onLogin);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, required this.onLogin});

  final _i8.Key? key;

  final void Function() onLogin;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onLogin: $onLogin}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i6.ProfilePage]
class ProfileRoute extends _i7.PageRouteInfo<void> {
  const ProfileRoute({List<_i7.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.ProfilePage();
    },
  );
}
