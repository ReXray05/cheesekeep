# TEST V2 — integración, recuperación y stress

7 de octubre de 2026. Fuente Godot4.4.1 en feature/gameplay-polish-v2. Resultados técnicos del agente TEST/PLAYTEST y reejecuciones del orquestador; revisión independiente en CODE_REVIEW_V2. Las suites se ejecutan headless. Este documento no certifica FPS de navegador ni diversión humana.

| Suite | Comprobaciones | Resultado |
| --- | ---: | --- |
| v2_bow_arrow.gd | 166 | 0 fallos |
| v2_player_input.gd | 64 | 0 fallos |
| v2_upgrades_ui.gd | 198 | 0 fallos |
| v2_integration.gd | 78 | 0 fallos |
| v2_playtest.gd | 24 | 0 fallos |
| Total de las cinco suites | **530** | **0 fallos** |
| v2_enemy_economy.gd | Suite de aserciones | PASS |
| Casos adicionales de geometría | 50 | PASS |

Los 50 casos geométricos y la suite Enemy/Economy se informan por separado, sin inflar el total530. Los tests V1 permanecen disponibles; sus cifras históricas no se suman a V2. Comando reproducible desde fuente: `godot --headless --path . --script tests/v2_integration.gd`; repetir con cada suite. En un entorno restringido, proporcionar `--log-file` absoluto en una carpeta escribible evita el fallo de permisos al crear user://logs.

## Cobertura significativa

Carga determinista, ventanas verde/morado y migración de mejoras V1; daño protegido positivo de melee y espectral sin crítico; penetración/hit IDs y finish idempotente; vuelo fuera del viewport dentro de arena; una recuperación de flecha por fallo, sin premio tras impacto o cleanup. Melee funciona con ammo=coins0 y arco roto; muerte única produce monedas y flechas físicas recogibles. Caps fusionan cantidades sin pérdidas y montado no recoge.

Input configurable, UI consumidora, liberación global, pausa/foco repetido sin reanudación accidental, recaptura explícita sin resetear carga, congelación de dash/respawn/oleadas y prioridad OVER. Aim usa ancla estable; geometría bloquea torre/borde en marcha, embestida, dash y empuje, con contacto360° y rodeo. Ajustes/progreso validan corrupción y versiones; guardar preferencias no convierte adquisiciones activas en retención. Menu/reinicio no duplica recursos o root.

## Cinco oleadas y recuperación

Bot sin godmode completa cinco oleadas incluido jefe: **52 bajas**, queso final **295**, **cinco excursiones de recogida en suelo** y **tres compras de munición**. Frames simulados por oleada:369/513/881/878/1438. El harness prueba muerte/reaparición sin conceder saldo o munición. Las oleadas requieren inicio manual y una elección por final; recursos no recogidos permanecen entre oleadas.

Es un ensayo automatizado que ejerce acciones reales de Game y economía. No sustituye una partida humana ni prueba por sí solo que el incentivo a salir de torre resulte divertido. Daños/precios/ventanas son balance inicial.

## Stress y limpieza

Fixture: **80 ratas,50 flechas,96 packs**; **325 nodos**. **120 ticks manuales en298565µs**, aproximadamente **2,49ms/tick de CPU headless**. No incluye render web, interacción humana ni tiempo completo de frame; no convertirlo en afirmación de60FPS de navegador. Partículas acotadas a80, rings8, afterimages6 y vocesSFX8. Pickups dibujados en lote, cantidades agrupadas sin nodos por unidad.

Derrota limpia actores/proyectiles/recursos; la medición de disposal completo vuelve de1 nodo a1 sin fuga de raíz. Efectos temporales pueden permanecer durante su vida acotada antes de desaparecer. El grafo de navegación y barrido flecha×enemigos son costes acotados revisados, pendientes de medición web a carga equivalente.

## Gate pendiente

Implementación, suites técnicas y revisión independiente permiten construir RC. Quedan por documentar navegador real/segunda partida, combinaciones de controles y UI, cursor/cámara/oclusiones, audio, persistencia local tras recarga, export reproducible y rendimiento sostenido. Valoración humana de feel/diversión abierta. Solo el orquestador cierra esos gates y publicación con evidencia final; tests headless aprobados no publican V2.
