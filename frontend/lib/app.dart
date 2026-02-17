import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenbasket/core/di/injection.dart';
import 'package:greenbasket/core/theme/app_theme.dart';
import 'package:greenbasket/presentation/blocs/auth/auth_bloc.dart';
import 'package:greenbasket/presentation/blocs/cart/cart_bloc.dart';
import 'package:greenbasket/presentation/blocs/notification/notification_bloc.dart';
import 'package:greenbasket/presentation/blocs/profile/profile_cubit.dart';
import 'package:greenbasket/routes/app_router.dart';

class GreenBasketApp extends StatelessWidget {
  const GreenBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<CartBloc>(create: (_) => getIt<CartBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => getIt<NotificationBloc>(),
        ),
        BlocProvider<ProfileCubit>(create: (_) => getIt<ProfileCubit>()),
      ],
      child: MaterialApp.router(
        title: 'GreenBasket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
