import '../models/dialogue.dart';

const ConversacionNpc conversacionConGromov = ConversacionNpc(
  nombreNpc: 'Camarada Gromov',
  tituloRol: 'PRAVDA-7 · ÚLTIMO SUPERVIVIENTE NOMINAL · 1962→',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Gromov',
      textoEnunciado:
          'Camarada cadete. Por fin alguien. Llevo aquí dieciséis personas, una de ellas yo. Las otras quince están en sus puestos exactos, con sus tazas exactas. Solo yo puedo hablar porque dejé de respirar tarde.',
      acotacion:
          'Gromov está sentado a una mesa congelada con tres tazas. La voz no le sale de la boca, sino del comunicador que sostiene contra el visor. Detrás suyo flota una pancarta espectral con la palabra "HUELGA" tachada.',
      opciones: [
        OpcionDialogo(
          texto: '¿Qué pasó aquí, camarada Gromov?',
          idNodoDestino: 'que_paso',
        ),
        OpcionDialogo(
          texto: 'Traigo los tres fragmentos de la bitácora.',
          idNodoDestino: 'fragmentos',
          requiereFlag: 'rumor_pravda7_fragmento3',
        ),
      ],
    ),
    'que_paso': NodoDialogo(
      id: 'que_paso',
      nombreEmisor: 'Gromov',
      textoEnunciado:
          'Directorskov apretó un botón el miércoles. El que apretaba los martes era seguro. El del miércoles no existía oficialmente; pero existía. La estación se desplazó al cuadrante Sigma y se quedó. No es un error. El error es que sigamos aquí, técnicamente respirando.',
      acotacion:
          'Una luz roja parpadea en el panel. La pancarta espectral oscila.',
      opciones: [
        OpcionDialogo(
          texto: 'Traigo los tres fragmentos de la bitácora.',
          idNodoDestino: 'fragmentos',
          requiereFlag: 'rumor_pravda7_fragmento3',
          destacada: true,
        ),
        OpcionDialogo(
          texto: '(Salir sin hacer nada.)',
          cierraDialogo: true,
        ),
      ],
    ),
    'fragmentos': NodoDialogo(
      id: 'fragmentos',
      nombreEmisor: 'Gromov',
      textoEnunciado:
          'Tres fragmentos. Uno escrito por Vostrikova joven. Otro recogido en una baliza por Gélida-9. Otro chamuscado por el Sol Camarada. Juntos dicen lo que el Comité llevará treinta años en negar: que Directorskov sabía. Camarada, tiene tres maneras de cerrar este expediente.',
      acotacion:
          'Gromov apoya el comunicador en la mesa. Las tres tazas tiemblan un poco.',
      opciones: [
        OpcionDialogo(
          texto:
              'Entregaré la bitácora al Inspector Krilov. El Partido decide.',
          idNodoDestino: 'final_partido',
          destacada: true,
        ),
        OpcionDialogo(
          texto:
              'Sellaré los nombres de los dieciséis y enterraré la bitácora.',
          idNodoDestino: 'final_humanista',
          destacada: true,
        ),
        OpcionDialogo(
          texto:
              'No basta. Voy a expulsar el Espectro de Directorskov a martillazos.',
          idNodoDestino: 'final_combate',
          requiereCuerpoMinimo: 7,
        ),
        OpcionDialogo(
          texto:
              'No basta. Voy a desmontar la mentira con un decreto contrarrevolucionario.',
          idNodoDestino: 'final_combate',
          requiereCarismaMinimo: 8,
        ),
        OpcionDialogo(
          texto:
              'No basta. Voy a desmontar el bucle electromecánico que '
              'sostiene al Espectro.',
          idNodoDestino: 'final_combate',
          requiereMenteMinima: 8,
        ),
      ],
    ),
    'final_partido': NodoDialogo(
      id: 'final_partido',
      nombreEmisor: 'Gromov',
      textoEnunciado:
          'Decisión partidista, camarada. Mi nombre figurará reglamentariamente como "vacante administrativa". Lléveselo todo. El Inspector no le abrazará, pero le firmará el visado. Vuele tranquila la Pravda-12.',
      acotacion:
          'Gromov deja el comunicador en la mesa. La pancarta espectral se enrolla por última vez.',
      opciones: [
        OpcionDialogo(
          texto: '(Aceptar y volver.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'pravda7_final_partido',
          destacada: true,
        ),
      ],
    ),
    'final_humanista': NodoDialogo(
      id: 'final_humanista',
      nombreEmisor: 'Gromov',
      textoEnunciado:
          'Gracias, camarada. El Partido se enfadará pero no podrá probar nada: las pruebas duermen aquí con nosotros. Llévele a Vostrikova un saludo y dígale que Gromov dejó las tazas servidas. Saldrá usted con un expediente más limpio del que merece.',
      acotacion:
          'Gromov inclina el casco. La taza del centro se inclina con él.',
      opciones: [
        OpcionDialogo(
          texto: '(Aceptar y volver.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'pravda7_final_humanista',
          destacada: true,
        ),
      ],
    ),
    'final_combate': NodoDialogo(
      id: 'final_combate',
      nombreEmisor: 'Gromov',
      textoEnunciado:
          'Entonces tendrá que ganárselo. El Espectro de Directorskov flota detrás del panel central. Va a invocar a dos sombras de los nuestros. No las mate: no se pueden matar dos veces. Solo cállelas.',
      acotacion:
          'El comunicador chisporrotea. Una luz roja se enciende en el panel y el aire se vuelve más pesado.',
      opciones: [
        OpcionDialogo(
          texto: '(Encarar al Espectro.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'pravda7_final_combate',
          destacada: true,
        ),
      ],
    ),
  },
);
