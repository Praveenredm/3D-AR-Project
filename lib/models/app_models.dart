import 'package:flutter/material.dart';

class DomainItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final int modelsCount;

  const DomainItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.modelsCount,
  });
}

class TopicItem {
  final String id;
  final String domainId;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? modelId;

  const TopicItem({
    required this.id,
    required this.domainId,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.modelId,
  });
}

class AnatomicalPart {
  final String id;
  final String name;
  final String description;
  final String function;
  final String bloodFlow;
  final List<String> keyPoints;
  final Offset hotspotScreenOffset; // Relative 2D projected anchor
  final double explosionOffsetX;
  final double explosionOffsetY;
  final double explosionOffsetZ;
  final Color partColor;

  const AnatomicalPart({
    required this.id,
    required this.name,
    required this.description,
    this.function = '',
    this.bloodFlow = '',
    required this.keyPoints,
    required this.hotspotScreenOffset,
    required this.explosionOffsetX,
    required this.explosionOffsetY,
    required this.explosionOffsetZ,
    required this.partColor,
  });
}

class ModelItem {
  final String id;
  final String title;
  final String subtitle;
  final String domainId;
  final String category;
  final String description;

  final Map<String, String> keyFacts;
  final List<AnatomicalPart> parts;

  final IconData icon;
  final Color accentColor;

  /// Normal 3D model
  final String? assetPath;

  /// Exploded/separated 3D model
  final String? explodedAssetPath;

  /// AR model
  final String? arAssetPath;

  /// Whether the model contains separately selectable meshes
  final bool hasSeparateMeshes;

  /// Whether exploded view is available
  final bool hasExplodedView;

  /// Whether AR is available
  final bool hasAR;

  const ModelItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.domainId,
    required this.category,
    required this.description,
    required this.keyFacts,
    required this.parts,
    required this.icon,
    required this.accentColor,

    this.assetPath,
    this.explodedAssetPath,
    this.arAssetPath,

    this.hasSeparateMeshes = false,
    this.hasExplodedView = false,
    this.hasAR = false,
  });
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class UserProfile {
  final String name;
  final String email;
  final int progressPercent;
  final int modelsViewed;
  final int quizzesDone;
  final int arSessions;

  const UserProfile({
    required this.name,
    required this.email,
    required this.progressPercent,
    required this.modelsViewed,
    required this.quizzesDone,
    required this.arSessions,
  });
}
