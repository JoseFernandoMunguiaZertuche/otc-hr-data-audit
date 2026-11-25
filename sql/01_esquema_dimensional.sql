-- =====================================================================
-- Reto OTC Consulting — Etapa 5
-- Esquema físico del modelo dimensional lógico (Etapa 4)
-- Motor: SQLite 3. Las claves sustitutas son enteros y la fila 0 de
-- cada dimensión representa al miembro desconocido.
-- =====================================================================

PRAGMA foreign_keys = ON;

DROP VIEW  IF EXISTS vw_activo;
DROP VIEW  IF EXISTS vw_habilidad;
DROP VIEW  IF EXISTS vw_asignacion;
DROP TABLE IF EXISTS hecho_activo;
DROP TABLE IF EXISTS hecho_habilidad;
DROP TABLE IF EXISTS hecho_asignacion;
DROP TABLE IF EXISTS dim_activo;
DROP TABLE IF EXISTS dim_habilidad;
DROP TABLE IF EXISTS dim_rol;
DROP TABLE IF EXISTS dim_proyecto;
DROP TABLE IF EXISTS dim_cliente;
DROP TABLE IF EXISTS dim_departamento;
DROP TABLE IF EXISTS dim_puesto;
DROP TABLE IF EXISTS dim_colaborador;
DROP TABLE IF EXISTS dim_tiempo;

-- ---------------------------------------------------------------------
-- DIMENSIONES
-- ---------------------------------------------------------------------

CREATE TABLE dim_tiempo (
    sk_tiempo       INTEGER PRIMARY KEY,   -- AAAAMMDD; 0 = sin fecha
    fecha           TEXT,
    anio            INTEGER,
    trimestre       INTEGER,
    mes             INTEGER,
    nombre_mes      TEXT,
    semana_iso      INTEGER,
    dia_semana      TEXT,
    es_fin_semana   INTEGER,
    anio_mes        TEXT
);

CREATE TABLE dim_colaborador (
    sk_colaborador              INTEGER PRIMARY KEY,
    id_colaborador              TEXT NOT NULL,
    nombre_completo             TEXT,
    genero                      TEXT,
    ciudad                      TEXT,
    estatus                     TEXT,
    puesto                      TEXT,
    departamento                TEXT,
    fecha_incorporacion         TEXT,
    fecha_baja                  TEXT,
    fecha_nacimiento            TEXT,
    tipo_nomina                 TEXT,
    sueldo_neto_total           REAL,
    sueldo_total_integrado      REAL,
    costo_mensual               REAL,
    costo_hora                  REAL,
    es_plantilla                INTEGER,
    antiguedad_meses            REAL,
    edad                        REAL,
    baja_primer_anio            INTEGER,
    tiene_asignacion_vigente    INTEGER,
    dedicacion_total_pct        REAL,
    sobreasignado               INTEGER,
    dias_en_banca               REAL,
    pct_expediente              REAL,
    expediente_completo         INTEGER,
    tiene_contrato              INTEGER,
    inversion_equipo_col        REAL,
    falta_puesto                INTEGER,
    falta_departamento          INTEGER,
    falta_tipo_nomina           INTEGER,
    falta_ciudad                INTEGER,
    falta_fecha_baja            INTEGER,
    falta_sueldo                INTEGER,
    inconsistencia_estatus_fecha INTEGER,
    version_scd                 INTEGER,
    vigente_desde               TEXT,
    vigente_hasta               TEXT,
    es_actual                   INTEGER
);

CREATE TABLE dim_puesto (
    sk_puesto   INTEGER PRIMARY KEY,
    id_puesto   INTEGER NOT NULL,
    puesto      TEXT
);

CREATE TABLE dim_departamento (
    sk_departamento INTEGER PRIMARY KEY,
    codigo          TEXT NOT NULL,
    nombre          TEXT,
    objetivo        TEXT,
    responsable     TEXT,
    centro_costos   TEXT,
    estatus         TEXT
);

CREATE TABLE dim_cliente (
    sk_cliente      INTEGER PRIMARY KEY,
    id_cliente      INTEGER NOT NULL,
    codigo_cliente  TEXT,
    cliente         TEXT,
    industria       TEXT,
    ciudad          TEXT,
    estado          TEXT,
    pais            TEXT,
    contacto_nom    TEXT,
    estatus         TEXT,
    n_proyectos     INTEGER
);

