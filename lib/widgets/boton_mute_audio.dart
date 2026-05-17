import 'package:flutter/material.dart';
import '../utilities/audio_procedural.dart';
import 'propaganda_button.dart';

/// Botón compacto que alterna el silencio del servicio de audio procedural.
/// Visualmente se integra con el resto de botones de propaganda.
class BotonMuteAudio extends StatefulWidget {
  const BotonMuteAudio({super.key});

  @override
  State<BotonMuteAudio> createState() => _BotonMuteAudioState();
}

class _BotonMuteAudioState extends State<BotonMuteAudio> {
  @override
  Widget build(BuildContext context) {
    final estaSilenciado = audioProcedural.silenciado;
    return BotonPropaganda(
      texto: estaSilenciado ? 'Audio: off' : 'Audio: on',
      compacto: true,
      onPressed: () {
        setState(() {
          audioProcedural.alternarSilenciado();
        });
      },
    );
  }
}
