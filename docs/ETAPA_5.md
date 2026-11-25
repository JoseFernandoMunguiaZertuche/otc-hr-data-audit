# Etapa 5 — Consultas, dimensiones y solución para Dirección

**Reto de Business Intelligence — Socio formador OTC Consulting**

**José Fernando Munguía Zertuche — A01199357**

**25 de noviembre de 2026**

---

## Resumen ejecutivo

Esta etapa cierra el proyecto con tres entregables que se complementan: las **consultas** que responden las preguntas de análisis sobre cada dimensión, el **perfil de valores distintos** de las nueve dimensiones del modelo lógico y una **solución replicable para Dirección** —un tablero estático que se puede publicar en Firebase Hosting o en cualquier servidor— construida sobre las tablas acondicionadas de la Etapa 3.

El modelo se implementó en SQLite con **nueve dimensiones y tres hechos**. La corrida deja **31 asignaciones**, **1,539 evaluaciones de habilidad** y **123 activos**, con **cero llaves huérfanas** en los tres hechos. Las consultas se ejecutan contra ese modelo, no contra los archivos originales, de modo que cualquier persona puede reproducir las cifras con un comando.

Los resultados principales del corte **2026-11-20** son:

- **30 de 75 activos** tienen una asignación registrada: **40.0% de utilización** sobre el headcount y **41.1%** sobre la plantilla (73 personas, sin los dos familiares de seguro).
- La **banca de plantilla** es de **43 personas** y **$1,912,228.33** al mes. Si se suman los dos familiares sin asignación, son **45 personas** y **$1,994,153.78**. La nómina activa es **$3,918,864.40**: **49.1% asignado**, **48.8% en banca** y **2.1% en familiares**.
- El hecho de asignación suma **$2,025,644.02** porque una persona tiene dos asignaciones al 100%; el costo único —sin duplicarla— es **$1,924,710.62**. Esa diferencia de **$100,933.40** es el costo de la única persona sobreasignada.
- **29 de 31 asignaciones no tienen rol**, **21 no tienen fecha de inicio real** y **14 no tienen puesto**. El costo de esas 14 asignaciones sin puesto es **$1,001,034.75**, casi la mitad del costo asignado.
- El **margen por proyecto está bloqueado, no en cero**: hay costo en las 31 asignaciones, pero **0 tienen ingreso facturable y 0 tienen margen** porque faltan tarifas y horas.
- La matriz cubre **54 de 75 activos**; hay **71 habilidades**, **1,539 evaluaciones** (10 sin colaborador) y **9 habilidades en riesgo** por tener un solo experto o ninguno.
- **32 de 107 registros son bajas (29.9%)**, pero **18 no tienen fecha de baja**. La cohorte 2025 es la más crítica: **12 bajas de 20 ingresos**.
- **70 de 123 activos no tienen costo**, **32 no tienen resguardo** y **9 equipos de personas dadas de baja siguen sin recuperarse** por **$40,693** de valor conocido.
- **Ningún expediente está completo**; el promedio activo es **52.7%**, con **64 activos sin departamento** y **29 sin puesto**.

La solución para Dirección es un tablero de **diez secciones** —resumen, utilización, costos, vencimientos, habilidades, rotación, activos, expediente, dimensiones y modelo— que se abre sin instalación, funciona sin conexión y se regenera con tres comandos. El documento explica cómo llevarlo a la arquitectura del cliente: Firebase como origen, un ETL programado, BigQuery o Firestore como destino analítico y Firebase Hosting para la consulta.

---

## 1. Qué se entrega

| Archivo | Contenido | Para qué sirve |
|---|---|---|
| `sql/01_esquema_dimensional.sql` | DDL de las 9 dimensiones, los 3 hechos, índices y vistas `vw_*` | Crear el modelo en SQLite o adaptarlo a otro motor |
| `sql/02_perfil_dimensiones.sql` | 9 consultas, una por dimensión, que devuelven valores distintos, nulos, mínimos y máximos de cada atributo | Evidencia reproducible del perfil de dimensiones |
| `sql/03_preguntas_analisis.sql` | 24 consultas marcadas con `-- @consulta` | Responder las nueve preguntas del reto |
| `src/etapa5_dw.py` | ETL que lee `data/acondicionado/` y construye `data/modelo/otc_dw.db` | Reproducir el modelo desde cero |
| `src/etapa5_consultas.py` | Ejecuta las 24 consultas y valida integridad referencial | Generar `resultados_analisis.json` |
| `src/etapa5_exportar.py` | Exporta el modelo al tablero | Generar `dashboard/datos.js` |
| `dashboard/` | Sitio estático de consulta para Dirección | Entregable visual, sin build ni dependencias |
| `data/modelo/otc_dw.db` | Base dimensional de la corrida | Consultar sin volver a correr el ETL |
| `data/modelo/perfil_dimensiones.json` | Perfil completo de las 9 dimensiones | Alimenta el documento y el tablero |
| `data/modelo/resultados_analisis.json` | Resultados de las 24 consultas + integridad | Evidencia de la corrida |
| `docs/ETAPA_5.md` | Este documento, fuente editable | Entregable para el socio formador |
| `docs/ETAPA_5.pdf` | Versión PDF con portada y tablas | Entrega directa en Canvas |
| `docs/ETAPA_5.html` | Versión HTML del documento | Lectura en navegador |

El repositorio de documentación y pipeline del equipo es **https://github.com/Francovarelav/otconsultingdocumentacion**. Ahí viven el pipeline M1–M14, el cargador a Firestore del proyecto `otc-rh-agentes` y el tablero React de las etapas anteriores. El repositorio **no versiona la base ni los Excel**: `salida/otc_rh.db` se genera al correr `src/acondicionamiento_rh.py`. Esta entrega usa las tablas acondicionadas de este repositorio, construidas a partir de los mismos siete módulos, y se alinea con esa arquitectura; mantiene sus propias consultas y su propio tablero para que el modelo dimensional sea auditable de punta a punta.

---

## 2. Preparación de los datos: de Firebase al modelo dimensional

### 2.1 Origen

Los datos provienen del **sandbox HR Management** de OTC Consulting, una PWA construida a la medida y hospedada en Firebase. La herramienta registra la operación en siete módulos: colaboradores, asignaciones, clientes y proyectos, activos y resguardos, matriz de habilidades, catálogo de habilidades y departamentos. El módulo de **Usuarios se excluye a propósito** porque contiene credenciales de acceso; el catálogo publicado también omite identificadores directos y datos bancarios.

| Fuente | Contenido | Registros |
|---|---|---:|
| `Catalogo_Colaboradores.xlsx` | Expediente operativo, puesto, área, estatus, fechas, nómina, sueldo y documentos | 107 |
| `Asignaciones_Colaboradores.xlsx` | Colaborador, cliente, proyecto, rol, tipo y fechas | 31 |
| `Catalogo_Clientes.xlsx` | Clientes y, en su segunda hoja, proyectos | 8 clientes y 12 proyectos |
| `Catalogo_Activos.xlsx` | Inventario y, en su segunda hoja, resguardos | 123 activos y 91 resguardos |
| `Matriz_Habilidades.xlsx` | Nivel de cada colaborador en cada habilidad | 1,539 pares |
| `Catalogo_Habilidades.xlsx` | Habilidades por tecnología y tipo | 71 |
| `Catalogo_Departamentos.xlsx` | Áreas, objetivo, responsable y centro de costos | 6 |
| `Catalogo_Roles.xlsx` | Puestos por nivel y departamento; fuente complementaria | 55 |

### 2.2 Acondicionamiento (Etapa 3)

El pipeline de la Etapa 3 aplica los métodos **M1 a M14** y no borra ni inventa registros: corrige formato, homologa catálogos, convierte centinelas en nulos, reconstruye llaves y deja trazabilidad. La corrida de este repositorio registra:

- **265 correcciones** en `log_correcciones`: M11 95, M2 77, M3 54, M6 26, M5 10, M7 2 y M8 1.
- **18 tablas** en `data/acondicionado/otc_rh.db`.
- **5 validaciones de reglas en cero**: sin activos con fecha de baja, sin bajas anteriores al ingreso, sin asignaciones vigentes de personal dado de baja, sin sueldos ni costos en cero.

