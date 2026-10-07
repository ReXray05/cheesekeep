# GAME VISION — Arquero y torre de queso

Estado: visión confirmada. Descubrimiento cerrado; valores numéricos sujetos a balance.
Fecha: 7 de octubre de 2026.
Nombre del juego: por decidir.
Responsables: GAME DESIGN INTERVIEWER y orquestador principal.

## Decisiones confirmadas por el usuario

### Concepto, género y sensación
Juego 2D de defensa arcade y supervivencia por oleadas. Un arquero móvil protege una torre de queso frente a ratas que llegan desde todas las direcciones. Combina defensa táctica, acción frenética y humor. Se buscan partidas cortas y un ciclo entretenido. Fallar castiga poco al principio y mucho en oleadas avanzadas.

Prioridades del usuario: funcionamiento sólido, mucho game juice y ciclo jugable entretenido. La satisfacción de disparar sigue siendo el criterio central del proyecto.

### Plataforma y presentación
Estética retro 8-bit. Primera entrega para navegador. Campo de juego cuadrado, con interfaz a los laterales en una ventana horizontal. Windows queda como plataforma secundaria.

### Cámara y escenario
Vista desde arriba con presentación isométrica. Arquero visible. Cámara que sigue al arquero. Enemigos pueden llegar por todos los lados.

### Movimiento, controles y refugio
Movimiento hacia el punto indicado mediante clic. Apuntado libre que sigue el cursor prácticamente de inmediato. Combate controlado solo con ratón.

Confirmado: clic izquierdo para movimiento e interacción; mantener/soltar clic derecho para cargar/disparar.

La carga no se puede cancelar. Clicar la torre permite subirse a ella. Desde la torre el arquero no recibe daño, pero la torre se rompe más rápidamente. Clicar la torre ordena aproximarse y subir al llegar cerca. Clicar el suelo baja y ordena desplazarse al punto. Se puede mover durante la carga, con menor velocidad. El multiplicador concreto de daño a la torre es un parámetro de balance.

### Core loop confirmado
Moverse y elegir posición → apuntar → mantener para cargar → buscar el sweet spot o arriesgar sobrecarga → soltar y disparar → dañar o matar ratas → obtener monedas → comprar munición y reparar queso → superar oleada → elegir mejora → afrontar mayor presión.

### Arco, carga y triángulo
Un triángulo fantasma se proyecta sobre el suelo. Su vértice nace en la punta del arco; su base apunta hacia el objetivo y representa el margen de posibles impactos. Comunica potencia, alcance, dispersión y precisión.

- Carga baja: triángulo corto y ancho, naranja; poca potencia y mayor margen de error.
- Sweet spot: triángulo más largo y estrecho, verde; requiere soltar en un instante preciso.
- Sobrecarga: rojo y vibración; aumenta la potencia pero empeora la precisión.

La carga modifica velocidad, daño, alcance y precisión. Los tiempos y curvas son parámetros abiertos que se ajustarán durante el prototipo.

### Riesgo y recompensa
Superar la carga óptima permite ganar potencia y penetración. Primero aparecen temblor y pérdida de precisión; después crece la probabilidad de rotura. Una rotura provoca un pequeño periodo de recuperación para arreglar el arco. La advertencia usa rojo y vibración. No se ha establecido coste monetario para reparar el arco; la reparación pagada confirmada corresponde a la torre de queso.

### Flechas
Física arcade. Munición limitada: la última corrección del usuario sustituye la opción de munición infinita. Flechas comprables con monedas. Desaparecen al impactar o salir de pantalla. Una flecha sobrecargada atraviesa varios enemigos y desaparece al agotar su capacidad de penetración.

### Enemigos y daño
Ratas básicas, rápidas, pesadas, con escudo y algún jefe. Atacan tanto al arquero como a la torre. Tienen puntos de vida; el daño recibido depende de la potencia del disparo. Los golpes críticos pueden romper escudos y armadura. Soltar en la ventana verde genera un crítico que rompe escudos y armadura. No se han solicitado zonas corporales diferenciadas.

Las variantes deben introducir decisiones de juego, además de estadísticas diferentes, conforme al alcance inicial solicitado. Sus comportamientos concretos siguen pendientes.

### Oleadas, economía y habilidades
Supervivencia por oleadas. Monedas por bajas y premios por oleadas. Tienda de flechas siempre disponible. Reparar el queso cuesta monedas.

Al final de cada oleada se ofrece una elección de habilidades, organizada como árbol. Categorías: arco, flechas, movilidad y torre. Al completar cada oleada se elige una mejora gratuita entre varias. Las ramas propuestas de arco, flechas, movilidad y torre están aceptadas. Los valores y requisitos concretos serán datos ajustables.

### Victoria, derrota y reaparición
El objetivo es conseguir que la torre aguante el máximo tiempo posible. El arquero puede revivir mientras la torre siga en pie. La destrucción de la torre termina la partida. Supervivencia infinita sin victoria final. Al perder se conserva automáticamente un porcentaje de las mejoras adquiridas según las monedas restantes; con cero monedas no se conserva ninguna. Los umbrales se ajustarán durante el balance.

Tiempo y posición de reaparición son parámetros de prototipo. La tienda no pausa el combate. Entre oleadas hay pausa para comprar y elegir mejora; el jugador inicia manualmente la siguiente.

### Interfaz, tutorial y audio
Interfaz limpia. Vida del jugador, munición y vida de la torre siempre visibles. Números de daño al impactar. Tutorial incluido. Sonidos y música retro.

### Game juice
Feedback abundante: sacudidas de cámara, vibraciones, animaciones, deformación de enemigos, arco y flechas bajo carga intensa; aberración cromática en ocasiones. El feedback debe permitir leer la carga y las amenazas. Intensidades, momentos y opciones para reducir efectos están pendientes.

