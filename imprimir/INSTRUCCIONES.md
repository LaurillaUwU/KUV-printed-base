# Cómo imprimir y armar el cubo LED v1

Guía paso a paso. Léala completa una vez antes de empezar: los imanes van **dentro** de las piezas y se meten
durante una pausa de la impresión; si uno queda mal puesto, hay que volver a imprimir esa pieza.

Los archivos de esta carpeta ya están orientados para imprimir: ábralos en el slicer **tal cual, sin girarlos ni escalarlos**.
(Si se cambia el diseño, se regeneran con `python exportar_impresion.py` desde la carpeta `cubo_led`.)

---

## 0. Resumen

| Archivo | Copias | Tamaño (mm) | Soportes | Pausas (altura de la última capa antes de la pausa) | Imanes por copia |
|---|---|---|---|---|---|
| 01a_plantilla_prueba_A.stl | 1 | 192 × 192 × 3 | no | — | 0 |
| 01b_plantilla_prueba_B.stl | 1 | 192 × 192 × 3 | no | — | 0 |
| 02_probeta_calibracion.stl | 1 | 84 × 30 × 8 | no | 7.2 | 5 planos |
| 03_portamatriz_lateral_A.stl | 3 | 185 × 189 × 22 | sí (árbol, en todas partes) | 13.8 | 8 planos |
| 04_portamatriz_lateral_B.stl | 1 | 185 × 189 × 22 | sí (árbol, en todas partes) | 13.8 | 8 planos |
| 05_portamatriz_superior_B.stl | 1 | 185 × 185 × 15 | sí (árbol, en todas partes) | 13.8 | **16 planos** |
| 06_placa_inferior.stl | 1 | 204 × 204 × 22 | no | 14.6 | 4 de canto |
| 07_columna.stl | 4 | 29 × 29 × 193 | no + borde (brim) 8 mm **solo por fuera** | 8.6, 98.4 y 172.2 | 6 de canto (2 por pausa) |
| 08_anillo_superior.stl | 1 | 204 × 204 × 53 | sí (árbol, en todas partes) | 19.6 y 30.6 | **16 planos** + 4 de canto |

- **Total: 14 impresiones** (2 plantillas, probeta, 5 portamatrices, placa, 4 columnas, anillo) y **101 imanes** (96 del cubo + 5 de la probeta).
- Impresora: cama de al menos **205 × 205 mm** y altura de al menos **195 mm**. La placa 06 y el anillo 08 miden 203.6 mm:
  en una cama de 205 mm solo caben **sin falda (skirt) ni borde (brim)** y algunos slicers (Cura) los marcan en gris igualmente.
  Con una cama de 220 × 220 mm (la más común) no hay problema.
- Filamento: PETG, unos 1.2 kg en total con los soportes (comprar 2 rollos de 1 kg).

### Material

| Material | Cantidad | Nota |
|---|---|---|
| Imanes de neodimio Ø5 × 2 mm, N35 | 101 (comprar 120) | Comprobar que sean de **2 mm** de grueso |
| Tornillos M3 × 8 mm, cabeza Allen (DIN 912) | 12 (comprar 20) | |
| Tornillos M2.5 × 6 mm autorroscantes | 4 | Raspberry Pi |
| Tornillos originales de las matrices | 14 por matriz | Ya los tiene |

Herramientas: ventosa para módulos LED (para quitar la cara superior), llave Allen de 2.5 mm **en forma de L**,
destornillador de precisión con **varilla de 3.4 mm de grosor como máximo** (4 tornillos de cada matriz quedan al fondo
de un pozo de 3.6 mm de ancho y 11.5 mm de hondo), rotulador permanente, un palillo o pinzas de plástico (las pinzas de acero se pegan a los imanes).

---

## 1. Ajustes del slicer (PETG, boquilla 0.4 mm)

