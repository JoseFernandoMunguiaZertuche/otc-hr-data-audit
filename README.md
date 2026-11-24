# Reto OTC Consulting — Auditoría y análisis de datos de Recursos Humanos

Repositorio del reto de Business Intelligence con socio formador **OTC Consulting** (OT Consulting, S.A. de C.V.), consultora mexicana de tecnologías de información e inteligencia artificial. El trabajo consiste en conocer la operación de su área de Recursos Humanos, explorar a fondo las fuentes de datos de su herramienta interna y proponer, a partir de evidencia, la analítica que esa herramienta necesita.

**Equipo** — Franco Varela Villegas (A01199186), Emilio Ogaz Galván (A01572029), Angelica Velez Cantu (A01199359), Melissa Anahid Esparza López (A01286887) y José Fernando Munguía Zertuche (A01199357). La exploración de la Etapa 2, el acondicionamiento de la Etapa 3 y el modelo dimensional de la Etapa 4 son el trabajo individual de José Fernando Munguía Zertuche.

## La herramienta del socio

OTC administra su capital humano en una PWA construida a la medida y hospedada en Firebase, el sandbox HR Management, con módulos de colaboradores, matriz de habilidades, asignaciones, clientes y proyectos, inventario de activos y catálogos de habilidades, roles y departamentos. Su pantalla de resumen muestra solo cuatro conteos y dos gráficas, por lo que registra la operación pero no la convierte en análisis para decidir.

## Estructura

- `docs/ETAPA_1.md` — Justificación y planeación. Conocimiento de la empresa y del área, necesidades de información y de analítica, herramienta actual, beneficios esperados y problemáticas del usuario principal.
- `docs/ETAPA_2.md` — Exploración de las fuentes de datos. Objeto de estudio, metadata, errores y datos faltantes e inconsistencias, reglas de negocio, preguntas de análisis, métricas, indicadores y atributos adicionales, y la propuesta de solución final.
- `notebooks/ETAPA_2_EDA_OTC.ipynb` — Notebook ejecutado con el análisis exploratorio completo, archivo por archivo y columna por columna, con las evidencias de cada cálculo.
- `notebooks/ETAPA_3_ACONDICIONAMIENTO_OTC.ipynb` — Notebook ejecutado del acondicionamiento: aplica los métodos M1 a M14 sobre los 7 archivos, registra cada corrección y valida las reglas de negocio con SQL.
- `data/acondicionado/` — Salida de esa corrida: las tablas acondicionadas en CSV, la base `otc_rh.db`, el `log_correcciones`, el reporte de calidad y las gráficas del prototipo.
- `docs/ETAPA_4.md` — Modelo dimensional lógico: los cuatro pasos de Kimball, grano, métricas, dimensiones y la definición de cada tabla de hechos y dimensión.
- `notebooks/ETAPA_4_MODELO_DIMENSIONAL_OTC.ipynb` — Notebook ejecutado que valida el grano y la integridad referencial, construye el hecho con sus llaves y genera los diagramas.
- `docs/modelo_dimensional_logico.png` y `docs/matriz_bus.png` — Diagramas del modelo y de las dimensiones conformadas, generados por código, no dibujados a mano.
- `docs/ETAPA_5_PRESENTACION_OTC.pptx` — Presentación ejecutiva de 10 diapositivas, en 16:9, lista para importar en Canva.
- `docs/ETAPA_5_GUION_VIDEO.md` — Guion del video de 10 a 11 minutos, con tiempos, pausas y qué decir en cada diapositiva.
- `data/excel/` — Las fuentes tal como las exporta el sandbox, un archivo por módulo.

## Las fuentes

| Archivo | Contenido | Registros |
|---|---|---|
| Catalogo_Colaboradores.xlsx | Expediente operativo y sueldo de cada colaborador | 107 |
| Asignaciones_Colaboradores.xlsx | Colaborador asignado por cliente y proyecto, con rol y fechas | 31 |
| Catalogo_Clientes.xlsx | Clientes y, en su segunda hoja, sus proyectos | 8 y 12 |
| Catalogo_Activos.xlsx | Inventario de equipo y, en su segunda hoja, sus resguardos | 123 y 91 |
| Matriz_Habilidades.xlsx | Nivel de cada colaborador en cada habilidad, en formato largo | 1,539 pares |
| Catalogo_Habilidades.xlsx | Catálogo de habilidades por tecnología y tipo | 71 |
| Catalogo_Departamentos.xlsx | Catálogo de áreas con objetivo, responsable y centro de costos | 6 |
| Catalogo_Roles.xlsx | Catálogo de puestos por nivel y departamento, fuente complementaria | 55 |

El sandbox tiene un módulo más, el de Usuarios, que se excluye a propósito porque contiene las credenciales de acceso a la herramienta. Por la misma razón el catálogo de colaboradores publicado aquí omite los identificadores directos y los datos bancarios, y los correos y teléfonos de la fuente ya vienen anonimizados en origen por el socio.

## Hallazgos principales

