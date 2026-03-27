-- OPTIONEEL - Check 4: Is het zorgplan ingezien door zorgpersoneel op dezelfde locatie?
-- Vereist: views 05 (v_zorgplan_inzage) en 06 (v_medewerkers_met_dienst_locaties).
-- Sla dit bestand over als je geen ORTEC- en audit-data hebt.
-- Resultaat: 1 = ja, 0 = nee.
CREATE OR ALTER VIEW verantwoording.v_check_zorgplan_ingezien AS

WITH clienten AS (

    SELECT * FROM verantwoording.v_clienten_in_zorg

),

-- Clientnummer opzoeken voor join met audits
clienten_met_nummer AS (

    SELECT
        c.objectId         AS client_id,
        c.identificationNo AS clientnummer

    FROM Ons_Plan_2.dbo.clients AS c
    INNER JOIN verantwoording.v_clienten_in_zorg AS ci
        ON ci.client_id = c.objectId

),

client_locaties AS (

    SELECT
        la.clientObjectId   AS client_id,
        l.name              AS locatienaam

    FROM Ons_Plan_2.dbo.location_assignments AS la
    INNER JOIN Ons_Plan_2.dbo.locations AS l
        ON l.objectId = la.locationObjectId

),

-- Audits in evaluatieperiode
audits_in_periode AS (

    SELECT *
    FROM verantwoording.v_zorgplan_inzage
    WHERE tijdstip >= DATEADD(day, -28, CAST(GETDATE() AS DATE))
      AND tijdstip <= CAST(GETDATE() AS DATE)

),

-- Koppel audits aan client_id via clientnummer
audits_met_client AS (

    SELECT
        a.tijdstip,
        a.medewerker_id,
        c.client_id

    FROM audits_in_periode AS a
    INNER JOIN clienten_met_nummer AS c
        ON CAST(c.clientnummer AS VARCHAR(50)) COLLATE database_default
         = CAST(a.clientnummer AS VARCHAR(50)) COLLATE database_default

),

-- Filter: medewerker moet zorgpersoneel zijn
audits_zorgpersoneel AS (

    SELECT
        a.tijdstip,
        a.medewerker_id,
        a.client_id

    FROM audits_met_client AS a
    INNER JOIN verantwoording.v_medewerkers_met_deskundigheidsgroepen AS eg
        ON eg.medewerker_id COLLATE database_default
         = a.medewerker_id COLLATE database_default
        AND eg.deskundigheidsgroep = 'Zorgpersoneel (tbv planning & control)'
        AND eg.startdatum <= CAST(GETDATE() AS DATE)
        AND (eg.einddatum IS NULL OR eg.einddatum >= DATEADD(day, -28, CAST(GETDATE() AS DATE)))

),

-- Filter: medewerker-locatie moet overlappen met client-locatie
audits_met_locatie_overlap AS (

    SELECT DISTINCT
        az.client_id

    FROM audits_zorgpersoneel AS az
    INNER JOIN verantwoording.v_medewerkers_met_dienst_locaties AS dl
        ON dl.medewerker_id COLLATE database_default
         = az.medewerker_id COLLATE database_default
    INNER JOIN client_locaties AS cl
        ON cl.client_id = az.client_id
        AND cl.locatienaam COLLATE database_default
          = dl.locatienaam COLLATE database_default

)

SELECT
    clienten.client_id,
    CASE
        WHEN audits_met_locatie_overlap.client_id IS NOT NULL THEN 1
        ELSE 0
    END AS zorgplan_ingezien

FROM clienten
LEFT JOIN audits_met_locatie_overlap
    ON audits_met_locatie_overlap.client_id = clienten.client_id;
GO
