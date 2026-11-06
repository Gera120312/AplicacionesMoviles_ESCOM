import 'package:flutter/material.dart';

import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) => Scaffold(
        appBar: AppBar(title: const Text('Configuración')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _sectionTitle(context, 'Apariencia'),
            Card(
              child: RadioGroup<AccentTheme>(
                groupValue: appState.accentTheme,
                onChanged: (value) => appState.setAccent(value!),
                child: Column(
                  children: <Widget>[
                    const RadioListTile<AccentTheme>(
                      title: Text('Guinda IPN'),
                      subtitle: Text('#6C1D45'),
                      value: AccentTheme.guinda,
                    ),
                    const RadioListTile<AccentTheme>(
                      title: Text('Azul ESCOM'),
                      subtitle: Text('#1565C0'),
                      value: AccentTheme.azul,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: RadioGroup<ThemeMode>(
                groupValue: appState.themeMode,
                onChanged: (value) => appState.setThemeMode(value!),
                child: Column(
                  children: <Widget>[
                    for (final mode in ThemeMode.values)
                      RadioListTile<ThemeMode>(
                        title: Text(_themeLabel(mode)),
                        value: mode,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Visualización'),
            Card(
              child: Column(
                children: <Widget>[
                  SwitchListTile(
                    title: const Text('Vista de cuadrícula'),
                    subtitle: const Text('Usar tarjetas en lugar de una lista'),
                    value: appState.isGridView,
                    onChanged: appState.setGridView,
                  ),
                  ListTile(
                    title: const Text('Criterio de ordenamiento'),
                    trailing: DropdownButton<SortOrder>(
                      value: appState.sortOrder,
                      onChanged: (value) => appState.setSortOrder(value!),
                      items: SortOrder.values
                          .map(
                            (order) => DropdownMenuItem(
                              value: order,
                              child: Text(_sortLabel(order)),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Orden ascendente'),
                    value: appState.ascending,
                    onChanged: appState.setAscending,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Información'),
            const Card(
              child: ListTile(
                leading: Icon(Icons.school_outlined),
                title: Text('Gestor de archivos'),
                subtitle: Text('Versión 1.0.0 · Práctica 4 · ESCOM-IPN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'Automático (sistema)',
      ThemeMode.light => 'Modo claro',
      ThemeMode.dark => 'Modo oscuro',
    };
  }

  String _sortLabel(SortOrder order) {
    return switch (order) {
      SortOrder.name => 'Nombre',
      SortOrder.size => 'Tamaño',
      SortOrder.date => 'Fecha',
      SortOrder.type => 'Tipo',
    };
  }
}
