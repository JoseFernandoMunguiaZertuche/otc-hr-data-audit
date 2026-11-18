# Reto OTC Consulting — Auditoría y análisis de datos de Recursos Humanos

Repositorio del reto de Business Intelligence con socio formador **OTC Consulting** (OT Consulting, S.A. de C.V.), consultora mexicana de tecnologías de información e inteligencia artificial. El trabajo consiste en conocer la operación de su área de Recursos Humanos, explorar a fondo las fuentes de datos de su herramienta interna y proponer, a partir de evidencia, la analítica que esa herramienta necesita.

**Equipo** — Franco Varela Villegas (A01199186), Emilio Ogaz Galván (A01572029), Angelica Velez Cantu (A01199359), Melissa Anahid Esparza López (A01286887) y José Fernando Munguía Zertuche (A01199357). La exploración de datos de la Etapa 2 y su notebook son el trabajo individual de José Fernando Munguía Zertuche.

## La herramienta del socio

OTC administra su capital humano en una PWA construida a la medida y hospedada en Firebase, el sandbox HR Management, con módulos de colaboradores, matriz de habilidades, asignaciones, clientes y proyectos, inventario de activos y catálogos de habilidades, roles y departamentos. Su pantalla de resumen muestra solo cuatro conteos y dos gráficas, por lo que registra la operación pero no la convierte en análisis para decidir.

## Estructura

- `docs/ETAPA_1.md` — Justificación y planeación. Conocimiento de la empresa y del área, necesidades de información y de analítica, herramienta actual, beneficios esperados y problemáticas del usuario principal.
- `docs/ETAPA_2.md` — Exploración de las fuentes de datos. Objeto de estudio, metadata, errores y datos faltantes e inconsistencias, reglas de negocio, preguntas de análisis, métricas, indicadores y atributos adicionales, y la propuesta de solución final.
- `notebooks/ETAPA_2_EDA_OTC.ipynb` — Notebook ejecutado con el análisis exploratorio completo, archivo por archivo y columna por columna, con las evidencias de cada cálculo.
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

## Propuesta de solución final

Un análisis de brechas sobre el sandbox actual, sin modificar la aplicación del socio, junto con el prototipo visual de un apartado nuevo de Analítica en el menú de su PWA. Ese apartado reuniría los indicadores de quién está en proyecto y quién libre, quién termina pronto, cuántos se van, costos y márgenes por proyecto, habilidades y vencimientos, con alertas, filtros, metas, tendencias y el detalle por persona detrás de cada número, además de pestañas analíticas dentro de los módulos de Asignaciones y Colaboradores.

## Cómo ejecutar el análisis

```bash
pip install -r requirements.txt
jupyter nbconvert --to notebook --execute --inplace notebooks/ETAPA_2_EDA_OTC.ipynb
```

El notebook lee los archivos de `data/excel/` y no requiere conexión a internet ni credenciales.

## Aviso de privacidad

Este repositorio es **privado**. Contiene datos operativos que el socio formador compartió con fines exclusivamente académicos, ya anonimizados en origen, y no debe hacerse público ni compartirse fuera del equipo y del curso. No contiene contraseñas, credenciales de acceso ni datos bancarios.