| Ajuste | Valor | Por qué |
|---|---|---|
| Altura de capa | **0.2 mm** | Las alturas de pausa están calculadas para capas de 0.2 mm |
| Altura de la primera capa | **0.2 mm** (no 0.3) | Si la primera capa es distinta, las pausas caen en la capa equivocada |
| Perímetros (paredes) | 4 | |
| Capas superiores / inferiores | 5 / 5 | |
| Relleno | 30 % giroide (40 % en las columnas) | |
| Temperaturas, ventilador, velocidad | Las del fabricante del filamento | |
| Temperatura de la cama | **70 °C** (no más) | Los imanes N35 pierden fuerza para siempre si se calientan demasiado; los de las columnas quedan a 6 mm de la cama durante horas |
| Soportes | Ver la tabla del resumen | |
| Capas de interfaz de soporte | 2 | La cara del anillo donde apoya la cara superior se imprime sobre soportes: así queda más plana y los imanes sujetan mejor |
| Distancia Z del soporte (separación superior) | **0.2 mm** | El PETG se suelda al soporte; con menos separación, al arrancarlo se puede romper la piel de 0.6 mm que cubre los imanes del anillo |
| Escala | **100 %** | No escalar ninguna pieza |

Consejos para PETG:
- En cama de PEI liso, poner una capa fina de pegamento en barra: el PETG se pega tanto que puede arrancar trozos de la lámina.
- Si el filamento hace hilos o burbujas, secarlo (unas horas a 65 °C) antes de imprimir las piezas grandes.

---

## 2. Polaridad de los imanes (hacerlo una sola vez, antes de imprimir)

Un imán al revés **empuja** la cara hacia fuera en lugar de sujetarla. Para no equivocarse, se marcan todos igual:

1. **Apilar todos los imanes en una sola columna.** Se pegan solos en el orden correcto. (Si son muchos, hacer 2–3 pilas,
   pero **juntarlas siempre en una sola pila** antes de marcar, para que todas queden igual.)
2. Con la pila de pie, **marcar con rotulador la cara de arriba de cada imán** (puede ir sacando el de arriba, marcarlo y dejarlo aparte
   en un recipiente que **no** sea de metal). Todas las caras marcadas son el mismo polo.
3. Separar **un imán marcado** y guardarlo aparte: es el **imán testigo** para comprobar las piezas al terminar (sección 6).

### Regla de colocación (la misma para todas las piezas)

| Dónde | Cómo se mete | Cara marcada |
|---|---|---|
| Portamatrices 03, 04, 05 (planos) | Acostado en un hueco redondo | **Hacia abajo** (debe verse la cara **sin** marca) |
| Anillo 08, pausa de 19.6 (planos) | Acostado en un hueco redondo | **Hacia abajo** (debe verse la cara **sin** marca) |
| Placa 06, columnas 07, anillo 08 pausa de 30.6 (de canto) | De pie, en un hueco en forma de "D" | **Hacia la pared delgada exterior** de la pieza (la que mira hacia fuera del cubo) |

En los de canto, la marca no se ve una vez metido el imán: mire hacia qué lado queda la marca **antes** de soltarlo en el hueco.

---

## 3. Cómo poner las pausas en el slicer

La pausa tiene que ocurrir **después de terminar la capa de la altura indicada** y **antes de la capa siguiente**, que es la que tapa los imanes.
En los slicers se añade la pausa **en la capa siguiente**:

| Pieza | Última capa antes de la pausa | Poner la pausa en la capa de altura | (número de capa) |
|---|---|---|---|
| 02 probeta | 7.2 mm | **7.4 mm** | 37 |
| 03, 04, 05 portamatrices | 13.8 mm | **14.0 mm** | 70 |
| 06 placa | 14.6 mm | **14.8 mm** | 74 |
| 07 columna | 8.6 / 98.4 / 172.2 mm | **8.8 / 98.6 / 172.4 mm** | 44 / 493 / 862 |
| 08 anillo | 19.6 / 30.6 mm | **19.8 / 30.8 mm** | 99 / 154 |

- **PrusaSlicer, OrcaSlicer, Bambu Studio:** cortar (slice), ir a la vista previa, subir el deslizador vertical de capas
  hasta la altura de la columna "Poner la pausa en…", pulsar el **+** junto al deslizador y elegir **"Pausa"** (Add pause).
- **Cura:** Extensiones → Post-procesado → Modificar G-code → **"Pause at height"**; elegir "Pause at: Layer No." y poner el número de capa de la tabla.
  Comprobar en la vista previa que la pausa queda justo antes de la capa que tapa los huecos (Cura puede contar las capas desde 0 o desde 1).

