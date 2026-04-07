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
    if (width < 760) return 2;
    if (width < 1200) return 3;
    return 4;
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

  void _openTabRoute(String route, int index) {
    setState(() => _bottomIndex = index);
    Navigator.pushNamed(context, route).then((_) {
      if (mounted) setState(() => _bottomIndex = 0);
    });
  }

  void _showAddedSnack(Product product) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.name} adicionado ao carrinho.'),
          duration: const Duration(milliseconds: 800),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    final String userName = auth.currentUser?.name.split(' ').first ?? 'Cliente';

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                PopupMenuItem<String>(value: 'settings', child: Text(context.t('Configurações'))),
                PopupMenuItem<String>(value: 'about', child: Text(context.t('Sobre'))),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => context.read<MenuProvider>().loadProducts(),
          child: Consumer<MenuProvider>(
            builder: (_, MenuProvider menu, _) {
              return CustomScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: <Widget>[
                  SliverToBoxAdapter(child: _PromoBanner(userName: userName)),
                  SliverToBoxAdapter(
                    child: Padding(
                      key: _searchSectionKey,
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                      child: SizedBox(
                        height: 44,
                        child: TextField(
                          focusNode: _searchFocusNode,
                          controller: _searchController,
                          style: const TextStyle(fontSize: 13),
                          onChanged: (String value) => menu.setSearchQuery(value),
                          decoration: InputDecoration(
                            hintText: 'Buscar no cardapio...',
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
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: SizedBox(
                        height: 36,
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
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.72,
                            ),
                          );
                        },
                      ),
                    )
                  else if (menu.visibleProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
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
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.72,
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomIndex,
          type: BottomNavigationBarType.fixed,
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
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu_rounded),
              label: 'Cardapio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search_rounded),
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
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: const AppProductImage(
                source: 'assets/images/logoo.png',
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                cacheWidth: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Olá, $userName! \u{1F37A}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.t('digitalMenu'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.access_time_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Aberta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
