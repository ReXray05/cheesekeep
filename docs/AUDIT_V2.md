# Auditoría previa a evolución V2

7 de octubre de 2026. Orquestador. Baseline eef11eb, tag M13_baseline_v1; rama feature/gameplay-polish-v2. Estado Git limpio antes de crear checkpoint. No se ha modificado gameplay, escenas, assets o build. Main publicada sigue intacta.

## Estado real y documentación

Leídos GAME_VISION, SPEC, ARCHITECTURE, PLAN, PLAN_REVIEW, BALANCE, PROGRESS y README. Revisadas escenas, controladores, datos y presentación. Godot 4.4.1, Compatibility, export web sin hilos. Varias cabeceras de visión/especificación/plan aún describen fase previa a implementación; son históricas, no descripción fiable del estado actual. ARCHITECTURE propone MENU pero no existe ese estado en código. PROGRESS todavía cita 1 FPS sin incorporar la posterior medición de primer plano de FINAL_REVIEW.

La escena game instancia componentes desde game.gd; las escenas de arco/rata/flecha también existen, pero la raíz principal crea nodos de sus scripts directamente. No hay CharacterBody, NavigationAgent ni colisionadores físicos: navegación y contactos son cálculos de geometría manuales.

| Sistema | Implementación actual |
| --- | --- |
| Estado e integración | game/game.gd: PREP, WAVE, CHOICE, OVER; no MENU ni PAUSED |
| Movimiento y refugio | player/player_controller.gd: clic a destino, aproximación y montaje, evasión circular del queso, marcha lenta cargando |
| Input | input/input_controller.gd: centralizado, botones físicos izquierdo/derecho fijos; sin acciones configurables ni teclado |
| Apuntado y cámara | game.gd, origen player.bow_origin; cámara asignada directamente a posición del jugador cada frame |
| Carga y rotura | weapons/bow_controller.gd: ventana verde, rojo, riesgo por delta, cooldown 1,5 s |
| Indicador | weapons/aim_indicator.gd: presentación separada, dispersión de base compartida con release |
| Proyectiles | projectiles/arrow_physics.gd: segmento barrido, presupuesto de impactos, rango físico, vida 4 s; raíz elimina fuera del viewport |
| Enemigos | enemies/enemy_controller.gd: objetivo directo, frontera circular, embestida manual sin obstáculo; cinco tipos |
| Oleadas | waves/wave_manager.gd: spawn acotado, jefe cada cinco, final sin pendientes/vivos, siguiente manual |
| Economía | economy/economy_manager.gd: saldo y munición transaccionales; raíz concede monedas inmediatamente al morir rata |
| Mejoras | upgrades/upgrade_manager.gd + data/upgrades.json: requisitos reales y rangos, 12 mejoras principalmente numéricas |
| HUD y árbol | ui/hud.gd: paneles, compra/reparación, ofertas; árbol visual en cuadrícula de dos columnas, sin ramas trazadas |
| Audio y juice | effects/feedback_controller.gd: música, ocho voces, partículas/anillos acotados, críticos al impactar, rotura; sin señal READY |
| Guardado/ajustes | systems/persistence.gd guarda historia y campo settings, pero no carga ajustes ni los aplica; toggles se reinician |

No existen dash, melee, AOE, pickups, pausa, menú principal ni splash personalizado. Ayuda es texto desplegable. SONIDO activa/desactiva música y efectos juntos.

## Diagnóstico prioritario