### Comprobar SIEMPRE en la vista previa antes de imprimir

1. En la **última capa antes de la pausa** (p. ej. 13.8 mm) los huecos de los imanes se ven **abiertos y vacíos**.
2. En la capa de la pausa o, como mucho, **una capa después**, los huecos quedan **tapados**. Es normal que en la capa de la pausa
   todavía se vea una rendija abierta encima del imán (pasa en la placa, las columnas, el anillo y la probeta): el imán ya está
   dentro y se tapa en la capa siguiente. Lo que **no** debe pasar es que el hueco se tape **antes** de la pausa.
3. **Dentro de los huecos no hay soportes.** Si el slicer pone soporte dentro de un hueco de imán, el imán no entra:
   quitarlo con un "bloqueador de soportes" (support blocker) sobre ese hueco, o pintando "no soportar" en esa zona.

---

## 4. Qué hacer en cada pausa

1. Esperar a que la impresora se detenga y aparte el cabezal. **No mover la pieza ni tocar la cama.** El cabezal está caliente (≈240 °C).
2. Quitar con el palillo cualquier hilo de plástico que haya caído dentro de los huecos.
3. **Contar los huecos** y comprobar que coinciden con la tabla (por ejemplo 8 en un portamatriz lateral, 16 en el superior).
4. Meter cada imán **hasta el fondo** con la orientación de la sección 2. Empujarlo con el palillo, no con pinzas de acero.
   - Planos: la cara sin marca debe quedar hacia arriba y el imán plano en el fondo.
   - De canto: de pie en la "D", con la parte redonda hacia abajo y el lado recto del hueco arriba.
5. Pasar una tarjeta o la uña por encima: **ningún imán debe sobresalir** de la superficie. Si uno sobresale, no está al fondo.
6. Volver a contar: todos los huecos con su imán.
7. Reanudar la impresión. No dejar la impresora en pausa mucho rato (como máximo unos minutos): la pieza podría despegarse al enfriarse.

No hace falta pegamento: la capa siguiente encierra los imanes.
Si un imán salta hacia otro o hacia una herramienta, sacarlo y volver a ponerlo con la orientación correcta antes de reanudar.

---

## 5. Pieza por pieza

### 01a / 01b Plantillas de prueba (imprimir primero)
Sin soportes ni pausas. Hay una para cada tipo de matriz: **01a para las matrices A** y **01b para las B**.
Sirven para comprobar, **antes de imprimir lo grande**, que los tornillos coinciden, que los conectores quedan libres
y que la impresora imprime a escala.

1. Apoyar cada plantilla sobre la cara trasera de su matriz, con la cara que estuvo sobre la cama hacia la matriz.
   Debe quedar **plana**: no debe apoyar sobre ningún componente.
   **Ningún conector ni componente debe quedar debajo de la plantilla.** La plantilla solo cubre la franja del borde y la tira
   central; los conectores HUB75 quedan en el hueco grande del medio. En la matriz **B**, el conector de alimentación debe caer
   en el corte de la tira central. Si solo cae ahí con la plantilla **dada vuelta**, no la use así: avise (las piezas saldrían
   en espejo y los portamatrices no se pueden dar vuelta).
2. Poner los tornillos originales **empezando por los del centro de cada lado** y siguiendo hacia las esquinas
   (los agujeros son ranuras cortas que absorben pequeños errores). Deben entrar los 14 sin forzar.
   **Apretarlos solo hasta que la cabeza toque la plantilla**: es una prueba, no hace falta más.
3. Pasar la uña por las **4 lengüetas** de los bordes: deben quedar **a ras del borde de la matriz**.
   Si quedan cortas (≈1 mm por dentro del borde), la impresora imprime más pequeño de lo debido.
4. **Avisar del resultado antes de seguir.**

### 02 Probeta de calibración
Sin soportes. **1 pausa** con la pieza a 7.2 mm: meter 1 imán en cada uno de los 5 huecos (orientación indiferente; es solo para probar).

