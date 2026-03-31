import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_settings_provider.dart';

class AppTexts {
  static const Map<String, Map<String, String>> values = <String, Map<String, String>>{
    'pt': <String, String>{
      'appName': 'Choperia 820',
      'digitalMenu': 'Cardapio digital',
      'loginTitle': 'Acesse sua conta',
      'email': 'E-mail',
      'password': 'Senha',
      'forgotPassword': 'Esqueceu a senha?',
      'login': 'Entrar',
      'createAccount': 'Criar conta',
      'settings': 'Configuracoes',
      'about': 'Sobre',
      'logout': 'Sair da conta',
      'trackOrder': 'Acompanhar pedido',
      'emptyCategoryTitle': 'Nada por aqui',
      'emptyCategorySubtitle': 'Nao encontramos itens para essa categoria.',
      'addToCart': 'Adicionar',
      'cart': 'Seu Carrinho',
      'emptyCartTitle': 'Carrinho vazio',
      'emptyCartSubtitle': 'Adicione porcoes deliciosas para continuar.',
      'orderTotal': 'Total do pedido',
      'checkout': 'Finalizar pedido',
      'appearance': 'Aparencia',
      'theme': 'Tema',
      'lightTheme': 'Claro',
      'darkTheme': 'Escuro',
      'language': 'Idioma',
      'account': 'Conta',
      'logoutSuccess': 'Voce saiu da conta.',
    },
    'en': <String, String>{
      'appName': 'Choperia 820',
      'digitalMenu': 'Digital menu',
      'loginTitle': 'Sign in to your account',
      'email': 'Email',
      'password': 'Password',
      'forgotPassword': 'Forgot password?',
      'login': 'Login',
      'createAccount': 'Create account',
      'settings': 'Settings',
      'about': 'About',
      'logout': 'Log out',
      'trackOrder': 'Track order',
      'emptyCategoryTitle': 'Nothing here',
      'emptyCategorySubtitle': 'No items found for this category.',
      'addToCart': 'Add',
      'cart': 'Your Cart',
      'emptyCartTitle': 'Cart is empty',
      'emptyCartSubtitle': 'Add delicious items to continue.',
      'orderTotal': 'Order total',
      'checkout': 'Checkout',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'language': 'Language',
      'account': 'Account',
      'logoutSuccess': 'You are logged out.',
    },
    'es': <String, String>{
      'appName': 'Choperia 820',
      'digitalMenu': 'Menu digital',
      'loginTitle': 'Ingresa en tu cuenta',
      'email': 'Correo',
      'password': 'Contrasena',
      'forgotPassword': 'Olvidaste tu contrasena?',
      'login': 'Entrar',
      'createAccount': 'Crear cuenta',
      'settings': 'Configuracion',
      'about': 'Acerca de',
      'logout': 'Cerrar sesion',
      'trackOrder': 'Seguir pedido',
      'emptyCategoryTitle': 'Nada por aqui',
      'emptyCategorySubtitle': 'No encontramos productos en esta categoria.',
      'addToCart': 'Agregar',
      'cart': 'Tu carrito',
      'emptyCartTitle': 'Carrito vacio',
      'emptyCartSubtitle': 'Agrega porciones para continuar.',
      'orderTotal': 'Total del pedido',
      'checkout': 'Finalizar pedido',
      'appearance': 'Apariencia',
      'theme': 'Tema',
      'lightTheme': 'Claro',
      'darkTheme': 'Oscuro',
      'language': 'Idioma',
      'account': 'Cuenta',
      'logoutSuccess': 'Sesion cerrada.',
    },
  };

  static String text(BuildContext context, String key) {
    final String code =
        Provider.of<AppSettingsProvider>(context, listen: false).locale.languageCode;
    return values[code]?[key] ?? values['pt']?[key] ?? key;
  }
}

extension AppTextExt on BuildContext {
  String t(String key) => AppTexts.text(this, key);
}
