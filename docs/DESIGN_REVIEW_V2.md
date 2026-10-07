# GAME DESIGN / SCOPE REVIEW V2

7 de octubre de 2026. Revisión independiente de diseño y alcance sobre fuente integrada, incluidos cambios locales del orquestador; no es certificación de una RC inmutable. El reviewer solo escribe este informe. Entrevista cerrada: GAME_VISION/SPEC V2 gobiernan el alcance.

## Veredicto

**GO de diseño/alcance para RC y prueba web. No se detectan fallos altos nuevos ni sistemas solicitados ausentes en la fuente revisada.** La evolución mantiene el arco como gesto principal, añade recuperación sin recursos y ventajas concretas de desplazarse, respeta recoger entre oleadas y evita forzar excursiones con castigos. El balance del combate móvil y la comodidad humana siguen sin certificarse. Release requiere cerrar navegador, audio/guardado/segunda partida y rendimiento con la build exacta; este informe no declara diversión ni 60 FPS.

## Evidencia examinada y ejecución propia

Leídos Game, Player/Input, Bow/Arrow, Enemy, PickupManager, UpgradeManager, HUD/shell, balance/enemigos/mejoras, tests V2 y CODE_REVIEW_V2. Revisadas capturas de render real de menú, ajustes, ayuda, HUD y árbol en `work/temp/v2-*.png`. Son capturas estáticas del orquestador: no prueban interacción web ni audibilidad.

Logs actuales: Bow166, Player64, UI/Upgrades198, integración78 comprobaciones sin fallos; Enemy/Economy PASS; bot/stress24 sin fallos. Revisados los fixtures para distinguir reglas inyectadas de comportamiento integrado. Ejecución independiente propia de `tests/v2_playtest.gd`, Godot4.4.1 headless con APPDATA aislado, produjo otra vez **24 checks/0 fallos, cinco oleadas con jefe,52 bajas, cinco excursiones, tres compras y queso295**. Log: `work/temp/v2_design_review_playtest.log`, relativo a la carpeta de entrega (dos niveles encima del proyecto).

El bot usa señales/métodos reales, munición/precios/premios y ofertas reales; no modifica HP para ganar las cinco oleadas. Apunta calculando lead y libera sistemáticamente en verde. **Combate montado y recoge en suelo entre oleadas**. Es evidencia de ciclo funcional y excursiones útiles para recargar saldo, no de alternancia espontánea entre melee/dash/morado durante oleada ni de diversión. Stress propio:325 nodos cargados frente65 base,120 ticks manuales en288907µs,96 registros y retorno1→1 al disponer escena; CPU headless, no FPS web.

## Lectura del nuevo loop

Las monedas de bajas ya no llegan al saldo a distancia; premio de oleada sí. Montado no recoge ni magnetiza. Salir obtiene poder de compra/retención y flechas recuperadas; melee permite generar flechas nuevas sin recursos. La recogida básica pequeña evita pisar cada objeto exactamente y la rama magnética amplía comodidad sin recoger desde torre. Fallos verdes/rojos/morados recorren terreno más allá del indicador y se recuperan solo si no tocaron enemigos; una protección bloqueada cuenta como impacto. Esa separación conserva el coste del error y evita duplicar munición.

Recursos permanecen entre oleadas y su límite agrupa cantidades sin pérdida. El jugador puede posponer excursiones hasta PREP/CHOICE; es una alternativa autorizada. No añadir recogida automática, caducidad, multiplicador económico de suelo ni temporizadores para invalidarla. Con esta evidencia todavía no se demuestra que salir durante WAVE compense siempre el riesgo: tampoco se exige que sea siempre óptimo. La torre inmune para arquero sigue intercambiando seguridad por daño extra al queso.

Dash conserva carga y ofrece desplazamiento/defensa breve, bloqueado por sólidos; no montaje automático. Melee no se admite mientras carga ni inicia carga durante su animación; el golpe encola una única acción al terminar dash si sigue permitido. Son alternativas con compromiso temporal coherente, sin un nuevo recurso o botón de área.

## Balance observado: seguimiento concreto

