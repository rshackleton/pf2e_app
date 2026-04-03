// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:pf2e_app/features/adventures/adventure_detail_page.dart' as _i1;
import 'package:pf2e_app/features/adventures/adventures_page.dart' as _i2;
import 'package:pf2e_app/features/adventures/services/adventure_service.dart'
    as _i7;
import 'package:pf2e_app/features/home/home_page.dart' as _i3;
import 'package:pf2e_app/features/login/login_page.dart' as _i4;

/// generated route for
/// [_i1.AdventureDetailPage]
class AdventureDetailRoute extends _i5.PageRouteInfo<AdventureDetailRouteArgs> {
  AdventureDetailRoute({
    _i6.Key? key,
    required _i7.Adventure adventure,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         AdventureDetailRoute.name,
         args: AdventureDetailRouteArgs(key: key, adventure: adventure),
         initialChildren: children,
       );

  static const String name = 'AdventureDetailRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AdventureDetailRouteArgs>();
      return _i1.AdventureDetailPage(key: args.key, adventure: args.adventure);
    },
  );
}

class AdventureDetailRouteArgs {
  const AdventureDetailRouteArgs({this.key, required this.adventure});

  final _i6.Key? key;

  final _i7.Adventure adventure;

  @override
  String toString() {
    return 'AdventureDetailRouteArgs{key: $key, adventure: $adventure}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdventureDetailRouteArgs) return false;
    return key == other.key && adventure == other.adventure;
  }

  @override
  int get hashCode => key.hashCode ^ adventure.hashCode;
}

/// generated route for
/// [_i2.AdventuresPage]
class AdventuresRoute extends _i5.PageRouteInfo<void> {
  const AdventuresRoute({List<_i5.PageRouteInfo>? children})
    : super(AdventuresRoute.name, initialChildren: children);

  static const String name = 'AdventuresRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.AdventuresPage();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.LoginPage]
class LoginRoute extends _i5.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i6.Key? key,
    required void Function(bool) onResult,
    List<_i5.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, onResult: onResult),
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>();
      return _i4.LoginPage(key: args.key, onResult: args.onResult);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, required this.onResult});

  final _i6.Key? key;

  final void Function(bool) onResult;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, onResult: $onResult}';
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
