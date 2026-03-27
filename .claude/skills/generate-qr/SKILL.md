---
name: generate-qr
description: Plan para QR codes cuando se apruebe el proyecto. NO implementar aún — solo referencia de diseño e impresión.
user-invocable: false
---

## QR Codes — Plan (pendiente de aprobación)

**Estado:** En espera de aprobación de jefatura / confirmación de presupuesto.

### Cuando se apruebe, implementar:

**Ruta:** `src/app/admin/qr-print/page.tsx`
**Librería:** `qrcode.react`
**Costo estimado impresión:** ~$10.000 CLP (20 placas laminadas, resistentes a humedad y aceite)

### Formato
- QR codifica: `MACHINE:POS-{numero}` (ej: `MACHINE:POS-125`)
- Tamaño: 6cm × 6cm — legible desde 1 metro en planta
- Info adicional: código + nombre + área (texto bajo el QR)
- Material: plástico o aluminio anodizado para resistir ambiente industrial

### Prioridad de instalación
1. QSS-700L (POS-125) — sierra principal, Group IV crítico
2. HDSV-700W (POS-160) — sierra secundaria
3. P-700 (POS-120) — perfiladora
4. Resto en orden de posición

### Decisión pendiente: ¿Código QR o NFC?
- QR: más barato, sin hardware adicional
- NFC: más robusto en ambientes con suciedad/aceite, tap directo
