import 'package:flutter/material.dart';
import 'favorites_services.dart';
import 'screens/theme.dart';

class FavoriteButton extends StatefulWidget {
  final Map<String, dynamic> place;

  const FavoriteButton({
    super.key,
    required this.place,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final result = await FavoritesService.isFavorite(widget.place);

    if (!mounted) return;

    setState(() {
      isFavorite = result;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await FavoritesService.removeFavorite(widget.place);
    } else {
      await FavoritesService.addFavorite(widget.place);
    }

    if (!mounted) return;

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _toggleFavorite,
      icon: Icon(
        isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
      ),
      color: AppColors.primaryTeal,
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
    );
  }
}
