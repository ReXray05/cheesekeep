# BALANCE — parámetros de Cheesekeep

Valores de la implementación del 7 de octubre de 2026. Son un punto de partida ajustable, no un balance definitivo. Distancias y velocidades usan las unidades del campo lógico de 360 × 360; se presenta a 720 × 720.

## Arco y flechas

Fuente: `data/balance.json`, sección `bow`.

| Parámetro | Valor inicial |
| --- | --- |
| Ventana verde inclusiva | 0,85–0,98 s |
| Pico de sobrecarga | 2,2 s |
| Reparación automática tras rotura | 1,5 s |
| Daño bajo / óptimo / rojo máximo | 12 / 34 / 50 |
| Multiplicador crítico verde | 1,5; daño inicial crítico 51 |
| Velocidad baja / óptima / máxima | 190 / 360 / 450 unidades/s |
| Alcance bajo / óptimo / máximo | 65 / 210 / 280 |
| Semiancho del margen bajo / óptimo / máximo | 42,5 / 3,5 / 27,5 |
| Tasa de rotura al pico rojo | 0,7/s |
| Penetración normal / roja / roja intensa | 1 / 2 / 3 enemigos |
| Vida máxima de una flecha | 4 s |

La carga normal interpola hasta 0,85 s; la ventana verde mantiene la potencia óptima y añade crítico. El rojo empieza después de 0,98 s: potencia, velocidad y alcance aumentan hasta 2,2 s, mientras vuelve a aumentar dispersión. La flecha se dirige a un punto uniforme de la base visible del triángulo. El rojo intenso concede el tercer impacto cuando la fracción de sobrecarga alcanza 0,6: inicialmente 1,712 s. Las mejoras de penetración añaden impactos a cualquier flecha.

La rotura es probabilística: `stress = max(0, (carga - sweet_end) / (peak - sweet_end))`; tasa `min(4, break_peak_rate * stress)`; probabilidad de cada paso `1 - exp(-tasa * delta)`. Mantener más allá del pico no aumenta las estadísticas de tiro, pero sigue elevando riesgo hasta el límite de tasa. La rotura no consume flecha ni monedas. El disparo consume una flecha; cada rata recibe como máximo un impacto de esa flecha. El proyectil desaparece al agotar penetración, alcance, vida o abandonar la pantalla.

## Arquero, queso y economía

| Parámetro | Valor inicial |
| --- | --- |
| Vida arquero / queso | 100 / 300 |
| Velocidad del arquero | 100 unidades/s |
| Velocidad cargando | 65 % de la normal |
| Reaparición | 2,5 s; junto al queso, con vida completa |
| Inmunidad tras reaparecer | 1 s |
| Daño al queso cuando estás montado | ×1,5 |
| Monedas / flechas al iniciar | 10 / 40 |
| Compra de flechas | 10 por 6 monedas |
| Reparación del queso | Hasta 30 HP por 12 monedas |
| Umbral para conservar todas las mejoras | 200 monedas restantes |

Montarse vuelve inmune al arquero; las ratas atacan el queso. Clic en el suelo baja. La tienda funciona sin pausar y no permite reparar queso intacto. Morir no reinicia saldo ni munición. Destruir el queso termina la partida.

## Ratas

Fuente: `data/enemies.json`; diferencias heredan la configuración básica.

| Tipo | HP | Velocidad | Radio | Monedas | Daño arquero / queso |
| --- | --- | --- | --- | --- | --- |
| Básica | 30 | 29 | 9 | 3 | 10 / 5 |
| Rápida | 18 | 55 | 7 | 4 | 10 / 5 |
| Escudada | 45 | 22 | 10 | 6 | 10 / 5 |
| Pesada | 95 | 18 | 13 | 10 | 10 / 5; embestida 20 / 14 |
| Jefe | 300 | 15 | 20 | 35 | 25 / 18 |

Ataques ordinarios: intervalo 0,9 s. Persiguen al arquero vivo en suelo si está a menos de 80 unidades; la rápida usa 100. En caso contrario buscan el queso. Distancia de contacto: radio de rata +5 para arquero, +29 para queso. Escudada y jefe reciben 25 % del daño normal mientras conservan protección; el crítico la rompe y aplica daño completo en ese mismo golpe.

