import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'teleconsultation_model.dart';
export 'teleconsultation_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ⚠️  Remplacez ces valeurs par vos vraies clés Agora
// ─────────────────────────────────────────────────────────────────────────────
const String _agoraAppId = '1b57338080574e3ba72e5cb091a8cb45';
const String _agoraToken = '007eJxTYFiRtvPgEWWDtKs3Ul/Mcj9dyMUqxS/kMYFL5cTsq5f3z1mhwGCYZGpubGxhYGFgam6SapyUaG6UapqcZGBpmGiRnGRi6jT7dlaDFSdDwsSnjIwMjAwsDIwMh64+yWICk8xgkgVMCjMk5uTkx6fkJ5fkF8UnZyTm5aXmMDAAAMzQMFE=';
const String _agoraChannel = 'allo_doctor_channel';
// ─────────────────────────────────────────────────────────────────────────────

class TeleconsultationWidget extends StatefulWidget {
  const TeleconsultationWidget({
    super.key,
    this.channelName,
    this.token,
    this.patientName,
  });

  final String? channelName;
  final String? token;
  final String? patientName;

  static String routeName = 'TeleConsultation';
  static String routePath = '/teleConsultation';

  @override
  State<TeleconsultationWidget> createState() => _TeleconsultationWidgetState();
}

class _TeleconsultationWidgetState extends State<TeleconsultationWidget> {
  late TeleconsultationModel _model;

  RtcEngine? _engine;
  bool _localUserJoined = false;
  bool _remoteUserJoined = false;
  int? _remoteUid;
  bool _muted = false;
  bool _cameraOff = false;
  bool _speakerOn = true;
  bool _isInitializing = true;
  String? _errorMessage;

