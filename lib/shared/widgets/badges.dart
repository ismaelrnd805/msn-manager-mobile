/// Badges réutilisables : statuts colorés, priorités, état de sync.
library;

import 'package:flutter/material.dart';

import '../../core/domain/enums.dart';
import '../../core/theme/msn_theme.dart';

/// Couleur canonique d'un statut (par nom d'enum en base).
///
/// Alignée sur le système de couleurs du design (voir prototype UI/UX) :
/// bleu = nouveau/en cours, cyan = qualifié/prêt, violet = en attente
/// d'une action côté client, ambre = à relancer/partiel, vert = terminé
/// avec succès, rouge = refusé/annulé, gris = brouillon.
Color statutColor(String statut) {
  switch (statut) {
    case 'nouvelle':
    case 'envoye':
    case 'envoyee':
    case 'enCours':
    case 'aFaire':
      return MsnColors.info;
    case 'qualifiee':
    case 'pretProduction':
      return MsnColors.accent;
    case 'devisEnvoye':
    case 'converti':
    case 'enValidation':
      return MsnColors.purple;
    case 'enAttente':
    case 'en_attente':
    case 'enProduction':
    case 'expire':
    case 'partiellementPayee':
      return MsnColors.warning;
    case 'convertie':
    case 'accepte':
    case 'payee':
    case 'livree':
    case 'terminee':
    case 'termineeReminders':
      return MsnColors.success;
    case 'refuse':
    case 'annulee':
    case 'abandonnee':
      return MsnColors.danger;
    case 'brouillon':
    default:
      return MsnColors.textSecondary;
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, this.color})
      : _statut = null;

  const StatusChip.statut({super.key, required String statut, String? label})
      : label = label ?? statut,
        color = null,
        _statut = statut;

  final String label;
  final Color? color;
  final String? _statut;

  @override
  Widget build(BuildContext context) {
    final c = color ?? statutColor(_statut ?? label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  const PriorityBadge({super.key, required this.priorite});

  final Priorite priorite;

  @override
  Widget build(BuildContext context) {
    final colors = {
      Priorite.basse: MsnColors.textSecondary,
      Priorite.normale: MsnColors.info,
      Priorite.haute: MsnColors.warning,
      Priorite.urgente: MsnColors.danger,
    };
    final c = colors[priorite]!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.flag, size: 12, color: c),
        const SizedBox(width: 3),
        Text(priorite.label,
            style: TextStyle(
                color: c, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Puce d'état de synchronisation (ONLINE / OFFLINE / SYNC…).
class SyncStatusChip extends StatelessWidget {
  const SyncStatusChip({super.key, required this.status, this.compact = false});

  final SyncStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (status) {
      SyncStatus.synchronise => (Icons.cloud_done, MsnColors.success),
      SyncStatus.enCours => (Icons.sync, MsnColors.info),
      SyncStatus.erreur => (Icons.cloud_off, MsnColors.danger),
      SyncStatus.online => (Icons.cloud_queue, MsnColors.info),
      SyncStatus.offline => (Icons.cloud_off, MsnColors.textSecondary),
      SyncStatus.nonConfigure => (Icons.settings_ethernet, MsnColors.warning),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          if (!compact) ...[
            const SizedBox(width: 5),
            Text(
              status.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
