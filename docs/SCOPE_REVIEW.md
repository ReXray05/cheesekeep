# SCOPE REVIEW — revisión de alcance y diseño

Fecha: 7 de octubre de 2026. Roles: SCOPE GUARDIAN y GAME DESIGN REVIEWER.
Fuentes: GAME_VISION.md, PLAN.md y PLAN_REVIEW.md.
Estado: alcance revisado; evaluación de gameplay pendiente de un prototipo ejecutado.

## Clasificación

| Prioridad | Contenido | Criterio |
| --- | --- | --- |
| NOW | Arquero móvil, cámara y apuntado libre; clic izquierdo mueve, derecho carga/suelta; penalización de movimiento cargando | Adaptación mínima a los controles confirmados; probar juntos movimiento y puntería |
| NOW | Triángulo naranja/verde/rojo, ventana crítica, dispersión coherente, sobrecarga y recuperación | La representación debe comunicar el resultado real de cada disparo |
| NOW | Flecha arcade, una rata básica, impacto/vida, números discretos y reinicio | Permitir repetir y comparar disparos sin economía ni contenido adicional |
| NOW | Comprobar arranque web y estabilidad del input | Detectar temprano incompatibilidades sin convertir la prueba en infraestructura adicional |
| LATER, tras core gate | Torre/refugio, oleadas, munición limitada, monedas, tienda sin pausa y reparación | Completar el loop de defensa después de validar que disparar funciona |
| LATER, MVP | Primera elección gratuita, muerte/reaparición, derrota/reinicio y conservación de mejoras | Probar una progresión pequeña y retención conforme a la visión; cifras provisionales ajustables |
| POST-CORE, tras playtest MVP | Rápidas, pesadas, escudadas y jefe; árbol compacto | Cada variante o rama debe cambiar una decisión observada durante juego |
| POST-CORE | Arte retro final, audio/música, tutorial y juice ampliado | Intensificar satisfacción sin perder lectura del triángulo y de las amenazas |
| POST-MVP | Exportación nativa Windows adicional | Navegador es la primera plataforma confirmada |
| REJECT para este alcance | Campaña extensa, multiplayer, crafting, inventario complejo, árbol enorme y variantes sin diferencia de comportamiento | No contribuyen al MVP solicitado |

## Riesgos de diseño que se evaluarán jugando

- El mismo cursor ordena movimiento y apunta: comprobar si disparar mientras se camina permite decisiones tácticas sin obligar a pelear con el control.
- La ventana verde debe premiar precisión y la roja ofrecer potencia/penetración con peligro legible. Ninguna opción debe dominar todos los disparos.
- El triángulo se evalúa por su correspondencia con dispersión y alcance, no por su apariencia aislada.
- Refugiarse intercambia seguridad del arquero por riesgo para el queso; el intercambio debe ser visible antes de castigar al jugador.
- Munición, reparación y retención compiten por monedas. Revisar que ahorrar para la próxima partida no convierta comprar en una mala decisión permanente.
- La tienda abierta y el juice abundante deben preservar la lectura del combate y no generar movimiento accidental.

## Gate y límites

Aplicar las correcciones del PLAN CRITIC y construir solo NOW. No añadir tienda, oleadas, árbol, jefe, música ni arte final antes de la prueba independiente del arco. Los valores de carga, rotura, daño, precios y retención son hipótesis de balance; no bloquean la construcción del prototipo por carecer de ajuste definitivo.

El GAME DESIGN REVIEWER espera una versión ejecutable para examinar primeros disparos, contraste naranja/verde/rojo, impacto, recuperación y repetición. Aún no hay evidencia para declarar la mecánica divertida. Después del core gate se revisará el MVP y se anotarán problemas concretos con pasos y gravedad.
