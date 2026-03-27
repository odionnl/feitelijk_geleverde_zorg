-- OPTIONEEL: Medewerker-locatiekoppelingen via ORTEC-diensten.
-- Vereist: tabel raw_ortec.dbo.diensten (geladen via ORTEC-pipeline).
-- Sla dit bestand over als je geen ORTEC-data hebt.
CREATE OR ALTER VIEW verantwoording.medewerkers_met_dienst_locaties AS

SELECT DISTINCT
    d.employee_id                   AS medewerker_id,
    loc.locatienaam

FROM raw_ortec.dbo.diensten AS d
INNER JOIN verantwoording.locaties_met_kostenplaatsen AS loc
    ON loc.kostenplaats_id COLLATE database_default
     = d.cost_center_id COLLATE database_default
    AND loc.startdatum_koppeling <= CAST(d.start_time AS DATE)
    AND (loc.einddatum_koppeling IS NULL
         OR loc.einddatum_koppeling > CAST(d.start_time AS DATE))
WHERE d.start_time >= DATEADD(day, -28, CAST(GETDATE() AS DATE))
  AND d.start_time <= CAST(GETDATE() AS DATE);
GO