Los huecos que no se pueden corregir se conservan como nulos y se reportan: 48 colaboradores sin puesto, 95 sin departamento, 18 bajas sin fecha, 21 asignaciones sin inicio real, 24 sin fin, 29 sin rol, 70 activos sin costo y 10 evaluaciones sin colaborador.

### 2.3 Modelo dimensional (Etapa 4)

El diseño sigue los cuatro pasos de Kimball y se documenta en `docs/ETAPA_4.md`. La constelación tiene tres procesos de negocio con granos distintos:

| Hecho | Grano | Filas | Dimensiones |
|---|---|---:|---|
| `hecho_asignacion` | Una asignación de un colaborador a un proyecto | 31 | Tiempo, Colaborador, Puesto, Departamento, Cliente, Proyecto, Rol |
| `hecho_habilidad` | Un colaborador y una habilidad evaluada | 1,539 | Tiempo, Colaborador, Habilidad |
| `hecho_activo` | Un activo del inventario | 123 | Tiempo, Colaborador, Activo |

**Tiempo y Colaborador son dimensiones conformadas**: las comparten los tres hechos, lo que permite comparar utilización, habilidades y equipo de la misma persona y en el mismo calendario.

### 2.4 Implementación de la Etapa 5

El ETL `src/etapa5_dw.py` lee las tablas acondicionadas, aplica el modelo lógico y escribe `data/modelo/otc_dw.db`. Cada dimensión tiene una fila **0** para el miembro desconocido; las llaves sustitutas son enteras y deterministas. El hecho de asignación agrega `sk_tiempo_corte` (20261120) para que la tercera función de `dim_tiempo` —inicio, fin y corte— quede explícita.

| Tabla | Filas | Miembro desconocido | Llave natural |
|---|---:|---:|---|
| `dim_tiempo` | 9,498 | 1 (fila 0) | `sk_tiempo` (AAAAMMDD) |
| `dim_colaborador` | 108 | 1 | `id_colaborador` |
| `dim_puesto` | 24 | 1 | `id_puesto` |
| `dim_departamento` | 7 | 1 | `codigo` |
| `dim_cliente` | 9 | 1 | `id_cliente` |
| `dim_proyecto` | 13 | 1 | `id_proyecto` |
| `dim_rol` | 2 | 1 | `rol_asignado` |
| `dim_habilidad` | 72 | 1 | `cod_habilidad` |
| `dim_activo` | 124 | 1 | `codigo` |
| `hecho_asignacion` | 31 | — | `id_asignacion` |
| `hecho_habilidad` | 1,539 | — | colaborador × habilidad |
| `hecho_activo` | 123 | — | `codigo` |

La corrida valida:

- **0 asignaciones huérfanas**, **0 habilidades huérfanas** y **0 activos huérfanos**.
- Costo asignado por fila: **$2,025,644.02**; costo único: **$1,924,710.62**.
- Nómina activa: **$3,918,864.40**.
- Inventario conocido: **$567,915.55**.

### 2.5 De Firebase a la arquitectura del cliente

La ruta replicable es la siguiente:

1. **Exportación.** Firebase no es un almacén analítico: se exportan las colecciones a JSON/CSV o se programa una Cloud Function que escriba un corte periódico en Cloud Storage.
2. **Aterrizaje.** Los archivos se depositan en un bucket de Cloud Storage con la fecha de corte en el nombre (`corte=2026-11-20/`).
3. **Acondicionamiento.** Corre el pipeline M1–M14 (Python) en Cloud Run o en una máquina de RH; produce las 18 tablas acondicionadas.
4. **Modelo dimensional.** Corre `src/etapa5_dw.py`; produce las 9 dimensiones y los 3 hechos.
5. **Publicación.** El modelo se carga a **BigQuery** para BI y consultas SQL de Dirección, y/o a **Firestore** para lectura desde la PWA. El tablero estático se publica en **Firebase Hosting**.
6. **Seguridad.** Los sueldos y costos individuales viven en una colección privada con rol `admin`; el tablero de Dirección usa agregados y no publica nombres.
7. **Operación.** Un programador (Cloud Scheduler) ejecuta el ETL cada mes o cada semana, valida las reglas y deja el corte anterior para comparar.

La integración con Firebase ya existe en el repositorio de documentación: el proyecto **`otc-rh-agentes`** tiene Firestore, Auth, Storage y Functions; el cargador `agentes/scripts/cargar_firestore.py` publica colaboradores, asignaciones, proyectos, clientes, activos, habilidades, matriz, catálogos e indicadores, y separa `colaboradores_privado` para los sueldos. La Etapa 5 agrega la capa dimensional y el tablero de consulta; no requiere cambiar la PWA del socio.

---

## 3. Modelo de consultas

### 3.1 Consultas por dimensión

`sql/02_perfil_dimensiones.sql` contiene **una consulta por dimensión** y **94 atributos perfilados**. Cada fila devuelve:

- `valores_distintos`: cuántos valores diferentes tiene el atributo, sin contar nulos.
- `nulos`: cuántos registros no tienen el dato.
- `minimo` y `maximo`: rango de fechas o de números.
- `detalle`: valores cuando son 10 o menos; si son más de 10, remite a la descripción del documento.

La fila 0 de cada dimensión se excluye del perfil: no es un valor real, es el miembro desconocido.

### 3.2 Consultas por pregunta

`sql/03_preguntas_analisis.sql` contiene **24 consultas** agrupadas en las nueve preguntas del reto. El runner `src/etapa5_consultas.py` las ejecuta y guarda el SQL y el resultado en `data/modelo/resultados_analisis.json`.

| Pregunta | Consultas | Dimensión principal |
|---|---|---|
| P1 · Asignados y banca | `q1_resumen`, `q1_banca_por_puesto`, `q1_banca_detalle`, `q1_concentracion_cliente` | Colaborador, Tiempo |
| P2 · Terminan pronto | `q2_vencimientos`, `q2_resumen` | Tiempo, Proyecto, Cliente |
| P3 · Nómina asignada | `q3_costos`, `q3_por_cliente` | Colaborador, Cliente |
| P4 · Costo por hora | `q4_costo_hora_puesto`, `q4_cobertura` | Puesto, Colaborador |
| P5 · Margen | `q5_bloqueo`, `q5_costo_por_proyecto` | Cliente, Proyecto |
| P6 · Habilidades | `q6_tecnologia`, `q6_niveles`, `q6_riesgo`, `q6_cobertura` | Habilidad, Colaborador |
| P7 · Riesgo de salida | `q7_resumen`, `q7_cohortes`, `q7_por_nomina` | Colaborador, Tiempo |
| P8 · Equipo e inventario | `q8_resumen`, `q8_marcas`, `q8_pendientes` | Activo, Colaborador |
| P9 · Expediente | `q9_expediente`, `q9_rangos` | Colaborador |

Las consultas usan SQLite. Para llevarlas a PostgreSQL, BigQuery o SQL Server solo cambian detalles de sintaxis (`strftime`, `substr`, `GROUP_CONCAT`); la lógica y las vistas son las mismas.

---

## 4. Perfil de las nueve dimensiones

Esta sección responde el requisito de identificar, para cada tabla de dimensión, cuántos valores diferentes existen, describirlos cuando son más de diez y reportar el rango de fechas cuando la dimensión es temporal. Los conteos excluyen la fila 0 (miembro desconocido) y los nulos.

**Resumen de miembros por dimensión:**

| Dimensión | Miembros reales | Miembro desconocido | Valores distintos de la llave | Rango de fechas principal |
|---|---:|---:|---:|---|
| `dim_tiempo` | 9,497 | 1 | 9,497 | 2003-01-01 → 2028-12-31 |
| `dim_colaborador` | 107 | 1 | 107 | Incorporación 2003-04-01 → 2026-10-06; bajas 2026-08-28 → 2026-11-09 |
| `dim_puesto` | 23 | 1 | 23 | Sin fechas |
| `dim_departamento` | 6 | 1 | 6 | Sin fechas |
| `dim_cliente` | 8 | 1 | 8 | Sin fechas |
| `dim_proyecto` | 12 | 1 | 12 | 2021-01-01 → 2028-10-30 |
| `dim_rol` | 1 | 1 | 1 | Sin fechas |
| `dim_habilidad` | 71 | 1 | 71 | Sin fechas |
| `dim_activo` | 123 | 1 | 123 | Compra 2017-04-26 → 2025-09-04 |

