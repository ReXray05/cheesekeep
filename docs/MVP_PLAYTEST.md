# MVP PLAYTEST — navegador, revisión independiente

Fecha: 7 de octubre de 2026. PLAYTEST AGENT; build MVP básica ejecutada en Brave/Windows desde `http://127.0.0.1:8766/web/index.html?qa=1`.

**Resultado: PASS técnico de las interacciones observadas, con rendimiento y aceptación humana pendientes.** No se encontraron bloqueos altos de UI en esta sesión. Este informe no acredita juego final, variedad, audio ni diversión subjetiva.

## Observado directamente

- Pantalla de arena cuadrada y paneles laterales: vida del arquero, queso, monedas, munición, oleada y controles legibles; ayuda y botones caben sin recorte en el tamaño probado.
- Clic en Empezar inició oleada 1; el botón se retiró durante combate y las ratas aparecieron desde varias direcciones.
- Comprar durante combate cambió 40 → 50 flechas y 10 → 4 monedas. Oleada/reloj/ratas continuaron; no hubo pausa ni movimiento del arquero producido por clic lateral. Sin dinero suficiente el botón quedó deshabilitado.
- Clic sobre queso aproximó al jugador y lo montó; el personaje se dibujó elevado. HUD mostró «REFUGIO: QUESO +50% DAÑO». No se midió inmunidad bajo ataque mientras montado ni multiplicador exacto en esta sesión; sí se comprobó señalización y estado visual.
- Clic en suelo bajó al arquero y lo desplazó, con cámara siguiéndolo y HUD fijo.
- Clic derecho real breve emitió flecha, mostró liberación y consumió 50 → 49 flechas sin menú contextual. Mantener físicamente el derecho no lo permite esta herramienta; esa ruta no se declara probada aquí.
- Las ratas infligieron daño a ambos objetivos: arquero 70/100 y queso 270/300 durante oleada activa. Sin disparar siguieron atacando y el queso se agrietó visualmente al caer su vida.
- Muerte real: arquero 0/100, cuerpo desaparecido, texto «REVIVES EN 0.9 s», queso 200/300. Reaparición posterior: arquero 100/100 y toast «¡El queso te devuelve a la vida!», queso 165/300. Saldo 4 y munición 49 permanecieron, sin recarga por morir.
- Consulta de warnings/errors de consola durante inicio/compra/bajar/disparar devolvió lista vacía.

## Limitaciones y hallazgos

**MEDIO — Tiempo aparente lento en sesión automatizada.** El reloj del juego avanzó aproximadamente 4–5 segundos entre esperas de 15–20 segundos de pared. `document.visibilityState` devolvió visible. `document.hasFocus` no está expuesto en el entorno de lectura de DOM; no se pudo atribuir la lentitud a foco, tab throttling, capturas o rendimiento del juego. No se aporta cifra FPS. Medir sesión de navegador en primer plano normal antes del final gate; comparar con QA para excluir coste de instrumentación.

**BAJO — Claridad bajo concentración de ratas.** Varias ratas cerca del arquero/tower pueden tapar el cuerpo y la parte inferior del queso. Priorizar orden visual, sombra/contorno e indicador de posición al pulir, sin aumentar efectos que oculten amenazas.

No se completó una oleada matando las seis ratas en esta prueba de navegador; elección gratuita, siguiente manual, compra/reparación con recompensas y conservación de árbol requieren evidencia separada de integración y playtest ampliado. El CORE_GATE documenta carga verde/roja y rotura usando eventos MouseEvent reproducibles y carga real, no botón físico sostenido. Integrar ambos informes sin confundir sus alcances.

## Derrota y reinicio observados al final de la sesión

El queso llegó a 0/300 y apareció «SE ACABÓ EL QUESO», oleada 1, tiempo 00:29, cero ratas vencidas, cuatro monedas restantes y «Conservas 0 / 0 mejoras (2%)». El botón «VOLVER A DEFENDER» reinició: arquero 100/100, queso 300/300, flechas 40, monedas 10, oleada 0, sin ratas y botón de comenzar disponible. La conservación con habilidades adquiridas no se probó en esta partida sin bajas; el porcentaje mostrado fue coherente con saldo4/umbral200.
