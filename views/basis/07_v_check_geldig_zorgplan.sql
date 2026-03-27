-- Check 1: Heeft de client een actief zorgplan op vandaag?
-- Resultaat: 1 = ja, 0 = nee.
CREATE OR ALTER VIEW verantwoording.v_check_geldig_zorgplan AS

WITH clienten AS (

    SELECT * FROM verantwoording.v_clienten_in_zorg

),

actieve_zorgplannen AS (

    SELECT DISTINCT cp.clientObjectId AS client_id
    FROM Ons_Plan_2.dbo.careplans AS cp
    INNER JOIN Ons_Plan_2.dbo.lst_care_plan_statuses AS st
        ON st.code = cp.status
    WHERE st.description = 'Actief'
      AND cp.beginDate <= CAST(GETDATE() AS DATE)
      AND (cp.endDate IS NULL OR cp.endDate > CAST(GETDATE() AS DATE))

)

SELECT
    clienten.client_id,
    CASE
        WHEN actieve_zorgplannen.client_id IS NOT NULL THEN 1
        ELSE 0
    END AS geldig_zorgplan

FROM clienten
LEFT JOIN actieve_zorgplannen
    ON actieve_zorgplannen.client_id = clienten.client_id;
GO
