-- Clienten met een actieve zorgtoewijzing op vandaag.
-- Grain: een rij per actieve client.
CREATE OR ALTER VIEW verantwoording.clienten_in_zorg AS

WITH clienten AS (

    SELECT
        objectId                AS client_id,
        identificationNo        AS clientnummer,
        CONCAT(
            COALESCE(givenName, firstName),
            CASE WHEN prefix IS NOT NULL THEN ' ' + prefix ELSE '' END,
            ' ' + lastName
        )                       AS client_naam

    FROM Ons_Plan_2.dbo.clients

),

zorgtoewijzingen AS (

    SELECT
        clientObjectId          AS client_id,
        dateBegin               AS startdatum,
        dateEnd                 AS einddatum

    FROM Ons_Plan_2.dbo.care_allocations

),

actieve_zorgtoewijzingen AS (

    SELECT DISTINCT client_id
    FROM zorgtoewijzingen
    WHERE startdatum <= CAST(GETDATE() AS DATE)
      AND (einddatum IS NULL OR einddatum > CAST(GETDATE() AS DATE))

)

SELECT
    clienten.client_id,
    clienten.clientnummer,
    clienten.client_naam

FROM clienten
INNER JOIN actieve_zorgtoewijzingen
    ON actieve_zorgtoewijzingen.client_id = clienten.client_id;
GO
