# TEST FINAL — Validación técnica integrada

7 de octubre de 2026. TEST AGENT. Proyecto `outputs/project` después de integrar variantes, árbol y feedback/audio. Godot **4.4.1 stable**, Windows x64, renderer Compatibility, ejecución headless. Suites ejecutadas con APPDATA separado por suite dentro de workspace. Todas terminaron con salida 0, sin errores ni advertencias.

| Suite | Resultado |
| --- | --- |
| core_tests | 835 comprobaciones, 0 fallos |
| systems_tests | 47 comprobaciones, 0 fallos |
| integration_tests | 36 comprobaciones, 0 fallos; tres oleadas reales, 24 bajas |
| feedback_tests | 32 comprobaciones, 0 fallos |
| enemy_variants_tests | PASS: cinco variantes, escudo/crítico, muerte única, aviso/embestida y summons de jefe |
| final_balance_tests | 16 comprobaciones, 0 fallos; cinco oleadas y fixture de carga |

Las suites instrumentadas suman **966 comprobaciones**; además pasan las aserciones de variantes. Core mantiene rotura por tiempo estable entre 30/60/144 FPS. Integración valida compra sin pausa, selección gratuita/manual, refugio, reaparición, derrota, guardado y nuevo run. Feedback valida recursos PCM, ausencia de autoplay, pool y toggles.

## Cinco oleadas con jefe

Bot reproducible (wave seed 1042, upgrades 77, bow 991), guardado inicialmente vacío. Usa movimiento, carga/liberación, puntería predictiva, compras, reparación y una elección de oferta real por oleada. No cambia estadísticas, HP de enemigos, monedas ni munición para progresar. Prefiere daño/cadencia/penetración cuando una oferta válida lo permite. Audio desactivado durante este ensayo; física y efectos visuales siguen procesándose.

| Oleada | Frames activos a 60 pasos/s | Bajas acumuladas | HP queso al acabar | Monedas | Flechas |
| --- | --- | --- | --- | --- | --- |
| 1 | 651 | 6 | 300 | 38 | 34 |
| 2 | 650 | 14 | 300 | 79 | 25 |
| 3 | 880 | 24 | 300 | 136 | 14 |
| 4 | 1252 | 36 | 300 | 217 | 17 |
| 5 | 1466 | 56 | 274,5 | 172 | 10 |

La quinta oleada incluyó jefe de 300 HP y seis ratas invocadas adicionales; terminó por daño de flechas reales. El bot compró munición y reparó en combate pagando con recompensas. Continúa hasta PREP después de quinta elección, no se bloquea. Picos del run: diez enemigos y dos flechas simultáneas. Total 5.859 pasos, incluyendo preparación: 97,65 segundos simulados. Esto es una sesión de bot eficiente, no demuestra duración de 5–8 minutos para jugadores ni diversión.

## Carga y liberación de objetos

Fixture controlado separado: 80 ratas básicas distribuidas en anillo, 50 flechas creadas mediante `_shoot` consumiendo munición real y 80 partículas tras tormenta de impactos. Este montaje fuerza carga simultánea y no representa cadencia humana. Incluye mundo, HUD, cámara y feedback de la escena real. Tras 120 pasos, las flechas y partículas/anillos han expirado. Destruir escena devuelve el conteo de nodos a su base: **325 nodos en fixture, 1 al terminar**.

Tiempo medio de llamada manual `_process`, medido mediante reloj de microsegundos: run normal **67,6 μs/paso**; fixture inicial 80 ratas/50 flechas/80 partículas, **883,3 μs/paso** durante 120 pasos. Entorno identifica procesador como AMD64 Family 25 Model 97 Stepping 2, AuthenticAMD. Tiempo real del ensayo completo aproximado 2 s. Estas cifras excluyen renderizado, audio de navegador y espera de frames; no son FPS web ni garantía de rendimiento en otro equipo.

## Límites de la conclusión

PASS técnico de reglas y ciclo integrado, sin defectos detectados en estas suites. Validación visual de navegador, input físico, audición, memoria de una sesión larga, percepción de carga/efectos y valoración de disfrute requieren pruebas separadas. Supervivencia infinita no queda demostrada por cinco oleadas. Los límites de spawn se validan en WaveManager y callback de summons; `_spawn_enemy` es API interna y no se invocó por encima del techo en el fixture.

Archivo de guardado de cada ensayo se restaura al finalizar. No se ha hecho commit de este informe ni del nuevo test; integración corresponde al orquestador.
