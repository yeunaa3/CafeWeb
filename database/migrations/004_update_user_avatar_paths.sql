IF COL_LENGTH('dbo.Users', 'avatar_url') IS NULL
    ALTER TABLE dbo.Users ADD avatar_url VARCHAR(255) NULL;
GO

UPDATE dbo.Users
SET avatar_url = '/images/avatars/uploads/avatar-1-1783652576762.png'
WHERE username = 'admin01';

UPDATE dbo.Users
SET avatar_url = '/images/avatars/uploads/avatar-2-1783652661782.png'
WHERE username = 'cashier01';

UPDATE dbo.Users
SET avatar_url = '/images/avatars/uploads/avatar-6-1783652158236.png'
WHERE username = 'customer01';
GO
