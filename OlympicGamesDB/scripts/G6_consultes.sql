-- QUERY 1: Quins atletes han obtingut més medalles en total en el conjunt dels Jocs Olímpics?
SELECT p.code, p.name, COUNT(m.id_medal) AS total_medalles
FROM MEDAL m
JOIN ATHLETE a ON a.code_athlete = m.code_athlete
JOIN PERSON p ON p.code = a.code_athlete
GROUP BY p.code, p.name
ORDER BY total_medalles DESC;
-- VALIDACIÓ: Confirma que l'atleta 1945125 (ZHANG Yufei) té 6 medalles registrades
SELECT medal_type, event, team
FROM MEDALLISTS
WHERE code_athlete = '1945125';

-- QUERY 2: Quins equips han guanyat almenys una medalla d’or en qualsevol disciplina?
SELECT DISTINCT t.code_team, t.team
FROM MEDAL m
JOIN TEAM t ON t.code_team = m.code_team
WHERE UPPER(m.medal_type) = 'GOLD MEDAL';
-- VALIDACIÓ: Confirma que l'equip ATHX42KWALKTESP02 ha obtingut medalla d’or
SELECT medal_type, name, team
FROM MEDALLISTS
WHERE code_team = 'ATHX42KWALKTESP02'
AND UPPER(medal_type) = 'GOLD MEDAL';

-- QUERY 3: Quins events del sport Athletics han atorgat més medalles en total?
SELECT e.event_code, e.name, COUNT(m.id_medal) AS total_medalles
FROM MEDAL m
JOIN EVENT e ON e.event_code = m.event_code
JOIN DISCIPLINE d ON d.discipline_code = e.discipline_code
JOIN SPORT s ON s.sport_code = d.sport_code
WHERE UPPER(s.sport) = 'ATHLETICS'
GROUP BY e.event_code, e.name
ORDER BY total_medalles DESC;
-- VALIDACIÓ: Confirma que Women's 4 x 400m Relay té 23 medalles registrades
SELECT medal_type, name, country, team
FROM MEDALLISTS
WHERE UPPER(discipline) = 'ATHLETICS'
AND UPPER(event) = 'WOMEN''S 4 X 400M RELAY';

-- QUERY 4: Quines disciplines del sport que continguin Cycling han atorgat més medalles?
SELECT d.discipline_code, d.discipline, COUNT(m.id_medal) AS total_medalles
FROM MEDAL m
JOIN EVENT e ON e.event_code = m.event_code
JOIN DISCIPLINE d ON d.discipline_code = e.discipline_code
JOIN SPORT s ON s.sport_code = d.sport_code
WHERE UPPER(s.sport) LIKE '%CYCLING%'
GROUP BY d.discipline_code, d.discipline
ORDER BY total_medalles DESC;
-- VALIDACIÓ: Confirma que Cycling Mountain Bike té 6 medalles registrades
SELECT medal_type, name, country, discipline
FROM MEDALLISTS
WHERE UPPER(discipline) = 'CYCLING MOUNTAIN BIKE';

-- QUERY 5: Quin sport acumula més medalles en proves de tipus individual?
SELECT s.sport, COUNT(m.id_medal) AS total_medalles_individuals
FROM MEDAL m
JOIN EVENT e ON m.event_code = e.event_code
JOIN DISCIPLINE d ON e.discipline_code = d.discipline_code
JOIN SPORT s ON d.sport_code = s.sport_code
WHERE m.code_team IS NULL
GROUP BY s.sport
ORDER BY total_medalles_individuals DESC;
-- VALIDACIÓ: Confirma que Athletics té 127 medalles individuals
SELECT medal_type, name, country, event
FROM MEDALLISTS
WHERE UPPER(discipline) = 'ATHLETICS'
AND UPPER(event_type) IN ('ATH', 'HATH');

-- QUERY 6: Quins atletes han guanyat medalles en més d’una disciplina diferent?
SELECT p.code, p.name, COUNT(DISTINCT d.discipline_code) AS total_disciplines
FROM MEDAL m
JOIN ATHLETE a ON a.code_athlete = m.code_athlete
JOIN PERSON p ON p.code = a.code_athlete
JOIN EVENT e ON e.event_code = m.event_code
JOIN DISCIPLINE d ON d.discipline_code = e.discipline_code
GROUP BY p.code, p.name
HAVING COUNT(DISTINCT d.discipline_code) > 1
ORDER BY total_disciplines DESC;
-- VALIDACIÓ: Confirma que FAULKNER Kristen té medalles en dues disciplines diferents
SELECT DISTINCT name, discipline
FROM MEDALLISTS
WHERE UPPER(name) = 'FAULKNER KRISTEN';

