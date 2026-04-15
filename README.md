# Ultrazvukový měřič vzdálenosti – HC-SR04

Projekt v rámci předmětu DE1, digitální návrh na FPGA (Nexys A7 50).  
Měření vzdálenosti pomocí ultrazvukového senzoru HC-SR04 se zobrazením výsledku na 7-segmentovém displeji.

---

## Popis projektu

Zařízení vyšle ultrazvukový pulz pomocí senzoru HC-SR04, změří dobu návratu echa a vypočítá vzdálenost. Výsledek je zobrazen v centimetrech na 7-segmentovém displeji desky Nexys A7. Měření se spouští stiskem tlačítka.

---

## Blokové schéma

![Blokové schéma](ultsound_top.png)

### Moduly

| Modul | Popis |
|---|---|
| `debounce` | Odstraňuje zákmity tlačítka (`btnd`), generuje čistý signál `btn_press` |
| `HC_SR04_CTL` | Řídí senzor – generuje `trig` pulz, měří délku `echo`, vypočítá vzdálenost |
| `display_driver` | Zobrazuje naměřenou hodnotu na 7-segmentovém displeji (`seg`, `an`) |

---

## Použitý hardware

- **FPGA deska:** Nexys A7 50 (Xilinx Artix-7)
- **Senzor:** HC-SR04 (ultrazvukový, rozsah 2–400 cm)

---

## Vstupy a výstupy

| Signál | Směr | Popis |
|---|---|---|
| `clk` | vstup | Systémové hodiny |
| `btnu` | vstup | Reset |
| `btnd` | vstup | Spuštění měření |
| `trig` | výstup | Trigger pulz pro senzor |
| `echo` | vstup | Echo signál ze senzoru |
| `seg(6:0)` | výstup | Segmenty displeje |
| `an(4:0)` | výstup | Anody displeje |
| `dp` | výstup | Desetinná tečka (neaktivní) |

---

## Simulace

> 

---

## Resource Report

> 
---

## Použité nástroje

- Vivado
- VHDL
- Claude

---

## Autoři

- **[Daniel Viskup]** – []
- **[Vít Uhlíř]** – []

---

## Reference

- [HC-SR04 Datasheet](https://cdn.sparkfun.com/datasheets/Sensors/Proximity/HCSR04.pdf)
- [Nexys A7 Reference Manual](https://digilent.com/reference/programmable-logic/nexys-a7/reference-manual)
