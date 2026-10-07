# PLAN REVIEW — revisión independiente

Fecha: 7 de octubre de 2026. Responsable: PLAN CRITIC (no programa).
Documentos revisados: GAME_VISION, SPEC, ARCHITECTURE y PLAN.
**Resultado: PASS WITH FIXES.** La secuencia protege el arco antes de ampliar contenido. Aplicar las cinco correcciones siguientes a los contratos antes de implementar; después se puede iniciar el prototipo. No es aprobación del gameplay ni de una build todavía inexistente.

## Hallazgos y correcciones obligatorias

1. **ALTO — Retención desactualizada.** SPEC §8, ARCHITECTURE §7 y PLAN todavía presentan la regla como una pregunta pendiente, aunque el usuario ya confirmó conservación automática de un porcentaje según dinero. Adoptar como balance provisional la fórmula documentada en visión: `p = clamp(monedas / 200.0, 0, 1)`; `K = floor(N * p)`. Conservar las primeras K adquisiciones en orden histórico, incluidos incrementos de rango. Comprar un nodo requiere que sus padres ya estén adquiridos, de modo que cualquier prefijo conserve requisitos. Dinero consumido al reiniciar y presupuesto inicial restablecido deben marcarse como propuesta de balance, no confirmación literal. Probar 0 monedas, cantidad baja, 200+, rangos, dependencias y archivo inválido. Mostrar porcentaje y cantidad antes de reiniciar.

2. **ALTO — Input puede quedarse cargando o cancelarse por daño ordinario.** La liberación de una carga ya capturada debe procesarse globalmente, incluso sobre panel lateral o fuera del campo. Perder foco exige reconciliar el botón al regreso; no inventar un disparo tardío tras muerte/rotura/derrota. Normalizar los estados físicos de botón antes de aceptar una nueva pulsación. ARCHITECTURE dice interrupción «por daño»: cambiar por muerte, rotura o fin de partida; un golpe corriente no cancela carga. Clic izquierdo de compra se consume en UI y no genera movimiento. Pruebas específicas: cargar → comprar → soltar; salir del campo → soltar; perder foco → regresar; morir cargando → revivir.

3. **ALTO — Geometría, escala y dispersión deben compartir contrato.** Definir un único tamaño lógico del SubViewport y convertir valores de velocidad/rango/arena si cambia a 360 × 360; no mezclar cifras pensadas para 720. Convertir cursor local usando transformación real de cámara y escala del campo. Seleccionar uniformemente un punto de la base visible, sin desviación oculta añadida; comprobar que rango y extremo coinciden, incluida dirección diagonal. La cámara y shake no afectan HUD. Probar mover/cargar/redimensionar con objetivos en cuatro direcciones. Critico verde rompe protección; penetración roja consume impactos, sin conceder crítico ni repetir daño a la misma rata.

4. **MEDIO — Contratos de loop deben quedar cerrados sin inflar prototipo.** Mantener tienda como panel superpuesto sin pausar; compra y reparación validan saldo/utilidad y cobran una vez. Montado, el arquero es inmune y todas las ratas tienen un objetivo válido: queso; anunciar el multiplicador extra. Oleada termina solo sin spawns pendientes ni ratas vivas; premio y elección una vez, siguiente manual. Muerte reinicia carga pero no saldo/munición; destrucción del queso vence a selección/reaparición simultánea. Estos casos pertenecen al MVP, después del gate del arco.

5. **MEDIO — Exportación y gate deben probarse temprano y con evidencia.** Identificar pareja motor/templates compatible (4.4.1 y 4.1.1 no se mezclan) y probar arranque HTTP del proyecto mínimo antes de invertir en contenido. Guardar herramientas/templates descargadas en `work/`; la build entregable en `outputs/`. Core gate requiere interacción ejecutada, no solo análisis de scripts: apuntado, verde/rojo, liberación inmediata, impacto, rotura y repetición. Si falta ejecución real, marcar gate pendiente y corregir el bloqueo antes de oleadas/tienda/árbol. No afirmar satisfacción subjetiva con tests automáticos.

## Plan corregido exacto

Actualizar los contratos anteriores → inicializar Git/proyecto y comprobar export mínima → M01 apuntado/movimiento/cámara → M02 carga/input → M03 triángulo/rotura/flecha → M04 una rata/daño → M05 revisión independiente y corrección de defectos altos → M06 torre/oleada → M07 economía sin pausa → M08 elección/derrota/reaparición/retención → playtest MVP → variedad compacta → juice/arte/audio/tutorial → balance → revisión independiente y build web probada.

**Scope guard:** antes de M05 solo formas provisionales, un enemigo, feedback mínimo y reinicio. Árbol ampliado, música, jefe, arte final y aberración cromática esperan. No hay hallazgo que exija cambiar el motor o añadir infraestructura.