-- QUERY 7: Quins atletes han guanyat almenys una medalla en events individuals i en events col·lectius?
SELECT p.code, p.name
FROM MEDAL m
JOIN ATHLETE a ON a.code_athlete = m.code_athlete
JOIN PERSON p ON p.code = a.code_athlete
GROUP BY p.code, p.name
HAVING SUM(CASE WHEN m.code_team IS NULL THEN 1 ELSE 0 END) > 0
AND SUM(CASE WHEN m.code_team IS NOT NULL THEN 1 ELSE 0 END) > 0
ORDER BY p.name;
-- VALIDACIÓ: Confirma que CAREY Jade té medalles individuals i col·lectives
SELECT medal_type, event, team
FROM MEDALLISTS
WHERE UPPER(name) = 'CAREY JADE';

-- QUERY 8: Quins atletes parlen més idiomes diferents?
SELECT p.code, p.name, COUNT(pa.language_code) AS total_idiomes
FROM ATHLETE a
JOIN PERSON p ON p.code = a.code_athlete
JOIN PARLA pa ON pa.code_athlete = a.code_athlete
GROUP BY p.code, p.name
ORDER BY total_idiomes DESC;
-- VALIDACIÓ: Confirma que ZABELINSKAYA Olga parla 8 idiomes
SELECT code, name, lang
FROM ATHLETES
WHERE code = 1545200;

-- QUERY 9: Quins atletes han participat en més events diferents del sport Athletics?
SELECT p.code, p.name, COUNT(DISTINCT pa.event_code) AS total_events
FROM PARTICIPA_ATHLETE pa
JOIN EVENT e ON e.event_code = pa.event_code
JOIN DISCIPLINE d ON d.discipline_code = e.discipline_code
JOIN SPORT s ON s.sport_code = d.sport_code
JOIN ATHLETE a ON a.code_athlete = pa.code_athlete
JOIN PERSON p ON p.code = a.code_athlete
WHERE UPPER(s.sport) = 'ATHLETICS'
GROUP BY p.code, p.name
ORDER BY total_events DESC;
-- VALIDACIÓ: Confirma que TA LOU-SMITH Marie-Josee participa en 3 events
SELECT code, name, events
FROM ATHLETES
WHERE code = 1951507;

-- QUERY 10: Quins venues han acollit més events diferents dels Jocs Olímpics?
SELECT v.venue_code, v.venue, COUNT(DISTINCT sc.event_code) AS total_events
FROM SCHEDULE sc
JOIN VENUE v ON v.venue_code = sc.venue_code
GROUP BY v.venue_code, v.venue
ORDER BY total_events DESC;
-- VALIDACIÓ: Confirma que el venue STA té 45 events diferents
SELECT DISTINCT event
FROM SCHEDULES
WHERE venue_code = 'STA';

-- QUERY 11: Quins atletes han participat en events però no han obtingut cap medalla?
SELECT DISTINCT a.code_athlete, p.name
FROM ATHLETE a
JOIN PERSON p ON a.code_athlete = p.code
JOIN PARTICIPA_ATHLETE pa ON a.code_athlete = pa.code_athlete
LEFT JOIN MEDAL m ON a.code_athlete = m.code_athlete
WHERE m.id_medal IS NULL;
-- VALIDACIÓ: Confirma que l'atleta 1541568 (CHIRILA Catalin) participa en algun event però no té cap medalla
SELECT pa.event_code, m.id_medal
FROM PARTICIPA_ATHLETE pa
LEFT JOIN MEDAL m ON pa.code_athlete = m.code_athlete
WHERE pa.code_athlete = 1541568;

-- QUERY 12: Quins equips han participat en events però no han obtingut cap medalla?
SELECT DISTINCT t.code_team, t.team
FROM TEAM t
JOIN PARTICIPA_TEAM pt ON t.code_team = pt.code_team
LEFT JOIN MEDAL m ON t.code_team = m.code_team
WHERE m.id_medal IS NULL;
--VALIDACIÓ: Confirma que l'equip ROWMNOCOX2--GER01 participa en algun event però no té cap medalla
SELECT pt.event_code, m.id_medal
FROM PARTICIPA_TEAM pt
LEFT JOIN MEDAL m ON pt.code_team = m.code_team
WHERE pt.code_team = 'ROWMNOCOX2--GER01';

