"""Construye el data warehouse dimensional de la Etapa 5.

Lee las tablas acondicionadas de la Etapa 3, aplica el modelo lógico de la
Etapa 4 y deja una base SQLite lista para consultar:

    data/modelo/otc_dw.db

También genera dos archivos de evidencia que alimentan el documento y el
tablero:

    data/modelo/perfil_dimensiones.json
    data/modelo/resumen_ejecutivo.json

Uso:
    python src/etapa5_dw.py
"""

from __future__ import annotations

import json
import math
import sqlite3
from datetime import date
from pathlib import Path

import numpy as np
import pandas as pd

RAIZ = Path(__file__).resolve().parents[1]
ORIGEN = RAIZ / "data" / "acondicionado"
DESTINO = RAIZ / "data" / "modelo"
ESQUEMA = RAIZ / "sql" / "01_esquema_dimensional.sql"
CORTE = pd.Timestamp("2026-11-20")

MESES = {
    1: "Enero", 2: "Febrero", 3: "Marzo", 4: "Abril", 5: "Mayo", 6: "Junio",
    7: "Julio", 8: "Agosto", 9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre",
}
DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]


# ---------------------------------------------------------------------------
# Utilidades
# ---------------------------------------------------------------------------

def leer(nombre: str) -> pd.DataFrame:
    return pd.read_csv(ORIGEN / f"{nombre}.csv")


def fecha(valor) -> str | None:
    """Convierte a ISO-8601 y trata la fecha centinela 1990-01-01 como nula."""
    if valor is None or (isinstance(valor, float) and math.isnan(valor)):
        return None
    marca = pd.to_datetime(valor, errors="coerce")
    if pd.isna(marca) or marca == pd.Timestamp("1990-01-01"):
        return None
    return marca.strftime("%Y-%m-%d")


def numero(valor, entero: bool = False):
    if valor is None or (isinstance(valor, float) and math.isnan(valor)):
        return None
    if pd.isna(valor):
        return None
    return int(valor) if entero else float(valor)


def escalar(valor):
    """Convierte tipos de numpy/pandas a tipos serializables por sqlite3."""
    if valor is None:
        return None
    if isinstance(valor, (np.integer,)):
        return int(valor)
    if isinstance(valor, (np.floating,)):
        return None if math.isnan(float(valor)) else float(valor)
    if isinstance(valor, (np.bool_,)):
        return int(valor)
    if isinstance(valor, float) and math.isnan(valor):
        return None
    if isinstance(valor, pd.Timestamp):
        return valor.strftime("%Y-%m-%d")
    return valor


def insertar(con: sqlite3.Connection, tabla: str, df: pd.DataFrame) -> None:
    columnas = ", ".join(df.columns)
    marcadores = ", ".join("?" for _ in df.columns)
    filas = [tuple(escalar(v) for v in fila) for fila in df.itertuples(index=False, name=None)]
    con.executemany(f"INSERT INTO {tabla} ({columnas}) VALUES ({marcadores})", filas)


def construir_tiempo() -> pd.DataFrame:
    fechas = pd.date_range("2003-01-01", "2028-12-31", freq="D")
    df = pd.DataFrame({
        "sk_tiempo": fechas.strftime("%Y%m%d").astype(int),
        "fecha": fechas.strftime("%Y-%m-%d"),
        "anio": fechas.year,
        "trimestre": fechas.quarter,
        "mes": fechas.month,
        "nombre_mes": [MESES[m] for m in fechas.month],
        "semana_iso": fechas.isocalendar().week.astype(int),
        "dia_semana": [DIAS[d] for d in fechas.dayofweek],
        "es_fin_semana": (fechas.dayofweek >= 5).astype(int),
        "anio_mes": fechas.strftime("%Y-%m"),
    })
    desconocido = pd.DataFrame([{
        "sk_tiempo": 0, "fecha": None, "anio": None, "trimestre": None, "mes": None,
        "nombre_mes": "Sin fecha", "semana_iso": None, "dia_semana": None,
        "es_fin_semana": None, "anio_mes": None,
    }])
    return pd.concat([desconocido, df], ignore_index=True)