CREATE TABLE dim_proyecto (
    sk_proyecto     INTEGER PRIMARY KEY,
    id_proyecto     INTEGER NOT NULL,
    llave_proyecto  TEXT,
    proyecto        TEXT,
    cliente         TEXT,
    fecha_inicio    TEXT,
    fecha_fin       TEXT,
    estatus         TEXT,
    resp_cli        TEXT,
    pm_otc          TEXT,
    version_scd     INTEGER,
    es_actual       INTEGER
);

CREATE TABLE dim_rol (
    sk_rol          INTEGER PRIMARY KEY,
    rol_asignado    TEXT NOT NULL
);

CREATE TABLE dim_habilidad (
    sk_habilidad            INTEGER PRIMARY KEY,
    cod_habilidad           TEXT NOT NULL,
    descripcion             TEXT,
    descripcion_unica       TEXT,
    tecnologia              TEXT,
    tipo                    TEXT,
    estatus                 TEXT,
    descripcion_repetida    INTEGER
);

CREATE TABLE dim_activo (
    sk_activo       INTEGER PRIMARY KEY,
    codigo          TEXT NOT NULL,
    desc            TEXT,
    tipo            TEXT,
    marca           TEXT,
    modelo          TEXT,
    serie           TEXT,
    proveedor       TEXT,
    fcompra         TEXT,
    estatus         TEXT,
    notas           TEXT
);

-- ---------------------------------------------------------------------
-- HECHOS
-- ---------------------------------------------------------------------

CREATE TABLE hecho_asignacion (
    sk_asignacion           INTEGER PRIMARY KEY,
    id_asignacion           INTEGER NOT NULL,
    sk_tiempo_inicio        INTEGER NOT NULL,
    sk_tiempo_fin           INTEGER NOT NULL,
    sk_tiempo_corte         INTEGER NOT NULL,
    sk_colaborador          INTEGER NOT NULL,
    sk_puesto               INTEGER NOT NULL,
    sk_departamento         INTEGER NOT NULL,
    sk_cliente              INTEGER NOT NULL,
    sk_proyecto             INTEGER NOT NULL,
    sk_rol                  INTEGER NOT NULL,
    tipo_de_asignacion      TEXT,
    pct_dedicacion          REAL,
    costo_mensual_asignado  REAL,
    costo_hora_asignado     REAL,
    dias_asignados          INTEGER,
    dias_para_fin           INTEGER,
    es_vigente              INTEGER,
    ingreso_facturable      REAL,
    margen                  REAL,
    FOREIGN KEY (sk_tiempo_inicio)  REFERENCES dim_tiempo (sk_tiempo),
    FOREIGN KEY (sk_tiempo_fin)     REFERENCES dim_tiempo (sk_tiempo),
    FOREIGN KEY (sk_tiempo_corte)   REFERENCES dim_tiempo (sk_tiempo),
    FOREIGN KEY (sk_colaborador)    REFERENCES dim_colaborador (sk_colaborador),
    FOREIGN KEY (sk_puesto)         REFERENCES dim_puesto (sk_puesto),
    FOREIGN KEY (sk_departamento)   REFERENCES dim_departamento (sk_departamento),
    FOREIGN KEY (sk_cliente)        REFERENCES dim_cliente (sk_cliente),
    FOREIGN KEY (sk_proyecto)       REFERENCES dim_proyecto (sk_proyecto),
    FOREIGN KEY (sk_rol)            REFERENCES dim_rol (sk_rol)
);

CREATE TABLE hecho_habilidad (
    sk_habilidad_hecho  INTEGER PRIMARY KEY,
    sk_colaborador      INTEGER NOT NULL,
    sk_habilidad        INTEGER NOT NULL,
    sk_tiempo           INTEGER NOT NULL,
    nivel_num           INTEGER,
    nivel_txt           TEXT,
    brecha_nivel        INTEGER,
    matriz_actualizada  INTEGER,
    FOREIGN KEY (sk_colaborador) REFERENCES dim_colaborador (sk_colaborador),
    FOREIGN KEY (sk_habilidad)   REFERENCES dim_habilidad (sk_habilidad),
    FOREIGN KEY (sk_tiempo)      REFERENCES dim_tiempo (sk_tiempo)
);

CREATE TABLE hecho_activo (
    sk_activo_hecho     INTEGER PRIMARY KEY,
    sk_activo           INTEGER NOT NULL,
    sk_colaborador      INTEGER NOT NULL,
    sk_tiempo_resguardo INTEGER NOT NULL,
    costo               REAL,
    dias_en_resguardo   INTEGER,
    pendiente_recuperar INTEGER,
    costo_pendiente     REAL,
    FOREIGN KEY (sk_activo)           REFERENCES dim_activo (sk_activo),
    FOREIGN KEY (sk_colaborador)      REFERENCES dim_colaborador (sk_colaborador),
    FOREIGN KEY (sk_tiempo_resguardo) REFERENCES dim_tiempo (sk_tiempo)
);

