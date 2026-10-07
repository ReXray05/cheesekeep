# PROGRESS — prototipo entregable

M01–M10 implementados: apuntado, carga, flechas, combate, oleadas, economía, árbol, retención, cinco variantes, arte, tutorial, audio y efectos. Gates técnicos de núcleo y MVP documentados. M11 tiene balance inicial y cinco oleadas reproducibles incluido jefe; ajuste humano abierto.

M12: build web Godot 4.4.1 sin hilos, fuente, plantillas y lanzador Windows incluidos. Seis suites: 966 comprobaciones más aserciones de variantes, cero fallos. Fixture 80 ratas/50 flechas/80 partículas libera objetos. Ver TEST_FINAL.md.

Rendimiento web pendiente: navegador automatizado informa 1 FPS y simulación más lenta que tiempo real, incluso en preparación. No se ha separado entorno y renderizado del juego. No se declara gate de rendimiento aprobado. Disfrute, audición y duración media requieren sesiones humanas.

Controles y retención reflejan las decisiones del usuario: izquierda mover/subir/bajar; derecha cargar/soltar; conservación automática por dinero, umbral provisional 200. Tienda sin pausa y comienzo manual implementados. Hitos preservados mediante tags Git, prototipo separado e historial recuperable en bundle.
# PROGRESS V2

Estado: entrevista cerrada, documentación/contratos en revisión; implementación aún no iniciada. Rama integración feature/gameplay-polish-v2. M13_baseline_v1 eef11eb conserva versión publicada. Auditoría docs/AUDIT_V2.md y 16 checks existentes sin fallos; FPS18–30 entorno automatizado, rendimiento60 no certificado.

Terminado: baseline/auditoría, cinco bloques entrevista, decisiones confirmadas en GAME_VISION/SPEC V2, propuesta PLAN V2. Activo: ARCHITECTURE AGENT contratos; siguiente PLAN CRITIC y SCOPE GUARDIAN. Backlog: M14–M27. Preguntas de diseño pendientes: ninguna; balance provisional se valida jugando.

Bugs altos: aim autorreferente, munición irrecuperable sin ataque alternativo. Medios: alcance visual acopla vuelo, oclusión/embestida torre, salto cámara, ausencia READY. Resultado actual: V1 pública intacta, no se declara V2 jugable.

