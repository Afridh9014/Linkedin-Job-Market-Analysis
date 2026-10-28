USE Linkedin
SELECT * FROM Linkedin_jobs;
       --CHECKING NULL VALUES
            SELECT COUNT(*) FROM Linkedin_jobs
            WHERE 
	        title IS NULL OR id IS NULL;
            SELECT COUNT(*) FROM Linkedin_jobs
            WHERE 
	        sector IS NULL OR publishedAt IS NULL;



-----------------------------------------------------------------------------------------------------------------------


----------------------------------BASIC UNDERSTANDING QUESTIONS -------------------------------------
--Job Role & Experience Level Analysis--
-- 1.Talent competition --
--How competitive is the market per role, and which companies attract the highest applicant volumes?--
   SELECT title,
          companyName,
          SUM(applicationsCount) AS total_applications FROM Linkedin_jobs
       GROUP BY title,companyName   
       ORDER BY total_applications DESC;

--2.What experience levels are most in demand?--
      SELECT experienceLevel,
             COUNT(*) AS total_jobs 
      FROM Linkedin_jobs
     GROUP BY experienceLevel
     ORDER BY total_jobs DESC;




--3.Which experience level faces the highest competition?--
     SELECT experienceLevel,
            SUM(applicationsCount) AS Competition
     FROM Linkedin_jobs
     GROUP BY experienceLevel
     ORDER BY Competition DESC;



--4.Which months see the highest hiring activity?--
    SELECT MONTH(publishedAt) as month ,
           COUNT(*) total_jobs 
    FROM Linkedin_jobs  
    GROUP BY MONTH(publishedAt)
    ORDER BY total_jobs DESC;


--5.Which roles attract the most applicants per posting?--
--Identify high-competition roles where supply of candidates outpaces demand--  
   SELECT title,
          SUM(applicationsCount) AS total_applications 
   FROM Linkedin_jobs
   GROUP BY title   
   ORDER BY total_applications DESC;

--6.Which sectors are posting the most jobs?--
--Understand where hiring demand is concentrated across industries--
    SELECT sector,
               COUNT(*) as total_jobs,
               SUM(applicationsCount) as total_applications
        FROM Linkedin_jobs
        WHERE sector IS NOT NULL
        GROUP BY sector
        ORDER BY total_jobs DESC;
-----------------------------------------------------------------------------------------------------------------------
--Advanced Business Analytics--
--1.Rank companies by hiring pace using DENSE_RANK — who leads?--
      SELECT title,
             COUNT(*) AS total_jobs,
             DENSE_RANK() OVER( ORDER BY COUNT(*) DESC) RANK
      FROM Linkedin_jobs
     GROUP BY title
     ORDER BY total_jobs DESC ;
----------------------------------------------------------------------------------------------------------------------

--2.Which jobs are significantly more competitive than average?--
     WITH avgcompetition as( 
                               SELECT title,
                               AVG(applicationsCount) as avg_applicationssCount
                               from Linkedin_jobs 
                               GROUP BY title
                               )
     SELECT L.title,
            L.applicationsCount,A.avg_applicationssCount
    FROM Linkedin_jobs L join avgcompetition A on L.title=A.title
     WHERE L.applicationsCount>A.avg_applicationssCount
     ORDER BY L.applicationsCount DESC;
----------------------------------------------------------------------------------------------------------------------
--3.Demand patterns--

--Which sectors, cities, and roles are seeing surges or declines in job postings over time?--
  WITH postingOvertime as(
  SELECT sector,
         city,
         title,
         YEAR(publishedAt) AS  year,
         MONTH(publishedAt) as month,
         COUNT(*) number_of_jobs
  FROM Linkedin_jobs
  GROUP BY sector,city,title,YEAR(publishedAt), MONTH(publishedAt) 
),
prevJobcount as(
    SELECT sector,
         city,
         title,
         year,
         month,
         number_of_jobs,
         LAG(number_of_jobs) OVER( ORDER BY  year asc,month asc) AS Prevnumber_of_jobs
  FROM postingOvertime
  GROUP BY sector,city,title,year,month,number_of_jobs
  )
  SELECT sector,
         city,
         title,
         year,
         month,
         number_of_jobs,
         Prevnumber_of_jobs,
         ROUND((number_of_jobs-Prevnumber_of_jobs)*100/Prevnumber_of_jobs,2)AS growth_percentage,
         CASE WHEN number_of_jobs>Prevnumber_of_jobs THEN 'Serge'
              WHEN number_of_jobs<Prevnumber_of_jobs THEN 'Declain'
              ELSE 'Standard' end as status
