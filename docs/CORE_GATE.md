# CORE MECHANIC GATE — revisión independiente de navegador

Fecha: 7 de octubre de 2026. Roles: PLAYTEST AGENT y GAME FEEL AGENT. Revisor independiente de implementación; no escribió código del juego.

## Resultado

**PASS técnico del núcleo tras correcciones.** Puede continuar el MVP pequeño. Esto acredita interacción ejecutada y legibilidad básica; no acredita diversión subjetiva, control físico mantenido ni aceptación final del producto. Conservar revisión de sensación humana al ampliar el ciclo.

## Método y evidencia

Build Godot 4.4.1/WebGL2 ejecutada en Brave desde `http://127.0.0.1:8766/web/index.html`. Revisé pantalla y ejecuté clic izquierdo real de navegador: arquero se desplazó, cámara siguió, rata y suelo cambiaron de posición en pantalla mientras HUD permaneció fijo. La herramienta disponible no mantiene físicamente el botón derecho: para carga se usó `tests/browser_harness.html`, que envía MouseEvent de movimiento/pulsación/liberación al canvas del juego. No se alteró estado interno mediante evaluate.

La primera versión del harness liberaba tras tiempo de pared y podía emitir antes de la carga deseada bajo esta sesión automatizada; no se aceptaron sus nombres «verde/rojo» como evidencia. Se corrigió para consultar telemetría equivalente al HUD y liberar al alcanzar carga real. Los resultados siguientes pertenecen a esa repetición:

- Verde: DOM registró liberación en carga **0,9325657 s, estado ¡CRÍTICO!**. Pantalla mostró **BAJAS 01**, toast ¡CRÍTICO!, número 30 (vida restante) y flecha desaparecida después de impacto.
- Rojo: DOM registró liberación en **1,6421 s, estado PELIGRO**. Pantalla mostró segunda baja, flecha todavía en vuelo después de atravesar la rata y toast de liberación; diferencia verificable frente al verde.
- Naranja: carga temprana mostró triángulo corto/ancho a 0,14 s; a 0,50/0,77 s se alargó y estrechó. Su vértice permaneció junto al arco y orientación hacia cursor/rata. Una emisión temprana produjo vuelo desviado/daño menor en pruebas anteriores.
- Rotura: una carga prolongada produjo estado REPARANDO y mensaje ¡CUERDA ROTA! Se reanudó carga y disparo después de recuperación. No quedó el arco bloqueado.
- Repetición y reinicio: botón lateral restauró bajas a cero y permitió nuevas secuencias; no desplazó arquero. Se observaron varias emisiones, impactos y reaparición de diana sin duplicación visible.
- Consola: consulta de warnings/errors durante secuencia sincronizada devolvió lista vacía. No equivale a medición de rendimiento ni a prueba de todas las rutas.

## Hallazgos y decisiones

**ALTO, corregido y repetido:** suelo ocultaba AimIndicator por orden z. Antes, estado TENSANDO no tenía triángulo; después de cambiar capa del suelo apareció y comunicó geometría variable. No añadir contenido antes de esta corrección: condición ya satisfecha.

**MEDIO, corregido:** «ACERTADOS» era contador de bajas y «FLECHAS» proyectiles activos, no aciertos ni reserva. Sustituidos por BAJAS/EN VUELO en prototipo. En MVP usar munición real claramente identificada.

**MEDIO, limitación de prueba:** las capturas tienen latencia y no permiten medir input lag en milisegundos ni acertar físicamente una ventana de 130 ms. La telemetría demuestra liberación crítica correcta; no demuestra facilidad de timing para una persona. Revisar rendimiento y ancho de ventana con juego normal antes de balance final.

**BAJO, pendiente de feel:** HUD muestra estados y advertencias claras, pero el indicador temprano es contorno discreto. Mantener visible con más ratas/efectos; ampliar feedback de impacto/audio en fase prevista. No introducir partículas fuertes hasta comprobar lectura táctica.

## Alcance de la aprobación

No se ensayó físicamente mantener derecho, pérdida de foco del sistema operativo, liberación fuera del navegador, redimensionado múltiple, rotura de escudos ni penetración en varios objetivos: estos quedan en backlog de pruebas MVP/final. Prototipo de una diana valida emisión y primer impacto; no sustituye economía, oleadas o combate contra enemigos móviles. Continuar torre/oleada/economía pequeña, repetir gate si se modifica input, coordenadas o arco. No presentar juego completo ni afirmar «ya es divertido» con esta evidencia.