Pesada y jefe preparan embestida cuando el objetivo está entre 40 y 110 unidades y han transcurrido 4 s de marcha normal desde el inicio o la anterior preparación. Preparación pesada 0,55 s, jefe 1 s. Dirección fijada al comenzar el aviso; pesada recorre hasta 44 unidades a 110/s y jefe hasta 55,25 a 85/s. Cada embestida daña una sola vez. El jefe solicita dos rápidas cada 6 s; la raíz limita invocaciones por capacidad.

## Oleadas

Fuente: `data/waves.json` y `wave_manager.gd`.

- Enemigos programados: `6 + 2 × (oleada - 1)`, además de invocaciones del jefe.
- Intervalo de aparición: `max(0,4; 1,1 - 0,07 × (oleada - 1))` segundos.
- Aparición en círculo a distancia 240–300 del queso; máximo 80 enemigos simultáneos.
- Rápidas desde oleada 2, escudadas desde 3, pesadas desde 4. Selección uniforme entre tipos disponibles.
- Un jefe como primera aparición en oleadas 5, 10, 15…; las restantes usan la selección normal.
- Premio de oleada: `8 + 2 × oleada` monedas. Termina al agotar apariciones y enemigos vivos.
- Elección gratuita de una mejora entre hasta tres ofertas elegibles; siguiente oleada manual. Sin mejoras disponibles: 10 monedas adicionales.
- No hay victoria final ni duración obligatoria. El tiempo mostrado incluye espera entre oleadas.

## Árbol compacto

Fuente: `data/upgrades.json`. Los efectos porcentuales se multiplican una vez por adquisición. El rango cuenta como adquisición para retención.

| Mejora | Requisito | Rangos | Efecto por rango |
| --- | --- | --- | --- |
| Cuerda ligera | Ninguno | 3 | Tiempos verde y pico rojo ×0,92 |
| Punta afilada | Ninguno | 3 | Daños base ×1,12 |
| Botas ligeras | Ninguno | 3 | Velocidad ×1,10 |
| Queso curado | Ninguno | 3 | Vida máxima del queso +45; recupera el incremento al adquirir |
| Pulso fino | Cuerda ligera | 2 | Semianchos del triángulo ×0,75 |
| Trenza resistente | Cuerda ligera | 3 | Tasa de rotura ×0,80 |
| Aguja de acero | Punta afilada | 2 | Un impacto adicional por flecha |
| Golpe maestro | Punta afilada | 2 | Multiplicador crítico ×1,10 |
| Disparo en marcha | Botas ligeras | 3 | Factor de movimiento cargando +0,08; máximo 1 |
| Paso de ratón | Disparo en marcha | 2 | Velocidad ×1,15 |
| Remiendo sabroso | Queso curado | 3 | Reparación +10 HP |
| Corteza firme | Queso curado | 3 | Multiplicador de daño al queso montado ×0,90 |

## Retención automática

Al perder: `K = floor(N × clamp(monedas / 200, 0, 1))`, donde N es el número de adquisiciones incluidas las conservadas de la partida anterior. Se guarda el prefijo de las primeras K adquisiciones, en orden histórico; se validan sus requisitos y rangos. Con cero monedas no se conserva ninguna; con 200 o más se conservan todas. Por ejemplo, 8 adquisiciones y 75 monedas conservan 3. El dinero restante no se hereda: la nueva partida empieza con 10 monedas y 40 flechas.

## Límites y seguimiento

Máximos de configuración: 80 enemigos, 50 flechas, 80 textos flotantes; no son medidas de FPS ni garantías de rendimiento. Validar el equilibrio entre comprar/reparar y ahorrar, supervivencia avanzada, facilidad del verde y ventajas relativas de crítico y rojo mediante sesiones adicionales. No se fija duración promedio ni se declara diversión comprobada por estos números.
# Balance V2 — punto de partida, pendiente de playtest

Reglas elegidas documentadas en SPEC/GAME_VISION V2; cifras de abajo son ajustables. Preservar datos históricos V1 como comparación, no usar RNG de rotura.

| Sistema | Inicial V2 |
| --- | --- |
| Verde | 0,85–0,98s, crítico rompe protección |
| Morado | 1,55–1,67s, daño28, velocidad420, semiancho18, atraviesa todas una vez |
| Rotura | 1,85s garantizada, recuperación1,5s, aviso rojo previo |
| Melee | daño12, alcance32, ángulo110°, cooldown0,45s, animación0,18s, empuje14 |
| Recompensa melee | monedas normales físicas y 2 flechas físicas garantizadas |
| Dash | 75 unidades /0,18s /1s cooldown, iFrames0,08s, corrección ligera |
| Recogida | radio12 suelo, ampliable por árbol, sin desaparición entre oleadas |
| Economía | inicio40 flechas/10monedas, pack10precio6, reparación30precio12 |

