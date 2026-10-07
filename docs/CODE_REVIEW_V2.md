# CODE REVIEW / PERFORMANCE REVIEW V2

7 de octubre de 2026. Revisión independiente de arquitectura, código y límites de recursos. Baseline comparada: `eef11eb`; fuente V2 integrada sobre `8f2a61a` con cambios locales del orquestador, no una RC inmutable. Solo documentación: el reviewer no ha editado gameplay, UI, datos ni tests de integración.

## Hallazgos y resolución

**ALTO, corregido durante revisión — perder foco estando pausado reanudaba la partida.** `game.gd::_notification` llamaba al toggle `request_pause`; PAUSED con pantalla pause ejecutaba resume_game al salir a otra ventana. El orquestador añadió guard de fase PREP/WAVE/CHOICE antes de invocar pausa por foco. Revisada la fuente corregida. Tests de integración incorporan regresión por el agente de pruebas; su ejecución final pertenece a TEST_V2. No cerrar este guard con un toggle nuevo.

**MEDIO, corregido durante revisión — clic torre desde lejos no aproximaba en WASD.** Player tenía destino/wants_tower válidos pero el retorno por vector WASD cero y desplazamiento directo ignoraban ese destino. La fuente corregida permite aproximación cuando wants_tower y conserva WASD para movimiento normal. E sigue siendo interacción cercana. Confirmación visual de las cuatro configuraciones corresponde al navegador.

Se examinó posible hit espectral fuera del área debido a su semiancho; no se confirma bug alcanzable con oleadas actuales: los spawns normales están entre radios240–300 dentro de arena320 y Enemy proyecta movimiento/summons. No se registra como blocker ni como fallo demostrado. Una cápsula barrida incorpora el radio de enemigo y semiancho; la lectura de sus extremos debe verificarse visualmente, especialmente cerca del borde.

## Contratos revisados

- MENU inicial suspende SceneTree y Router; Game procesa navegación pero retorna antes de simular. PAUSED guarda resume_phase; release suspendido no dispara al cerrar overlay y recaptura explícita conserva carga. Router recibe release global en `_input` y nuevos comandos en `_unhandled_input`, de modo que los Controls pueden consumir pulsaciones nuevas. Focus-out ahora es idempotente por guard.
- World PAUSABLE contiene actores, visuales y AudioStreamPlayers. Labels de daño usan world.create_tween; dummy usa timer con process_always=false. El gate central congela Bow/respawn/waves y el árbol sigue navegable. Verificación de audio real y canvas requiere navegador; leer source no prueba audibilidad.
- Aim procede de aim_anchor independiente de direction, con epsilon3; el cursor usa canvas inverso efectivo y conserva último punto fuera del campo. Cámara suaviza posición y shake va en offset. No queda realimentación de bow_origin al aim. Probar centro/montaje/cursor durante movimiento en navegador.
- Bow elimina rotura RNG; verde crítico y morado no crítico. Shot una vez, ammo descontada solo en Game. Arrow.finish es idempotente, emite antes de queue_free; impacts cuentan incluso protegidos y miss pickup solo aparece con hit_count0 y final válido. No culling del viewport. Spectral usa hit_ids y presupuesto ilimitado, nunca daño repetido por frame.
- Enemy.dead protege daño/ataques/summons y asigna death_source antes de died. died es única ruta de score/pickups; result.killed solo feedback. Melee protegido sigue quitando HP, empuje comparte geometría y baja melee produce monedas/flechas físicas. Premio de wave permanece automático. Ningún premio doble encontrado en el flujo integrado.
- Pickups se eliminan antes de collected, permanecen entre oleadas y mientras el jugador muere, y montado no recoge. Cap agrupa cantidades del mismo tipo; no descarta riqueza ni convierte packs a saldo automáticamente. Manager dibuja en lote, sin nodos por recurso.
- Persistence valida tipos, versiones1/2, floats finitos y clamps; versiones futuras/corrupción usan defaults. IDs V1 permanecen; fast_draw escala ventanas y steady_string tiene efecto determinista. Guardar ajustes conserva historia retenida; derrota guarda settings explícitos. Retención usa saldo recogido, sin incorporar suelo pendiente.

## Ejecución independiente

Godot **4.4.1 stable official**, headless, proyecto integrado:

- `tests/v2_bow_arrow.gd`: **166 assertions, 0 failures**, exit0.
- `tests/v2_enemy_economy.gd`: **PASS**, exit0; incluye recuperación melee protegida sin recursos, muerte única, suma exacta sobre cap, bloqueo de aspiración desde torre, no expiry, miss accesible, contacto360°, rodeo opuesto, embestida/knockback barridos.

Las ejecuciones limpias usan `--log-file` absoluto en `work/`. Un intento previo sin esa opción no pudo crear user://logs en sandbox y Godot falló; no era fallo del juego. Repetidas con log absoluto, ambas salidas son limpias. Estos tests no escriben ni alteran source. TEST_V2 registrará integración/foco/cinco oleadas con el agente de pruebas.

## Rendimiento y límites

Fuente revisada: pickups cap96 registros agrupados; partículas80; rings8; afterimages6; voces SFX8; enemies80; arrows50; labels flotantes80. No efectos o timers por moneda/flecha; queue_free y filtros limpian flechas/enemigos finalizados. Upgrade tree se construye al abrir, no por frame. Reinicio recarga escena completa y conexiones anteriores mueren con ella. Los pickups ilimitados en cantidad mantienen un número acotado de registros.

Principal coste CPU potencial: para ratas persiguiendo al jugador al otro lado del queso, Enemy reconstruye grafo de visibilidad de seis vértices por tick. Además `_segment` recorre enemies por cada arrow (máximo50×80 pruebas por frame) y ordena solo candidatos encontrados. Son costes acotados, no evidencia de 60FPS. Una cache de rutas o índice espacial no se exige sin medición que la justifique. HUD recompone textos por frame; telemetry/JavaScriptBridge puede añadir coste en qa y cargas del prototipo, pero no se activa en run normal sin qa.

El reviewer no ha medido FPS de navegador ni declara rendimiento sostenido aprobado. El stress/bot de integración del agente de pruebas y la observación web del orquestador deben adjuntar condiciones, carga y cifras; FPS headless no representan el renderer web. Tampoco tests técnicos certifican diversión o comodidad de controles.

Evidencia recibida del agente TEST/PLAYTEST V2 al cerrar esta revisión: integración **74 checks/0 fallos** y bot/stress **24 checks/0 fallos**. Bot supera cinco oleadas con jefe,52 bajas, queso295, cinco excursiones de recogida y tres compras; prueba muerte/reaparición sin recursos. Stress:80 ratas/50 flechas/96 registros, nodos65→325,120 ticks manuales en287243µs (≈2,39ms/tick de CPU headless, no tiempo completo de frame web), partículas≤80. Derrota deja72 nodos con siete transitorios; disposal completo vuelve1→1. Estos resultados son ejecución del agente de pruebas, no medición independiente del navegador por este reviewer; consultar su TEST_V2 para harness/condiciones.

## Veredicto

**GO técnico de código para completar integración y construir RC de prueba:** los hallazgos altos encontrados se corrigieron en fuente, contratos principales y tests independientes indicados pasan. **Release aún requiere** evidencia final de integración/foco, stress acotado y navegador real (layout, controles, cámara, audio, guardado y segunda partida), además revisión del diff de la RC exacta. No es LGTM abstracto ni aprobación de performance/diversión.
