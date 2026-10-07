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

# SCOPE REVIEW V2 — alcance autorizado

Fecha: 7 de octubre de 2026. SCOPE GUARDIAN, solo análisis/documentación. La entrevista V2 está cerrada; los límites V1 anteriores son historia y no impiden implementar lo ya solicitado para V2.

| Clasificación | Contenido | Límite de aceptación |
| --- | --- | --- |
| NOW V2 | Aim estable, vuelo verde+, recuperación de fallos, huella/oclusiones de torre y cámara suave | Corregir geometría real sin física balística ni navegación compleja añadida |
| NOW V2 | WASD/clic, tiro izquierdo/derecho, opuesto interacción, central melee, E torre, Espacio dash y Esc/botón pausa | Todas combinaciones y ajustes persistentes; UI sin comandos fantasma |
| NOW V2 | Melee multiobjetivo, empuje, lentitud breve y cooldown; útil roto; flechas garantizadas por sus bajas | Recuperar combate con ceroammo/saldo incluso contra protección; no reemplazar arco como opción principal |
| NOW V2 | Dash corto, corrección ligera, iFrames iniciales, bloqueo por sólidos; desde torre baja+dash | Conserva carga; melee pendiente solo al terminar y si no carga; sin montaje automático |
| NOW V2 | Monedas de bajas y flechas falladas físicas, recogida cómoda y mejora magnética | Persisten entre oleadas; fusionar conservando recursos; torre no recoge remotamente |
| NOW V2 | Naranja/verde/rojo/morado/rojo breve/rotura garantizada; espectral integrada | Un disparo, una flecha, corredor constante, daño moderado/protección, atraviesa todos una vez; sin RNG |
| NOW V2 | Menú, pausa, ayuda/ajustes, splash original y UI vintage propia | Una autoridad de estados, tienda sin pausa, HUD vital visible; música/SFX separados |
| NOW V2 | Árbol visual combinable con requisitos y especializaciones; migración/retención | Preservar IDs y rangos válidos, una elección por oleada, sin exclusiones añadidas |
| NOW V2 | Perfect/BREAK/READY, señales dash/melee/pickup y balance cinco oleadas+jefe | Efectos acotados y legibles; gameplay/feel por delante de decoración |
| LATER dentro V2 | Arte/polish UI definitivo y ajuste fino de cámara, tiempos/daño/radios | Después de gates del núcleo; no confundir orden de ejecución con recorte de alcance solicitado |
| POST-MVP | Export Windows adicional, más variantes/contenido más allá de las cinco existentes, optimización compleja | Solo si nuevas pruebas/necesidad lo justifican; no frenar release web |
| REJECT | Temporizador/castigo por quedarse en torre o bonus monetario extra al salir | Contrario a incentivos físicos elegidos |
| REJECT | Recogida automática al terminar oleada, caducidad de pickups, pérdida por techo, magnetismo montado | Contrario a permanencia/excursiones confirmadas |
| REJECT | AOE con botón o recurso separado, morado rompe armadura, límite arbitrario de ratas atravesadas, rotura RNG | Contrario a modalidad integrada de carga y especialidad verde |
| REJECT | Cancelación manual por dash/pausa/cambio de controles, munición infinita/regalo al revivir | Contrario a carga no cancelable y recuperación mediante combate |
| REJECT | Ramas mutuamente excluyentes, crafting, campaña, multiplayer, inventario complejo | No solicitado o incompatible con ramas combinables |

No se abren nuevas decisiones de diseño. Las cifras en BALANCE V2 son hipótesis; ajustar daño mínimo protegido, radios/cooldowns y ventanas no añade sistemas. El menú no concede restauración de recursos ni otra fórmula de retención. Conservar flexibilidad técnica para cumplir contratos sin convertir el plan en una reescritura.

Gate de alcance: implementar NOW por dependencias de PLAN_REVIEW V2, comprobar cada integración y después completar polish solicitado. No se aprueba todavía experiencia ni rendimiento: hacen falta sesiones ejecutadas, recuperación ceroammo observable y revisión independiente web. No hay extras necesarios para cumplir el objetivo.
