USE CBMS;
GO

IF COL_LENGTH('dbo.Users', 'gender') IS NULL
BEGIN
    ALTER TABLE dbo.Users
    ADD gender NVARCHAR(10) NULL;
END;
GO

IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_Users_Gender'
)
BEGIN
    ALTER TABLE dbo.Users
    ADD CONSTRAINT CK_Users_Gender
        CHECK (gender IS NULL OR gender IN (N'Nam', N'Nữ', N'Khác'));
END;
GO
