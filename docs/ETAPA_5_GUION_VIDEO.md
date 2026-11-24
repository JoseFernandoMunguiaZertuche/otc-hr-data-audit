# Etapa 5 — Guion del video

**Reto de Business Intelligence — Socio formador OTC Consulting**  
**José Fernando Munguía Zertuche · A01199357**

**Duración objetivo: 10 a 11 minutos.** El rango de la entrega es de 8 a 12, así que hay margen para hablar lento y hacer pausas. El texto está calculado a unas 95 palabras por minuto. Si te pasas de 12, recorta la diapositiva 7 (tratamiento) o la 3 (etapas); no recortes el modelo ni la evidencia del repositorio.

La presentación es `docs/ETAPA_5_PRESENTACION_OTC.pptx`, con 10 diapositivas en 16:9. Se importa en Canva desde **Crear un diseño → Importar → PowerPoint**. Usa Arial y formas simples, así que no debería moverse nada; revisa que los textos sigan en su lugar después de importar.

---

## Antes de grabar

1. Abre en el navegador tu repositorio: `github.com/JoseFernandoMunguiaZertuche/otc-hr-data-audit`. Muestra GitHub, no una carpeta local.
2. Deja abierta una pestaña con el notebook de la Etapa 4 ya renderizado, para usarla en la diapositiva 9.
3. Cierra pestañas, notificaciones y cualquier dato personal que no quieras que salga.
4. Prueba el micrófono y graba en 1080p. La cámara debe verte la cara todo el video; si usas círculo, que sea visible y estable.
5. Ten la presentación en pantalla completa y este guion al lado, no en la diapositiva.
6. No leas la diapositiva: el texto de pantalla es apoyo, tú explicas.
7. Habla lento y separa las ideas con una pausa corta. Es mejor sobrar tiempo que atropellarse.

---

## 0:00 – 0:45 · Diapositiva 1 — Portada

**En pantalla:** portada. Cámara encendida.

**Di esto:**

> Buenos días. Soy José Fernando Munguía Zertuche, matrícula A01199357.
>
> Este es mi trabajo individual del reto de Business Intelligence con OTC Consulting.
>
> En los próximos minutos voy a mostrar cómo convertí los datos de Recursos Humanos de su herramienta interna en un modelo que sí permite decidir.
>
> La idea es simple: la empresa ya registra su operación. Lo que falta es leerla. Empiezo por el problema.

**Pausa:** dos segundos antes de cambiar de diapositiva.

---

## 0:45 – 1:45 · Diapositiva 2 — El reto

**En pantalla:** diapositiva 2, señala la cifra del 40.0%.

**Di esto:**

> OTC vende horas y conocimiento. Su margen depende de cuánta gente está en proyecto y cuánto cuesta.
>
> Su herramienta tiene ocho módulos: colaboradores, asignaciones, clientes, proyectos, habilidades, activos y catálogos. Registra todo.
>
> Pero su pantalla de resumen solo muestra cuatro conteos y dos donas. Sin tendencia, sin filtros, sin alertas.
>
> Y la pregunta que importa es muy concreta: quién está asignado, cuánto cuesta y qué viene.
>
> Hoy la respuesta es incómoda: solo el cuarenta por ciento de los colaboradores activos tiene proyecto.

---

## 1:45 – 2:45 · Diapositiva 3 — Las etapas

**En pantalla:** diapositiva 3, recorre las cuatro tarjetas con la mano o el cursor.

**Di esto:**

> El trabajo tuvo cuatro etapas.
>
> Primero entendí la empresa y el área.
>
> Después exploré las ocho fuentes, columna por columna.
>
> Luego acondicioné los datos: doscientas sesenta y cinco correcciones y cero huérfanos.
>
> Y al final diseñé el modelo dimensional.
>
> Cada etapa quedó en un notebook ejecutado de mi repositorio. Cualquiera puede repetir el recorrido.

---

## 2:45 – 4:00 · Diapositiva 4 — Hallazgos

**En pantalla:** diapositiva 4. Señala cada cifra al nombrarla.

**Di esto:**

> Al explorar encontramos cuatro cosas.
>
> Una: la utilización es del cuarenta por ciento. Treinta de setenta y cinco activos tienen proyecto.
>
> Dos: la mitad de la nómina, un millón novecientos noventa mil pesos al mes, está en gente sin asignación.
>
> Tres: casi el ochenta y nueve por ciento no tiene área capturada. Por eso hoy no se puede analizar por departamento.
>
> Y cuatro: veintiuna de treinta y una asignaciones traen la fecha centinela mil novecientos noventa. Ese dato no es una fecha: es un vacío.
>
> La conclusión: no faltaban datos. Faltaba tratamiento, reglas y un modelo para leerlos.

**Pausa:** deja que se lea la banda azul antes de continuar.

---

## 4:00 – 5:05 · Diapositiva 5 — Requerimientos