-- QUERY 13: Quins events tenen participació tant d’atletes masculins com femenins?
SELECT e.event_code, e.name
FROM EVENT e
JOIN PARTICIPA_ATHLETE pa ON e.event_code = pa.event_code
JOIN PERSON p ON pa.code_athlete = p.code
GROUP BY e.event_code, e.name
HAVING COUNT(DISTINCT p.gender) > 1;
--VALIDACIÓ 
SELECT p.gender, COUNT(*) as num_athletes
FROM PARTICIPA_ATHLETE pa
JOIN PERSON p ON pa.code_athlete = p.code
WHERE pa.event_code = 'EV0196'
GROUP BY p.gender;

-- QUERY 14: Quins events són de tipus col·lectiu?
SELECT DISTINCT e.event_code, e.name
FROM EVENT e
JOIN PARTICIPA_TEAM pt ON e.event_code = pt.event_code;
--VALIDACIÓ
SELECT pt.code_team, t.team
FROM PARTICIPA_TEAM pt
JOIN TEAM t ON pt.code_team = t.code_team
WHERE pt.event_code = 'EV0103';

-- QUERY 15: Quin NOC té més atletes participants en disciplines de Badminton?
SELECT p.code_noc, COUNT(DISTINCT a.code_athlete) as num_athletes
FROM PERSON p
JOIN ATHLETE a ON p.code = a.code_athlete
JOIN PARTICIPA_ATHLETE pa ON a.code_athlete = pa.code_athlete
JOIN EVENT e ON pa.event_code = e.event_code
JOIN DISCIPLINE d ON e.discipline_code = d.discipline_code
WHERE UPPER(d.discipline) LIKE '%BADMINTON%'
GROUP BY p.code_noc
ORDER BY num_athletes DESC
FETCH FIRST 1 ROWS WITH TIES;
--VALIDACIÓ:
SELECT COUNT(DISTINCT a.code_athlete) as num_athletes
FROM ATHLETE a
JOIN PERSON p ON a.code_athlete = p.code
JOIN PARTICIPA_ATHLETE pa ON a.code_athlete = pa.code_athlete
JOIN EVENT e ON pa.event_code = e.event_code
JOIN DISCIPLINE d ON e.discipline_code = d.discipline_code
WHERE UPPER(d.discipline) LIKE '%BADMINTON%'
AND p.code_noc = 'CHN';

-- QUERY 16: Quin NOC té més equips competint en el sport Judo?
SELECT t.code_noc, COUNT(DISTINCT t.code_team) as num_teams
FROM TEAM t
JOIN PARTICIPA_TEAM pt ON t.code_team = pt.code_team
JOIN EVENT e ON pt.event_code = e.event_code
JOIN DISCIPLINE d ON e.discipline_code = d.discipline_code
JOIN SPORT s ON d.sport_code = s.sport_code
WHERE UPPER(s.sport) LIKE '%JUDO%'
GROUP BY t.code_noc
ORDER BY num_teams DESC
FETCH FIRST 1 ROWS WITH TIES;
--VALIDACIÓ:
SELECT t.code_team, t.team
FROM TEAM t
JOIN PARTICIPA_TEAM pt ON t.code_team = pt.code_team
JOIN EVENT e ON pt.event_code = e.event_code
JOIN DISCIPLINE d ON e.discipline_code = d.discipline_code
JOIN SPORT s ON d.sport_code = s.sport_code
WHERE UPPER(s.sport) LIKE '%JUDO%'
AND t.code_noc = 'AUT';

-- QUERY 17: Quins NOC han obtingut més medalles en total, sumant medalles d’atletes i d’equips?

