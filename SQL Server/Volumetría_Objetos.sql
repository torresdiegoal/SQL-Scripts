/*
#########################################################################################
### SCRIPT QUE GENERA UN RESUMEN DE LOS METADATOS DE TODAS LAS TABLAS DE UN DATABASE  ##
########################################################################################

-- Para que funcione, se le aplica directamente la query sobre el nombre de la base de datos:
-- Click derecho sobre el Database -> New Query

select *
from sys.tables

--where name = 'BI_VW_Fechas_simples'
*/
--USE BD_CLINICOS_BI;

--update #tables_views


--select * from INFORMATION_SCHEMA.TABLES

if OBJECT_ID('tempdb..#tables_views') IS NOT NULL
	begin
		drop table #tables_views
	end


select 
  object_id,
  name,
  type_desc,
  create_date,
  modify_date,
  max_column_id_used

into #tables_views
from sys.tables

union all


select  
  object_id,
  name,
  type_desc,
  CAST(create_date As date) create_date,
  CAST(modify_date As date) modify_date
from sys.views

--select * from #tables_views


SELECT
  t.object_id,
  OBJECT_NAME(t.object_id) ObjectName,
  --sum(u.total_pages) * 8 Total_Reserved_kb,
  t.type_desc,
  max(p.rows) RowsCount,
  t.max_column_id_used ColumnsCount,
  sum(u.used_pages) * 8 Used_Space_kb,
  --t.create_date,
  --GETDATE(create_date) Create_date
  CAST(t.create_date As date) create_date,
  --t.modify_date
  CAST(t.modify_date As date) modify_date
--INTO #SISTEMA
FROM
  #tables_views t 
  LEFT JOIN sys.partitions p 
    on t.object_id = p.object_id 
  LEFT JOIN sys.allocation_units u
    on p.hobt_id = u.container_id 
WHERE
  u.type_desc = 'IN_ROW_DATA'
GROUP BY
  t.object_id,
  OBJECT_NAME(t.object_id),
  t.type_desc,
  t.max_column_id_used,
  t.create_date,
  t.modify_date
ORDER BY
  --Used_Space_kb desc,
  ObjectName;

 --
 /*
--Generar estadísticas para ver última actualización de datos 
SELECT name AS stats_name,   
    STATS_DATE(object_id, stats_id) AS statistics_update_date  
FROM sys.stats   
--WHERE 
	--object_id = OBJECT_ID('dbo.dimPatients')
	--type_desc = 'IN_ROW_DATA'
order by statistics_update_date desc; 
 */