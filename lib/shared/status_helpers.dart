import 'package:flutter/material.dart';
import 'package:texflow/models/status.dart';

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
      return const Color(0xFF8B5CF6);
    case Status.emAndamento:
      return const Color(0xFF4C5FE0);
    case Status.concluido:
      return const Color(0xFF2CB88A);
    case Status.cancelado:
      return const Color(0xFFE0524A);
  }
}