### 4.1 `dim_tiempo`

**9,497 días reales + 1 desconocido.** Calendario completo de **2003-01-01 a 2028-12-31**. La llave es `AAAAMMDD`; la fila 0 representa “sin fecha”. Cubre 26 años, 312 meses y 53 semanas ISO.

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `fecha` | 9,497 | 0 | 2003-01-01 → 2028-12-31 |
| `anio` | 26 | 0 | 2003 a 2028; 2004, 2008, 2012, 2016 y 2020 tienen 366 días |
| `trimestre` | 4 | 0 | T1 2,347; T2 2,366; T3 2,392; T4 2,392 |
| `mes` | 12 | 0 | Enero a diciembre; 806 días en los meses de 31 días |
| `nombre_mes` | 12 | 0 | Enero, febrero, …, diciembre |
| `semana_iso` | 53 | 0 | Semanas 1 a 53 |
| `dia_semana` | 7 | 0 | Lunes a domingo; miércoles a domingo con 1,357 días |
| `es_fin_semana` | 2 | 0 | 0 = 6,783 días; 1 = 2,714 días |
| `anio_mes` | 312 | 0 | 2003-01 a 2028-12 |

**Lectura para Dirección.** El calendario permite fechar incorporaciones, asignaciones, resguardos y proyectos en una sola dimensión. No hay fechas reales antes de 2003 porque la incorporación más antigua es de 2003-04-01; el extremo 2028 existe para los proyectos que terminan después del corte.

### 4.2 `dim_colaborador`

**107 personas + 1 desconocido.** Es la dimensión más rica y la más incompleta. Conserva identidad seudónima, género, ciudad, estatus, puesto, área, fechas, nómina, sueldo, costo, antigüedad, expediente, asignación y banderas de calidad.

#### Identidad, estatus y catálogos

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `id_colaborador` | 107 | 0 | Identificador seudónimo; no se lista |
| `nombre_completo` | 107 | 0 | Dato personal; no se lista |
| `genero` | 2 | 0 | Masculino 77; Femenino 30 |
| `ciudad` | 24 | 0 | Monterrey 51; Edo. de México 12; Ciudad de México 12; Puebla 7; Tlaxcala 4; 24 en total |
| `estatus` | 2 | 0 | Activo 75; Baja 32 |
| `puesto` | 23 | 48 | Consultor funcional Oracle EBS Senior 10; Consultor técnico Java Senior 5; Consultor funcional Oracle Cloud y EBS Senior 5; 23 en total |
| `departamento` | 2 | 95 | Operaciones y Soporte 11; Ventas 1 |
| `fecha_incorporacion` | 85 | 1 | 2003-04-01 → 2026-10-06 |
| `fecha_baja` | 8 | 93 | 2026-08-28 → 2026-11-09 |
| `fecha_nacimiento` | 104 | 1 | 1946-05-14 → 2002-06-02 |
| `tipo_nomina` | 9 | 6 | SMR 36; MAGNESON-SINDICATO 20; OTC 100% 18; XERES OT-SINDICATO 10; OTC-SINDICATO (SMR) 10; MODALIDAD 40-SMR 3; ADMINISTRATIVA 2; IRAZU/ASIMILADOS 1; EXTRANJERO 1 |

#### Costo, antigüedad y situación al corte

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `sueldo_neto_total` | 66 | 0 | 25 registros en $0; máximo $132,227.37 |
| `sueldo_total_integrado` | 74 | 25 | $7,450.10 a $135,460.71 |
| `costo_mensual` | 74 | 25 | $7,450.10 a $135,460.71 |
| `costo_hora` | 73 | 25 | $46.56 a $846.63 |
| `es_plantilla` | 2 | 0 | 1 = 105; 0 = 2 familiares |
| `antiguedad_meses` | 87 | 1 | 1.5 a 283.6 meses |
| `edad` | 35 | 1 | 24 a 80 años |
| `baja_primer_anio` | 2 | 0 | 0 = 100; 1 = 7 |
| `tiene_asignacion_vigente` | 2 | 0 | 0 = 77; 1 = 30 |
| `dedicacion_total_pct` | 2 | 77 | 100% en 29; 200% en 1 |
| `sobreasignado` | 2 | 0 | 0 = 106; 1 = 1 |
| `dias_en_banca` | 67 | 31 | 45 a 7,237 días |
| `pct_expediente` | 11 | 0 | 0% a 84.6% |
| `expediente_completo` | 1 | 0 | 0 en las 107 personas |
| `tiene_contrato` | 2 | 0 | 0 = 92; 1 = 15 |
| `inversion_equipo_col` | 26 | 42 | $0 a $26,018 |

#### Banderas de calidad

| Bandera | Valores distintos | Nulos | Valor 1 |
|---|---:|---:|---:|
| `falta_puesto` | 2 | 0 | 48 |
| `falta_departamento` | 2 | 0 | 95 |
| `falta_tipo_nomina` | 2 | 0 | 6 |
| `falta_ciudad` | 1 | 0 | 0 |
| `falta_fecha_baja` | 2 | 0 | 18 |
| `falta_sueldo` | 2 | 0 | 25 |
| `inconsistencia_estatus_fecha` | 2 | 0 | 1 |

**Fechas.** Incorporación: **2003-04-01 a 2026-10-06**. Bajas: **2026-08-28 a 2026-11-09**. Nacimiento: **1946-05-14 a 2002-06-02**.

**Lectura para Dirección.** La dimensión permite analizar a las 107 personas, incluidas las 77 que no tienen asignación y que nunca aparecerían si el análisis se hiciera solo desde el hecho. Pero 48 personas no tienen puesto y 95 no tienen área: cualquier reporte por área o por puesto cubre una minoría. Los 25 sueldos nulos y los 25 sueldos netos en cero impiden costear a una parte de la plantilla. La versión SCD es 1 en las 107 filas: el modelo está preparado para historia, pero la fuente solo entrega la foto del corte.

### 4.3 `dim_puesto`

**23 puestos + 1 desconocido.** Tiene más de diez valores, así que se describe en lugar de listarse:

- **Consultoría funcional y técnica (17):** Oracle EBS, Oracle Cloud, Cloud + EBS, NetSuite, Kronos, DBA, Java, .NET, RPA y Web, en niveles Senior, Analista y Gerente.
- **Administración y finanzas (2):** Gerente y Senior.
- **Dirección y gestión (3):** Gerente de Proyectos y Operaciones, Gerente de Recursos Humanos y Asesor Comercial Senior.
- **Familiar colaborador (1):** puesto usado por los dos familiares de seguro.

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `id_puesto` | 23 | 0 | 1 a 23 |
| `puesto` | 23 | 0 | 17 perfiles de consultoría, 2 de administración, 3 de gestión y 1 familiar |

**Lectura para Dirección.** El catálogo está subutilizado: 14 de las 31 asignaciones caen en el miembro desconocido porque la persona trae `PENDIENTE`, y 29 activos no tienen puesto. El costo de esas 14 asignaciones sin puesto es **$1,001,034.75**. Sin puesto no se puede comparar el perfil del consultor con la necesidad del proyecto ni calcular una tarifa por rol.

### 4.4 `dim_departamento`

**6 áreas + 1 desconocido.** Tiene seis valores, por lo que se listan todos:

| Código | Área | Objetivo (resumen) | Responsable | Centro de costos |
|---|---|---|---|---|
| D0001 | Ventas | Conseguir clientes, dar seguimiento y facturar proyectos y asignaciones | No capturado | No capturado |
| D0002 | Administración y Finanzas | Control de ingresos y egresos, contabilidad, transferencias e impuestos | No capturado | No capturado |
| D0003 | Recursos Humanos | Reclutamiento, selección y administración de requerimientos | No capturado | No capturado |
| D0004 | Operaciones y Soporte | Seguimiento a proyectos, soporte técnico y funcional, equipo y accesos | No capturado | No capturado |
| D0005 | Dirección General | Administración general de OTC | No capturado | No capturado |
| D0006 | Procesos y Mejora Continua | Documentación, automatización y mejora continua | No capturado | No capturado |

