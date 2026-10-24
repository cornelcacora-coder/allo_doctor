import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service central du mode hors-ligne pour Allo Docteur.
///
/// Fonctionnalités :
/// - Détection temps réel de la connectivité (via connectivity_plus)
/// - Activation du cache Firestore offline (persistance automatique)
/// - Mise en cache locale des données patient critiques (SharedPreferences)
/// - Synchronisation automatique à la reconnexion
class OfflineService extends ChangeNotifier {
  // ─── Singleton ───────────────────────────────────────────────────────────
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  // ─── État ────────────────────────────────────────────────────────────────
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  SharedPreferences? _prefs;

  // ─── Clés SharedPreferences ──────────────────────────────────────────────
  static const String _keyPatientId = 'offline_patient_id';
  static const String _keyPatientName = 'offline_patient_name';
  static const String _keyPatientEmail = 'offline_patient_email';
  static const String _keyPrescriptions = 'offline_prescriptions';
  static const String _keyAppointments = 'offline_appointments';
  static const String _keyLastSync = 'offline_last_sync';

  // ─── Initialisation ──────────────────────────────────────────────────────

  /// Initialise le service — à appeler une fois au démarrage de l'app.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();

    // Activer la persistance Firestore offline (non-web uniquement)
    if (!kIsWeb) {
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (_) {
        // Déjà initialisé
      }
    }
    // Sur Web, Firestore gère son propre cache via les settings standards, inutile d'appeler enablePersistence qui déclenche failed-precondition lors des hot restarts.

    // Écouter les changements de connectivité
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);

    // Vérifier l'état initial
    final result = await Connectivity().checkConnectivity();
    _updateOnlineStatus(result);
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateOnlineStatus(results);
  }

  void _updateOnlineStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = results.any((r) => r != ConnectivityResult.none);

    if (_isOnline != wasOnline) {
      notifyListeners();
      if (_isOnline) {
        // Vient de se reconnecter — synchroniser
        _syncOnReconnect();
      }
    }
  }

  // ─── Mise en cache des données patient ───────────────────────────────────

  /// Met en cache le profil patient (appelé à la connexion).
  Future<void> cachePatientProfile({
    required String patientId,
    required String name,
    required String email,
  }) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyPatientId, patientId);
    await prefs.setString(_keyPatientName, name);
    await prefs.setString(_keyPatientEmail, email);
    await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  /// Met en cache la liste des ordonnances.
  Future<void> cachePrescriptions(
      List<Map<String, dynamic>> prescriptions) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyPrescriptions, jsonEncode(prescriptions));
    await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  /// Met en cache la liste des rendez-vous.
  Future<void> cacheAppointments(
      List<Map<String, dynamic>> appointments) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(_keyAppointments, jsonEncode(appointments));
    await prefs.setString(_keyLastSync, DateTime.now().toIso8601String());
  }

  // ─── Lecture du cache ────────────────────────────────────────────────────

  String get cachedPatientId => _prefs?.getString(_keyPatientId) ?? '';
  String get cachedPatientName =>
      _prefs?.getString(_keyPatientName) ?? 'Patient';
  String get cachedPatientEmail => _prefs?.getString(_keyPatientEmail) ?? '';

  List<Map<String, dynamic>> get cachedPrescriptions {
    final raw = _prefs?.getString(_keyPrescriptions);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> get cachedAppointments {
    final raw = _prefs?.getString(_keyAppointments);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  String get lastSyncLabel {
    final raw = _prefs?.getString(_keyLastSync);
    if (raw == null) return 'Jamais synchronisé';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'A l\'instant';
      if (diff.inMinutes < 60) return 'Il y a \${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a \${diff.inHours}h';
      return 'Il y a \${diff.inDays} jour(s)';
    } catch (_) {
      return 'Inconnu';
    }
  }

  // ─── Synchronisation à la reconnexion ────────────────────────────────────

  Future<void> _syncOnReconnect() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Re-télécharger les ordonnances
      final prescSnap = await FirebaseFirestore.instance
          .collection('prescriptions')
          .where('patientId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      final prescriptions = prescSnap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
      await cachePrescriptions(prescriptions);

      // Re-télécharger les RDV
      final apptSnap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(30)
          .get();

      final appointments = apptSnap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
      await cacheAppointments(appointments);

      debugPrint(
          '[OfflineService] Synchronisation terminée après reconnexion');
    } catch (e) {
      debugPrint('[OfflineService] Erreur de synchronisation : \$e');
    }
  }

  /// Forcer une synchronisation manuelle.
  Future<void> forceSyncNow() async {
    if (!_isOnline) return;
    await _syncOnReconnect();
    notifyListeners();
  }

  // ─── Nettoyage ───────────────────────────────────────────────────────────

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