FROM prevJobcount;
 
 
--------------------------------------------------------------------------------------------------------------
--4.Experience gaps--
--Are employers disproportionately seeking senior talent, and where are entry-level opportunities growing?--
   WITH entryLevel AS(
   SELECT title,
          SUM(CASE WHEN experienceLevel='Entry level' THEN 1 ELSE 0 END) AS entry_level,
          COUNT(applicationsCount) seekers
        FROM Linkedin_jobs
        GROUP BY title
        
),
seniorlevel as(
               SELECT title,
               SUM(CASE WHEN experienceLevel LIKE '%Senior%' THEN 1 ELSE 0 END) AS senior_talent,
               COUNT(applicationsCount) seekersOf_seniorRole
               FROM Linkedin_jobs
               GROUP BY title
               
)
SELECT E.title,S.senior_talent,S.seekersOf_seniorRole,E.entry_level,seekers
FROM entryLevel E JOIN seniorlevel s ON E.title=S.title
WHERE S.senior_talent <>0  AND E.entry_level <>0
ORDER BY S.senior_talent DESC,E.entry_level DESC;

-------------another one------------------------------------------------------------------------------------------
SELECT sector,
       SUM(CASE WHEN experienceLevel IN ('Director','Executive','Mid-Senior level') THEN 1 ELSE 0 END) AS senior_roles, 
       SUM(CASE WHEN experienceLevel IN ('Entry level','Internship') THEN 1 ELSE 0 END) AS entry_roles,  
       ROUND(SUM(CASE WHEN experienceLevel IN ('Director','Executive','Mid-Senior level')THEN 1.0 ELSE 0 END) 
       /NULLIF(SUM(CASE WHEN experienceLevel IN ('Entry level','Internship')THEN 1 ELSE 0 END),0), 2) AS senior_to_entry_ratio 
FROM Linkedin_jobs
GROUP BY sector 
ORDER BY senior_to_entry_ratio DESC;



--------------------------------------------------------------------------------------------------------------
--5.Which companies have nationwide hiring presence?--
    SELECT TOP 15 companyName,
                  COUNT(DISTINCT city)AS cities_present,
                  COUNT(DISTINCT state)AS states_present,
                  COUNT(*)AS total_jobs
    FROM linkedin_jobs
    WHERE companyName IS NOT NULL
    GROUP BY companyName
    HAVING COUNT(DISTINCT state) > 2
    ORDER BY states_present DESC, cities_present DESC;
--------------------------------------------------------------------------------------------------------------
--6.Which cities and states have the highest job activity?--

--Identify geographic hotspots for talent demand--
SELECT TOP 15 city,
              state,
              count(id) total_jobs,
              SUM(applicationsCount) totalapplications 
FROM Linkedin_jobs
GROUP BY city,state
ORDER BY total_jobs DESC   ;
--------------------------------------------------------------------------------------------------------------

-- Work Type & Contract Insights--
--7.Full-time vs contract vs part-time — what does the market prefer?--
     SELECT 
        CASE WHEN contractType='Full-time' then contractType
              WHEN contractType='contract' then contractType
              WHEN contractType='Part-time' then contractType END as contract,
        COUNT(*) market_prefer
      FROM Linkedin_jobs
      WHERE contractType NOT IN('Internship','Temporary','Other')
      GROUP BY  CASE WHEN contractType='Full-time' then contractType
                 WHEN contractType='contract' then contractType
                 WHEN contractType='Part-time' then contractType END;
-----------------------------------------------------------------------------------------------------------------------

--8.Which sectors need senior talent vs. entry-level?--
        SELECT sector,
               SUM(CASE WHEN experienceLevel  LIKE '%Senior%' THEN 1 ELSE 0 END) AS senior_talent,
               SUM(CASE WHEN experienceLevel='Entry level' THEN 1 ELSE 0 END) AS entry_level      
        FROM Linkedin_jobs
        GROUP BY sector
        ORDER BY senior_talent DESC,entry_level DESC  ;     

 --------------------------------------------------------------------------------------------------------------
 --9.Which companies are the most active hirers?--
--Benchmark employer hiring velocity and applicant attraction--
   SELECT companyName,
             COUNT(*) AS total_jobs,
             SUM(applicationsCount) total_applications
      FROM Linkedin_jobs
     GROUP BY companyName
     HAVING COUNT(*) >=10
     ORDER BY total_jobs DESC ;

--------------------------------------------------------------------------------------------------------------
--10.What is the monthly trend in job postings?--

--Track hiring momentum over time to forecast future demand--
   SELECT companyName,
          YEAR(publishedAt) AS year,
          MONTH(publishedAt) month,
          COUNT(*) total_jobs,
          SUM(applicationsCount) AS job_seakers
    FROM Linkedin_jobs
    GROUP BY companyName,YEAR(publishedAt),MONTH(publishedAt)
    ORDER BY year asc ,month ASC;
          

--------------------------------------------------------------------------------------------------------------

  
  