- Solo 30 de los 75 colaboradores activos tienen una asignación registrada, una utilización del 40.0%, y el 50.9% de la nómina integrada mensual, $1,994,153.78 de $3,918,864.40, está en gente sin proyecto.
- El 88.8% de los colaboradores no tiene departamento capturado y el 44.9% tiene el puesto en PENDIENTE, por lo que hoy no se puede analizar por área ni por puesto.
- 24 de las 31 asignaciones no tienen fecha de fin y 21 usan la fecha centinela 1990-01-01, así que no se puede saber quién termina pronto.
- 18 de las 32 bajas no tienen fecha de baja, 9 resguardos de equipo de personas dadas de baja siguen abiertos y 70 de los 123 activos no tienen costo registrado.
- Las fuentes no traen el ingreso ni la tarifa de cada proyecto, por lo que el margen por proyecto todavía no se puede calcular y se propone como atributo a agregar.

El detalle completo, con severidad e impacto por hallazgo, está en `docs/ETAPA_2.md` y calculado paso a paso en el notebook.

## Etapa 3 — acondicionamiento sobre los 7 archivos

El notebook de la Etapa 3 corre de punta a punta sobre los archivos publicados, sin subirlos a mano y sin perder ni inventar registros. Resultado de la corrida con fecha de corte 2026-11-20:

- **265 correcciones** registradas en `log_correcciones`: M11 95, M2 77, M3 54, M6 26, M5 10, M7 2 y M8 1.
- **18 tablas** cargadas en `otc_rh.db`, y las 5 validaciones de reglas en cero: sin activos con fecha de baja, sin bajas anteriores al ingreso, sin asignaciones vigentes de personal dado de baja, sin sueldos ni costos en cero.
- **73** personas de plantilla activa, **43 en banca** con un costo mensual de **$1,994,153.78**, **32** activos sin resguardo, **9** equipos pendientes de recuperar por **$40,693**, **1** colaborador sobreasignado y **7** habilidades en riesgo de persona clave.

## Etapa 4 — modelo dimensional lógico

El diseño aplica los cuatro pasos de Kimball sobre las tablas acondicionadas y se documenta en `docs/ETAPA_4.md`. Resultado: **tres hechos** (`hecho_asignacion`, `hecho_habilidad`, `hecho_activo`) con granos de 31, 1,539 y 123 filas, y **nueve dimensiones**, de las cuales Tiempo y Colaborador son conformadas. El grano de la asignación se validó contra los datos (31 filas únicas, sin duplicados lógicos ni llaves huérfanas) y el costo asignado de la corrida es **$2,025,644.02**. Los huecos de la fuente se representan con el miembro desconocido: 29 asignaciones sin rol, 21 sin fecha de inicio real y 10 evaluaciones sin colaborador.

## Propuesta de solución final

Un análisis de brechas sobre el sandbox actual, sin modificar la aplicación del socio, junto con el prototipo visual de un apartado nuevo de Analítica en el menú de su PWA. Ese apartado reuniría los indicadores de quién está en proyecto y quién libre, quién termina pronto, cuántos se van, costos y márgenes por proyecto, habilidades y vencimientos, con alertas, filtros, metas, tendencias y el detalle por persona detrás de cada número, además de pestañas analíticas dentro de los módulos de Asignaciones y Colaboradores.

## Etapa 5 — evidencia final

La entrega se completa con una presentación ejecutiva de 10 diapositivas y un guion de video de 10 a 11 minutos. La presentación resume el reto, las cuatro etapas, los requerimientos, las métricas justificadas, los hallazgos y su tratamiento, el modelo dimensional y las acciones futuras, e incluye capturas del repositorio. El guion indica qué decir en cada diapositiva, con tiempos y pausas, y cómo grabar mostrando la cara y el cuaderno abierto desde este repositorio. El video se entrega por liga de YouTube en Canvas.

## Cómo ejecutar el análisis

```bash
pip install -r requirements.txt
jupyter nbconvert --to notebook --execute --inplace notebooks/ETAPA_2_EDA_OTC.ipynb
jupyter nbconvert --to notebook --execute --inplace notebooks/ETAPA_3_ACONDICIONAMIENTO_OTC.ipynb
jupyter nbconvert --to notebook --execute --inplace notebooks/ETAPA_4_MODELO_DIMENSIONAL_OTC.ipynb
```

Los notebooks leen los archivos de `data/excel/` o de `data/acondicionado/`, y no requieren conexión a internet ni credenciales. El de la Etapa 4 regenera el diagrama y la matriz de bus en `docs/`.

## Aviso sobre los datos

Este repositorio es público porque así lo pide la entrega del reto, y su contenido fue saneado con ese fin. Los datos que el socio formador compartió ya vienen anonimizados en origen, con correos y teléfonos genéricos, y esta versión publica además excluye el módulo de Usuarios con sus credenciales de acceso, los identificadores directos como CURP, RFC y NSS, y todos los datos bancarios, por lo que no contiene contraseñas ni información bancaria de ninguna persona.
