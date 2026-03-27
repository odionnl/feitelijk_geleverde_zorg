# Verantwoording Feitelijk Geleverde Zorg

Standalone T-SQL views waarmee je per client een verantwoordingsscore (0–100%) berekent. Bedoeld voor organisaties die werken met **Nedap Ons** (OnsDB / SQL Server).

## Checks

| # | Check | Verplicht? | Resultaat |
|---|---|---|---|
| 1 | **Geldig zorgplan** — heeft de client een actief zorgplan? | Ja | 0 / 1 |
| 2 | **Recente rapportages** — zijn er rapportages in de evaluatieperiode? | Ja | 0 / 1 |
| 3 | **Medicatie afgetekend** — is medicatie correct afgetekend? | Ja | 0 / 1 / NULL (n.v.t.) |
| 4 | **Zorgplan ingezien** — is het zorgplan ingezien door zorgpersoneel op dezelfde locatie? | Nee | 0 / 1 |

De score wordt berekend als percentage van de van toepassing zijnde checks. Checks met NULL (zoals medicatie bij clienten zonder medicatie) tellen niet mee in de deler.

## Vereisten

- SQL Server 2016+ (voor `CREATE OR ALTER VIEW`)
- Leestoegang tot de Nedap Ons database (standaard: `Ons_Plan_2`)
- **Optioneel** (voor check 4): ORTEC roosterdata + RPA audit-logs zorgplaninzage

## Mapstructuur

```
00_setup.sql                    Schema aanmaken + configuratie-instructies
views/
  basis/                        Verplichte views (checks 1-3)
    01_clienten_in_zorg.sql
    02_locaties_met_kostenplaatsen.sql
    03_medewerkers_met_deskundigheidsgroepen.sql
    04_medicatie_toedieningen.sql
    07_check_geldig_zorgplan.sql
    08_check_recente_rapportages.sql
    09_check_medicatie_afgetekend.sql
  optioneel/                    Views voor check 4 (ORTEC + audit-data)
    05_zorgplan_inzage.sql
    06_medewerkers_met_dienst_locaties.sql
    10_check_zorgplan_ingezien.sql
  resultaat/                    Eindview met score per client
    11a_feitelijk_geleverde_zorg.sql   (met check 4)
    11b_feitelijk_geleverde_zorg.sql   (zonder check 4)
```

## Installatie

### Stap 1: Configuratie aanpassen

Zoek-en-vervang in **alle** SQL-bestanden:

| Zoek | Vervang door | Toelichting |
|---|---|---|
| `Ons_Plan_2` | Jouw OnsDB databasenaam | Verplicht |
| `raw_ortec` | Jouw ORTEC database/schema | Alleen voor check 4 |
| `raw_ons_audits` | Jouw audits database/schema | Alleen voor check 4 |
| `28` (in `DATEADD`) | Jouw evaluatieperiode in dagen | Standaard: 28 dagen |

### Stap 2: Scripts uitvoeren

Voer de bestanden uit in nummervolgorde op je SQL Server:

**Altijd:**
```
00_setup.sql
views/basis/01_clienten_in_zorg.sql
views/basis/02_locaties_met_kostenplaatsen.sql
views/basis/03_medewerkers_met_deskundigheidsgroepen.sql
views/basis/04_medicatie_toedieningen.sql
views/basis/07_check_geldig_zorgplan.sql
views/basis/08_check_recente_rapportages.sql
views/basis/09_check_medicatie_afgetekend.sql
```

**Met ORTEC + audit-data (4 checks):**
```
views/optioneel/05_zorgplan_inzage.sql
views/optioneel/06_medewerkers_met_dienst_locaties.sql
views/optioneel/10_check_zorgplan_ingezien.sql
views/resultaat/11a_feitelijk_geleverde_zorg.sql
```

**Zonder ORTEC/audit-data (3 checks):**
```
views/resultaat/11b_feitelijk_geleverde_zorg.sql
```

### Stap 3: Resultaat bekijken

```sql
SELECT * FROM verantwoording.feitelijk_geleverde_zorg;
```

## Databronnen

### OnsDB (verplicht)

Alle views lezen uit de standaard Nedap Ons-database (`dbo` schema):

| Tabel | Gebruikt door |
|---|---|
| `clients` | Clientgegevens |
| `care_allocations` | Actieve zorgtoewijzingen |
| `careplans` | Zorgplannen |
| `lst_care_plan_statuses` | Zorgplanstatussen |
| `careplan_reports` | Rapportages |
| `locations` | Locaties |
| `location_assignments` | Client-locatiekoppelingen |
| `costcenters` | Kostenplaatsen |
| `costcenter_assignments` | Locatie-kostenplaatskoppelingen |
| `employees` | Medewerkers |
| `expertise_profile_assignments` | Deskundigheidskoppelingen |
| `expertise_profiles` | Deskundigheden |
| `expertise_group_expertise_profiles` | Groep-deskundigheidskoppelingen |
| `expertise_groups` | Deskundigheidsgroepen |
| `administration_agreements` | Toedienafspraken |
| `medication_administrations` | Medicatietoedieningen |
| `medication_charts` | Medicatieoverzichten |
| `status_updates` | Statusupdates medicatie |

### ORTEC (optioneel)

| Tabel | Beschrijving |
|---|---|
| `diensten` | Gepubliceerde diensten met medewerker- en kostenplaats-ID |

### Audit-logs (optioneel)

| Tabel | Beschrijving |
|---|---|
| `audits` | RPA-logs van zorgplaninzage met medewerker- en clientnummer |

## Licentie

Ontwikkeld door [Odion](https://www.odion.nl). Vrij te gebruiken door andere Nedap Ons-organisaties.
