-- =====================================================
-- Script de Criação da Base de Dados BasisBook para SQL Server
-- Database: BasisBookDb
-- =====================================================

-- IMPORTANTE: Execute este script no SQL Server Management Studio ou sqlcmd

-- 1. Criar a database se não existir
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BasisBookDb')
BEGIN
    CREATE DATABASE [BasisBookDb];
END
GO

USE [BasisBookDb];
GO

-- 2. Tabela de controle de migrações (EF Core)
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='__EFMigrationsHistory' AND xtype='U')
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] NVARCHAR(150) NOT NULL,
        [ProductVersion] NVARCHAR(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
 );
END
GO

-- 3. Tabela de Assuntos
IF EXISTS (SELECT * FROM sysobjects WHERE name='Assunto' AND xtype='U')
    DROP TABLE [Assunto];
GO

CREATE TABLE [Assunto] (
    [CodAs] INT NOT NULL IDENTITY(1,1),
    [Descricao] NVARCHAR(20) NOT NULL,
    [Id] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
CONSTRAINT [PK_Assunto] PRIMARY KEY ([CodAs])
);
GO

CREATE INDEX [IX_Assunto_Descricao] ON [Assunto] ([Descricao]);
CREATE INDEX [IX_Assunto_IsDeleted] ON [Assunto] ([IsDeleted]);
GO

-- 4. Tabela de Autores
IF EXISTS (SELECT * FROM sysobjects WHERE name='Autor' AND xtype='U')
    DROP TABLE [Autor];
GO

CREATE TABLE [Autor] (
    [CodAu] INT NOT NULL IDENTITY(1,1),
    [Nome] NVARCHAR(40) NOT NULL,
    [Id] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
 [IsDeleted] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Autor] PRIMARY KEY ([CodAu])
);
GO

CREATE INDEX [IX_Autor_Nome] ON [Autor] ([Nome]);
CREATE INDEX [IX_Autor_IsDeleted] ON [Autor] ([IsDeleted]);
GO

-- 5. Tabela de Formas de Compra
IF EXISTS (SELECT * FROM sysobjects WHERE name='FormaCompra' AND xtype='U')
    DROP TABLE [FormaCompra];
GO

CREATE TABLE [FormaCompra] (
  [Id] INT NOT NULL IDENTITY(1,1),
    [Nome] NVARCHAR(50) NOT NULL,
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_FormaCompra] PRIMARY KEY ([Id])
);
GO

CREATE INDEX [IX_FormaCompra_Nome] ON [FormaCompra] ([Nome]);
CREATE INDEX [IX_FormaCompra_IsDeleted] ON [FormaCompra] ([IsDeleted]);
GO

-- 6. Tabela de Livros
IF EXISTS (SELECT * FROM sysobjects WHERE name='Livro' AND xtype='U')
    DROP TABLE [Livro];
GO

CREATE TABLE [Livro] (
    [Codl] INT NOT NULL IDENTITY(1,1),
    [Titulo] NVARCHAR(40) NOT NULL,
    [Editora] NVARCHAR(40) NOT NULL,
 [Edicao] INT NOT NULL,
[AnoPublicacao] NVARCHAR(4) NOT NULL,
    [Id] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
    [CreatedAt] DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    [UpdatedAt] DATETIME2 NULL,
    [IsDeleted] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_Livro] PRIMARY KEY ([Codl])
);
GO

CREATE INDEX [IX_Livro_Titulo] ON [Livro] ([Titulo]);
CREATE INDEX [IX_Livro_Editora] ON [Livro] ([Editora]);
CREATE INDEX [IX_Livro_AnoPublicacao] ON [Livro] ([AnoPublicacao]);
CREATE INDEX [IX_Livro_IsDeleted] ON [Livro] ([IsDeleted]);
GO

-- 7. Tabela de relacionamento Livro-Assunto (N:N)
IF EXISTS (SELECT * FROM sysobjects WHERE name='Livro_Assunto' AND xtype='U')
    DROP TABLE [Livro_Assunto];
GO

