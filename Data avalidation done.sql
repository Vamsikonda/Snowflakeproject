-- Validate the data set--- 
---india vs England (2023-oct-29)--- 

select *
from 
cricket.clean.match_detail_clean
where match_type_number='4686'

---- by batsmen-- 
select 
country,
Batter,
sum(runs)
from
delivery_clean_tbl 
where match_type_number='4686'
group by country,Batter
order by 1,2,3 desc

----- by country ---------------

select 
V.VENUE,
V.MATCH_TYPE,
V.FIRST_TEAM,
V.SECOND_TEAM,
Sum(runs)+Sum(EXTRAS)
from
delivery_clean_tbl D Join 
MATCH_DETAIL_CLEAN V on D.match_type_number= V.match_type_number
where V.match_type_number='4686' 
group by 
V.VENUE,
V.MATCH_TYPE,
V.FIRST_TEAM,
V.SECOND_TEAM

