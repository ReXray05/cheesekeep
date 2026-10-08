# Cheesekeep — La última corteza

**[JUGAR EN EL NAVEGADOR](https://rexray05.github.io/cheesekeep/)** · [Repositorio](https://github.com/ReXray05/cheesekeep)

En este repositorio, el lanzador `JUGAR.cmd` y la build `web/` están en la raíz. GitHub Pages publica desde `main` y el archivo de entrada abre la build sin instalación. Las instrucciones con `../` de abajo se refieren al paquete original de entrega. Para reexportar un clon independiente, instala las plantillas oficiales Godot 4.4.1 y vacía las rutas de plantillas personalizadas en el preset Web; elige `web/index.html` como destino.

Juego 2D de supervivencia: protege una torre de queso frente a ratas, carga el arco buscando el instante verde o la ventana morada para atravesar grupos. Movimiento con ratón o WASD, disparo configurable y combate cuerpo a cuerpo. Fuente Godot 4.4.1 y GDScript; entrega para navegador.

La fuente V2 está en la rama `feature/gameplay-polish-v2`; la publicación enlazada conserva V1 hasta completar la verificación web y publicar V2. El checkpoint `M13_baseline_v1` conserva V1. La build candidata se exporta desde esta fuente a `../web/`; no se declara publicada por tener tests aprobados.

## Jugar en Windows

Abre `../JUGAR.cmd` con doble clic. Inicia un servidor local en `http://127.0.0.1:8877/index.html` y abre el navegador. No requiere instalar Godot, Python ni Node. Mantén juntas las carpetas y archivos de la entrega. El servidor solo escucha en este equipo y termina después de 30 minutos sin peticiones.

No abras `web/index.html` como archivo local: la exportación necesita HTTP. Si el navegador no se abre, visita la dirección anterior. Si no carga, comprueba que el puerto 8877 esté libre y vuelve a ejecutar el lanzador. Para un servidor manual, desde la carpeta de entrega: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Servidor-local.ps1 -Port 8877`.

## Controles y objetivo

| Acción | Control |
| --- | --- |
| Apuntar | Mover el ratón dentro del campo |
| Caminar | Clic a destino o WASD, seleccionable en Ajustes |
| Subir al queso | Botón contrario al disparo sobre torre; se aproxima y sube. E también interactúa cerca en WASD |
| Bajar | Botón de movimiento sobre suelo, E cerca o Espacio para bajar con dash |
| Cargar arco | Mantener derecho o izquierdo, seleccionable en Ajustes |
| Disparar | Soltar el botón de disparo elegido |
| Golpe cuerpo a cuerpo | Botón central; barrido hacia cursor, sin munición |
| Dash | Espacio; dirección de movimiento o cursor si estás quieto |
| Pausa | Esc o botón II |
| Comprar, reparar, elegir mejora o iniciar oleada | Clic izquierdo en la interfaz |
| Controles, música/SFX separados, efectos y ayuda | Ajustes del menú principal o de pausa; preferencias persistentes |

Puedes caminar mientras cargas, inicialmente al 65 % de velocidad. La secuencia es naranja → verde → rojo → morado → rojo breve → rotura garantizada. Verde: crítico que rompe protección. Morado: segundo instante especial, flecha espectral de franja constante que atraviesa grupos, respeta protección y consume una flecha. No hay rotura aleatoria antes del límite; la cuerda se recupera sola con aviso READY. No hay cancelación manual de carga. Dash conserva carga y tiene invulnerabilidad breve inicial; la torre y el borde bloquean su recorrido. Melee empuja múltiples ratas, funciona sin flechas y con arco roto, pero no mientras cargas.

Desde el queso eres inmune, pero la torre recibe inicialmente un 50 % más de daño y no recoges recursos. La pausa congela carga, proyectiles, dash y reaparición. Si sueltas el disparo durante pausa, al continuar pulsa y suelta de nuevo para resolver esa carga; no se dispara automáticamente ni empieza desde cero. Perder foco pausa la partida.

Empieza la primera oleada con el botón lateral. Comprar flechas y reparar no pausa el combate. Al completar una oleada eliges una mejora gratuita, compras o reparas y comienzas la siguiente cuando quieras. Si el arquero muere revive en 2,5 s mientras quede queso. Si el queso se destruye, termina la partida y aparece el botón para volver a jugar. Supervivencia infinita, sin pantalla de victoria.

## Progresión y guardado

La tienda inicial vende 10 flechas por 6 monedas y recupera hasta 30 puntos de queso por 12 monedas. Las bajas dejan monedas físicas: recógelas en suelo; el premio de oleada sigue siendo automático. Bajas melee dejan además flechas garantizadas y disparos que no tocaron ningún enemigo dejan una flecha recuperable al terminar. Cargas bajas se clavan al final del indicador; verdes y superiores continúan por el área jugable. Los recursos permanecen entre oleadas hasta recogerlos. Puedes recuperarte con cero flechas y cero monedas mediante melee y recogida.

Veinte mejoras distintas, con cuarenta rangos adquiribles en total, se organizan en arco, flechas, movilidad/melee, recogida y torre. Se ofrecen según requisitos y rangos disponibles; las ramas son combinables. Una elección gratuita por oleada. Consulta sus efectos en `data/upgrades.json` y `docs/BALANCE.md`; el árbol muestra enlaces entre requisitos y puede consultarse entre oleadas.

Al perder se conservan automáticamente `floor(adquisiciones × clamp(monedas / 200, 0, 1))` mejoras. Se conserva el prefijo histórico, contando cada rango y respetando requisitos. Cero monedas conserva cero; 200 o más conserva todo. Solo cuentan monedas recogidas y premios automáticos, no las del suelo. El dinero se reinicia y cada partida empieza con 10 monedas y 40 flechas. El guardado local usa `user://cheesekeep.json`; en web pertenece al almacenamiento del navegador y a la dirección de origen. Cambiar navegador, puerto o borrar almacenamiento puede dejar el progreso anterior inaccesible. V2 conserva IDs de mejoras V1 y migra sus guardados; guarda preferencias por separado del progreso retenido. Retención ocurre al finalizar la partida; cerrar o abandonar al menú antes no guarda las nuevas adquisiciones.

## Abrir y modificar la fuente

Importa `project.godot` en Godot 4.4.1 y ejecuta la escena principal con F6 o el proyecto con F5. La principal es `scenes/game/game.tscn`; `scenes/game/prototype.tscn`, si está incluida, contiene la prueba aislada del arco. La build web final se encuentra en `../web/`.

En Windows puedes abrir la fuente con **`EDITAR-EN-GODOT.cmd`**, incluido junto a `project.godot` y también en la carpeta de entrega. El lanzador `Abrir-Godot.ps1` usa Godot4.4.1 portable de Descargas; no requiere instalar otro editor. Abre `game.tscn` para ver la escena y pulsa **F5** para jugar el proyecto. Ajusta cifras en los JSON de `data/`; el juego publicado necesita reexportarse después de modificar la fuente. El orquestador confirmó el editor abierto con el proyecto Cheesekeep.

La raíz en `scripts/game/game.gd` coordina el estado y la integración. Controladores y presentación se separan para arquero, arco, flechas y ratas. Las oleadas, economía, mejoras, persistencia y HUD tienen módulos propios. El campo usa un SubViewport de 360 × 360 ampliado a 720 × 720, con paneles laterales en una ventana lógica de 1152 × 720. El tick de gameplay es coordinado por la raíz.

Edita `data/balance.json` para arco, arquero, torre, economía y límites; `data/enemies.json` para las cinco ratas; `data/waves.json` para ritmo y aparición; `data/upgrades.json` para ramas y efectos. Los recursos gráficos y su procedencia se documentan junto a los assets y en los informes del proyecto.

## Exportar

La entrega incluye plantillas web sin hilos de Godot 4.4.1 en `../export_templates/`. Mantén esa ubicación: `export_presets.cfg` las referencia. Desde Godot abre Proyecto → Exportar → Web y exporta a `../web/index.html`. Desde una terminal, con el ejecutable Godot accesible: `godot --headless --path . --export-release Web ../web/index.html`. Sirve siempre el resultado por HTTP. Una exportación nativa Windows no forma parte de esta build web.

## Pruebas y límites

Los diagnósticos se ejecutan con Godot, por ejemplo `godot --headless --path . --script tests/v2_integration.gd`. V2 registra 530 comprobaciones sin fallos, suite Enemy/Economy aprobada y 50 casos de geometría; véase `docs/TEST_V2.md` y `docs/CODE_REVIEW_V2.md`. Las pruebas incluyen recuperación sin recursos, pausa/foco, cinco oleadas con jefe, migración y límites de objetos. Los informes V1 `docs/CORE_GATE.md`, `docs/MVP_PLAYTEST.md`, `docs/TEST_CORE.md`, `docs/TEST_SYSTEMS.md` y `docs/TEST_INTEGRATION.md` se conservan como historia. Los tests no prueban por sí solos diversión, calidad de audio ni rendimiento web sostenido.

Ajuste del8 de octubre: huella sólida limitada al suelo, rodeo completo del queso con clic y deslizamiento al caminar con WASD; la zona visual de clic torre conserva tamaño. Espectral base **56 de daño**, el doble del valor V2 inicial28, con protección enemiga intacta. Regresión específica **119 comprobaciones sin fallos**, además de la reejecución de las suites V2; F5 permite probar el ajuste directamente en Godot.

Esta entrega mantiene un alcance compacto: cinco tipos de ratas (básica, rápida, escudada, pesada y jefe), veinte mejoras y una arena. No incluye campaña, multijugador, inventario ni ejecutable nativo. El balance de largas sesiones y las invocaciones de jefes requieren seguimiento adicional. Los límites de objetos y mediciones CPU headless no equivalen a una garantía de FPS web. El gate de navegador, rendimiento sostenido y valoración humana de V2 permanece pendiente hasta documentar su ejecución.

La documentación de diseño y mantenimiento está en `docs/`: GAME_VISION, SPEC, ARCHITECTURE, PLAN, PLAN_REVIEW, PROGRESS y BALANCE.

## Cambios de versión

- V2: aim estable, vuelo independiente del indicador para verde+, huella sólida compartida, cámara suave; melee/dash, recursos físicos y recuperación sin munición; carga morada y rotura determinista; controles configurables, preferencias persistentes, menú/pausa/ayuda/splash y árbol con veinte mejoras. Implementación y tests técnicos completos; gates web y experiencia humana pendientes.
- V2, ajuste8oct: se reduce colisión al pie del queso, se sustituye rodeo greedy por grafo de navegación y se permite deslizamiento de marcha; dash conserva bloqueo sólido. Espectral28→56. Editor portable y lanzador de fuente incluidos.
- V1 / M13: versión publicada preservada, combate de ratón, doce mejoras, monedas por baja automáticas, carga roja con riesgo aleatorio y vuelo limitado por indicador. Sus informes originales siguen en `docs/`.
