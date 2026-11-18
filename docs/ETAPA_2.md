# Etapa 2 — Exploración de las fuentes de datos

**Reto de Business Intelligence — Socio formador OTC Consulting**
**Trabajo individual — José Fernando Munguía Zertuche, A01199357**

El código completo de esta exploración, con sus salidas como evidencia, está en el notebook `notebooks/ETAPA_2_EDA_OTC.ipynb` de este repositorio.

## Objeto de estudio

El hecho a ser analizado es la asignación de consultores a proyectos de clientes y su costo, porque OTC Consulting vende las horas y el conocimiento de su gente y su margen depende de cuántos consultores están en proyecto y cuánto cuesta cada uno. La problemática es que su herramienta interna registra la operación en ocho módulos pero no la convierte en análisis, pues su resumen solo muestra cuatro conteos y dos gráficas, y que los datos fuente traen vacíos e inconsistencias que hoy impiden calcular con confianza la utilización, el costo de la gente sin proyecto, las asignaciones por terminar y el margen por proyecto. La unidad de análisis principal es el par formado por un colaborador y un proyecto en un periodo, apoyada en el colaborador, el cliente, la habilidad y el activo como dimensiones.

## Metadata de las fuentes de datos

Las fuentes son los archivos que exporta el sandbox HR Management del socio, una PWA hospedada en Firebase, y se describen con palabras propias a partir de su contenido.

| Fuente | Descripción | Registros |
|---|---|---|
| Catalogo_Colaboradores.xlsx | Expediente operativo de cada colaborador con puesto, departamento, estatus, fechas de ingreso y baja, esquema de nómina, componentes de su sueldo y banderas de documentos de su expediente, con uid como llave y el folio id como identificador visible | 107 |
| Asignaciones_Colaboradores.xlsx | Tabla de hechos que une a cada colaborador con el cliente y el proyecto donde trabaja, el rol que desempeña, el tipo de asignación y sus fechas de inicio y fin | 31 |
| Catalogo_Clientes.xlsx | Catálogo de clientes con industria, ciudad y contacto, y en su hoja Proyectos el detalle de cada proyecto con responsable del cliente, gerente de OTC, fechas y estatus | 8 clientes y 12 proyectos |
| Catalogo_Activos.xlsx | Inventario de equipo con tipo, marca, modelo, serie, proveedor, costo y fechas de compra y garantía, y en su hoja Resguardos el historial de qué colaborador tiene cada equipo y desde cuándo | 123 activos y 91 resguardos |
| Matriz_Habilidades.xlsx | Nivel de cada colaborador en cada habilidad en formato largo, con la tecnología y el tipo de habilidad, sin fecha de evaluación | 1,539 pares de 56 colaboradores |
| Catalogo_Habilidades.xlsx | Catálogo de habilidades con código, descripción, tecnología y tipo duro o blando | 71 |
| Catalogo_Departamentos.xlsx | Catálogo de áreas con su objetivo, responsable y centro de costos | 6 |
| Catalogo_Roles.xlsx | Catálogo de puestos con nivel y departamento, incluido como fuente complementaria porque el sandbox también lo exporta | 55 |

El módulo de Usuarios se excluye a propósito de este repositorio porque contiene las credenciales de acceso a la herramienta, y el catálogo de colaboradores publicado omite los identificadores directos y los datos bancarios por protección de datos. Los correos y teléfonos ya vienen anonimizados en origen por el socio con un mismo valor para todos los registros.

## Errores, datos faltantes e inconsistencias descubiertas