-- ---------------------------------------------------------------------
-- ÍNDICES
-- ---------------------------------------------------------------------

CREATE INDEX ix_asig_colaborador  ON hecho_asignacion (sk_colaborador);
CREATE INDEX ix_asig_cliente      ON hecho_asignacion (sk_cliente);
CREATE INDEX ix_asig_proyecto     ON hecho_asignacion (sk_proyecto);
CREATE INDEX ix_asig_tiempo_ini   ON hecho_asignacion (sk_tiempo_inicio);
CREATE INDEX ix_asig_tiempo_fin   ON hecho_asignacion (sk_tiempo_fin);
CREATE INDEX ix_hab_colaborador   ON hecho_habilidad (sk_colaborador);
CREATE INDEX ix_hab_habilidad     ON hecho_habilidad (sk_habilidad);
CREATE INDEX ix_act_colaborador   ON hecho_activo (sk_colaborador);

-- ---------------------------------------------------------------------
-- VISTAS DE CONSUMO (nombres legibles para el tablero y el reporte)
-- ---------------------------------------------------------------------

CREATE VIEW vw_asignacion AS
SELECT
    f.sk_asignacion,
    f.id_asignacion,
    co.id_colaborador,
    co.nombre_completo,
    co.estatus              AS estatus_colaborador,
    co.puesto               AS puesto_colaborador,
    co.departamento         AS departamento_colaborador,
    pu.puesto               AS puesto_catalogo,
    de.nombre               AS departamento,
    cl.cliente,
    cl.industria,
    pr.proyecto,
    pr.estatus              AS estatus_proyecto,
    ro.rol_asignado,
    f.tipo_de_asignacion,
    ti.fecha                AS fecha_inicio,
    tf.fecha                AS fecha_fin,
    tc.fecha                AS fecha_corte,
    f.pct_dedicacion,
    f.costo_mensual_asignado,
    f.costo_hora_asignado,
    f.dias_asignados,
    f.dias_para_fin,
    f.es_vigente,
    f.ingreso_facturable,
    f.margen
FROM hecho_asignacion f
JOIN dim_colaborador  co ON co.sk_colaborador  = f.sk_colaborador
JOIN dim_puesto       pu ON pu.sk_puesto       = f.sk_puesto
JOIN dim_departamento de ON de.sk_departamento = f.sk_departamento
JOIN dim_cliente      cl ON cl.sk_cliente      = f.sk_cliente
JOIN dim_proyecto     pr ON pr.sk_proyecto     = f.sk_proyecto
JOIN dim_rol          ro ON ro.sk_rol          = f.sk_rol
JOIN dim_tiempo       ti ON ti.sk_tiempo       = f.sk_tiempo_inicio
JOIN dim_tiempo       tf ON tf.sk_tiempo       = f.sk_tiempo_fin
JOIN dim_tiempo       tc ON tc.sk_tiempo       = f.sk_tiempo_corte;

CREATE VIEW vw_habilidad AS
SELECT
    f.sk_habilidad_hecho,
    co.id_colaborador,
    co.nombre_completo,
    co.estatus AS estatus_colaborador,
    ha.cod_habilidad,
    ha.descripcion_unica,
    ha.tecnologia,
    ha.tipo,
    f.nivel_num,
    f.nivel_txt,
    ti.fecha AS fecha_evaluacion
FROM hecho_habilidad f
JOIN dim_colaborador co ON co.sk_colaborador = f.sk_colaborador
JOIN dim_habilidad   ha ON ha.sk_habilidad   = f.sk_habilidad
JOIN dim_tiempo      ti ON ti.sk_tiempo      = f.sk_tiempo;

CREATE VIEW vw_activo AS
SELECT
    f.sk_activo_hecho,
    ac.codigo,
    ac.desc,
    ac.tipo,
    ac.marca,
    ac.modelo,
    co.id_colaborador,
    co.nombre_completo,
    co.estatus AS estatus_colaborador,
    ti.fecha AS fecha_resguardo,
    f.costo,
    f.dias_en_resguardo,
    f.pendiente_recuperar,
    f.costo_pendiente
FROM hecho_activo f
JOIN dim_activo      ac ON ac.sk_activo      = f.sk_activo
JOIN dim_colaborador co ON co.sk_colaborador = f.sk_colaborador
JOIN dim_tiempo      ti ON ti.sk_tiempo      = f.sk_tiempo_resguardo;
