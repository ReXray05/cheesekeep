# Cheesekeep — La última corteza

Juego 2D de supervivencia con ratón: protege una torre de queso frente a ratas, carga el arco buscando el instante verde o arriesga sobrecarga para atravesar grupos. Fuente Godot 4.4.1 y GDScript; primera entrega para navegador.

## Jugar en Windows

Abre `../JUGAR.cmd` con doble clic. Inicia un servidor local en `http://127.0.0.1:8877/index.html` y abre el navegador. No requiere instalar Godot, Python ni Node. Mantén juntas las carpetas y archivos de la entrega. El servidor solo escucha en este equipo y termina después de 30 minutos sin peticiones.

No abras `web/index.html` como archivo local: la exportación necesita HTTP. Si el navegador no se abre, visita la dirección anterior. Si no carga, comprueba que el puerto 8877 esté libre y vuelve a ejecutar el lanzador. Para un servidor manual, desde la carpeta de entrega: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Servidor-local.ps1 -Port 8877`.

## Controles y objetivo

| Acción | Control |
| --- | --- |
| Apuntar | Mover el ratón dentro del campo |
| Caminar | Clic izquierdo sobre el suelo |
| Subir al queso | Clic izquierdo sobre la torre; el arquero se aproxima y sube |
| Bajar | Clic izquierdo sobre el suelo |
| Cargar arco | Mantener botón derecho |
| Disparar | Soltar botón derecho |
| Comprar, reparar, elegir mejora o iniciar oleada | Clic izquierdo en la interfaz |
| Reducir efectos, silenciar o consultar ayuda | Botones laterales |

Puedes caminar mientras cargas, inicialmente al 65 % de velocidad. Verde: crítico y rotura de protección enemiga. Rojo: mayor potencia y penetración, más dispersión y riesgo de romper cuerda. La cuerda se recupera sola; no hay cancelación manual de carga. Desde el queso eres inmune, pero la torre recibe inicialmente un 50 % más de daño.

Empieza la primera oleada con el botón lateral. Comprar flechas y reparar no pausa el combate. Al completar una oleada eliges una mejora gratuita, compras o reparas y comienzas la siguiente cuando quieras. Si el arquero muere revive en 2,5 s mientras quede queso. Si el queso se destruye, termina la partida y aparece el botón para volver a jugar. Supervivencia infinita, sin pantalla de victoria.

## Progresión y guardado

La tienda inicial vende 10 flechas por 6 monedas y recupera hasta 30 puntos de queso por 12 monedas. Bajas y oleadas dan monedas. Doce mejoras, organizadas en arco, flechas, movilidad y torre, se ofrecen según requisitos y rangos disponibles. Consulta todos sus efectos en `docs/BALANCE.md`; el árbol puede consultarse entre oleadas.

Al perder se conservan automáticamente `floor(adquisiciones × clamp(monedas / 200, 0, 1))` mejoras. Se conserva el prefijo histórico, contando cada rango y respetando requisitos. Cero monedas conserva cero; 200 o más conserva todo. El dinero se reinicia y cada partida empieza con 10 monedas y 40 flechas. El guardado local usa `user://cheesekeep.json`; en web pertenece al almacenamiento del navegador y a la dirección de origen. Cambiar navegador, puerto o borrar almacenamiento puede dejar el progreso anterior inaccesible. El guardado de retención ocurre al finalizar la partida; cerrar antes no guarda las nuevas adquisiciones.

## Abrir y modificar la fuente

Importa `project.godot` en Godot 4.4.1 y ejecuta la escena principal con F6 o el proyecto con F5. La principal es `scenes/game/game.tscn`; `scenes/game/prototype.tscn`, si está incluida, contiene la prueba aislada del arco. La build web final se encuentra en `../web/`.

La raíz en `scripts/game/game.gd` coordina el estado y la integración. Controladores y presentación se separan para arquero, arco, flechas y ratas. Las oleadas, economía, mejoras, persistencia y HUD tienen módulos propios. El campo usa un SubViewport de 360 × 360 ampliado a 720 × 720, con paneles laterales en una ventana lógica de 1152 × 720. El tick de gameplay es coordinado por la raíz.

Edita `data/balance.json` para arco, arquero, torre, economía y límites; `data/enemies.json` para las cinco ratas; `data/waves.json` para ritmo y aparición; `data/upgrades.json` para ramas y efectos. Los recursos gráficos y su procedencia se documentan junto a los assets y en los informes del proyecto.

## Exportar

La entrega incluye plantillas web sin hilos de Godot 4.4.1 en `../export_templates/`. Mantén esa ubicación: `export_presets.cfg` las referencia. Desde Godot abre Proyecto → Exportar → Web y exporta a `../web/index.html`. Desde una terminal, con el ejecutable Godot accesible: `godot --headless --path . --export-release Web ../web/index.html`. Sirve siempre el resultado por HTTP. Una exportación nativa Windows no forma parte de esta build web.

## Pruebas y límites

Los diagnósticos se ejecutan con Godot, por ejemplo `godot --headless --path . --script tests/enemy_variants_tests.gd`. Los informes `docs/CORE_GATE.md`, `docs/MVP_PLAYTEST.md`, `docs/TEST_CORE.md`, `docs/TEST_SYSTEMS.md`, `docs/TEST_INTEGRATION.md` y las revisiones independientes registran el alcance real de las comprobaciones. Consulte esos informes para evidencia, defectos y limitaciones; los tests no prueban por sí solos diversión, calidad de audio ni rendimiento sostenido.

Esta entrega mantiene un alcance compacto: cinco tipos de ratas (básica, rápida, escudada, pesada y jefe), doce mejoras y una arena. No incluye campaña, multijugador, inventario ni ejecutable nativo. El balance de largas sesiones y las invocaciones de jefes requieren seguimiento adicional. Los límites de objetos no equivalen a una garantía de FPS.

La documentación de diseño y mantenimiento está en `docs/`: GAME_VISION, SPEC, ARCHITECTURE, PLAN, PLAN_REVIEW, PROGRESS y BALANCE.