| Atributo | Valores distintos | Nulos | Valores |
|---|---:|---:|---|
| `codigo` | 6 | 0 | D0001 a D0006 |
| `nombre` | 6 | 0 | Las seis áreas de la tabla |
| `objetivo` | 6 | 0 | Un objetivo por área |
| `responsable` | 0 | 6 | Ninguno capturado |
| `centro_costos` | 0 | 6 | Ninguno capturado |
| `estatus` | 1 | 0 | Activo en las seis |

**Lectura para Dirección.** El catálogo existe, pero no sirve para imputar costo: **0 de 6** áreas tienen responsable y centro de costos. Además, solo se usan dos áreas en el expediente (Operaciones y Soporte, 11 personas; Ventas, 1) y **95 personas no tienen área**. No se puede responder “cuánto cuesta cada área” con los datos actuales.

### 4.5 `dim_cliente`

**8 clientes + 1 desconocido.** Tiene ocho valores, por lo que se listan todos:

| Cliente | Industria | Ciudad | Proyectos | Estatus |
|---|---|---|---:|---|
| Metalsa | Automotriz | Apodaca, Nuevo León | 3 | Activo |
| Grupo Daltile | Manufactura | No capturada | 3 | Activo |
| Allegion | Manufactura | No capturada | 1 | Activo |
| Citi | Consultoría | No capturada | 1 | Activo |
| Parker Servicios de México | Manufactura | Apodaca, Nuevo León | 1 | Activo |
| Rent A Center (RAC México Operaciones) | Rentas de equipo | Apodaca, Nuevo León | 1 | Activo |
| Fanosa | Manufactura | No capturada | 1 | Activo |
| Novocast | Manufactura | El Carmen, Nuevo León | 1 | Activo |

| Atributo | Valores distintos | Nulos | Valores |
|---|---:|---:|---|
| `id_cliente` | 8 | 0 | 1 a 8 |
| `codigo_cliente` | 8 | 0 | C0001 a C0008 |
| `cliente` | 8 | 0 | Los ocho de la tabla |
| `industria` | 4 | 0 | Manufactura 5; Automotriz 1; Consultoría 1; Rentas de Equipo 1 |
| `ciudad` | 2 | 4 | Apodaca 3; El Carmen 1; cuatro sin ciudad |
| `estado` | 1 | 4 | Nuevo León 4 |
| `pais` | 1 | 4 | México 4 (se normalizaron “Méxcio” y “Mèxico”) |
| `contacto_nom` | 8 | 0 | Dato de contacto; no se lista |
| `estatus` | 1 | 0 | Activo en los ocho |
| `n_proyectos` | 2 | 0 | 1 proyecto en 6 clientes; 3 proyectos en 2 |

**Lectura para Dirección.** La cartera tiene ocho clientes, pero solo tres aparecen en asignaciones: Metalsa, Grupo Daltile y Allegion. Cinco clientes tienen proyectos y ninguna persona asignada, así que su operación es invisible en el hecho. Cuatro clientes no tienen ciudad, estado ni país, lo que impide un análisis geográfico completo.

### 4.6 `dim_proyecto`

**12 proyectos + 1 desconocido.** Tiene más de diez valores, así que se describe:

- **Metalsa (3):** Ams Manufactura, Soporte Ams Manufacta y Asignación Indefinida.
- **Grupo Daltile (3):** Marazzi, Asignación EBS Temporal (3 meses) y Asignación Funcional-Técnico (4 meses).
- **Allegion (1):** Migración EBS.
- **Citi (1):** Soporte Oracle Cloud.
- **Parker Servicios de México (1):** Desarrollo de Indicadores.
- **Rent A Center (1):** Shine - Asignación de Recursos de Apoyo.
- **Fanosa (1):** Soporte DBA.
- **Novocast (1):** Hosting EBS.

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `id_proyecto` | 12 | 0 | 1 a 12 |
| `llave_proyecto` | 12 | 0 | Cliente + proyecto normalizado |
| `proyecto` | 12 | 0 | Los doce de la descripción |
| `cliente` | 8 | 0 | Metalsa 3; Grupo Daltile 3; los otros seis, 1 cada uno |
| `fecha_inicio` | 6 | 6 | 2021-01-01 → 2026-10-13 |
| `fecha_fin` | 3 | 9 | 2026-09-23 → 2028-10-30 |
| `estatus` | 2 | 0 | En Curso 7; Por Iniciar 5 |
| `resp_cli` | 6 | 6 | Dato de contacto; no se lista |
| `pm_otc` | 2 | 6 | Dato personal; no se lista |
| `version_scd` | 1 | 0 | 1 en los 12 |
| `es_actual` | 1 | 0 | 1 en los 12 |

**Fechas.** Inicio: **2021-01-01 a 2026-10-13**. Fin: **2026-09-23 a 2028-10-30**.

**Lectura para Dirección.** Solo cuatro de los doce proyectos tienen asignaciones (Asignación Indefinida, Soporte AMS, Marazzi y Migración EBS); ocho están vacíos. Seis proyectos no tienen fecha de inicio y nueve no tienen fecha de fin, así que no se puede medir su duración ni su avance. Seis no tienen PM de OTC y seis no tienen responsable del cliente. La dimensión sirve para costear, pero todavía no para gestionar el ciclo de vida del proyecto.

### 4.7 `dim_rol`

**1 rol real + 1 desconocido.** El único valor es **CONSULTOR FUNCIONAL ORACLE EBS SENIOR**.

| Atributo | Valores distintos | Nulos | Valores |
|---|---:|---:|---|
| `rol_asignado` | 1 | 0 | CONSULTOR FUNCIONAL ORACLE EBS SENIOR |

**Lectura para Dirección.** Es la dimensión más pobre del modelo: 29 de 31 asignaciones no tienen rol y caen en el miembro desconocido. Solo dos asignaciones usan el rol capturado. No se puede analizar la mezcla de roles por proyecto ni comparar el rol asignado con el puesto de la persona. Es una alerta de captura, no un problema del modelo.

### 4.8 `dim_habilidad`

**71 habilidades + 1 desconocido.** Tiene más de diez valores, así que se describe por tecnología:

| Tecnología | Habilidades | Evaluaciones | Expertos (nivel ≥ 3) | % expertos |
|---|---:|---:|---:|---:|
| Oracle EBS | 30 | 645 | 182 | 28.2% |
| Plataformas Tecnológicas | 20 | 469 | 156 | 33.3% |
| Oracle Fusion Cloud | 17 | 349 | 117 | 33.5% |
| Idiomas | 1 | 54 | 7 | 13.0% |
| Certificaciones | 1 | 12 | 12 | 100.0% |
| Otros | 2 | 0 | 0 | — |

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `cod_habilidad` | 71 | 0 | 67 códigos H (H0002–H0068) y 4 códigos S (S0001–S0005) |
| `descripcion` | 58 | 0 | 13 descripciones repetidas entre EBS y Cloud |
| `descripcion_unica` | 71 | 0 | Descripción desambiguada por tecnología |
| `tecnologia` | 6 | 0 | Las seis de la tabla |
| `tipo` | 2 | 0 | Hard 67; Soft 4 |
| `estatus` | 1 | 0 | Activo en las 71 |
| `descripcion_repetida` | 2 | 0 | 0 = 45; 1 = 26 filas (13 pares) |

**Lectura para Dirección.** El catálogo está completo, pero la matriz no: cubre 54 de 75 activos y 28 activos no tienen ninguna evaluación. De las 71 habilidades, **3 no tienen ningún experto** (Opm, Fuse y Taleo), **4 tienen un solo experto** (Ebtax, Xtr, Landed Cost y Mfg Cloud) y **2 de “Otros” no tienen evaluación** (Empatía y Manejo de Conflictos). El 44.9% de las evaluaciones son Básico y solo 16.0% Experto. La matriz mide presencia, no certificación vigente: no hay fecha de evaluación ni vencimiento.