No hay bonus por estar fuera; recogida a tiempo, melee y reducción de presión a torre son incentivos. Premio de oleada automático sigue disponible; monedas de bajas no suman saldo hasta recoger. Magnetismo no debe permitir recoger desde torre ni eliminar todas las excursiones. Flechas recuperables no deben duplicarse por impactos/salida/reinicio.

Verificar protección: melee debe poder acabar incluso una rata blindada con ceroammo; si tarda demasiado para recuperar la partida, ajustar daño mínimo/knockback/cooldown conservando especialidad verde. Morado moderado y daño una vez por ID; su potencia grupal requiere límites de ancho, no límite arbitrario de enemigos. Ajustar después sesiones reales y ensayo cinco oleadas+jefe, no considerar diversión certificada por bot.

## Árbol V2 efectivo

Fuente: `data/upgrades.json` de la candidata2d5aa57. **20 IDs distintos,40 rangos totales**:12 IDs V1 preservados y8 nuevos. La tabla V1 anterior es histórica; esta sustituye sus efectos incompatibles. Rebuild parte de bases y aplica rangos una vez, valida orden de ventanas y clamps; no acumula efectos al abrir UI. Ramas combinables, sin exclusividades.

| ID / mejora | Requisito | Rangos | Efecto por rango |
| --- | --- | ---: | --- |
| fast_draw / Cuerda ligera | Ninguno | 3 | Verde inicio/fin, morado inicio/fin, rotura y pico rojo ×0,92; adelanta toda la secuencia |
| damage / Punta afilada | Ninguno | 3 | Daño bajo/óptimo/rojo/espectral ×1,12 |
| stride / Botas ligeras | Ninguno | 3 | Velocidad de marcha ×1,10 |
| cheese / Queso curado | Ninguno | 3 | Vida máxima queso +45; se recupera incremento al adquirir |
| precision / Pulso fino | fast_draw | 2 | Semianchos del cono normal ×0,75; no estrecha franja espectral |
| steady_string / Trenza resistente | fast_draw | 3 | break_time +0,12s, prolonga rojo final antes de rotura garantizada; no RNG ni cambio del cooldown de recuperación |
| piercing / Aguja de acero | damage | 2 | +1 impacto para flecha normal/roja; espectral ya ilimitada |
| keen_edge / Golpe maestro | damage | 2 | Multiplicador crítico verde ×1,10 |
| momentum / Disparo en marcha | stride | 3 | Factor de marcha cargando +0,08, máximo1 |
| nimble / Paso de ratón | momentum | 2 | Velocidad de marcha ×1,15 |
| repair / Remiendo sabroso | cheese | 3 | Reparación +10HP |
| rind / Corteza firme | cheese | 3 | Multiplicador de daño queso montado ×0,90, mínimo1 |
| spectral_corridor / Corredor fantasma | precision | 1 | Semiancho espectral ×1,50:18→27 |
| spectral_window / Pulso espectral | steady_string | 1 | Fin de morado +0,10s y rotura +0,10s; conserva duración del rojo final |
| sweep / Barrido de corteza | stride | 1 | Alcance melee +10 y ángulo +50°:32→42 /110→160° |
| shove / Despejar el paso | sweep | 1 | Empuje melee ×2 y daño +6:14→28 /12→18 |
| dash_chain / Paso fugaz | momentum | 1 | Cooldown dash ×0,72 y iFrames +0,04s:1→0,72 /0,08→0,12s |
| magnet / Bolsillo magnético | Ninguno | 1 | Radio magnético +20:12→32; solo en suelo |
| wide_collect / Manos llenas | magnet | 1 | Recogida +10 y magnetismo +12:12→22 /32→44 |
| field_repair / Reserva de corteza | repair | 1 | Reparación +20HP y precio −3monedas, mínimo1; se suma a rangos de repair |

Casos relevantes de migración: steady_string conserva ID/rango pero sustituye reducción probabilística de rotura por margen determinista; fast_draw conserva ID/rango y escala también ventanas moradas y límite de rotura. Pulso espectral extiende fin de morado y límite juntos, evitando consumir todo el rojo final. Estas especializaciones cambian corredor/tiempos/barrido/recogida; no añaden botones o recursos nuevos.