  Duration _callDuration = Duration.zero;
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeleconsultationModel());
    _stopwatch = Stopwatch();
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // Demande des permissions uniquement sur mobile (Android / iOS)
      // Sur le Web, le navigateur gère automatiquement la demande de permission
      if (!kIsWeb) {
        await [Permission.microphone, Permission.camera].request();
      }

      final engine = createAgoraRtcEngine();
      _engine = engine;

      await engine.initialize(const RtcEngineContext(
        appId: _agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            if (mounted) {
              setState(() {
                _localUserJoined = true;
                _isInitializing = false;
              });
              _stopwatch.start();
              _startTimer();
            }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _remoteUserJoined = true;
              });
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            if (mounted) {
              setState(() {
                _remoteUid = null;
                _remoteUserJoined = false;
              });
            }
          },
          onError: (err, msg) {
            if (mounted) {
              setState(() {
                _isInitializing = false;
                _errorMessage = 'Erreur Agora: $err — $msg';
              });
            }
          },
        ),
      );

      await engine.enableVideo();
      await engine.enableAudio();
      await engine.startPreview();

      await engine.joinChannel(
        token: widget.token ?? _agoraToken,
        channelId: widget.channelName ?? _agoraChannel,
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Erreur initialisation: $e';
        });
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _stopwatch.isRunning) {
        setState(() {
          _callDuration = _stopwatch.elapsed;
        });
        _startTimer();
      }
    });
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    try {
      await _engine?.muteLocalAudioStream(_muted);
    } catch (_) {}
  }

  Future<void> _toggleCamera() async {
    setState(() => _cameraOff = !_cameraOff);
    try {
      if (_cameraOff) {
        await _engine?.disableVideo();
      } else {
        await _engine?.enableVideo();
      }
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    try {
      await _engine?.switchCamera();
    } catch (_) {}
  }

  Future<void> _toggleSpeaker() async {
    setState(() => _speakerOn = !_speakerOn);
    try {
      await _engine?.setEnableSpeakerphone(_speakerOn);
    } catch (_) {}
  }

  Future<void> _endCall() async {
    _stopwatch.stop();
    try {
      await _engine?.leaveChannel();
      await _engine?.release();
    } catch (_) {}
    if (mounted) context.safePop();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _engine?.leaveChannel();
    _engine?.release();
    _model.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fond : vidéo distante ──────────────────────────────────────────
          _buildRemoteView(),

          // ── Gradient overlay bas ──────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD0A0E1A)],
                ),
              ),
            ),
          ),

          // ── Gradient overlay haut ─────────────────────────────────────────
          Positioned(
            left: 0, right: 0, top: 0,
            height: 160,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC0A0E1A), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Header : nom patient + durée ──────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Bouton retour
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.patientName ?? 'Patient',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(
                                color: _localUserJoined ? const Color(0xFF16C583) : Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _localUserJoined
                                  ? (_remoteUserJoined
                                      ? _formatDuration(_callDuration)
                                      : 'En attente du patient...')
                                  : 'Connexion...',
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Badge qualité réseau
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi, color: Color(0xFF16C583), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'HD',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Vue locale (miniature) ────────────────────────────────────────
          Positioned(
            top: 120,
            right: 16,
            width: 110,
            height: 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  _buildLocalView(),
                  if (_cameraOff)
                    Container(
                      color: const Color(0xFF1A2035),
                      child: const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54, size: 32),
                      ),
                    ),
                  // Bordure
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Message si pas encore connecté / erreur ────────────────────────
          if (_isInitializing || _errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2035),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage == null)
                      const CircularProgressIndicator(color: Color(0xFF16C583))
                    else
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? 'Initialisation de l\'appel...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.safePop(),
                        child: Text(
                          'Retour',
                          style: GoogleFonts.outfit(color: const Color(0xFF16C583)),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

          // ── Contrôles en bas ─────────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Rangée 1 : contrôles secondaires
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ControlChip(
                          icon: _speakerOn ? Icons.volume_up : Icons.volume_off,
                          label: _speakerOn ? 'HP' : 'HP off',
                          active: _speakerOn,
                          onTap: _toggleSpeaker,
                        ),
                        const SizedBox(width: 16),
                        _ControlChip(
                          icon: Icons.flip_camera_ios_outlined,
                          label: 'Retourner',
                          active: true,
                          onTap: _switchCamera,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Rangée 2 : contrôles principaux
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Micro
                        _RoundButton(
                          icon: _muted ? Icons.mic_off : Icons.mic,
                          backgroundColor: _muted
                              ? Colors.redAccent.withOpacity(0.3)
                              : Colors.white.withOpacity(0.15),
                          iconColor: _muted ? Colors.redAccent : Colors.white,
                          onTap: _toggleMute,
                          label: _muted ? 'Muet' : 'Micro',
                        ),
                        // Raccrocher (central, grand)
                        GestureDetector(
                          onTap: _endCall,
                          child: Container(
                            width: 72, height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE53935).withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                          ),
                        ),
                        // Caméra
                        _RoundButton(
                          icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                          backgroundColor: _cameraOff
                              ? Colors.redAccent.withOpacity(0.3)
                              : Colors.white.withOpacity(0.15),
                          iconColor: _cameraOff ? Colors.redAccent : Colors.white,
                          onTap: _toggleCamera,
                          label: _cameraOff ? 'Cam off' : 'Caméra',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteView() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine!,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: widget.channelName ?? _agoraChannel),
        ),
      );
    }
    // Pas encore de patient connecté
    return Container(
      color: const Color(0xFF0D1220),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1A2035),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF16C583), width: 2),
              ),
              child: const Icon(Icons.person, color: Colors.white54, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              'En attente du patient...',
              style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalView() {
    if (_engine == null || !_localUserJoined) {
      return Container(color: const Color(0xFF1A2035));
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }
}

// ── Widgets helpers ──────────────────────────────────────────────────────────

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onTap,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  const _ControlChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Colors.white.withOpacity(0.12)
              : Colors.redAccent.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.white24 : Colors.redAccent.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white70 : Colors.redAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: active ? Colors.white70 : Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