Tiene una **esquina cortada**. Mirándola desde arriba con esa esquina **abajo a la izquierda**: la fila de delante son los
imanes (izquierda) y los agujeros guía M3 (derecha); la de atrás, los tornillos de la matriz (izquierda) y los pasadores (derecha).
En cada grupo los agujeros van de **más pequeño (izquierda) a más grande (derecha)**. Anote los resultados contando desde la izquierda.
Tiene 4 grupos de agujeros:
- 5 huecos de imán (5.1 → 5.5 mm; el diseño usa 5.2): anotar en cuáles el imán **entró a mano, sin forzar, y quedó al fondo y sin bailar**.
- 4 agujeros guía M3 (2.4 → 2.7 mm; el diseño usa 2.6): enroscar un M3×8 en cada uno con la llave Allen; anotar en cuáles
  **entra sin forzar demasiado y queda firme** (no gira en falso), y si alguno agrieta la pieza.
- 4 agujeros para el tornillo de la matriz (1.3 → 1.6 mm): anotar en cuáles **pasa con un poco de juego**.
- 4 agujeros grandes para el pasador (4.4 → 5.0 mm; el diseño usa 4.8). Opcional: se comprueba al final con los pasadores del anillo.

La probeta no prueba los huecos en "D" de los imanes de canto. Su primera prueba real es la **primera pausa de la primera
columna** (a solo 8.6 mm de altura): si ahí el imán no entra, cancelar y avisar; se pierde muy poco plástico.

Avisar del resultado: con eso se ajustan las holguras del diseño antes de imprimir lo grande.

### 03 / 04 / 05 Portamatrices
- Se imprimen con la cara que toca la matriz **abajo** y la cara de los imanes **arriba**.
- Soportes árbol "en todas partes": el marco queda en el aire sobre la matriz.
- Apoya en la cama solo por una franja estrecha en forma de cuadrado: activar **borde (brim) de 5 mm** (o "orejas" en las
  4 esquinas) para que las esquinas no se levanten.
- **1 pausa** (última capa 13.8 mm): **8 imanes planos** en los laterales 03 y 04, **16** en el superior 05; **cara marcada hacia abajo** (se ve la cara sin marca).
- En los laterales A (03) uno de los imanes de arriba está desplazado 20 mm del centro: es a propósito (evita la ventana del conector).
- Imprimir **un 03 primero** y probarlo con una matriz A antes de imprimir los demás (sección 7).
- Al quitar los soportes, revisar que las ranuras de los 14 tornillos y las ventanas de los conectores queden limpias.
- Debajo de cada una de las 2 uñas, la cara de arriba del portamatriz lleva soporte (zona de unos 16 × 4 mm). Esa zona apoya
  contra el riel: **rasparla o lijarla hasta dejarla plana**; si quedan restos de soporte, la cara no queda a ras con las columnas.

### 06 Placa inferior
- Sin soportes.
- **1 pausa** (última capa 14.6 mm): **4 imanes de canto**, uno en el centro de cada riel (las 4 paredes que suben),
  **cara marcada hacia fuera de la placa** (hacia la pared delgada exterior del riel).

### 07 Columnas (4)
- Se imprimen de pie, apoyadas en la cama por el poste cuadrado, la aleta y las dos alas de la moldura. **Sin soportes**,
  con **borde (brim) de 8 mm solo por fuera** ("Outer brim only" en PrusaSlicer/Orca; "Brim Only on Outside" en Cura) y velocidad
  moderada (son altas y delgadas). Con borde también por dentro, el rincón entre el poste y las alas se llena de una lámina
  que luego hay que cortar.
- Se pueden imprimir de una en una o varias a la vez (si van varias, en cada pausa hay que poner 2 imanes **por columna**).
- **3 pausas** (últimas capas 8.6, 98.4 y 172.2 mm): en cada una, **2 imanes de canto**, uno en cada cara del poste cuadrado,
  **cara marcada hacia fuera** (hacia la pared delgada que mira hacia las alas de la moldura).
  Los 2 imanes de cada pausa quedan a 1 cm uno del otro y se atraen: meter el primero hasta el fondo, sujetarlo con el palillo
  y meter el segundo; comprobar que el primero no se movió.