def construir_colaborador(c: pd.DataFrame) -> pd.DataFrame:
    c = c.sort_values("id_colaborador").reset_index(drop=True)
    df = pd.DataFrame({
        "sk_colaborador": range(1, len(c) + 1),
        "id_colaborador": c.id_colaborador,
        "nombre_completo": c.nombre_completo,
        "genero": c.genero,
        "ciudad": c.ciudad,
        "estatus": c.estatus,
        "puesto": c.puesto,
        "departamento": c.departamento,
        "fecha_incorporacion": c.fecha_incorporacion.map(fecha),
        "fecha_baja": c.fecha_baja.map(fecha),
        "fecha_nacimiento": c.fecha_nacimiento.map(fecha),
        "tipo_nomina": c.tipo_nomina,
        "sueldo_neto_total": c.sueldo_neto_total,
        "sueldo_total_integrado": c.sueldo_total_integrado,
        "costo_mensual": c.costo_mensual,
        "costo_hora": c.costo_hora,
        "es_plantilla": c.es_plantilla,
        "antiguedad_meses": c.antiguedad_meses,
        "edad": c.edad,
        "baja_primer_anio": c.baja_primer_anio,
        "tiene_asignacion_vigente": c.tiene_asignacion_vigente,
        "dedicacion_total_pct": c.dedicacion_total_pct,
        "sobreasignado": c.sobreasignado,
        "dias_en_banca": c.dias_en_banca,
        "pct_expediente": c.pct_expediente,
        "expediente_completo": c.expediente_completo,
        "tiene_contrato": c.tiene_contrato,
        "inversion_equipo_col": c.inversion_equipo_col,
        "falta_puesto": c.falta_puesto,
        "falta_departamento": c.falta_departamento,
        "falta_tipo_nomina": c.falta_tipo_nomina,
        "falta_ciudad": c.falta_ciudad,
        "falta_fecha_baja": c.falta_fecha_baja,
        "falta_sueldo": c.falta_sueldo,
        "inconsistencia_estatus_fecha": c.inconsistencia_estatus_fecha,
        "version_scd": 1,
        "vigente_desde": c.fecha_incorporacion.map(fecha),
        "vigente_hasta": None,
        "es_actual": 1,
    })
    desconocido = pd.DataFrame([{
        "sk_colaborador": 0, "id_colaborador": "DESCONOCIDO",
        "nombre_completo": "No identificado", "genero": "No especificado",
        "ciudad": None, "estatus": "Desconocido", "puesto": "No especificado",
        "departamento": "No especificado", "fecha_incorporacion": None,
        "fecha_baja": None, "fecha_nacimiento": None, "tipo_nomina": None,
        "sueldo_neto_total": None, "sueldo_total_integrado": None,
        "costo_mensual": None, "costo_hora": None, "es_plantilla": 0,
        "antiguedad_meses": None, "edad": None, "baja_primer_anio": 0,
        "tiene_asignacion_vigente": 0, "dedicacion_total_pct": None,
        "sobreasignado": 0, "dias_en_banca": None, "pct_expediente": None,
        "expediente_completo": 0, "tiene_contrato": 0, "inversion_equipo_col": None,
        "falta_puesto": 0, "falta_departamento": 0, "falta_tipo_nomina": 0,
        "falta_ciudad": 0, "falta_fecha_baja": 0, "falta_sueldo": 0,
        "inconsistencia_estatus_fecha": 0, "version_scd": 0,
        "vigente_desde": None, "vigente_hasta": None, "es_actual": 1,
    }])
    return pd.concat([desconocido, df], ignore_index=True)


