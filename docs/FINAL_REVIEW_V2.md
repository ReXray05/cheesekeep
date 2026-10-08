# FINAL REVIEW V2 — candidata técnica

7 de octubre de 2026. Reviewer independiente de arquitectura/código/performance. Fuente examinada: **2d5aa57932dbd8b9c9c5cb28d46091fd2803a7a7**, integración V2 final. Baseline V1 `eef11eb` preservada. Revisión read-only de source y única escritura de este informe; no gameplay, datos o build modificados por el reviewer.

## Dictamen

**GO para empaquetar y publicar una RC técnica de V2, con limitaciones visibles.** No quedan defectos altos de código confirmados en la candidata revisada. **No se aprueba rendimiento web sostenido ni feel/diversión humana.** No presentar esta RC como validación final de esos criterios. Una build que carga y pasa tests sigue requiriendo comprobar experiencia y rendimiento en condiciones normales antes de cerrar el gate completo.

## Cambios finales examinados

Contrastado commit de integración con CODE_REVIEW_V2 y contratos ARCHITECTURE V2: guard idempotente de foco mantiene PAUSED; WASD admite aproximación por clic torre; HUD recibe estado inicial antes de simular MENU; Game conserva captura/recaptura sin reiniciar carga, mundo PAUSABLE y tweens de labels asociados a world. Overlay/menú/ajustes permanecen activos mientras gameplay se congela. No nuevas rutas que dupliquen ammo/recompensa/retención encontradas.

Revisadas integración de melee/dash/pickups/finish, settings persistentes, feedback READY mediante recovered, geometría común y aim desde ancla independiente. Árbol final distribuye requisitos como jerarquía desplazable y dibuja todos los enlaces de requires; no elimina elegibilidad ni cambia adquisición combinable. Datos actuales: **20 mejoras distintas y40 rangos**, no26. Sustitución de glifos decorativos principales por símbolos ASCII legibles en menú/HUD/árbol; textos españoles y marcador de bloqueo × permanecen. `git diff --check` de source/config respecto al commit examinado no informa errores.

Boot splash propio y versión2.0 declarados en project.godot; Compatibility/Godot4.4.1, preset Web sin hilos y templates4.4.1. Export excluye docs/tests/web para no incorporar artefactos al pack. Exportación del orquestador: **exit0**. Archivos candidatos index.html/js/pck/wasm presentes en `outputs/web/`; presencia no sustituye ejecución HTTP.

## Evidencia técnica

Reejecución independiente sobre la fuente final: **v2_upgrades_ui.gd,198 assertions,0 failures,exit0**, log absoluto `work/final-review-v2-ui.log`, Godot4.4.1 stable official. Prueba el árbol/datos/requisitos/ventanas y construcción UI tras cambios finales; no certifica todas las resoluciones por render visual. Review anterior reejecutó Bow166 y Enemy/Economy PASS sin errores. TEST_V2 reúne **530 checks/0 fallos** (166+64+198+78+24), Enemy/Economy PASS y50 casos de geometría adicionales.

Bot cinco oleadas+jefe:52 bajas,queso295,cinco excursiones y tres compras. Stress80ratas/50flechas/96packs,325nodos;120ticks en298565µs ≈2,49ms/tick CPU headless. Disposal1→1. Son resultados técnicos del harness, no una tasa de FPS web ni una valoración de diversión. Caps de registros/efectos y cleanup examinados; no se recomienda pooling/refactor adicional sin medición que lo justifique.

## Navegador y límites observados

Evidencia comunicada por el orquestador, sobre build local HTTP en Brave automatizado: menú carga, nueva partida entra a PREP; disparo consume ammo40→39 y genera un pickup tras fallar; pausa/ajustes/reanudación permiten WASD y disparo izquierdo; aproximación a torre y segundo disparo dejan ammo38/dos pickups. No errores de consola reportados en ese recorrido. Esta evidencia está atribuida al orquestador; el reviewer no la ha reproducido mediante una sesión separada.

Comprobación adicional comunicada al cierre: recarga web vuelve a MENU con WASD/disparo izquierdo guardados; símbolos decorativos corregidos siguen legibles. Esta observación cubre persistencia de esas preferencias tras recarga en el origen local; no certifica todas las claves ni retención de derrota web.

