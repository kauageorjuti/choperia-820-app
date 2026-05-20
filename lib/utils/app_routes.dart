import 'package:flutter/material.dart';

import '../models/product.dart';
import '../pages/about_page.dart';
import '../pages/cart_page.dart';
import '../pages/checkout_page.dart';
import '../pages/forgot_password_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../pages/order_tracking_page.dart';
import '../pages/order_confirmation_page.dart';
import '../pages/product_details_page.dart';
import '../pages/register_page.dart';
import '../pages/settings_page.dart';
import '../pages/splash_page.dart';
import '../pages/store_info_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String tracking = '/tracking';
  static const String orderConfirmation = '/order-confirmation';
  static const String about = '/about';
  static const String settingsPage = '/settings';
  static const String storeInfo = '/store-info';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _route(const SplashPage(), settings);
      case login:
        return _route(const LoginPage(), settings);
      case register:
        return _route(const RegisterPage(), settings);
      case forgotPassword:
        return _route(const ForgotPasswordPage(), settings);
      case home:
        return _route(const HomePage(), settings);
      case productDetails:
        final Product product = settings.arguments as Product;
        return _route(ProductDetailsPage(product: product), settings);
      case cart:
        return _route(const CartPage(), settings);
      case checkout:
        return _route(const CheckoutPage(), settings);
      case tracking:
        return _route(const OrderTrackingPage(), settings);
      case orderConfirmation:
        final String? orderId = settings.arguments as String?;
        return _route(OrderConfirmationPage(orderId: orderId), settings);
      case about:
        return _route(const AboutPage(), settings);
      case storeInfo:
        return _route(const StoreInfoPage(), settings);
      case settingsPage:
        return _route(const SettingsPage(), settings);
      default:
        return _route(const SplashPage(), settings);
    }
  }

  static Route<dynamic> _route(Widget child, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => child,
      transitionsBuilder: (
        _,Animation<double> animation, _,
        Widget page,
      ) {
        final CurvedAnimation curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: page,
          ),
        );
      },
    );
  }
}