def construir_dims_simples(datos: dict[str, pd.DataFrame]) -> tuple[pd.DataFrame, ...]:
    puestos = datos["cat_puesto"].sort_values("id_puesto")
    dim_puesto = pd.concat([
        pd.DataFrame([{"sk_puesto": 0, "id_puesto": 0, "puesto": "No especificado"}]),
        pd.DataFrame({
            "sk_puesto": range(1, len(puestos) + 1),
            "id_puesto": puestos.id_puesto.astype(int),
            "puesto": puestos.puesto,
        }),
    ], ignore_index=True)

    areas = datos["departamento_acondicionado"].sort_values("codigo")
    dim_departamento = pd.concat([
        pd.DataFrame([{
            "sk_departamento": 0, "codigo": "D0000", "nombre": "No especificado",
            "objetivo": None, "responsable": None, "centro_costos": None,
            "estatus": "Desconocido",
        }]),
        pd.DataFrame({
            "sk_departamento": range(1, len(areas) + 1),
            "codigo": areas.codigo,
            "nombre": areas.nombre,
            "objetivo": areas.objetivo,
            "responsable": areas.responsable,
            "centro_costos": areas.centro_costos,
            "estatus": areas.estatus,
        }),
    ], ignore_index=True)

    clientes = datos["cliente_acondicionado"].sort_values("id_cliente")
    dim_cliente = pd.concat([
        pd.DataFrame([{
            "sk_cliente": 0, "id_cliente": 0, "codigo_cliente": "C0000",
            "cliente": "No especificado", "industria": None, "ciudad": None,
            "estado": None, "pais": None, "contacto_nom": None,
            "estatus": "Desconocido", "n_proyectos": None,
        }]),
        pd.DataFrame({
            "sk_cliente": range(1, len(clientes) + 1),
            "id_cliente": clientes.id_cliente.astype(int),
            "codigo_cliente": clientes.codigo_cliente,
            "cliente": clientes.cliente,
            "industria": clientes.industria,
            "ciudad": clientes.ciudad,
            "estado": clientes.estado,
            "pais": clientes.pais.replace({"Méxcio": "México", "Mèxico": "México"}),
            "contacto_nom": clientes.contacto_nom,
            "estatus": clientes.estatus,
            "n_proyectos": clientes.n_proyectos.astype("Int64"),
        }),
    ], ignore_index=True)

    proyectos = datos["proyecto_acondicionado"].sort_values("id_proyecto")
    dim_proyecto = pd.concat([
        pd.DataFrame([{
            "sk_proyecto": 0, "id_proyecto": 0, "llave_proyecto": "P000",
            "proyecto": "No especificado", "cliente": None, "fecha_inicio": None,
            "fecha_fin": None, "estatus": "Desconocido", "resp_cli": None,
            "pm_otc": None, "version_scd": 0, "es_actual": 1,
        }]),
        pd.DataFrame({
            "sk_proyecto": range(1, len(proyectos) + 1),
            "id_proyecto": proyectos.id_proyecto.astype(int),
            "llave_proyecto": proyectos.llave_proyecto,
            "proyecto": proyectos.proyecto,
            "cliente": proyectos.cliente,
            "fecha_inicio": proyectos.fecha_inicio.map(fecha),
            "fecha_fin": proyectos.fecha_fin.map(fecha),
            "estatus": proyectos.estatus,
            "resp_cli": proyectos.resp_cli,
            "pm_otc": proyectos.pm_otc,
            "version_scd": 1,
            "es_actual": 1,
        }),
    ], ignore_index=True)

    roles = sorted(datos["asignacion_acondicionada"].rol_asignado.dropna().unique())
    dim_rol = pd.concat([
        pd.DataFrame([{"sk_rol": 0, "rol_asignado": "No especificado"}]),
        pd.DataFrame({"sk_rol": range(1, len(roles) + 1), "rol_asignado": roles}),
    ], ignore_index=True)

    habilidades = datos["habilidad_acondicionada"].sort_values("cod_habilidad")
    dim_habilidad = pd.concat([
        pd.DataFrame([{
            "sk_habilidad": 0, "cod_habilidad": "H000", "descripcion": "No especificada",
            "descripcion_unica": "No especificada", "tecnologia": None,
            "tipo": None, "estatus": "Desconocido", "descripcion_repetida": 0,
        }]),
        pd.DataFrame({
            "sk_habilidad": range(1, len(habilidades) + 1),
            "cod_habilidad": habilidades.cod_habilidad,
            "descripcion": habilidades.descripcion,
            "descripcion_unica": habilidades.descripcion_unica,
            "tecnologia": habilidades.tecnologia,
            "tipo": habilidades.tipo,
            "estatus": habilidades.estatus,
            "descripcion_repetida": habilidades.descripcion_repetida,
        }),
    ], ignore_index=True)

    activos = datos["activo_acondicionado"].sort_values("codigo")
    dim_activo = pd.concat([
        pd.DataFrame([{
            "sk_activo": 0, "codigo": "A000", "desc": "No especificado", "tipo": None,
            "marca": None, "modelo": None, "serie": None, "proveedor": None,
            "fcompra": None, "estatus": "Desconocido", "notas": None,
        }]),
        pd.DataFrame({
            "sk_activo": range(1, len(activos) + 1),
            "codigo": activos.codigo,
            "desc": activos.desc,
            "tipo": activos.tipo,
            "marca": activos.marca,
            "modelo": activos.modelo,
            "serie": activos.serie,
            "proveedor": activos.proveedor,
            "fcompra": activos.fcompra.map(fecha),
            "estatus": activos.estatus,
            "notas": activos.notas,
        }),
    ], ignore_index=True)

    return dim_puesto, dim_departamento, dim_cliente, dim_proyecto, dim_rol, dim_habilidad, dim_activo