SELECT n.code_noc, n.country, SUM(x.total_medalles) AS total_medalles
FROM (
    SELECT p.code_noc, COUNT(m.id_medal) AS total_medalles
    FROM MEDAL m
    JOIN PERSON p ON p.code = m.code_athlete
    WHERE m.code_team IS NULL
    GROUP BY p.code_noc

    UNION ALL

    SELECT t.code_noc, COUNT(me.code_team) AS total_medalles
    FROM (
        SELECT DISTINCT code_team, event_code, medal_code
        FROM MEDAL
        WHERE code_team IS NOT NULL
    ) me
    JOIN TEAM t ON t.code_team = me.code_team
    GROUP BY t.code_noc
) x
JOIN NOC n ON n.code_noc = x.code_noc
GROUP BY n.code_noc, n.country
ORDER BY total_medalles DESC;

-- VALIDACIÓ:
-- Confirma que USA té 126 medalles totals: 92 individuals + 34 d'equip

SELECT COUNT(medal_code) AS medalles_individuals_usa
FROM MEDALLISTS
WHERE country_code = 'USA'
AND code_team IS NULL;

SELECT COUNT(*) AS medalles_equip_usa
FROM (
    SELECT DISTINCT code_team, event, medal_code
    FROM MEDALLISTS
    WHERE country_code = 'USA'
    AND code_team IS NOT NULL
);

SELECT 92 + 34 AS total_medalles_usa
FROM DUAL;

-- QUERY 18: Quines disciplines tenen participació d’atletes de més NOC diferents?
SELECT d.discipline_code, d.discipline, COUNT(DISTINCT p.code_noc) as num_nocs
FROM DISCIPLINE d
JOIN EVENT e ON d.discipline_code = e.discipline_code
JOIN PARTICIPA_ATHLETE pa ON e.event_code = pa.event_code
JOIN PERSON p ON pa.code_athlete = p.code
GROUP BY d.discipline_code, d.discipline
ORDER BY num_nocs DESC;
--VALIDACIÓ
SELECT COUNT(DISTINCT p.code_noc) as num_nocs
FROM EVENT e
JOIN PARTICIPA_ATHLETE pa ON e.event_code = pa.event_code
JOIN PERSON p ON pa.code_athlete = p.code
WHERE e.discipline_code = 'ATH';

-- QUERY 19: Quins NOC han obtingut més medalles per atleta participant?

SELECT n.code_noc,
       n.country,
       p_noc.total_athletes,
       NVL(tmn.total_medals, 0) AS total_medals,
       ROUND(NVL(tmn.total_medals, 0) / p_noc.total_athletes, 4) AS ratio_medals_per_athlete
FROM (
    SELECT p.code_noc, COUNT(DISTINCT pa.code_athlete) AS total_athletes
    FROM PARTICIPA_ATHLETE pa
    JOIN PERSON p ON p.code = pa.code_athlete
    WHERE p.code_noc IS NOT NULL
    GROUP BY p.code_noc
) p_noc
JOIN NOC n ON n.code_noc = p_noc.code_noc
LEFT JOIN (
    SELECT x.code_noc, SUM(x.total_medals) AS total_medals
    FROM (
        SELECT p.code_noc, COUNT(m.id_medal) AS total_medals
        FROM MEDAL m
        JOIN PERSON p ON p.code = m.code_athlete
        WHERE m.code_team IS NULL
        GROUP BY p.code_noc

        UNION ALL

        SELECT t.code_noc, COUNT(me.code_team) AS total_medals
        FROM (
            SELECT DISTINCT code_team, event_code, medal_code
            FROM MEDAL
            WHERE code_team IS NOT NULL
        ) me
        JOIN TEAM t ON t.code_team = me.code_team
        GROUP BY t.code_noc
    ) x
    GROUP BY x.code_noc
) tmn ON tmn.code_noc = p_noc.code_noc
WHERE NVL(tmn.total_medals, 0) > 0
ORDER BY ratio_medals_per_athlete DESC;

-- VALIDACIÓ:
-- Confirma que USA té 369 atletes participants, 126 medalles totals i ràtio 0.3415

SELECT COUNT(DISTINCT pa.code_athlete) AS total_athletes_usa
FROM PARTICIPA_ATHLETE pa
JOIN PERSON p ON p.code = pa.code_athlete
WHERE p.code_noc = 'USA';

SELECT COUNT(medal_code) AS medalles_individuals_usa
FROM MEDALLISTS
WHERE country_code = 'USA'
AND code_team IS NULL;

SELECT COUNT(*) AS medalles_equip_usa
FROM (
    SELECT DISTINCT code_team, event, medal_code
    FROM MEDALLISTS
    WHERE country_code = 'USA'
    AND code_team IS NOT NULL
);

