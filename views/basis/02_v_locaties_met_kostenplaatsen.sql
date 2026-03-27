-- Locaties met al hun kostenplaatskoppelingen over alle tijd.
-- Grain: een rij per locatie x koppelingsperiode.
-- Wordt gebruikt door de optionele check 'zorgplan ingezien' (ORTEC-koppeling).
CREATE OR ALTER VIEW verantwoording.v_locaties_met_kostenplaatsen AS

SELECT
    l.objectId                          AS locatie_id,
    l.name                              AS locatienaam,
    l.materializedPath                  AS locatie_hierarchie_pad,
    cc.identificationNo                 AS kostenplaats_id,
    CAST(cca.beginDate AS DATE)         AS startdatum_koppeling,
    CAST(cca.endDate AS DATE)           AS einddatum_koppeling

FROM Ons_Plan_2.dbo.locations AS l
LEFT JOIN Ons_Plan_2.dbo.costcenter_assignments AS cca
    ON cca.unitObjectId = l.objectId
LEFT JOIN Ons_Plan_2.dbo.costcenters AS cc
    ON cc.objectId = cca.costcenterObjectId;
GO
