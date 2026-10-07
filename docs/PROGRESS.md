# PROGRESS

## Estado actual
M01–M04 integrados como primer checkpoint ejecutable; M05 pendiente de playtest independiente en navegador. No se ha añadido contenido de MVP.

## Terminadas
- GAME DESIGN INTERVIEWER: entrevista y cierre de visión con usuario.
- ARCHITECTURE AGENT: SPEC, ARCHITECTURE, PLAN y contratos.
- PLAN CRITIC: PASS WITH FIXES; correcciones incorporadas.
- SCOPE GUARDIAN: alcance por puertas documentado.
- BOW/ARROW AGENT: carga, crítico, sobrecarga, rotura, triángulo, flecha/penetración y visuales separados.
- ENEMY SYSTEM AGENT: rata básica, vida, ataque, daño y visuales separados.
- Orquestador: movimiento, penalización cargando, cámara, campo cuadrado, input central, escena de prueba, integración.
- Godot 4.4.1: ejecución headless integrada sin errores de juego.
- Exportación web: build sin hilos generada; servidor local Node en puerto 8766.

## Activas
- PLAYTEST / GAME FEEL AGENT: CORE_GATE en navegador; incluye harness de eventos para cargas temporizadas.
- TEST AGENT: pruebas de reglas y robustez del núcleo.

## Correcciones verificadas
- Exportar necesita directorios temporales accesibles; export con temporales dentro de work.
- Plantilla web_release utiliza hilos; sustituida por web_nothreads_release y debug correspondientes.
- Servidor Python local no responde en este entorno; Node localhost sí responde.

## Backlog después del core gate
M06 oleadas y refugio → M07 economía → M08 mejoras, derrota/reaparición y retención → playtest MVP → M09 variedad → M10 feel/arte/audio/tutorial → M11 balance → M12 revisión y build final.

## Decisiones
La entrevista actual sustituye prototipo fijo/parábola original por movimiento y flecha arcade. Verde crítico rompe armadura; rojo da penetración y riesgo. Regla de retención automática confirmada; umbral 200 monedas es balance provisional.

## Limitaciones de validación
Las pruebas automáticas no certifican diversión. La automatización de navegador permite clics pero no mantener físicamente botón; el harness genera secuencias temporizadas de eventos de ratón sobre el canvas. El informe debe distinguir ambos métodos.
