# PROGRESS — prototipo entregable

M01–M10 implementados: apuntado, carga, flechas, combate, oleadas, economía, árbol, retención, cinco variantes, arte, tutorial, audio y efectos. Gates técnicos de núcleo y MVP documentados. M11 tiene balance inicial y cinco oleadas reproducibles incluido jefe; ajuste humano abierto.

M12: build web Godot 4.4.1 sin hilos, fuente, plantillas y lanzador Windows incluidos. Seis suites: 966 comprobaciones más aserciones de variantes, cero fallos. Fixture 80 ratas/50 flechas/80 partículas libera objetos. Ver TEST_FINAL.md.

Rendimiento web pendiente: navegador automatizado informa 1 FPS y simulación más lenta que tiempo real, incluso en preparación. No se ha separado entorno y renderizado del juego. No se declara gate de rendimiento aprobado. Disfrute, audición y duración media requieren sesiones humanas.

Controles y retención reflejan las decisiones del usuario: izquierda mover/subir/bajar; derecha cargar/soltar; conservación automática por dinero, umbral provisional 200. Tienda sin pausa y comienzo manual implementados. Hitos preservados mediante tags Git, prototipo separado e historial recuperable en bundle.
# PROGRESS V2

Estado: implementación V2 integrada, suites técnicas y revisiones completadas; RC en verificación final por orquestador. Rama feature/gameplay-polish-v2. M13_baseline_v1 eef11eb conserva V1 publicada y todos los informes V1 anteriores. Las cifras FPS históricas de auditoría describen V1/entorno automatizado, no certifican V2.

Terminado: auditoría/entrevista, decisiones GAME_VISION/SPEC, contratos ARCHITECTURE y gates PLAN/SCOPE; aim estable, vuelo verde+, geometría común, cámara suave, melee/dash, pickups permanentes, carga morada/rotura determinista, input configurable, ajustes versionados, MENU/PAUSED, ayuda/splash, feedback perfect/BREAK/READY y árbol combinable. Fuente actual contiene20 IDs de mejora y40 rangos totales; conserva12 IDs V1 y añade8 V2. M14–M24 implementados; M25 cuenta con bot cinco oleadas+jefe, falta valoración humana; M26 review de código/performance técnico completo con gate web pendiente; M27 fuente/docs/export en cierre. Ninguna entrevista nueva necesaria.

Validación:166 bow +64 player/input +198 UI/upgrades +78 integración +24 playtest = **530 comprobaciones,0 fallos**, además Enemy/Economy PASS y50 casos de geometría. Bot sin godmode:cinco oleadas+jefe,52 bajas,queso295,cinco excursiones,tres compras. Stress80ratas/50flechas/96packs,325nodos y120ticks/298565µs CPU headless; disposal1→1. Detalles y límites en TEST_V2/CODE_REVIEW_V2. No equivalen a FPS web ni evaluación de diversión.

Hallazgos de revisión corregidos: pérdida de foco estando pausado reanudaba la partida; clic torre no aproximaba en WASD; contratos de carga/captura y geometría validados tras integración. Bugs altos V1 de aim y recuperación de munición resueltos en source/tests. No declarar gate de navegador/oclusiones/audio/performance aprobado por esta documentación.

Activo orquestador: export web4.4.1 sin hilos, revisión de layout/controles/segunda partida y almacenamiento en navegador; medir rendimiento real y revisar feel humano. Publicación V2 pendiente de esos gates. Build candidata `outputs/web/`, fuente `outputs/project/`; main pública V1 preservada hasta cierre RC. Balance de sesiones largas y comodidad subjetiva permanecen abiertos.

