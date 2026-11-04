# Cómo imprimir el cubo LED v1

Archivos de esta carpeta, ya orientados para imprimir (abrir tal cual en el slicer, sin girarlos).
Si se cambia algo del diseño, regenerarlos con `python exportar_impresion.py` desde la carpeta `cubo_led`.

| Archivo | Copias | Tamaño (mm) | Soportes | Pausas para imanes |
|---|---|---|---|---|
| 01_plantilla_prueba.stl | 1 | 185 × 185 × 2 | no | — |
| 02_probeta_calibracion.stl | 1 | 84 × 30 × 8 | no | z = 7.2 (5 imanes) |
| 03_portamatriz_lateral_A.stl | 3 | 185 × 189 × 22 | sí, árbol, en todas partes | z = 13.8 (8 imanes) |
| 04_portamatriz_lateral_B.stl | 1 | 185 × 189 × 22 | sí, árbol, en todas partes | z = 13.8 (8 imanes) |
| 05_portamatriz_superior_B.stl | 1 | 185 × 185 × 15 | sí, árbol, en todas partes | z = 13.8 (8 imanes) |
| 06_placa_inferior.stl | 1 | 203 × 203 × 22 | no | z = 14.6 (4 imanes de canto) |
| 07_columna.stl | 4 | 29 × 29 × 193 | solo desde la cama + borde (brim) 8 mm | z = 9.6, 99.0 y 172.6 (2 imanes de canto en cada una) |
| 08_anillo_superior.stl | 1 | 203 × 203 × 53 | sí, árbol, en todas partes | z = 19.6 (8 imanes) y z = 30.6 (4 de canto) |

Requisitos de la impresora: cama de al menos 205 × 205 mm y altura de al menos 195 mm.

## 1. Ajustes del slicer (PETG, boquilla 0.4 mm)

- **Altura de capa 0.2 mm y primera capa también 0.2 mm.** Las alturas de pausa están calculadas para esto; con otra altura de capa no coinciden.
- Perímetros (paredes): 4. Capas superiores e inferiores: 5.
- Relleno: 30 % giroide (40 % en las columnas).
- Temperaturas, ventilador y velocidad: las que recomiende el fabricante del filamento PETG.
- Columnas: borde (brim) de 8 mm y velocidad moderada; son altas y delgadas.
- Soportes "árbol, en todas partes": el marco de los portamatrices y el del anillo quedan en el aire sobre otras partes de la pieza.

## 2. Cómo poner las pausas

La pausa tiene que ocurrir **después de terminar la capa de la altura indicada y antes de la siguiente** (la que tapa los huecos).

- PrusaSlicer, OrcaSlicer, Bambu Studio: en la vista previa, mover el deslizador de capas hasta la capa **siguiente** (altura indicada + 0.2 mm) y añadir ahí una "pausa".
- Cura: extensión "Pause at height" con la altura indicada + 0.2 mm.
- **Comprobar siempre en la vista previa**: en la capa de la pausa los huecos de los imanes deben verse abiertos, y en la siguiente, tapados.

En la pausa: meter los imanes (hasta el fondo, planos o de canto según el hueco), comprobar que ninguno sobresale y reanudar.
No hace falta pegamento: la impresora los deja encerrados.

## 3. Polaridad de los imanes (importante)

Si un imán queda al revés, empuja la cara hacia fuera en vez de sujetarla.

1. Apilar todos los imanes en una sola columna (se pegan solos en el orden correcto).
2. Con un rotulador, marcar la cara de arriba de cada imán de la pila. Todas las caras marcadas son el mismo polo.
3. Colocar así:
   - **Portamatrices (03, 04, 05)**: cara marcada **hacia abajo**.
   - **Anillo (08), los 8 planos**: cara marcada **hacia abajo**.
   - **Imanes de canto (06 placa, 07 columnas, 08 anillo a z = 30.6)**: cara marcada **hacia la pared exterior delgada** (la cara que luego toca el portamatriz).
4. **En el anillo (08), a z = 30.6**: de los 4 imanes de canto, uno queda en el centro de su riel y los otros tres desplazados 20 mm.
   **Marcar con rotulador por fuera el lado del anillo cuyo imán está centrado**: ahí va el portamatriz lateral B.

## 4. Orden de impresión (probar antes de imprimir todo)

1. **01 Plantilla.** Apoyarla en la cara trasera de una matriz A y de la B: un tornillo original debe entrar por los 14 agujeros
   y la plantilla debe apoyar plana (si algo la levanta, hay un componente donde va el aro del portamatriz). Avisar si algo no encaja.
2. **02 Probeta.** Comprobar qué hueco sujeta mejor un imán, qué agujero va bien para el inserto M3, en cuál pasa
   el tornillo original con un poco de juego (1.3–1.6 mm) y el pasador. Avisar del resultado: con eso se ajusta el diseño antes de lo grande.
3. **03 Un portamatriz lateral A** y probarlo con una matriz A: que apoye plano, que entren los 14 tornillos y que los conectores queden libres.
4. **06 Placa + 4 × 07 Columnas.** Poner los insertos M3, atornillar las columnas y colgar el portamatriz de prueba del riel.
5. **El resto:** 2 × 03 más, 04, 05 y 08.

## 5. Insertos térmicos M3 (12)

Soldador a unos 230–245 °C con punta para insertos; apretar despacio y recto, sin empujar de más.
- Columnas: 2 cada una (arriba y abajo) = 8.
- Portamatrices laterales (03 y 04): 1 cada uno, en la cara trasera = 4.

## 6. Armado

1. Columnas a la placa: 4 × M3×8 por debajo (≤ 0.3 N·m, sin forzar).
2. Raspberry Pi a la placa: 4 × M2.5×6 autorroscantes.
3. Cada matriz a su portamatriz con sus 14 tornillos originales, **apretando suave** (solo hasta que toquen).
4. Bajar cada cara lateral **en vertical desde arriba** hasta que quede colgada del riel inferior. El lateral B va en el lado que se marcó en el anillo.
5. Conectar los cables de las matrices.
6. Anillo encima de las columnas, con su marca sobre el lateral B: 4 × M3×8 por arriba (≤ 0.3 N·m).
7. Desde dentro, por las ventanas del anillo: el **tornillo M3×8 de seguridad** de cada cara lateral (obligatorio).
8. Cara superior apoyada sobre el anillo (la centran los 2 pasadores).

Para cambiar una matriz lateral más tarde hay que quitar antes la cara superior y el anillo.