**MEDIO, balance pendiente — recuperación protegida bajo presión.** Datos efectivos: shield45HP, melee12 reducido a3HP; requiere15 golpes, al menos6,3s entre primero y último con cooldown0,45s, más acercamientos causados por empuje. Boss300HP protegido requiere100 golpes, mínimo44,55s equivalente. El jefe invoca runners: esas bajas blandas permiten recuperar flechas antes de matar todo el jefe con melee. Verde rompe protección y conserva una ventaja clara.

Tests prueban daño positivo, muerte única y recursos físicos. La integración repone posición del enemigo entre golpes; el test Enemy aplica muchos golpes sin simular cadencia/ataques. Por tanto no certifican recuperación cómoda de una rata blindada mientras queso/arquero reciben presión. No hay softlock lógico encontrado, pero el gate humano ceroammo/cero saldo, todas las flechas previas impactadas y enemigos protegidos vivos sigue necesario. Si tarda demasiado, ajustar daño/cooldown/empuje de los parámetros existentes; no regalar munición ni eliminar protección. Esta incertidumbre no exige sistema adicional ni bloquea RC de prueba.

**MEDIO, balance pendiente — excursiones activas.** La ejecución de cinco oleadas pierde solo5HP de queso y reúne224 monedas al clear final antes de su última excursión. Demuestra que la estrategia montado/verde + recogida entre oleadas funciona con ese bot; no acredita desafío humano ni necesidad de combatir móvil. En sesión real comparar recoger temprano para reparar/rearmar frente recoger al final y observar utilidad de dash/melee/morado. Mantener ambas rutas, ajustar cifras solo ante esa evidencia.

**BAJO, lectura del árbol — orientación requiere scroll.** Captura1152×720 mantiene HUD vital y muestra requisitos enlazados, adquirida/disponible/ofrecida/bloqueada y rangos. Árbol supera ancho del campo y usa scroll horizontal/vertical; en la captura se ven nodos parciales en bordes. No es contenido perdido: la instrucción de desplazamiento está visible. Verificar navegación real y tooltips en la resolución web reducida antes de declarar claridad aprobada.

## Carga, ramas y presentación

Secuencia naranja→verde→rojo→morado→rojo breve→rotura es determinista, con advertencia y recuperación. Morado28 sin crítico queda bajo verde34×1,5=51 por objetivo; gana cobertura y penetración ilimitada, conserva protección (7HP sobre blindado). Verde mantiene especialidad de romper defensa. Rojo finito sacrifica precisión por potencia/penetración. No se ha añadido bomba radial, daño repetido por frame ni botón separado.

Las nuevas especializaciones cambian decisiones concretas: corredor espectral más ancho, ventana morada ampliada manteniendo rojo final, melee con abanico160°/alcance42, empuje/daño, dash más frecuente con iFrames, recogida/imán y reparación eficiente. Existen porcentajes básicos junto a estas opciones, pero el árbol ya no se limita a incrementos equivalentes. Requisitos combinables; no exclusiones nuevas. IDs V1 siguen activos, fast_draw escala secuencia y steady_string amplía margen determinista. UpgradeManager recompone desde bases y valida orden de umbrales, evitando ofertas con carga imposible. Una elección gratuita por oleada permanece.

La UI rectangular con barras de título/bordes/botones expresa la inspiración vintage solicitada sin depender de assets Windows. Capturas muestran ajustes de movimiento/disparo y volúmenes música/SFX separados, ayuda sobre melee roto/recuperación/morado y HUD vital visible. Perfect/BREAK/READY y acciones tienen rutas separadas de feedback/audio; no crean daño o premios. Cámara/aim y oclusión de enemigos en movimiento requieren observar el navegador: los stills en PREP no bastan.

## Alcance final

**NOW solicitado está representado:** correcciones aim/vuelo/geometría, input configurable persistente, pausa/menú/ayuda/splash, dash/melee/recursos físicos, carga morada, ramas visuales combinables, señales/presentación/audio. No se solicita campaña, crafting, inventario, nueva infraestructura, enemigos extra, dash complejo ni multiplayer. Export Windows adicional queda POST-MVP; más contenido/optimización compleja solo tras necesidad medida.

Prioridad para cierre: probar build web exacta, después ajustar lo observado. No ampliar alcance para resolver incertidumbres de balance. El bot y las suites permiten un GO de RC concreto; las limitaciones descritas impiden declarar gameplay humano/performance final aprobados.