### 4.9 `dim_activo`

**123 activos + 1 desconocido.** Tiene más de diez valores, así que se describe:

- **Tipo:** 122 laptops y 1 monitor.
- **Marca:** Dell 62; HP 26; Lenovo 24; Acer 9; ASUS 2.
- **Modelo:** 78 modelos distintos; el más frecuente es Inspiron Business 3520, con 20 equipos.
- **Proveedor:** 6 proveedores; PCEL concentra 43; 70 equipos no tienen proveedor.
- **Estatus:** los 123 están “Activo”, incluso los que las notas dicen que no funcionan.

| Atributo | Valores distintos | Nulos | Valores o rango |
|---|---:|---:|---|
| `codigo` | 123 | 0 | 123 códigos A0001–A0128 (con huecos) |
| `desc` | 2 | 0 | Computadora 122; Monitor 1 |
| `tipo` | 2 | 0 | Laptop 122; Monitor 1 |
| `marca` | 5 | 0 | Dell 62; HP 26; Lenovo 24; Acer 9; ASUS 2 |
| `modelo` | 78 | 1 | 78 modelos; Inspiron Business 3520 (20) |
| `serie` | 123 | 0 | Dato identificable; no se lista |
| `proveedor` | 6 | 70 | PCEL 43; Delivery Experts 5; Oresa Norte 2; otros tres proveedores con 1 equipo cada uno |
| `fcompra` | 35 | 70 | 2017-04-26 → 2025-09-04 |
| `estatus` | 1 | 0 | Activo en los 123 |
| `notas` | 5 | 115 | 5 equipos con nota de falla: 4 “NO FUNCIONA” y 1 “Ya no sirve” |

**Fechas.** Compra: **2017-04-26 a 2025-09-04**.

**Lectura para Dirección.** El inventario está identificado por código y serie, pero no está valorado: 70 de 123 equipos no tienen costo ni fecha de compra. Treinta y dos no tienen resguardo y nueve siguen en manos de personas dadas de baja. El valor conocido de **$567,915.55** es un piso, no el valor real. Cinco equipos con nota de falla siguen con estatus Activo y se pueden volver a asignar.

---

## 5. Respuestas a las nueve preguntas de análisis

### P1 · ¿Quiénes están asignados y quiénes no, y cuánto tiempo llevan así?

**Consulta:** `q1_resumen`, `q1_banca_por_puesto`, `q1_banca_detalle`, `q1_concentracion_cliente`.

| Indicador | Valor |
|---|---:|
| Headcount activo | 75 |
| Plantilla activa (sin familiares) | 73 |
| Asignados | 30 |
| Banca de plantilla | 43 |
| Familiares sin asignación | 2 |
| Sin asignación total | 45 |
| Utilización sobre headcount | 40.0% |
| Utilización sobre plantilla | 41.1% |

La banca de plantilla se concentra en puestos sin capturar: **15 personas sin puesto** cuestan **$690,870.17** al mes. Le siguen 4 consultores técnicos Oracle EBS Senior ($191,765.36), 3 funcionales Oracle EBS Senior ($198,040.57) y 3 funcionales Cloud + EBS Senior ($189,101.41). Los días en banca van de 45 a 7,237; el promedio más alto está en consultores técnicos Oracle EBS Senior (3,977 días) y en administración financiera Senior (3,958 días).

**Concentración por cliente.** De los 30 asignados, **23 están en Metalsa (76.7%)**, 5 en Allegion (16.7%) y 3 en Grupo Daltile (10.0%). Metalsa concentra **$1,637,865.78**, el **80.9%** del costo asignado. Es la dependencia comercial más alta del corte.

**Lectura.** La utilización del 40% es baja para una consultora que vende horas. La banca no es homogénea: hay perfiles técnicos y funcionales con más de diez años de antigüedad y sin proyecto. El problema no es solo comercial; también es de visibilidad: 15 de las 43 personas en banca no tienen puesto capturado, así que no se sabe qué perfil se está dejando de vender.

### P2 · ¿Quiénes terminan pronto y en qué proyecto y cliente?

**Consulta:** `q2_vencimientos`, `q2_resumen`.

| Ventana | Asignaciones |
|---|---:|
| ≤ 30 días | 0 |
| 31–60 días | 3 |
| 61–90 días | 0 |
| Más de 90 días | 4 |
| Sin fecha de fin | 24 |

Las 7 asignaciones con fecha de fin son:

| ID | Colaborador | Cliente | Proyecto | Fin | Días |
|---:|---|---|---|---|---:|
| 5 | OTC014 | Grupo Daltile | Marazzi | 2027-01-01 | 42 |
| 10 | OTC050 | Grupo Daltile | Marazzi | 2027-01-01 | 42 |
| 23 | OTC095 | Grupo Daltile | Marazzi | 2027-01-01 | 42 |
| 28 | OTC104 | Allegion | Migración EBS | 2027-07-01 | 223 |
| 29 | OTC105 | Allegion | Migración EBS | 2027-07-01 | 223 |
| 30 | OTC106 | Allegion | Migración EBS | 2027-07-01 | 223 |
| 31 | OTC107 | Allegion | Migración EBS | 2028-07-01 | 589 |

**Lectura.** La ventana de 30 días está vacía, no sana: las 24 asignaciones sin fecha de fin no se pueden alertar. Las tres personas de Marazzi vencen en 42 días y las tres de Migración EBS en 223; la persona OTC107 tiene la asignación más larga, hasta 2028. Sin fecha de fin no hay renovación, no hay plan de reemplazo y no hay forma de saber si el proyecto se queda sin gente.

### P3 · ¿Qué porcentaje de la nómina está asignado y cuánto cuesta la gente sin proyecto?

**Consulta:** `q3_costos`, `q3_por_cliente`.

| Concepto | Personas | Costo mensual | % de la nómina |
|---|---:|---:|---:|
| Nómina activa | 75 | $3,918,864.40 | 100.0% |
| Asignado (costo único) | 30 | $1,924,710.62 | 49.1% |
| Banca de plantilla | 43 | $1,912,228.33 | 48.8% |
| Familiares sin asignación | 2 | $81,925.45 | 2.1% |
| Sin asignación total | 45 | $1,994,153.78 | 50.9% |

**El detalle que importa.** El hecho de asignación suma **$2,025,644.02**, no $1,924,710.62. La diferencia es **$100,933.40**: una persona tiene dos asignaciones al 100% y su costo se cuenta dos veces. El costo único es el que cierra contra la nómina; el costo por fila es el que explica el hecho. Las dos cifras son correctas para preguntas distintas.

**Lectura.** La mitad de la nómina ($1.99 M) está en gente sin proyecto. La banca de plantilla cuesta $1.91 M; los familiares, $81.9 k. No es un problema menor: con 40% de utilización, OTC paga la mitad de su nómina sin generar ingreso. La concentración en Metalsa agrava el riesgo: si ese cliente ajusta, no hay cartera diversificada que absorba a la gente.

### P4 · ¿Cuál es el costo por experto en un proyecto por hora?

**Consulta:** `q4_costo_hora_puesto`, `q4_cobertura`.

| Puesto | Asignaciones | Personas | Costo hora promedio | Mínimo | Máximo | Costo mensual |
|---|---:|---:|---:|---:|---:|---:|
| No especificado | 14 | 14 | $446.89 | $212.41 | $810.56 | $1,001,034.75 |
| Consultor funcional Oracle EBS Senior | 4 | 4 | $162.31 | $87.65 | $187.20 | $103,880.64 |
| Consultor funcional Oracle Cloud Senior | 3 | 3 | $412.08 | $322.33 | $542.67 | $197,797.47 |
| Gerente de Proyectos y Operaciones | 2 | 1 | $630.83 | $630.83 | $630.83 | $201,866.80 |
| Consultor técnico Java Senior | 2 | 2 | $418.85 | $418.51 | $419.18 | $134,030.48 |
| Consultor DBA Oracle Senior | 1 | 1 | $662.81 | $662.81 | $662.81 | $106,049.90 |
| Consultor técnico Web Senior | 1 | 1 | $461.01 | $461.01 | $461.01 | $73,761.12 |
| Consultor funcional Oracle Cloud y EBS Senior | 1 | 1 | $448.06 | $448.06 | $448.06 | $71,689.12 |
| Consultor técnico Oracle EBS Senior | 1 | 1 | $381.55 | $381.55 | $381.55 | $61,048.62 |
| Consultor Kronos Senior | 1 | 1 | $238.01 | $238.01 | $238.01 | $38,080.80 |
| Consultor funcional Oracle Cloud y EBS Analista | 1 | 1 | $227.53 | $227.53 | $227.53 | $36,404.32 |

