import '../models/dialogue.dart';

const ConversacionNpc conversacionConAlcaldeZovnak = ConversacionNpc(
  nombreNpc: 'Alcalde Provisional',
  tituloRol: 'PRESIDENCIA · ASAMBLEA PERMANENTE ZOVNAK-4',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Alcalde Provisional',
      textoEnunciado:
          'Camarada cadete. La asamblea lleva en sesión cuarenta años. Acaba de aprobar, por trescientos veintidós a trescientos veintidós, conocerle a usted. ¿Trae el formulario F-447?',
      acotacion:
          'Tres ojos rojos miden tu paciencia. Las antenas de la sien vibran al ritmo del quórum. El martillo de asamblea está hecho de basalto pulido.',
      opciones: [
        OpcionDialogo(
          texto: '(Mostrar el F-447 que llevas encima.)',
          idNodoDestino: 'f447_aceptado',
          destacada: true,
          requiereMenteMinima: 6,
        ),
        OpcionDialogo(
          texto:
              'No tengo formulario, pero traigo razones excelentes y rimadas.',
          idNodoDestino: 'discurso_intentado',
          requiereCarismaMinimo: 7,
        ),
        OpcionDialogo(
          texto: 'No traigo nada. ¿Qué votan ahora mismo?',
          idNodoDestino: 'que_se_vota',
        ),
        OpcionDialogo(
          texto: '(Mirar amenazadoramente la urna.)',
          idNodoDestino: 'amenaza_urna',
          requiereCuerpoMinimo: 7,
        ),
      ],
    ),
    'f447_aceptado': NodoDialogo(
      id: 'f447_aceptado',
      nombreEmisor: 'Alcalde Provisional',
      textoEnunciado:
          'Un F-447 en tres copias carbónicas. Mocionemos su admisión inmediata. La asamblea aprueba por unanimidad — salvo dos abstenciones técnicas y una "duda existencial". Sea bienvenido. La Pravda-7 está más cerca de lo que cree. Tome este sello.',
      acotacion:
          'Te entrega una insignia oxidada con la inscripción "VOTANTE HONORARIO".',
      opciones: [
        OpcionDialogo(
          texto: 'Gracias, Alcalde. (Aceptar la insignia.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'alcalde_aliado',
          destacada: true,
        ),
      ],
    ),
    'discurso_intentado': NodoDialogo(
      id: 'discurso_intentado',
      nombreEmisor: 'Alcalde Provisional',
      textoEnunciado:
          'Una décima endecasílaba sobre el reparto del oxígeno por méritos laborales. Conmovedora. La asamblea llora reglamentariamente. La asamblea vota llorar más. La votación dura tres horas. Le concedemos paso, pero su rima "vodka-cosmos" queda anotada como deuda métrica.',
      acotacion:
          'Las antenas se inclinan en señal de respeto unánime forzado.',
      opciones: [
        OpcionDialogo(
          texto: 'Acepto la deuda. (Pasar.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'alcalde_aliado',
          destacada: true,
        ),
      ],
    ),
    'que_se_vota': NodoDialogo(
      id: 'que_se_vota',
      nombreEmisor: 'Alcalde Provisional',
      textoEnunciado:
          'En este momento se vota si la luz puede estar encendida. La votación lleva cuarenta años. No tiene quórum desde el martes. Si quiere pasar, vote a favor o conviértalo en moción para combate inmediato.',
      acotacion:
          'Los marcianos votantes te miran como quien mira a un nuevo punto del orden del día.',
      opciones: [
        OpcionDialogo(
          texto: 'Voto a favor de la luz. (Pasar pacíficamente.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'alcalde_pacifico',
        ),
        OpcionDialogo(
          texto: 'Lo convierto en moción de combate.',
          cierraDialogo: true,
          consecuenciaNarrativa: 'alcalde_combate',
          destacada: true,
        ),
      ],
    ),
    'amenaza_urna': NodoDialogo(
      id: 'amenaza_urna',
      nombreEmisor: 'Alcalde Provisional',
      textoEnunciado:
          'Camarada, la urna nº 47 está protegida por sesenta años de consenso doloroso. Si la toca, la asamblea moverá moción de defensa. Mociónese contra el camarada.',
      acotacion:
          'Las papeletas ya levantadas tiemblan como banderas pequeñas.',
      opciones: [
        OpcionDialogo(
          texto: 'Que se mocione. (Provocar combate.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'alcalde_combate',
          destacada: true,
        ),
        OpcionDialogo(
          texto: 'Retiro la mirada. (Calmar.)',
          idNodoDestino: 'que_se_vota',
        ),
      ],
    ),
  },
);