### 08 Anillo superior
- Se imprime **boca abajo** (las molduras sobre la cama). Apoya en la cama solo por un marco de 5 mm de ancho: activar
  **borde (brim) de 5 mm** (o "orejas" en las esquinas). Si una esquina se levanta, la cara superior no asentará plana.
- Soportes árbol "en todas partes", **excepto** dentro de los
  4 rebajes redondos de las esquinas (donde va la cabeza de los M3) y de los **4 agujeros de los tornillos de seguridad**
  (uno en cada riel, atraviesan el riel): poner ahí bloqueadores de soportes, para que la cabeza apoye en una superficie limpia
  y el agujero quede libre. Si aun así queda soporte dentro de un agujero, quitarlo con una broca o un destornillador fino.
- **Pausa 1** (última capa 19.6 mm): **16 imanes planos, cara marcada hacia abajo** (se ve la cara sin marca).
- **Pausa 2** (última capa 30.6 mm): **4 imanes de canto**, uno en cada riel, **cara marcada hacia fuera del anillo**.
  - De estos 4, **uno está en el centro de su riel** y los otros tres desplazados 20 mm.
  - **Durante esta misma pausa**, marcar con rotulador en la pieza (en la cara de arriba del riel, por fuera) el lado cuyo imán
    está centrado: ahí va el portamatriz lateral **B**. Al terminar la pieza el imán queda tapado y ya no se ve.
    (Si se olvida, se reconoce a simple vista: el riel **B** tiene muescas solo en sus dos extremos; los otros tres tienen
    además una muesca en el medio.)

---

## 6. Comprobar los imanes al terminar cada pieza (imán testigo)

Acercar el imán testigo **con su cara marcada mirando a la pieza** a cada posición de imán, por la cara que toca a la otra pieza:

| Pieza | Cara que se prueba | Debe |
|---|---|---|
| Portamatrices 03, 04, 05 | La cara trasera (la de los imanes, opuesta a la matriz) | **Atraer** en las 8 posiciones (16 en el 05) |
| Placa 06 | Cara exterior de cada riel | **Repeler** |
| Columnas 07 | Las 2 caras exteriores del poste | **Repeler** en las 6 posiciones |
| Anillo 08 | Cara superior (donde apoya la cara de arriba) y cara exterior de cada riel | **Repeler** en las 20 posiciones |

Si una posición hace lo contrario, ese imán quedó al revés: esa pieza no sujetará bien en ese punto. Avisar antes de seguir.

---

## 7. Orden de impresión recomendado

1. **01a y 01b Plantillas** → probar cada una en su matriz (sección 5) y avisar.
2. **02 Probeta** → probar y avisar (puede que haya que ajustar holguras).
3. **03 Un portamatriz lateral A** → probarlo con una matriz A: que apoye plano, que entren los 14 tornillos, que los conectores
   queden libres y que **ningún componente toque** los refuerzos redondos de detrás del marco (los de los imanes y el del tornillo de seguridad).
4. **06 Placa + 4 × 07 Columnas** → atornillar las columnas y colgar el portamatriz de prueba (con su matriz) del riel:
   la matriz debe entrar entre las molduras de las columnas con una pequeña holgura a cada lado.
5. **El resto:** 2 × 03 más, 04, 05 y 08.

---

## 8. Tornillos M3 sin insertos (los 12)

**No hacen falta insertos térmicos ni soldador.** Los 12 M3×8 (4 de la placa, 4 del anillo y los 4 de seguridad) entran en un
agujero guía de 2.6 mm y **hacen su propia rosca en el plástico**:
- La primera vez cuestan un poco: es normal. Girar despacio y **recto**, sin empujar de lado.
- Apretar suave (≤ 0.3 N·m: con la llave en L sujetada por el brazo corto, hasta que haga tope, sin forzar).
- Al volver a poner un tornillo que ya se quitó, girarlo primero hacia atrás hasta notar que "cae" en la rosca hecha; si no, hace una rosca nueva y la gasta.
- Pruébelo antes en la probeta (sección 5).
- **Excepción, los 4 de seguridad (paso 7 del armado):** ahí el brazo corto de la llave está dentro del tornillo y no se puede
  usar para limitar la fuerza. Girar sujetando el brazo largo **solo con dos dedos**, sin fuerza, y parar en cuanto haga tope.
  Por eso su rosca se hace antes, en la mesa (paso 3 del armado).

