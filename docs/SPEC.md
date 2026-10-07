# SPEC — Arquero y queso

Fecha: 7 de octubre de 2026. ARCHITECTURE AGENT. Previo a implementación y revisión independiente. Las cifras son balance provisional, no decisiones del usuario ni resultados medidos.

## Juego y presentación

Godot 4.x/GDScript para navegador. Supervivencia infinita, defensa arcade táctica y frenética, humor y retro 8-bit. Campo central cuadrado de 720 × 720 en ventana 1152 × 720 con dos paneles de 216; render interno del campo 360 × 360 escalado nearest. Son medidas técnicas propuestas. Cámara sigue arquero; paneles no se desplazan. Aspecto isométrico con suelo de rombos, sombras, elevación de sprites y orden por y. Física plana sin gravedad ni zonas corporales.

## Ratón, movimiento y torre

Izquierdo en suelo: mover hacia destino. Izquierdo en torre: aproximarse y subir al llegar cerca. Desde torre, izquierdo en suelo baja y mueve hacia destino. Derecho mantenido: cargar; soltar: disparar. Puntería inmediata y libre. Velocidad base provisional 100 unidades/s; se mueve cargando al 65% de velocidad. Un impacto normal recibido no cancela carga. No existe cancelación manual. Subir/bajar no cancela carga. Sobre torre no recibe daño; daño al queso aumentado, propuesta ×1,5. Ratas atacan al arquero cercano en suelo o al queso; si jugador muerto/refugiado, van al queso.

La UI consume sus clics izquierdos sin mover al arquero. Durante carga se captura liberación derecha global incluso sobre panel/fuera de campo; se conserva último aim válido cuando cursor sale del campo. El navegador no abre menú contextual. Perder foco resuelve interrupción segura, sin disparo gratuito ni carga atascada. Muerte, rotura y derrota interrumpen carga: son consecuencias, no cancelación voluntaria. Cursor mundial se obtiene con transformaciones del campo/cámara; shake no crea desplazamiento oculto del origen físico.

## Carga, triángulo y flecha

Estados IDLE, CHARGING, OVERCHARGING, RELEASE instantáneo y COOLDOWN. Naranja: poco alcance/daño/velocidad, base ancha. Verde: instante de precisión y crítico que rompe protección. Rojo: más daño/penetración, vibración, peor precisión y riesgo creciente de rotura, con reparación temporal automática. Liberar emite flecha inmediatamente.

Triángulo fantasma en suelo: vértice en punta del arco, base transversal a distancia de alcance. Longitud crece y base se estrecha hasta óptimo; en sobrecarga la base vuelve a ensancharse. Flecha elige uniformemente un punto de la base y viaja en línea recta hacia él. Alcance físico coincide con distancia real hasta ese punto; el indicador comunica dispersión verdadera. Vibración visual no añade desviación no mostrada.

| Balance inicial, unidades del mundo interno 360 | Propuesta |
| --- | --- |
| Sweet spot | 0,85–0,98 s |
| Sobrecarga / máxima potencia | >0,98 s / 2,2 s |
| Recuperación por rotura | 1,5 s |
| Daño bajo / óptimo / rojo máximo | 12 / 34 / 50 |
| Multiplicador crítico | 1,5 |
| Velocidad baja / óptima / máxima | 190 / 360 / 450 por segundo |
| Alcance bajo / óptimo / máximo | 65 / 210 / 280 |
| Semianchura base baja / verde / rojo máximo | 42,5 / 3,5 / 27,5 |
| Impactos normales / rojo avanzado | 1 / hasta 3 |

Riesgo por segundo creciente; probabilidad por paso `1-exp(-riesgo*delta)`, nunca fija por frame. Propuesta riesgo 0 al comenzar rojo, 0,7/s a 2,2 s y aumento posterior acotado. RNG con semilla para diagnósticos. Potencia limitada para no crecer infinitamente.

Munición limitada: una flecha al emitir, no al romper sin disparar (propuesta). Sin munición se rechaza carga con aviso. Flecha desaparece tras impacto normal, tras agotar penetración, alcance, lifetime o al salir del campo visible. Detectar segmento entre pasos; procesar impactos por distancia y nunca dañar dos veces al mismo enemigo con una flecha. Crítico rompe escudo/armadura y aplica daño a HP; no crítico contra protección causa daño reducido. Penetración roja no produce crítico por sí sola.

## Oleadas, economía y mejora

Inicio manual de cada oleada. Final solo cuando no quedan spawns pendientes ni ratas vivas: premio, elección gratuita de UNA mejora entre varias elegibles, compra/reparación y espera manual. Tienda siempre disponible y no pausa combate. Propuestas: 40 flechas, 10 monedas iniciales; 10 flechas cuestan 6; reparar 30 HP cuesta 12; básico 30 HP, velocidad 29, recompensa 3; arquero 100 HP, queso 300; reaparición 2,5 s con 1 s inmunidad mientras queso vivo. Reaparición no regala saldo/munición. Comprar valida saldo y utilidad antes de cobrar.

Primera oleada propuesta 6 básicas, spawn cada 1,1 s, premio 8. Dificultad por cantidad, composición e intervalo acotado; no multiplicar eternamente todas las estadísticas. Partidas iniciales objetivo de balance 5–8 min, sin fin forzado. Variantes finales: básica, rápida, pesada con embestida anunciada, escudada y jefe periódico con amenaza propia. Solo básica antes de gate/MVP.

Árbol compacto: arco (cadencia/tolerancia), flecha (daño/penetración), movilidad (marcha/disparo en marcha), torre (vida/reparación). Datos con requisitos y rangos; ofrecer hasta tres elegibles y evitar selección duplicada. No ampliar a sistemas ajenos al bucle.