El promedio global es **$408.40/hora**, con un mínimo de **$87.65** y un máximo de **$810.56**. Las 14 asignaciones sin puesto cuestan **$1,001,034.75**, el **49.4%** del costo asignado, y su costo hora promedio es $446.89.

**Lectura.** El costo hora se puede calcular porque hay sueldo integrado en 30 de las 31 asignaciones, pero el puesto no se puede usar como criterio: 14 asignaciones caen en “No especificado” y distorsionan cualquier promedio por rol. El rango $87.65–$810.56 muestra que el costo hora depende más del perfil que del proyecto. Para cotizar, primero hay que capturar el puesto y el rol.

### P5 · ¿Cuál es el margen por cliente y por proyecto?

**Consulta:** `q5_bloqueo`, `q5_costo_por_proyecto`.

| Indicador | Valor |
|---|---:|
| Asignaciones | 31 |
| Con ingreso facturable | 0 |
| Con margen | 0 |
| Costo asignado | $2,025,644.02 |

El costo por proyecto está listo:

| Cliente | Proyecto | Personas | Costo mensual asignado |
|---|---|---:|---:|
| Metalsa | Asignación Indefinida | 18 | $1,319,330.43 |
| Metalsa | Soporte AMS Manufacta | 5 | $318,535.35 |
| Grupo Daltile | Marazzi | 3 | $222,848.98 |
| Allegion | Migración EBS | 5 | $164,929.26 |

**Lectura.** El margen está **bloqueado, no en cero**. La fuente no tiene tarifa por proyecto ni horas facturables: `tarifa_proyecto` y `registro_horas` están vacías. Cualquier margen que se publicara hoy sería inventado. La consulta deja el costo listo para el día en que el socio capture las tarifas; mientras tanto, el tablero muestra el bloqueo y la lista de datos que faltan.

### P6 · ¿Qué habilidades se tienen, en qué nivel y cuáles faltan?

**Consulta:** `q6_tecnologia`, `q6_niveles`, `q6_riesgo`, `q6_cobertura`.

| Indicador | Valor |
|---|---:|
| Habilidades en catálogo | 71 |
| Evaluaciones | 1,539 |
| Evaluaciones sin colaborador | 10 |
| Activos con matriz | 54 de 75 |
| Activos sin matriz | 28 |

La distribución por nivel es **Básico 686 (44.9%)**, **Intermedio 369 (24.1%)**, **Avanzado 230 (15.0%)** y **Experto 244 (16.0%)**. La cobertura por tecnología está en la tabla 4.8.

**Habilidades en riesgo (≤ 1 experto o sin evaluación):**

| Código | Habilidad | Tecnología | Evaluados | Expertos |
|---|---|---|---:|---:|
| H0023 | Opm | Oracle EBS | 12 | 0 |
| H0062 | Fuse | Plataformas Tecnológicas | 10 | 0 |
| H0028 | Taleo | Oracle EBS | 9 | 0 |
| H0008 | Ebtax | Oracle EBS | 20 | 1 |
| H0007 | Xtr | Oracle EBS | 15 | 1 |
| H0043 | Landed Cost | Oracle Fusion Cloud | 15 | 1 |
| H0045 | Mfg (Oracle Fusion Cloud) | Oracle Fusion Cloud | 14 | 1 |
| S0004 | Empatía | Otros | 0 | 0 |
| S0005 | Manejo de Conflictos | Otros | 0 | 0 |

**Lectura.** Hay talento, pero no está medido de forma pareja: 28 activos no tienen ninguna evaluación y 10 filas de la matriz no tienen colaborador. Tres habilidades críticas no tienen experto y cuatro dependen de una sola persona. La matriz no tiene fecha de evaluación, así que no se puede saber si un experto sigue vigente. Para staffing, la pregunta “¿quién puede cubrir este proyecto?” se puede responder con la matriz actual, pero con un margen de error alto.

### P7 · ¿Qué colaboradores están en riesgo de salir?

**Consulta:** `q7_resumen`, `q7_cohortes`, `q7_por_nomina`.

| Indicador | Valor |
|---|---:|
| Personas | 107 |
| Activos | 75 |
| Bajas | 32 |
| % de bajas | 29.9% |
| Bajas sin fecha | 18 |
| Bajas en el primer año | 7 |
| Permanencia promedio de las bajas | 25.2 meses |

**Cohortes recientes:**

| Año de ingreso | Ingresos | Bajas | % de baja | Bajas en primer año | Permanencia promedio |
|---|---:|---:|---:|---:|---:|
| 2026 | 15 | 6 | 40.0% | 6 | 4.0 meses |
| 2025 | 20 | 12 | 60.0% | 1 | 15.2 meses |
| 2024 | 20 | 7 | 35.0% | 0 | 28.2 meses |
| 2023 | 10 | 3 | 30.0% | 0 | 38.5 meses |
| 2022 | 7 | 2 | 28.6% | 0 | 50.7 meses |
| 2021 | 5 | 1 | 20.0% | 0 | 67.5 meses |

**Por esquema de nómina:** MAGNESON-SINDICATO 10 bajas de 20 personas (50.0%); SMR 7 de 36 (19.4%); sin esquema 6 de 6 (100%); OTC 100% 4 de 18 (22.2%); XERES OT-SINDICATO 4 de 10 (40.0%); extranjero 1 de 1.

**Lectura.** **25 de las 55 personas que entraron desde 2024 ya salieron (45.5%).** La cohorte 2025 es la más crítica: 12 bajas de 20 ingresos. La cohorte 2026 ya tiene 6 bajas en el primer año. Pero la rotación por periodo no se puede calcular completa: 18 de 32 bajas no tienen fecha. Lo que sí se puede afirmar es que la permanencia promedio de quienes salen es de 25.2 meses y que el esquema MAGNESON-SINDICATO concentra 10 de las 32 salidas. La causa de la baja no existe en la fuente, así que no se puede responder “por qué se va la gente”; solo “quiénes y cuándo”.

### P8 · ¿Qué equipo sigue con personas que ya salieron y cuánto vale el inventario?

**Consulta:** `q8_resumen`, `q8_marcas`, `q8_pendientes`.

| Indicador | Valor |
|---|---:|
| Activos | 123 |
| Sin costo | 70 |
| Sin resguardo | 32 |
| Pendientes de recuperar | 9 |
| Valor conocido del inventario | $567,915.55 |
| Valor pendiente de recuperar | $40,693.00 |
| Pendientes con costo | 4 de 9 |

**Por marca:**

| Marca | Equipos | Sin costo | Valor conocido |
|---|---:|---:|---:|
| Dell | 62 | 39 | $256,441.78 |
| HP | 26 | 15 | $102,109.00 |
| Lenovo | 24 | 7 | $180,101.01 |
| Acer | 9 | 8 | $13,464.76 |
| ASUS | 2 | 1 | $15,799.00 |

Los nueve equipos pendientes son laptops (ocho) y un monitor; el de mayor costo es A0010 (Lenovo, $12,189) en OTC018, seguido de A0026 (Dell, $12,006) en OTC048. Cuatro no tienen costo.

**Lectura.** El inventario está identificado, pero no valorado: 70 de 123 equipos no tienen costo ni fecha de compra. Treinta y dos no tienen resguardo y nueve siguen con personas de baja. El valor en riesgo de $40,693 es un mínimo. Además, cinco equipos con nota de falla siguen con estatus Activo; se pueden volver a asignar.

### P9 · ¿Qué tan completo y confiable está el expediente?

**Consulta:** `q9_expediente`, `q9_rangos`.

