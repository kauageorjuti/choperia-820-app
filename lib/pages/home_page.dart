import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/app_routes.dart';
import '../utils/app_texts.dart';
import '../widgets/cart_badge_icon.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/app_product_image.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchSectionKey = GlobalKey();
  int _bottomIndex = 0;

  int _columnsForWidth(double width) {
    if (width < 760) return 1;
    if (width < 1200) return 2;
    return 3;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final MenuProvider menu = context.read<MenuProvider>();
      if (menu.products.isEmpty && !menu.isLoading) {
        menu.loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    _searchFocusNode.unfocus();
  }

  void _focusSearchField() {
    setState(() => _bottomIndex = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BuildContext? sectionContext = _searchSectionKey.currentContext;
      if (sectionContext != null) {
        Scrollable.ensureVisible(
          sectionContext,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
      }
      _searchFocusNode.requestFocus();
    });
  }

  void _openTabRoute(String routeName, int tabIndex) {
    setState(() => _bottomIndex = tabIndex);
    Navigator.pushNamed(context, routeName).then((_) {
      if (!mounted) return;
      setState(() => _bottomIndex = 0);
    });
  }

  void _showAddedSnack(Product product) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Text('${product.name} adicionado ao carrinho.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final String userName = auth.currentUser?.name.split(' ').first ?? 'Cliente';

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('appName')),
        actions: <Widget>[
          CartBadgeIcon(
            onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'about') {
                Navigator.pushNamed(context, AppRoutes.about);
              }
              if (value == 'settings') {
                Navigator.pushNamed(context, AppRoutes.settingsPage);
              }
            },
            itemBuilder: (_) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'settings', child: Text(context.t('settings'))),
              PopupMenuItem<String>(value: 'about', child: Text(context.t('about'))),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<MenuProvider>().loadProducts(),
        child: Consumer<MenuProvider>(
          builder: (_, MenuProvider menu, _) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(child: _PromoBanner(userName: userName)),
                SliverToBoxAdapter(
                  child: Padding(
                    key: _searchSectionKey,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        focusNode: _searchFocusNode,
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (String value) => menu.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Buscar produto pelo nome',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: menu.searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    menu.setSearchQuery('');
                                  },
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
                    child: SizedBox(
                      height: 38,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: menu.categories.length,
                        itemBuilder: (_, int index) {
                          final String category = menu.categories[index];
                          return CategoryChip(
                            label: category,
                            selected: menu.selectedCategory == category,
                            onTap: () {
                              _dismissKeyboard();
                              menu.selectCategory(category);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (menu.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverLayoutBuilder(
                      builder: (_, constraints) {
                        final int columns = _columnsForWidth(constraints.crossAxisExtent);
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, _) => const SkeletonCard(),
                            childCount: columns * 2,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: columns == 1 ? 0.82 : 0.76,
                          ),
                        );
                      },
                    ),
                  )
                else if (menu.visibleProducts.isEmpty)
                  SliverFillRemaining(
                    child: EmptyState(
                      title: context.t('emptyCategoryTitle'),
                      subtitle: menu.searchQuery.isNotEmpty
                          ? 'Nao encontramos produto com esse nome.'
                          : context.t('emptyCategorySubtitle'),
                      icon: Icons.search_off_rounded,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverLayoutBuilder(
                      builder: (_, constraints) {
                        final int columns = _columnsForWidth(constraints.crossAxisExtent);
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (_, int index) {
                              final Product product = menu.visibleProducts[index];
                              return RepaintBoundary(
                                child: ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.productDetails,
                                      arguments: product,
                                    );
                                  },
                                  onAdd: () {
                                    context.read<CartProvider>().addProduct(product);
                                    _showAddedSnack(product);
                                  },
                                ),
                              );
                            },
                            childCount: menu.visibleProducts.length,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: columns == 1 ? 0.82 : 0.76,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF101010).withValues(alpha: 0.90),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _bottomIndex,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFFD4AF37),
            unselectedItemColor: const Color(0xFFB3B3B3),
            selectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            onTap: (int index) {
              if (index == 0) {
                _dismissKeyboard();
                setState(() => _bottomIndex = 0);
                return;
              }
              if (index == 1) {
                _focusSearchField();
                return;
              }
              if (index == 2) {
                _dismissKeyboard();
                _openTabRoute(AppRoutes.tracking, 2);
                return;
              }
              _dismissKeyboard();
              _openTabRoute(AppRoutes.settingsPage, 3);
            },
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book_rounded),
                label: 'Cardapio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded),
                activeIcon: Icon(Icons.manage_search_rounded),
                label: 'Buscar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Pedidos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              Color(0xFF0D0D0D),
              Color(0xFF1A1A1A),
              Color(0xFF2A2109),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x33D4AF37)),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const AppProductImage(
                source: 'assets/images/logo.jpg',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                cacheWidth: 120,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Ola, $userName! \u{1F37A}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.t('digitalMenu'),
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




