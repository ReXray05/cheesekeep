# PLAN — Milestones y gates

Fecha: 7 de octubre de 2026. ARCHITECTURE AGENT. Pendiente de PLAN CRITIC; aún no se crean código/escenas.

## Antes de implementación

Visión cerrada con últimas respuestas. Revisar SPEC/ARCHITECTURE/PLAN con PLAN CRITIC independiente y generar PLAN_REVIEW; corregir riesgos antes de inicializar. Motor 4.4.1 y templates web 4.4.1 disponibles según orquestador; comprobar exportación efectiva, no usar templates 4.1.1. Inicializar Git propio, .gitignore de cachés, commit documental. Mantener BALANCE y PROGRESS con propietarios, decisiones, abiertos, bugs y resultados reales.

Tras gate documental, comprobar arranque web mínimo temprano. No confundir arte con núcleo terminado ni compilación con experiencia jugada. Correcciones del usuario sustituyen arquero fijo/gravedad por movimiento y física arcade.

## Arco primero

| Milestone runnable | Alcance | Prueba para avanzar |
| --- | --- | --- |
| M01_aim | Campo cuadrado, cámara, jugador provisional, aim y clic mover | Aim tras cámara/movimiento/escalado |
| M02_charge | Derecho carga/libera, marcha lenta | Release inmediato; UI/foco no atascan carga |
| M03_arrow | Triángulo naranja/verde/rojo, rotura/cooldown, flecha | Dispersión real coincide con base; riesgo por delta |
| M04_enemy | Una básica, HP, segmento/hit/números | Hit rápido y muerte única |
| M05_core_loop | Repetición y reinicio de pantalla de prueba | CORE MECHANIC GATE independiente |

Prototipo SOLO estos sistemas. Sin tienda, oleadas, árbol, boss, música ni partículas complejas. Reserva de munición suficiente/reinicio para repetir. Movimiento es adaptación del núcleo a decisiones del usuario. Cada hito: implementar → ejecutar → jugar → registrar 3–5 problemas → corregir → repetir → commit/tag functional; no guardar doce copias del proyecto.

PLAYTEST AGENT/GAME FEEL AGENT juegan primeros diez segundos, bajo/verde/rojo, movimiento cargando, liberación sobre UI, rotura, impacto y reinicio. TEST AGENT verifica reglas/carga; CODE REVIEWER revisa núcleo. Informes ALTO/MEDIO/BAJO con pasos y evidencia. No avanzar con problemas altos de input, lectura, trayectoria o repetición. Satisfacción requiere juego real: si solo hay smoke tests, gate sigue pendiente, no se declara divertido.

## MVP y expansión

M06_wave: torre, aproximar/subir/bajar, daño extra al queso, objetivos de ratas y oleada básica con pending/alive correctos. Final y siguiente manual.

M07_economy: ammo, monedas, premios, compra y reparación sin pausa. Comprobar compra cargando/atacado, saldo insuficiente y queso lleno. ECONOMY AGENT revisa precios/recompensas tras transacciones correctas.

M08_upgrades: una elección gratuita entre varias, efectos desde datos, reaparición mientras queso vivo, derrota, retención automática por dinero y reinicio/guardado. Política: prefijo de adquisiciones con ratio coins/200 limitado a 1; umbral provisional. Probar cero monedas, 200, fracciones, padres/rangos y corrupción.

Gate MVP independiente: completar tres oleadas, comprar, reparar, subir/bajar, morir/revivir, perder queso y reiniciar. Ensayar cero ammo, doble selección, último enemigo simultáneo a muerte y queso destruido durante respawn. Corregir altos antes de variedad.

M09_enemy_variety: rápida, pesada con amenaza anunciada, escudada y jefe; shared controller/data, decisiones distintas. UPGRADE DESIGNER amplía árbol compacto arco/flecha/movilidad/torre. SCOPE GUARDIAN clasifica nuevas propuestas NOW/LATER/POST-MVP/REJECT. Sin campaña, crafting, multiplayer o veinte tipos.

M10_game_feel: recoil/tensión, squash/flash, estela/números, shake y aberración puntual regulable; arte retro, tutorial y audio tras gesto usuario. UI AGENT comprueba vida/ammo/queso visibles y solo ratón. Los efectos no cambian origen de disparo ni esconden amenazas.

M11_balance: medir ritmo temprano, pérdida tardía, valor de refugio/compra/ahorro y duración inicial objetivo 5–8 min. Datos a BALANCE. Dificultad mediante composición/cantidad/presión acotada. No afirmar duración o variedad conseguida sin sesiones medidas.

M12_release_candidate: CODE REVIEWER/GAME DESIGN REVIEWER/PERFORMANCE REVIEWER independientes. Medir FPS/nodos/carga/reinicio en navegador con máxima oleada/efectos; registrar equipo y condiciones. Corregir lo observado; sin optimización prematura.

## Ownership, integración y entrega

Ajustar roles a concurrencia disponible; revisores pueden ejecutarse secuencialmente. Orquestador posee Main, player/world, enlaces, HUD/economía/upgrades/audio. Bow/Arrow Agent posee weapons/projectiles; Enemy Agent enemies y después WaveManager. Test Agent tests; documentos un editor a la vez. Contratos de ARCHITECTURE antes de paralelo. Usar ramas/worktrees para implementación paralela según requisito original; integrar solo tras diff, ejecución y prueba propia.

Final gate independiente produce informe de gameplay/enemigos/economía/UI/código/performance/build; corregir altos y repetir checks afectados. Build web real desde HTTP: input derecho sin menú, redimensionado sin deformación, audio, persistencia y segunda partida. No declarar release únicamente desde editor.

Paquete: proyecto Godot/source/assets, build web, README arranque/export/controles/enemigos/mejoras/limitaciones, GAME_VISION, SPEC, ARCHITECTURE, PLAN, PLAN_REVIEW, BALANCE, PROGRESS e informes. Web es primera entrega; export nativo Windows adicional puede esperar. Mantener commits funcionales M01–M12 y registrar trabajo no probado explícitamente.

## Riesgos a revisar

SubViewport/cámara/input y shake; captura derecha global/foco; compra sin movimiento ni pausa; muerte/rotura/gameover limpia charge; retención conserva prerrequisitos; límite de ratas/flechas/efectos en supervivencia infinita; núcleo gate antes de contenido; satisfacción subjetiva no se infiere de tests; templates usados deben coincidir con motor 4.4.1.