---

## 9. Armado

Orden obligatorio: una vez puesto el anillo, las caras laterales ya no se pueden sacar.

1. **Columnas a la placa:** apoyar la placa sobre dos listones o libros (para llegar a los agujeros de abajo) y poner cada columna
   en su esquina con las alas de la moldura **a ras de los bordes de la placa**. Mantenerla así mientras se aprieta: con un solo
   tornillo la columna puede quedar girada unos grados y entonces la cara lateral roza al bajarla.
   4 × M3×8 desde **abajo** de la placa, por los agujeros de las esquinas. El tornillo entra en el
   agujero del poste y **hace su propia rosca en el plástico**: la primera vez cuesta un poco, es normal. Girar despacio y recto;
   al final apretar suave (≤ 0.3 N·m: con la llave en L sujetada por el brazo corto, hasta que haga tope, sin forzar).
   Si más adelante se quita y se vuelve a poner, girarlo primero hacia atrás hasta notar que "cae" en la rosca hecha.
   El agujero pasa a 2 mm de los imanes de la columna: **no forzar**. Si cuesta demasiado, sacarlo, limpiar el agujero y volver a intentarlo.
2. **Raspberry Pi a la placa:** 4 × M2.5×6 autorroscantes en los 4 soportes.
   - **Antes de montarla, dejarla completamente configurada** (tarjeta microSD con el sistema, Wi-Fi y acceso remoto por SSH)
     y probada: una vez armado el cubo, para llegar a la tarjeta o a los puertos hay que quitar la cara superior y el anillo.
   - **Orientación:** la Pi entra en dos posiciones. La correcta es con la **tarjeta microSD del lado donde los soportes quedan
     pegados al borde de la Pi** (a 3.5 mm); los puertos USB y Ethernet quedan del otro lado, 24 mm más allá de los soportes.
     Al revés, los puertos quedan a 17 mm de la pared y no cabe un enchufe.
3. **Cada matriz a su portamatriz** con sus 14 tornillos originales (matriz con los LED hacia abajo, sobre un paño suave):
   - **Lo primero, antes de poner la matriz** en los portamatrices laterales 03 y 04: enroscar un M3×8 en el agujero del tornillo
     de seguridad (cara trasera, en la barra del lado contrario a las uñas, a 33 mm del centro: un agujero de 2.6 mm en un refuerzo
     redondo de 10 mm) hasta que la punta asome por el otro lado, y sacarlo. Así la rosca queda hecha en la mesa y en el paso 7 el
     tornillo entra fácil. **Si la matriz ya está puesta** (el portamatriz de prueba), enroscarlo **solo 8 vueltas** (4 mm): más
     adentro la punta se acerca a los componentes de la matriz.
   - Las 3 matrices A en los 3 portamatrices 03; la matriz B lateral en el 04; la matriz B superior en el 05.
   - Empezar por los tornillos del centro de cada lado y seguir hacia las esquinas.
   - 4 tornillos (2 en la cara superior) quedan al fondo de un pozo: meter el tornillo con la punta imantada del destornillador o con un poco de masilla adhesiva.
   - **Apretar muy suave**: solo hasta que la cabeza toque el plástico. Si se aprieta más, la cabeza se hunde en el plástico.
4. **Caras laterales:** antes de la primera, comprobar que las 4 columnas siguen a ras de los bordes de la placa. Cada una se baja **en vertical desde arriba**, con las uñas hacia abajo, **deslizándola pegada a las
   columnas** (los imanes ayudan) hasta que las uñas pasen por detrás del riel inferior y la cara quede colgada.
   No la separe de las columnas al bajarla: la uña solo deja 0.7 mm detrás del riel, y si la cara va separada, la uña cae
   encima del riel en lugar de detrás. Al final la cara debe quedar a ras con las columnas, sin escalón. Las 3 caras A van en 3 lados cualesquiera; la cara **B** va en el lado que luego tendrá
   la marca del anillo (el lateral B es el que lleva su imán superior en el centro).
