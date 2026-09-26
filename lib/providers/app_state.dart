import 'package:flutter/material.dart';

import '../models/app_models.dart' hide QuizQuestion;
import '../data/app_data.dart';

enum ViewerMode { normal, exploded, xray }

enum ARStatus { instructions, scanning, placed }

class AppState extends ChangeNotifier {
  // Navigation
  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  // User Profile & Progress
  final String _userName = 'Praveen';
  String get userName => _userName;

  int _progressPercent = 68;
  int get progressPercent => _progressPercent;

  int _modelsViewed = 12;
  int get modelsViewed => _modelsViewed;

  int _quizzesDone = 5;
  int get quizzesDone => _quizzesDone;

  int _arSessions = 3;
  int get arSessions => _arSessions;

  final Set<String> _bookmarkedIds = {'heart', 'brain'};
  Set<String> get bookmarkedIds => _bookmarkedIds;

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  void toggleBookmark(String id) {
    if (_bookmarkedIds.contains(id)) {
      _bookmarkedIds.remove(id);
    } else {
      _bookmarkedIds.add(id);
    }
    notifyListeners();
  }

  // Domain & Category Filter
  String _activeCategory = 'All';
  String get activeCategory => _activeCategory;

  void setActiveCategory(String category) {
    _activeCategory = category;
    notifyListeners();
  }

  // 3D Viewer State
  ModelItem _currentModel = AppData.heartModel;
  ModelItem get currentModel => _currentModel;

  ViewerMode _viewerMode = ViewerMode.normal;
  ViewerMode get viewerMode => _viewerMode;

  double _explosionRatio = 0.0;
  double get explosionRatio => _explosionRatio;

  String? _selectedPartId = 'aorta';
  String? get selectedPartId => _selectedPartId;

  bool _showHotspots = true;
  bool get showHotspots => _showHotspots;

  bool _isAutoRotating = false;
  bool get isAutoRotating => _isAutoRotating;

  double _zoomScale = 1.0;
  double get zoomScale => _zoomScale;

  void setModel(ModelItem model) {
    _currentModel = model;
    _explosionRatio = 0.0;
    _selectedPartId = model.parts.isNotEmpty ? model.parts.first.id : null;
    _viewerMode = ViewerMode.normal;
    _modelsViewed++;
    notifyListeners();
  }

  void setViewerMode(ViewerMode mode) {
    _viewerMode = mode;
    if (mode == ViewerMode.exploded && _explosionRatio == 0.0) {
      _explosionRatio = 0.55;
    } else if (mode == ViewerMode.normal) {
      _explosionRatio = 0.0;
    }
    notifyListeners();
  }

  void setExplosionRatio(double ratio) {
    _explosionRatio = ratio.clamp(0.0, 1.0);
    if (_explosionRatio > 0.05 && _viewerMode != ViewerMode.exploded) {
      _viewerMode = ViewerMode.exploded;
    } else if (_explosionRatio == 0.0 && _viewerMode == ViewerMode.exploded) {
      _viewerMode = ViewerMode.normal;
    }
    notifyListeners();
  }

  void setSelectedPartId(String? partId) {
    _selectedPartId = partId;
    notifyListeners();
  }

  void toggleHotspots() {
    _showHotspots = !_showHotspots;
    notifyListeners();
  }

  void toggleAutoRotate() {
    _isAutoRotating = !_isAutoRotating;
    notifyListeners();
  }

  void setZoomScale(double zoom) {
    _zoomScale = zoom.clamp(0.5, 3.0);
    notifyListeners();
  }

  void zoomIn() => setZoomScale(_zoomScale + 0.2);
  void zoomOut() => setZoomScale(_zoomScale - 0.2);
  void resetView() {
    _zoomScale = 1.0;
    _explosionRatio = 0.0;
    _viewerMode = ViewerMode.normal;
    _isAutoRotating = false;
    notifyListeners();
  }

  // AR Experience State
  ARStatus _arStatus = ARStatus.instructions;
  ARStatus get arStatus => _arStatus;

  double _arPlacementScale = 1.0;
  double get arPlacementScale => _arPlacementScale;

  double _arPlacementRotation = 0.0;
  double get arPlacementRotation => _arPlacementRotation;

  void startARScan() {
    _arStatus = ARStatus.scanning;
    _arSessions++;
    notifyListeners();
  }

  void placeARModel() {
    _arStatus = ARStatus.placed;
    notifyListeners();
  }

  void resetARExperience() {
    _arStatus = ARStatus.instructions;
    _arPlacementScale = 1.0;
    _arPlacementRotation = 0.0;
    notifyListeners();
  }

  void setARScale(double scale) {
    _arPlacementScale = scale.clamp(0.4, 2.5);
    notifyListeners();
  }

  void setARRotation(double rotation) {
    _arPlacementRotation = rotation;
    notifyListeners();
  }

  // Quiz State
  List<QuizQuestion> _questions = AppData.quizQuestions;
  List<QuizQuestion> get questions => _questions;

  int _currentQuizIndex = 0;
  int get currentQuizIndex => _currentQuizIndex;

  int? _selectedQuizAnswerIndex;
  int? get selectedQuizAnswerIndex => _selectedQuizAnswerIndex;

  bool _isAnswerSubmitted = false;
  bool get isAnswerSubmitted => _isAnswerSubmitted;

  int _quizScore = 0;
  int get quizScore => _quizScore;

  bool _isQuizCompleted = false;
  bool get isQuizCompleted => _isQuizCompleted;

  void startQuiz({
    required String domainId,
    required String category,
    required int questionCount,
  }) {
    final availableQuestions = AppData.quizQuestionsFor(
      domainId: domainId,
      category: category,
    );
    _questions = availableQuestions.take(questionCount).toList();
    _currentQuizIndex = 0;
    _selectedQuizAnswerIndex = null;
    _isAnswerSubmitted = false;
    _quizScore = 0;
    _isQuizCompleted = false;
    notifyListeners();
  }

  void selectQuizAnswer(int index) {
    if (_isAnswerSubmitted) return;
    _selectedQuizAnswerIndex = index;
    _isAnswerSubmitted = true;

    if (index == _questions[_currentQuizIndex].correctIndex) {
      _quizScore++;
    }
    notifyListeners();
  }

  void nextQuizQuestion() {
    if (_currentQuizIndex < _questions.length - 1) {
      _currentQuizIndex++;
      _selectedQuizAnswerIndex = null;
      _isAnswerSubmitted = false;
    } else {
      _isQuizCompleted = true;
      _quizzesDone++;
      _progressPercent = (_progressPercent + 4).clamp(0, 100);
    }
    notifyListeners();
  }

  void restartQuiz() {
    _questions = AppData.quizQuestions;
    _currentQuizIndex = 0;
    _selectedQuizAnswerIndex = null;
    _isAnswerSubmitted = false;
    _quizScore = 0;
    _isQuizCompleted = false;
    notifyListeners();
  }
}
