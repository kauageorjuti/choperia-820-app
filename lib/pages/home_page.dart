import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../pages/store_info_page.dart';
import '../providers/app_settings_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/app_routes.dart';
import '../utils/app_texts.dart';
import '../widgets/cart_badge_icon.dart';
import '../widgets/category_chip.dart';
import '../widgets/empty_state.dart';
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
  int _bottomIndex = 0;

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

  void _dismissKeyboard() => _searchFocusNode.unfocus();

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
    context.watch<AppSettingsProvider>(); // garante rebuild ao trocar tema

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        // ── AppBar ────────────────────────────────────────────
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
                PopupMenuItem<String>(
                    value: 'settings',
                    child: Text(context.t('Configurações'))),
                PopupMenuItem<String>(
                    value: 'about', child: Text(context.t('Sobre'))),
              ],
            ),
          ],
        ),
        // ── Body ──────────────────────────────────────────────
        body: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => context.read<MenuProvider>().loadProducts(),
          child: Consumer<MenuProvider>(
            builder: (_, MenuProvider menu, _) {
              return CustomScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: <Widget>[
                  // 1. Header restaurante (banner + logo + info)
                  SliverToBoxAdapter(
                    child: _RestaurantHeader(),
                  ),

                  // 2. Campo de busca
                  SliverToBoxAdapter(
                    child: _SearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: menu.setSearchQuery,
                      onClear: () {
                        _searchController.clear();
                        menu.setSearchQuery('');
                      },
                      isEmpty: menu.searchQuery.isEmpty,
                    ),
                  ),

                  // 3. Tabs de categoria (sticky)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _CategoryTabsDelegate(
                      categories: menu.categories,
                      selected: menu.selectedCategory,
                      scaffoldColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      onSelect: (String cat) {
                        _dismissKeyboard();
                        menu.selectCategory(cat);
                      },
                    ),
                  ),

                  // 4. Conteúdo: loading | vazio | lista
                  if (menu.isLoading)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _) => const _CardDivider(child: SkeletonCard()),
                        childCount: 8,
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
                    _ProductList(
                      products: menu.visibleProducts,
                      selectedCategory: menu.selectedCategory,
                      allCategories: menu.categories,
                      onTap: (Product p) => Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: p,
                      ),
                      onAdd: (Product p) {
                        context.read<CartProvider>().addProduct(p);
                        _showAddedSnack(p);
                      },
                    ),
                ],
              );
            },
          ),
        ),
        // ── Bottom Nav ────────────────────────────────────────
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _bottomIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          onTap: (int index) {
            if (index == 0) {
              _dismissKeyboard();
              setState(() => _bottomIndex = 0);
              return;
            }
            if (index == 1) {
              _dismissKeyboard();
              _searchFocusNode.requestFocus();
              setState(() => _bottomIndex = 1);
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

// ────────────────────────────────────────────────────────────────────────────
// _RestaurantHeader — banner hero + logo circular + info + status
// ────────────────────────────────────────────────────────────────────────────

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final StoreStatus status = StoreInfoPage.currentStatus();
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final double bannerH = isMobile ? 132.0 : 248.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ── Banner de capa ──────────────────────────────────
        SizedBox(
          height: bannerH,
          width: double.infinity,
          child: Image.asset(
            'assets/images/banner_food.png',
            fit: BoxFit.cover,
          ),
        ),

        // ── Info do restaurante ─────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              // Logo circular sobreposto ao banner
              Positioned(
                top: -40,
                left: 0,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 3,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logoo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Conteúdo de info (com padding para não sobrepor a logo)
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Nome
                    const Text(
                      'Choperia 820',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Endereço
                    Row(
                      children: <Widget>[
                        Icon(Icons.place_outlined,
                            size: 14,
                            color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        const Text(
                          'Rua Hum, 820',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        const Text('•',
                            style: TextStyle(color: Color(0xFFAAAAAA))),
                        const SizedBox(width: 6),
                        // Mais informações
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.storeInfo),
                          child: Text(
                            'Mais informações',
                            style: TextStyle(
                              fontSize: 13,
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Status aberto/fechado
                    Row(
                      children: <Widget>[
                        Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: status.color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Badge entrega e retirada
                        _DeliveryBadge(label: 'Entrega'),
                        const SizedBox(width: 6),
                        _DeliveryBadge(label: 'Retirada'),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Linha divisória
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }
}

class _DeliveryBadge extends StatelessWidget {
  const _DeliveryBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: cs.onPrimaryContainer,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _SearchBar
// ────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
    required this.isEmpty,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: SizedBox(
        height: 44,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          style: const TextStyle(fontSize: 13),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar no cardapio...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: isEmpty
                ? null
                : IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _CategoryTabsDelegate — SliverPersistentHeaderDelegate para tabs sticky
// ────────────────────────────────────────────────────────────────────────────

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  const _CategoryTabsDelegate({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.scaffoldColor,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;
  final Color scaffoldColor;

  @override
  double get minExtent => 46;

  @override
  double get maxExtent => 46;

  @override
  bool shouldRebuild(_CategoryTabsDelegate old) =>
      old.selected != selected ||
      old.categories != categories ||
      old.scaffoldColor != scaffoldColor;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: scaffoldColor,
      height: 46,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: categories.length,
              itemBuilder: (_, int i) {
                final String cat = categories[i];
                return CategoryChip(
                  label: cat,
                  selected: selected == cat,
                  onTap: () => onSelect(cat),
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// _ProductList — lista vertical com cabeçalhos de categoria
// ────────────────────────────────────────────────────────────────────────────

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.selectedCategory,
    required this.allCategories,
    required this.onTap,
    required this.onAdd,
  });

  final List<Product> products;
  final String selectedCategory;
  final List<String> allCategories;
  final ValueChanged<Product> onTap;
  final ValueChanged<Product> onAdd;

  bool get _showCategoryHeaders => selectedCategory == 'Tudo';

  @override
  Widget build(BuildContext context) {
    if (!_showCategoryHeaders) {
      // Sem cabeçalhos: lista simples
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int i) => _CardDivider(
            child: ProductCard(
              product: products[i],
              onTap: () => onTap(products[i]),
              onAdd: () => onAdd(products[i]),
            ),
          ),
          childCount: products.length,
        ),
      );
    }

    // Com cabeçalhos de categoria
    final List<Widget> items = <Widget>[];
    String? lastCategory;
    for (final Product p in products) {
      if (p.category != lastCategory) {
        lastCategory = p.category;
        items.add(_CategoryHeader(label: p.category));
      }
      items.add(
        _CardDivider(
          child: ProductCard(
            product: p,
            onTap: () => onTap(p),
            onAdd: () => onAdd(p),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, int i) => items[i],
        childCount: items.length,
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ────────────────────────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1C1C1C) : const Color(0xFFF5F5F5),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1.2,
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        child,
        const Divider(height: 1, thickness: 0.5, indent: 12, endIndent: 12),
      ],
    );
  }
}
