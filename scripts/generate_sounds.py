#!/usr/bin/env python3
"""Dashink ses efektleri ve müzik döngüsü: assets/sounds/*.wav (22.05 kHz, 16 bit, mono).

Dış kaynak/lisans gerektirmesin diye sesler burada sentezlenir.
Kullanım: python3 scripts/generate_sounds.py
"""

import math
import random
import struct
import wave
from pathlib import Path

RATE = 22050
OUT = Path(__file__).resolve().parent.parent / 'assets' / 'sounds'


def write(name, samples, level=0.8):
    peak = max(1e-9, max(abs(s) for s in samples))
    gain = level / peak
    with wave.open(str(OUT / f'{name}.wav'), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(
            struct.pack('<h', int(max(-1, min(1, s * gain)) * 32767))
            for s in samples))


def tone(freq, dur, release=0.08, sweep=0.0, harmonics=((1, 1.0), (2, 0.25))):
    n = int(RATE * dur)
    out, phase = [], 0.0
    for i in range(n):
        t = i / RATE
        f = freq * (1 + sweep * t / dur)
        phase += 2 * math.pi * f / RATE
        a = min(1.0, t / 0.004) * math.exp(-t / release)
        out.append(a * sum(g * math.sin(phase * h) for h, g in harmonics))
    return out


def noise(dur, release=0.05, lowpass=0.2):
    n = int(RATE * dur)
    out, prev = [], 0.0
    for i in range(n):
        t = i / RATE
        prev += lowpass * (random.uniform(-1, 1) - prev)
        out.append(prev * min(1.0, t / 0.003) * math.exp(-t / release))
    return out


def concat(*parts):
    out = []
    for p in parts:
        out.extend(p)
    return out


def mix(a, b):
    n = max(len(a), len(b))
    return [(a[i] if i < len(a) else 0) + (b[i] if i < len(b) else 0) for i in range(n)]


def main():
    random.seed(7)
    OUT.mkdir(parents=True, exist_ok=True)
    write('tap', tone(660, 0.08, release=0.025))
    write('coin', concat(tone(988, 0.07, 0.04), tone(1319, 0.18, 0.08)))
    write('draw', noise(0.12, release=0.06, lowpass=0.08), level=0.45)
    write('fall', mix(tone(440, 0.6, 0.35, sweep=-0.6), noise(0.25, 0.08, 0.05)))
    write('record', concat(tone(523, 0.12, 0.08), tone(659, 0.12, 0.08),
                           tone(784, 0.12, 0.08), tone(1047, 0.45, 0.25)))
    write('purchase', concat(tone(784, 0.09, 0.05), tone(1175, 0.25, 0.12)))

    # Müzik: 8 saniyelik sakin pentatonik döngü (bas + melodi).
    bpm, beats = 120, 16
    beat = 60 / bpm
    notes = [523, 587, 659, 784, 880]
    melody = []
    for i in range(beats):
        f = notes[(i * 3 + (i // 4)) % len(notes)]
        melody.extend(tone(f, beat, release=0.18, harmonics=((1, 1.0), (3, 0.1))))
    bass = []
    for i in range(beats // 2):
        f = [131, 165, 147, 196][(i // 2) % 4]
        bass.extend(tone(f, beat * 2, release=0.6, harmonics=((1, 1.0), (2, 0.4))))
    write('music', mix([s * 0.5 for s in melody], bass), level=0.5)


if __name__ == '__main__':
    main()