SELECT ROUND((92 + 34) / 369, 4) AS ratio_usa
FROM DUAL;


-- QUERY 20: Quins entrenadors entrenen més atletes en disciplines individuals?
SELECT 
    p.name AS coach_name, 
    COUNT(DISTINCT e.code_athlete) AS num_athletes_individual
FROM ENTRENAT e
JOIN PERSON p ON e.code_coach = p.code
JOIN PARTICIPA_ATHLETE pa ON e.code_athlete = pa.code_athlete
JOIN EVENT ev ON pa.event_code = ev.event_code
LEFT JOIN PARTICIPA_TEAM pt ON ev.event_code = pt.event_code
WHERE pt.event_code IS NULL
GROUP BY p.name, e.code_coach
ORDER BY num_athletes_individual DESC;

--VALIDACIÓ
--La consulta no retorna cap resultat a causa d'una limitació estructural en el procés de càrrega de dades. 
--El fitxer athletes.csv conté un camp 'coach' amb informació sobre l'entrenador de cada atleta. 
--Tanmateix, aquest camp és text lliure completament no estructurat, amb formats molt diversos 

----------------
-- #Query 21
-- Entrenadors que entrenen atletes de més d’un equip
--
SELECT e.code_coach
FROM ENTRENAT e
JOIN PERTANY p ON e.code_athlete = p.code_athlete
GROUP BY e.code_coach
HAVING COUNT(DISTINCT p.code_team) > 1;

-- Validació 
SELECT C.NAME 
FROM COACHES c
WHERE C.CODE LIKE '1533246';

SELECT *
FROM TEAMS t
WHERE t.COACHES LIKE ('%PEDRERO Ofelia%');
----------------
-- #Query 22
-- Entrenadors que entrenen atletes en més disciplines
--

SELECT 
    C.code_coach,  
    COUNT(DISTINCT D.discipline_code) AS total_disciplinas
FROM COACH C
JOIN PERSON P ON C.code_coach = P.code
JOIN ENTRENAT E ON C.code_coach = E.code_coach
JOIN PARTICIPA_ATHLETE PA ON E.code_athlete = PA.code_athlete
JOIN EVENT EV ON PA.event_code = EV.event_code
JOIN DISCIPLINE D ON EV.discipline_code = D.discipline_code
GROUP BY C.code_coach
ORDER BY total_disciplinas DESC;

-- Validació 
SELECT c.name 
FROM coaches c
WHERE c.CODE LIKE '1903722';

SELECT COUNT(C.DISCIPLINES) as TOTAL_DISCIPLINES
FROM COACHES C
WHERE C.NAME LIKE '%MOHAMED Mai%';

----------------
-- #Query 23
-- Disciplines amb més entrenadors associats
--

SELECT CD.DISCIPLINE_CODE
FROM COACH_DISCIPLINE CD
JOIN COACH C
ON CD.CODE_COACH = C.CODE_COACH
GROUP BY CD.DISCIPLINE_CODE
ORDER BY COUNT (DISTINCT C.CODE_COACH) DESC;

-- Validació 
SELECT COUNT(C.CODE_COACH) 
FROM COACH_DISCIPLINE CD
JOIN COACH C 
ON CD.CODE_COACH = C.CODE_COACH
WHERE CD.DISCIPLINE_CODE LIKE 'GAR'

SELECT COUNT(C.CODE_COACH) 
FROM COACH_DISCIPLINE CD
JOIN COACH C 
ON CD.CODE_COACH = C.CODE_COACH
WHERE CD.DISCIPLINE_CODE LIKE 'TKW'

----------------
-- #Query 24
-- Entrenadors amb atletes amb més medalles totals
--

SELECT e.code_coach
FROM ENTRENAT e
JOIN MEDAL m ON e.code_athlete = m.code_athlete
GROUP BY e.code_coach
ORDER BY COUNT(m.id_medal) DESC;

-- Validació
SELECT c.name 
FROM coaches c
WHERE c.CODE LIKE '1895269'; 

SELECT A.CODE_ATHLETE
FROM ENTRENAT A
WHERE A.CODE_COACH = '1895269';

SELECT *
FROM ATHLETES A 
WHERE A.CODE = '1895152';

SELECT *
FROM MEDALLISTS M
WHERE M.NAME LIKE '%FRIIS Emma%';

