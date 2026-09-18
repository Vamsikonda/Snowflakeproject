Use role sysadmin;
use warehouse compute_WH;

------ We need to create database named Cricket and create schema for anlaysis purpose we should be required to create 4 schemas as we need to analyze the data in four different schemas
--landing layer ,Raw Layer, clean Layer ,consumpation Layer --

--- let's create the database and schemas --- 

CREATE DATABASE if not exists cricket
CREATE or REPLACE SCHEMA cricket.land;
CREATE or REPLACE SCHEMA cricket.raw;
CREATE or REPLACE SCHEMA cricket.clean;
CREATE or REPLACE SCHEMA cricket.consumpation;

---- if we want to see the schemas created by use we use this command --------- 

Show SCHEMAS;

--First step : We need to uplaod the files in landing zone for that need to create the fileformat.
---The source file that we have is in Json format. so we need to create the Json file. 

use schema land

--- This creates or replaces a Snowflake file format named my_json_format for JSON files. TYPE = JSON tells Snowflake that the source data is JSON. NULL_IF specifies values that should be interpreted as NULL. STRIP_OUTER_ARRAY = TRUE is used when the JSON document is wrapped in an outer array; it removes that outer array and allows each JSON object inside the array to be treated as an individual record. The COMMENT is just documentation for the file format.

CREATE or replace file format my_json_format
type =json
null_if = ('\\n', 'null', '')
strip_outer_array = true
comment = 'Json File Format with outer stip array flag true';
CREATE OR REPLACE FILE FORMAT my_json_format
TYPE = JSON
STRIP_OUTER_ARRAY = TRUE;

-- Need to create the stage -- 

create or replace stage my_stg

REMOVE @my_stg/cricket/json/;

list @my_stg 
--need to check the data from the json file -

-- Step 1 : 
select $1,$2,$3 from  @my_stg 

-- Step2 : The thing is here the json data is form of meta data, info, innnigns in different nodes. so we need to represent 
SELECT 
    $1:meta AS meta,
    $1:info AS info,
    $1:innings AS innings,
    METADATA$FILENAME AS file_name,
    METADATA$FILE_ROW_NUMBER AS file_row_number,
    METADATA$FILE_CONTENT_KEY AS file_content_key,
    METADATA$FILE_LAST_MODIFIED AS stg_modified_ts
FROM @my_stg/cricket/json/1384401.json.gz
(FILE_FORMAT => 'my_json_format');


--Actually the size of snowflake sight should be in 250 MB. if the files more than that, the stage won't support or unable to process. so we will use Snowsql to upload all the files---







