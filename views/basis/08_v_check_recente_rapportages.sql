-- Check 2: Heeft de client rapportages in de evaluatieperiode (28 dagen)?
-- Resultaat: 1 = ja, 0 = nee.
CREATE OR ALTER VIEW verantwoording.v_check_recente_rapportages AS

WITH clienten AS (

    SELECT * FROM verantwoording.v_clienten_in_zorg

),

rapportages_in_periode AS (

    SELECT DISTINCT clientObjectId AS client_id
    FROM Ons_Plan_2.dbo.careplan_reports
    WHERE reportingDate >= DATEADD(day, -28, CAST(GETDATE() AS DATE))
      AND reportingDate <= CAST(GETDATE() AS DATE)

)

SELECT
    clienten.client_id,
    CASE
        WHEN rapportages_in_periode.client_id IS NOT NULL THEN 1
        ELSE 0
    END AS recente_rapportages

FROM clienten
LEFT JOIN rapportages_in_periode
    ON rapportages_in_periode.client_id = clienten.client_id;
GO
