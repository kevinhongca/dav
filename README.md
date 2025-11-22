# Digital Audio Visualizer

This project implements a real-time audio visualizer using a microphone, FFT module, graphics controller, ping-pong RAM, and a VGA display pipeline. The system captures audio, computes its frequency spectrum, and displays a live histogram of frequency magnitudes on a VGA monitor.

## System Overview

- Audio signals from the **microphone** are captured and sent into the **ADC**, where they are converted from analog to digital samples.
- These digital samples are processed by the **FFT module** to extract their frequency components.
- The resulting frequency data is temporarily stored in **RAM**, allowing other modules to access it.
- The **graphics controller** reads the frequency content and generates the corresponding pixel data for the audio histogram visualization.
- This pixel data is written into the **ping-pong RAM**, providing double-buffered frame storage for smooth updates.
- The **VGA driver** continuously reads pixel data from the active RAM buffer using its internal timing counters and outputs the synchronized VGA signals needed to display the real-time histogram on the monitor.

## Block Diagram

<p align="center">
  <img src="dav outline.png" width="80%" alt="Digital Audio Visualizer Block Diagram">
</p>