def construir_hechos(datos: dict[str, pd.DataFrame], dims: dict[str, pd.DataFrame]) -> tuple[pd.DataFrame, ...]:
    a = datos["asignacion_acondicionada"].copy()
    c = datos["colaborador_acondicionado"].copy()
    ac = datos["activo_acondicionado"].copy()
    m = datos["matriz_habilidad_long"].copy()

    persona = c.set_index("id_colaborador")
    a["costo_mensual"] = a.id_colaborador.map(persona.costo_mensual)
    a["costo_hora"] = a.id_colaborador.map(persona.costo_hora)
    a["costo_mensual_asignado"] = a.costo_mensual * a.pct_dedicacion / 100
    a["costo_hora_asignado"] = a.costo_hora * a.pct_dedicacion / 100
    a["dias_asignados"] = (
        pd.to_datetime(a.fecha_fin, errors="coerce").fillna(CORTE)
        - pd.to_datetime(a.fecha_inicio, errors="coerce")
    ).dt.days

    mapas = {
        "colaborador": dict(zip(dims["dim_colaborador"].id_colaborador, dims["dim_colaborador"].sk_colaborador)),
        "puesto": dict(zip(dims["dim_puesto"].id_puesto, dims["dim_puesto"].sk_puesto)),
        "departamento": dict(zip(dims["dim_departamento"].nombre.str.casefold(), dims["dim_departamento"].sk_departamento)),
        "cliente": dict(zip(dims["dim_cliente"].id_cliente, dims["dim_cliente"].sk_cliente)),
        "proyecto": dict(zip(dims["dim_proyecto"].id_proyecto, dims["dim_proyecto"].sk_proyecto)),
        "rol": dict(zip(dims["dim_rol"].rol_asignado, dims["dim_rol"].sk_rol)),
        "habilidad": dict(zip(dims["dim_habilidad"].cod_habilidad, dims["dim_habilidad"].sk_habilidad)),
        "activo": dict(zip(dims["dim_activo"].codigo, dims["dim_activo"].sk_activo)),
    }

    sk_puesto = a.id_colaborador.map(persona.id_puesto).map(
        lambda v: mapas["puesto"].get(int(v), 0) if pd.notna(v) else 0
    )
    sk_departamento = a.id_colaborador.map(persona.departamento).map(
        lambda v: mapas["departamento"].get(str(v).casefold(), 0) if isinstance(v, str) else 0
    )

    hecho_asignacion = pd.DataFrame({
        "sk_asignacion": range(1, len(a) + 1),
        "id_asignacion": a.id_asignacion.astype(int),
        "sk_tiempo_inicio": pd.to_datetime(a.fecha_inicio, errors="coerce").dt.strftime("%Y%m%d").fillna("0").astype(int),
        "sk_tiempo_fin": pd.to_datetime(a.fecha_fin, errors="coerce").dt.strftime("%Y%m%d").fillna("0").astype(int),
        "sk_tiempo_corte": 20261120,
        "sk_colaborador": a.id_colaborador.map(mapas["colaborador"]).fillna(0).astype(int),
        "sk_puesto": sk_puesto.fillna(0).astype(int),
        "sk_departamento": sk_departamento.fillna(0).astype(int),
        "sk_cliente": a.id_cliente.map(mapas["cliente"]).fillna(0).astype(int),
        "sk_proyecto": a.id_proyecto.map(mapas["proyecto"]).fillna(0).astype(int),
        "sk_rol": a.rol_asignado.map(mapas["rol"]).fillna(0).astype(int),
        "tipo_de_asignacion": a.tipo_de_asignacion,
        "pct_dedicacion": a.pct_dedicacion,
        "costo_mensual_asignado": a.costo_mensual_asignado.round(2),
        "costo_hora_asignado": a.costo_hora_asignado.round(2),
        "dias_asignados": a.dias_asignados,
        "dias_para_fin": a.dias_para_fin,
        "es_vigente": a.vigente.astype(int),
        "ingreso_facturable": None,
        "margen": None,
    })

    hecho_habilidad = pd.DataFrame({
        "sk_habilidad_hecho": range(1, len(m) + 1),
        "sk_colaborador": m.id_colaborador.map(mapas["colaborador"]).fillna(0).astype(int),
        "sk_habilidad": m.cod_habilidad.map(mapas["habilidad"]).fillna(0).astype(int),
        "sk_tiempo": 0,
        "nivel_num": m.nivel_num,
        "nivel_txt": m.nivel_txt,
        "brecha_nivel": None,
        "matriz_actualizada": None,
    })

    resguardo = pd.to_datetime(ac.fecha_ini, errors="coerce")
    # Solo fechas dentro del calendario de dim_tiempo; el resto cae al miembro 0.
    resguardo = resguardo.where(
        (resguardo >= pd.Timestamp("2003-01-01")) & (resguardo <= pd.Timestamp("2028-12-31"))
    )
    hecho_activo = pd.DataFrame({
        "sk_activo_hecho": range(1, len(ac) + 1),
        "sk_activo": ac.codigo.map(mapas["activo"]).fillna(0).astype(int),
        "sk_colaborador": ac.id_colaborador.map(mapas["colaborador"]).fillna(0).astype(int),
        "sk_tiempo_resguardo": resguardo.dt.strftime("%Y%m%d").fillna("0").astype(int),
        "costo": ac.costo,
        "dias_en_resguardo": (CORTE - resguardo).dt.days,
        "pendiente_recuperar": ac.pendiente_recuperar.astype(int),
        "costo_pendiente": np.where(
            ac.pendiente_recuperar.eq(1), ac.costo.fillna(0), 0.0
        ).round(2),
    })

    return hecho_asignacion, hecho_habilidad, hecho_activo


