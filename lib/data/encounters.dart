import '../models/character.dart';
import 'enemies.dart';

enum TipoEncuentro {
  archivadorYRatas,
  emboscadaCabo,
  asambleaZovnak4,
  recepcionGelida9,
  huelgaSolar,
  bossPravda7,
}

class ConfiguracionEnemigoEnGrid {
  final Combatiente Function() factoria;
  final int filaInicial;
  final int columnaInicial;

  const ConfiguracionEnemigoEnGrid({
    required this.factoria,
    required this.filaInicial,
    required this.columnaInicial,
  });
}

class ConfiguracionEncuentro {
  final List<ConfiguracionEnemigoEnGrid> enemigos;
  final String textoApertura;
  final String textoVictoria;
  final String textoDerrota;
  final int xpRecompensa;
  final String? idObjetoBotin;

  const ConfiguracionEncuentro({
    required this.enemigos,
    required this.textoApertura,
    required this.textoVictoria,
    required this.textoDerrota,
    this.xpRecompensa = 3,
    this.idObjetoBotin,
  });
}

ConfiguracionEncuentro obtenerConfiguracionEncuentro(TipoEncuentro tipo) {
  switch (tipo) {
    case TipoEncuentro.archivadorYRatas:
      return ConfiguracionEncuentro(
        enemigos: [
          ConfiguracionEnemigoEnGrid(
            factoria: crearFuncionarioEspectralDeArchivo,
            filaInicial: 1,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearRataMutadaDeMantenimiento,
            filaInicial: 0,
            columnaInicial: 5,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearRataMutadaDeMantenimiento,
            filaInicial: 2,
            columnaInicial: 5,
          ),
        ],
        textoApertura:
            '— ¡Documentación, ciudadano! — exige el Funcionario abriendo un formulario que se autorrellena. De dos cajones inferiores brotan, chillando, dos Ratas Mutadas de Mantenimiento.',
        textoVictoria:
            'El Funcionario Espectral se disuelve en polvo de carbón y las ratas se retiran detrás de las paredes con dignidad burocrática.',
        textoDerrota:
            'Pierdes la compostura. El Funcionario te declara "improductivo" y los roedores festejan con un baile reglamentario.',
        xpRecompensa: 6,
        idObjetoBotin: 'ushanka_termica',
      );

    case TipoEncuentro.emboscadaCabo:
      // La antigua emboscada del Cabo + Auxiliar pasa a ser una patrulla
      // de la Brigada del Sello en sus tres variantes (garrote, puños y
      // rifle). El nombre del TipoEncuentro se conserva por compatibilidad
      // con el room/reactor que lo referencian.
      return ConfiguracionEncuentro(
        enemigos: [
          ConfiguracionEnemigoEnGrid(
            factoria: crearBrigadistaSelloGarrote,
            filaInicial: 1,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearBrigadistaSelloPunos,
            filaInicial: 2,
            columnaInicial: 5,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearBrigadistaSelloRifle,
            filaInicial: 0,
            columnaInicial: 6,
          ),
        ],
        textoApertura:
            'Tres brigadistas del Sello entran en formación. El del garrote escupe al suelo. El de los puños se truena los nudillos. El del rifle, atrás, ya tiene tu nombre en el cargador.',
        textoVictoria:
            'La patrulla cae con sus respectivos sellos a medio estampar. Los tres expedientes que llevaban quedan dispersos en el suelo, sin firma legible.',
        textoDerrota:
            'La Brigada del Sello te reduce contra el suelo y te imprime, con cuidado funcionarial, tres sellos rojos en la frente.',
        xpRecompensa: 11,
        idObjetoBotin: 'casco_ingeniera',
      );

    case TipoEncuentro.asambleaZovnak4:
      return ConfiguracionEncuentro(
        enemigos: [
          ConfiguracionEnemigoEnGrid(
            factoria: crearMarcianoVotante,
            filaInicial: 0,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearMarcianoVotante,
            filaInicial: 2,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearAlcaldeProvisional,
            filaInicial: 1,
            columnaInicial: 5,
          ),
        ],
        textoApertura:
            'El Alcalde Provisional levanta el martillo de la asamblea: — ¡Mociónese contra el camarada! Dos marcianos votantes alzan papeletas al unísono. Llevan 40 años esperando una papeleta así.',
        textoVictoria:
            'La asamblea se levanta sin quórum. El Alcalde Provisional firma un acta declarándose "vencido por motivos de procedimiento". Te entrega una insignia oxidada.',
        textoDerrota:
            'La asamblea aprueba por unanimidad declarar el incidente "no documentado". Te invitan a votar a favor. Es difícil decir que no.',
        xpRecompensa: 12,
        idObjetoBotin: 'torso_capote_oficial',
      );

    case TipoEncuentro.recepcionGelida9:
      return ConfiguracionEncuentro(
        enemigos: [
          ConfiguracionEnemigoEnGrid(
            factoria: crearJefeDeRecepcionGelida,
            filaInicial: 1,
            columnaInicial: 5,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearBurocrataCongelado,
            filaInicial: 0,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearBurocrataCongelado,
            filaInicial: 2,
            columnaInicial: 4,
          ),
        ],
        textoApertura:
            'El Jefe de Recepción de Gélida-9 alza un sello escarchado: — Sin los 47 formularios F-447, su acceso al planeta queda denegado. Dos burócratas congelados rompen el silencio crujiendo.',
        textoVictoria:
            'El Jefe de Recepción firma un papel "PASE PROVISIONAL DE EMERGENCIA". Una hoja escarchada cae de su carpeta: parece un fragmento de la bitácora de la Pravda-7.',
        textoDerrota:
            'Los burócratas congelados rodean al cadete con cuerdas de papel. Le ofrecen un asiento en la cola desde 1968. Te lo agradeces a ti mismo.',
        xpRecompensa: 11,
        idObjetoBotin: 'ushanka_termica',
      );

    case TipoEncuentro.huelgaSolar:
      return ConfiguracionEncuentro(
        enemigos: [
          ConfiguracionEnemigoEnGrid(
            factoria: crearDelegadoSindicalSolar,
            filaInicial: 1,
            columnaInicial: 5,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearInspectorSindical,
            filaInicial: 0,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearInspectorSindical,
            filaInicial: 2,
            columnaInicial: 4,
          ),
        ],
        textoApertura:
            'El Delegado Sindical Solar abre su maletín dorado: — El Sol Camarada declara huelga general retroactiva contra el camarada. Dos Inspectores Sindicales bloquean la salida de la plataforma orbital.',
        textoVictoria:
            'El Delegado firma una "RESOLUCIÓN DE NEGOCIACIÓN UNILATERAL". El Sol Camarada se calma. Una hoja chamuscada cae del techo: fragmento final de la bitácora de la Pravda-7.',
        textoDerrota:
            'El Delegado te declara "no-trabajador honorario" y te asigna a la cola sindical permanente. Te dan un carné con número de cinco cifras.',
        xpRecompensa: 14,
        idObjetoBotin: 'arma_libreta_decretos',
      );

    case TipoEncuentro.bossPravda7:
      return ConfiguracionEncuentro(
        enemigos: [
          ConfiguracionEnemigoEnGrid(
            factoria: crearEspectroDirectorskov,
            filaInicial: 1,
            columnaInicial: 5,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearSombraDeCosmonauta,
            filaInicial: 0,
            columnaInicial: 4,
          ),
          ConfiguracionEnemigoEnGrid(
            factoria: crearSombraDeCosmonauta,
            filaInicial: 2,
            columnaInicial: 4,
          ),
        ],
        textoApertura:
            'El Espectro de Directorskov flota frente al panel roto: — Camarada, el botón debía pulsarse. Pulsé el correcto. Eran ustedes los que estaban en el sitio incorrecto. Dos sombras de cosmonautas se despegan de las paredes.',
        textoVictoria:
            'El Espectro de Directorskov se disuelve en formularios sin nombre. Las sombras se derrumban como ropa vacía. Un comunicador antiguo sigue susurrando "ya pueden irse".',
        textoDerrota:
            'El botón se aprieta otra vez. Las luces se apagan. La Pravda-7 anota a un cosmonauta más en su tripulación oficial.',
        xpRecompensa: 22,
        idObjetoBotin: 'arma_remache_neumatico',
      );
  }
}