CREATE TABLE [Livro_Assunto] (
    [Livro_Codl] INT NOT NULL,
    [Assunto_CodAs] INT NOT NULL,
    CONSTRAINT [PK_Livro_Assunto] PRIMARY KEY ([Livro_Codl], [Assunto_CodAs]),
    CONSTRAINT [FK_Livro_Assunto_Livro] FOREIGN KEY ([Livro_Codl]) 
        REFERENCES [Livro] ([Codl]) ON DELETE CASCADE,
    CONSTRAINT [FK_Livro_Assunto_Assunto] FOREIGN KEY ([Assunto_CodAs]) 
     REFERENCES [Assunto] ([CodAs]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_Livro_Assunto_Livro] ON [Livro_Assunto] ([Livro_Codl]);
CREATE INDEX [IX_Livro_Assunto_Assunto] ON [Livro_Assunto] ([Assunto_CodAs]);
GO

-- 8. Tabela de relacionamento Livro-Autor (N:N)
IF EXISTS (SELECT * FROM sysobjects WHERE name='Livro_Autor' AND xtype='U')
    DROP TABLE [Livro_Autor];
GO

CREATE TABLE [Livro_Autor] (
    [Livro_Codl] INT NOT NULL,
    [Autor_CodAu] INT NOT NULL,
    CONSTRAINT [PK_Livro_Autor] PRIMARY KEY ([Livro_Codl], [Autor_CodAu]),
    CONSTRAINT [FK_Livro_Autor_Livro] FOREIGN KEY ([Livro_Codl]) 
    REFERENCES [Livro] ([Codl]) ON DELETE CASCADE,
    CONSTRAINT [FK_Livro_Autor_Autor] FOREIGN KEY ([Autor_CodAu]) 
        REFERENCES [Autor] ([CodAu]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_Livro_Autor_Livro] ON [Livro_Autor] ([Livro_Codl]);
CREATE INDEX [IX_Livro_Autor_Autor] ON [Livro_Autor] ([Autor_CodAu]);
GO

-- 9. Tabela de preços por forma de compra
IF EXISTS (SELECT * FROM sysobjects WHERE name='Livro_Preco' AND xtype='U')
    DROP TABLE [Livro_Preco];
GO

CREATE TABLE [Livro_Preco] (
    [Livro_Codl] INT NOT NULL,
    [FormaCompra_Id] INT NOT NULL,
    [Valor] DECIMAL(10,2) NOT NULL,
    CONSTRAINT [PK_Livro_Preco] PRIMARY KEY ([Livro_Codl], [FormaCompra_Id]),
    CONSTRAINT [FK_Livro_Preco_Livro] FOREIGN KEY ([Livro_Codl]) 
    REFERENCES [Livro] ([Codl]) ON DELETE CASCADE,
    CONSTRAINT [FK_Livro_Preco_FormaCompra] FOREIGN KEY ([FormaCompra_Id]) 
    REFERENCES [FormaCompra] ([Id]) ON DELETE CASCADE
);
GO

CREATE INDEX [IX_Livro_Preco_Livro] ON [Livro_Preco] ([Livro_Codl]);
CREATE INDEX [IX_Livro_Preco_FormaCompra] ON [Livro_Preco] ([FormaCompra_Id]);
CREATE INDEX [IX_Livro_Preco_Valor] ON [Livro_Preco] ([Valor]);
GO

-- 10. Inserir dados padrão das formas de compra
INSERT INTO [FormaCompra] ([Nome], [CreatedAt], [IsDeleted]) VALUES 
(N'Compra Online', GETUTCDATE(), 0),
(N'Loja Física', GETUTCDATE(), 0),
(N'E-book', GETUTCDATE(), 0),
(N'Audiobook', GETUTCDATE(), 0);
GO

-- 11. Inserir alguns assuntos de exemplo
INSERT INTO [Assunto] ([Descricao], [CreatedAt], [IsDeleted]) VALUES 
(N'Ficção', GETUTCDATE(), 0),
(N'Romance', GETUTCDATE(), 0),
(N'Tecnologia', GETUTCDATE(), 0),
(N'História', GETUTCDATE(), 0),
(N'Biografia', GETUTCDATE(), 0);
GO

-- 12. Inserir alguns autores de exemplo
INSERT INTO [Autor] ([Nome], [CreatedAt], [IsDeleted]) VALUES 
(N'Machado de Assis', GETUTCDATE(), 0),
(N'Clarice Lispector', GETUTCDATE(), 0),
(N'José Saramago', GETUTCDATE(), 0),
(N'Gabriel García Márquez', GETUTCDATE(), 0);
GO

-- 13. View para relatórios (opcional)
IF EXISTS (SELECT * FROM sys.views WHERE name = 'VwRelLivrosPorAutor')
    DROP VIEW [VwRelLivrosPorAutor];
GO

CREATE VIEW [VwRelLivrosPorAutor] AS
SELECT 
    a.[Nome] AS [AutorNome],
    l.[Titulo] AS [LivroTitulo],
    l.[Editora],
    l.[AnoPublicacao],
    MIN(lp.[Valor]) AS [PrecoMinimo],
    MAX(lp.[Valor]) AS [PrecoMaximo],
    COUNT(DISTINCT la2.[Assunto_CodAs]) AS [QuantidadeAssuntos]
FROM [Autor] a
INNER JOIN [Livro_Autor] la ON a.[CodAu] = la.[Autor_CodAu]
INNER JOIN [Livro] l ON la.[Livro_Codl] = l.[Codl]
LEFT JOIN [Livro_Preco] lp ON l.[Codl] = lp.[Livro_Codl]
LEFT JOIN [Livro_Assunto] la2 ON l.[Codl] = la2.[Livro_Codl]
WHERE a.[IsDeleted] = 0 AND l.[IsDeleted] = 0
GROUP BY a.[CodAu], a.[Nome], l.[Codl], l.[Titulo], l.[Editora], l.[AnoPublicacao];
GO

-- 14. Registrar a migração como aplicada
INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES 
(N'20260110000000_InitialCreateSqlServer', N'9.0.0');
GO

-- 15. Verificação final
SELECT 'Estrutura criada com sucesso no SQL Server!' as Status;
SELECT COUNT(*) as TotalTabelas FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_CATALOG = 'BasisBookDb' AND TABLE_NAME NOT LIKE 'VwRel%' AND TABLE_TYPE = 'BASE TABLE';
GO

PRINT 'Database BasisBookDb criada com sucesso no SQL Server Express!';
GO

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================