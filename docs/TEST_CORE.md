# TEST CORE — Resultado automático

7 de octubre de 2026. TEST AGENT. Ejecutado sobre el prototipo integrado con Godot **4.4.1 stable**, en modo headless, mediante `res://tests/core_tests.gd`. APPDATA temporal situado dentro del workspace para evitar permisos sobre el perfil del sistema.

**Resultado: 835 comprobaciones, 0 fallos, salida 0.** Sin errores de scripts durante esta ejecución.

Cobertura: transición/carga y crítico verde; emisión única al soltar; 400 disparos distribuidos entre cinco tiempos de carga y dirección diagonal, verificando que cada extremo alcanza la base visible y queda dentro de sus límites; dispersión a ambos lados; sobrecarga penetrante sin crítico; reset y cooldown; segmento de flecha rápida limitado al alcance; target duplicado sin consumir penetración; protección rota por crítico; muerte y recompensa única; movimiento reducido al 65% cargando y movimiento detenido al morir.

Monte Carlo de rotura: 1.000 cargas de hasta 2,2 segundos por framerate, semillas reproducibles. Fracción rota: **30 FPS 34,7%; 60 FPS 38,0%; 144 FPS 34,3%**. Todas están dentro de ±7 puntos del valor analítico aproximado 34,75%; diferencia entre extremos 3,7 puntos. Esta tolerancia contempla variación aleatoria y discretización. No constituye una medida de rendimiento.

No evaluado aquí: input físico del navegador, foco/clic en UI, puntería con cámara, percepción del triángulo, satisfacción, audio, exportación, oleadas, economía, tienda, árbol o retención. Son pruebas de reglas del núcleo y no autorizan por sí solas superar el CORE MECHANIC GATE.
