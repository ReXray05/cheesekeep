# Audio original

Todos los archivos WAV se sintetizan específicamente para Cheese Keep mediante `tools/generate_audio.py`, usando únicamente seno, pulso, envolventes y ruido matemático con semilla. Melodía y secuencia de bajo originales; no contiene muestras, canciones, voces ni clips de terceros.

Formato: PCM mono, 16 bits, 22.050 Hz. Diez efectos cortos y música de 20 segundos. Inicio y final de cada WAV son cero; la música tiene envolvente por nota para unión de loop sin salto. Puede regenerarse con Python estándar: `python tools/generate_audio.py`. Total generado: 1.015.222 bytes (aproximadamente 0,97 MiB), inferior al presupuesto de 2 MB.

Integración: efectos a −12 dB, música a −22 dB, máximo ocho voces de efectos más una de música. Música utiliza AudioStreamWAV LOOP_FORWARD. No se reproduce al configurar; primer gesto que llama wave_start o fire habilita audio. La opción de efectos visuales es independiente del audio.
