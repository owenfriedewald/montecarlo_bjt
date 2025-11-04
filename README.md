# Monte Carlo Analysis (ECE 3410)

Statistical simulation of a four-resistor BJT bias circuit to evaluate how component tolerances affect the transistor’s Q-point (ICQ and VCEQ).  
Based on *Microelectronic Circuit Design* (Jaeger & Blalock, 5th Ed., §5.11).

---

## 🎯 Objective
- Design bias circuit with ICQ ≈ 75 µA, VCEQ ≈ 5 V, β = 80  
- Apply Monte Carlo analysis for ±10 % resistors, ±5 % VCC, ±50 % β  
- Generate ICQ/VCEQ histograms for 50 – 500 runs  
- Evaluate sensitivity for:
  - Case 1 → RC & RE  
  - Case 2 → R1 & R2  
  - Case 3 → β  

---

## ⚙️ Nominal Values
| Symbol | Value | Units | Notes |
|--------|--------|-------|-------|
| VCC | 15 | V | Supply |
| RC | 68 k | Ω | Std E-series |
| RE | 68 k | Ω | Std E-series |
| R1 | 1.20 M | Ω | Upper divider |
| R2 | 820 k | Ω | Lower divider |
| β | 80 | – | Given |
| ICQ | ≈ 72 | µA | Nominal |
| VCEQ | ≈ 5.1 | V | Nominal |

---

## 🧮 Key Equations
```
VTH = VCC * (R2 / (R1 + R2))
RTH = (R1 * R2) / (R1 + R2)
IB  = (VTH - 0.7) / [RTH + (β + 1)*RE]
IC  = β * IB
VCE = VCC - IC*RC - IE*RE
X   = X_nom * (1 + Δ),  Δ ~ U(-T, +T)
```

---

## 📊 Summary (N = 500)
| Case | Varied | σ(ICQ) (µA) | σ(VCEQ) (V) |
|------|---------|-------------|--------------|
| 1 | RC, RE | 3.8 | 0.37 |
| 2 | R1, R2 | 4.0 | 0.54 |
| 3 | β | 2.2 | 0.29 |

**Most sensitive:** R1/R2 divider → largest spread in Q-point.  
**Least sensitive:** β variation due to emitter degeneration.

---

## 🧠 MATLAB Snippet
```matlab
VCC=15; R1=1.2e6; R2=820e3; RC=68e3; RE=68e3; beta=80;
Vth=VCC*R2/(R1+R2); Rth=(R1*R2)/(R1+R2);
IB=(Vth-0.7)/((beta+1)*RE+Rth);
IC=beta*IB; VE=(beta+1)*IB*RE; VC=VCC-IC*RC; VCE=VC-VE;
```

---

## 📁 Structure
```
montecarlo_matlab/
 ├── monte_bjt.m
 └── README.md
```

---

**Author:** Owen Friedewald  
Dual BSEE/BSCE Student · University of Missouri  
omfvq4@umsystem.edu
