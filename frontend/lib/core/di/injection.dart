import 'package:get_it/get_it.dart';
import 'package:greenbasket/core/network/api_client.dart';
import 'package:greenbasket/core/network/network_info.dart';
import 'package:greenbasket/core/storage/secure_storage.dart';
import 'package:greenbasket/core/storage/local_storage.dart';
import 'package:greenbasket/data/datasources/local/cart_local.dart';
import 'package:greenbasket/data/datasources/local/search_history_local.dart';
import 'package:greenbasket/data/datasources/local/user_cache.dart';
import 'package:greenbasket/data/datasources/remote/auth_api.dart';
import 'package:greenbasket/data/datasources/remote/product_api.dart';
import 'package:greenbasket/data/datasources/remote/cart_api.dart';
import 'package:greenbasket/data/datasources/remote/order_api.dart';
import 'package:greenbasket/data/datasources/remote/user_api.dart';
import 'package:greenbasket/data/datasources/remote/wishlist_api.dart';
import 'package:greenbasket/data/datasources/remote/notification_api.dart';
import 'package:greenbasket/data/datasources/remote/recipe_api.dart';
import 'package:greenbasket/data/datasources/remote/search_api.dart';
import 'package:greenbasket/data/datasources/remote/wallet_api.dart';
import 'package:greenbasket/data/datasources/remote/offer_api.dart';
import 'package:greenbasket/data/datasources/remote/review_api.dart';
import 'package:greenbasket/data/datasources/remote/payment_api.dart';
import 'package:greenbasket/data/repositories/auth_repository_impl.dart';
import 'package:greenbasket/data/repositories/product_repository_impl.dart';
import 'package:greenbasket/data/repositories/cart_repository_impl.dart';
import 'package:greenbasket/data/repositories/order_repository_impl.dart';
import 'package:greenbasket/data/repositories/user_repository_impl.dart';
import 'package:greenbasket/data/repositories/wishlist_repository_impl.dart';
import 'package:greenbasket/data/repositories/recipe_repository_impl.dart';
import 'package:greenbasket/data/repositories/search_repository_impl.dart';
import 'package:greenbasket/data/repositories/wallet_repository_impl.dart';
import 'package:greenbasket/data/repositories/offer_repository_impl.dart';
import 'package:greenbasket/data/repositories/notification_repository_impl.dart';
import 'package:greenbasket/data/repositories/review_repository_impl.dart';
import 'package:greenbasket/data/repositories/payment_repository_impl.dart';
import 'package:greenbasket/domain/repositories/auth_repository.dart';
import 'package:greenbasket/domain/repositories/product_repository.dart';
import 'package:greenbasket/domain/repositories/cart_repository.dart';
import 'package:greenbasket/domain/repositories/order_repository.dart';
import 'package:greenbasket/domain/repositories/user_repository.dart';
import 'package:greenbasket/domain/repositories/wishlist_repository.dart';
import 'package:greenbasket/domain/repositories/recipe_repository.dart';
import 'package:greenbasket/domain/repositories/search_repository.dart';
import 'package:greenbasket/domain/repositories/wallet_repository.dart';
import 'package:greenbasket/domain/repositories/offer_repository.dart';
import 'package:greenbasket/domain/repositories/notification_repository.dart';
import 'package:greenbasket/domain/repositories/review_repository.dart';
import 'package:greenbasket/domain/repositories/payment_repository.dart';
import 'package:greenbasket/presentation/blocs/auth/auth_bloc.dart';
import 'package:greenbasket/presentation/blocs/cart/cart_bloc.dart';
import 'package:greenbasket/presentation/blocs/notification/notification_bloc.dart';
import 'package:greenbasket/presentation/blocs/profile/profile_cubit.dart';

final getIt = GetIt.instance;

void configureDependencies() {
  // ── Core ─────────────────────────────────────────────────────────────
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(),
  );
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfo());
  getIt.registerLazySingleton(() => createDio(getIt<SecureStorageService>()));

  // ── Remote Data Sources ──────────────────────────────────────────────
  getIt.registerLazySingleton(() => AuthApi(getIt()));
  getIt.registerLazySingleton(() => ProductApi(getIt()));
  getIt.registerLazySingleton(() => CartApi(getIt()));
  getIt.registerLazySingleton(() => OrderApi(getIt()));
  getIt.registerLazySingleton(() => UserApi(getIt()));
  getIt.registerLazySingleton(() => WishlistApi(getIt()));
  getIt.registerLazySingleton(() => NotificationApi(getIt()));
  getIt.registerLazySingleton(() => RecipeApi(getIt()));
  getIt.registerLazySingleton(() => SearchApi(getIt()));
  getIt.registerLazySingleton(() => WalletApi(getIt()));
  getIt.registerLazySingleton(() => OfferApi(getIt()));
  getIt.registerLazySingleton(() => ReviewApi(getIt()));
  getIt.registerLazySingleton(() => PaymentApi(getIt()));

  // ── Local Data Sources ───────────────────────────────────────────────
  getIt.registerLazySingleton(() => CartLocalDatasource());
  getIt.registerLazySingleton(() => SearchHistoryLocal());
  getIt.registerLazySingleton(() => UserCacheLocal());

  // ── Repositories ─────────────────────────────────────────────────────
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<WishlistRepository>(
    () => WishlistRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<OfferRepository>(
    () => OfferRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(getIt(), getIt()),
  );

  // ── Global BLoCs ─────────────────────────────────────────────────────
  getIt.registerFactory(() => AuthBloc(getIt()));
  getIt.registerFactory(() => CartBloc(getIt()));
  getIt.registerFactory(() => NotificationBloc(getIt()));
  getIt.registerFactory(() => ProfileCubit(getIt()));
}
