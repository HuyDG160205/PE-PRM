import 'package:flutter/material.dart';
import 'package:pe/app/theme.dart';
import 'package:pe/features/equipment/domain/entities/equipment.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.isComparing = false,
    this.onToggleCompare,
  });

  final Equipment device;
  final VoidCallback onTap;
  final bool isComparing;
  final VoidCallback? onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final palette = categoryPalette(device.category);
    final yearLabel = device.hasYear ? '${device.year}' : 'Unknown year';
    final priceLabel = device.hasPrice ? '\$${device.price!.toStringAsFixed(0)}' : 'Price N/A';
    final depositLabel = 'Deposit \$${device.deposit.toStringAsFixed(0)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: palette.bg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      categoryBadgeLabel(device.category),
                      style: TextStyle(
                        color: palette.fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                device.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (onToggleCompare != null)
                              IconButton(
                                tooltip: isComparing ? 'Remove from watchlist' : 'Add to watchlist',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                icon: Icon(
                                  isComparing ? Icons.bookmark : Icons.bookmark_border,
                                  color: isComparing ? AppColors.primary : AppColors.textMuted,
                                  size: 22,
                                ),
                                onPressed: onToggleCompare,
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${device.category} • $yearLabel',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$priceLabel • $depositLabel',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