| Severidad | Tabla y campo | Hallazgo | Impacto |
|---|---|---|---|
| Crítica | colaboradores, email y teléfono | Un solo correo distinto y un solo teléfono distinto en los 107 registros | No sirven como llave ni para contacto y delatan la anonimización de origen |
| Alta | colaboradores, depto | El 88.8% no tiene departamento capturado y solo se usan 2 de los 6 departamentos | No se puede analizar plantilla ni costo por área |
| Alta | colaboradores, puesto | El 44.9% tiene el puesto en PENDIENTE, un valor placeholder del catálogo | El análisis por puesto pierde casi a la mitad de la plantilla |
| Alta | colaboradores, fechabaja | 18 de las 32 bajas no tienen fecha de baja y 1 activo sí la tiene | No se puede calcular la rotación por periodo ni la antigüedad real |
| Alta | asignaciones, fin | 24 de las 31 asignaciones no tienen fecha de fin y las 31 están En Curso | No se puede saber quién termina pronto ni medir duraciones reales |
| Alta | asignaciones, inicio | 21 asignaciones usan la fecha centinela 1990-01-01 y lo mismo pasa en 35 resguardos | Las duraciones salen de décadas si se calculan directo |
| Alta | asignaciones, rol | 29 de las 31 asignaciones tienen el rol en PENDIENTE | No se puede validar que el rol asignado coincida con el puesto |
| Alta | matriz, uid_colaborador | 2 documentos de matriz apuntan a colaboradores que no existen, con 10 pares de habilidades | Basura relacional que infla los conteos de habilidades |
| Alta | activos, costo y fcompra | 70 de los 123 activos no tienen costo ni fecha de compra | El valor del inventario queda subestimado y sin base de depreciación |
| Alta | activos, fgarantia | Ningún activo tiene fecha de garantía | No se puede alertar sobre garantías por vencer |
| Alta | activos, notas y estatus | 4 equipos marcados como que no funcionan siguen con estatus Activo | Se puede seguir asignando equipo inservible |
| Alta | resguardos, f_fin | 9 resguardos abiertos pertenecen a colaboradores dados de baja | Riesgo de pérdida de equipo al no recuperarse en la salida |
| Media | clientes contra asignaciones | 5 de los 8 clientes tienen proyectos y ninguna asignación registrada, pues solo METALSA, Grupo Daltile y Allegion aparecen en asignaciones | La operación de esos clientes es invisible en la tabla de hechos |
| Media | colaboradores, doc_ | El cumplimiento documental promedio es del 45.5% y ningún colaborador tiene el expediente completo, con 22 colaboradores en cero | El semáforo de expediente no puede usarse como meta |
| Media | colaboradores, doc_contrato | La columna guarda el tipo de contrato y no un sí o no como las demás banderas de documentos | Mezcla dos significados en una misma familia de columnas |
| Media | colaboradores, sueldo | 5 colaboradores activos tienen el sueldo integrado en cero | Se subestima la nómina y el costo por experto |
| Media | matriz contra colaboradores | 7 colaboradores dados de baja siguen con habilidades en la matriz y solo 56 de 107 tienen matriz | La oferta de habilidades disponibles se sobreestima |
| Media | habilidades, descripcion | 13 descripciones repetidas con códigos distintos entre Oracle eBS y Oracle Fusion Cloud | Los conteos por habilidad se parten entre códigos equivalentes |
| Media | activos, marca | 12 variantes escritas de marca para 5 marcas reales, con diferencias de mayúsculas y espacios | Los reportes por marca salen mal agregados sin normalizar |
| Media | departamentos, responsable y centroCostos | Ningún departamento tiene responsable ni centro de costos | El catálogo de áreas no sirve para imputar costos ni responsables |
| Baja | roles contra colaboradores | 31 de los 55 puestos del catálogo no los ocupa nadie | Catálogo sin depurar que ensucia los selectores de la herramienta |

La integridad referencial del resto de las relaciones es completa, pues las asignaciones, los resguardos y los proyectos sí apuntan a registros existentes, y los puestos y departamentos capturados sí pertenecen a sus catálogos.

## Definición de las reglas de negocio para el tratamiento de los datos

Un colaborador activo debe tener una sola asignación principal vigente y puede apoyar en asignaciones secundarias solo si se registra su porcentaje de dedicación, mientras que un gerente de proyecto puede estar en varios proyectos a la vez. Toda baja debe llevar su fecha de baja y al registrarse deben cerrarse sus asignaciones y sus resguardos de equipo. Ninguna asignación es válida sin fecha de inicio real y la fecha centinela 1990-01-01 se trata como dato faltante y nunca como fecha. El puesto y el departamento son obligatorios y se toman de los catálogos por su código y no por texto libre, y el valor PENDIENTE solo se permite como estado temporal con fecha de corrección. El sueldo total integrado debe ser igual a la suma de sus componentes y se valida en cada corte. Cada habilidad de la matriz debe llevar su fecha de evaluación y su evaluador para poder medir su evolución. Las marcas de activos se normalizan en mayúsculas y sin espacios, y un equipo que no funciona cambia a baja técnica y cierra su resguardo. El costo por hora de un experto se deriva de su sueldo total integrado mensual entre 160 horas como supuesto explícito de costeo mientras el socio no entregue las horas reales facturables.

