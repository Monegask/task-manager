import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../../../../shared/widgets/priority_icon.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_icon.dart';
import '../../../../shared/widgets/task_tile.dart';

// ignore_for_file: avoid_print

/// Экран «Мои задачи» — главный экран приложения.
///
/// Mock-данные заменятся на Riverpod-провайдер в Stage 3 после реализации
/// drift-слоя (Stage 1) и sync-сервиса (Stage 2).
class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  _Filter _activeFilter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;
    final active = tasks.where((t) => t.status == TaskStatusDisplay.active).toList();
    final completed = tasks.where((t) => t.status == TaskStatusDisplay.completed).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: tasks.isEmpty
          ? _EmptyState(filter: _activeFilter)
          : CustomScrollView(
              slivers: [
                if (active.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      label: 'Активные',
                      count: active.length,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildTile(active[i]),
                      childCount: active.length,
                    ),
                  ),
                ],
                if (completed.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      label: 'Завершены',
                      count: completed.length,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _buildTile(completed[i]),
                      childCount: completed.length,
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print('TODO: открыть форму создания задачи — Stage 3'),
        child: const Icon(Icons.add, size: 22),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Мои задачи'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: _FilterBar(
          active: _activeFilter,
          onChanged: (f) => setState(() => _activeFilter = f),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded),
          tooltip: 'Фильтры',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          tooltip: 'Ещё',
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTile(_MockTask task) {
    return TaskTile(
      key: ValueKey(task.id),
      id: task.id,
      title: task.title,
      status: task.status,
      priority: task.priority,
      scheduledLabel: task.scheduledLabel,
      tags: task.tags,
      onTap: () => print('TODO: открыть задачу ${task.id} — Stage 3'),
      onStatusTap: () => _toggleStatus(task),
    );
  }

  void _toggleStatus(_MockTask task) {
    setState(() {
      final idx = _mockTasks.indexOf(task);
      if (idx == -1) return;
      _mockTasks[idx] = task.copyWith(
        status: task.status == TaskStatusDisplay.active
            ? TaskStatusDisplay.completed
            : TaskStatusDisplay.active,
      );
    });
  }

  List<_MockTask> get _filteredTasks => switch (_activeFilter) {
        _Filter.all => _mockTasks,
        _Filter.active =>
          _mockTasks.where((t) => t.status == TaskStatusDisplay.active).toList(),
        _Filter.completed =>
          _mockTasks.where((t) => t.status == TaskStatusDisplay.completed).toList(),
      };
}

// ── Фильтры ────────────────────────────────────────────────────────────────

enum _Filter { all, active, completed }

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.active, required this.onChanged});

  final _Filter active;
  final ValueChanged<_Filter> onChanged;

  static const _labels = {
    _Filter.all: 'Все',
    _Filter.active: 'Активные',
    _Filter.completed: 'Завершены',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: _Filter.values.map((f) {
          final isActive = f == active;
          return GestureDetector(
            onTap: () => onChanged(f),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? AppColors.accent : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _labels[f]!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final _Filter filter;

  static const _messages = {
    _Filter.all: 'Нет задач.\nНажмите + чтобы создать первую.',
    _Filter.active: 'Нет активных задач.',
    _Filter.completed: 'Нет завершённых задач.',
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          _messages[filter]!,
          style: AppTextStyles.emptyState,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Mock data (заменится Riverpod-провайдером в Stage 3) ───────────────────

class _MockTask {
  const _MockTask({
    required this.id,
    required this.title,
    this.priority = TaskPriorityDisplay.none,
    this.status = TaskStatusDisplay.active,
    this.scheduledLabel,
    this.tags = const [],
  });

  final String id;
  final String title;
  final TaskPriorityDisplay priority;
  final TaskStatusDisplay status;
  final String? scheduledLabel;
  final List<String> tags;

  _MockTask copyWith({
    TaskStatusDisplay? status,
    TaskPriorityDisplay? priority,
  }) {
    return _MockTask(
      id: id,
      title: title,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      scheduledLabel: scheduledLabel,
      tags: tags,
    );
  }
}

// Модифицируемый список для UI-демонстрации toggle
final _mockTasks = <_MockTask>[
  const _MockTask(
    id: 'TM-001',
    title: 'Реализовать drift-схему и DAO для задач',
    priority: TaskPriorityDisplay.high,
    scheduledLabel: 'Сегодня',
    tags: ['drift', 'этап-1'],
  ),
  const _MockTask(
    id: 'TM-002',
    title: 'Настроить Supabase RLS и sync-сервис',
    priority: TaskPriorityDisplay.high,
    scheduledLabel: 'Завтра',
    tags: ['supabase', 'этап-2'],
  ),
  const _MockTask(
    id: 'TM-003',
    title: 'Добавить RRULE-билдер для повторяющихся задач',
    priority: TaskPriorityDisplay.normal,
    scheduledLabel: '20 мая',
    tags: ['rrule'],
  ),
  const _MockTask(
    id: 'TM-004',
    title: 'Реализовать drag-and-drop в Calendar view на Windows',
    priority: TaskPriorityDisplay.normal,
    scheduledLabel: '25 мая',
  ),
  const _MockTask(
    id: 'TM-005',
    title: 'Добавить тёмную тему и empty states',
    priority: TaskPriorityDisplay.low,
    tags: ['ui', 'этап-6'],
  ),
  const _MockTask(
    id: 'TM-006',
    title: 'Подготовить подписанный release APK',
    priority: TaskPriorityDisplay.low,
    tags: ['этап-7'],
  ),
  const _MockTask(
    id: 'TM-000',
    title: 'Bootstrap Flutter проект',
    priority: TaskPriorityDisplay.none,
    status: TaskStatusDisplay.completed,
    scheduledLabel: '11 мая',
    tags: ['этап-0'],
  ),
];
