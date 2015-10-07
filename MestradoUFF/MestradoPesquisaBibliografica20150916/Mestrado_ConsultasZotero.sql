--Para facilitar o saneamento usei a seleção abaixo para excluir registros que não eram artigos:
SELECT IDV.value, IT.TypeName
  FROM items I 
  INNER JOIN itemData ID ON (I.itemID = ID.itemID 
  AND I.itemTypeID != 14 --Snapshot
  AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID)) 
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
  INNER JOIN itemTypes IT ON (I.itemTypeID = IT.itemTypeID AND IT.TypeName <> 'journalArticle')
  ORDER BY IT.TypeName, IDV.value; 

--Para facilitar o saneamento usei a seleção abaixo para excluir artigos com idioma chinês e alemão
  SELECT IDV.value, IDVD.value
  FROM items I 
  INNER JOIN itemData ID ON (I.itemID = ID.itemID 
  AND I.ITEMTYPEID != 14 --Snapshot
  AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID) 
--
  INNER JOIN (SELECT IDV4.value, ID4.itemID 
              FROM itemData ID4 
              INNER JOIN fields F4 ON (ID4.fieldID = F4.fieldID AND F4.fieldName = 'language')
              INNER JOIN itemDataValues IDV4 ON (ID4.valueID = IDV4.valueID ) AND IDV4.value in ('Chinese', 'German', 'French')) IDVD 
              ON (I.itemID = IDVD.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
  ORDER BY IDVD.value, IDV.value;

  
--Para facilitar o saneamento usei a seleção abaixo mudando apenas C.collectionName = 'ERP e ANP' AND CP.collectionName = 'Scopus' e colocando no google tradutor
--INNER JOIN collections C ON (C.collectionID = CP.parentCollectionID AND C.collectionName = 'ERP e REGIME' AND CP.collectionName = 'Scopus')
SELECT DISTINCT I.itemID as "ID", 
		  IDV.value as "TEMA",
		  IDV.value ||' ===============' || ifnull(IDVF.value, '-') || '########################' as "TRADUZIR", 
		  NULL as "TRADUZIDO"
  FROM collections CP
  INNER JOIN collections C ON (C.collectionID = CP.parentCollectionID)
  INNER JOIN collectionItems CI ON (CP.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID 
  AND I.itemTypeID != 14 --Snapshot
  AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
--
  LEFT JOIN (SELECT IDV6.value, ID6.itemID 
              FROM itemData ID6 
              INNER JOIN fields F6 ON (ID6.fieldID = F6.fieldID AND F6.fieldName = 'abstractNote')
              INNER JOIN itemDataValues IDV6 ON (ID6.valueID = IDV6.valueID )) IDVF ON (I.itemID = IDVF.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
--Após identificado o ValueID de quais necessitam excluir:
insert into itemDataValues (value) values ('EXCLUIR');
--
--Alterei o select anterior para usar o itemID e simplificar o insert abaixo sem necessidade de usar o INNER JOIN
insert into itemData (itemID, fieldID, valueID)
SELECT DISTINCT ID.itemID, 
(select fieldID from fields where fieldName = 'rights') as "fieldID",
(select valueID from itemDataValues where value = 'EXCLUIR') as "valueID"  
FROM itemData ID  
INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
WHERE IDV.valueID in (50, 75, 143, 233, 276, 298, 325, 347, 404, 480, 490, 495, 508, 519, 524, 529, 535, 541, 546, 551, 556, 561, 566, 574, 579, 593, 598, 616, 624, 632, 640, 657, 700, 709, 717, 725, 756, 762, 770, 785, 790, 820, 839, 845, 852, 860, 867, 873, 881, 896, 908, 922, 938, 946, 952, 960, 964, 973, 979, 985, 993, 1001, 1013, 1078, 1136, 1189, 1306, 1380, 1144, 1409, 1499, 1555, 1561, 1570, 1593, 1628, 1658, 1684, 1728, 1751, 1757, 1771, 1775, 10, 1823, 118, 1839, 1872, 1878, 307, 1895, 1907, 1912, 330, 1919, 362, 1926, 1930, 1933, 1936, 1940, 1944, 392, 1952, 421, 1959, 1964, 441, 1972, 1977, 453, 1989, 1995, 1998, 2003, 2007, 472, 2019, 2022, 2026, 2034, 513, 588, 606, 2063, 648, 693, 1020, 709, 2099, 739, 2110, 2116, 2121, 2128, 2132, 832, 2144, 2152, 2164, 2173, 2213, 1128, 2247, 2260, 1250, 2353, 2364, 2370, 1341, 2422, 2446, 1422, 1435, 1473, 2494, 2498, 2512, 2520, 2558, 2578, 2607, 2615, 2626, 2636, 2655, 2667, 2696);
--
select * from itemData where valueID in (select valueID from itemDataValues where value = 'EXCLUIR');
--Excluir os arquivos ordenador por direitos no Zotero
--Limpar a lixeira do Zotero
delete from itemDataValues where values = 'EXCLUIR';

--Para facilitar a busca do PDF dos artigos listar por base de indexação de artigos
SELECT DISTINCT CP.collectionName, I.itemID as "ID", IDV.value as "TEMA"
  FROM collections CP
  INNER JOIN collections C ON (C.collectionID = CP.parentCollectionID)
  INNER JOIN collectionItems CI ON (CP.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID 
  AND I.itemTypeID != 14 --Snapshot
  AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
  ORDER BY CP.collectionName, IDV.value 
--

--Atualizar os artigos que tinham PDF (DISPONIVEL) e aqueles que não tinham (INDISPONIVEL)
insert into itemDataValues (value) values ('DISPONIVEL');
insert into itemDataValues (value) values ('INDISPONIVEL');

--Atualizar os artigos que tinham PDF (DISPONIVEL)
insert into itemData (itemID, fieldID, valueID)
SELECT DISTINCT ID.itemID, 
(select fieldID from fields where fieldName = 'rights') as "fieldID",
(select valueID from itemDataValues where value = 'DISPONIVEL') as "valueID"  
FROM itemData ID
WHERE ID.itemID in (1, 145, 515, 768, 849, 936, 947, 970, 1055, 1154, 1165, 1183, 1206, 1228, 1282, 1287, 1292, 1307, 1326, 1422, 1438, 1450, 1510, 1512, 1513, 1515, 1517, 1520, 1521, 1523, 1526, 1527, 1578, 1585, 1586, 1599, 1607, 1610, 1616, 1617, 1618, 1634, 1635, 1636, 1645, 1646, 1650, 1658, 1660, 1670, 1677, 1684, 1685, 1687, 1702, 1705, 1724);
--
--Atualizar os artigos que não tinham PDF (INDISPONIVEL)
insert into itemData (itemID, fieldID, valueID)
SELECT DISTINCT ID.itemID, 
(select fieldID from fields where fieldName = 'rights') as "fieldID",
(select valueID from itemDataValues where value = 'INDISPONIVEL') as "valueID"  
FROM itemData ID
WHERE ID.itemID in (12, 25, 40, 49, 72, 82, 92, 97, 130, 140, 185, 460, 501, 673, 735, 759, 773, 794, 839, 909, 919, 965, 973, 1009, 1033, 1077, 1083, 1098, 1104, 1122, 1132, 1137, 1143, 1233, 1237, 1248, 1254, 1277, 1341, 1367, 1387, 1392, 1419, 1442, 1461, 1467, 1470, 1473, 1476, 1489, 1494, 1498, 1514, 1516, 1524, 1525, 1529, 1536, 1582, 1595, 1608, 1613, 1614, 1620, 1622, 1632, 1637, 1638, 1640, 1642, 1643, 1644, 1651, 1653, 1668, 1671, 1672, 1674, 1679, 1680, 1688, 1689, 1690, 1694, 1697, 1698, 1699, 1700, 1701, 1703, 1708, 1709);
--

--
--Tratar nomes de autores conhecidos dentro do Zotero:
SELECT CD.firstName || ' ' || CD.lastName, count(I.ITEMID)
FROM items I
LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
WHERE I.ITEMTYPEID = 4
GROUP BY CD.firstName || ' ' || CD.lastName
ORDER BY count(I.ITEMID) DESC;

--###############################################################################
CREATE TABLE A_ARTIGOS (
	itemID	INTEGER UNIQUE,
	CODIGO	TEXT,
	ARTIGO	TEXT,
	AUTORES	TEXT,
	ANO	TEXT,
	OBJETIVO	TEXT,
	METODO	TEXT,
	SISTEMA_INFORMACAO	TEXT,
	FASE	TEXT,
	SELECAO	TEXT,
	TIPO_ESTUDO	TEXT,
	QTDE_CRITERIOS	NUMERIC,
	QTDE_SUBCRITERIOS	NUMERIC,
	ARTIGO_TRADUZIDO	TEXT,
	RESUMO_TRADUZIDO	TEXT,
	PRIMARY KEY(itemID)
);
---Montar uma tabela de NxN A_CRI_X_ART(idCRI, CODIGO), uma vez que o mesmo critério pode ser de um artigo, mas ser de outro artigo
CREATE TABLE A_CRI_X_ART (
	criID	INTEGER,
	CODIGO	TEXT
);
--
CREATE TABLE A_CRITERIOS (
	criID	INTEGER,
	CRITERIO	TEXT,
	CRITERIA	TEXT
);
---Montar uma tabela de NxN A_SUB_X_CRI(idCRI, idSUB, CODIGO), uma vez que o mesmo subcritério pode ser de um critério num artigo, mas ser de outro critério em outro artigo
--Obrigatório manter o vínculo com o Artigo aqui, pois só a relação subcritério, critério não significa muito em função de agrupamento e contagem
CREATE TABLE A_SUB_X_CRI (
	subID	INTEGER,
	criID	INTEGER,
	CODIGO	TEXT
);
--
CREATE TABLE A_SUBCRITERIOS (
	subID	INTEGER,
	SUBCRITERIO	TEXT,
	SUBCRITERIA	TEXT
);
--
--Tabela de Apoio para popular A_SUB_X_CRI
CREATE TABLE A_SUB_CRI (
	CRITERIO	TEXT,
	SUBCRITERIO	TEXT,
	CODIGO	TEXT
);
--
--Tabela de Apoio para popular A_CRI_X_ART
CREATE TABLE A_ART_CRI (
	CRITERIO	TEXT,
	CODIGO	TEXT
);
--###############################################################################
--Carga das informações para as tabelas criadas:
INSERT INTO A_ARTIGOS (itemID, ARTIGO)
SELECT DISTINCT I.itemID as "itemID", IDV.value as "ARTIGO"
  FROM items I
  INNER JOIN itemData ID ON (I.itemID = ID.itemID 
  AND I.itemTypeID != 14 --Snapshot
  AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
  ORDER BY  IDV.value

--Carga via CSV de uma codificação para artigos criada anteriormente criando a tabela AA_ARTIGO - novos estudos a codificação pode ser criada diretamente na tabela;
--Atualização na tabela de interesse:
UPDATE A_ARTIGOS
SET CODIGO = (SELECT AA_ARTIGO.CODIGO 
						  FROM AA_ARTIGO 
					     WHERE AA_ARTIGO.ARTIGO = A_ARTIGOS.ARTIGO);

--Verificações e ajustes:						 
SELECT A.*, B.* 
FROM AA_ARTIGO A
INNER JOIN A_ARTIGOS B
ON (A.ARTIGO = B.ARTIGO);

SELECT A.*, B.* 
FROM AA_ARTIGO A
INNER JOIN A_ARTIGOS B
ON (A.ARTIGO = B.ARTIGO);

--75 SENDO QUE 43 TEM CÓDIGO
SELECT * FROM A_ARTIGOS 
WHERE CODIGO IS NOT NULL
ORDER BY CODIGO;

SELECT A.*
FROM AA_ARTIGO A
WHERE A.CODIGO NOT IN (SELECT B.CODIGO FROM A_ARTIGOS B);

SELECT * 
FROM A_ARTIGOS
ORDER BY CODIGO;
--REPETIDO A23

SELECT ROWID, * 
FROM A_ARTIGOS
WHERE ARTIGO LIKE 'Abordagem estratégica para a seleção de sistemas erp utilizando apoio multicritério à decisão';

--NAO HAVIA A25, A32, A39, A7
UPDATE A_ARTIGOS
SET CODIGO = 'A7'
WHERE ARTIGO LIKE 'Measuring the success possibility of implementing ERP by utilizing the incomplete linguistic preference relations';

UPDATE A_ARTIGOS
SET CODIGO = 'A25'
WHERE ARTIGO LIKE 'A General Framework to Measure Organizational Risk during Information Systems Evolution and its Customization';

UPDATE A_ARTIGOS
SET CODIGO = 'A32'
WHERE ARTIGO LIKE 'A novel hybrid evaluation model for the performance of ERP project based on ANP and improved matter-element extension model';

UPDATE A_ARTIGOS
SET CODIGO = 'A39'
WHERE itemID = '112';
--					
--drop da AA_ARTIGO	 

--Buscar Autores para a A_ARTIGOS
SELECT GROUP_CONCAT(CD.firstName || ' ' || CD.lastName, '; '), A.CODIGO, A.ARTIGO, A.AUTORES
FROM items I
INNER JOIN itemCreators IC ON (I.itemID = IC.itemID)
INNER JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
INNER JOIN A_ARTIGOS A ON (A.itemID = I.itemID)
WHERE I.ITEMTYPEID = 4
   AND A.CODIGO IS NOT NULL
GROUP BY A.CODIGO, A.ARTIGO, A.AUTORES
ORDER BY A.CODIGO, A.ARTIGO, A.AUTORES;

--Atualizar Autores na A_ARTIGOS
UPDATE A_ARTIGOS
SET AUTORES = (SELECT GROUP_CONCAT(CD.firstName || ' ' || CD.lastName, '; ')
FROM items I
INNER JOIN itemCreators IC ON (I.itemID = IC.itemID)
INNER JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
INNER JOIN A_ARTIGOS A ON (A.itemID = I.itemID)
WHERE I.ITEMTYPEID = 4
   AND A.CODIGO IS NOT NULL
   AND A.CODIGO = A_ARTIGOS.CODIGO
GROUP BY A.CODIGO
ORDER BY A.CODIGO);

--Buscar o ANO para a A_ARTIGOS
SELECT SUBSTR(IDV5.value,1,4) ANO, A.*
FROM items I
INNER JOIN itemData ID5 ON (I.itemID = ID5.itemID) 
INNER JOIN fields F5 ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
INNER JOIN itemDataValues IDV5 ON (ID5.valueID = IDV5.valueID )
INNER JOIN A_ARTIGOS A ON (A.itemID = I.itemID);

--Atualizar ANO na A_ARTIGOS
UPDATE A_ARTIGOS
SET ANO = (SELECT SUBSTR(IDV5.value,1,4)
FROM items I
INNER JOIN itemData ID5 ON (I.itemID = ID5.itemID) 
INNER JOIN fields F5 ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
INNER JOIN itemDataValues IDV5 ON (ID5.valueID = IDV5.valueID )
INNER JOIN A_ARTIGOS A ON (A.itemID = I.itemID)
WHERE A.itemID = A_ARTIGOS.itemID);

SELECT DISTINCT I.itemID as itemID, 
		  IDV.value as TRADUZIR_TEMA,
		  NULL as TEMA_TRADUZIDO,
		  ifnull(IDVF.value, '-') as TRADUZIR_RESUMO, 
		  NULL as RESUMO_TRADUZIDO
  FROM collections CP
  INNER JOIN collections C ON (C.collectionID = CP.parentCollectionID)
  INNER JOIN collectionItems CI ON (CP.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID 
  AND I.itemTypeID != 14 --Snapshot
  AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
--
  LEFT JOIN (SELECT IDV6.value, ID6.itemID 
              FROM itemData ID6 
              INNER JOIN fields F6 ON (ID6.fieldID = F6.fieldID AND F6.fieldName = 'abstractNote')
              INNER JOIN itemDataValues IDV6 ON (ID6.valueID = IDV6.valueID )) IDVF ON (I.itemID = IDVF.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Usando a tomada de decisão múltiplos critérios para avaliar o projeto de integração dos módulos de ERP e MES', RESUMO_TRADUZIDO = 'Este estudo usa a vários critérios de tomada de decisão (MCDM) para avaliar o projeto de integração do MES em módulos de ERP em uma empresa de Taiwan PCB. O CMMS foi aplicado para filtrar os indicadores de eficácia após a integração de módulos, e derivados dos pesos de indicador. O resultado deste estudo mostra que o indicador de custo é o indicador mais importante na integração MES para ERP. Este estudo também pode ser a referência para pesquisadores para calcular os indicadores de sistemas de ERP e MES desempenho.' where itemID = '24';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Usando o julgamento tomada de decisão e avaliação de laboratório e método de processo analítico de rede para integrar os módulos do ERP e MES', RESUMO_TRADUZIDO = 'Enterprise Resource Planning (ERP) pode coordenar as diferentes funções de empresas e melhorar os fluxos de informação. Quanto à situação de produção real, o ERP não pode receber e registrar as informações de equipamentos em detalhe, eo sistema de execução de manufatura (MES) não pode coletar vários tipos de informações entre diferentes funções empresariais. Portanto, o ERP que integra o MES pode ajudar a empresa a controlar o funcionamento negócio sem problemas. Esta pesquisa aplicada a fazer julgamento e avaliação laboratorial (DEMATEL) e método de processo analítico de rede (ANP) para o módulo MES para seleção do sistema ERP decisão. Os resultados da pesquisa mostram que o DEMATEL pode clarificar a relação ea ANP pode calcular os pesos dos critérios dos módulos do ERP e MES. A pesquisa também indicou que há uma alta demanda em integrar o módulo de vendas e distribuição (SDM) de ERP para o sistema de gestão de materiais (MMS) de MES, o que pode melhorar a eficácia do MES.' where itemID = '38';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um quadro geral para medir o risco organizacional durante a evolução dos sistemas de informação e sua personalização', RESUMO_TRADUZIDO = 'Sistemas de informação alterar iniciativas muitas vezes representam o maior investimento (e, portanto, risco) para as grandes corporações ainda existem alguns quadros de gestão na literatura para ajudar os tomadores de decisão de risco medida durante este processo de mudança em toda a organização. O (ORE) quadro Organização Avaliação de Risco foi desenvolvido com base no paradigma da ciência de design como um multicritério, risco relativo, condição consequência, o quadro de decisão de gestão que permitirá aos órgãos de decisão executiva para calcular e comparar a evolução do risco em pontos fixos do ciclo de mudança e torná-estruturado e decisões de redução dos riscos equilibrados. Enterprise Resource Planning iniciativas evolução sistemas em empresas de distribuição são um exemplo modelo do problema definido. O quadro ORE é personalizado para o ERP-ORE frame - trabalho para demonstrar a sua aplicação. O quadro ERP-ORE enfatiza as dimensões políticas e processo de evolução de sistemas e utiliza o Analytic Hierarchy Process para permitir a gestão de tomar decisões disciplinadas de mitigação de risco. O quadro ERP-ORE é ilustrada através de uma descrição estudo de caso de um distribuidor suprimentos médicos implementação de um sistema ERP. O foco é sobre o papel do sistema de ERP como um gerenciador de informações na cadeia de abastecimento.' where itemID = '47';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Uma abordagem baseada em anp distorcido para a seleção de fornecedores de ERP', RESUMO_TRADUZIDO = 'No processo de seleção do fornecedor a questão mais importante é determinar um método de tomada de decisão adequado para selecionar o melhor fornecedor. Essencialmente, a Seleção Problema Vendor (VSP) é um problema de tomada de decisão multi-critério envolvendo critério tangível, bem como intangível. Processo de Hierarquia Analítica (AHP) pode lidar melhor com esses critérios. Mas AHP não aborda a questão das interdependências entre e entre diferentes níveis de atributos. ANP oferece uma estrutura holística para a seleção das melhores Enterprise Resource Planning (ERP) alternativa fornecedor usando um relacionamento multi-direcional dinâmico entre os atributos de decisão. Também ANP equipado com lógica fuzzy ajuda a superar a imprecisão ou imprecisão nas preferências. O método adotado aqui usa números fuzzy triangulares para comparação de pares de atributos e ponderações são calculadas usando conceito de entropia. Um exemplo prático explica o nosso conceito e também uma comparação é feita com crisp ANP' where itemID = '64';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'A estrutura de avaliação de projetos de ERP', RESUMO_TRADUZIDO = 'O objetivo deste trabalho é propor um quadro metodológico para lidar com o problema complexo de avaliar Enterprise Resource Planning (ERP) projetos. A pressão competitiva desencadeada pelo processo de globalização está a conduzir a implementação de projetos de ERP em cada vez mais grandes números. Eles ocupam um espaço dominante na de hoje a aumentar rapidamente os investimentos em TI. Paradoxalmente, os pesquisadores observaram uma tendência de deterioração da avaliação desses investimentos. Considerando estacas enormes organizacionais juntamente com um alto risco de fracasso associado aos projetos de ERP, é imperativo que eles sejam devidamente avaliados. Metodologia convencional, que contada deslocamento custo como o único benefício, mostrou-se inadequada para os modernos projetos de TI que têm decrescentes possibilidades de deslocamento de custos e um foco crescente em objectivos de eficácia. A eficácia é um atributo multi-dimensional e não é passível de fácil quantificação. Projetos de ERP precisa critérios de avaliação multi-dimensionais e uma metodologia que se estende para a fase de implementação como o seu perfil realmente molda-se no segundo. Uma solução, na forma de uma estrutura de processo que incorpora aprendizado participativo e os processos de tomada de decisão baseada na técnica de Grupo Nominal (TGN) e adotando a metodologia de avaliação do Processo de Hierarquia Analítica (AHP), propõe. Um exemplo de caso é dado para ilustrar sua aplicabilidade na prática.' where itemID = '79';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Usando a abordagem ANP na seleção e avaliação comparativa de sistemas ERP', RESUMO_TRADUZIDO = 'Objetivo - Este estudo tem como objetivo fornecer uma boa visão sobre o uso da rede processo analítico (ANP), uma metodologia multi-critérios de tomada de decisão na selecção e avaliação comparativa planejamento de recursos empresariais (ERP). Desenhista / metodologia / abordagem - Neste estudo, o modelo ANP é proposto com um exemplo caso real na escolha do melhor sistema de ERP como um quadro para orientar os gestores. Apreciação - Este modelo oferece às empresas uma abordagem simples, flexível e fácil de usar para avaliar os sistemas de ERP de forma eficiente. Achados demonstram que o modelo ANP, com pequenas modificações, pode ser útil a todas as empresas em suas decisões de seleção do sistema ERP. Limitações da pesquisa / implicações - ANP é uma metodologia altamente complexa e requer mais cálculos numéricos na avaliação das prioridades compostas do que o processo de hierarquia analítica tradicional e, portanto, aumenta o esforço. Originalidade / valor - Esta é provavelmente a primeira vez que foi feita uma tentativa de aplicar o modelo ANP nas decisões de seleção do sistema ERP. ANP tem a capacidade de ser usado como uma ferramenta de análise de decisão, uma vez que incorpora feedback e relações de interdependência entre os critérios de decisão e alternativas. Além disso, a avaliação e seleção de software ERP pode ser muito útil para a pesquisa ea prática acadêmica.' where itemID = '145';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Framework para medir ERP implementação prontidão em pequenas e médias empresas (PME): Um estudo de caso em software developer empresa', RESUMO_TRADUZIDO = 'Enterprise Resource Planning (ERP) é um produto que permite às organizações alcançar sua vantagem competitiva. No entanto, as falhas de implementação de ERP ainda são considerados bastante elevados. Esta pesquisa foi realizada para formular o quadro de auto-avaliação de open source prontidão de implementação de ERP, que incidiu sobre os aspectos pré-implementação de ERP. O quadro de avaliação de prontidão de implementação de ERP proposto foi desenvolvido usando a Fuzzy-base ANP (distorcido ANP), onde os fatores de prontidão examinados são agrupados em três categorias, a saber, gestão de projetos, organizativa e prontidão de gerenciamento de mudanças. A fim de ver a aplicação do quadro, foi realizado um estudo de caso sobre uma PME envolvida no desenvolvimento de software. Fizemos grupo de discussão com Chief Technology Officer, Chief Strategy Officer e Gerente de Projetos. Os resultados mostraram que a empresa não está pronto para implementar o ERP de código aberto. Embora a empresa é forte no aspecto de recursos humanos, eles ainda são fracas em outros aspectos, de modo que eles precisam de algumas estratégias para melhorar o seu nível de prontidão antes de implementar ERP de código aberto.' where itemID = '157';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'O estudo sobre a avaliação do sistema ERP baseado em método difuso processo de hierarquia analítica', RESUMO_TRADUZIDO = 'O documento faz uso do método de avaliação abrangente AHP-fuzzy para analisar e avaliar o desempenho de implementação de ERP. Este método pode refletir corretamente o nível de implementação e personagens de um projeto de ERP. Este documento apresenta uma instância do aplicativo e introduz como avaliar uma empresa de desempenho de implementação do sistema ERP, fazendo uso do método de avaliação abrangente AHP-fuzzy. Ele fornece essência e teoria apoio científico para a tomada de decisão.' where itemID = '167';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Seleção de software ERP usando o conjunto de métodos e TPOSIS áspera sob ambiente difuso', RESUMO_TRADUZIDO = 'Software ERP indevidamente selecionado pode ter um impacto sobre o tempo necessário e os custos e quota de mercado de uma empresa, selecionar o melhor software ERP desejável tem sido o problema mais crítico por um longo tempo. Por outro lado, a seleção de software ERP é um processo de decisão (MCDM) problema dos múltiplos critérios, e na literatura, muitos métodos foram introduzidos para avaliar este tipo de problema, que tem sido amplamente utilizada em problemas de seleção MCDM. Neste trabalho, é proposta uma abordagem integrada de seleção de software ERP processo de hierarquia analítica melhorada pela teoria dos conjuntos rústica (Rough-AHP) e método TOPSIS fuzzy para obter classificação final.' where itemID = '172';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um projeto modelo teórico para o processo de seleção de software ERP sob as restrições de custo e qualidade: Uma abordagem difusa', RESUMO_TRADUZIDO = 'Enterprise Resource Planning (ERP) de seleção de software é uma das questões mais importantes a tomada de decisões, abrangendo fatores qualitativos e quantitativos para as organizações. Vários critérios de tomada de decisão (MCDM) foi encontrado para ser uma abordagem útil para analisar esses fatores conflitantes. Os critérios qualitativos são frequentemente acompanhadas de ambigüidades e imprecisões. Isso faz com que a lógica fuzzy uma abordagem mais natural para este tipo de problemas. Este estudo apresenta uma estrutura benéfico para os gestores para utilização no processo de seleção de fornecedores de software ERP. A fim de avaliar os fornecedores de ERP metodologicamente, é também proposto um quadro hierárquico. Como uma ferramenta de MCDM, foi utilizado processo analítico hierarquia (AHP) e sua extensão difusa para obter decisões mais decisivos, priorizando critérios e atribuição de pesos às alternativas. O objetivo deste trabalho é selecionar a alternativa mais adequada que atenda as necessidades do cliente no que diz respeito às limitações de custo e qualidade. No final deste estudo, um estudo de caso do mundo real da Turquia também é apresentado para ilustrar a eficiência da metodologia e sua aplicabilidade Na prática. ' where itemID = '177';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Seleção do sistema ERP usando uma abordagem AHP baseada em simulação: um caso de empresa Homeshopping coreano', RESUMO_TRADUZIDO = 'Um sistema de planejamento de recursos empresariais (ERP) é um investimento fundamental que pode afetar significativamente a competitividade futura e do desempenho de uma empresa. O método de análise hierárquica (AHP) é freqüentemente aplicada para selecionar um sistema de ERP, uma vez que é bem adequado para vários critérios de problemas de tomada de decisão. Este estudo apresenta um método AHP baseada em simulação (SiAHP) para a tomada de decisão em grupo e é aplicado para o problema do mundo real de seleção de um sistema de ERP adequado para uma empresa Homeshopping coreano. Para melhorar a aptidão de um método AHP grupo e para facilitar o processo de seleção do sistema ERP, este trabalho propõe uma abordagem baseada em simulação para a construção de um consenso do grupo em vez de formar estimativas pontuais que são agregados a partir de julgamentos de preferências individuais. Para ser mais específico, o método proposto é baseado em observações de distribuições de freqüência observados empiricamente e não utiliza procedimentos de agregação, em comparação com grupo típico AHP para a obtenção de uma solução grupo. Esta abordagem, refletindo a diversificação de opiniões dos membros do grupo como elas são, é concebido para ser útil como uma ferramenta para a obtenção de insights sobre acordos e desacordos com relação às alternativas entre os indivíduos de um grupo. A exemplo do mundo real demonstra a viabilidade de nossa abordagem proposta.' where itemID = '182';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Satisfação de qualidade de serviço dos usuários e melhoria das seleções de consultoria de ERP desempenho', RESUMO_TRADUZIDO = 'Recentemente, as empresas têm desenvolvido Enterprise Resource Planning (ERP). Sistemas de ERP irá integrar processos de negócio e fornecer informações. No entanto, implementação de ERP bem sucedido é caro e requer um longo tempo para ser concluído. As empresas costumam usar consultores externos para garantir um projeto de ERP bem sucedido. Seleção consultor ERP é uma tarefa difícil para um ERP implementação do projeto. Este estudo analisou a satisfação do serviço de qualidade dos utilizadores na selecção consultor ERP e investigados melhoria dos sistemas de ERP desempenho. Nós ilustrado como aplicar o Processo de Hierarquia Analítica (AHP) para definir pesos prioritárias para alternativas de consultoria, a fim de resolver os problemas de seleção de consultores ERP. ' where itemID = '198';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Segmentando fatores críticos de sucesso para implementação de ERP usando um AHP distorcido integrado e abordagem DEMATEL difusa', RESUMO_TRADUZIDO = 'Enterprise Resource Planning (ERP) Sistemas como pacotes de software padrão foram bem recebidas na maioria das indústrias. Embora a implementação desses sistemas precisa considerar questões para alcançar o sucesso e níveis de aspiração planejadas. A fim de identificar e classificar estas questões como fatores críticos de sucesso ERP (QCA), várias pesquisas têm sido feitas e as importâncias desses fatores foram discutidos. Como a área considerável, o grau de influência de fatores envolvidos no projeto de ERP é um espaço para a investigação. Neste trabalho, com considerando o grau de fatores de influência sobre as outras, um modelo híbrido foi proposto com base na análise do processo distorcido hierarquia analítica e DEMATEL fuzzy para avaliar e avaliar os fatores críticos para a implementação do projeto ERP. Encontrar a relação de causa e efeito entre os fatores eo grau de influência sobre o outro foi a principal contribuição do estudo de caso da pesquisa atual sobre uma empresa siderúrgica iraniana. Na companhia caso o fator de causa e razões foram identificados como: "., A competência da equipe do projeto e da cultura organizacional, utilizando modelo híbrido FAHP-DEMATEL © IDOSI Publicações, 2013." plano claro projeto "," formação e educação "," campeão do projeto' where itemID = '203';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Critérios de prioridade para recursos empresariais seleção sistemas de planejamento para as empresas de construção civil: uma abordagem multicritério', RESUMO_TRADUZIDO = 'Neste estudo, como um primeiro passo, um conjunto de critérios e subcritérios foi proposto para planejamento de recursos empresariais (ERP) selecção de sistemas para empresas do setor de construção civil, que é baseado em uma revisão da literatura a respeito da aplicação de modelos multicritério para avaliar sistemas ERP. Posteriormente, após a validação destes critérios por um grupo de especialistas em tecnologia da informação, uma pesquisa de campo foi desenvolvido com base na aplicação de um questionário e da utilização do processo de hierarquia analítica. Esta pesquisa nos permitiram realizar uma análise da consistência julgamento dos 11 entrevistados que participaram deste estudo e para captar suas percepções de critérios de importância. A pesquisa revelou que os inquiridos considerou o critério de software a ser o mais importante e mostrou a importância de subcritérios dentro de grupos de critérios, que muito contribuíram para o processo de tomada de decisões na seleção de sistemas de ERP.' where itemID = '208';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Modelo de avaliação da inteligência de negócios para sistemas corporativos utilizando TOPSIS difusa', RESUMO_TRADUZIDO = 'Avaliação de inteligência de negócios para os sistemas da empresa antes de comprar e implantá-los é de vital importância para criar um ambiente de apoio à decisão para os gestores nas organizações. Este estudo tem como objetivo propor um novo modelo para fornecer uma abordagem simples para avaliar os sistemas empresariais em aspectos de inteligência de negócios. Esta abordagem também ajuda o tomador de decisão para selecionar o sistema da empresa que tem inteligência adequado para apoiar as tarefas de decisão dos gestores. Usando ampla revisão da literatura, 34 critérios sobre as especificações de inteligência de negócios são determinados. Um modelo que explora técnica TOPSIS fuzzy tem sido proposto nesta pesquisa. Pesos distorcido dos critérios e julgamentos nebulosos sobre sistemas empresariais como alternativas são utilizados para calcular índices de avaliação e ranking. Esta aplicação é realizado para ilustrar a utilização do modelo para os problemas de avaliação de sistemas corporativos. Nesta base, as organizações serão capazes de selecionar, avaliar e comprar sistemas corporativos que possibilitam melhor ambiente de apoio à decisão em seus sistemas de trabalho. © 2011 Elsevier Ltd. Todos os direitos reservados.' where itemID = '515';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Medição de flexibilidade do sistema ERP baseado em processo analítico rede difusa', RESUMO_TRADUZIDO = 'Para atender às mudanças do ambiente interno e externo, sistema de Enterprise Resources Planning (ERP) precisa ter uma boa flexibilidade. A flexibilidade é uma solicitação indispensável e é também uma maneira que devem ser tomadas durante o processo de ERP estabelecimento. Medida da flexibilidade é um item importante para a implementação de flexibilidade ERP. De acordo com as características do sistema de ERP, um sistema de índice para a medição da flexibilidade do sistema ERP é apresentado com a interdependência e de feedback relações entre os critérios e / ou índices de ser tidos em conta. Devido à informação imprecisão e incerteza durante o processo de medição de flexibilidade, números fuzzy triangulares são usados ​​para indicar as opiniões de preferência dos especialistas e tomadores de decisão. Um modelo de mensuração flexibilidade de sistema ERP baseado em difusa rede processo analítico (FANP) é proposto. Os pesos locais de critérios e índices são obtidos por método de programação de preferências difusas (FPP). Um supermatrix não ponderada com base na estrutura de rede do sistema de indexação é desenvolvida, e o limite supermatrix é gerado. O nível de flexibilidade do sistema ERP pode ser medido pelos pesos e dezenas de ERP. Finalmente, um caso é dada pelo método proposto. ' where itemID = '768';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Empresa de selecção de projectos sistema de informação em matéria de BOCR', RESUMO_TRADUZIDO = 'Sistemas de informação da empresa, tais como planejamento de recursos empresariais (ERP), sistemas de execução de fabricação (MES), gestão de relacionamento com o cliente (CRM) e assim por diante, estão compreendendo cada vez mais atenção, devido à sua capacidade para melhorar a produção e desempenho dos negócios, e aumentar a vantagem competitiva para as empresas. No entanto, o que esses sistemas de informação empresariais trazer não são apenas benefícios e potenciais oportunidades, mas também os custos e riscos potenciais. Assim, uma avaliação abrangente e sistemática é necessária para executivos para escolher o projeto mais adequado de muitas alternativas. Este artigo propõe um método primeira decisão de selecção dos projectos. Processo rede Analytic (ANP) é usado para fazer a decisão em matéria de prestações (B), oportunidades (O), custos (C) e riscos (R). Então este método de decisão é examinado por um estudo de caso de selecção de projectos MES em um fabricante camisola chinês. Embora este caso é sobre a seleção de empresa projeto de sistema de informação, que contribui para o estudo da aplicação ANP na selecção de projectos em áreas mais amplas, além de projetos de sistemas de informação da empresa.' where itemID = '849';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'ERP em nuvens ou ainda abaixo', RESUMO_TRADUZIDO = 'Objetivo: O objetivo deste trabalho é investigar a maturidade do mercado a adotar a nuvem como a plataforma de ERP futuro, usando o processo analítico hierarquia (AHP) metodologia de apoio à decisão. Desenhista / metodologia / abordagem: Entrevistar é realizado na amostra de conveniência, de empresas de diversos setores. A entrevista é conduzida através de entrevista por telefone de especialistas e questionário auto-administrado. Os resultados são então utilizados como base para a formação do peso factores necessários para o modelo de decisão AHP. Os dados são analisados ​​e sintetizado utilizando o AHP e Expert Choice. Resultados: Os resultados demonstraram um enorme interesse para a redução de TCO, mas também uma preocupação com a privacidade dos dados e disponibilidade. As grandes empresas querem que seus dados em servidores locais, enquanto as empresas menores tendem a atuar como primeiros adotantes ", principalmente por causa dos benefícios de custo que Cloud oferece. Por fim, os fornecedores de ver as soluções híbridas como a abordagem mais adequada para o mercado global, pelo menos enquanto existem atuais obstáculos Nuvem limitações Pesquisa / implicações:. Esta pesquisa não pretende responder a pergunta o que é a melhor solução para uma determinada indústria Em vez disso, ele assume a abordagem geral, que responde à pergunta o que, em geral, ser a solução adequada para. o SME eo quanto são PME prontos para adotar o ERP na nuvem. Uma outra pesquisa é necessária a validação destes resultados na prática. Essa investigação deve ser específicos da indústria, ou seja, diminuiu para uma indústria só. Então, seria possível responder a pergunta o que é a melhor solução para as PME de alta tecnologia Implicações práticas:. Este artigo resume prós e contras úteis nuvem para os tomadores de decisão para estabelecer um ponto de partida para a reorganização de TI. Além disso, AHP resultados fornecem algumas indicações sobre a percepção do mercado em relação nuvem e ERP, enquanto as declarações dos fornecedores de soluções ERP sobre-Cloud fornecer uma visão interessante do mercado de ERP nos próximos anos. Originalidade / valor: Mercado exige flexibilidade constante e relação custo-eficácia, forçando as empresas a adaptar-se mais rapidamente do que nunca. Portanto, há um risco significativo para os primeiros adotantes e seu negócio se adotarem uma solução inadequada. Este documento oferece uma visão geral de alto nível de compreensão do mercado das PME e vontade de adotar ERP na nuvem da idéia, e demonstra como a metodologia de apoio à decisão AHP pode ser usado para avaliar a preparação das empresas a adotar a solução Cloud-ERP.' where itemID = '936';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'As exigências dos clientes de personalização ERP baseado usando a técnica AHP', RESUMO_TRADUZIDO = 'Finalidade-A personalização é uma tarefa difícil para muitas organizações que implementam o planejamento de recursos empresariais (ERP). O objetivo deste trabalho é desenvolver um novo quadro com base nas necessidades dos clientes para examinar as opções de personalização do ERP para a empresa. O processo de hierarquia analítica (AHP) técnica tem sido aplicada de forma complementar com este quadro de priorizar opções de personalização de ERP. Desenhista / na literatura empírica metodologia / Baseado abordagem, o papel proposto um quadro personalização ERP ancorado nas necessidades do cliente. Um método de pesquisa estudo de caso foi utilizado para avaliar a aplicabilidade do quadro em um cenário da vida real. Em um estudo de caso com 15 profissionais que trabalham com o fornecedor lados do cliente de e em uma implementação de ERP, o papel aplicado o quadro em conjunto com a técnica AHP para priorizar as opções de personalização viáveis ​​para implementação de ERP. Apreciação-O trabalho demonstra a aplicabilidade do quadro em identificar as várias opções possíveis para a organização cliente para considerar quando decidir personalizar seu produto ERP selecionado. Limitações da pesquisa / implicações de mais estudos de caso precisa ser levada a cabo em vários contextos de adquirir conhecimentos sobre a generalização das observações. Isso também irá contribuir para aperfeiçoar o quadro personalização ERP proposto. Implicações muito prático-poucas fontes de literatura sugerem métodos para explorar e avaliar as opções de personalização em projetos de ERP a partir da perspectiva da engenharia de requisitos. O quadro proposto ajuda os profissionais e consultores ancorar as decisões de personalização em necessidades do cliente e usar uma técnica de priorização bem estabelecida, AHP, para identificar as opções de personalização viáveis ​​para a empresa de execução. Originalidade / estudos de pesquisa publicados valor-No previamente fornecer uma abordagem para priorizar opções de personalização para o ERP ancorado nas necessidades do cliente. © Emerald Group Publishing Limited.' where itemID = '947';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Avaliação da importância dos critérios para a seleção de Sistemas Integrados de Gestão (ERP) para uso em empresas de construção civil', RESUMO_TRADUZIDO = 'A adoção de ERP (Enterprise Resource Planning) por empresas introduziu a necessidade de avaliação e seleção de tais sistemas. Esta discussão está inserida em um contexto de múltiplas percepções ou critérios de avaliação. No presente estudo, uma revisão sistemática da literatura foi realizada em um conjunto de artigos publicados em revistas indexadas na base Scopus, ISI Web of Science, e bancos de dados Engenharia Aldeia enfocando a avaliação de múltiplos critérios de sistemas de ERP. Com base nesta revisão da literatura, os critérios e sub-critérios foi estabelecido, o qual foi submetido à validação por um grupo de profissionais com forte seleção ERP Sistema e experiência de implementação, resultando em uma árvore composta por 45 sub-critérios agrupados em cinco critérios. Uma pesquisa de TI e as áreas de construção civil foi realizado em uma amostra de 79 respondentes, a fim de investigar a importância relativa desses critérios. O inquérito demonstrou que os grandes, Negócios, e critérios Financial Software foram consideradas pelos entrevistados como o mais importante.' where itemID = '970';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Seleção de fornecedores de ERP usando ferramentas AHP na indústria do vestuário', RESUMO_TRADUZIDO = 'Objetivo - O objetivo deste trabalho é explorar a seleção dos melhores fornecedores de ERP no sector do vestuário, utilizando análise hierárquica (AHP). Desenhista / metodologia / abordagem - AHP é usado para atingir o propósito do papel; critérios de seleção são determinados por gestores e especialistas. Apreciação - Três planejamento de recursos empresariais diferente (ERP) fornecedores são investigados e melhor alternativa é selecionado usando AHP. Após a melhor alternativa é selecionado, a análise de custo-benefício é calculado de forma a definir resultado decisivo. Todos os cálculos são verificados através da realização do teste de consistência. Limitações da pesquisa / implicações - Critérios de selecção e suas avaliações podem ser alteradas dependendo do tamanho da fabricante de roupas e tipo de produto. Originalidade / valor - Os resultados do estudo serão úteis para os fabricantes de vestuário que planeja implementar um sistema de ERP em suas organizações. Além disso, eles podem usar o AHP em outros problemas de decisão bem.' where itemID = '1055';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Uma metodologia baseada no AHP para classificar fatores críticos de sucesso dos sistemas de informação executivos', RESUMO_TRADUZIDO = 'Para acadêmicos e profissionais envolvidos com os sistemas de informação computadorizados, uma questão central é o estudo dos fatores críticos de sucesso (FCS) de desenvolvimento de sistemas de informação e implementação. Considerando que vários fatores críticos de sucesso analisa aparecem na literatura, a maioria deles não têm qualquer formação técnica. Neste trabalho, propomos a utilização do processo de hierarquia analítica (AHP) para definir prioridades fatores críticos de sucesso. Os resultados sugerem que elementos técnicos são menos críticos do que a informação e os fatores humanos e que um conhecimento adequado dos requisitos de informação de usuários é o mais importante fatores críticos de sucesso relacionados com os sistemas de informação executiva (EIS). © 2004 Elsevier B.V. Todos os direitos reservados.' where itemID = '1154';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Uma abordagem baseada no AHP para seleção do sistema ERP', RESUMO_TRADUZIDO = 'Um sistema de Enterprise Resource Planning (ERP) é um investimento fundamental que pode afetar significativamente a competitividade futura e do desempenho de uma empresa. Este estudo apresenta um quadro abrangente para a seleção de um sistema de ERP adequado. O quadro pode construir sistematicamente os objectivos da seleção ERP para apoiar os objetivos de negócio e estratégias de uma empresa, identificar os atributos adequados e estabelecer um padrão de avaliação consistente para facilitar um processo de decisão em grupo. Um exemplo do mundo real demonstra a viabilidade do quadro proposto. © 2004 Elsevier B.V. Todos os direitos reservados.' where itemID = '1165';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'A avaliação de risco em projetos de ERP: Identificar e priorizar os fatores', RESUMO_TRADUZIDO = 'Várias figuras afirmaram que ERP (enterprise resource planning) sistemas tornaram-se um dos maiores investimentos em TI nos últimos anos. A implementação do sistema ERP, no entanto, não é uma tarefa fácil. Relatórios de pesquisa anteriores invulgarmente elevado de falha em projetos de ERP, por vezes, comprometer o funcionamento do núcleo da organização de execução. O caso mais famoso é FoxMeyer entrou com pedido de proteção do Capítulo 11 falência. Além disso, os sistemas de ERP parecem apresentar riscos únicos em curso devido à sua singularidade. Neste estudo, foi utilizado um método Delphi para identificar potenciais fatores de risco projetos de ERP, e construiu uma estrutura baseada em AHP para analisar e então priorizados os projetos de ERP fatores de risco. O resultado revela que alguns fatores de risco importantes merecem mais atenção durante a implementação de projetos de ERP.' where itemID = '1183';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Investigando a importância de fatores que influenciam a adoção de tecnologias de integração em autoridades governamentais locais', RESUMO_TRADUZIDO = 'Objetivo: A aplicação de tecnologias de integração de aplicações empresariais (EAI) na integração de sistemas de informação heterogêneos (IS) tem sido perseguido por várias organizações públicas e privadas. No entanto, quando EAI adicionou eficácia e reforçou as infra-estruturas de tecnologia da informação no domínio privado, autoridades governamentais locais (LGAs) têm sido lentos em adotar soluções de EAI rentáveis ​​para expandir significativamente as capacidades do seu convencionalmente inflexível IS. Apesar EAI representa uma proposta atraente para os OPL e oferece a oportunidade de alavancar o IS em uma cadeia ininterrupta de processos, EAI não tem sido amplamente investigada em OPL. A literatura indica vários estudos de investigação, incidindo essencialmente em uma série de fatores diferentes (por exemplo, benefícios, barreiras) que influenciam a adoção EAI. No entanto, devido ao grande número de fatores diferentes, pode não ser suficiente para OPL para tomar decisões por apenas com foco em fatores. Assim, o objetivo deste trabalho é avaliar e priorizar os fatores que influenciam a adoção EAI em LGAs através do processo de hierarquia (AHP) técnica analítica. Desenhista / metodologia / abordagem: Para investigar os fenômenos menos reconhecidos como adoção EAI em OPL, o autor segue um, caso qualitativo abordagem de estudo interpretativo a realizar esta pesquisa. Esta abordagem irá ajudar na análise do fenômeno em seu ambiente natural, examinar as complexidades e os processos em profundidade, por exemplo, analisar e priorizar a importância de fatores que influenciam o processo de tomada de decisão para adoção EAI, e fornecer flexibilidade considerável durante entrevistas e observações. Resultados: De acordo com os resultados empíricos, as propostas fatores de adoção de EAI são apropriados para estudar o contexto de pesquisa. A análise e estudo dos factores é feita cuidadosamente e especificamente para caber e ser compatível dentro do contexto de uma LGA. Como resultado, é evidente a partir dos resultados empíricos de que a maioria dos fatores influenciaram o processo de tomada de decisão para adoção EAI exceto dois fatores que não são testados. Originalidade / valor: O autor leva em consideração o vazio literatura e priorizar a importância dos fatores, introduzindo a técnica AHP. Esta técnica é substancial, pois pode melhorar a análise da adoção EAI em LGAs, testes e justifica a viabilidade da técnica AHP por um estudo de caso, e facilita LGAs em perceber a importância dos fatores de adoção de EAI. Por isso, contribui significativamente para o corpo de conhecimentos e práticas nesta área e fornecendo apoio suficiente à gestão, acelerando o processo de adoção EAI. © Emerald Group Publishing Limited.' where itemID = '1206';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Sistemas empresariais: State-of-the-art e as tendências futuras', RESUMO_TRADUZIDO = 'Os rápidos avanços em métodos de integração de informação industrial estimularam um enorme crescimento no uso de sistemas corporativos. Consequentemente, uma variedade de técnicas têm sido utilizadas para sondar os sistemas da empresa. Estas técnicas incluem a gestão de processos de negócios, gestão de fluxo de trabalho, Enterprise Application Integration (EAI), Arquitetura Orientada a Serviços (SOA), computação em grade, e outros. Muitas aplicações requerem uma combinação dessas técnicas, o que está a dar origem ao aparecimento de sistemas corporativos. Desenvolvimento das técnicas tem originado a partir de diferentes disciplinas e tem o potencial de melhorar significativamente o desempenho dos sistemas corporativos. No entanto, a falta de ferramentas poderosas ainda representa um grande obstáculo para a exploração de todo o potencial dos sistemas corporativos. Em particular, os métodos formais e métodos de sistemas são cruciais para a modelagem de sistemas corporativos complexos, o que coloca desafios únicos. Neste artigo, fazemos uma breve levantamento do estado da arte na área de sistemas corporativos como eles se relacionam com a informática industrial. © 2011 IEEE.' where itemID = '1228';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Uma avaliação dos facilitadores e inibidores para a adoção da tecnologia de integração de aplicativos corporativos: um estudo empírico', RESUMO_TRADUZIDO = 'Objetivo - Integração de aplicativos empresariais (EAI) tem como objetivo integrar várias aplicações empresariais, tais como sistemas legados, sistemas de planejamento de recursos empresariais e aplicativos de negócios best-of-breed, para ajudar na promoção metas organizacionais. EAI é uma área relativamente nova de preocupação para pesquisadores e profissionais e pesquisas sobre sua adoção pelas organizações continuam a ser examinado. Desenhista / metodologia / abordagem - Este artigo estende a pesquisa anterior, proporcionando um exame sistemático de ambas as dimensões genéricas e específicas dos facilitadores e inibidores para a adoção da tecnologia de EAI. A validação rigorosa destes factores foi estabelecida. Um estudo de caso foi realizado para aperfeiçoar o instrumento desenvolvido. Apreciação - Os resultados indicam que a adopção de EAI é facilitada por factores genéricos específicos, bem como a esta tecnologia. Limitações da pesquisa / implicações - Várias limitações do estudo precisam ser mencionados nesta fase. Em primeiro lugar, o desenho desta pesquisa incorporou apenas um local para examinar e enriquecer a lista de facilitadores e inibidores da adoção EAI. Não se sabe se estes resultados se aplicam a outras organizações, outras tecnologias e se a dimensão do projecto tem alguma influência sobre os resultados. Trabalho mais empírica é necessária para incrementar o instrumento desenvolvido. Os resultados deste estudo têm três implicações específicas para futuras pesquisas. Em primeiro lugar, este estudo pode ser replicado para examinar o efeito desses facilitadores sobre o desempenho do projeto EAI. Em segundo lugar, mais pesquisas podem ser realizadas para validar dimensões identificadas neste estudo. Uma pesquisa pode reforçar o processo de validação do instrumento desenvolvido e a estrutura das dimensões e construções usadas. Finalmente, os resultados deste estudo e do instrumento desenvolvido pode ser aplicado em outras tecnologias, como serviços web, etc. implicações práticas - O papel estende-se rei e lista de Teo para incluir fatores EAI-específicas. Em segundo lugar, ele valida o instrumento através do procedimento card sorting e um estudo de caso. As dimensões identificadas pode ser usado em pesquisas futuras sobre a adoção EAI. Os resultados também têm implicações gerenciais importantes. Os gerentes que estão planejando adotar a tecnologia EAI pode usar o instrumento desenvolvido para avaliar sistematicamente os facilitadores e inibidores desta tecnologia no seu contexto organizacional. Originalidade / valor - Este estudo estende e se acumula no quadro de Teo de inibidores e facilitadores da adoção de TI no contexto EAI. © Emerald Group Publishing Limited.' where itemID = '1282';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'EAI e SOA: Fatores e métodos que influenciam a integração de vários sistemas de ERP (em um ambiente SAP) para cumprir com a Lei Sarbanes-Oxley', RESUMO_TRADUZIDO = 'Objetivo - O trabalho procura avaliar os fatores e os métodos utilizados para integrar vários sistemas de ERP para cumprir com a Lei Sarbanes-Oxley (SOA) em um ambiente EAI com foco na aplicação armazém de negócios SAP. Desenhista / metodologia / abordagem - O artigo analisa pesquisas anteriores, inquéritos, processos reais e documentação definidos no sistema SAP, bem como informações recolhidas a partir de promotores, auditores e especialistas de conformidade. Apreciação - Para cumprir com o SOA, é aconselhável olhar para a área de EAI para obter assistência. O desafio da configuração de uma paisagem de cumprir a SOA sem EAI significa que a maioria das ligações para transferência de dados seria contra interfaces de integração, o que não é aceitável para os grupos de conformidade. Para requisitos de SOA, incluindo controles internos, testes de segurança, autorizações e consistência e velocidades, existem ferramentas para ajudar com sucesso atingir a meta de conformidade de TI no ambiente SAP. Limitações da pesquisa / implicações - Como SOA continua a tomar forma, posterior revisão e investigação de como essas mudanças vão afetar o meio ambiente EAI devem ser realizadas. Implicações práticas - O artigo fornece a percepção de que alcançar a conformidade SOA não é uma tarefa fácil, e que a tecnologia disponível deve ser utilizado para concluir esta tarefa. TI deve estruturar uma organização que rege semelhante ao encontrado no lado de aplicativos do sistema para cumprir a SOA. Originalidade / valor - Com o passar e implementação do SOA, as empresas estão enfrentando uma pressão adicional para desenvolver os meios para auditar constantemente-se internamente. Como a tecnologia é a chave para alcançar este objetivo, as organizações devem preparar suas infraestruturas de TI para suportar os serviços de conformidade e de TI para desenvolver a estratégia. © Emerald Group Publishing Limited.' where itemID = '1287';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Modelagem de um sistema de CRM com um quadro EAI', RESUMO_TRADUZIDO = 'Algumas estruturas empresariais arquiteturas e sistemas de informação pode ser usada para modelar os diferentes aspectos da Enterprise Application Integration (EAI). Considerando-se várias destas estruturas e, em particular, as abordagens propostas pelo Modelo Conceitual do Brown da Integração e da integração Visualizações de Sandoe, definimos um quadro EAI (EAIF), expressa como um modelo UML padrão. Suas principais contribuições são, por um lado, para unificar conceitos e terminologia relacionadas com aspectos de integração e, por outro lado para modelar as principais características relacionadas com processos, serviços, mecanismos e as pessoas envolvidas na integração de negócios. Além disso, EAIF pode ser usado dentro da empresa para ajudar os gerentes de projeto de integração. Os principais objetivos deste trabalho são: - apresentar a especificação EAIF, que complementa o modelo UML standard, e - experimentar a modelagem dos processos, serviços, mecanismos e as pessoas de um sistema de CRM (Customer Relationship Management) usando a especificação para ilustrar a processo de instanciação EAIF. A aplicação ao estudo de caso permitiu a detecção de inconsistências na definição de alguns dos processos de integração de CRM e os serviços correspondentes, sugerindo mudanças nas estratégias de negócios.' where itemID = '1292';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um sistema de gerenciamento de logística baseada na Web para o fornecimento ágil projeto de rede demanda', RESUMO_TRADUZIDO = 'Objetivo - on-line, on-demand e disponibilidade em tempo real de informações para todos os membros de um sistema de produção que lhes permite ser ágil e na melhor posição para reagir rapidamente, de forma eficiente, de forma síncrona, e coletivamente às mudanças no mercado. Este trabalho propõe um sistema integrado de gerenciamento de logística baseada na Web para o projeto de rede demanda de suprimentos ágil (ASDN). Desenhista / metodologia / abordagem - O trabalho apresenta um sistema de software, que é distribuído como código aberto. Um estudo de caso da ABB Empresa na Finlândia foi realizada e isso demonstra a validade da ASDN na concepção e gestão de redes de demanda de abastecimento. Apreciação - aplicações de software atuais, tais como ERP, WMS e EAI não suportam a tomada de decisões de nível superior. Existem várias medidas de desempenho, que estão diretamente ligados à estrutura da rede. Implicações práticas - O software apresentado suporta modelagem, análise e otimização de redes de demanda limitada de abastecimento. Também é discutida a análise logística de nível de rede que está por trás da ferramenta de modelagem. Originalidade / valor - O artigo introduz o software ASDN, que está disponível livremente para a pesquisa e usos comerciais. O exemplo de caso mostra como este tipo de decisões relacionadas à arquitetura de rede pode ser analisado. © Emerald Group Publishing Limited.' where itemID = '1307';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Integração de processos de negócios é viável?', RESUMO_TRADUZIDO = 'Objetivo - O objetivo deste trabalho é investigar se a integração de processos de negócios é viável. Desenhista / metodologia / abordagem - Este artigo emprega uma estratégia de estudo de caso único para pesquisar a questão de pesquisa acima mencionado. O estudo de caso é exploratória. Apreciação - Com base nas conclusões e no contexto da organização caso, parece que a tecnologia de integração de aplicações empresariais (EAI) pode integrar processos de negócios. No entanto, uma vez que não é possível generalizar a partir de um estudo de caso único, mais pesquisas são sugeridas para investigar esta área. A partir do estudo de caso, parece que a EAI pode facilmente integrar os processos de negócios quando ele é combinado com planejamento de recursos empresariais (ERP). Limitações da pesquisa / implicações - Este é um estudo de caso único e, assim, os resultados não podem ser generalizados. Implicações práticas - A data empíricas sugerem que as organizações podem combinar com EAI ERP para integrar seus processos de negócio de uma forma mais flexível. Originalidade / valor - A contribuição do papel é triplo: ele descreve a camada de automação de processos de negócios de tecnologia EAI, define e apresenta um modelo de cenário para a integração de processos de negócios e examina a questão de pesquisa. © Emerald Group Publishing Limited.' where itemID = '1326';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'O impacto da integração de aplicações empresariais em ciclos de vida dos sistemas de informação', RESUMO_TRADUZIDO = 'Sistemas de Informação (SI) tornaram-se o tecido organizacional para a colaboração intra e inter-organizacional no negócio. Como resultado, existe uma pressão crescente de clientes e fornecedores para um movimento direto longe de sistemas diferentes operando em paralelo no sentido de uma arquitetura compartilhada mais comum. Em parte, isso foi conseguido através da emergência de uma nova tecnologia que está sendo empacotado em um portfólio de tecnologias conhecidas como integração de aplicações empresariais (EAI). O seu surgimento no entanto, está apresentando os tomadores de decisão de investimento encarregados da avaliação dos IS com um desafio interessante. A integração da IS em linha com as necessidades da empresa é aumentar a identificar e ciclo de vida, o que torna difícil avaliar o impacto total do sistema, uma vez que não tem início e / ou fim definitivo. Na verdade, o argumento apresentado neste artigo é que os modelos de ciclo de vida tradicionais estão mudando como resultado de tecnologias que suportam a sua integração com outros sistemas. Neste trabalho, a necessidade de uma melhor compreensão das EAI e seu impacto sobre os ciclos de vida de SI são discutidos e uma estrutura de classificação proposto. © 2003 Elsevier Science BV Todos os direitos reservados.' where itemID = '1422';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Empresa iniciativas transformadoras', RESUMO_TRADUZIDO = 'Integração Enterprise-aplicação (EAI), a estratégia ágil que envolve tecnologia e processo que permite que os sistemas díspares para a troca de informações em nível de negócios em idiomas que cada um entende, fornece a infra-estrutura de backbone para a implementação de um modelo de processo de negócio. Em última análise, EAI serve como facilitador de estratégias de alto nível detalhado como parte de um esforço de modelagem de processos de negócios e fornece a estrutura flexível para abordar a mudança de clima de negócios.' where itemID = '1438';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Informações de integração de informação e estratégias para empresas adaptáveis', RESUMO_TRADUZIDO = 'Sistemas de informação empresariais, tais como Enterprise Resource Planning (ERP), têm sido muitas vezes criticado por sua rigidez. Alternativamente, globais, empresas matriciais muitas vezes seguem uma abordagem de sistemas de informação federado. O primeiro tipo de empresas, que nós chamamos as empresas padronizadas, a falta de flexibilidade, enquanto o segundo tipo, que chamamos de empresas descentralizadas, a falta de visibilidade. Para criar o que havemos de chamar uma empresa adaptável a estratégia de sistemas de informação deve alcançar ambos os objectivos: a visibilidade e flexibilidade. Eu discutir os problemas associados com a falta de qualquer um destes dois, e como a tecnologia de integração de informações, dentro do espaço de integração de aplicações empresariais, pode levar à criação de empresas adaptáveis. © 2002 Elsevier Science Ltd. Todos os direitos reservados.' where itemID = '1450';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Usando desdobramento da função qualidade para realizar a avaliação de fornecedores e recomendação fornecedor para sistemas de business intelligence', RESUMO_TRADUZIDO = 'Business intelligence (BI) tem sido reconhecida como um importante sistema de informação da empresa para ajudar os tomadores de decisões conseguir uma medição e gestão de desempenho. Geralmente, os usuários de BI típicos consistem de analistas financeiros, planejadores de marketing e gerentes gerais. No entanto, a maioria deles não estão familiarizados com as principais tecnologias de BI. A fim de ajudar os executivos corporativos melhor avaliar fornecedores de BI, critérios de avaliação são divididos em requisitos de comercialização (MRS) e atributos técnicos (TM), respectivamente. Em particular, um MCDM difusa (multi-critérios de tomada de decisão), com base QFD (Quality Function Deployment) é proposto como segue: (1) distorcido Delphi é utilizado para agregar as dezenas de fornecedores de BI de desempenho, (2) DEMATEL difusa (tomada de decisão e laboratório de teste) é conduzido a reconhecer as causalidades entre MRS e TAs, e (3) distorcido AHP (processo de hierarquia analítica) é utilizado para recomendar os sistemas de BI ideais. Para uma melhor análise comparativa, os pontos fortes e fracos dos três fornecedores de BI competitivas (ou seja, SAP, SAS, e Microsoft) são simultaneamente visualizada através de exibição de um diagrama de linha (em termos de TM) e um diagrama de radar (em termos de RMs). Mais importante, os resultados experimentais demonstram que a avaliação de fornecedores e recomendação fornecedor foram concluídas com êxito. (C) 2014 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1510';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Selecionando o melhor "sistema de ERP para PME que utilizam uma combinação de métodos ANP e PROMETHEE"', RESUMO_TRADUZIDO = 'Enterprise Resource Planning (ERP), que integra todas as unidades dentro de uma organização ao nível da informação, desempenha um papel importante para uma empresa de sucesso. Com o sistema de ERP certo, é mais fácil para fornecer coordination.between as unidades, eliminar o desperdício e tomar decisões mais rápidas e melhores. A adoção de um sistema de ERP é uma decisão de investimento significativo para uma empresa, portanto, uma grande dose de atenção deve ser dada à seleção do sistema certo. Uma vez que há um grande número de critérios a considerar na escolha de um sistema de ERP, o processo em si é considerado como um multi-critério decisório problema complexo. Neste estudo, dois multi-critérios predominantes tomada de decisões técnicas, processo analítico Network (ANP) e Preferência Ranking Método Organização para Enriquecimento Evaluations (PROMETHEE), são utilizados em combinação para melhor atender o problema de seleção de ERP. Em primeiro lugar, ANP é utilizado para determinar os pesos de todos os critérios e, em seguida, os pesos obtidos são utilizados no método para o ranking PROMETHEE óptima das escolhas alternativas do sistema. Para demonstrar a viabilidade da metodologia proposta, um caso de aplicação é executada no problema de seleção de ERP para as Pequenas e Médias Empresas (PME) em Istambul, Turquia. A metodologia híbrida proposta classificada com sucesso as alternativas e identificou o melhor sistema de ERP com base na informação obtida a partir de um conjunto de PME participaram deste estudo. (C) 2014 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1512';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Usando distorcido processo analítico de rede para avaliar os riscos na implementação do sistema de planejamento de recursos empresariais', RESUMO_TRADUZIDO = 'O objetivo deste trabalho foi avaliar o nível de risco para ambas as culturas intra-organizacionais e para diferentes sectores de actividade, a implementação de um sistema de planejamento de recursos empresariais (ERP). Este estudo adota o método fuzzy processo analítico Network (FANP) para avaliar os riscos de implementação de ERP, que foram classificados em quatro dimensões: gestão e execução, sistema de software, usuários e planejamento tecnologia. Uma pesquisa empírica foi conduzida que utilizou os dados de pesquisa coletados de 20 especialistas de ERP em Taiwan para avaliar, classificar e melhorar os riscos críticos de implementação de ERP através do método FANP. Com base nos resultados do método FANP, uma pesquisa de acompanhamento dos utilizadores finais de ERP em diferentes departamentos de três indústrias foi conduzido para avaliar como as culturas intra-organizacional e cross-indústrias afetam usuários percebida arrisca um cenário do mundo real. Os resultados da pesquisa demonstraram que a falta de apoio e assistência de gestão "é um risco vital para uma implementação de ERP bem sucedido. Apoio da alta gerência e envolvimento são fatores cruciais e essenciais para o sucesso da implementação do ERP de uma empresa." A comunicação ineficaz com os usuários "foi encontrado para ser o segundo maior fator de risco. Os benefícios de usar o método FANP para avaliar os fatores de risco vêm dos pesos claros prioritárias entre alternativas. Finalmente, este estudo fornece sugestões para ajudar as empresas a diminuir os riscos de ERP, e aumentar as chances de sucesso de implementações de ERP entre culturas intra-organizacionais e em todo-indústrias. (C) 2014 Elsevier BV Todos os direitos reservados ".' where itemID = '1513';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Desenvolvimento de uma metodologia híbrida para seleção do sistema ERP: O caso da Turkish Airlines', RESUMO_TRADUZIDO = 'Planejamento de recursos empresariais (ERP) sistemas que visam integrar, sincronizar e centralizar os dados organizacionais são geralmente considerados como uma ferramenta vital para as empresas a ser bem sucedido no mercado global em rápida transformação. Devido à sua alta aquisitivo aquisição, instalação e custo de implementação e da ampla gama de ofertas, a seleção de sistemas ERP é uma decisão estratégica importante e difícil. Uma vez que existe uma ampla gama de critérios tangíveis e intangíveis a ser considerado, é muitas vezes definido como um problema multi-critério tomada de decisão. Para superar os desafios impostos pela natureza multifacetada do problema, propõe aqui uma metodologia híbrida de três estágios. O processo começa com a identificação da maioria dos critérios que prevalecem através de uma série de sessões de brainstorming que incluem pessoas de diferentes unidades organizacionais. Então, devido à importância variável dos critérios, uma difusa Analytic Hierarchy Process, que lida com a incerteza inerente ao processo de tomada de decisão, é usado para obter a importância relativa / pesos dos critérios. Estes critérios ponderados são então usados ​​como entrada para a técnica de Ordem de Preferência pelos Similarity ao método Solução Ideal para classificar as alternativas de decisão. Como um caso ilustrativo do mundo real, a metodologia proposta é aplicada ao problema de seleção de ERP na Turkish Airlines. Por causa da natureza colaborativa e sistemático da metodologia, os resultados obtidos a partir do processo foram encontrados para ser altamente satisfatório e confiável pelos decisores. (C) 2014 Elsevier B.V. Todos os direitos reservados.' where itemID = '1515';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'O sistema MCDM QoS baseada em SaaS para aplicações de ERP com Rede Social', RESUMO_TRADUZIDO = 'A computação em nuvem oferece quase todos os seus serviços, incluindo software, os dados do usuário, recursos do sistema, processos e sua computação através da Internet. A computação em nuvem consiste em três classes principais; Software como Serviço, Infraestrutura como Serviço e Plataforma como Serviço. Usando Software as a Service (SaaS), os usuários são capazes de alugar software de aplicação e bancos de dados que, em seguida, instalar em seu computador na forma tradicional. No sistema de Enterprise Resource Planning (ERP), o ambiente de serviço do sistema foi alterada de modo a permitir a aplicação das SaaS no ambiente de computação em nuvem. Esta alteração foi implementada, a fim de prestar o serviço sistema de ERP para os usuários de uma forma conveniente e eficiente mais barato, mais através da Internet em vez de ter de configurar o seu próprio computador. Recentemente muitos pacotes ERP SaaS estão disponíveis na Internet. Por esta razão, é muito difícil para os usuários a encontrar o pacote de ERP em SaaS que melhor atendam às suas necessidades. Os QoS (Quality of Service) pode fornecer uma solução para este problema. No entanto, de acordo com pesquisas recentes, não só a identificação atributos de qualidade para SaaS ERP, mas também um processo para encontrar e recomendar software no ambiente de computação em nuvem, provou estar a faltar. Neste artigo, propomos um modelo de QoS para SaaS ERP. O modelo de QoS proposto consiste em 6 critérios; Funcionalidade, confiabilidade, usabilidade, eficiência, facilidade de manutenção e de negócios. Usando esse modelo QoS, propomos um sistema multi Critérios de Tomada de Decisão (MCDM) que encontra o melhor ajuste para o SaaS ERP no ambiente de computação em nuvem e faz recomendações para os usuários em ordem de prioridade. A fim de organizar os clusters de qualidade, nós organizamos um grupo de peritos e tem a sua opinião para organizar os clusters de qualidade usando Grupo Rede Social. Redes sociais podem ser utilizados de forma eficiente para obter a opinião de vários tipos de grupos de peritos. A fim de estabelecer a prioridade, utilizou-se comparações de pares para calcular os pesos de prioridade de cada atributo de qualidade ao mesmo tempo representando suas inter-relações. Finalmente, usando o modelo de rede de qualidade e prioritárias pesos, este estudo avaliou três tipos de SaaS ERPs. Nossos resultados mostram como encontrar os SaaS ERPs mais adequadas de acordo com a sua correlação com os critérios e recomendar um pacote de ERP em SaaS que precisa melhor se adapte às dos usuários.' where itemID = '1517';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'A metodologia MCDM híbrido para ERP problema de seleção com critérios interagindo', RESUMO_TRADUZIDO = 'Um sistema de planejamento de recursos empresariais (ERP) é um sistema de informação para planejar e integrar todos os subsistemas de uma empresa, incluindo a compra, produção, vendas e finanças. Adopção de um quadro tão abrangente pode resultar em grande economia de custos e horas-homem. Esta pesquisa explora a aplicação de um procedimento de tomada de decisão multicritério híbrido (MCDM) para a avaliação de várias alternativas de ERP. O quadro de avaliação proposto integra três metodologias: processo analítico de rede (ANP), Choquet integral (Cl) e Atratividade de medição por uma técnica de avaliação com base categórica (MACBETH). ANP produz as prioridades de alternativas em relação aos critérios de avaliação interdependentes. Os comportamentos conjuntivo ou disjuntivas entre os critérios são determinados utilizando MACBETH e Cl. Aplicação numérica da metodologia proposta é implementada no problema tomada de decisão de uma empresa que enfrenta com quatro projetos de ERP. A classificação final é comparado com o obtido por ignorando as interacções entre critérios. Os resultados demonstram que a ignorância das interações pode levar a decisões erradas. (C) 2012 Elsevier B.V. Todos os direitos reservados.' where itemID = '1520';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Medir a possibilidade de sucesso de implementação de ERP, utilizando as relações de preferência Linguísticos incompletos', RESUMO_TRADUZIDO = 'Este artigo aplica-se um modelo de previsão hierárquico analítico com base em decisão do multi-critério Fazendo com relações de preferência Linguísticos incompletos (InLinPreRa) para ajudar as organizações a se tornarem conscientes dos fatores essenciais que afetam o Enterprise Resource Planning (ERP), bem como identificar as ações necessárias antes de implementar ERP. A subjetividade e imprecisão nos procedimentos de previsão são tratadas variáveis ​​lingüísticas quantificados em um intervalo [-t, t]. Em seguida, previu sucesso / insucesso valores são obtidos para permitir às organizações decidir se iniciar ERP, inibir a adopção ou a tomada de acções correctivas para aumentar a possibilidade de sucesso de ERP. Comparações de pares são usados ​​para determinar os pesos prioritárias de fatores influentes, e as possíveis classificações de ocorrência de sucesso ou fracasso resultado entre os tomadores de decisão. Não há qualquer inconsistência ocorreu neste procedimentos, porque esta abordagem proposta permite que cada perito decisão de escolher um critério explícito ou alternativa para o sem restrição. Quando há n critérios em uma matriz de decisão, apenas n - 1 são tomadas tempos de comparações de pares. Esta abordagem não só melhora a eficiência de comparação aos pares em comparação com o AHP tradicional, mas também evita a verificação da consistência de relação de preferência linguística quando os tomadores de decisão comprometem os processos de comparação de pares. (C) 2011 Elsevier B. V. Todos os direitos reservados.' where itemID = '1521';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Strategic Enterprise Resource Planning em um de cuidados de saúde sistema utilizando um modelo de Tomada de Decisões multicritério', RESUMO_TRADUZIDO = 'Este artigo trata de planejamento de recursos empresariais estratégicos (ERP) em um sistema de cuidados de saúde através de um processo de tomada de decisão multicritério (MCDM) modelo. O modelo é desenvolvido e analisado com base em dados obtidos a partir de um fornecedor líder orientada para o doente de serviços de cuidados de saúde na Coréia. Critérios e prioridades objetivo são identificados e estabelecidos através da análise hierárquica (AHP). Programação por metas (GP) é utilizado para obter soluções satisfatórias para a concepção, avaliação e implementação de um ERP. Os resultados do modelo são avaliados e análises de sensibilidade são conduzidos em um esforço para melhorar o modelo de aplicabilidade. O estudo de caso fornece gerenciamento com informações valiosas para o planejamento e controle das atividades e serviços de cuidados de saúde.' where itemID = '1523';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Sistema de apoio distorcido baseado no AHP decisão para a seleção de sistemas ERP na indústria têxtil, utilizando balanced scorecard', RESUMO_TRADUZIDO = 'Um sistema de planejamento de recursos empresariais (ERP) é a espinha dorsal de informação de uma empresa que integra e automatiza todas as operações comerciais. É uma questão crítica para selecionar o sistema de ERP adequado que atende a todas as estratégias de negócio e os objetivos da empresa. Este estudo apresenta todos abordagem para selecionar um sistema de ERP Adequado para indústria têxtil. Empresas têxteis têm resolver as dificuldades de implementar sistemas ERP, tais como estrutura variante de produtos, a variedade de produção e recursos humanos não qualificados. No início, a visão e as estratégias do arco organização verificado usando balanced scorecard. De acordo com a visão da empresa. estratégias e KPIs, que chamamos de preparar um pedido de proposta. Então pacotes ERP que não cumprem os requisitos da empresa são eliminados. Após fase de gestão estratégica, a metodologia proposta dá conselhos antes da seleção ERP. Os critérios foram determinados e comparados de acordo com a sua importância. As soluções de sistemas ERP de descanso foram selecionados para avaliar. Uma equipa de avaliação externa consiste em consultores de ERP foi designado para selecionar uma destas soluções de acordo com os critérios pré-determinados. Neste estudo, o processo de hierarquia analítica distorcido, uma extensão difusa do multi-critérios de tomada de decisão técnica AHP, foi utilizado para comparar estas soluções de sistemas ERP. A metodologia foi aplicada para uma empresa de fabricação de têxteis. (c) 2008 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1526';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um sistema de suporte à decisão integrado lidar com objectivos qualitativos e quantitativos para a seleção de software empresarial', RESUMO_TRADUZIDO = 'Os métodos anteriores para a seleção de software empresarial geralmente levam em conta os atributos que são restritos a alguns fatores financeiros, tais como custos e benefícios. No entanto, a literatura não tem em estudos considerando a avaliação da adequação tanto funcional e não funcional de software alternativas contra vários requisitos. Este estudo apresenta um novo sistema de apoio à decisão para combinar estes dois tipos de avaliação para selecionar software empresarial adequado. A estrutura objetiva hierárquica que contém ambos os objectivos qualitativos e quantitativos é proposto para avaliar os produtos de software de forma sistemática. Esta abordagem usa um algoritmo heurístico, um processo multi-critério tomada de decisão difusa e um modelo de programação multi-objetivo fazer decisão final de selecção. Todas as fases do método apresentado são aplicadas em projeto de seleção de software ERP de uma empresa de eletrônicos para validá-lo com um aplicativo real. Os resultados satisfatórios são obtidos durante este projeto. A empresa pode selecionar o software certo para caber seus processos de negócio, em vez de adaptar os seus processos de negócio para ajustar o software. (C) 2008 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1527';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Abordagens para gerir a informação linguística difusa hesitante com base na distância e similaridade do cosseno de medidas para HFLTSs e sua aplicação na tomada de decisão qualitativa', RESUMO_TRADUZIDO = 'As informações qualitativas e hesitante é comum na prática processo de tomada de decisão. Em tão complicado problema tomada de decisão, é flexível para que os peritos usam expressões lingüísticas comparativas para expressar as suas opiniões, pois as expressões lingüísticas são muito mais perto do termo lingüístico única ou simples para modo humano de pensar e de cognição. O conjunto termo lingüístico distorcido hesitante (HFLTS) acaba por ser uma ferramenta poderosa na representação e provocando as expressões lingüísticas comparativas. A fim de desenvolver algumas abordagens para a tomada de decisão com informação linguística difusa hesitante, neste artigo, em primeiro lugar, introduzir uma família de novos medidas de distância e similaridade para HFLTSs, tais como as medidas de distância cosseno e similaridade, as medidas ponderadas distância cosseno e de similaridade, a distância fim ponderada cosseno e medidas de similaridade, e as medidas contínuas distância cosseno e similaridade. São propostas todas estas medidas de distância e similaridade do ponto de vista geométrico, enquanto as medidas existentes distância e por similaridade HFLTSs baseiam-se nas diferentes formas de medidas de distância álgebra. Depois, com base nas medidas hesitantes distância cosseno linguística difusa entre os elementos lingüísticos difusos hesitantes, o método HFL-TOPSIS baseado em co-seno distância eo método HFL-Vikor baseado em co-seno-distância são desenvolvidos para lidar com hesitante linguística vários critérios tomada de decisão difusa problemas. O passo a passo de algoritmos esses são dados dois métodos para a conveniência de aplicações. Por fim, um exemplo numérico que respeita à selecção dos sistemas de ERP é dado para ilustrar a validação e a eficiência dos métodos propostos. (C) 2015 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1578';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um modelo de ERP para seleção de fornecedores na indústria eletrônica', RESUMO_TRADUZIDO = 'Asus Tech, é a maior fabricante da placa-mãe em Taiwan. Centenas de fornecedores colaborar com a empresa no negócio. Assim que a seleção de fornecedores é a função mais importante de um departamento de compras da empresa. Um sistema de planejamento de recursos empresariais (ERP) no processo de seleção de fornecedores pode resultar em grande economia de custos e horas-homem. No conceito de empurrar e puxar, um sistema ERP atua como uma ferramenta eficiente na integração de recursos e criação de lucro para a empresa. Através de ERP, um gerente de decisão pode perceber claramente a força ea fraqueza da operação de compra. Para estabelecer um ambiente em tempo real de compra, uma metodologia de processo analítico de rede (ANP), a técnica de preferência por ordem semelhança com solução ideal (TOPSIS) e programação linear (LP) são efectivamente aplicadas no processo de seleção de fornecedores. ANP e TOPSIS são usadas para calcular o peso e fornecedores dar uma classificação; LP efetivamente aloca quantidade para cada fornecedor. Quanto ao resultado, quatro placa PC fornecedores são dadas ordens para 1200, 727, 1000 e 73 peças. (C) 2010 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1585';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Avaliação de projetos de desenvolvimento de software utilizando uma abordagem de decisão multi-critério distorcido', RESUMO_TRADUZIDO = 'O desenvolvimento de software é uma atividade inerentemente incertas. Para lidar com a incerteza e imprecisão da percepção e experiência no processo de decisão subjetiva dos seres humanos, este trabalho apresenta um modelo de avaliação baseado no método difuso multi-critérios de tomada de decisão (MCDM) para medir o desempenho de projetos de desenvolvimento de software. Em um problema MCDM, um tomador de decisão (DM) tem que escolher a melhor alternativa que satisfaça os critérios de avaliação entre um conjunto de soluções candidatas. Em geral, é difícil encontrar uma alternativa que atenda a todos os critérios em simultâneo, portanto, uma boa solução de compromisso é o preferido. Este problema pode tornar-se mais complexa quando vários DMs estão envolvidos, cada um não ter uma percepção comum sobre as alternativas. Recentemente, um método de classificação de compromisso (conhecido como o método Vikor) tem sido proposto para identificar tais soluções de compromisso, proporcionando um grupo de utilidade máxima para a maioria e um mínimo de um indivíduo para pesar o adversário. Na sua configuração actual, o método trata valores exatos para a avaliação das alternativas, que podem ser bastante restritiva com critérios não quantificáveis. Isso será especialmente verdadeiro se a avaliação é feita por meio de termos lingüísticos. Por esta razão, nós estendemos o método Vikor de modo a processar esses dados e fornecer uma avaliação mais abrangente em um ambiente difuso. Para demonstrar o potencial da metodologia, a prorrogação proposta é usado para medir o desempenho de produtos de software de recursos empresariais (ERP). (C) 2007 IMACS. Publicado por Elsevier BV Todos os direitos reservados.' where itemID = '1586';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Avaliação de ERP terceirização', RESUMO_TRADUZIDO = 'A terceirização tem evoluído como um meio viável para alcançar economias de custos em tecnologia da informação organizacional. Esta opção, no entanto, envolve riscos significativos. Este artigo discute por que os modelos formais de avaliação de custos são difíceis de aplicar na presente decisão, e demonstra como métodos multi-critérios podem ser utilizados para apoiar esta decisão crítica. (c) 2006 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1599';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Combinando Tomada de Decisão e Avaliação de teste de laboratório com processo analítico rede para executar uma investigação de Auditoria de Tecnologia da Informação e Controle de Riscos em um Enterprise Resource Planning Ambiente', RESUMO_TRADUZIDO = 'A pesquisa examinou diferentes tipos de risco através de entrevistas com especialistas. Os riscos estudados incluem o risco de interrupção de negócios, riscos de processos de interdependência e risco a segurança do sistema. A tomada de experimentação e avaliação laboratorial decisão é usado para encontrar a relação entre riscos e combinado com o processo de rede analítico para selecionar as medidas ideais para reduzir os riscos. Os resultados indicam que a tecnologia da informação (TI) consultores preferem o Disaster Recovery Plan (DRP). Eles costumam usar a replicação remota ou High Availability (HA) para proteger os dados. O pessoal de TI acreditam que todos os controles de riscos de TI são importantes. Contas indicam que o controle de acesso de dados é muito importante porque os usuários têm acesso a dados para executar todos os dias. Usuários de TI expressar uma preferência para controle de entrada / saída de dados como o controle mais importante. Os resultados obtidos a partir de todos os peritos indicam que os controles mais importantes global são a entrada de dados / controle de saída, controle de acesso de dados e assim por diante. Os gerentes precisam considerar esses riscos para evitar eventuais problemas. Copyright (c) 2012 John Wiley & Sons, Ltd.' where itemID = '1607';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um Modelo de Avaliação híbrido Novel para o desempenho do ERP projeto com base em ANP e melhorado Matéria-Elemento Extension Modelo', RESUMO_TRADUZIDO = 'Consideráveis recursos são necessários ao implementar o projeto de ERP, por isso, é necessário avaliar o seu desempenho. Em primeiro lugar, o sistema de índice de avaliação de desempenho da implementação do projeto de ERP foi construído, e um processo analítico Network (ANP), que pode perfeitamente ter a relação entre índices de avaliação em conta foi utilizada para determinar o peso do índice. Em segundo lugar, um modelo de extensão matéria-elemento melhorado, que pode superar as limitações e insuficiências do tradicional modelo de extensão matéria-elemento ao realizar a avaliação abrangente, foi proposto para avaliar o desempenho implementação do projeto ERP. Por último, tendo projeto de ERP de uma empresa como um exemplo, uma avaliação abrangente foi feito, e o resultado da análise empírica mostra que este modelo de avaliação híbrido proposto é viável e prático.' where itemID = '1610';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'O desenvolvimento de um quadro prático para a avaliação de prontidão ERP usando o processo analítico rede difusa', RESUMO_TRADUZIDO = 'Estudos anteriores relatam invulgarmente elevado fracasso em projetos de planejamento de recursos empresariais (ERP). Assim, é necessária a realização de uma avaliação na fase inicial de um programa de implementação de ERP para identificar debilidades ou problemas que podem levar ao fracasso do projeto. Pode ser encontrada uma solução prática definitiva para esses tipos de problemas na literatura. Neste trabalho, um novo olhar sobre os determinantes da prontidão de uma empresa para implementar um projeto de ERP é apresentado e usando o processo analítico rede difusa de um quadro prático é desenvolvido. Condições atuais da empresa a respeito do projeto ERP pode ser determinada e as mudanças necessárias antes da implantação do sistema ERP pode ser especificado. A prontidão para implementação de ERP é decomposto em gerenciamento de projetos, áreas de gestão organizacional e mudança e os factores de avaliação são identificadas após estudo detalhado dos fatores críticos de sucesso na implementação de ERP. A estrutura proposta é aplicada a um caso real e as vantagens são ilustradas. (C) 2009 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1616';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um processo de seleção de software ERP com o uso de rede neural artificial baseada em abordagem analítica processo rede', RESUMO_TRADUZIDO = 'Uma seleção de software de planejamento de recursos empresariais (ERP) é conhecido por ser multi problema tomada de decisão atributo (MADM). Este problema foi modelado de acordo com processo analítico método rede (ANP), devido a Tato que considera critérios e critérios relações e inter-relações sub na escolha do software. Opiniões de muitos especialistas são obtidos enquanto a construção de modelo ANP para o ERP seleção, em seguida, opiniões arco reduzida para um único valor através de métodos como médias geométricas de modo a obter os resultados desejados. Para usar o modelo ANP para a seleção de ERP para uma nova organização, um novo grupo de opiniões de especialistas são necessários. Neste caso, o mesmo problema irá ser em contracorrente. No modelo proposto, quando os modelos da ANP e Ann são a instalação, uma seleção de software ERP pode ser feita facilmente pelas opiniões de um único perito. Nesse cálculo caso da média geométrica de respostas que obtidos a partir de muitos especialistas será desnecessário. Além disso, o efeito da opinião subjetiva de um único tomador de decisão serão evitados. Em termos de dificuldade, a ANP tem algumas dificuldades devido ao valor próprio e seu cálculo do valor limite. Um modelo de ANN foi concebido e treinou com o uso de resultados da ANP, a fim de calcular prioridade software ERP. O modelo de rede neural artificial (RNA) é treinado por resultados obtidos a partir ANP. Parece que não existe qualquer dificuldade de maior, a fim de prever as prioridades de software com modelo ANN treinada. Por isso resulta modelo ANN foi vir apropriado para usar na seleção de ERP para uma outra nova decisão. (C) 2008 Elsevier Ltd. Todos os direitos reservados.' where itemID = '1617';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Apoiar a decisão módulo de sequenciamento no processo de implementação de ERP-An aplicação do método da ANP', RESUMO_TRADUZIDO = 'O artigo aborda o alinhamento entre os processos de negócios e tecnologia da informação em planejamento de recursos empresariais (ERP) implementação. Mais especificamente, nós nos concentramos em uma das decisões-chave a nível de alinhamento tático: a decisão sobre a sequência de implementação dos módulos de ERP. Uma vez que o módulo de sequenciação problema envolve uma miríade de problemas técnicos e organizacionais, ligados uns aos outros em forma de rede, o processo analítico metodologia rede (ANP) é aplicado. Como resultado do estudo, apresentamos pela primeira vez um quadro geral nível conceitual para sequenciar implementações de módulos de ERP e expandir o modelo para um nível mais detalhado em um estudo de caso. As prioridades para a sequência de implementação dos módulos de ERP são determinados no estudo de caso. (C) 2009 Elsevier B.V. Todos os direitos reservados.' where itemID = '1618';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Determinando ERP opções de personalização que usam técnica de grupo nominal e processo de hierarquia analítica', RESUMO_TRADUZIDO = 'Um sistema de planejamento de recursos empresariais (ERP) é um sistema de informação que suporta e integra muitas facetas de um negócio. Uma questão crítica na implementação de ERP é a forma de preencher a lacuna entre o sistema ERP e os processos de negócio de uma organização, personalizando ou o sistema, ou os processos de negócio da organização, ou ambos. A revisão da literatura mostra que a personalização é um grande obstáculo na maioria dos projetos de implementação de ERP. Esta pesquisa se aplica a técnica de grupo nominal (NGT) e processo de hierarquia analítica. (AMP) técnicas ao quadro de Luo e forte para ajudar as organizações a determinar opções de personalização viáveis para suas iniciativas de implementação de ERP. Um estudo de caso é apresentado para ilustrar sua aplicabilidade na prática. O estudo tem implicações teóricas e práticas para a nossa compreensão do processo de implementação de ERP. (C) 2014 Elsevier B.V. Todos os direitos reservados.' where itemID = '1634';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Determinantes da escolha de Software semântica baseada na web como um serviço: Um quadro integrador no contexto do e-procurement e ERP', RESUMO_TRADUZIDO = 'A largura de banda de Internet cada vez maior e as necessidades em rápida mutação das empresas para a eficácia com os parceiros da cadeia de suprimento e está levando as organizações a adotar infra-estruturas de sistemas de informação que são rentáveis, bem como flexível. A questão parece ser: o que está levando as organizações a ir para Software as a Service (SaaS) de e-procurement e ERP baseado, ao invés do modelo de provisionamento de software empacotado? Considerando que há estudos que relatam a tecnologia, custo, qualidade, externalidades de rede e processo como as principais variáveis ​​na função de utilidade do usuário, mas a maioria dos estudos têm modelado de um ou dois dos seus modelos. O estudo é de natureza exploratória e tenta identificar, classificar e dimensões de classificação que afetam as decisões de fornecimento de SaaS. Neste estudo, desenvolvemos um quadro integrativo para identificar os determinantes da escolha de SaaS no contexto específico de SaaS baseados e-procurement e ERP. O quadro foi então analisada usando método Analytic Hierarchy Process estendida (AHP) sugerido pela Liberatore (1987) ea importância relativa e os pesos dos critérios identificados usando os dados coletados em 8 usuários e 9 fornecedores de SaaS de serviços baseados e-procurement e ERP . Embora a análise ajudou na identificação de qualidade e custos como os dois mais importantes determinantes da escolha de SaaS baseados e-procurement e ERP, mas os outros critérios, tais como benefícios das externalidades de rede, tecnologia e processo também foram encontrados para ser determinantes significativos de escolha. (C) 2014 Elsevier B.V. Todos os direitos reservados.' where itemID = '1635';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Avaliação da importância relativa dos critérios para a seleção de Sistemas Integrados de Gestão (ERP) para uso em empresas da construção civil', RESUMO_TRADUZIDO = 'A adoção de ERP (Enterprise Resource Planning) por empresas introduziu a necessidade de avaliação e seleção de tais sistemas. Esta discussão está inserida em um contexto de múltiplas percepções ou critérios de avaliação. No presente estudo, uma revisão sistemática da literatura foi realizada em um conjunto de artigos publicados em revistas indexadas na base Scopus, ISI Web of Science, e bancos de dados Engenharia Aldeia enfocando a avaliação de múltiplos critérios de sistemas de ERP. Com base nesta revisão da literatura, os critérios e sub-critérios foi estabelecido, o qual foi submetido à validação por um grupo de profissionais com forte seleção ERP Sistema e experiência de implementação, resultando em uma árvore composta por 45 sub-critérios agrupados em cinco critérios. Uma pesquisa de TI e as áreas de construção civil foi realizado em uma amostra de 79 respondentes, a fim de investigar a importância relativa desses critérios. O inquérito demonstrou que os grandes, Negócios, e critérios Financial Software foram consideradas pelos entrevistados como o mais importante.' where itemID = '1636';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Comparando-se a importância relativa dos critérios de avaliação na seleção de software de aplicações empresariais proprietárias e de código aberto - um estudo conjunto de sistemas ERP e Office', RESUMO_TRADUZIDO = 'Até recentemente, as organizações que desejam adquirir sistemas de aplicação não tiveram escolha a não ser adotar o software proprietário. Com o advento do software de código aberto (OSS), um novo modelo de desenvolvimento e distribuição de software entrou no palco. OSS tem evoluído a partir de uma infra-estrutura geralmente horizontal para aplicações mais altamente visível em domínios verticais, dando sistemas de informação (SI) gestores mais graus de liberdade em sua seleção de software de aplicações empresariais (EAS). Apesar de um grande corpo de pesquisa existente sobre a importância relativa dos critérios de avaliação para EAS proprietárias, o papel dos OSS no processo de avaliação EAS tem recebido pouca atenção até agora. Para preencher esta lacuna de investigação, este estudo representa a primeira investigação empírica para comparar a importância relativa dos critérios de avaliação na seleção EAS proprietárias e de código aberto. Através de uma pesquisa on-line, avaliou as respostas dos gestores é de 358 organizações para a desova estudo conjunto 8592 comparações par de compromisso e 3580 avaliações de compra sobre o planeamento de propriedade e iniciativa open-source de recursos (ERP) e pacotes de software do Office. Os resultados mostram que a importância relativa dos critérios de avaliação varia significativamente entre os sistemas ERP proprietárias e de código aberto. Fatores de implementação, como facilidade de implementação e suporte são muito mais cruciais na avaliação de código-fonte aberto do que de sistemas ERP de propriedade, que é geralmente devido a' where itemID = '1645';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Um desenvolvimento modelo de avaliação de desempenho do sistema ERP baseado na abordagem do balanced scorecard', RESUMO_TRADUZIDO = 'Anteriormente investigação realizada não foi significativa quando se considera o aspecto de obter um modelo para medir o desempenho de um sistema de Enterprise Resource Planning (ERP). Portanto, esta pesquisa tenta apresentar um modelo de avaliação objetiva e quantitativa baseada na abordagem Balance Scorecard com a finalidade de avaliar o desempenho do sistema ERP. A metodologia utilizada na pesquisa envolve a Grounded Theory, Expert Questionnaire, o Analytic Hierarchy Process, ea Teoria dos Conjuntos Fuzzy para filtrar e desenvolver os KPIs para o modelo de avaliação de desempenho do sistema ERP. Espera-se que tal modelo pode ser utilizado por empresas para avaliar a eficiência do sistema ERP durante as várias fases de gestão e de apoio dentro do sistema. Finalmente, este modelo de avaliação é verificado em uma empresa caso através da análise da sua abordagem de avaliação imparcial e quantificáveis. Este resultado permite-nos compreender ainda mais a eficiência autêntico, e explorar se as empresas cumpriram as suas objetivos propostos após a introdução do sistema de ERP.' where itemID = '1646';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Uma abordagem multicritério para avaliação de riscos na manutenção ERP', RESUMO_TRADUZIDO = 'Planejamento de recursos empresariais (ERP) não pode permanecer estático após a sua implementação, eles precisam de manutenção. Manutenção ERP é um processo essencial exigida pelo ambiente de negócios em rápida mudança e as necessidades habituais de manutenção de software. No entanto, esses projetos são altamente complexo e arriscado. Assim, a gestão de riscos associados a projetos de manutenção de ERP é crucial para atingir um desempenho satisfatório. Infelizmente, os riscos de manutenção ERP não foram estudadas em profundidade. Por esta razão, este artigo apresenta um risco taxonomia geral. Ele reúne os riscos que afetam o desempenho de manutenção ERP. Além disso, os autores usam a metodologia analítica processo hierarquia (AHP) para analisar os riscos fatores identificados. Ela ajuda a gerentes, vendedores, consultores, auditores, usuários e equipe de TI para gerenciar a manutenção ERP melhor. Os resultados sugerem que a fase mais crítica na manutenção ERP é a primeira fase, que recebe, identifica, classifica e classifica a modificação do software. Os perigos mais importantes na manutenção ERP são a cooperação eo compromisso dos usuários de ERP e gestores. Crown Copyright (c) 2010 Publicado por Elsevier Inc. Todos os direitos reservados.' where itemID = '1650';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'O pedido de seleção de software ERP baseada em capacidade modular usando o método AHP', RESUMO_TRADUZIDO = 'Resource Planning (ERP) seleção sistema da empresa é muito importante para uma empresa como isso afeta completamente produção e serviço metodologia das empresas. Além disso, a seleção ERP está ficando cada vez mais difícil por causa de uma grande variedade de soluções de software ERP disponíveis. O presente estudo tem o objetivo de selecionar o software mais adequado entre dois candidatos eleitos após algumas análises para a decisão final, usando uma técnica com processo de hierarquia analítica apoio (AHP) em uma fábrica que está planejando usar o software ERP que se adapta as suas funções.' where itemID = '1658';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Seleção de fornecedores de ERP usando ferramentas AHP na indústria do vestuário', RESUMO_TRADUZIDO = 'Objetivo - O objetivo deste trabalho é explorar a seleção dos melhores fornecedores de ERP no sector do vestuário, utilizando análise hierárquica (AHP). Desenhista / metodologia / abordagem - AHP é usado para atingir o propósito do papel; critérios de seleção são determinados por gestores e especialistas. Apreciação - Três planejamento de recursos empresariais diferente (ERP) fornecedores são investigados e melhor alternativa é selecionado usando AHP. Após a melhor alternativa é selecionado, a análise de custo-benefício é calculado de forma a definir resultado decisivo. Todos os cálculos são verificados através da realização do teste de consistência. Limitações da pesquisa / implicações - Critérios de selecção e suas avaliações podem ser alteradas dependendo do tamanho da fabricante de roupas e tipo de produto. Originalidade / valor - Os resultados do estudo serão úteis para os fabricantes de vestuário que planeja implementar um sistema de ERP em suas organizações. Além disso, eles podem usar o AHP em outros problemas de decisão bem.' where itemID = '1660';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Modelo para la selección de software ERP: El caso de Venezuela', RESUMO_TRADUZIDO = 'Enterprise Resource Planning (ERP Sistemas) tornaram-se elementos críticos na área de fabricação. Um sistema ERP é composto de um conjunto de ferramentas de gestão que suportam o processo de tomada de decisão, gerar a plena integração entre as áreas funcionais da empresa, produzir altos níveis de produtividade na cadeia de abastecimento e reduzir os custos da empresa e inventários, entre muitos outros benefícios . No entanto, o processo de seleção de software ERP não é uma tarefa fácil e precisa de atenção especial. A fim de tornar este processo o mais eficaz e eficiente possível, um modelo é proposto neste artigo. Este modelo permite que as empresas para encontrar a alternativa mais adequada para as necessidades da organização, tendo em conta a experiência de outras empresas que já utilizaram os sistemas de ERP, a fim de obter eficiência no processo de seleção, bem como na implementação e operação do sistema. O modelo leva em conta a participação de empresas venezuelanas, que já implementaram software ERP e permitem a organização de incorporar as suas necessidades específicas e critérios específicos, como variáveis ​​de entrada. O modelo foi desenvolvido com base no artigo: "Fatores para a seleção de software ERP em empresas de grande porte: o caso venezuelano» [Castro, 2004], aplicando o Analytic Hierarchy Process (AHP) e utilizando ferramentas estatísticas como análise de cluster.' where itemID = '1670';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Selecionando uma aplicação de Tecnologia da Informação com enfoque na eficácia: um estudo de caso de um sistema para PCP', RESUMO_TRADUZIDO = 'Ao longo dos anos, Tecnologia da Informação (TI) está crescendo o seu papel de apoio às actividades de produção. No início, as atividades realizadas pela TI eram muito simples, mas hoje em dia, ele suporta quase todas as atividades de produção, incluindo processos e produtos desenvolvimento. Planejamento e Controle da Produção é uma área específica onde a TI pode efetivamente trazer impactos significativos, abrindo horizontes para novas estratégias operacionais e até mesmo estratégias de negócios. Exemplos de como a TI pode ajudar o meio ambiente operacional são o uso de MRP, MRP II e ERP. Por outro lado, persistem as dúvidas sobre os resultados obtidos com os investimentos em TI. A fim de avaliar os impactos de TI nas operações da organização, é necessário uma abordagem comparando os resultados das aplicações de TI relacionados com os objetivos, metas e requisitos de produção e de toda a organização, em outras palavras, considerando a eficácia de aplicações. Este artigo relata um estudo de caso relacionado com a seleção de uma nova aplicação de TI no planejamento de produção em uma indústria. Este trabalho foi desenvolvido em uma grande empresa de fabricação e discute-se impactos da TI na gestão de operações e negócios na organização. AHP (Analytic Hierarchy Process) foi a ferramenta utilizada para o processo de tomada de decisão.' where itemID = '1677';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Fatores que influenciam a investigar os tomadores de decisão do governo local, enquanto a adoção de tecnologias de integração (IntTech)', RESUMO_TRADUZIDO = 'O surgimento de tecnologias inovadoras e revolucionárias de Integração (IntTech) foi altamente influenciado as autoridades do governo local (LGAs) no seu processo de tomada de decisão. OPL que planejam adotar tais IntTech pode considerar isso como um investimento sério. Defende, no entanto, afirmam que tais IntTech surgiram para superar os problemas de integração em todos os níveis (por exemplo, dados, objetos e processos). Com o surgimento do governo electrónico (e-Government), os OPL se voltaram para IntTech para automatizar totalmente e oferecer os seus serviços on-line e integrar suas infraestruturas de TI. Embora pesquisas anteriores sobre a adoção de IntTech considerou vários fatores (por exemplo, pressão, tecnológica, apoio e financeira), atenção e recursos inadequados têm sido aplicados em investigar sistematicamente os fatores individuais, de decisão e de contexto organizacional, influenciar as decisões da gestão de topo para a adopção IntTech em OPL. É um fenômeno altamente considerado que o sucesso das operações de uma organização depende fortemente de compreender as atitudes de um indivíduo e comportamentos, do contexto envolvente e do tipo de decisões tomadas. Com base na evidência empírica recolhida através de dois estudos de caso intensivo, este trabalho procura investigar os fatores que influenciam os tomadores de decisão ao adotar IntTech. Os resultados ilustram duas doutrinas diferentes um inclinado e receptivo no sentido de tomar decisões arriscadas, o outro inclinado. Várias justificativas subjacentes podem ser atribuídos a tais mentalidades em OPL. Os autores propõem-se contribuir para o corpo de conhecimento, explorando os fatores que influenciam o processo decisório da alta administração ao adotar IntTech vital para facilitar reformas operacionais dos LGAs. (C) 2014 Elsevier B.V. Todos os direitos reservados.' where itemID = '1684';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Demanda e apoio à integração de aplicativos corporativos na Nigéria', RESUMO_TRADUZIDO = 'A demanda e apoio à integração dos aplicativos empresariais (EAI) na Nigéria foi investigada. Os resultados mostram que a demanda e suporte para EAI são movidos por uma série de fatores, incluindo a preocupação com dados / integração de informações, uma interface comum para todas as aplicações empresariais, de uma melhor comunicação e transferência de dados mais rápida, captura de dados em tempo real e acesso à informação através de várias redes, bem como os dados e integridade das informações em vários sistemas. As empresas de TI na Nigéria estão seguindo o progresso da tecnologia e estão preparados para responder a ela em suas abordagens para soluções de EAI. Suas abordagens futuras será influenciado na maior medida pelo progresso na interface gráfica do usuário (GUI) e, em seguida, pela evolução do Enterprise Resource Planning (ERP), sistemas operacionais, software como serviço (SaaS), parametrização de aplicações para uma fácil personalização, Aplicações Prestação de serviços e sistemas de código aberto em que ordem. Eles acreditam que a Nigéria tem a maior capacidade de Software as a Service (SaaS) e Software como Serviço Garantido (SASS). Um número crescente de empresas estão usando ferramentas de código aberto no desenvolvimento e implementação de soluções de EAI, e esta é uma indicação de um mercado que está a assumir a sua própria personalidade, mas também uma inscrição para a democratização do acesso software. A popularidade do SQL Server e suas variedades, seguido de perto pela Oracle e Java / Javascript, como ferramentas de EAI na Nigéria é provavelmente um reflexo de seu destaque no cenário internacional.' where itemID = '1685';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Quadro Business-to-government integração de aplicações: Um estudo de caso da indústria de alta tecnologia em Taiwan', RESUMO_TRADUZIDO = 'Integração business-to-government (B2Gi) requer o desenvolvimento de um framework de integração único, inter-organizacional para cumprir os requisitos dinâmicos de várias entidades empresariais e organizações governamentais. Os autores propuseram uma estrutura conceitual para o prestador de serviços de integração inter-organizacional (IISP) como uma diretriz filosófica e estratégica para o desenvolvimento de integração inter-organizacional. Um estudo de caso do mundo real foi discutida, com a apresentação de um modelo de custo-benefício para avaliar a possibilidade de adopção de tal modelo de negócio. Com a ajuda da orientação para B2Gi, prevê-se que o modelo de integração proposto irá aproveitar o trade-off entre as questões de flexibilidade e controlabilidade. (C) 2013 Elsevier B.V. Todos os direitos reservados.' where itemID = '1687';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Sistemas de informação de logística - Uma análise de soluções de software para cadeia de suprimentos coordenação', RESUMO_TRADUZIDO = 'Objetivo - avaliar o desenvolvimento de aplicativos de software e suas funcionalidades / benefícios em relação ao supply chain management e atuais cenários de desenvolvimento futuro. Desenhista / metodologia / abordagem - Uma gama de peças acadêmicos e não-acadêmicos publicados recentemente de trabalho que podem ser classificados como pertinentes à área em questão. Estas fontes empregam ambas as visões teóricas e práticas sobre o tema do software da cadeia de suprimentos de coordenação e funcionalidades relacionadas e resultou benefícios. Apreciação - Há uma sobreposição significativa sobre as funcionalidades de aplicações de software ea tendência de convergência está prestes a se intensificar. Ao mesmo tempo, a necessidade de informação em tempo real vai se tornar fundamental, colocando ênfase em sistemas de TI flexíveis que podem lidar com grandes quantidades de dados e são fáceis de interconexão. Por sua vez isso vai levar à crescente importância do software de integração de sistemas e processo de criação de normas. Limitações da pesquisa / implicações - Como resultado do contínuo desenvolvimento e convergência de soluções de TI e ambiente de negócios turbulento mais investigação aplicada serão necessárias na área da configuração do produto, tecnologia RFID, as normas em relação à interoperabilidade de aplicações de software (tecnologias EAI) . Este controlo é baseado apenas em recursos escritos e foram empregados há consultores ou entrevistas gerente. Portanto, os pontos de vista das empresas não são apresentados nas questões abrangidas. Implicações práticas - A seleção das soluções de software apropriadas para uma empresa vai precisar de mais tempo, experiência e dinheiro e o papel de fornecedores de pacotes de software se tornará mais significativo. Originalidade / valor - Este escrutínio estipula a forma como as funcionalidades de aplicações de software evoluir com sobreposição uns dos outros e, assim, ajuda os pesquisadores e empresas para obter uma visão mais clara sobre o desenvolvimento de aplicativos de software da cadeia de suprimentos.' where itemID = '1702';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Integração empresarial com ERP e EAI', RESUMO_TRADUZIDO = '-' where itemID = '1705';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Usando a rede analítica para a seleção de sistemas de planejamento de recursos empresariais (ERP) alinhadas à estratégia de negócios', RESUMO_TRADUZIDO = 'A escolha de um Enterprise Resource Planning (ERP) deve ser feita criteriosamente pelos altos custos envolvidos na aquisição de tais sistemas. Os gerentes em áreas como contabilidade, tecnologia da informação financeira e necessitam de apoio e ferramentas que ajudam na escolha de um ERP adequado para o seu negócio. Com este artigo, apresentamos um estudo teve como objetivo investigar a possibilidade de um Sistema de Apoio à Decisão (DSS) a ser utilizado para esta seleção inter-relacionando os critérios de avaliação, o que poderia permitir a contemplar o alinhamento estratégico entre Negócios e Tecnologia da Informação. A partir da revisão da literatura 28 fatores relacionados à seleção de pacotes de software, foram identificados com ênfase especial em ERP. Para os procedimentos de investigação, foram adoptadas as qualitativas, em que os 18 fatores considerados relevantes para uma boa seleção de ERP foram classificados com a técnica Delphi e usado como entrada em um DSS: Processo Rede Analítica (ANP), aplicado como um estudo de caso em uma pequena empresa que contratou o ERP. Os resultados mostraram que a ANP foi eficiente em critérios inter-relacionados e avaliou o alinhamento estratégico entre as empresas e Informações Technology.Key palavras: Seleção de Sistema de Informação; Enterprise Resource Planning - ERP; Processo Analytic Network - ANP, RESUMOA ESCOLHA de hum Sistema Integrado de Gestão (Enterprise Resourse Planning - ERP) ser desen Feita de forma criteriosa Pelos altos custódio envolvidos com a Aquisição Deste tipo de Sistema. Gestores de áreas Como Contabilidade, Financeira e Tecnologia da Informação necessitam de Apoio e Ferramentas that OS auxiliem na Seleção de hum ERP Adequado Ao Seu Negócio. Com this article, apresenta-se Uma Pesquisa that visou VerificAR a possibilidade de hum Sistema de Apoio à Decisão (SAD) ser Utilizado parágrafo ESSA Seleção, inter-relacionando criterios de avaliação, that possibilitassem contemplar o Alinhamento Estratégico Entre o Negócio ea Tecnologia de Informação . À partir da Revisão da literatura were identificados 28 Fatores Relacionados A Seleção de pacotes de software, com especial ênfase AOS Sistemas Integrados de Gestão. Para a Realização da Pesquisa, adotaram-se Procedimentos de Natureza qualitativa em that OS 18 Fatores, considerados Relevantes parágrafo Uma boa Seleção de ERP, were Classificados com uma Técnica Delphi, utilizados Como entrada em hum SAD: Processo de Rede Analítica (processo analítico de rede - ANP) e Aplicados Como Estudo de Caso em Uma Empresa de Pequeno Porte Que contratou ERP. Os Resultados obtidos demonstraram Que o ANP mostrou-se Eficiente em inter-relacionar criterios e avaliar o Alinhamento Estratégico Entre o Negócio ea Tecnologia de Informação.Palavras-Chave: Seleção de Sistema de Informação; Enterprise Resource Planning - ERP; Processo Analytic Network - ANP' where itemID = '1724';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'A aplicação da AHP em Biotechnology Industry com ERP Implementação KSF', RESUMO_TRADUZIDO = 'Esta pesquisa centrou-se na produção de Phalaenopsis, particularmente na sua implementação de planejamento de recursos empresariais, as dimensões ea adoção de AHP (Analytical Hierarchy Process). A importância do índice de avaliação e seus atributos foram revistos. Os resultados desta pesquisa mostraram que os fatores que levaram à incorporação de ERP Key Factor de Sucesso na Indústria de Biotecnologia (KSF) eram treinamento dos funcionários, o total apoio de executivos em integração de sistemas ERP, a comunicação com a empresa, assistência à formação e tecnologia transferência, em tempo real e sistema de precisão e eficiência e flexibilidade na alocação de recursos. Os resultados deste estudo irão beneficiar a indústria de biotecnologia na compreensão dos fatores importantes que contribuíram para o sucesso do ERP, e, portanto, é fundamental para o desenvolvimento de produtos e estratégias de marketing. Ele serve como uma referência para entrar no mercado de renovação.' where itemID = '139';
update A_ARTIGOS set ARTIGO_TRADUZIDO = 'Priorização de planejamento de recursos empresariais critérios sistemas: Concentrando-se em indústria de construção', RESUMO_TRADUZIDO = 'Muitas organizações utilizam sistemas integrados de gestão, que são mais conhecidos como sistemas de ERP (Enterprise Resource Planning). A utilização destes sistemas tem levado à discussão dos métodos de avaliá-los, tendo em conta as percepções e vários critérios de avaliação. Em primeiro lugar, com base em uma revisão da literatura sobre a implementação e aplicação de modelos multi-critérios para a avaliação de sistemas ERP, um conjunto de critérios de seleção do sistema ERP e subcritérios é proposto para a aplicação de ERP para empresas na indústria da construção, porque existe uma maior necessidade de apoiar as organizações brasileiro da construção civil, onde há escassez deste tipo de sistema. Posteriormente, após a validação destes critérios por um grupo de tecnologia da informação (TI) especialistas, 79 entrevistados desenhada principalmente da indústria da construção e participou em um estudo de campo para examinar suas percepções sobre a importância destes critérios. O estudo mostrou que os critérios de negócios, e de software financeiro foram mais importante para os inquiridos. Além disso, também foi apresentada a importância dos subcritérios de cada grupo de critérios para ajudar os tomadores de decisão na escolha de sistemas de ERP.' where itemID = '1';

-----------------------------------------------------------------------
update A_ARTIGOS set OBJETIVO = 'Adoção de EAI', METODO = 'AHP', SISTEMA_INFORMACAO = 'EAI', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '21' where CODIGO = 'A1';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '13' where CODIGO = 'A2';
update A_ARTIGOS set OBJETIVO = 'Seleção de PCP', METODO = 'AHP', SISTEMA_INFORMACAO = 'PCP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '11', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A3';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '20' where CODIGO = 'A4';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '13' where CODIGO = 'A5';
update A_ARTIGOS set OBJETIVO = 'Avaliar desempenho do ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Utilização', SELECAO = '', QTDE_CRITERIOS = '4', QTDE_SUBCRITERIOS = '25' where CODIGO = 'A6';
update A_ARTIGOS set OBJETIVO = 'Avaliar sucesso em projetos de implantação ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '7', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A7';
update A_ARTIGOS set OBJETIVO = 'Avaliar ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Utilização', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '10' where CODIGO = 'A8';
update A_ARTIGOS set OBJETIVO = 'Avaliar projeto de EAI entre o ERP e MES', METODO = 'AHP e VIKOR', SISTEMA_INFORMACAO = 'EAI/ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '17' where CODIGO = 'A9';
update A_ARTIGOS set OBJETIVO = 'Definir o tipo adequado de instalação (nuvem ou local) do ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '2', QTDE_SUBCRITERIOS = '5' where CODIGO = 'A10';
update A_ARTIGOS set OBJETIVO = 'Avaliar projeto de implantação ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '15' where CODIGO = 'A11';
update A_ARTIGOS set OBJETIVO = 'Avaliar riscos em projetos de implantação ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '6', QTDE_SUBCRITERIOS = '28' where CODIGO = 'A12';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP e TOPSIS', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A13';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '8', QTDE_SUBCRITERIOS = '1465' where CODIGO = 'A14';
update A_ARTIGOS set OBJETIVO = 'Seleção de fornecedores de ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '4', QTDE_SUBCRITERIOS = '14' where CODIGO = 'A15';
update A_ARTIGOS set OBJETIVO = 'Seleção de um provedor de serviços ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '6', QTDE_SUBCRITERIOS = '17' where CODIGO = 'A16';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '10' where CODIGO = 'A17';
update A_ARTIGOS set OBJETIVO = 'Avaliar viabilidade de customização do ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Desenvolvimento', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A18';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '2', QTDE_SUBCRITERIOS = '12' where CODIGO = 'A19';
update A_ARTIGOS set OBJETIVO = 'Avaliar sucesso em projetos de implantação ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '9' where CODIGO = 'A20';
update A_ARTIGOS set OBJETIVO = 'Avaliar riscos na manutenção do ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Manutenção', SELECAO = '', QTDE_CRITERIOS = '7', QTDE_SUBCRITERIOS = '30' where CODIGO = 'A21';
update A_ARTIGOS set OBJETIVO = 'Seleção consultores de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A22';
update A_ARTIGOS set OBJETIVO = 'Seleção de fornecedores de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '9', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A23';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '2', QTDE_SUBCRITERIOS = '9' where CODIGO = 'A24';
update A_ARTIGOS set OBJETIVO = 'Avaliar riscos na customização do ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Desenvolvimento', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '13' where CODIGO = 'A25';
update A_ARTIGOS set OBJETIVO = 'Seleção de fornecedores de ERP', METODO = 'ANP e TOPSIS', SISTEMA_INFORMACAO = 'ERP', FASE = 'Utilização', SELECAO = '', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '20' where CODIGO = 'A26';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '13' where CODIGO = 'A27';
update A_ARTIGOS set OBJETIVO = 'Avaliar projeto de implantação ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '10', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A28';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '17' where CODIGO = 'A29';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'ANP e MACBETH', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '16' where CODIGO = 'A30';
update A_ARTIGOS set OBJETIVO = 'Avaliar sequencia implantação dos módulos do ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '24', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A31';
update A_ARTIGOS set OBJETIVO = 'Avaliar projeto de implantação ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '3', QTDE_SUBCRITERIOS = '11' where CODIGO = 'A32';
update A_ARTIGOS set OBJETIVO = 'Avaliar projeto de EAI entre o ERP e MES', METODO = 'ANP', SISTEMA_INFORMACAO = 'EAI/ERP', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '6', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A33';
update A_ARTIGOS set OBJETIVO = 'Seleção do melhor projeto de MES', METODO = 'ANP', SISTEMA_INFORMACAO = 'MES', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '4', QTDE_SUBCRITERIOS = '25' where CODIGO = 'A34';
update A_ARTIGOS set OBJETIVO = 'Avaliar se a empresa está preparada para implantar o ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '16' where CODIGO = 'A35';
update A_ARTIGOS set OBJETIVO = 'Avaliar a flexibilidade do ERP', METODO = 'ANP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '17' where CODIGO = 'A36';
update A_ARTIGOS set OBJETIVO = 'Avaliar sistemas de BI', METODO = 'TOPSIS', SISTEMA_INFORMACAO = 'BI', FASE = 'Aquisição', SELECAO = '', QTDE_CRITERIOS = '34', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A37';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '16' where CODIGO = 'A38';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '16' where CODIGO = 'A39';
update A_ARTIGOS set OBJETIVO = 'Avaliar projeto de implantação ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Implantação', SELECAO = '', QTDE_CRITERIOS = '4', QTDE_SUBCRITERIOS = '23' where CODIGO = 'A40';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A41';
update A_ARTIGOS set OBJETIVO = 'Seleção de ERP', METODO = 'AHP', SISTEMA_INFORMACAO = 'ERP', FASE = 'Aquisição', SELECAO = 'Seleção', QTDE_CRITERIOS = '5', QTDE_SUBCRITERIOS = '0' where CODIGO = 'A42';

--###############################################################################
						 
--Validar a importação de dados da planilha
--Formula usada na planilha para o campo codigo =CONCATENAR(SE(ÉCÉL.VAZIA(D548);"";$D$1); SE(ÉCÉL.VAZIA(D548);SE(ÉCÉL.VAZIA(E548);"";"");";");SE(ÉCÉL.VAZIA(E548);"";$E$1); SE(ÉCÉL.VAZIA(E548);SE(ÉCÉL.VAZIA(F548);"";"");";");SE(ÉCÉL.VAZIA(F548);"";$F$1); SE(ÉCÉL.VAZIA(F548);SE(ÉCÉL.VAZIA(G548);"";"");";");SE(ÉCÉL.VAZIA(G548);"";$G$1); SE(ÉCÉL.VAZIA(G548);SE(ÉCÉL.VAZIA(H548);"";"");";");SE(ÉCÉL.VAZIA(H548);"";$H$1); SE(ÉCÉL.VAZIA(H548);SE(ÉCÉL.VAZIA(I548);"";"");";");SE(ÉCÉL.VAZIA(I548);"";$I$1); SE(ÉCÉL.VAZIA(I548);SE(ÉCÉL.VAZIA(J548);"";"");";");SE(ÉCÉL.VAZIA(J548);"";$J$1); SE(ÉCÉL.VAZIA(J548);SE(ÉCÉL.VAZIA(K548);"";"");";");SE(ÉCÉL.VAZIA(K548);"";$K$1); SE(ÉCÉL.VAZIA(K548);SE(ÉCÉL.VAZIA(L548);"";"");";");SE(ÉCÉL.VAZIA(L548);"";$L$1); SE(ÉCÉL.VAZIA(L548);SE(ÉCÉL.VAZIA(M548);"";"");";");SE(ÉCÉL.VAZIA(M548);"";$M$1); SE(ÉCÉL.VAZIA(M548);SE(ÉCÉL.VAZIA(N548);"";"");";");SE(ÉCÉL.VAZIA(N548);"";$N$1); SE(ÉCÉL.VAZIA(N548);SE(ÉCÉL.VAZIA(O548);"";"");";");SE(ÉCÉL.VAZIA(O548);"";$O$1); SE(ÉCÉL.VAZIA(O548);SE(ÉCÉL.VAZIA(P548);"";"");";");SE(ÉCÉL.VAZIA(P548);"";$P$1); SE(ÉCÉL.VAZIA(P548);SE(ÉCÉL.VAZIA(Q548);"";"");";");SE(ÉCÉL.VAZIA(Q548);"";$Q$1); SE(ÉCÉL.VAZIA(Q548);SE(ÉCÉL.VAZIA(R548);"";"");";");SE(ÉCÉL.VAZIA(R548);"";$R$1); SE(ÉCÉL.VAZIA(R548);SE(ÉCÉL.VAZIA(S548);"";"");";");SE(ÉCÉL.VAZIA(S548);"";$S$1); SE(ÉCÉL.VAZIA(S548);SE(ÉCÉL.VAZIA(T548);"";"");";");SE(ÉCÉL.VAZIA(T548);"";$T$1); SE(ÉCÉL.VAZIA(T548);SE(ÉCÉL.VAZIA(U548);"";"");";");SE(ÉCÉL.VAZIA(U548);"";$U$1); SE(ÉCÉL.VAZIA(U548);SE(ÉCÉL.VAZIA(V548);"";"");";");SE(ÉCÉL.VAZIA(V548);"";$V$1); SE(ÉCÉL.VAZIA(V548);SE(ÉCÉL.VAZIA(W548);"";"");";");SE(ÉCÉL.VAZIA(W548);"";$W$1); SE(ÉCÉL.VAZIA(W548);SE(ÉCÉL.VAZIA(X548);"";"");";");SE(ÉCÉL.VAZIA(X548);"";$X$1); SE(ÉCÉL.VAZIA(X548);SE(ÉCÉL.VAZIA(Y548);"";"");";");SE(ÉCÉL.VAZIA(Y548);"";$Y$1); SE(ÉCÉL.VAZIA(Y548);SE(ÉCÉL.VAZIA(Z548);"";"");";");SE(ÉCÉL.VAZIA(Z548);"";$Z$1); SE(ÉCÉL.VAZIA(Z548);SE(ÉCÉL.VAZIA(AA548);"";"");";");SE(ÉCÉL.VAZIA(AA548);"";$AA$1); SE(ÉCÉL.VAZIA(AA548);SE(ÉCÉL.VAZIA(AB548);"";"");";");SE(ÉCÉL.VAZIA(AB548);"";$AB$1); SE(ÉCÉL.VAZIA(AB548);SE(ÉCÉL.VAZIA(AC548);"";"");";");SE(ÉCÉL.VAZIA(AC548);"";$AC$1); SE(ÉCÉL.VAZIA(AC548);SE(ÉCÉL.VAZIA(AD548);"";"");";");SE(ÉCÉL.VAZIA(AD548);"";$AD$1); SE(ÉCÉL.VAZIA(AD548);SE(ÉCÉL.VAZIA(AE548);"";"");";");SE(ÉCÉL.VAZIA(AE548);"";$AE$1); SE(ÉCÉL.VAZIA(AE548);SE(ÉCÉL.VAZIA(AF548);"";"");";");SE(ÉCÉL.VAZIA(AF548);"";$AF$1); SE(ÉCÉL.VAZIA(AF548);SE(ÉCÉL.VAZIA(AG548);"";"");";");SE(ÉCÉL.VAZIA(AG548);"";$AG$1); SE(ÉCÉL.VAZIA(AG548);SE(ÉCÉL.VAZIA(AH548);"";"");";");SE(ÉCÉL.VAZIA(AH548);"";$AH$1); SE(ÉCÉL.VAZIA(AH548);SE(ÉCÉL.VAZIA(AI548);"";"");";");SE(ÉCÉL.VAZIA(AI548);"";$AI$1); SE(ÉCÉL.VAZIA(AI548);SE(ÉCÉL.VAZIA(AJ548);"";"");";");SE(ÉCÉL.VAZIA(AJ548);"";$AJ$1); SE(ÉCÉL.VAZIA(AJ548);SE(ÉCÉL.VAZIA(AK548);"";"");";");SE(ÉCÉL.VAZIA(AK548);"";$AK$1); SE(ÉCÉL.VAZIA(AK548);SE(ÉCÉL.VAZIA(AL548);"";"");";");SE(ÉCÉL.VAZIA(AL548);"";$AL$1); SE(ÉCÉL.VAZIA(AL548);SE(ÉCÉL.VAZIA(AM548);"";"");";");SE(ÉCÉL.VAZIA(AM548);"";$AM$1); SE(ÉCÉL.VAZIA(AM548);SE(ÉCÉL.VAZIA(AN548);"";"");";");SE(ÉCÉL.VAZIA(AN548);"";$AN$1); SE(ÉCÉL.VAZIA(AN548);SE(ÉCÉL.VAZIA(AO548);"";"");";");SE(ÉCÉL.VAZIA(AO548);"";$AO$1); SE(ÉCÉL.VAZIA(AO548);SE(ÉCÉL.VAZIA(AP548);"";"");";");SE(ÉCÉL.VAZIA(AP548);"";$AP$1); SE(ÉCÉL.VAZIA(AP548);SE(ÉCÉL.VAZIA(AQ548);"";"");";");SE(ÉCÉL.VAZIA(AQ548);"";$AQ$1); SE(ÉCÉL.VAZIA(AQ548);SE(ÉCÉL.VAZIA(AR548);"";"");";");SE(ÉCÉL.VAZIA(AR548);"";$AR$1); SE(ÉCÉL.VAZIA(AR548);SE(ÉCÉL.VAZIA(AS548);"";"");";");SE(ÉCÉL.VAZIA(AS548);"";$AS$1) )
--Formula usada na planilha para remover o ultimo ; =SE(DIREITA(C2;1)=";";EXT.TEXTO(C2;1;NÚM.CARACT(C2)-1);C2)
SELECT DISTINCT E.subID, C.criID, D.CODIGO
FROM A_CRITERIOS C
INNER JOIN A_SUB_CRI D ON (C.CRITERIO = D.CRITERIO)
INNER JOIN A_SUBCRITERIOS E ON (D.SUBCRITERIO = E.SUBCRITERIO)
ORDER BY D.CODIGO, C.criID, E.subID
--
--Popular a tabela com os ID's
DELETE FROM A_SUB_X_CRI;

INSERT INTO A_SUB_X_CRI (subID, criID, CODIGO)
SELECT DISTINCT E.subID, C.criID, D.CODIGO
FROM A_CRITERIOS C
INNER JOIN A_SUB_CRI D ON (C.CRITERIO = D.CRITERIO)
INNER JOIN A_SUBCRITERIOS E ON (D.SUBCRITERIO = E.SUBCRITERIO)
ORDER BY D.CODIGO, C.criID, E.subID;

DELETE FROM A_CRI_X_ART;

INSERT INTO A_CRI_X_ART (criID, CODIGO)
SELECT DISTINCT C.criID, D.CODIGO
FROM A_CRITERIOS C
INNER JOIN A_ART_CRI D ON (C.CRITERIO = D.CRITERIO)
ORDER BY D.CODIGO, C.criID;

SELECT COUNT(*) FROM A_ART_CRI;
SELECT COUNT(*) FROM A_CRI_X_ART;
--###############################################################################
--Validar a quantidade de subcritérios
SELECT A.CODIGO, A.QTDE_SUBCRITERIOS, COUNT(*)
FROM A_SUB_X_CRI C
LEFT JOIN A_ARTIGOS A ON (C.CODIGO = A.CODIGO)
LEFT JOIN A_SUBCRITERIOS B ON (B.subID =C.subID)
GROUP BY A.CODIGO, A.QTDE_SUBCRITERIOS
HAVING COUNT(*) != A.QTDE_SUBCRITERIOS
ORDER BY A.CODIGO

--Validar a quantidade de criterios
SELECT A.CODIGO, A.QTDE_CRITERIOS, COUNT(*)
FROM A_CRI_X_ART C
LEFT JOIN A_ARTIGOS A ON (C.CODIGO = A.CODIGO)
LEFT JOIN A_CRITERIOS B ON (B.criID =C.criID)
GROUP BY A.CODIGO, A.QTDE_CRITERIOS
HAVING COUNT(*) != A.QTDE_CRITERIOS
ORDER BY A.CODIGO

--Artigos, criterios e subcriterios
SELECT A.CODIGO, A.FASE, A.QTDE_CRITERIOS,  A.QTDE_SUBCRITERIOS, C.CRITERIO, E.SUBCRITERIO
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
LEFT JOIN A_SUB_X_CRI D ON (B.criID = D.criID AND A.CODIGO = D.CODIGO)
LEFT JOIN A_SUBCRITERIOS E ON (D.subID = E.subID)
ORDER BY A.CODIGO, A.FASE, A.QTDE_CRITERIOS, A.QTDE_SUBCRITERIOS, C.CRITERIO, E.SUBCRITERIO

--Os 10 criterios mais usados
SELECT C.CRITERIO, count(*) as TOTAL
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
GROUP BY C.CRITERIO
ORDER BY COUNT(*) DESC
LIMIT 10

--Os quinze critérios mais usados na seleção de software
SELECT C.CRITERIO, count(*) as TOTAL
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE A.SELECAO = 'SIM'
GROUP BY C.CRITERIO
ORDER BY COUNT(*) DESC
LIMIT 15

--Os cinco critérios mais usados tanto na revisão bibliográfica quanto na seleção de software
SELECT C.CRITERIO, count(*) as TOTAL
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE C.CRITERIO IN (SELECT C.CRITERIO
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE A.SELECAO = 'SIM'
GROUP BY C.CRITERIO
ORDER BY COUNT(*) DESC
LIMIT 5)
GROUP BY C.CRITERIO
LIMIT 5
--É possível melhorar 
SELECT * FROM (SELECT C.CRITERIO 
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
GROUP BY C.CRITERIO
ORDER BY COUNT(*) DESC
LIMIT 5) as SEM
--
LEFT JOIN 
--
(SELECT C.CRITERIO
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE A.SELECAO = 'SIM'
GROUP BY C.CRITERIO
ORDER BY COUNT(*) DESC
LIMIT 5) as COM
--
ON (SEM.CRITERIO = COM.CRITERIO)
--
--Os critérios a serem usados e os artigos, o ideal é ter uma matriz onde cada artigo seja uma coluna
SELECT C.CRITERIO, GROUP_CONCAT(A.CODIGO)
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE C.CRITERIO IN ('FORNECEDOR', 'SOFTWARE', 'TECNOLOGIA', 'CUSTOS', 'FINANCEIRO')
GROUP BY C.CRITERIO
ORDER BY C.CRITERIO
--OU
SELECT T1.CRITERIO, T1.CODIGO, T2.TOTAL FROM (SELECT C.CRITERIO, A.CODIGO
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE C.CRITERIO IN ('FORNECEDOR', 'SOFTWARE', 'TECNOLOGIA', 'CUSTOS', 'FINANCEIRO')) AS T1
--
INNER JOIN (SELECT C.CRITERIO, COUNT(*) AS TOTAL
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
WHERE C.CRITERIO IN ('FORNECEDOR', 'SOFTWARE', 'TECNOLOGIA', 'CUSTOS', 'FINANCEIRO')
GROUP BY C.CRITERIO) AS T2
--
ON (T1.CRITERIO = T2.CRITERIO)
--
ORDER BY T2.TOTAL DESC

--Critérios e Subcritérios e seus respectivos artigos em matriz
SELECT C.CRITERIO, E.SUBCRITERIO, GROUP_CONCAT(A.CODIGO)
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
LEFT JOIN A_SUB_X_CRI D ON (B.criID = D.criID AND A.CODIGO = D.CODIGO)
LEFT JOIN A_SUBCRITERIOS E ON (D.subID = E.subID)
WHERE C.CRITERIO IN ('FORNECEDOR', 'SOFTWARE', 'TECNOLOGIA', 'CUSTOS', 'FINANCEIRO')
GROUP BY C.CRITERIO, E.SUBCRITERIO
ORDER BY C.CRITERIO, E.SUBCRITERIO
--
--OU --Os cinco Criterios a serem usados e seus subcriterios
SELECT C.CRITERIO, E.SUBCRITERIO, GROUP_CONCAT(A.CODIGO) as CODIGO_ARTIGO, COUNT(*) as QTDE_ARTIGO
FROM A_ARTIGOS A
LEFT JOIN A_CRI_X_ART B ON (A.CODIGO = B.CODIGO)
LEFT JOIN A_CRITERIOS C ON (B.criID = C.criID)
LEFT JOIN A_SUB_X_CRI D ON (B.criID = D.criID AND A.CODIGO = D.CODIGO)
LEFT JOIN A_SUBCRITERIOS E ON (D.subID = E.subID)
WHERE C.CRITERIO IN ('FORNECEDOR', 'SOFTWARE', 'TECNOLOGIA', 'CUSTOS', 'FINANCEIRO')
GROUP BY C.CRITERIO, E.SUBCRITERIO
ORDER BY COUNT(*) DESC
--A quantidade de critérios A14 está errado
--###############################################################################
--Para saber a quantidade de artigos por Assunto Pesquisado e Base usei a seleção abaixo.
SELECT CA.CollectionName, CB.CollectionName, COUNT(*)
		FROM collections CA
		LEFT JOIN collections CB
		        ON (CA.collectionID = CB.parentCollectionID)
		INNER JOIN collectionItems CI 
			ON (CI.collectionID = CB.collectionID)
		INNER JOIN items I 
			ON (CI.itemID = I.itemID)
GROUP BY CA.CollectionName, CB.CollectionName
ORDER BY CA.CollectionName, CB.CollectionName;
--Não pode totalizar os registros pois haverá repetições do mesmo artigo em assuntos diferentes e base diferente.
--O problema das repetições é com collectionItems

--Para comprovar isso basta usar:
SELECT CA.CollectionName,
       IDV.value
  FROM collections CA
       LEFT JOIN collections CB
              ON ( CA.collectionID = CB.parentCollectionID ) 
       INNER JOIN collectionItems CI
               ON ( CI.collectionID = CB.collectionID ) 
       INNER JOIN items I
               ON ( CI.itemID = I.itemID AND I.itemTypeID != 14 --Snapshot
                                         AND I.dateAdded = (SELECT MAX( dateAdded )
                                                              FROM items II
                                                             WHERE II.itemID = I.itemID))
       INNER JOIN itemData ID
               ON ( I.itemID = ID.itemID) 
       INNER JOIN fields F
               ON ( ID.fieldID = F.fieldID AND F.fieldName = 'title' ) 
       INNER JOIN itemDataValues IDV
               ON ( ID.valueID = IDV.valueID)
ORDER BY IDV.value, CA.CollectionName;

--Contra essa seleção
SELECT IDV.value, IDV.*
  FROM itemData ID
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID AND IDV.value != 'Snapshot')   
  ORDER BY IDV.valueID;

--Após o saneamento usar essas estatística
SELECT CA.CollectionName, CB.CollectionName, COUNT(*)
		FROM collections CA
		LEFT JOIN collections CB
		        ON (CA.collectionID = CB.parentCollectionID)
		INNER JOIN collectionItems CI 
			ON (CI.collectionID = CB.collectionID)
		INNER JOIN items I 
			ON (CI.itemID = I.itemID)
where CI.collectionID = (select collectionID from collectionItems i where ci.itemID = i.itemID)				
GROUP BY CA.CollectionName, CA.CollectionName
ORDER BY  COUNT(*), CA.CollectionName, CA.CollectionName; 

SELECT CA.CollectionName, COUNT(*)
		FROM collections CA
		LEFT JOIN collections CB
		        ON (CA.collectionID = CB.parentCollectionID)
		INNER JOIN collectionItems CI 
			ON (CI.collectionID = CB.collectionID)
		INNER JOIN items I 
			ON (CI.itemID = I.itemID)
where CI.collectionID = (select collectionID from collectionItems i where ci.itemID = i.itemID)				
GROUP BY CA.CollectionName
ORDER BY  COUNT(*), CA.CollectionName;                                    
                                                                        
--Nem sempre é bom apresentar esse pois apresenta numeros diferente do anterior																		
SELECT CA.CollectionName, COUNT(*)
		FROM collections CA
		INNER JOIN collectionItems CI 
			ON (CI.collectionID = CA.collectionID)
		INNER JOIN items I 
			ON (CI.itemID = I.itemID)
where CI.collectionID = (select collectionID from collectionItems i where ci.itemID = i.itemID)			
GROUP BY CA.CollectionName
ORDER BY COUNT(*) desc;  

--Por Ano
  SELECT SUBSTR(IDV5.value,1,4) "Ano", count(*)
              FROM itemData ID5 
              INNER JOIN fields F5 
              ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 
              ON (ID5.valueID = IDV5.valueID )
              GROUP BY SUBSTR(IDV5.value,1,4)
              ORDER BY SUBSTR(IDV5.value,1,4) DESC;

--Por Periódico              
SELECT IDV1.value, count(*) 
              FROM itemData ID1 
              INNER JOIN fields F1 
              ON (ID1.fieldID = F1.fieldID AND F1.fieldName = 'publicationTitle')
              INNER JOIN itemDataValues IDV1 
              ON (ID1.valueID = IDV1.valueID )
              GROUP BY IDV1.value
              ORDER BY count(*) DESC;

--Por Periódico Nome Abreviado                            
SELECT IDV2.value, count(*)
              FROM itemData ID2 
              INNER JOIN fields F2 
              ON (ID2.fieldID = F2.fieldID AND F2.fieldName = 'journalAbbreviation')
              INNER JOIN itemDataValues IDV2 
              ON (ID2.valueID = IDV2.valueID )
              GROUP BY IDV2.value
              ORDER BY count(*) DESC;
              
--Quantidade de Autores por Artigo
SELECT CD.firstName || ' ' || CD.lastName, count(I.ITEMID)
FROM items I
LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
WHERE I.ITEMTYPEID = 4
GROUP BY CD.firstName || ' ' || CD.lastName
ORDER BY count(I.ITEMID) DESC;

--Artigos mais antigos:
SELECT IDV.value ||'; ' || SUBSTR(IDVE.value,1,4) || '; ' || CD.firstName || ' ' ||CD.lastName ||'.'
  FROM collections C
  INNER JOIN collectionItems CI ON (C.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
--
  LEFT JOIN (SELECT IDV5.value, ID5.itemID 
              FROM itemData ID5 
              INNER JOIN fields F5 ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 ON (ID5.valueID = IDV5.valueID )) IDVE ON (I.itemID = IDVE.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
    LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
    LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
    INNER JOIN creatorTypes CT ON (CT.creatorTypeID = IC.creatorTypeID AND CT.creatorType = 'author')
    INNER JOIN creators CA ON (CA.creatorDataID = CD.creatorDataID AND CA.creatorID = IC.creatorID)    
WHERE I.itemID in
--artigos mais antigos entre 1999 e 2001
            (SELECT ID5.itemID
              FROM itemData ID5 
              INNER JOIN fields F5 
              ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 
              ON (ID5.valueID = IDV5.valueID )
              WHERE SUBSTR(IDV5.value,1,4) BETWEEN '1999' AND '2001')
      GROUP BY I.itemID
  ORDER BY I.itemID desc;
             
  
--Artigos mais recentes
SELECT IDV.value ||'; ' || SUBSTR(IDVE.value,1,4) || '; ' || CD.firstName || ' ' ||CD.lastName ||'.'
  FROM collections C
  INNER JOIN collectionItems CI ON (C.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
--
  LEFT JOIN (SELECT IDV5.value, ID5.itemID 
              FROM itemData ID5 
              INNER JOIN fields F5 ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 ON (ID5.valueID = IDV5.valueID )) IDVE ON (I.itemID = IDVE.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
    LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
    LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
    INNER JOIN creatorTypes CT ON (CT.creatorTypeID = IC.creatorTypeID AND CT.creatorType = 'author')
    INNER JOIN creators CA ON (CA.creatorDataID = CD.creatorDataID AND CA.creatorID = IC.creatorID)    
WHERE I.itemID in
--artigos mais recentes entre 2013 e 2014
            (SELECT ID5.itemID
              FROM itemData ID5 
              INNER JOIN fields F5 
              ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 
              ON (ID5.valueID = IDV5.valueID )
              WHERE SUBSTR(IDV5.value,1,4) BETWEEN '2013' AND '2014')
      GROUP BY I.itemID
  ORDER BY SUBSTR(IDVE.value,1,4) desc;
                        
--Artigos mais citados
SELECT IDV.value ||'; ' || SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title)) || '; ' || CD.firstName || ' ' ||CD.lastName ||'.',
SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title))*1
  FROM collections C
  INNER JOIN collectionItems CI ON (C.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
    LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
    LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
    INNER JOIN creatorTypes CT ON (CT.creatorTypeID = IC.creatorTypeID AND CT.creatorType = 'author')
    INNER JOIN creators CA ON (CA.creatorDataID = CD.creatorDataID AND CA.creatorID = IC.creatorID)    
    LEFT JOIN itemNotes INC ON (I.itemID = INC.sourceItemID AND INC.title like 'Cited By%') 
  WHERE SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title)) IS NOT NULL
  GROUP BY I.itemID, SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title))
  ORDER BY SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title))*1 desc;

                
SELECT IDVI.value "Direito"
  FROM collections C
  INNER JOIN collectionItems CI ON (C.collectionID = CI.collectionID AND C.collectionName in ('AHP e ERP', 'SCOPUS', 'WOS'))--('AHP and ERP', 'AHP and EAI', 'EAI and ERP'))
  INNER JOIN items I ON (CI.itemID = I.itemID AND I.itemTypeID = 4)  --4 = journalArticle
