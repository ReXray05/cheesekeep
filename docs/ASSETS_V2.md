# ASSETS V2 — procedencia y reproducción

7 de octubre de 2026. Assets propios añadidos a la candidata2d5aa57; recursos V1 y sus créditos/licencias se conservan. No se han usado imágenes, sonidos, logos o controles extraídos de Windows.

## Cinco efectos nuevos

`assets/audio/dash.wav`, `melee.wav`, `ready.wav`, `spectral.wav`, `perfect.wav` son síntesis original procedural específica para Cheesekeep. Generador de trabajo: `work/create_v2_audio.py`, junto a la fuente `outputs/project`; usa Python estándar, math/random/wave/struct, pulso, seno, envolvente y ruido matemático con semilla42. No samples, voces, melodías comerciales o clips de terceros.

Formato de estos cinco WAV: **PCM mono16bits,16000Hz**. Dash0,14s; melee0,18s; ready0,20s; spectral0,30s; perfect0,15s. Barridos de frecuencia y ruido dan identidades distintas. Son efectos breves integrados mediante FeedbackController, con ocho voces SFX máximas; música y SFX tienen volúmenes independientes persistentes. Audición y volumen efectivo deben revisarse jugando en navegador; disponer de archivo no certifica calidad percibida.

Los WAV de V1 y música conservan su procedencia en `assets/audio/SOURCES.md` y generador `tools/generate_audio.py`. Su formato22050Hz y diez efectos se refieren a V1; no confundirlos con los cinco nuevos16000Hz. Los scripts de trabajo V2 son herramientas de generación, no dependencia de runtime; el juego distribuye los WAV finales y sus imports Godot.

## Boot splash

`assets/sprites/boot_splash.png`: ilustración propia procedural, RGB640×360, dibujada con Pillow mediante `work/create_v2_splash.py`. Rectángulos, polígonos y texto forman ventana original CHEESE/OS y queso pixelado; no es captura de Windows ni asset de terceros. Godot4.4.1 la usa como bootsplash sin filtrado, independiente del menú jugable. Se distribuye PNG final, sin requerir Pillow para jugar/exportar.

El texto usa **Press Start2P**, recurso tipográfico V1 conservado en `assets/fonts/PressStart2P-Regular.ttf`. Autoría: The Press Start2P Project Authors, copyright2012; licencia **SIL Open Font License1.1**, archivo íntegro `assets/fonts/OFL.txt`, Reserved Font Name Press Start2P. La tipografía es un recurso externo licenciado; la composición del splash es propia.

## UI y visuales

Ventanas, bordes, paleta y botones vintage se definen como StyleBoxFlat/Theme en `scripts/ui/vintage_theme.gd`; composición y glifos decorativos principales propios/ASCII, sin packs o skin ajeno. Actores, flechas, indicador, árbol, afterimages y pickups se dibujan mediante primitivas Godot sobre los controladores existentes. Efectos y audio son presentación: nunca crean daño o recursos. No claims de assets completamente nuevos para V1: esta nota documenta adiciones V2, preservando créditos anteriores.
