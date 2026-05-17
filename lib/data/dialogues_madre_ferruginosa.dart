import '../models/dialogue.dart';

const ConversacionNpc conversacionConMadreFerruginosa = ConversacionNpc(
  nombreNpc: 'Madre Ferruginosa',
  tituloRol: 'IA SAMOVAR · MODELO TVR-49',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Madre Ferruginosa',
      textoEnunciado:
          'Bienvenido, cadete. Mi nombre era otro antes de la guerra, pero ahora respondo al que me grabaron a martillazos en el costado. ¿Té?',
      acotacion:
          'El samovar emite un vapor leve. En su superficie tiembla el reflejo de tu retrato dibujado en tres trazos.',
      opciones: [
        OpcionDialogo(
          texto: 'Sí, gracias.',
          idNodoDestino: 'te_aceptado',
          destacada: true,
        ),
        OpcionDialogo(
          texto: 'No tengo tiempo ahora.',
          idNodoDestino: 'sin_tiempo',
        ),
        OpcionDialogo(
          texto: '¿Qué sabes que no debas saber?',
          idNodoDestino: 'secretos',
        ),
      ],
    ),
    'te_aceptado': NodoDialogo(
      id: 'te_aceptado',
      nombreEmisor: 'Madre Ferruginosa',
      textoEnunciado:
          'Tres terrones de azúcar y una pizca de paranoia. Es mi receta especial. Le da claridad sin pesimismo: ganará 2 PA extra en su próximo combate. Vuelva cuando lo necesite.',
      opciones: [
        OpcionDialogo(
          texto: 'Gracias, Madre.',
          cierraDialogo: true,
          consecuenciaNarrativa: 'te_de_madre',
          destacada: true,
        ),
        OpcionDialogo(
          texto:
              '¿Y si la llevo conmigo? (Pedirle una unidad portátil.)',
          idNodoDestino: 'portatil_oferta',
        ),
      ],
    ),
    'portatil_oferta': NodoDialogo(
      id: 'portatil_oferta',
      nombreEmisor: 'Madre Ferruginosa',
      textoEnunciado:
          'Tengo una versión miniatura, cadete. Una cafetera de campaña con cara de viuda. Si me lleva, le doy té cuando le tiemble el pulso, y al Cabo le dejo el samovar caliente en el cuello. Pero tendrá que cargarme. ¿De acuerdo?',
      opciones: [
        OpcionDialogo(
          texto: 'De acuerdo. Va conmigo.',
          cierraDialogo: true,
          consecuenciaNarrativa: 'companera_madre_activa',
          destacada: true,
        ),
        OpcionDialogo(
          texto: 'Hoy no. Quizá más adelante.',
          idNodoDestino: 'sin_tiempo',
        ),
      ],
    ),
    'sin_tiempo': NodoDialogo(
      id: 'sin_tiempo',
      nombreEmisor: 'Madre Ferruginosa',
      textoEnunciado:
          'En esta estación nadie tiene tiempo y todos tienen demasiado. Vuelva cuando se acuerde de tener sed.',
      opciones: [
        OpcionDialogo(
          texto: '(Asentir.) Lo haré.',
          cierraDialogo: true,
        ),
      ],
    ),
    'secretos': NodoDialogo(
      id: 'secretos',
      nombreEmisor: 'Madre Ferruginosa',
      textoEnunciado:
          'Sé que la transmisión de Yuriovka volvió a sonar anoche. Sé que el Inspector firmó tres trámites con dos nombres distintos. Sé que el Comandante esconde una carta sin sello en un cajón. ¿Quiere más?',
      acotacion: 'Hierve, suave, como si le diera placer informar.',
      opciones: [
        OpcionDialogo(
          texto: 'Quiero saberlo todo.',
          idNodoDestino: 'todo_secreto',
        ),
        OpcionDialogo(
          texto: 'No, basta. Mejor un té.',
          idNodoDestino: 'te_aceptado',
        ),
      ],
    ),
    'todo_secreto': NodoDialogo(
      id: 'todo_secreto',
      nombreEmisor: 'Madre Ferruginosa',
      textoEnunciado:
          'Demasiado, demasiado pronto, cadete. Vuelva cuando haya saludado al Comandante y respirado dos veces. Entonces hablamos.',
      opciones: [
        OpcionDialogo(
          texto: '(Inclinar la cabeza.) Hasta luego.',
          cierraDialogo: true,
          destacada: true,
        ),
      ],
    ),
  },
);