----------------
-- #Query 25
-- Tècnics associats a més disciplines
--

SELECT T.CODE_TECHNICAL
FROM TECHNICAL_DISCIPLINE TD
JOIN TECHNICAL_OFFICIAL T 
ON TD.CODE_TECHNICAL = T.CODE_TECHNICAL
GROUP BY T.CODE_TECHNICAL
ORDER BY COUNT (DISTINCT TD.DISCIPLINE_CODE) DESC;

-- Validació 
SELECT DISCIPLINES 
FROM TECHNICAL_OFFICIALS 
WHERE CODE LIKE '2279615';

----------------
-- #Query 26
-- Organitzacions amb més tècnics afiliats
--
SELECT organisation_code
FROM TECHNICAL_OFFICIAL
GROUP BY organisation_code
ORDER BY COUNT(code_technical) DESC

-- Validació 

SELECT * 
FROM ORGANISATION O
WHERE O.ORGANISATION_CODE LIKE 'World Aquatics'; -- dona 95

SELECT * 
FROM ORGANISATION O
WHERE O.ORGANISATION_CODE LIKE 'PBU';

SELECT MAX (COUNT(T.ORGANISATION)) AS MAX -- tb dona 95, per tant correcta
FROM TECHNICAL_OFFICIALS T
GROUP BY T.ORGANISATION;

----------------
-- #Query 27
-- Tècnics que treballen en més d’una disciplina
--

SELECT T.CODE_TECHNICAL
FROM TECHNICAL_OFFICIAL T
JOIN TECHNICAL_DISCIPLINE TD
ON T.CODE_TECHNICAL = TD.CODE_TECHNICAL
GROUP BY T.CODE_TECHNICAL
HAVING COUNT (DISTINCT TD.DISCIPLINE_CODE) > 1

-- #Validation# 

SELECT T.DISCIPLINES
FROM TECHNICAL_OFFICIALS T
WHERE T.CODE = '1550643';

----------------
-- #Query 28
-- Disciplines amb més esdeveniments programades
--

SELECT ev.discipline_code
FROM SCHEDULE s
JOIN EVENT ev ON s.event_code = ev.event_code
GROUP BY ev.discipline_code
ORDER BY COUNT(s.schedule_id) DESC;

-- #Validation#

SELECT DISCIPLINE_CODE, COUNT(*) AS total_sessions
FROM SCHEDULES
GROUP BY DISCIPLINE_CODE
ORDER BY total_sessions DESC;

----------------
-- #Query 29
-- Sessions amb menor durada 
--

SELECT schedule_id, start_date, end_date, status, phase, event_code, venue_code,
       TO_TIMESTAMP_TZ(end_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') - TO_TIMESTAMP_TZ(start_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') AS durada