**El entorno informa1FPS y simulación lenta incluso en PREP sin enemigos.** No se ha separado causa de juego, visibilidad/oclusiones del navegador, entorno automatizado o GPU. No atribuirlo exclusivamente al navegador ni certificar60FPS. El stress CPU headless no descarta un cuello de render, transporte o scheduling. Este resultado mantiene pendiente el gate de rendimiento real y hace improcedente declarar la experiencia web plenamente aprobada.

El recorrido indicado no certifica audición, todas las combinaciones de controles bajo carga, partida humana completa, segunda derrota/reinicio, conservación de ajustes tras recarga web ni oclusión360° observada exhaustivamente. Las suites cubren esos contratos técnicos en diferente medida, pero no deben presentarse como interacción humana en navegador.

## Pendientes para cierre de calidad

- Medir navegador en primer plano y condiciones normales, separando tiempo simulado/real, CPU/render y carga; repetir preparación y fixture con enemigos/flechas. Registrar hardware/navegador y resultado, sin deducir60FPS del harness.
- Partida humana de principio a derrota y segunda partida: controles, apuntado/montaje/cámara, melee/dash, ventanas/READY, recogida, tienda y árbol. Confirmar legibilidad de ratas tras queso y escalado.
- Audio real con música/SFX independientes y volumen0; guardar/cargar preferencias y retención en mismo origen HTTP; verificar publicación RC tras copiar exactamente la build candidata.
- Ajustar balance/feel solo con observaciones reproducibles. Mantener etiqueta RC y estos límites hasta completar evidencia.

La revisión técnica no encuentra motivo para rehacer arquitectura o añadir sistemas. La publicación autorizada de una candidata puede continuar con este dictamen, conservando V1 recuperable y documentación honesta; los gates pendientes no se marcan aprobados por publicar.

## Addendum8 de octubre — ajuste solicitado

Revisado diff read-only tras petición de quitar atasco detrás del queso y duplicar espectral. La huella Rect2(-27,-3,54,28) ocupa solo suelo; TOWER_CLICK_RECT mantiene región visual previa. Navegación Player de seis puntos reemplaza greedy que podía quedarse en esquina; slide_motion permite deslizamiento de marcha, mientras dash sigue constrain_motion. Espectral base/fallback56, crítico falso y protección intacta. No nuevos defectos altos confirmados en fuente revisada. Posibles oclusiones de ratas detrás del queso permanecen criterio visual pendiente, no confundir huella libre con render aprobado.

Evidencia de reejecución del orquestador:119/0 regresión específica (56 rutas entre ocho puntos y casos franja/diagonal/dash/montaje); suites530/0 y Enemy/Economy PASS con asserts basados en nueva huella, sin conservar coordenadas obsoletas. Bot nuevo cinco oleadas+jefe52bajas,queso275,monedas228,cinco excursiones,tres compras. Stress120ticks299701µs CPU headless/325nodos, sin afirmarFPSweb. Editor Godot4.4.1 portable confirmado abierto sobre game.tscn; acceso F5 mediante lanzador nuevo. No se usa esa apertura como evidencia de audición o feel humano.

**Se mantiene GO para RC técnica del ajuste y actualización autorizada de GitHub; rendimiento web sostenido y evaluación humana permanecen pendientes.** El addendum corresponde al diff posterior a2d5aa57, cuyos cambios de source/build cerrará en commit el orquestador. Documentación no publica por sí misma ni cambia el dictamen de calidad previo.

## Verificación HTTP del ajuste (8 octubre 2026)

La build final se ha abierto en el navegador integrado de Codex mediante HTTP. Menú y partida arrancan; telemetría de PREP marca60FPS tanto al inicio como a los56 segundos de simulación, con65 nodos. El arquero llega por clic a(-70,-20) y cruza la franja trasera hasta(70,-20). Esto mejora la evidencia anterior de Brave automatizado a1FPS, pero no certifica carga máxima ni equilibrio/feel humano. No se ha modificado la cadencia del juego para ocultar el resultado anterior.

Godot4.4.1 portátil encontrado en Descargas y editor abierto con ventana `game.tscn - Cheesekeep — La última corteza - Godot Engine`. El lanzador EDITAR-EN-GODOT.cmd permite reabrirlo y F5 ejecuta el proyecto editable.

Cierre adicional observado en prueba HTTP: al perder el queso ya no se anuncia una reaparición pendiente. Derrota elimina las ratas, proyectiles y pickups; integración78/0 repetida con enemigo vivo y reaparición activa al caer la torre. Export final exit0. La candidata completa se publica en GitHub main; calidad a carga máxima y ajuste humano siguen abiertos.
