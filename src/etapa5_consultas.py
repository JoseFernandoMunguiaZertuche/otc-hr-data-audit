"""Ejecuta las consultas de la Etapa 5 y guarda la evidencia.

Lee `sql/03_preguntas_analisis.sql`, ejecuta cada bloque marcado con
`-- @consulta <nombre>` contra `data/modelo/otc_dw.db` y escribe:

    data/modelo/resultados_analisis.json

También valida la integridad referencial y los totales contra las etapas
anteriores. Uso:
    python src/etapa5_consultas.py
"""

from __future__ import annotations

import json
import math
import re
import sqlite3
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[1]
DB = RAIZ / "data" / "modelo" / "otc_dw.db"
SQL = RAIZ / "sql" / "03_preguntas_analisis.sql"
SALIDA = RAIZ / "data" / "modelo" / "resultados_analisis.json"


def bloques(texto: str) -> dict[str, str]:
    marcas = list(re.finditer(r"^-- @consulta (\w+)\s*$", texto, flags=re.M))
    resultado = {}
    for i, marca in enumerate(marcas):
        inicio = marca.end()
        fin = marcas[i + 1].start() if i + 1 < len(marcas) else len(texto)
        consulta = texto[inicio:fin].strip()
        consulta = "\n".join(
            linea for linea in consulta.splitlines()
            if not linea.lstrip().startswith("--")
        ).strip()
        resultado[marca.group(1)] = consulta
    return resultado


def limpio(valor):
    if isinstance(valor, float) and (math.isnan(valor) or math.isinf(valor)):
        return None
    return valor


def ejecutar(con: sqlite3.Connection, sql: str) -> list[dict]:
    cur = con.execute(sql)
    columnas = [d[0] for d in cur.description]
    return [
        {c: limpio(v) for c, v in zip(columnas, fila)}
        for fila in cur.fetchall()
    ]


def integridad(con: sqlite3.Connection) -> dict:
    q = lambda sql: con.execute(sql).fetchone()[0]
    return {
        "filas_dimensiones": {
            tabla: q(f"SELECT COUNT(*) FROM {tabla}")
            for tabla in [
                "dim_tiempo", "dim_colaborador", "dim_puesto", "dim_departamento",
                "dim_cliente", "dim_proyecto", "dim_rol", "dim_habilidad", "dim_activo",
            ]
        },
        "filas_hechos": {
            tabla: q(f"SELECT COUNT(*) FROM {tabla}")
            for tabla in ["hecho_asignacion", "hecho_habilidad", "hecho_activo"]
        },
        "asignaciones_huerfanas": q("""
            SELECT COUNT(*) FROM hecho_asignacion f
            WHERE NOT EXISTS (SELECT 1 FROM dim_colaborador d WHERE d.sk_colaborador = f.sk_colaborador)
               OR NOT EXISTS (SELECT 1 FROM dim_puesto d WHERE d.sk_puesto = f.sk_puesto)
               OR NOT EXISTS (SELECT 1 FROM dim_departamento d WHERE d.sk_departamento = f.sk_departamento)
               OR NOT EXISTS (SELECT 1 FROM dim_cliente d WHERE d.sk_cliente = f.sk_cliente)
               OR NOT EXISTS (SELECT 1 FROM dim_proyecto d WHERE d.sk_proyecto = f.sk_proyecto)
               OR NOT EXISTS (SELECT 1 FROM dim_rol d WHERE d.sk_rol = f.sk_rol)
               OR NOT EXISTS (SELECT 1 FROM dim_tiempo d WHERE d.sk_tiempo = f.sk_tiempo_inicio)
               OR NOT EXISTS (SELECT 1 FROM dim_tiempo d WHERE d.sk_tiempo = f.sk_tiempo_fin)
               OR NOT EXISTS (SELECT 1 FROM dim_tiempo d WHERE d.sk_tiempo = f.sk_tiempo_corte)
        """),
        "habilidades_huerfanas": q("""
            SELECT COUNT(*) FROM hecho_habilidad f
            WHERE NOT EXISTS (SELECT 1 FROM dim_colaborador d WHERE d.sk_colaborador = f.sk_colaborador)
               OR NOT EXISTS (SELECT 1 FROM dim_habilidad d WHERE d.sk_habilidad = f.sk_habilidad)
               OR NOT EXISTS (SELECT 1 FROM dim_tiempo d WHERE d.sk_tiempo = f.sk_tiempo)
        """),
        "activos_huerfanos": q("""
            SELECT COUNT(*) FROM hecho_activo f
            WHERE NOT EXISTS (SELECT 1 FROM dim_activo d WHERE d.sk_activo = f.sk_activo)
               OR NOT EXISTS (SELECT 1 FROM dim_colaborador d WHERE d.sk_colaborador = f.sk_colaborador)
               OR NOT EXISTS (SELECT 1 FROM dim_tiempo d WHERE d.sk_tiempo = f.sk_tiempo_resguardo)
        """),
        "costo_asignado_filas": round(q("SELECT SUM(costo_mensual_asignado) FROM hecho_asignacion"), 2),
        "costo_asignado_unico": round(q("""
            SELECT SUM(costo_mensual) FROM dim_colaborador
            WHERE estatus = 'Activo' AND tiene_asignacion_vigente = 1
        """), 2),
        "nomina_activa": round(q("SELECT SUM(costo_mensual) FROM dim_colaborador WHERE estatus = 'Activo'"), 2),
        "costo_inventario": round(q("SELECT SUM(costo) FROM hecho_activo"), 2),
        "evaluaciones": q("SELECT COUNT(*) FROM hecho_habilidad"),
    }


def main() -> None:
    if not DB.exists():
        raise SystemExit(f"No existe {DB}. Corre primero src/etapa5_dw.py")
    consultas = bloques(SQL.read_text(encoding="utf-8"))
    con = sqlite3.connect(DB)
    resultados = {}
    for nombre, consulta in consultas.items():
        filas = ejecutar(con, consulta)
        resultados[nombre] = {
            "sql": consulta,
            "filas": filas,
        }
        print(f"{nombre:26s} {len(filas):>3d} filas")

    resultados["_integridad"] = integridad(con)
    con.close()

    SALIDA.write_text(
        json.dumps(resultados, ensure_ascii=False, indent=2, default=str),
        encoding="utf-8",
    )

    print("\nIntegridad:")
    for clave, valor in resultados["_integridad"].items():
        print(f"  {clave:24s} {valor}")
    print(f"\nGuardado en {SALIDA}")


if __name__ == "__main__":
    main()
