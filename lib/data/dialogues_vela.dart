import '../models/dialogue.dart';

const ConversacionNpc conversacionConVelaTchun = ConversacionNpc(
  nombreNpc: 'Ingeniera Vostrikova',
  tituloRol: 'INGENIERA DE CINTA ADHESIVA · PRAVDA-12',
  idNodoInicial: 'saludo',
  nodos: {
    'saludo': NodoDialogo(
      id: 'saludo',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Ah, eres tú. Pasa, pasa, pero no toques nada que esté soldando, brille o cante. Las tres cosas son síntoma de mal funcionamiento. Y no me pidas el formulario F-447, está pegado al motor con cinta adhesiva por buen motivo.',
      acotacion:
          'Vostrikova está de rodillas frente a un panel abierto del reactor. Gafas de soldar levantadas sobre la frente, un rollo de cinta adhesiva pegado al antebrazo como reserva, y un cuaderno de notas con la etiqueta "DIARIO DE CAMPO" embutido en el bolsillo.',
      opciones: [
        OpcionDialogo(
          texto: 'Vengo de parte del Comandante Ostrog.',
          idNodoDestino: 'conoces_a_ostrog',
          requiereFlag: 'hablo_con_ostrog',
        ),
        OpcionDialogo(
          texto: '¿Necesitas ayuda con algo?',
          idNodoDestino: 'explica_caja',
        ),
        OpcionDialogo(
          texto: '¿Es seguro este reactor?',
          idNodoDestino: 'pregunta_reactor',
          requiereMenteMinima: 6,
        ),
      ],
    ),
    'conoces_a_ostrog': NodoDialogo(
      id: 'conoces_a_ostrog',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Ostrog. Ese hombre lleva veinte años diciéndome que repare cosas que sabemos que nunca volverán a funcionar. Le tengo cariño. ¿Te ha dicho lo de la caja?',
      acotacion: 'Levanta una ceja. Espera.',
      opciones: [
        OpcionDialogo(
          texto: 'Mencionó algo. Cuéntame.',
          idNodoDestino: 'explica_caja',
          destacada: true,
        ),
      ],
    ),
    'pregunta_reactor': NodoDialogo(
      id: 'pregunta_reactor',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          '"La cinta adhesiva no tiene ideología. Pero pega igual de bien en todos los sistemas políticos." Eso digo yo y eso anoto en el diario de campo. Es seguro en el mismo sentido en que es seguro vivir: probablemente. Los dos núcleos resuenan en fase desde que rompí la junta secundaria con un martillo. Si dejas de oírlo respirar, sal corriendo.',
      acotacion:
          'Da una palmada cariñosa al casco del reactor. Algo cruje dentro.',
      opciones: [
        OpcionDialogo(
          texto: 'Entendido. Vengo a otra cosa: ¿necesitas ayuda?',
          idNodoDestino: 'explica_caja',
          destacada: true,
        ),
      ],
    ),
    'explica_caja': NodoDialogo(
      id: 'explica_caja',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Tengo una caja. No tiene etiqueta. Mejor que no tenga etiqueta. Necesito que la escondas en algún lugar de la Pravda-12 donde el Inspector Krilov no mire. Y donde tampoco mire la propia caja, porque a veces parece que mire.',
      acotacion:
          'Señala con la barbilla a una caja metálica gris junto a un panel. No tiembla, no zumba, pero ocupa el aire alrededor más densamente que el resto del aire.',
      opciones: [
        OpcionDialogo(
          texto: 'Cuenta conmigo. La escondo.',
          idNodoDestino: 'aceptar_esconder',
          destacada: true,
          requiereSinFlag: 'caja_entregada_krilov',
        ),
        OpcionDialogo(
          texto: 'Antes de aceptar, déjame examinarla.',
          idNodoDestino: 'intentar_abrir_caja',
          requiereMenteMinima: 7,
          requiereSinFlag: 'caja_entregada_krilov',
        ),
        OpcionDialogo(
          texto:
              'Antes de aceptar, déjame forzar el cierre a mano.',
          idNodoDestino: 'intentar_abrir_caja',
          requiereCuerpoMinimo: 7,
          requiereSinFlag: 'caja_entregada_krilov',
        ),
        OpcionDialogo(
          texto: 'Lo siento, Vostrikova. Le voy a contar al Inspector.',
          idNodoDestino: 'aceptar_entregar',
          requiereSinFlag: 'caja_escondida_vela',
        ),
      ],
    ),
    'intentar_abrir_caja': NodoDialogo(
      id: 'intentar_abrir_caja',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          '... ¿Tú sabes lo que haces? Está bien, pero rápido. El cierre es eléctrico de 1958, no le des con la mano.',
      acotacion:
          'Te tiende una varilla aislada. Aplicas dos toques en la secuencia correcta. La caja exhala, casi un suspiro humano.',
      opciones: [
        OpcionDialogo(
          texto: '(Mirar dentro.)',
          idNodoDestino: 'vio_lo_que_hay_dentro',
          destacada: true,
          consecuenciaNarrativa: 'caja_vista',
        ),
      ],
    ),
    'vio_lo_que_hay_dentro': NodoDialogo(
      id: 'vio_lo_que_hay_dentro',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Eso, camarada, es un comunicador de larga distancia. Frecuencias prohibidas. Si Krilov lo encuentra, no es solo a mí a quien reasignan a una boya: también al Camarada Gromov, que ya respira menos por llegar tarde al turno. Lo encontré en el Reactor 2 hace seis meses. Alguien lo había escondido allí desde 1958. Lo he estado escuchando.',
      acotacion:
          'Sus manos están firmes pero los ojos no. Cierra la caja con cuidado.',
      opciones: [
        OpcionDialogo(
          texto: 'Lo escondo igualmente. Confía en mí.',
          idNodoDestino: 'aceptar_esconder',
          destacada: true,
        ),
        OpcionDialogo(
          texto: '¿Qué has escuchado en esas frecuencias?',
          idNodoDestino: 'frecuencias_prohibidas',
        ),
        OpcionDialogo(
          texto: 'Tras ver esto, sigo prefiriendo contárselo a Krilov.',
          idNodoDestino: 'aceptar_entregar',
        ),
      ],
    ),
    'frecuencias_prohibidas': NodoDialogo(
      id: 'frecuencias_prohibidas',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Una voz, en frecuencia descendiente. Habla en un protocolo de la Misión Petrov del 58. Repite tres palabras: "todavía estamos abajo". No sé quién es ese plural. Y no sé qué es ese abajo. Sospecho que es la Pravda-7. La que perdió Directorskov.',
      acotacion:
          'Se quita las gafas de soldar. Sus ojos son más jóvenes sin ellas.',
      opciones: [
        OpcionDialogo(
          texto: 'La escondo. Esto se queda entre nosotros.',
          idNodoDestino: 'aceptar_esconder',
          destacada: true,
        ),
        OpcionDialogo(
          texto: 'Es información que el Inspector querrá tener.',
          idNodoDestino: 'aceptar_entregar',
        ),
      ],
    ),
    'aceptar_esconder': NodoDialogo(
      id: 'aceptar_esconder',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Gracias, camarada. Llévatela y métela detrás del samovar de Madre Ferruginosa. Si te pregunta qué es, dile que un té. Ella entenderá. Y si Krilov pregunta por mí, yo siempre estoy reparando algo. Es mi alibi y mi profesión.',
      acotacion:
          'Te entrega la caja envuelta en un trapo. Pesa menos de lo que parece.',
      opciones: [
        OpcionDialogo(
          texto: 'Contigo, Vostrikova. (Aceptar la caja.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'caja_escondida_vela',
          destacada: true,
        ),
      ],
    ),
    'aceptar_entregar': NodoDialogo(
      id: 'aceptar_entregar',
      nombreEmisor: 'Vostrikova',
      textoEnunciado:
          'Vaya. Bien. Es tu decisión, camarada. Lo entiendo, en serio. Solo... no le digas a Ostrog que fui yo quien la tenía. Dile que la encontraste tú. Por su sueño.',
      acotacion:
          'Su voz se vuelve seca. Vuelve a bajarse las gafas y reanuda la soldadura.',
      opciones: [
        OpcionDialogo(
          texto: '(Coger la caja para entregarla a Krilov.)',
          cierraDialogo: true,
          consecuenciaNarrativa: 'caja_entregada_krilov',
          destacada: true,
        ),
      ],
    ),
  },
);