**En pantalla:** diapositiva 5.

**Di esto:**

> Con eso claro, definimos cuatro requerimientos.
>
> Utilización y banca: quién está libre, cuánto cuesta y desde cuándo.
>
> Costo y margen: cuánto cuesta cada proyecto y cuánto deja.
>
> Habilidades: nivel, certificaciones y vencimientos.
>
> Y activos y expediente: equipo en riesgo y calidad documental.
>
> Cada requerimiento se convierte en indicadores concretos, no en un tablero genérico.

---

## 5:05 – 6:20 · Diapositiva 6 — Métricas

**En pantalla:** diapositiva 6.

**Di esto:**

> De ahí salen tres métricas que ya se pueden calcular.
>
> Utilización: asignados entre activos. Decide contratación y detecta capacidad ociosa.
>
> Costo asignado: costo mensual por porcentaje de dedicación. Mide el costo real de cada proyecto, sin duplicar la nómina.
>
> Y costo de banca: la nómina de quien no está asignado. Cuantifica lo que cuesta la gente libre.
>
> Ingreso y margen también están definidos, pero no los invento: esperan que el socio capture tarifas y horas.

---

## 6:20 – 7:40 · Diapositiva 7 — Tratamiento y reglas

**En pantalla:** diapositiva 7.

**Di esto:**

> Para que esos números sean creíbles, el tratamiento quedó documentado.
>
> Doscientas sesenta y cinco correcciones en el log, ocho fuentes homologadas, cero huérfanos y cero duplicados en el hecho.
>
> Y cuatro reglas que gobiernan todo.
>
> La fecha mil novecientos noventa se trata como nula.
>
> Una baja cierra sus asignaciones y sus resguardos.
>
> El sueldo integrado es la suma de sus componentes.
>
> Y PENDIENTE no es una categoría de análisis.
>
> Cada regla se validó con SQL sobre las tablas acondicionadas.

---

## 7:40 – 9:10 · Diapositiva 8 — Modelo dimensional

**En pantalla:** diapositiva 8, señala el hecho central y las dimensiones.

**Di esto:**

> El modelo sigue los cuatro pasos de Kimball. Tres hechos y nueve dimensiones.
>
> La asignación es el hecho central: treinta y una filas, una por asignación, con su colaborador, proyecto, rol y periodo.
>
> Habilidad tiene mil quinientas treinta y nueve evaluaciones.
>
> Activo tiene ciento veintitrés equipos.
>
> Tiempo y Colaborador son dimensiones conformadas: las comparten los tres hechos.
>
> El diagrama no está dibujado a mano; lo genera el notebook.
>
> Y el grano se validó contra los datos: cero duplicados y cero huérfanos.

---

## 9:10 – 10:20 · Diapositiva 9 — Evidencia en el repositorio

**En pantalla:** diapositiva 9 y, si puedes, cambia un momento al navegador con tu repositorio abierto. Muestra la página del notebook, no el archivo local.

**Di esto:**

> Todo esto está en mi repositorio público.
>
> Estas capturas son de mi cuenta de GitHub, no de una carpeta local.
>
> Ahí están el README, los documentos de cada etapa, los tres notebooks ejecutados con sus salidas y las tablas acondicionadas.
>
> Los datos sensibles quedaron fuera: no está el módulo de Usuarios, no hay identificadores directos y no hay datos bancarios.
>
> El video lo estoy grabando con el cuaderno abierto desde este repositorio.

**Pausa:** vuelve a la presentación.

---

## 10:20 – 11:20 · Diapositiva 10 — Cierre

**En pantalla:** diapositiva 10.

**Di esto:**

> ¿Qué sigue? Tres acciones.
>
> Primero, capturar tarifas y horas para calcular margen real.
>
> Segundo, agregar fecha y evaluador a la matriz para medir brecha de habilidades.
>
> Tercero, un corte mensual automático para tener historia y tendencia, no una sola foto.
>
> Con eso, el tablero deja de contar y empieza a decidir.
>
> Gracias.

**Pausa:** tres segundos con la cara en cámara antes de detener la grabación.

---

## Después de grabar

1. Revisa que se te vea la cara y que el audio se entienda; si algo salió mal, regraba solo esa parte.
2. Súbelo a YouTube. Puede ser público o “no listado”; lo importante es que la liga abra sin pedir permiso.
3. Copia la liga del video, no la de YouTube Studio.
4. Pega la liga en Canvas y revisa que abra en una ventana sin sesión.
5. Si el profesor pide el archivo, guarda también el PPTX; la entrega principal es la liga.

## Si te falta tiempo

- Si vas lento y llegas a 12 minutos, recorta la diapositiva 7 a la mitad: di solo las dos primeras reglas.
- No recortes la diapositiva 8 ni la 9: son el modelo y la evidencia del repositorio.
- Si te sobra tiempo, no agregues diapositivas; agrega pausas.
