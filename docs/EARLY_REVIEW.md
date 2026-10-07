# EARLY REVIEW — código y rendimiento MVP

Fecha: 7 de octubre de 2026. Revisor independiente CODE + PERFORMANCE REVIEWER. Solo lectura; no se modificó implementación. Fuente en transición: GameController MVP ya integrado, HUD/economía aún a cargo de agentes. No revisión final.

**Resultado: PASS WITH FIXES; corregir ALTO antes de jugar MVP.**

## Hallazgos

1. **ALTO — Flechas siguen resolviendo daño y recompensas tras derrota.** En `scripts/game/game.gd`, `_process` ejecuta `arrow.tick` y `_segment` sin comprobar fase; el callback `enemy.died` sigue sumando score y monedas. `_game_over` guarda conservación y resultado una vez, pero una flecha en vuelo puede matar al fotograma siguiente y cambiar cifras después del guardado. Corregir congelando/eliminando proyectiles al perder y protegiendo resolución/recompensas con fase OVER. Prueba: flecha próxima a rata y queso destruido antes de impacto; saldo/bajas/retención permanecen en valores del final.

2. **MEDIO — Suelo estático recalculado y enviado cada frame.** `world_visuals.gd` llama `queue_redraw` siempre; `_draw` construye 961 polígonos `PackedVector2Array` y colores por frame, más borde y torre. La cámara ya transforma comandos de dibujo retenidos: moverla no exige reconstruir suelo. Separar suelo estático en CanvasItem que dibuja una vez, de destino animado/torre (redibujan cuando cambia reloj visible o vida). A 60 FPS se evitan aproximadamente 57.660 construcciones de polígonos por segundo. Esta cifra describe trabajo evitado, no FPS medidos. El retraso de la sesión web es una señal para medir, no prueba causal de este componente.

3. **MEDIO — Telemetría de pruebas hace puente JS por frame.** `game.gd` genera dos snapshots de status, copia/merge de diccionarios, JSON y `JavaScriptBridge.eval` cada frame en prototype/qa. Mantener telemetría diagnóstica, pero limitar frecuencia a 10–20 Hz; registrar crítico/rotura/liberación como evento si la ventana verde de 130 ms exige precisión adicional. Nunca necesitar este puente en juego normal. Los controles siguen funcionando a través del input del canvas; evitar que la instrumentación ralentice lo que mide.

## Revisión adicional sin hallazgo bloqueante

InputController centraliza ratón: campo rectangular, escalado a SubViewport y transformación inversa de cámara; liberación derecha global atraviesa UI y reset evita disparo tras muerte/rotura. La cámara y posición del cursor se actualizan por frame: pruebas posteriores deben incluir redimensionado y giro rápido, sin afirmar latencia medida desde screenshots. Player.hurt rechaza daño muerto/montado/invulnerable; muerte resetea arco y respawn. Enemy.take_hit usa dead como guard para emitir muerte una vez; Arrow.hit_ids impide repetir impacto sobre misma rata. Arrows/enemies se filtran y liberan: estructura suficiente para MVP con límites, sin necesidad de pooling ni arquitectura nueva.

No añadir variedad ni efectos nuevos para resolver estos tres hallazgos. Medir una sesión normal y otra QA, con mismo número de ratas/flechas, después de corregir suelo/telemetría. No se aporta una cifra de FPS porque no se midió rendimiento en esta revisión de fuente.