# ---------------------------------------------------------------------------
# Perfilado
# ---------------------------------------------------------------------------

def _valores(serie: pd.Series, limite: int = 10) -> dict:
    limpia = serie.dropna()
    distintos = limpia.nunique()
    resultado = {"distintos": int(distintos), "nulos": int(serie.isna().sum())}
    if distintos == 0:
        return resultado
    if distintos <= limite:
        conteo = limpia.value_counts(dropna=False)
        resultado["valores"] = [
            {"valor": str(k), "conteo": int(v)} for k, v in conteo.items()
        ]
    else:
        conteo = limpia.value_counts().head(5)
        resultado["top"] = [
            {"valor": str(k), "conteo": int(v)} for k, v in conteo.items()
        ]
    return resultado


def _convertir_tipos(serie: pd.Series) -> pd.Series:
    """Recupera el tipo real de una columna que quedó como object al concatenar."""
    if serie.dtype != object:
        return serie
    no_nulos = int(serie.notna().sum())
    if no_nulos == 0:
        return serie
    numerica = pd.to_numeric(serie, errors="coerce")
    if int(numerica.notna().sum()) == no_nulos:
        return numerica
    fechas = pd.to_datetime(serie, errors="coerce")
    if int(fechas.notna().sum()) == no_nulos:
        return fechas
    return serie


