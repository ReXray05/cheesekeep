# ENEMY REVIEW

Variedad compacta tras MVP gate: básica preservada; rápida obliga a priorizar distancia y movimiento; escudada premia liberar verde; pesada anuncia una embestida bloqueada en una dirección; jefe combina armadura, embestida lenta y dos rápidas cada seis segundos.

Datos compartidos en `data/enemies.json`: las variantes heredan los valores básicos y sustituyen solo sus diferencias. No escalan HP automáticamente por oleada. El controlador conserva `configure`, `tick`, `take_hit`, `attack` y `died`; añade `summon_requested(kind, at)`. La raíz crea las invocaciones y limita enemigos simultáneos. El controlador no tiene procesamiento autónomo.

Las siluetas usan tamaño, bufanda, placa, corona y borde de protección además del color. La preparación de embestida muestra aro y línea roja; se fija dirección al iniciar el aviso. La colisión de embestida usa segmento para evitar saltar el objetivo; cada embestida daña como máximo una vez. Los impactos críticos rompen protección y dañan en ese mismo golpe.

Validación automatizada: carga de cinco configuraciones, armadura/recompensa única, preparación sin movimiento, dirección fija, contacto durante embestida y dos invocaciones por evento sin actividad tras muerte. La integración y legibilidad real de las variantes requieren playtest de la raíz; el informe no declara su balance definitivo ni satisfacción comprobada.
