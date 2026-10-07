"""Regenerate original Cheese Keep retro PCM audio; only Python standard library."""
from pathlib import Path
import math
import random
import struct
import wave

RATE = 22050
DEST = Path(__file__).resolve().parents[1] / "assets" / "audio"
DEST.mkdir(parents=True, exist_ok=True)


def write(name, samples):
    values = [max(-0.98, min(0.98, sample)) for sample in samples]
    values[0] = values[-1] = 0.0
    with wave.open(str(DEST / (name + ".wav")), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(RATE)
        output.writeframes(b"".join(struct.pack("<h", int(value * 32767)) for value in values))


def pulse(phase):
    return 1.0 if phase % 1.0 < 0.25 else -1.0 / 3.0


def sound(name, seconds, low, high, noise=0.0, melody=None):
    rng = random.Random(349 + len(name))
    phase = 0.0
    result = []
    for index in range(int(seconds * RATE)):
        t = index / RATE
        u = t / seconds
        frequency = low + (high - low) * u
        if melody:
            frequency = melody[min(len(melody) - 1, int(u * len(melody)))]
        phase += frequency / RATE
        envelope = min(1.0, t / 0.005) * (1.0 - u) ** 1.7
        result.append(envelope * (0.42 * pulse(phase) + noise * rng.uniform(-1.0, 1.0)))
    write(name, result)


sound("fire", 0.14, 720, 130, 0.15)
sound("impact", 0.12, 210, 60, 0.22)
sound("critical", 0.24, 880, 240, 0.09, [880, 1174, 1568, 784])
sound("blocked", 0.15, 180, 90, 0.04)
sound("snap", 0.36, 760, 50, 0.31)
sound("damage", 0.22, 190, 55, 0.12)
sound("purchase", 0.18, 600, 900, melody=[659, 988])
sound("wave_start", 0.4, 350, 700, melody=[330, 440, 659])
sound("wave_clear", 0.55, 400, 900, melody=[523, 659, 784, 1047])
sound("over", 0.65, 600, 100, melody=[392, 330, 262, 196])

# Forty half-second beats: original melody with a soft bass ostinato.
# Each note is enveloped to zero at its boundary, including the loop seam.
notes = [64, 67, 69, 67, 64, 62, 60, 62, 64, 67, 72, 71, 69, 67, 64, 62,
         60, 64, 67, 64, 62, 65, 69, 65, 64, 67, 69, 72, 71, 67, 64, 62,
         60, 62, 64, 67, 69, 67, 64, 62]
bass = [48, 48, 45, 45, 53, 53, 43, 43]
result = []
for index in range(20 * RATE):
    t = index / RATE
    beat = int(t / 0.5)
    local = t % 0.5
    envelope = min(1.0, local / 0.015) * max(0.0, 1.0 - local / 0.5) ** 1.8
    lead_hz = 440.0 * 2 ** ((notes[beat] - 69) / 12)
    bass_hz = 440.0 * 2 ** ((bass[(beat // 2) % len(bass)] - 69) / 12)
    lead = pulse(local * lead_hz)
    low = math.sin(math.tau * bass_hz * local)
    tick = math.sin(math.tau * 95 * local) * math.exp(-local * 48)
    result.append(envelope * (0.17 * lead + 0.22 * low) + 0.035 * tick)
write("music", result)
print(f"Generated 11 original PCM WAVs: {sum(p.stat().st_size for p in DEST.glob('*.wav'))} bytes")
