/// Sélection multiple réutilisable pour toutes les listes.
///
/// Chaque écran de liste instancie un [SelectionController<T>] :
/// - appui long sur une carte → mode sélection ;
/// - tap sur une carte sélectionnée → bascule ;
/// - l'[SelectionAppBar] remplace l'AppBar : compteur, tout sélectionner,
///   désélectionner, actions métier (suppression…) et sortie du mode.
library;

import 'package:flutter/material.dart';

import '../../core/theme/msn_theme.dart';

/// Contrôleur de sélection — un par écran de liste.
class SelectionController<T> extends ChangeNotifier {
  final Set<T> _selected = {};
  bool _mode = false;

  bool get isSelecting => _mode;
  Set<T> get selected => Set.unmodifiable(_selected);
  int get count => _selected.length;

  void enterSelection(T item) {
    _mode = true;
    _selected.add(item);
    notifyListeners();
  }

  void toggle(T item) {
    if (!_mode) return;
    if (!_selected.remove(item)) _selected.add(item);
    if (_selected.isEmpty) _mode = false;
    notifyListeners();
  }

  void selectAll(Iterable<T> items) {
    _selected.addAll(items);
    _mode = true;
    notifyListeners();
  }

  void clear() {
    _selected.clear();
    _mode = false;
    notifyListeners();
  }

  bool isSelected(T item) => _selected.contains(item);
}

/// AppBar du mode sélection : compteur, tout/désélectionner, fermer.
class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SelectionAppBar({
    super.key,
    required this.count,
    required this.total,
    required this.onClose,
    required this.onSelectAll,
    required this.onClearSelection,
    this.actions = const [],
  });

  final int count;
  final int total;
  final VoidCallback onClose;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MsnColors.primaryDark,
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: 'Quitter la sélection',
        onPressed: onClose,
      ),
      title: Text('$count sélectionné${count > 1 ? 's' : ''}',
          style: const TextStyle(fontSize: 16)),
      actions: [
        ...actions,
        TextButton(
          onPressed: onSelectAll,
          child: Text('Tout ($total)',
              style: const TextStyle(color: Colors.white, fontSize: 12.5)),
        ),
        IconButton(
          icon: const Icon(Icons.remove_done, size: 20),
          tooltip: 'Tout désélectionner',
          onPressed: onClearSelection,
        ),
      ],
    );
  }
}