### Alcance inicial y validación
Se mantiene el desarrollo por etapas solicitado. Primero se valida una pantalla de prueba del arco con apuntado, carga, triángulo, sobrecarga, flecha, un enemigo, daño y reinicio. El prototipo inicial debe adaptar esa prueba al movimiento y perspectiva confirmados; no asumirá gravedad balística, porque la respuesta actual pide física arcade.

Después se integra el MVP con movimiento, refugio en torre de queso, oleadas, munición limitada, monedas, compra de flechas, reparación, una mejora, muerte/reaparición, derrota y reinicio. La variedad, el árbol ampliado, arte y audio final llegan después de validar el núcleo.

El prototipo debe ser funcional y recibir feedback suficiente para evaluar los disparos. El pulido intenso se amplía tras superar la revisión de la mecánica central. No se declarará divertido sin pruebas de juego.

## Propuestas todavía abiertas

Ninguna propuesta de esta sección se considera confirmada.

### Ejemplos de ramas del árbol para discutir
- Arco: carga rápida frente a tensión sostenida, con ventajas distintas de cadencia y sobrecarga.
- Flechas: penetración reforzada frente a daño concentrado, para grupos o ratas pesadas.
- Movilidad: desplazamiento más rápido frente a mejor capacidad de disparar en movimiento.
- Torre: refuerzo del queso frente a reparaciones más eficientes.

La dirección de estas ramas fue aceptada; sus estadísticas y desbloqueos son propuestas de balance. Cada rama deberá aportar una decisión comprensible y ajustarse al MVP.

### Regla de conservación para pruebas

Propuesta numérica inicial: porcentaje = mínimo(100 %, monedas / 200). Se conserva la parte entera de ese porcentaje multiplicado por las mejoras adquiridas, empezando por las más antiguas para respetar requisitos. El dinero se consume y cada partida inicia con su presupuesto base. Es un valor de balance provisional, no un umbral solicitado por el usuario.

### Parámetros propuestos para pruebas posteriores
Tiempo hasta sweet spot y ancho de su ventana; comienzo de sobrecarga; curva de probabilidad de rotura; recuperación; daño y velocidad; dispersión; penetración; alcance; vida y velocidad de ratas; capacidad de munición; recompensas; precios; reparación; daño extra a torre al refugiarse; reaparición; ritmo y composición de oleadas.

## Puerta de desarrollo
No se han creado código, escenas, assets ni proyecto Godot. La entrevista ha finalizado. SPEC, arquitectura y plan se redactan antes de crear el proyecto; PLAN CRITIC revisará el plan antes del desarrollo. Godot 4.x y GDScript son la preferencia técnica original.

# Evolución V2 — decisiones confirmadas (entrevista cerrada)

Esta sección sustituye reglas incompatibles de V1; el texto histórico se conserva. GAMEPLAY > FEEL > CLARIDAD > ROBUSTEZ > CONTENIDO > EFECTOS. Se evoluciona el proyecto existente.

CONFIRMADO: alternar excursiones breves y combate móvil. No forzar salida con temporizadores/castigos arbitrarios. Monedas por bajas físicas; flechas falladas recuperables. Cargas bajas se clavan al final del cono; verdes y superiores continúan más allá del indicador y, si fallan, se recuperan en el último punto accesible del terreno. Recursos permanecen entre oleadas hasta recoger; premio de oleada sigue automático. Recogida cercana básica cómoda y mejora magnética. No bonus económico adicional por estar fuera en V2.

CONFIRMADO: melee con botón central, barrido corto hacia cursor, múltiples ratas, daño moderado, empuje claro y pausa entre golpes. Movimiento algo más lento al golpear, sin melee durante carga. Bajas melee dan monedas y algunas flechas físicas garantizadas. Melee funciona con toda eficacia durante rotura del arco. Recuperación viable con cero flechas/cero monedas.

CONFIRMADO: secuencia naranja → verde → rojo → morado → rojo breve → rotura garantizada al excederse. Sin rotura aleatoria previa. Morado es la habilidad de área integrada en la carga, sin botón/recurso separado: una flecha espectral gigante de franja constante, daño moderado, respeta protección, atraviesa todas las ratas una vez por rata y consume una flecha. Recuperable si falla. Verde sigue siendo crítico que rompe protección.

CONFIRMADO: movimiento configurable WASD/clic, disparo izquierdo/derecho; movimiento/interacción usa el botón contrario, central melee. E interactúa cerca de torre en WASD; clic torre también disponible. Espacio dash corto y ágil en dirección de movimiento o cursor estando quieto, corrección ligera, invulnerabilidad breve inicial atravesando ratas, obstáculos sólidos bloquean. Carga continúa; melee solicitado durante dash se ejecuta al terminar si no hay carga. Espacio desde torre baja y encadena dash; no monta automáticamente al pasar cerca.

CONFIRMADO: ajustes persistentes (movimiento, disparo, música/SFX separados, ayuda, efectos); pausa teclado/botón integrada, menú principal y boot splash personalizados; UI original inspirada en sistemas Windows antiguos; árbol visual de ramas combinables con requisitos y especializaciones que cambian estilo. Una mejora gratuita por oleada, retención automática por porcentaje del saldo al perder, tiendas sin pausa. Perfect shot, BREAK y READY cortos y reconocibles. Cámara suave y rápida. Corrección real de aim, proyectiles y geometría de torre/ratas.

ABIERTO PARA BALANCE/PLAYTEST, no para nueva entrevista: cifras de dash/melee/morado/radios, tiempos de ventanas, daño, precios y contenido exacto del árbol dentro de estas reglas. Se ajustan con pruebas y revisión sin añadir sistemas ajenos.

