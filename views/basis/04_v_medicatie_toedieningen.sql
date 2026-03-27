-- Medicatietoedieningen met status.
-- Grain: een rij per toediening x statusupdate.
-- Filters: niet vrijgesteld, geen test-overzichten.
CREATE OR ALTER VIEW verantwoording.v_medicatie_toedieningen AS

SELECT
    ma.id                               AS toediening_id,
    mc.client_id,
    aa.medication_chart_id,
    mc.generated_at                     AS overzicht_gegenereerd_op,
    mc.date                             AS overzicht_datum,
    ma.scheduled_at                     AS ingepland_op,
    su.[to]                             AS status,
    su.created_at                       AS status_gewijzigd_op

FROM Ons_Plan_2.dbo.administration_agreements AS aa
INNER JOIN Ons_Plan_2.dbo.medication_administrations AS ma
    ON ma.administration_agreement_id = aa.id
INNER JOIN Ons_Plan_2.dbo.status_updates AS su
    ON su.medication_administration_id = ma.id
INNER JOIN Ons_Plan_2.dbo.medication_charts AS mc
    ON mc.id = aa.medication_chart_id
WHERE ma.exempt = 0
  AND mc.fake = 0;
GO