def _perfilar_columna(serie: pd.Series, nombre: str) -> dict:
    if nombre == "anio_mes":
        return {"tipo": "texto", **_valores(serie)}
    serie = _convertir_tipos(serie)
    if pd.api.types.is_datetime64_any_dtype(serie):
        validas = serie.dropna()
        return {
            "tipo": "fecha",
            "distintos": int(validas.nunique()),
            "nulos": int(serie.isna().sum()),
            "min": validas.min().strftime("%Y-%m-%d") if len(validas) else None,
            "max": validas.max().strftime("%Y-%m-%d") if len(validas) else None,
        }
    if pd.api.types.is_numeric_dtype(serie):
        validas = serie.dropna()
        base = {
            "tipo": "numero",
            "distintos": int(validas.nunique()),
            "nulos": int(serie.isna().sum()),
            "min": float(validas.min()) if len(validas) else None,
            "max": float(validas.max()) if len(validas) else None,
        }
        base.update(_valores(serie))
        return base
    base = {"tipo": "texto", **_valores(serie)}
    return base


def perfilar_dimensiones(con: sqlite3.Connection, dims: dict[str, pd.DataFrame]) -> dict:
    perfil = {}
    for nombre, df in dims.items():
        llave = df.columns[0]
        reales = df[df[llave] != 0].copy()
        for col in reales.columns:
            if col.startswith("sk_"):
                continue
            if col == "fecha" or col.startswith("fecha_") or col in {"fcompra", "vigente_desde", "vigente_hasta"}:
                reales[col] = pd.to_datetime(reales[col], errors="coerce")
        columnas = {
            col: _perfilar_columna(reales[col], col)
            for col in reales.columns if not col.startswith("sk_")
        }
        perfil[nombre] = {
            "filas_reales": int(len(reales)),
            "filas_totales": int(len(df)),
            "miembro_desconocido": int(df[llave].eq(0).sum()),
            "llave": llave,
            "columnas": columnas,
        }
    return perfil


