import 'package:flutter/material.dart';
import 'package:texflow/models/status.dart';
import 'package:texflow/shared/app_colors.dart';

String statusLabel(Status status) {
  switch (status) {
    case Status.naoIniciado:
      return 'Planejamento';
    case Status.emAndamento:
      return 'Em produção';
    case Status.concluido:
      return 'Concluído';
    case Status.cancelado:
      return 'Cancelado';
  }
}

Color statusColor(Status status) {
  switch (status) {
    case Status.naoIniciado:
      return AppColors.purple;
    case Status.emAndamento:
      return AppColors.primary;
    case Status.concluido:
      return AppColors.success;
    case Status.cancelado:
      return AppColors.danger;
  }
}