## Descripción de las preguntas de análisis detonadoras

Las preguntas que fortalecen el estudio y que deben poder responderse con datos son quiénes están asignados y quiénes no a una fecha dada y cuánto tiempo llevan así, quiénes terminan pronto una asignación y en qué proyecto y cliente, qué porcentaje de la nómina está asignado y cuánto cuesta la gente que está sin proyecto, cuál es el costo por experto en un proyecto por hora derivado de su salario mensual, cuál es el margen por cliente y por proyecto al cruzar su ingreso con el costo de su gente asignada, qué habilidades se tienen y en qué nivel y cuáles faltan para los proyectos que vienen, qué colaboradores están en riesgo de salir, qué equipo sigue en poder de personas que ya salieron y cuánto vale el inventario real, y qué tan completo y confiable está el expediente de cada colaborador para confiar en los demás indicadores.

## Definición de las métricas

Las métricas que ya existen en las fuentes son los conteos de colaboradores por estatus, las asignaciones registradas, los clientes y los proyectos, los componentes de sueldo por colaborador, los pares de habilidad por nivel y el costo registrado de los activos. Las métricas que deben agregarse son la utilización, el costo de la gente sin proyecto, el costo por hora por experto, el costo mensual por proyecto, la rotación por periodo, el cumplimiento del expediente y la cobertura de habilidades por proyecto. Con los datos actuales la utilización ya se puede calcular y es del 40.0%, pues solo 30 de los 75 colaboradores activos tienen asignación, y el 50.9% de la nómina integrada mensual está en gente sin proyecto con $1,994,153.78 de un total de $3,918,864.40.

## Definición de los indicadores necesarios para el análisis

Los indicadores necesarios son el porcentaje de utilización con su meta y su tendencia, el porcentaje y el monto de nómina asignada contra no asignada, las asignaciones por vencer en los siguientes treinta días, el costo por experto y por proyecto, el margen por proyecto, la rotación mensual y anual, el porcentaje de expediente completo, la cobertura de habilidades contra lo que pide cada proyecto y el número de alertas abiertas por vencimientos, datos faltantes e inconsistencias, todos con filtros por fecha, cliente, proyecto y departamento y con el detalle por persona detrás de cada número.

## Definición de los atributos adicionales que se requieren

Para responder las preguntas anteriores se requieren la fecha de fin real y el porcentaje de dedicación en cada asignación, el código único de proyecto ligado a su ingreso y a su tarifa facturable, las horas facturables reales por colaborador, la fecha de evaluación y el evaluador en cada habilidad de la matriz, el motivo de cada baja, el responsable y el centro de costos en cada departamento, y el registro de quién hizo cada cambio en la herramienta y cuándo.

## Evidencias de la exploración

La importación de los datos y su análisis desde el cuaderno se evidencian en el notebook `notebooks/ETAPA_2_EDA_OTC.ipynb`, que quedó ejecutado con todas sus salidas, incluyendo el perfilado de cada archivo y cada columna, la tabla de hallazgos construida por código, la evaluación de la integridad referencial y de las reglas de negocio, los primeros indicadores calculados y sus gráficas.

## Propuesta de solución final

La solución final propuesta es un análisis de brechas sobre el sandbox actual, sin modificar la aplicación del socio, en el que cada agregado se justifica por el problema que resuelve y el análisis que habilita, junto con el prototipo visual de un apartado nuevo de Analítica en el menú de su PWA y de pestañas analíticas dentro de los módulos de Asignaciones y Colaboradores. Ese apartado reuniría los indicadores de quién está en proyecto y quién libre, quién termina pronto, cuántos se van, costos y márgenes por proyecto, habilidades y vencimientos, con alertas, filtros, metas, tendencias y el detalle por persona detrás de cada número, apoyado en el saneamiento previo de las brechas críticas de seguridad y de calidad de datos, porque sin datos confiables ningún indicador nuevo sería creíble.