def resumen_ejecutivo(con: sqlite3.Connection) -> dict:
    q = lambda sql: con.execute(sql).fetchone()[0]
    nomina = q("SELECT COALESCE(SUM(costo_mensual), 0) FROM dim_colaborador WHERE estatus = 'Activo'")
    asignado = q("SELECT COALESCE(SUM(costo_mensual), 0) FROM dim_colaborador WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 1")
    banca = q("SELECT COALESCE(SUM(costo_mensual), 0) FROM dim_colaborador WHERE estatus = 'Activo' AND es_plantilla = 1 AND tiene_asignacion_vigente = 0")
    familiares = q("SELECT COALESCE(SUM(costo_mensual), 0) FROM dim_colaborador WHERE estatus = 'Activo' AND es_plantilla = 0")
    return {
        "corte": CORTE.strftime("%Y-%m-%d"),
        "colaboradores": q("SELECT COUNT(*) FROM dim_colaborador WHERE sk_colaborador <> 0"),
        "plantilla_activa": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND es_plantilla = 1"),
        "activos": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo'"),
        "bajas": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Baja'"),
        "familiares_activos": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND es_plantilla = 0"),
        "asignaciones": q("SELECT COUNT(*) FROM hecho_asignacion"),
        "colaboradores_asignados": q("SELECT COUNT(DISTINCT sk_colaborador) FROM hecho_asignacion"),
        "banca_plantilla": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND es_plantilla = 1 AND tiene_asignacion_vigente = 0"),
        "sin_asignacion_total": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 0"),
        "sin_asignacion_sin_costo": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 0 AND costo_mensual IS NULL"),
        "sobreasignados": q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND sobreasignado = 1"),
        "clientes": q("SELECT COUNT(*) FROM dim_cliente WHERE sk_cliente <> 0"),
        "proyectos": q("SELECT COUNT(*) FROM dim_proyecto WHERE sk_proyecto <> 0"),
        "habilidades": q("SELECT COUNT(*) FROM dim_habilidad WHERE sk_habilidad <> 0"),
        "activos_inventario": q("SELECT COUNT(*) FROM dim_activo WHERE sk_activo <> 0"),
        "nomina_activa": round(nomina, 2),
        "costo_asignado_unico": round(asignado, 2),
        "costo_asignado_filas": round(q("SELECT COALESCE(SUM(costo_mensual_asignado), 0) FROM hecho_asignacion"), 2),
        "costo_banca": round(banca, 2),
        "costo_familiares": round(familiares, 2),
        "costo_sin_asignacion": round(banca + familiares, 2),
        "pct_nomina_asignada": round(100 * asignado / nomina, 1),
        "pct_nomina_banca": round(100 * banca / nomina, 1),
        "pct_nomina_familiares": round(100 * familiares / nomina, 1),
        "utilizacion_headcount_pct": round(100 * q("SELECT COUNT(DISTINCT sk_colaborador) FROM hecho_asignacion") / q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo'"), 1),
        "utilizacion_plantilla_pct": round(100 * q("SELECT COUNT(DISTINCT sk_colaborador) FROM hecho_asignacion") / q("SELECT COUNT(*) FROM dim_colaborador WHERE estatus = 'Activo' AND es_plantilla = 1"), 1),
        "costo_inventario": round(q("SELECT COALESCE(SUM(costo), 0) FROM hecho_activo"), 2),
        "activos_sin_costo": q("SELECT COUNT(*) FROM hecho_activo WHERE costo IS NULL"),
        "equipos_por_recuperar": q("SELECT COUNT(*) FROM hecho_activo WHERE pendiente_recuperar = 1"),
        "costo_por_recuperar": round(q("SELECT COALESCE(SUM(costo_pendiente), 0) FROM hecho_activo"), 2),
        "asignaciones_sin_rol": q("SELECT COUNT(*) FROM hecho_asignacion WHERE sk_rol = 0"),
        "asignaciones_sin_inicio": q("SELECT COUNT(*) FROM hecho_asignacion WHERE sk_tiempo_inicio = 0"),
        "evaluaciones_sin_colaborador": q("SELECT COUNT(*) FROM hecho_habilidad WHERE sk_colaborador = 0"),
    }


def main() -> None:
    DESTINO.mkdir(parents=True, exist_ok=True)
    datos = {
        nombre: leer(nombre) for nombre in [
            "colaborador_acondicionado", "asignacion_acondicionada", "proyecto_acondicionado",
            "cliente_acondicionado", "activo_acondicionado", "habilidad_acondicionada",
            "matriz_habilidad_long", "departamento_acondicionado", "kpi_habilidad", "cat_puesto",
        ]
    }

    dim_tiempo = construir_tiempo()
    dim_colaborador = construir_colaborador(datos["colaborador_acondicionado"])
    (dim_puesto, dim_departamento, dim_cliente, dim_proyecto,
     dim_rol, dim_habilidad, dim_activo) = construir_dims_simples(datos)
    dims = {
        "dim_tiempo": dim_tiempo,
        "dim_colaborador": dim_colaborador,
        "dim_puesto": dim_puesto,
        "dim_departamento": dim_departamento,
        "dim_cliente": dim_cliente,
        "dim_proyecto": dim_proyecto,
        "dim_rol": dim_rol,
        "dim_habilidad": dim_habilidad,
        "dim_activo": dim_activo,
    }

    hechos = construir_hechos(datos, dims)
    nombres_hechos = ["hecho_asignacion", "hecho_habilidad", "hecho_activo"]

    ruta = DESTINO / "otc_dw.db"
    if ruta.exists():
        ruta.unlink()
    con = sqlite3.connect(ruta)
    con.executescript(ESQUEMA.read_text(encoding="utf-8"))
    for nombre, df in dims.items():
        insertar(con, nombre, df)
    for nombre, df in zip(nombres_hechos, hechos):
        insertar(con, nombre, df)
    con.commit()

    perfil = perfilar_dimensiones(con, dims)
    resumen = resumen_ejecutivo(con)
    con.close()

    (DESTINO / "perfil_dimensiones.json").write_text(
        json.dumps(perfil, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    (DESTINO / "resumen_ejecutivo.json").write_text(
        json.dumps(resumen, ensure_ascii=False, indent=2), encoding="utf-8"
    )

    print(f"Base dimensional: {ruta}")
    for nombre, df in dims.items():
        print(f"  {nombre:20s} {len(df):>6,d} filas")
    for nombre, df in zip(nombres_hechos, hechos):
        print(f"  {nombre:20s} {len(df):>6,d} filas")
    print("\nResumen ejecutivo:")
    for clave, valor in resumen.items():
        print(f"  {clave:30s} {valor}")


if __name__ == "__main__":
    main()