-- 
  LEFT JOIN (SELECT IDV9.value, ID9.itemID 
              FROM itemData ID9 
              INNER JOIN fields F9 ON (ID9.fieldID = F9.fieldID AND F9.fieldName = 'rights')
              INNER JOIN itemDataValues IDV9 ON (ID9.valueID = IDV9.valueID )) IDVI ON (I.itemID = IDVI.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--

--
--GERAL
SELECT IDV.value "Artigo", 
       C.collectionName "Coleção", 
       IDVA.value "Banco de Artigos", 
       IDVB.value "Periódico",
       IDVC.value "Revista",
       IDVG.value "ArXiv",
       IDVD.value "Linguagem",
       SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title)) "Citações",
       SUBSTR(IDVE.value,1,4) "Ano",
	   GROUP_CONCAT(CD.firstName || ' ' || CD.lastName, '; ') AS AUTORES,
       CA.dateAdded, CA.dateModified,
	   GROUP_CONCAT(T.name, '; ') AS PALAVRAS_CHAVE,
       IDVF.value "Resumo"       
  FROM collections C
  INNER JOIN collectionItems CI ON (C.collectionID = CI.collectionID)
  INNER JOIN items I ON (CI.itemID = I.itemID AND I.itemTypeID = 4)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
--
  LEFT JOIN (SELECT IDV1.value, ID1.itemID 
              FROM itemData ID1 
              INNER JOIN fields F1 ON (ID1.fieldID = F1.fieldID AND F1.fieldName = 'libraryCatalog')
              INNER JOIN itemDataValues IDV1 ON (ID1.valueID = IDV1.valueID )) IDVA ON (I.itemID = IDVA.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
-- 
  LEFT JOIN (SELECT IDV2.value, ID2.itemID 
              FROM itemData ID2 
              INNER JOIN fields F2 ON (ID2.fieldID = F2.fieldID AND F2.fieldName = 'journalAbbreviation')
              INNER JOIN itemDataValues IDV2 ON (ID2.valueID = IDV2.valueID )) IDVB ON (I.itemID = IDVB.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
  LEFT JOIN (SELECT IDV3.value, ID3.itemID 
              FROM itemData ID3 
              INNER JOIN fields F3 ON (ID3.fieldID = F3.fieldID AND F3.fieldName = 'publicationTitle')
              INNER JOIN itemDataValues IDV3 ON (ID3.valueID = IDV3.valueID )) IDVC ON (I.itemID = IDVC.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
  LEFT JOIN (SELECT IDV4.value, ID4.itemID 
              FROM itemData ID4 
              INNER JOIN fields F4 ON (ID4.fieldID = F4.fieldID AND F4.fieldName = 'language')
              INNER JOIN itemDataValues IDV4 ON (ID4.valueID = IDV4.valueID )) IDVD ON (I.itemID = IDVD.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
  LEFT JOIN (SELECT IDV5.value, ID5.itemID 
              FROM itemData ID5 
              INNER JOIN fields F5 ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 ON (ID5.valueID = IDV5.valueID )) IDVE ON (I.itemID = IDVE.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
  LEFT JOIN (SELECT IDV6.value, ID6.itemID 
              FROM itemData ID6 
              INNER JOIN fields F6 ON (ID6.fieldID = F6.fieldID AND F6.fieldName = 'abstractNote')
              INNER JOIN itemDataValues IDV6 ON (ID6.valueID = IDV6.valueID )) IDVF ON (I.itemID = IDVF.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
  LEFT JOIN (SELECT IDV7.value, ID7.itemID 
              FROM itemData ID7 
              INNER JOIN fields F7 ON (ID7.fieldID = F7.fieldID AND F7.fieldName = 'DOI')
              INNER JOIN itemDataValues IDV7 ON (ID7.valueID = IDV7.valueID )) IDVG ON (I.itemID = IDVG.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
    LEFT JOIN itemNotes INA ON (I.itemID = INA.sourceItemID AND INA.title like 'Source:%')
    LEFT JOIN itemNotes INB ON (I.itemID = INB.sourceItemID AND INB.title like 'Language of Original Document:%')
    LEFT JOIN itemNotes INC ON (I.itemID = INC.sourceItemID AND INC.title like 'Cited By%')    
--Era pra aparecer mais repetições de linhas devido a possibilidade de ter mais de um autor por artigo, mas diminuiu
    LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
    LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
	LEFT JOIN itemTags IT ON (I.itemID = IT.itemID)
	LEFT JOIN Tags T ON (IT.tagID = T.tagID)
    INNER JOIN creatorTypes CT ON (CT.creatorTypeID = IC.creatorTypeID AND CT.creatorType = 'author')
    INNER JOIN creators CA ON (CA.creatorDataID = CD.creatorDataID AND CA.creatorID = IC.creatorID)    	
   --WHERE IDV.value like 'ERP Software Selection%'
  GROUP BY IDV.value
  ORDER BY IDV.value desc;
  
--CAMPOS AUTORES, IDIOMA, DIFERENTE E FALTANDO TAGS  
SELECT IDV.value "Artigo", 
       C.collectionName "Coleção", 
       CASE INA.title 
        WHEN 'Source: Scopus' 
        THEN 'Scopus' END "Base dos Artigos",
       CASE WHEN ((INA.title IS NOT NULL) AND (IDVA.value IS NOT NULL))
               THEN CASE INA.title 
        WHEN 'Source: Scopus' 
        THEN 'Scopus' END || ' - ' || IDVA.value
            WHEN ((INA.title IS NULL) AND (IDVA.value IS NOT NULL))
               THEN IDVA.value
            WHEN ((INA.title IS NOT NULL) AND (IDVA.value IS NULL))
               THEN CASE INA.title 
        WHEN 'Source: Scopus' 
        THEN 'Scopus' END
       ELSE NULL END "A",
       IDVA.value "Banco de Artigos", 
       IDVB.value "Periódico",
       IDVC.value "Revista",
       IDVG.value "ArXiv",
       IDVD.value "Linguagem",
       LTRIM(REPLACE(INB.title, 'Language of Original Document:', ' ')) "Idioma",
       SUBSTR(INC.title,(INSTR (INC.title, ':') + 1), LENGTH (INC.title)) "Citações",
       SUBSTR(IDVE.value,1,4) "Ano",
       CD.firstName, CD.lastName, CA.dateAdded, CA.dateModified,
       IDVF.value "Resumo"       
  FROM collections C
  INNER JOIN collectionItems CI ON (C.collectionID = CI.collectionID AND C.collectionName in ('AHP e ERP', 'SCOPUS', 'WOS'))--('AHP and ERP', 'AHP and EAI', 'EAI and ERP'))
  INNER JOIN items I ON (CI.itemID = I.itemID AND I.itemTypeID = 4)  --4 = journalArticle
  INNER JOIN itemData ID ON (I.itemID = ID.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
  INNER JOIN fields F ON (ID.fieldID = F.fieldID AND F.fieldName = 'title')
  INNER JOIN itemDataValues IDV ON (ID.valueID = IDV.valueID)
--
  LEFT JOIN (SELECT IDV1.value, ID1.itemID 
              FROM itemData ID1 
              INNER JOIN fields F1 ON (ID1.fieldID = F1.fieldID AND F1.fieldName = 'libraryCatalog')
              INNER JOIN itemDataValues IDV1 ON (ID1.valueID = IDV1.valueID )) IDVA ON (I.itemID = IDVA.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
-- 
  LEFT JOIN (SELECT IDV2.value, ID2.itemID 
              FROM itemData ID2 
              INNER JOIN fields F2 ON (ID2.fieldID = F2.fieldID AND F2.fieldName = 'journalAbbreviation')
              INNER JOIN itemDataValues IDV2 ON (ID2.valueID = IDV2.valueID )) IDVB ON (I.itemID = IDVB.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
  LEFT JOIN (SELECT IDV3.value, ID3.itemID 
              FROM itemData ID3 
              INNER JOIN fields F3 ON (ID3.fieldID = F3.fieldID AND F3.fieldName = 'publicationTitle')
              INNER JOIN itemDataValues IDV3 ON (ID3.valueID = IDV3.valueID )) IDVC ON (I.itemID = IDVC.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
  LEFT JOIN (SELECT IDV4.value, ID4.itemID 
              FROM itemData ID4 
              INNER JOIN fields F4 ON (ID4.fieldID = F4.fieldID AND F4.fieldName = 'language')
              INNER JOIN itemDataValues IDV4 ON (ID4.valueID = IDV4.valueID )) IDVD ON (I.itemID = IDVD.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
  LEFT JOIN (SELECT IDV5.value, ID5.itemID 
              FROM itemData ID5 
              INNER JOIN fields F5 ON (ID5.fieldID = F5.fieldID AND F5.fieldName = 'date')
              INNER JOIN itemDataValues IDV5 ON (ID5.valueID = IDV5.valueID )) IDVE ON (I.itemID = IDVE.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
 
--
  LEFT JOIN (SELECT IDV6.value, ID6.itemID 
              FROM itemData ID6 
              INNER JOIN fields F6 ON (ID6.fieldID = F6.fieldID AND F6.fieldName = 'abstractNote')
              INNER JOIN itemDataValues IDV6 ON (ID6.valueID = IDV6.valueID )) IDVF ON (I.itemID = IDVF.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
  LEFT JOIN (SELECT IDV7.value, ID7.itemID 
              FROM itemData ID7 
              INNER JOIN fields F7 ON (ID7.fieldID = F7.fieldID AND F7.fieldName = 'DOI')
              INNER JOIN itemDataValues IDV7 ON (ID7.valueID = IDV7.valueID )) IDVG ON (I.itemID = IDVG.itemID AND I.dateAdded = (SELECT MAX(dateAdded) FROM items II WHERE II.itemID = I.itemID))
--
    LEFT JOIN itemNotes INA ON (I.itemID = INA.sourceItemID AND INA.title like 'Source:%')
    LEFT JOIN itemNotes INB ON (I.itemID = INB.sourceItemID AND INB.title like 'Language of Original Document:%')
    LEFT JOIN itemNotes INC ON (I.itemID = INC.sourceItemID AND INC.title like 'Cited By%')    
--Era pra aparecer mais repetições de linhas devido a possibilidade de ter mais de um autor por artigo, mas diminuiu
    LEFT JOIN itemCreators IC ON (I.itemID = IC.itemID)
    LEFT JOIN creatorData CD ON (CD.creatorDataID = IC.creatorID)
    INNER JOIN creatorTypes CT ON (CT.creatorTypeID = IC.creatorTypeID AND CT.creatorType = 'author')
    INNER JOIN creators CA ON (CA.creatorDataID = CD.creatorDataID AND CA.creatorID = IC.creatorID)    
   --WHERE IDV.value like 'ERP Software Selection%'
  GROUP BY IDV.value
  ORDER BY IDV.value desc;

 