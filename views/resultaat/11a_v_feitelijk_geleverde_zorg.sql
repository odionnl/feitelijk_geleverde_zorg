-- Eindresultaat: verantwoordingsscore per client (0-100%).
-- Variant MET check 4 (zorgplan ingezien).
-- Gebruik dit bestand als je bestanden 05, 06 en 10 ook hebt uitgevoerd.
-- Grain: een rij per client in zorg.
CREATE OR ALTER VIEW verantwoording.v_feitelijk_geleverde_zorg AS

WITH clienten AS (

    SELECT * FROM verantwoording.v_clienten_in_zorg

),

geldig_zorgplan AS (

    SELECT * FROM verantwoording.v_check_geldig_zorgplan

),

recente_rapportages AS (

    SELECT * FROM verantwoording.v_check_recente_rapportages

),

medicatie_afgetekend AS (

    SELECT * FROM verantwoording.v_check_medicatie_afgetekend

),

zorgplan_ingezien AS (

    SELECT * FROM verantwoording.v_check_zorgplan_ingezien

)

SELECT
    clienten.client_id,
    clienten.client_naam,

    -- Individuele checks
    COALESCE(geldig_zorgplan.geldig_zorgplan, 0)            AS geldig_zorgplan,
    COALESCE(recente_rapportages.recente_rapportages, 0)    AS recente_rapportages,
    medicatie_afgetekend.medicatie_afgetekend,
    COALESCE(zorgplan_ingezien.zorgplan_ingezien, 0)        AS zorgplan_ingezien,

    -- Score: percentage behaalde checks (dynamische deler)
    CAST(ROUND(
        (
            COALESCE(geldig_zorgplan.geldig_zorgplan, 0.0)
            + COALESCE(recente_rapportages.recente_rapportages, 0.0)
            + COALESCE(medicatie_afgetekend.medicatie_afgetekend, 0.0)
            + COALESCE(zorgplan_ingezien.zorgplan_ingezien, 0.0)
        ) * 100.0 / NULLIF(
            CASE WHEN geldig_zorgplan.client_id       IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN recente_rapportages.client_id IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN zorgplan_ingezien.client_id   IS NOT NULL THEN 1 ELSE 0 END
            + CASE WHEN medicatie_afgetekend.medicatie_afgetekend IS NOT NULL THEN 1 ELSE 0 END,
            0
        ),
    0) AS INT)                                              AS client_score,

    -- Metadata
    CAST(GETDATE() AS DATE)                                 AS peildatum,
    DATEADD(day, -28, CAST(GETDATE() AS DATE))              AS startdatum

FROM clienten
LEFT JOIN geldig_zorgplan
    ON geldig_zorgplan.client_id = clienten.client_id
LEFT JOIN recente_rapportages
    ON recente_rapportages.client_id = clienten.client_id
LEFT JOIN medicatie_afgetekend
    ON medicatie_afgetekend.client_id = clienten.client_id
LEFT JOIN zorgplan_ingezien
    ON zorgplan_ingezien.client_id = clienten.client_id;
GO
