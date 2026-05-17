import '../models/dialogue.dart';

const ConversacionNpc conversacionConJefeGelida = ConversacionNpc(
  nombreNpc: 'Jefe de Recepción',
  tituloRol: 'GÉLIDA-9 · COMITÉ DE BIENVENIDA · EN SESIÓN DESDE 1968',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Jefe de Recepción',
      textoEnunciado:
          'Camarada cadete. Bienvenido al cordón administrativo de Gélida-9. Para acceder al planeta, presente cuarenta y siete (47) copias debidamente cumplimentadas del formulario F-447. Lleva usted una (1).',
      acotacion:
          'El Jefe de Recepción habla envuelto en vaho. Su sello escarchado pesa más que su mano. Detrás de él, una cola de burócratas congelados se extiende desde 1968. Algunos parpadean. Otros no.',
      opciones: [
        OpcionDialogo(
          texto:
              'Camarada Jefe, le propongo un duplicado matemático del F-447 que ya traigo.',
          idNodoDestino: 'ruta_mente_falsificar',
          requiereMenteMinima: 7,
        ),
        OpcionDialogo(
          texto:
              'Permita que le explique, en verso, la urgencia de mi misión.',
          idNodoDestino: 'ruta_carisma_discurso',
          requiereCarismaMinimo: 7,
        ),
        OpcionDialogo(
          texto: 'Le doy un minuto antes de cruzar de todos modos.',
          idNodoDestino: 'ruta_cuerpo_forzar',
          requiereCuerpoMinimo: 7,
          destacada: true,
        ),
        OpcionDialogo(
          texto: 'Me pongo en la cola. (Esperar.)',
          idNodoDestino: 'ruta_cola',
        ),
      ],
    ),
    'ruta_mente_falsificar': NodoDialogo(
      id: 'ruta_mente_falsificar',
      nombreEmisor: 'Jefe de Recepción',
      textoEnunciado:
          'Cuarenta y seis copias firmadas con la misma mano… técnicamente cuarenta y siete, contando el original. Reglamento §17 cláusula obscura. Lo concedo. Pase. Y llévese esto: lo encontramos congelado en una baliza el invierno de 1958.',
      acotacion:
          'Te tiende una hoja escarchada con el sello "PRAVDA-7 · BITÁCORA · FRAGMENTO 2 DE 3".',
      opciones: [
        OpcionDialogo(
          texto: '(Aceptar el fragmento y entrar.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'paso_gelida_concedido',
          destacada: true,
        ),
      ],
    ),
    'ruta_carisma_discurso': NodoDialogo(
      id: 'ruta_carisma_discurso',
      nombreEmisor: 'Jefe de Recepción',
      textoEnunciado:
          'Una octava real en honor al frío administrativo. Me ha tocado la conciencia y el reglamento, en ese orden. Pase. Esto es para usted: lo dejaron junto a una bandera congelada en 1958.',
      acotacion:
          'Una lágrima se le congela antes de caer. Te entrega una hoja escarchada con el sello "PRAVDA-7 · BITÁCORA · FRAGMENTO 2 DE 3".',
      opciones: [
        OpcionDialogo(
          texto: '(Aceptar el fragmento y entrar.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'paso_gelida_concedido',
          destacada: true,
        ),
      ],
    ),
    'ruta_cuerpo_forzar': NodoDialogo(
      id: 'ruta_cuerpo_forzar',
      nombreEmisor: 'Jefe de Recepción',
      textoEnunciado:
          'Camarada, eso constituye una moción de fuerza contra el procedimiento. Solicito al Comité de Bienvenida que active los burócratas congelados en posición defensiva.',
      acotacion:
          'Dos burócratas se descongelan crujiendo. La cola completa observa con respeto procedimental.',
      opciones: [
        OpcionDialogo(
          texto: 'Que se descongelen.',
          cierraDialogo: true,
          consecuenciaNarrativa: 'gelida_combate',
          destacada: true,
        ),
        OpcionDialogo(
          texto: 'Espere, mejor un duplicado matemático.',
          idNodoDestino: 'ruta_mente_falsificar',
          requiereMenteMinima: 7,
        ),
        OpcionDialogo(
          texto:
              'Espere. Resolvamos esto con un discurso ablandador.',
          idNodoDestino: 'ruta_carisma_discurso',
          requiereCarismaMinimo: 7,
        ),
      ],
    ),
    'ruta_cola': NodoDialogo(
      id: 'ruta_cola',
      nombreEmisor: 'Jefe de Recepción',
      textoEnunciado:
          'Saludable decisión, camarada. Su turno será atendido en 1996. Mientras tanto, contemple la pancarta del Comité, que también espera.',
      acotacion:
          'Sientes que las orejas se te congelan un poco más. No es desagradable, exactamente.',
      opciones: [
        OpcionDialogo(
          texto:
              '(Reconsiderar tras un rato.) Le propongo un duplicado matemático.',
          idNodoDestino: 'ruta_mente_falsificar',
          requiereMenteMinima: 7,
        ),
        OpcionDialogo(
          texto: '(Reconsiderar.) Mejor le explico en verso.',
          idNodoDestino: 'ruta_carisma_discurso',
          requiereCarismaMinimo: 7,
        ),
        OpcionDialogo(
          texto: '(Reconsiderar.) Cruzo de todos modos.',
          idNodoDestino: 'ruta_cuerpo_forzar',
          requiereCuerpoMinimo: 7,
        ),
        OpcionDialogo(
          texto: 'Mejor me voy. (Salir.)',
          cierraDialogo: true,
        ),
      ],
    ),
  },
);
