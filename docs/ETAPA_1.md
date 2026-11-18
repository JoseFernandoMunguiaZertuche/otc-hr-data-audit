# Etapa 1 — Justificación y planeación

**Reto de Business Intelligence — Socio formador OTC Consulting**
**Equipo — Franco Varela Villegas, Emilio Ogaz Galván, Angelica Velez Cantu, Melissa Anahid Esparza López y José Fernando Munguía Zertuche**

## Objetivo del reto

Conocer a fondo la operación del área de Recursos Humanos de OTC Consulting y de su herramienta interna de administración de personal, explorar las fuentes de datos que esa herramienta genera y construir sobre esa evidencia una propuesta de analítica que le permita al socio tomar decisiones con datos y no solo con experiencia.

## Conocimiento de la empresa

OT Consulting, S.A. de C.V. es una consultora mexicana de tecnologías de información fundada en 2003 y con sede en Monterrey, Nuevo León, según consta en su sitio oficial otconsulting.com.mx y en registros públicos. Nació vendiendo e implementando sistemas ERP de Oracle y evolucionó hacia la consultoría de software como negocio central, con servicios de Oracle EBS y Oracle Cloud como su línea principal. Un caso público documentado por Escala 24x7 muestra la migración del ERP Oracle EBS de Grupo Quimmco a AWS realizada junto con OTC, lo que confirma su especialización en ese ecosistema.

Desde hace unos cuatro años tiene un área especializada en inteligencia artificial que ofrece agentes y estrategias de adopción de IA en procesos de negocio, y en octubre de 2025 realizó junto con Anastasia un evento público de IA aplicada, lo que confirma su alianza con esa plataforma de planeación y pronósticos. En la entrevista el socio explicó además que comercializa con socios externos las soluciones SaaS Anastasia y CPA Vision, que su área comercial atiende industrias como retail, salud, manufactura, automotriz, construcción, alimentos, servicios y seguros, que compite con Softtek y Neoris en México y con Accenture, Deloitte e IBM a nivel internacional, que reporta un margen de utilidad aproximado del 30% y que su visión es ser un referente de consultoría tecnológica en Latinoamérica para 2035. Estos últimos datos provienen de la entrevista con el socio y no de fuentes públicas.

Como es una empresa de consultoría, su principal activo es su gente, porque lo que vende son las horas, el conocimiento y las certificaciones de sus consultores. Por eso Recursos Humanos es un área estratégica para el negocio.

## Conocimiento del área donde se estará trabajando

El área de Recursos Humanos administra el capital humano de toda la organización. En la entrevista el socio describió un área comercial de unas 5 personas, un equipo de consultoría e implementación de unos 80 colaboradores, unos 20 colaboradores adicionales para proyectos específicos y el área de inteligencia artificial, además de la coordinación con un abogado externo en temas laborales y contractuales. Sus funciones principales son el reclutamiento y la selección de perfiles técnicos muy competidos en el mercado, la integración y asignación de cada colaborador a los proyectos, la capacitación y la certificación Oracle y de IA, la nómina y la administración de personal con altas y bajas, la evaluación del desempeño y el clima y el cumplimiento laboral.

## Conocimiento de la forma en que se generan las fuentes de datos

Los datos de Recursos Humanos se generan a lo largo de todo el ciclo del colaborador. En el reclutamiento se registran vacantes y candidatos, al ingresar se crea el expediente con puesto, área, fecha de ingreso, tipo de contrato y sueldo, la nómina genera pagos, prestaciones e incidencias, el registro de asignaciones muestra qué consultor trabaja en qué cliente y proyecto, y a eso se suman las habilidades y certificaciones, las evaluaciones y, al final, los datos de bajas. Toda esa información vive hoy en la herramienta interna del socio, descrita enseguida.

## Conocimiento de la herramienta de análisis actualmente usada y de los recursos tecnológicos

La empresa administra Recursos Humanos con una PWA construida a la medida y hospedada en Firebase, el sandbox HR Management que el socio compartió con el equipo. La herramienta lleva la trazabilidad del departamento con módulos de colaboradores, matriz de habilidades, asignaciones, clientes, inventario de activos y catálogos de habilidades, roles y departamentos, y permite exportar cada módulo a Excel y respaldar la base completa en JSON. Su pantalla de resumen muestra únicamente cuatro conteos y dos gráficas de dona, sin tendencias, sin filtros por periodo y sin alertas, y en la última plática el socio precisó que la solución final del reto no es modificar esta aplicación sino analizar lo que le falta para permitir un mayor análisis de la información y mostrar con un prototipo visual cómo se verían las pantallas con esos agregados.

## Conocimiento de las necesidades de información y de analítica de datos

El área necesita conocer su tasa de rotación por área y sus causas, porque reemplazar a un consultor es costoso y tardado, y medir el tiempo y el costo de contratación. Necesita medir la utilización de sus consultores, es decir qué porcentaje está asignado a proyectos y cuánto cuesta la gente que no lo está, y contar con un inventario confiable de habilidades y certificaciones con sus vencimientos. También necesita analizar el costo de personal frente al ingreso que genera cada proyecto, anticipar quién termina pronto una asignación para planear la siguiente, y planear las contrataciones según los proyectos que el área comercial espera cerrar.

## Conocimiento de los beneficios que se obtendrán de la intervención

La intervención permitirá a Recursos Humanos detectar a tiempo las causas de rotación y retener talento difícil de reemplazar, hacer más rápida y eficiente la contratación y planear las capacitaciones según los proyectos que vienen. También evitará perder proyectos por falta de consultores y pagar personal sin asignar, protegerá el margen de la empresa al controlar el costo de personal y aumentar las horas facturables, y permitirá asignar mejor a cada consultor según sus habilidades y certificaciones.

## Comprensión de las necesidades y problemáticas del usuario principal

La necesidad principal del socio es contar con un mejor control y una analítica real dentro de su herramienta de administración de personal. Los puntos clave de la problemática son la falta de orden y de validaciones en el sistema, que permite datos incompletos e inconsistentes, la falta de analítica, pues no hay métricas ni indicadores útiles para decidir más allá de los conteos básicos, la falta de funciones, porque el tablero es muy básico para cubrir a todo el departamento, y la falta de trazabilidad, porque no existe un lugar para los procesos ni para los documentos y procedimientos del área. Sobre esa problemática el equipo exploró las fuentes en la Etapa 2 y propone como solución final un análisis de brechas con el prototipo visual de un apartado de analítica, sin modificar la aplicación del socio.

## Breve descripción de las etapas del reto

En la primera etapa el equipo se familiariza con el socio, su empresa y su área de Recursos Humanos mediante la entrevista y este documento. En la segunda etapa se navegan y exploran las fuentes de datos entregadas, archivo por archivo y columna por columna, para conocerlas al cien por ciento y documentar su metadata, sus errores y sus reglas de negocio. En las etapas siguientes se definen los requerimientos de análisis y se construye la propuesta de solución con sus indicadores y su prototipo visual, justificando cada agregado por el análisis que habilita.

## Referencias

Entrevista y pláticas con el socio formador OTC Consulting y sandbox HR Management compartido por el socio. Sitio oficial de OT Consulting en otconsulting.com.mx. Escala 24x7, caso de migración de Oracle EBS de Grupo Quimmco a AWS junto con OT Consulting. Padrón de Proveedores 2025 del Tribunal Electoral de Nuevo León, registro de OT Consulting, S.A. de C.V.
