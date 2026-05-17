import '../models/dialogue.dart';

const ConversacionNpc conversacionConOstrog = ConversacionNpc(
  nombreNpc: 'Comandante Ostrog "el Quemado"',
  tituloRol: 'JEFE NOMINAL · GLASNOV-7',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Camarada cadete. Bien hecho con el archivador. Hacía 19 años que protestaba.',
      acotacion:
          'Ostrog está de pie en la Cantina. Tiene una mancha de soldadura en la mejilla y una taza vacía en la mano.',
      opciones: [
        OpcionDialogo(
          texto: 'Comandante. Reporto cumplimiento del primer trámite.',
          idNodoDestino: 'orden_simulacro',
          destacada: true,
        ),
        OpcionDialogo(
          texto: '¿Por qué nadie había abierto ese archivador?',
          idNodoDestino: 'archivador_historia',
        ),
        OpcionDialogo(
          texto: '(En silencio, esperar a que continúe.)',
          idNodoDestino: 'silencio_incomodo',
        ),
      ],
    ),
    'orden_simulacro': NodoDialogo(
      id: 'orden_simulacro',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Excelente. El Inspector Krilov llega en catorce horas. Necesito que la estación parezca operativa. Aviso: la palabra "parezca" es importante. Si pretendiéramos que fuera operativa, ya nos habrían cerrado.',
      acotacion: 'Hace un gesto vago hacia los pasillos. Suspira.',
      opciones: [
        OpcionDialogo(
          texto: '¿Qué necesita exactamente, comandante?',
          idNodoDestino: 'tareas',
        ),
        OpcionDialogo(
          texto: '¿Cuánto tiempo lleva sin pasar una inspección?',
          idNodoDestino: 'historia_inspecciones',
        ),
        OpcionDialogo(
          texto: 'Esto suena como una farsa.',
          idNodoDestino: 'reaccion_brusca',
        ),
      ],
    ),
    'archivador_historia': NodoDialogo(
      id: 'archivador_historia',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'El último cosmonauta que intentó archivar algo allí fue trasladado a una boya meteorológica. La boya tampoco existe ya, oficialmente. Así son las cosas.',
      acotacion: 'Mira hacia la compuerta como si esperara algo.',
      opciones: [
        OpcionDialogo(
          texto: 'Comandante, sobre la inspección...',
          idNodoDestino: 'orden_simulacro',
        ),
        OpcionDialogo(
          texto: '¿Y usted? ¿Cuánto lleva aquí?',
          idNodoDestino: 'historia_ostrog',
        ),
      ],
    ),
    'silencio_incomodo': NodoDialogo(
      id: 'silencio_incomodo',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          '... Bien. Aprecio a los cosmonautas que esperan. Significa que aún saben que la mayoría de órdenes no llegarán. Ahora, al asunto.',
      opciones: [
        OpcionDialogo(
          texto: 'Le escucho.',
          idNodoDestino: 'orden_simulacro',
        ),
      ],
    ),
    'tareas': NodoDialogo(
      id: 'tareas',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Tres cosas. Una, hable con la Ingeniera Vostrikova en el reactor: tiene una caja, no pregunte qué hay dentro y no exija el F-447. Dos, presente sus respetos al samovar Madre Ferruginosa, sirve té con bonificaciones útiles. Tres, mire de no abrir la cápsula del Inquilino #4, salvo que sea estrictamente necesario.',
      acotacion: 'Cuenta con los dedos. Le faltan dos.',
      opciones: [
        OpcionDialogo(
          texto: '¿Inquilino #4?',
          idNodoDestino: 'inquilino',
        ),
        OpcionDialogo(
          texto: 'Entendido. Procedo.',
          idNodoDestino: 'despedida',
          destacada: true,
        ),
      ],
    ),
    'historia_inspecciones': NodoDialogo(
      id: 'historia_inspecciones',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'La última fue en el 58. No vino nadie. Yo redacté el informe yo mismo, con caligrafía distinta cada párrafo. Pasé con sobresaliente.',
      opciones: [
        OpcionDialogo(
          texto: '¿Y ahora viene un Inspector real?',
          idNodoDestino: 'tareas',
        ),
      ],
    ),
    'reaccion_brusca': NodoDialogo(
      id: 'reaccion_brusca',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Camarada. La Unión Cosmonáutica es muchas cosas: lenta, vieja, mal ventilada. Pero "farsa" es una palabra que se firma con tres testigos. Modere su vocabulario.',
      acotacion: 'Tono seco. Ha levantado un milímetro la barbilla.',
      opciones: [
        OpcionDialogo(
          texto: 'Disculpe, comandante. Me explico mejor.',
          idNodoDestino: 'tareas',
          destacada: true,
        ),
      ],
    ),
    'historia_ostrog': NodoDialogo(
      id: 'historia_ostrog',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Cuarenta y un años. Llegué con una novia y un certificado. Perdí ambos en el incendio del módulo Norte. Por eso me llaman "el Quemado", aunque la mancha es solo soldadura.',
      acotacion: 'Sonríe un poco.',
      opciones: [
        OpcionDialogo(
          texto: 'Lo siento.',
          idNodoDestino: 'tareas',
        ),
      ],
    ),
    'inquilino': NodoDialogo(
      id: 'inquilino',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Un cosmonauta congelado desde 1958. Misión Petrov. No haga preguntas sobre la Misión Petrov. Si la cápsula pita, fingimos que es la nevera.',
      acotacion: 'Mira hacia un lado y baja la voz.',
      opciones: [
        OpcionDialogo(
          texto: '(Anotar mentalmente.) Procedo con las tareas.',
          idNodoDestino: 'despedida',
          destacada: true,
        ),
      ],
    ),
    'despedida': NodoDialogo(
      id: 'despedida',
      nombreEmisor: 'Ostrog',
      textoEnunciado:
          'Buena suerte, camarada. Y recuerde: la productividad oficial nunca coincide con la real. Es ahí donde vivimos.',
      acotacion: 'Levanta su taza vacía como brindando.',
      opciones: [
        OpcionDialogo(
          texto: 'Por la productividad oficial. (Saludar y retirarse.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'ostrog_alineado',
          destacada: true,
        ),
      ],
    ),
  },
);
