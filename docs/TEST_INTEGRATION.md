# TEST INTEGRATION — MVP

7 de octubre de 2026. TEST AGENT. Ejecutado con Godot **4.4.1 stable** headless sobre `scenes/game/game.tscn`, mediante `tests/integration_tests.gd`. **36 comprobaciones, cero fallos, salida 0, sin errores de scripts.** Duración de ejecución aproximada 1,1 s; 3.598 fotogramas de simulación manual a 1/60 s. No es una medición de FPS.

Bot reproducible: semillas wave=1042, upgrades=77, bow=991. Usa `_next_wave`, `_begin`, `_release`, dirección calculada hacia rata dentro de 150 unidades y corrección por movimiento durante vuelo. Invoca el tick real de partida; no cambia balance, monedas, munición, HP de ratas ni elimina enemigos directamente. Actualiza frames del SceneTree periódicamente para cámara/canvas.

| Oleada | Frames activos | Bajas acumuladas | Queso al terminar | Monedas antes de mejora |
| --- | --- | --- | --- | --- |
| 1 | 651 | 6 | 285 | 32 |
| 2 | 743 | 14 | 345 | 56 |
| 3 | 855 | 24 | 390 | 100 |

En preparación el bot sube al queso, prueba daño ×1,5 y protección del arquero, baja y vuelve. Compra diez flechas por seis monedas durante oleada sin cambiar fase; reparar queso lleno no cobra. Completa las tres oleadas disparando, escoge exactamente una mejora gratuita y comprueba que la siguiente no comienza sola. Reparación dañada cobra precio real. Las mejoras de queso elegidas por RNG explican el aumento de vida máxima registrado; el test no modifica esos valores.

Casos de integración: golpe letal durante carga la interrumpe y no permite emisión al soltar; revive mientras queso vivo; puede disparar después. Segunda muerte seguida de destrucción del queso cancela reaparición pendiente. GAME_OVER limpia flechas, detiene oleada/tiempo y rechaza compra, reparación, próxima oleada, disparo y daño. El prefijo retenido calculado a partir del saldo coincide con archivo real; nueva instancia reinicia score, oleadas, actores, flechas y monedas iniciales, y carga solo progreso retenido. Archivo previo de guardado se respalda y restaura al terminar, usando APPDATA aislado en workspace.

El primer intento del test detectó un error del propio bot: intentó cargar durante recuperación de una descarga iniciada antes de morir la última rata. Se corrigió resolviendo esa carga mediante liberación y esperando el cooldown real. No se alteró implementación para forzar resultados.

Límites: esta prueba usa APIs de juego, no ratón físico ni UI real de navegador; no evalúa legibilidad, satisfacción, calidad sonora, rendimiento web ni sincronización de almacenamiento IndexedDB. No sustituye el playtest independiente del MVP ni demuestra que el juego resulte divertido.