FROM SCHEDULE
WHERE start_date IS NOT NULL
AND end_date IS NOT NULL
AND status <> 'CANCELLED'
AND TO_TIMESTAMP_TZ(end_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') > TO_TIMESTAMP_TZ(start_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM')
AND TO_TIMESTAMP_TZ(end_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') - TO_TIMESTAMP_TZ(start_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') = (
    SELECT MIN(TO_TIMESTAMP_TZ(end_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') - TO_TIMESTAMP_TZ(start_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM'))
    FROM SCHEDULE
    WHERE start_date IS NOT NULL
    AND end_date IS NOT NULL
    AND status <> 'CANCELLED'
    AND TO_TIMESTAMP_TZ(end_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM') > TO_TIMESTAMP_TZ(start_date, 'YYYY-MM-DD"T"HH24:MI:SSTZH:TZM')
)
ORDER BY schedule_id;

-- #Validation#

-- Confirma que una de les sessions retornades existeix a la taula crua SCHEDULES i que té una durada d'1 minut, amb estat FINISHED.

SELECT start_date, end_date, status, phase, event, venue_code
FROM SCHEDULES
WHERE start_date = '2024-08-03T21:20:00+02:00'
AND end_date = '2024-08-03T21:21:00+02:00'
AND phase = 'Women''s 100m Final';

-- #Query 30
-- Venues que acullen Athletics
--

SELECT DISTINCT v.venue_code
FROM VENUE v
JOIN SCHEDULE s ON v.venue_code = s.venue_code
JOIN EVENT ev ON s.event_code = ev.event_code
JOIN DISCIPLINE d ON ev.discipline_code = d.discipline_code
WHERE UPPER(d.discipline) = 'ATHLETICS';

-- #Validation#

SELECT * 
FROM VENUE V
WHERE V.VENUE_CODE = 'TRO'

-- Trigger 1

CREATE OR REPLACE TRIGGER trg_no_duplicate_entrenat
BEFORE INSERT ON ENTRENAT
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM ENTRENAT
    WHERE code_coach = :NEW.code_coach
      AND code_athlete = :NEW.code_athlete;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Aquest entrenador ja entrena aquest atleta.');
    END IF;
END;
/


-- Validació 
INSERT INTO ENTRENAT (code_coach, code_athlete)
VALUES (1895269, 1895152);


--TRIGGER 2

CREATE OR REPLACE TRIGGER trg_no_delete_atleta_medallista
BEFORE DELETE ON ATHLETE
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM MEDAL
    WHERE code_athlete = :OLD.code_athlete;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Accio denegada: No es pot eliminar un atleta que ha obtingut una medalla olimpica.');
    END IF;
END;
/
 
--VALIDACIONS 

-- SALTA TRIGGER
SELECT DISTINCT p.name, a.code_athlete
FROM ATHLETE a
JOIN PERSON p ON a.code_athlete = p.code
JOIN MEDAL m ON a.code_athlete = m.code_athlete;

DELETE FROM ATHLETE WHERE code_athlete = 1536197;

--NO SALTA TRIGGER
SELECT a.code_athlete, p.name
FROM ATHLETE a
JOIN PERSON p ON a.code_athlete = p.code
LEFT JOIN MEDAL m ON a.code_athlete = m.code_athlete
LEFT JOIN PARLA pr ON a.code_athlete = pr.code_athlete
LEFT JOIN PARTICIPA_ATHLETE pa ON a.code_athlete = pa.code_athlete
LEFT JOIN PERTANY pt ON a.code_athlete = pt.code_athlete
LEFT JOIN ENTRENAT e ON a.code_athlete = e.code_athlete
WHERE m.id_medal IS NULL
  AND pr.code_athlete IS NULL
  AND pa.code_athlete IS NULL
  AND pt.code_athlete IS NULL
  AND e.code_athlete IS NULL
FETCH FIRST 1 ROWS ONLY;

DELETE FROM ATHLETE WHERE code_athlete = 1945767;
ROLLBACK;

-- TRIGGER 3

CREATE TABLE HISTORIC_MEDAL (
    id_historic NUMBER NOT NULL,
    id_medal NUMBER,
    old_medal_type VARCHAR2(20),
    new_medal_type VARCHAR2(20),
    old_code_athlete NUMBER,
    new_code_athlete NUMBER,
    old_code_team VARCHAR2(20),
    new_code_team VARCHAR2(20),
    old_event_code VARCHAR2(20),
    new_event_code VARCHAR2(20),
    usuari VARCHAR2(100),
    data_modificacio TIMESTAMP,
    CONSTRAINT pk_historic_medal PRIMARY KEY (id_historic)
);

CREATE SEQUENCE seq_historic_medal
START WITH 1
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_auditoria_medal
AFTER UPDATE ON MEDAL
FOR EACH ROW
BEGIN
    INSERT INTO HISTORIC_MEDAL (id_historic, id_medal, old_medal_type, new_medal_type, old_code_athlete, new_code_athlete, old_code_team, new_code_team, old_event_code, new_event_code, usuari, data_modificacio)
    VALUES (seq_historic_medal.NEXTVAL, :OLD.id_medal, :OLD.medal_type, :NEW.medal_type, :OLD.code_athlete, :NEW.code_athlete, :OLD.code_team, :NEW.code_team, :OLD.event_code, :NEW.event_code, USER, SYSTIMESTAMP);
END;
/

-- VALIDACIONS

-- SALTA TRIGGER
SELECT id_medal, medal_type, code_athlete, code_team, event_code
FROM MEDAL
WHERE id_medal = 1561;

UPDATE MEDAL
SET medal_type = 'Silver Medal'
WHERE id_medal = 1561;

SELECT id_medal, old_medal_type, new_medal_type, old_code_athlete, new_code_athlete, old_code_team, new_code_team, usuari, data_modificacio
FROM HISTORIC_MEDAL
WHERE id_medal = 1561;