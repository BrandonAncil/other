SELECT *
FROM ushouseholdincome;

SELECT *
FROM ushouseholdincome_statistics;

SELECT id, COUNT(id)
FROM ushouseholdincome
GROUP BY id
HAVING COUNT(id) > 1;

DELETE FROM ushouseholdincome
WHERE row_id IN (
    SELECT row_id
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS running_count
        FROM ushouseholdincome) AS new_table
    WHERE running_count > 1
);

SELECT state_name, COUNT(state_name)
FROM ushouseholdincome
GROUP BY state_name
ORDER BY state_name;

UPDATE ushouseholdincome
SET state_name = 'Alabama'
WHERE state_name = 'alabama';

UPDATE ushouseholdincome
SET state_name = 'Georgia'
WHERE state_name = 'georia';

SELECT *
FROM ushouseholdincome
WHERE place IS NULL;

UPDATE ushouseholdincome
SET place = 'Autaugaville'
WHERE city = 'Vinemont'
    AND county = 'Autauga County';

SELECT type, COUNT(type)
FROM ushouseholdincome
GROUP BY type
ORDER BY type;

UPDATE ushouseholdincome
SET type = 'Village'
WHERE type = 'village';

UPDATE ushouseholdincome
SET type = 'Borough'
WHERE type = 'Boroughs';

SELECT aland, awater
FROM ushouseholdincome
WHERE aland = 0
    AND awater = 0;

SELECT state_name, SUM(aland), SUM(awater)
FROM ushouseholdincome
GROUP BY state_name;

SELECT *
FROM ushouseholdincome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
WHERE mean != 0;

SELECT u.state_name, ROUND(AVG(mean),1), ROUND(AVG(median),1)
FROM ushouseholdincome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
WHERE mean != 0
GROUP BY u.state_name
ORDER BY 2 DESC;

SELECT type, COUNT(type), ROUND(AVG(mean), 1), ROUND(AVG(median), 1)
FROM ushouseholdincome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
WHERE mean != 0
GROUP BY type
HAVING COUNT(type) > 100
ORDER BY 3 DESC;

SELECT *
FROM ushouseholdincome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
WHERE mean != 0
    AND type = 'Community';

SELECT u.state_name, city, ROUND(AVG(mean), 1)
FROM ushouseholdincome u
JOIN ushouseholdincome_statistics us
ON u.id = us.id
GROUP BY u.state_name, city
ORDER BY 3 DESC;