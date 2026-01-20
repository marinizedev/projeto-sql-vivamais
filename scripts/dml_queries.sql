-- ======================================================
-- RELATÓRIO 1: Lista de clientes com tipo e nome
-- ======================================================

SELECT 
    c.id AS 'ID Cliente',
    c.tipo AS 'Tipo (PF/PJ)',
    COALESCE(cp.nome_completo, cj.razao_social) AS 'Nome/Razão Social'
FROM tbl_cliente c
LEFT JOIN tbl_cliente_pf cp ON cp.id_cliente = c.id
LEFT JOIN tbl_cliente_pj cj ON cj.id_cliente = c.id
ORDER BY c.id;

-- ======================================================
-- RELATÓRIO 2: Total de vendas por cliente(com pagamentos)
-- ======================================================
SELECT 
    c.id AS 'ID Cliente',
    c.id AS 'Tipo (PF/PJ)',
    COALESCE(pf.nome_completo, pj.razao_social) AS 'Nome/Razão Social',
    COUNT(DISTINCT v.id) AS 'Quantidade de Vendas',
    SUM(p.valor) AS 'Valor Total Vendido (R$)'
FROM tbl_cliente c 
LEFT JOIN tbl_cliente_pf pf ON pf.id_cliente = c.id
LEFT JOIN tbl_cliente_pj pj ON pj.id_cliente = c.id
INNER JOIN tbl_venda v ON v.id_cliente = c.id
INNER JOIN tbl_pagamento p ON p.id_venda = v.id
GROUP BY c.id, c.tipo, COALESCE(pf.nome_completo, pj.razao_social)
ORDER BY SUM(p.valor) DESC;

-- ======================================================
-- RELATÓRIO 3: Total de vendas por vendedor
-- ======================================================
SELECT
    vd.id AS 'ID Vendedor',
    vd.nome_completo AS 'Vendedor',
    COUNT(DISTINCT v.id) AS 'Quantidade de Vendas',
    SUM(p.valor) AS 'Valor Total Vendido (R$)'
FROM tbl_vendedor vd
INNER JOIN tbl_venda v ON v.id_vendedor = vd.id
INNER JOIN tbl_pagamento p ON p.id_venda = v.id
GROUP BY vd.id, vd.nome_completo
ORDER BY SUM(p.valor) DESC;

-- ======================================================
-- RELATÓRIO 4: Produtos mais vendidos (quantidade)
-- ======================================================
SELECT
    pr.id AS 'ID Produto',
    pr.nome_produto AS 'Produto',
    c.nome_categoria AS 'Categoria',
    SUM(iv.qtde_vendida) AS 'Quantidade Vendida',
    SUM(iv.qtde_vendida * iv.preco_unitario) AS 'Valor Total (R$)'
FROM tbl_item_venda iv
INNER JOIN tbl_produto pr ON pr.id = iv.id_produto
INNER JOIN tbl_categoria c ON c.id = pr.id_categoria
GROUP BY pr.id, pr.nome_produto, c.nome_categoria
ORDER BY SUM(iv.qtde_vendida) DESC;

-- ======================================================
-- RELATÓRIO 5: Pagamentos por situação e forma
-- ======================================================
SELECT 
    p.situacao AS 'Situação',
    p.forma_pagamento AS 'Forma de Pagamento',
    COUNT(*) AS 'Quantidade de Pagamento',
    SUM(p.valor) AS 'Valor Total (R$)'
FROM tbl_pagamento p 
GROUP BY p.situacao, p.forma_pagamento
ORDER BY p.situacao, p.forma_pagamento;

-- ======================================================
-- RELATÓRIO 6: Pagamentos pendentes com dados do cliente
-- ======================================================
SELECT
    p.id AS 'ID Pagamento',
    p.data_vencimento AS 'Data de Vencimento',
    p.valor AS 'Valor (R$)',
    p.forma_pagamento AS 'Forma de Pagamento',
    c.tipo AS 'Tipo (pf/pj)',
    COALESCE(cf.nome_completo, cj.razao_social) AS 'Cliente',
    v.id AS 'ID Venda'
FROM tbl_pagamento p
INNER JOIN tbl_venda v ON v.id = p.id_venda
INNER JOIN tbl_cliente c ON c.id = v.id_cliente
LEFT JOIN tbl_cliente_pf cf ON cf.id_cliente = c.id
LEFT JOIN tbl_cliente_pj cj ON cj.id_cliente = c.id
WHERE p.situacao = 'Pendente'
ORDER BY p.data_vencimento;

-- ======================================================
-- REALTÓRIO 7: Produtos com estoque abaixo do mínimo
-- ======================================================
SELECT 
    pr.id AS 'ID Produto',
    pr.nome_produto AS 'Produto',
    c.nome_categoria AS 'Categoria',
    pr.qtde_estoque_minimo AS 'Estoque Mínimo',
    pr.qtde_estoque AS 'Estoque Atual',
    (pr.qtde_estoque_minimo - pr.qtde_estoque) AS 'Falta para o Mínimo'
FROM tbl_produto pr
INNER JOIN tbl_categoria c ON c.id = pr.id_categoria
WHERE pr.qtde_estoque < pr.qtde_estoque_minimo
ORDER BY (pr.qtde_estoque_minimo - pr.qtde_estoque) DESC;

-- ======================================================
-- RELATÓRIO 8: Detalhamento completo das vendas
-- ======================================================
SELECT
    v.id AS 'ID Venda',
    v.data_hora AS 'Data e Hora',
    c.tipo AS 'Tipo (PF/PJ)',
    COALESCE(cf.nome_completo, cj.razao_social) AS 'Cliente',
    vd.nome_completo AS 'Vendedor',
    pr.nome_produto AS 'Produto',
    iv.qtde_vendida AS 'Quantidade',
    iv.preco_unitario AS 'Preço Unitário',
    (iv.qtde_vendida * iv.preco_unitario) AS 'Subtotal Item (R$)',
    p.forma_pagamento AS 'Forma de Pagamento',
    p.situacao AS 'Situação Pagamento',
    p.valor AS 'Valor Total Pagamento (R$)'
FROM tbl_venda v
INNER JOIN tbl_cliente c ON c.id = v.id_cliente
LEFT JOIN tbl_cliente_pf cf ON cf.id_cliente = c.id
LEFT JOIN tbl_cliente_pj cj ON cj.id_cliente = c.id
INNER JOIN tbl_vendedor vd ON vd.id = v.id_vendedor
INNER JOIN tbl_item_venda iv ON iv.id_venda = v.id
INNER JOIN tbl_produto pr ON pr.id = iv.id_produto
INNER JOIN tbl_pagamento p ON p.id_venda = v.id
ORDER BY v.data_hora, v.id;