-- Check 3: Is medicatie correct toegediend in de evaluatieperiode?
-- Resultaat: 1 = ja, 0 = nee, NULL = niet van toepassing (geen medicatie).
-- NULL-waarden tellen niet mee in de score-berekening.
CREATE OR ALTER VIEW verantwoording.v_check_medicatie_toegediend AS

WITH clienten AS (

    SELECT * FROM verantwoording.v_clienten_in_zorg

),

toedieningen AS (

    SELECT * FROM verantwoording.v_medicatie_toedieningen

),

-- Meest recente overzicht per client+datum (voor peildatum)
huidige_overzichten AS (

    SELECT
        medication_chart_id,
        ROW_NUMBER() OVER (
            PARTITION BY client_id, overzicht_datum
            ORDER BY overzicht_gegenereerd_op DESC
        ) AS rn

    FROM toedieningen
    WHERE overzicht_gegenereerd_op < CAST(GETDATE() AS DATE)

),

-- Filter: in evaluatieperiode, huidig overzicht, geen 'none_scheduled'
relevante_toedieningen AS (

    SELECT
        t.client_id,
        CASE
            WHEN t.status IN ('handed', 'administered', 'prepared', 'self_managed') THEN 1
            ELSE 0
        END AS geldig_status

    FROM toedieningen AS t
    INNER JOIN huidige_overzichten AS ho
        ON ho.medication_chart_id = t.medication_chart_id
        AND ho.rn = 1
    WHERE t.ingepland_op >= DATEADD(day, -28, CAST(GETDATE() AS DATE))
      AND t.ingepland_op <= CAST(GETDATE() AS DATE)
      AND t.status != 'none_scheduled'

),

-- Per client: heeft minstens 1 geldige toediening?
per_client AS (

    SELECT
        client_id,
        MAX(geldig_status) AS medicatie_toegediend

    FROM relevante_toedieningen
    GROUP BY client_id

)

SELECT
    clienten.client_id,
    per_client.medicatie_toegediend

FROM clienten
LEFT JOIN per_client
    ON per_client.client_id = clienten.client_id;
GO
