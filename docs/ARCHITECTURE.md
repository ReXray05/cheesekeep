# ARCHITECTURE — Godot modular

Fecha: 7 de octubre de 2026. ARCHITECTURE AGENT. Contratos previos a implementación.

## Entorno y escena

Godot 4.4.1 disponible. Orquestador obtuvo plantillas web 4.4.1 en `work/templates/web_release.zip` y `web_debug.zip`; comprobar uso efectivo en exportación. No utilizar templates 4.1.1. Compatibility y export sin hilos si permitido; probar HTTP y documentar requisitos reales. Sin plugins de gameplay/backend/física 3D.

Main/Game organiza estado, input, jugador, economía, mejoras, HUD y audio. Control/HBoxContainer compone paneles laterales y SubViewportContainer cuadrado. SubViewport 360 × 360 se escala a 720 con nearest; contiene World Node2D, suelo, torre, actores, proyectiles, efectos y Camera2D. Arena provisional radio 330 unidades; cámara muestra parte y sigue al jugador. Mundo y distancias son 2D planos, isometría solo visual. Sombras e indicador bajo actores; orden por y. Jugador elevado visualmente sobre queso mantiene posición de suelo.

Input central: transforma cursor local del campo con inversa de canvas/cámara. UI captura izquierdo, pero liberación derecha de carga ya iniciada llega siempre a arco. Último aim válido se mantiene fuera de campo. Shake visual acotado y transformación coherente; origen físico del arco no depende de deformación del sprite. Pérdida de foco limpia input/carga de forma explícita.

## Contratos compactos de implementación

| Componente | Contrato y propiedad |
| --- | --- |
| Game/Main | Orquesta estados, referencias y enlaces; jugador, mundo, input/HUD, economía, mejoras y audio |
| BowController Node | `begin_charge`, `release(direction)`, `tick(delta)`; signals `shot(data Dictionary)`, `snapped`; estado/tiempo/riesgo/cooldown desde config |
| BowVisuals + AimIndicator Node2D | Lee parámetros del arco; dibuja tensión, recoil y triángulo; no decide daño ni RNG |
| ArrowPhysics Node2D | `setup(origin,data)`, integración de segmento, signal `moved_segment(from,to)`, registro IDs impactados y presupuesto de penetración |
| ArrowVisuals | Orientación, estela/estiramiento desde estado de física |
| EnemyController Node2D | `configure(kind,wave)`, `take_hit(damage,critical)` retorna Dictionary `killed,blocked,dealt`; `tick(delta,playerPos,towerPos,playerAlive,mounted)`; signals `attack(target,amount)`, `died(reward)` |
| EnemyVisuals | Variante, flash, squash y aviso; no calcula recompensa |
| WaveManager | Datos de composición/spawn, pending/alive y final único; nunca lógica de tienda |

Shot Dictionary inmutable tras release: `direction Vector2`, `speed float`, `damage float`, `critical bool`, `pierce int`, `range float`. Configuración permite tiempo y semianchura para AimIndicator; release muestrea base uniformemente. Main valida/descuenta exactamente una munición antes de instanciar; no se descuenta en visuales. Main procesa moved_segment contra círculos de enemigos ordenados por distancia, llama take_hit y register_hit; este adaptador puede extraerse si crece, sin duplicar física. Contratos acordados antes de trabajo paralelo.

No autoloads inicialmente. Referencias inyectadas por escena raíz y señales para feedback. No búsquedas globales por frame, singletons de cada sistema ni referencias circulares. Si Main crece al integrar MVP, extraer economía/upgrades/input/HUD en componentes pequeños; no crear abstracciones vacías antes de necesitarlas. Prototipo reutiliza componentes y se abre por escena propia o `?prototype=1`, sin fork de código de arco.

## Estados, datos y guardado

MENU → PRE_WAVE → WAVE → UPGRADE_SELECTION → PRE_WAVE. GAME_OVER al destruir queso desde cualquier fase. SHOP es panel siempre disponible, no fase pausante. Muerte/respawn/refugio son estados de jugador. Game valida transiciones: siguiente oleada solo tras elección, GAME_OVER rechaza compras/disparos/spawns. Muerte/rotura/derrota resetean carga y referencias pendientes.

Compras transaccionales: validar saldo, capacidad/utilidad y torre viva antes de descontar/aplicar. Muerte y oleada emiten premio una sola vez. Ratas atacan por cooldown, no contacto cada frame. Reiniciar crea nueva instancia de partida; elimina timers/flechas/actores y señales anteriores.

Resources o tablas tipadas pequeñas centralizan BowConfig, EnemyData, WaveConfig, UpgradeData. Balance solo en una fuente efectiva y documentado en BALANCE. UpgradeData: ID, título, explicación, categoría, max_rank, requisitos, estadística, operación, valor. Estadísticas se recomponen desde bases + rangos, sin volver a multiplicar valores actuales cada vez que se abre UI.

Retención: lista ordenada de adquisiciones válida (padres antes que hijos), conservar prefijo `floor(N*clamp(coins/200,0,1))`; umbral 200 provisional. Reset saldo. JSON user:// versionado guarda ajustes/progreso retenido; validar IDs, rangos, requisitos y archivo corrupto. Almacenamiento web local, sin cloud. Resultado de derrota expone regla al usuario.

Estructura: scenes/{game,player,weapons,projectiles,enemies,ui,effects}; scripts con mismas categorías y waves/economy/upgrades/systems; data/{balance,enemies,waves,upgrades}; assets/{sprites,audio,fonts,effects}; tests; docs; README. Collision layers/máscaras explícitas; flechas afectan enemigos y nunca jugador/torre.

## Robustez y verificación

RNG reproducible para riesgo/ofertas/oleadas. Flechas verifican segmento a alta velocidad, un hit por enemy ID, rango/lifetime/offscreen. Ataques y target selection limitados en frecuencia. Ensayo inicial 80 ratas/50 flechas, spawn respeta techo y reanuda plazas libres; efectos acotados. Objetivo 60 FPS, medir navegador/equipo real. Sin pooling hasta necesidad medida.

Tests significativos: sweet spot, riesgo independiente de dt, varios impactos de segmento, muerte/recompensa única, saldo insuficiente, ofertas/requisitos, wave finish, respawn/gameover/reinicio y retención/corrupción. Smoke headless detecta parse/carga; navegador verifica input, cámara, UI/foco, audio, scaling y guardado. No sustituir playtest con headless.

