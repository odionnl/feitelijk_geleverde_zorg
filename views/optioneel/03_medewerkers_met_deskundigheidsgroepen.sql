-- Medewerkers gekoppeld aan hun deskundigheidsgroepen.
-- Grain: een rij per medewerker (personeelsnummer) x deskundigheidsgroep x periode.
-- Wordt gebruikt door de optionele check 'zorgplan ingezien'.
CREATE OR ALTER VIEW verantwoording.medewerkers_met_deskundigheidsgroepen AS

SELECT
    emp.identificationNo                AS medewerker_id,
    eg.name                             AS deskundigheidsgroep,
    epa.startTime                       AS startdatum,
    epa.endTime                         AS einddatum

FROM Ons_Plan_2.dbo.expertise_profile_assignments AS epa
INNER JOIN Ons_Plan_2.dbo.employees AS emp
    ON emp.objectId = epa.employeeObjectId
INNER JOIN Ons_Plan_2.dbo.expertise_profiles AS ep
    ON ep.objectId = epa.expertiseProfileObjectId
    AND ep.visible = 1
INNER JOIN Ons_Plan_2.dbo.expertise_group_expertise_profiles AS egep
    ON egep.expertiseProfileObjectId = ep.objectId
INNER JOIN Ons_Plan_2.dbo.expertise_groups AS eg
    ON eg.objectId = egep.expertiseGroupObjectId;
GO