| Indicador | Valor |
|---|---:|
| Activos | 75 |
| Expediente promedio | 52.7% |
| Expedientes completos | 0 |
| Sin puesto | 29 |
| Sin departamento | 64 |
| Sin sueldo | 5 |
| Con contrato | 14 |
| Expediente en 0% | 0 |

**Distribución:** 25 activos entre 1% y 49%; 50 activos entre 50% y 99%; ninguno en 100%. El 0% no aparece entre activos, pero sí en el total de 107 (17 personas, en su mayoría bajas).

**Lectura.** El expediente no está completo en ninguna persona. El promedio activo de 52.7% es bajo para un área que depende de documentos para nómina, contratos y cumplimiento. Los huecos más graves son departamento (64 activos), puesto (29) y contrato (61 sin contrato registrado). Sin expediente completo, los demás indicadores se calculan sobre una base parcial: la utilización y el costo son confiables, pero el análisis por área, puesto y cumplimiento no.

---

## 6. Solución para Dirección

### 6.1 El tablero

El entregable visual es `dashboard/index.html`, un sitio estático de **diez secciones**:

1. **Resumen.** Utilización, costo de nómina, banca, alertas y las nueve dimensiones.
2. **Utilización.** Banca por puesto, concentración por cliente y detalle de las personas sin asignación.
3. **Costos.** Reparto de la nómina, costo por cliente, costo por proyecto y costo hora por puesto.
4. **Por terminar.** Las siete asignaciones con fecha de fin y las ventanas de 30/60/90 días.
5. **Habilidades.** Cobertura por tecnología, niveles, habilidades en riesgo y activos sin matriz.
6. **Rotación.** Bajas, cohortes, permanencia y esquema de nómina.
7. **Activos.** Inventario, costo conocido, equipos por recuperar y marcas.
8. **Expediente.** Promedio, rangos y huecos que bloquean el análisis.
9. **Dimensiones.** Selector de las nueve dimensiones con valores distintos, nulos, rangos y detalle.
10. **Modelo y SQL.** Flujo de datos, hechos, dimensiones, controles de integridad, comandos y archivos.

El tablero no usa frameworks, CDN ni build. Se abre con doble clic, funciona sin conexión y se puede publicar copiando la carpeta `dashboard/` a Firebase Hosting, Netlify, un bucket de Cloud Storage o el servidor del cliente. No publica nombres, sueldos individuales, correos, teléfonos, series ni contactos: solo agregados y IDs seudónimos.

### 6.2 Arquitectura replicable

```
Firebase HR Management
        │  exportación / Cloud Function
        ▼
Cloud Storage  ──►  Acondicionamiento M1–M14  ──►  Modelo dimensional
   (corte)              (Python)                    (9 dims + 3 hechos)
                                                        │
                              ┌─────────────────────────┴─────────────────────┐
                              ▼                                               ▼
                       BigQuery / SQLite                              Firestore
                     (consultas de Dirección)                    (lectura de la PWA)
                              │                                               │
                              └─────────────────────────┬─────────────────────┘
                                                        ▼
                                              Tablero estático / Firebase Hosting
```

**Pasos de instalación en el cliente:**

1. **Crear el proyecto de Firebase** (o reutilizar `otc-rh-agentes`) y habilitar Firestore, Auth, Storage, Functions y Hosting.
2. **Definir roles** `admin`, `rh`, `lector` y `colaborador`; los sueldos y costos individuales van a `colaboradores_privado`, solo `admin`.
3. **Exportar** las siete colecciones del sandbox a un corte con fecha; excluir Usuarios, credenciales y datos bancarios.
4. **Correr el acondicionamiento** `python src/acondicionamiento_rh.py --corte AAAA-MM-DD` (repositorio de documentación) para generar las 18 tablas.
5. **Correr el modelo** `python src/etapa5_dw.py` para generar `otc_dw.db`.
6. **Ejecutar las consultas** `python src/etapa5_consultas.py`; el runner falla si hay llaves huérfanas.
7. **Exportar el tablero** `python src/etapa5_exportar.py`.
8. **Publicar** `dashboard/` en Firebase Hosting o en el servidor del cliente.
9. **Programar** el ETL con Cloud Scheduler y dejar el corte anterior para comparar.
10. **Monitorear** las reglas de calidad: 0 huérfanos, 0 sueldos en cero, 0 asignaciones sin fecha, 0 activos sin resguardo.

### 6.3 Integración con Firebase

El repositorio de documentación ya tiene la arquitectura:

- Proyecto **`otc-rh-agentes`** en Firebase (plan Blaze).
- **Firestore** con colecciones `colaboradores`, `colaboradores_privado`, `asignaciones`, `proyectos`, `clientes`, `activos`, `departamentos`, `habilidades`, `matriz`, `calidad_datos`, `log_correcciones`, `indicadores`, `catalogos`, `config` y `sops`.
- **Auth** con roles `admin`, `rh`, `lector` y `colaborador`.
- **Storage** para CVs y documentos.
- **Functions** para los agentes y la rutina diaria.
- **Cargador** `agentes/scripts/cargar_firestore.py`, que lee `salida/otc_rh.db` y publica los documentos; separa los sueldos en `colaboradores_privado`.

La Etapa 5 se puede integrar de dos formas:

1. **BI:** cargar las 9 dimensiones y los 3 hechos a **BigQuery** y conectar el tablero o Looker Studio. Es la ruta recomendada para consultas de Dirección y para crecer a millones de filas.
2. **PWA:** publicar en Firestore una colección `analitica` con los agregados del tablero (resumen, utilización, costos, habilidades, activos y perfil de dimensiones) y leerla desde la PWA con las reglas actuales. Los datos individuales siguen en `colaboradores_privado`.

La regla de oro es la misma de la Etapa 3: **no se publica un dato individual sin rol**. El tablero de Dirección usa agregados; el detalle por persona se queda en la PWA con `admin` o `rh`.

### 6.4 Seguridad y privacidad

- **Usuarios fuera.** El módulo de Usuarios no se exporta; no hay credenciales en el repositorio ni en el tablero.
- **Datos personales fuera.** El tablero no incluye nombres, correos, teléfonos, CURP, RFC, NSS, domicilio ni datos bancarios. Solo IDs seudónimos y agregados.
- **Sueldos y costos.** En Firestore viven en `colaboradores_privado`, solo `admin`. En el tablero se muestran agregados; el detalle individual no se publica.
- **Reglas de Firestore.** Lectura por rol; escritura solo por Cloud Functions con Admin SDK. El navegador no escribe.
- **App Check.** reCAPTCHA Enterprise para las funciones y la PWA.
- **Trazabilidad.** Cada corrección del acondicionamiento queda en `log_correcciones`; cada cambio de dato en la PWA queda en la bandeja de aprobaciones.

### 6.5 Recomendaciones técnicas

| # | Recomendación | Por qué | Prioridad |
|---:|---|---|---|
| 1 | Capturar **fecha de inicio y fin** en toda asignación | Hoy 21 no tienen inicio y 24 no tienen fin; sin fechas no hay duración, vencimiento ni plan de reemplazo | Alta |
| 2 | Capturar **rol** en toda asignación | 29 de 31 no tienen rol; no se puede comparar perfil con necesidad ni tarifar por rol | Alta |
| 3 | Capturar **puesto y departamento** de los 107 colaboradores | 48 sin puesto y 95 sin área; el análisis por área y puesto es inviable | Alta |
| 4 | Capturar **tarifa por proyecto y horas facturables** | Sin ellas el margen está bloqueado; es la pregunta de negocio más importante | Alta |
| 5 | Capturar **costo y fecha de compra** de los 123 activos | 70 sin costo; el inventario de $567,915.55 es un piso | Alta |
| 6 | Capturar **fecha y causa de baja** | 18 de 32 bajas sin fecha y 0 con causa; no se puede medir rotación ni costo de reemplazo | Alta |
| 7 | Capturar **fecha de evaluación y vencimiento de certificaciones** | La matriz no tiene fecha; no se sabe si un experto sigue vigente | Media |
| 8 | Usar **catálogos por ID** en la PWA, no texto libre | Evita “PENDIENTE”, variantes de marca y descripciones duplicadas | Media |
| 9 | Cerrar **asignaciones y resguardos** al registrar una baja | 9 equipos siguen con personas de baja; riesgo de pérdida | Media |
| 10 | Validar **dedicación total ≤ 100%** | Hay una persona sobreasignada al 200%; el costo se duplica en el hecho | Media |
| 11 | Programar el **ETL mensual** y comparar cortes | Sin historia no hay tendencia; el modelo SCD2 ya está preparado | Media |
| 12 | Mover el análisis a **BigQuery** y dejar Firestore para la PWA | BigQuery es más barato y rápido para agregados; Firestore para lectura por documento | Baja |

