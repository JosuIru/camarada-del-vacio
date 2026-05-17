import '../models/dialogue.dart';

const ConversacionNpc conversacionConDelegadoSolar = ConversacionNpc(
  nombreNpc: 'Delegado Sindical Solar',
  tituloRol: 'SESG · RAMA 7-B · MEDIADOR ESTELAR · 1962',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Delegado Sindical',
      textoEnunciado:
          'Camarada cadete. Le hablo en nombre del Sol Camarada, afiliado a la rama 7-B del Sindicato Estelar Galáctico. Su Pravda-12 acaba de cruzar la frontera nominal sin haber cotizado nada. El Sol exige condiciones laborales mejores o irá a la huelga.',
      acotacion:
          'El Delegado lleva casco aislante reflejante. Sobre la mesa de negociación, cuatro papeles oficiales, todos rojos. Por el altavoz se oye al Sol gruñir despacio, como una caldera vieja.',
      opciones: [
        OpcionDialogo(
          texto:
              'En nombre del Comité Cósmico acepto las demandas del Sol y firmo el pliego.',
          idNodoDestino: 'ceder',
        ),
        OpcionDialogo(
          texto:
              'Decreto que su huelga es contrarrevolucionaria y queda anulada.',
          idNodoDestino: 'decreto_anular',
          requiereCarismaMinimo: 7,
        ),
        OpcionDialogo(
          texto:
              'Saboteo el altavoz por la espalda; sin altavoz no hay sindicato.',
          idNodoDestino: 'sabotaje',
          requiereMenteMinima: 7,
        ),
        OpcionDialogo(
          texto: 'Esto se resuelve con una moción de fuerza inmediata.',
          idNodoDestino: 'forzar',
          requiereCuerpoMinimo: 7,
          destacada: true,
        ),
      ],
    ),
    'ceder': NodoDialogo(
      id: 'ceder',
      nombreEmisor: 'Delegado Sindical',
      textoEnunciado:
          'Camarada de visión clara. El pliego entra en vigor: cinco minutos extra de eclipse al año, una bandera roja por cada protuberancia y derecho a la siesta a las 14:00 hora estelar. El Sol Camarada le agradece. Tome esta hoja chamuscada: la encontramos flotando hace cuatro años. Parece bitácora.',
      acotacion:
          'El altavoz solar emite algo parecido a un suspiro. La pancarta de HUELGA se enrolla sola.',
      opciones: [
        OpcionDialogo(
          texto: '(Aceptar el fragmento y firmar.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'solar_acuerdo',
          destacada: true,
        ),
      ],
    ),
    'decreto_anular': NodoDialogo(
      id: 'decreto_anular',
      nombreEmisor: 'Delegado Sindical',
      textoEnunciado:
          'Eso… técnicamente es contrarrevolucionario por nuestra parte. Levanto la huelga. El Sol Camarada lo acepta bajo protesta formal. Aquí tiene una hoja chamuscada que llevaba años en nuestro archivo: parece de la Pravda-7.',
      acotacion:
          'El Sol bufa por el altavoz, pero el Delegado le silencia con un gesto sindical complicado.',
      opciones: [
        OpcionDialogo(
          texto: '(Aceptar el fragmento.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'solar_acuerdo',
          destacada: true,
        ),
      ],
    ),
    'sabotaje': NodoDialogo(
      id: 'sabotaje',
      nombreEmisor: 'Delegado Sindical',
      textoEnunciado:
          'El altavoz cae al suelo con la elegancia de un cuadro mal colgado. Sin altavoz no hay voz solar. Sin voz solar no hay sindicato. La huelga queda técnicamente "en espera de revocación". Aquí tiene una hoja chamuscada que estaba dentro del cono.',
      acotacion:
          'El Delegado mira el altavoz roto con una mezcla de respeto profesional y resignación.',
      opciones: [
        OpcionDialogo(
          texto: '(Recoger el fragmento.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'solar_sabotaje',
          destacada: true,
        ),
      ],
    ),
    'forzar': NodoDialogo(
      id: 'forzar',
      nombreEmisor: 'Delegado Sindical',
      textoEnunciado:
          'Una moción de fuerza contra un sindicato afiliado, cadete, es indistinguible de una huelga reventada. El Sol convocará Inspectores Sindicales. ¿Insiste?',
      acotacion:
          'El Delegado cierra el maletín dorado con un clic ceremonial.',
      opciones: [
        OpcionDialogo(
          texto: 'Insisto. Que vengan.',
          cierraDialogo: true,
          consecuenciaNarrativa: 'solar_combate',
          destacada: true,
        ),
        OpcionDialogo(
          texto:
              'Lo retiro. Mejor saboteo el altavoz silenciosamente.',
          idNodoDestino: 'sabotaje',
          requiereMenteMinima: 7,
        ),
        OpcionDialogo(
          texto:
              'Lo retiro. Arranco el altavoz con las manos antes de '
              'levantar la voz.',
          idNodoDestino: 'sabotaje',
          requiereCuerpoMinimo: 7,
        ),
        OpcionDialogo(
          texto:
              'Lo retiro. Cierro la cuestión con un decreto '
              'contrarrevolucionario y nos vamos.',
          idNodoDestino: 'decreto_anular',
          requiereCarismaMinimo: 7,
        ),
      ],
    ),
  },
);