1. **ALTO: bloqueo de combate por munición.** La raíz rechaza carga con ammo=0. Sin saldo para compra (precio6) no hay ataque alternativo, recuperación ni premio de oleada si quedan enemigos. Estado alcanzable tras malgastar munición y compras; confirmado por lógica, no reproducido agotando 50 clics en esta sesión. Reaparecer no concede flechas. La derrota puede llegar, pero el jugador no puede recuperar su combate.
2. **ALTO: apuntado autorreferente.** El vector apunta desde bow_origin, que incluye direction*9. Ese direction procede del aim anterior. Cerca del centro, el origen cambia de lado y el siguiente vector puede invertirse. Epsilon de un solo punto no rompe ese ciclo; causa lógica identificada. Reproducción visual exhaustiva a 1–2 píxeles pendiente, no se afirma certificada.
3. **MEDIO: rango real acoplado a longitud visual.** Bow.release emite range=endpoint.length y ArrowPhysics elimina al consumirlo para cualquier carga. Esto explica desaparición al final del indicador; no es un fallo de dibujo. Regla original sí exigía rango. La nueva regla verde+ sustituirá ese contrato y sus tests.
4. **MEDIO: torre y oclusión.** Las básicas se detienen a radio+29, de modo que no se asume penetración del queso en marcha normal. El sprite elevado tapa parcialmente ratas que llegan desde atrás, observado en navegador. Embestidas integran posición sin colisión contra torre y pueden atravesar su huella. La solución deberá combinar geometría de ocupación/contacto/navegación y legibilidad, no cambiar z-index aislado.
5. **MEDIO: salto de cámara.** Montaje fuerza posición a(0,0) desde radio<34; desmontaje fuerza(0,38). Cámara copia la posición sin smoothing, tween o blending; comprobado subiendo/bajando en preparación.
6. **MEDIO: pocos incentivos para salir.** Se puede permanecer montado indefinidamente, inmune, con daño queso×1,5. Monedas y premios automáticos, tienda remota, sin recursos físicos ni ventaja de melee/dash/AOE. No se declara que quedarse gane siempre; quedarse sin disparar sí pierde el queso.
7. **BAJO/MEDIO: READY/perfect.** Rotura tiene aviso, sonido y burst. Recuperación únicamente vuelve a IDLE/HUD LISTO; no evento/audio/burst propio. Crítico tiene shake al salir y efectos fuertes al impactar; si falla no hay reconocimiento especial claro de perfect shot.

## Ejecución y partidas

- Arranque Godot headless90frames sin errores.
- Ensayo existente final_balance_tests: 16 comprobaciones, cero fallos. Cinco oleadas y jefe,56bajas, queso274,5; compras/reparación/mejoras reales. Bot automatizado, no valoración humana de diversión.
- Sesión navegador publicada ?qa=1: partida1, montar e iniciar oleada, HP arquero100 estando montado; seis ratas, queso90 y después derrota en tiempo simulado40,83 s. Rata trasera parcialmente oculta. Reinicio mediante botón correcto.
- Partida2: volver a montar, bajar al suelo y desplazarse; telemetría mounted=false y posición distinta, empezar oleada manual. La sesión acaba en derrota, con arquero muerto y torre destruida; no se certifica aquí una reaparición observada directamente.
- Partida3, después de reiniciar: clic derecho breve en preparación confirmado por munición40→39 y arrows=1. No se mantiene físicamente el botón con esta API. Ensayos previos CORE_GATE/MVP cubren cargas temporizadas mediante harness; no se sustituyen por afirmaciones de juego humano.
- FPS observados25–30 en preparación y18–26 con seis básicas en este navegador automatizado; tiempo simulado menor que reloj en algunos tramos. Se requiere medición posterior en condiciones normales; no es evidencia de 60 FPS sostenidos.

## Dependencias de evolución

Definir incentivos de torre, fuentes de recursos, melee y AOE con el usuario antes de especificar economía. Input/settings centralizados deben preceder botones nuevos y pausa; mismo GameState para overlays/pausa/menú. Cámara separará posición física y seguimiento visual sin desalinear transformación de cursor. Regla de flecha verde+ necesita metadato explícito de carga para distinguir rojo (no crítico) y límite de área frente a viewport. Reutilizar distribución actual, separar ownership y revisar contratos antes de editar raíz compartida. Migración del guardado debe preservar historia y ajustes sin sobrescribirlos por derrota.

Siguiente paso: GAME DESIGN INTERVIEWER, primer bloque exclusivamente sobre abandonar la torre de forma atractiva. No se eligen mecanismos nuevos hasta respuestas.