### 6.6 Ruta de 30/60/90 días

- **30 días.** Limpiar los campos que bloquean las preguntas de negocio: fechas de asignación, rol, puesto, departamento y causa de baja. Publicar el tablero en Firebase Hosting con el corte actual.
- **60 días.** Capturar tarifas y horas; activar el margen por proyecto. Cargar el modelo a BigQuery y programar el ETL mensual.
- **90 días.** Incorporar historia SCD2 (cortes mensuales), certificaciones con vencimiento y un tablero de alertas para Dirección. Medir la utilización contra la meta del 80% y la banca contra la meta del 10%.

### 6.7 Criterios de aceptación

- El ETL corre de punta a punta y deja **0 llaves huérfanas**.
- Las 24 consultas devuelven resultados y el tablero abre sin errores.
- La suma del costo único más la banca de plantilla más los familiares cierra contra la nómina activa.
- El tablero no publica nombres, sueldos individuales ni datos personales.
- El margen se muestra como bloqueado mientras no existan tarifas y horas.
- Cualquier persona puede reproducir la corrida con los comandos de la sección 7.

---

## 7. Cómo reproducir la corrida

```bash
# 1. Dependencias
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 2. Modelo dimensional (lee data/acondicionado/)
python src/etapa5_dw.py

# 3. Consultas y validación de integridad
python src/etapa5_consultas.py

# 4. Tablero
python src/etapa5_exportar.py
python -m http.server 8000
# abrir http://localhost:8000/dashboard/
```

El ETL no requiere conexión a internet ni credenciales. La base de salida es `data/modelo/otc_dw.db`; los resultados quedan en `data/modelo/resultados_analisis.json` y el tablero en `dashboard/datos.js`.

Para revisar el perfil de dimensiones directamente en SQLite:

```bash
sqlite3 data/modelo/otc_dw.db < sql/02_perfil_dimensiones.sql
```

Para revisar una pregunta:

```bash
sqlite3 -header -column data/modelo/otc_dw.db \
  "SELECT * FROM vw_asignacion WHERE fecha_fin IS NOT NULL ORDER BY dias_para_fin;"
```

---

## 8. Límites y siguientes pasos

### 8.1 Lo que no se puede responder todavía

- **Margen por proyecto y por cliente.** Faltan tarifas y horas; `tarifa_proyecto` y `registro_horas` están vacías.
- **Rotación mensual o anual completa.** 18 de 32 bajas no tienen fecha; la cohorte sí se puede calcular, el periodo no.
- **Duración real de las asignaciones.** 21 de 31 no tienen fecha de inicio; 24 no tienen fin.
- **Antigüedad real en banca.** `dias_en_banca` usa la última asignación o, si no hay historial, la incorporación; es una cota superior.
- **Análisis por área y por puesto.** 95 sin área y 48 sin puesto.
- **Certificaciones vigentes.** No hay fecha de evaluación ni vencimiento.
- **Costo real del inventario.** 70 de 123 activos no tienen costo.
- **Historia y tendencia.** La fuente solo entrega la foto del corte; el modelo SCD2 está preparado, pero no hay versiones.

### 8.2 Lo que cambia si se captura

| Dato que falta | Pregunta que se desbloquea |
|---|---|
| Fecha de inicio y fin de asignación | Duración, vencimiento, plan de reemplazo, utilización por periodo |
| Rol | Mezcla de roles, comparación puesto-rol, tarifa por rol |
| Puesto y departamento | Costo por área, análisis por puesto, plan de carrera |
| Tarifa y horas | Ingreso, margen, rentabilidad por cliente y proyecto |
| Fecha y causa de baja | Rotación por periodo, causas, costo de reemplazo |
| Costo de activo | Valor real del inventario, depreciación, recuperación |
| Fecha de evaluación y certificación | Vigencia de habilidades, riesgo de persona clave |
| Cortes mensuales | Tendencia, estacionalidad, comparación contra metas |

---

## Anexo A · Catálogo de consultas

| Consulta | Qué devuelve |
|---|---|
| `q1_resumen` | Headcount, plantilla, asignados, banca, familiares, utilización |
| `q1_banca_por_puesto` | Personas, costo y días en banca por puesto |
| `q1_banca_detalle` | 15 personas con más días en banca |
| `q1_concentracion_cliente` | Asignados y costo por cliente |
| `q2_vencimientos` | Asignaciones con fecha de fin y ventana |
| `q2_resumen` | Conteo por ventana de 30/60/90 días |
| `q3_costos` | Nómina, asignado único, asignado por fila, banca, familiares y porcentajes |
| `q3_por_cliente` | Asignaciones, personas y costo por cliente |
| `q4_costo_hora_puesto` | Costo hora por puesto, mínimo, máximo y costo mensual |
| `q4_cobertura` | Asignaciones, sin puesto, sin rol y costo hora global |
| `q5_bloqueo` | Asignaciones con ingreso y margen (hoy 0) |
| `q5_costo_por_proyecto` | Costo y personas por proyecto |
| `q6_tecnologia` | Habilidades, evaluaciones y expertos por tecnología |
| `q6_niveles` | Distribución por nivel |
| `q6_riesgo` | Habilidades con ≤ 1 experto o sin evaluación |
| `q6_cobertura` | Activos con matriz, sin matriz y evaluaciones sin persona |
| `q7_resumen` | Bajas, porcentaje, sin fecha, primer año y permanencia |
| `q7_cohortes` | Ingresos, bajas y permanencia por año de ingreso |
| `q7_por_nomina` | Bajas por esquema de nómina |
| `q8_resumen` | Activos, sin costo, sin resguardo, pendientes y valor |
| `q8_marcas` | Equipos, sin costo y valor por marca |
| `q8_pendientes` | Equipos de personas dadas de baja |
| `q9_expediente` | Promedio, completos, sin puesto, sin área, sin sueldo y contrato |
| `q9_rangos` | Distribución del expediente por rango |

## Anexo B · Evidencia de la corrida

| Control | Resultado |
|---|---:|
| Filas `hecho_asignacion` | 31 |
| Filas `hecho_habilidad` | 1,539 |
| Filas `hecho_activo` | 123 |
| Asignaciones huérfanas | 0 |
| Habilidades huérfanas | 0 |
| Activos huérfanos | 0 |
| Costo asignado por fila | $2,025,644.02 |
| Costo asignado único | $1,924,710.62 |
| Nómina activa | $3,918,864.40 |
| Inventario conocido | $567,915.55 |
| Evaluaciones | 1,539 |
| Consultas ejecutadas | 24 |
| Atributos perfilados | 94 |

## Anexo C · Referencias

- Kimball, R. y Ross, M. (2013). *The Data Warehouse Toolkit: The Definitive Guide to Dimensional Modeling* (3a ed.). Wiley.
- Documento y cuaderno de la Etapa 3 de este repositorio: `notebooks/ETAPA_3_ACONDICIONAMIENTO_OTC.ipynb` y `data/acondicionado/`.
- Documento y cuaderno de la Etapa 4 de este repositorio: `docs/ETAPA_4.md` y `notebooks/ETAPA_4_MODELO_DIMENSIONAL_OTC.ipynb`.
- Repositorio de documentación y pipeline del equipo: https://github.com/Francovarelav/otconsultingdocumentacion.
- Firebase. *Cloud Firestore security rules* y *Firebase Hosting*. Documentación oficial.

---

**Nota final.** Este documento y el tablero son un prototipo académico construido con datos anonimizados del socio formador. No incluyen credenciales, nombres, sueldos individuales, datos bancarios ni información de contacto. Las cifras son las de la corrida del **2026-11-20** y se regeneran con los comandos de la sección 7.
