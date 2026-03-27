-- OPTIONEEL: Audit-logs van zorgplaninzage.
-- Vereist: tabel raw_ons_audits.dbo.audits (geladen via RPA-pipeline).
-- Sla dit bestand over als je geen audit-data hebt.
CREATE OR ALTER VIEW verantwoording.zorgplan_inzage AS

SELECT
    tijdstip,
    LEFT(gebruiker_medewerkernummer,
         CHARINDEX('-', gebruiker_medewerkernummer) - 1) AS medewerker_id,
    betreft_cli_nt_cli_ntnummer                          AS clientnummer

FROM raw_ons_audits.dbo.audits
WHERE gebruiker_medewerkernummer LIKE '%-%';
GO