5. **Cables:** conectar los cables HUB75 y de alimentación de las matrices laterales a través de las ventanas de los portamatrices.
   Deje que los cables salgan **rectos hacia el centro del cubo**: el riel del anillo tiene una muesca justo detrás de cada
   conector y el cable pasa por ella al bajar el anillo. No los doble hacia arriba ni hacia los lados (en las caras A, el
   cable de alimentación queda justo debajo de un refuerzo del anillo: si se dobla hacia arriba, el anillo lo pisa).
   **Cables de la cara superior:** enchufarlos ahora en la Pi (o en el adaptador HUB75) y dejar su otro extremo saliendo hacia
   arriba, por encima de las columnas. Con el anillo puesto ya no se llega a la Pi.
6. **Anillo:** bajarlo sobre las columnas, con su **marca sobre la cara B** (si no coincide, el imán superior central de
   2 caras queda sin pareja y esas caras sujetan menos). Bajarlo despacio mirando que cada cable entre en su muesca del riel
   y que los cables de la cara superior salgan por una de las ventanas del anillo.
   4 × M3×8 desde **arriba**, en las esquinas; también hacen su propia rosca en el poste. Apretar suave (≤ 0.3 N·m).
7. **Tornillos de seguridad (obligatorios):** 1 × M3×8 en cada cara lateral, desde dentro del cubo. Cada uno va en el riel del anillo,
   unos 7 mm por debajo del anillo y a 33 mm del centro de la cara, en un trozo del riel entre dos muescas.
   **Antes de empezar, apartar hacia abajo los cables de esa cara, y hacia el centro los de la cara superior** (salen por las
   mismas ventanas del anillo), para que no estorben a la llave. El agujero queda 12 mm más allá del borde
   de la ventana: lo más fácil es **pegar el tornillo en la punta del brazo corto de la llave con un poco de masilla adhesiva**
   (o usar una llave con punta de bola) y llevarlo así hasta el agujero: bajar la llave en L **con el brazo largo vertical
   por la ventana del anillo** y el brazo corto horizontal, con el tornillo en su punta. El agujero del riel es una ranura que se alarga
   hacia abajo: si el tornillo no entra, bajarlo un poco dentro de la ranura hasta notar que entra en el agujero de la cara. Atraviesa el riel y entra 4 mm en el
   portamatriz, en la rosca hecha en el paso 3. Apretar suave, con dos dedos (sección 8).
   Sin estos tornillos un golpe o un tirón puede soltar una cara.
8. **Cara superior:** conectar en ella los cables que salen por la ventana del anillo y apoyarla sobre el anillo; los 2 pasadores la centran y los 16 imanes la sujetan.
   Los cables bajan rectos por las aberturas del anillo, que están justo debajo de cada conector.
   Entra en dos posiciones (girada 180°): elegir la que deje mejor sus cables. Para quitarla después hace falta una
   **ventosa para módulos LED** (no hay borde del que agarrarla).
   No tiene tornillo: para transportar el cubo, llevarlo derecho o quitar antes la cara superior.
9. **Prueba final de calor y Wi-Fi:** encender todo al menos 30 minutos mostrando imágenes
   **con el cubo cerrado**, y comprobar que la Pi se conecta por Wi-Fi desde fuera del cubo y que no se calienta demasiado
   (`vcgencmd measure_temp` debe quedar por debajo de 70 °C). El plástico y los imanes no deben pasar de unos 70–80 °C.
   Si se calienta, avisar: habrá que añadir un disipador o un ventilador pequeño.

**Para cambiar una matriz lateral, o llegar a la tarjeta microSD o a los puertos de la Pi:** quitar la cara superior, los 4 tornillos
de seguridad, los 4 tornillos del anillo y el anillo; luego subir la cara lateral en vertical. Al volver a poner los tornillos,
girarlos primero hacia atrás hasta que "caigan" en su rosca (sección 8).

---

## 10. Seguridad

- Los imanes de neodimio son peligrosos si se tragan: guardarlos lejos de niños y mascotas.
- Pellizcan fuerte al juntarse: manejarlos de uno en uno.
- Mantenerlos lejos de tarjetas, móviles y del cabezal de la impresora mientras se trabaja.
- El cubo armado pesa unos 2–3 kg: levantarlo siempre por la placa inferior, nunca por las caras.
