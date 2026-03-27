-- Schema aanmaken
IF NOT EXISTS (SELECT 1
FROM sys.schemas
WHERE name = 'verantwoording')
    EXEC('CREATE SCHEMA verantwoording');
GO