Persistencia confirmada: al perder se conserva automáticamente un porcentaje del árbol según dinero. Regla numérica provisional: `ratio=clamp(coins/200,0,1)`; `retained=floor(acquired_count*ratio)`. Conservar adquisiciones más antiguas en orden, incluidos rangos; padres deben adquirirse antes de hijos. Cero monedas conserva cero; 200 permite conservar todo. Dinero se consume/reset en nuevo run. Mostrar porcentaje, retenidas/perdidas antes de reiniciar. Guardado local versionado en navegador, sin sincronización entre equipos.

## HUD, tutorial y criterios

Vida jugador, munición y vida queso siempre visibles; además monedas, oleada y arco. Tutorial ratón: mover, cargar, verde, torre, compra y siguiente manual. Números de daño y señales distintas para escudo/crítico/rotura. Texto/formas acompañan color. Audio retro, recoil, squash, estelas, shake y aberración puntual después de núcleo funcional; interruptor de efectos y volumen. El HUD permanece legible.

Prototipo SOLO apuntar/mover, cargar, triángulo, rotura, flecha arcade, una básica, daño y reinicio. Gate exige juego real y lectura correcta. MVP añade torre, oleadas, tienda, primera elección, reaparición, derrota, retención y reinicio. Final añade variedad/árbol compacto/arte/audio/tutorial. Build web debe arrancar desde HTTP, jugarse con ratón, conservar cuadrado al escalar, reiniciar sin nodos duplicados y registrar rendimiento. No declarar diversión a partir de compilación o tests.

# SPEC V2 — contrato vigente tras entrevista

Reglas V2 prevalecen sobre las tablas históricas de V1 conservadas debajo. Los números siguientes son punto inicial de balance, no valores elegidos por el usuario.

Input central abstracto: move_up/down/left/right, move_to_position, aim, charge/shoot, melee, dash, interact, pause. WASD y clic seleccionables; tiro izquierdo/derecho y botón opuesto movimiento/interacción; central melee, E torre cercana, Espacio dash, Esc pausa. Persistencia versionada valida ajustes/progreso, tolera guardados V1 y datos corruptos. UI consume pulsaciones sin ataques/movimiento; liberación de carga iniciada debe resolverse incluso sobre panel. Pausa conserva tiempo de carga, dash, respawn, proyectiles/oleadas sin avance ni disparo involuntario al volver. Menú, ajustes y ayuda usan un único estado/overlay, tienda durante combate no pausa.

Carga sin cancelación voluntaria. Ventana verde 0,85–0,98 s; rojo hasta morado provisional 1,55–1,67 s; rojo final hasta rotura garantizada 1,85 s. No RNG de rotura. Morado: daño inicial 28, velocidad420, semiancho18, penetración sin límite (un hit por ID), no crítico/rotura de protección, una munición. El fantasma grande debe mostrar el corredor real; no multiplicar daño por frames ni efectos. Indicador independiente de vida física. Cargas bajas mantienen alcance; verde+ viaja hasta contacto que agote penetración, área jugable o lifetime seguro6s. Si ningún enemigo fue impactado, genera una sola flecha recuperable en punto final accesible; impactos no duplican munición.

Melee: sin munición, cursor estable, barrido frontal corto (alcance32, ángulo110°), daño inicial12, cooldown0,45s, animación0,18s, empuje14. Daño una vez por enemigo por golpe, multiobjetivo; ralentización durante animación, no mientras carga. Disponible roto y con cero saldo. Baja melee concede recompensa normal de monedas y dos flechas físicas iniciales garantizadas. Recompensas no duplicadas cuando múltiples sistemas causan muerte. Pickups monedas/flechas agrupables, radio básico12, mejoras magnéticas ampliables en suelo. Permanecen entre oleadas; saldo solo incorpora monedas recogidas. Premio de oleada automático y retención siguen funcionando.

Dash inicial distancia75, duración0,18s, cooldown1,0s; perfil rápido con desaceleración, corrección angular limitada, iFrames primeros0,08s. Movimiento/cursor como dirección fallback. No atravesar huella sólida de torre ni borde; contacto/bloqueo termina desplazamiento coherentemente. Espacio montado baja y dash; carga conservada y apuntado estable, melee encolado al final si permitido. Cámara sigue target visual suavizado con respuesta rápida, shake aparte; conversión de cursor usa transform actual.

Torre/ratas: zona no transitable y contactos geométricos coherentes para marcha/embestida, solución de oclusión compatible con Y-sort sin aparentar andar encima. Aim usa ancla independiente del facing anterior y zona muerta que retiene último aim válido. Cambio de cursor a 1–2px no oscila.

UI: lenguaje reutilizable de ventanas rectangulares/barras/bordes/botones con volumen, controles originales, estados hover/pressed/disabled, sliders separados música/SFX, menú, pausa, ajustes, ayuda, HUD/tienda y árbol de líneas/ramos; no assets Windows. Mantener campo cuadrado y métricas vitales visibles. Árbol combinable con prerrequisitos y mejoras de precisión/potencia, movilidad/melee, economía/recogida y torre; efectos no meros porcentajes. Bootsplash Godot4.4 independiente del menú. Perfect, BREAK, READY, dash/melee/pickup usan señales y feedback acotado.

Verificación: pares configuraciones movimiento/disparo, pausa/foco, ceroammo/saldo con todas flechas consumidas, críticos/protección/espectral multiimpacto, recuperación sin duplicación, dash límites/torre/montaje y carga, aim centro/cámara, navegación 360°, ajustes/progreso, cinco oleadas+jefe, nodos/efectos estables, navegador real y export reproducible. No declarar diversión/performance aprobadas solo por headless.

