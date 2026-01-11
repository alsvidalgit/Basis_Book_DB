-- Script para criar a VIEW obrigatória do relatório
CREATE OR ALTER VIEW dbo.vw_Rel_LivrosPorAutor
AS
SELECT 
    a.CodAu AS AutorId,
    a.Nome AS AutorNome,
    l.Codl AS LivroId,
    l.Titulo AS LivroTitulo,
    l.Editora AS LivroEditora,
    l.Edicao AS LivroEdicao,
    l.AnoPublicacao AS LivroAnoPublicacao,
    ass.CodAs AS AssuntoId,
    ass.Descricao AS AssuntoDescricao
FROM Autor a
    INNER JOIN Livro_Autor la ON a.CodAu = la.Autor_CodAu
    INNER JOIN Livro l ON la.Livro_Codl = l.Codl
    LEFT JOIN Livro_Assunto las ON l.Codl = las.Livro_Codl
    LEFT JOIN Assunto ass ON las.Assunto_CodAs = ass.CodAs
WHERE a.IsDeleted = 0 
    AND l.IsDeleted = 0 
    AND (ass.IsDeleted = 0 OR ass.IsDeleted IS NULL);

-- Comando para testar a VIEW
-- SELECT * FROM dbo.vw_Rel_LivrosPorAutor ORDER BY AutorNome, LivroTitulo;