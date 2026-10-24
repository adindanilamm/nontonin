import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../core/genres.dart';
import '../services/tmdb_service.dart';
import '../widgets/app_buttons.dart';
import 'recommendation_result_page.dart';

/// Halaman Rekomendasi: pengguna memilih genre, urutan, dan rating minimum.
class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final Set<int> _selected = {};
  SortOption _sort = SortOption.popular;
  double _minRating = 7;

  void _reset() => setState(() {
        _selected.clear();
        _sort = SortOption.popular;
        _minRating = 7;
      });

  void _search() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendationResultPage(
          genreIds: Genres.selectable.where(_selected.contains).toList(),
          sort: _sort,
          minRating: _minRating,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSearch = _selected.isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                const Text('Rekomendasi Untukmu',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  'Pilih genre dan preferensimu, kami carikan filmnya.',
                  style:
                      TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(
                      child: Text('Genre',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                    ),
                    Text('Bisa pilih lebih dari satu',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Genres.selectable.map((id) {
                    final selected = _selected.contains(id);
                    return _GenreChip(
                      label: Genres.nameOf(id),
                      selected: selected,
                      onTap: () => setState(() {
                        selected ? _selected.remove(id) : _selected.add(id);
                      }),
                    );
                  }).toList(),
                ),
                if (!canSearch) ...[
                  const SizedBox(height: 10),
                  const Text('Pilih minimal 1 genre',
                      style: TextStyle(fontSize: 12, color: AppColors.error)),
                ],
                const SizedBox(height: 28),
                const Text('Urutkan Berdasarkan',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _SegmentedSort(
                  value: _sort,
                  onChanged: (v) => setState(() => _sort = v),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text('Rating Minimum',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600)),
                    ),
                    Text('${_minRating.toStringAsFixed(1)}+',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold)),
                  ],
                ),
                Slider(
                  value: _minRating,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (v) => setState(() => _minRating = v),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text('10',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'Cari Rekomendasi',
                    icon: Icons.auto_awesome,
                    onPressed: canSearch ? _search : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenreChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedSort extends StatelessWidget {
  final SortOption value;
  final ValueChanged<SortOption> onChanged;

  const _SegmentedSort({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: SortOption.values.map((option) {
          final active = option == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
