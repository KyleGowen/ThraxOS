# Thraximundar machine context

Observed locally on 2026-07-31. This file intentionally omits serial numbers, network addresses, and unique device instance paths.

## Hardware

| Component | Observed value |
| --- | --- |
| System | GMKtec NucBox G3 Plus, x64 |
| CPU | Intel Processor N150, 4 cores / 4 threads; Intel specifies up to 3.6 GHz, 6 MB cache, 6 W base power |
| Memory | 16 GiB DDR4-3200, one observed module |
| Graphics | Intel Graphics; Parsec Virtual Display Adapter also installed |
| Storage | AirDisk 1 TB NVMe SSD, healthy; about 846 GB free when inventoried |
| Display | Vizio E32-D1, observed at 1920×1080 |
| Audio | Generic USB Audio Device |
| Firmware | American Megatrends 5.27, firmware date 2024-11-06 |

CPU reference: [Intel Processor N150 specifications](https://www.intel.com/content/www/us/en/products/sku/241636/intel-processor-n150-6m-cache-up-to-3-60-ghz/specifications.html).

## Operating system

- Microsoft Windows 11 Pro, 64-bit.
- Version `10.0.26200`, build `26200` at inventory time.
- Primary volume: `C:`, NTFS.
- Git for Windows 2.53.0 is installed.
- Node.js is not on the normal PATH; Codex provides a bundled Node runtime when needed.

## Intended role

Thraximundar is a dedicated rhythm-game host and should favor predictable latency, stable input, recoverable configuration, and remote observability. Do not apply generic “PC optimization” changes without evidence and explicit approval; audio, graphics, USB, power, and scheduler changes can affect play quality or remote availability.
