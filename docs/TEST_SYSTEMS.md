# TEST SYSTEMS — MVP

7 de octubre de 2026. Godot 4.4.1 stable, ejecución headless de `tests/systems_tests.gd`, APPDATA aislado dentro de work/systems. **47 comprobaciones, cero fallos, salida 0 y sin errores de ejecución.**

Se comprobaron: inicio duplicado rechazado; seis spawns básicos dentro del anillo 240–300; final de oleada únicamente tras vaciar pendientes/vivos; premio único; segunda oleada de ocho; techo de 80 y liberación de una plaza sin ráfaga atrasada. Economía: saldo insuficiente/negativo, compra atómica, consumo de una flecha y recompensas positivas.

Mejoras: tres ofertas estables, raíces solamente en MVP, prerrequisitos, rangos máximos, rechazo de IDs desconocidos e historia inválida, reconstrucción sin mutar bases ni acumular efectos al repetir. Configuración: 12 nodos, cuatro raíces, dependientes ocultos mientras `expanded=false`. Cada adquisición es una entrada de historia; también los rangos repetidos cuentan para conservación.

Persistencia: cero dinero conserva cero, 99 monedas de cuatro adquisiciones conserva una, 100 conserva dos, 200 o más conserva cuatro. Mantiene prefijo legal, padre antes de hijo. Se escribió, leyó y reemplazó un archivo real versionado; JSON corrupto, versión de tipo inválido e IDs/prerrequisitos incorrectos se recuperan sin errores. Test elimina su archivo aislado al terminar.

Números efectivos nuevos: primera oleada 6, +2 por oleada; intervalo 1,1 s menos 0,07 por oleada hasta 0,4 s; premio `8 + 2*wave` (primera 10). Tienda por defecto 10 flechas/6 monedas. Retención `floor(N*clamp(coins/200,0,1))`, umbral provisional ajustable. WaveManager no posee `_process`; raíz llama tick y aporta conteo de vivos. EconomyManager recibe sección economy de configuración. Las reparaciones y reinicio de saldo corresponden a raíz.

Fuera de esta prueba: compras desde UI en combate, daño extra en torre, guardado real del navegador y disfrute del ciclo. Se requiere integración/playtest. El nodo expandido piercing añade `bow.pierce_bonus`; el arco deberá aplicarlo antes de habilitarlo en la entrega ampliada.
