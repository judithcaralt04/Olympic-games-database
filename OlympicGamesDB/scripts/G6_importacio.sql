-- =========================================
-- INSERT COUNTRY
-- =========================================

INSERT INTO COUNTRY (id_country, name_country)
SELECT ROW_NUMBER() OVER (ORDER BY name_country) AS id_country,
       name_country
FROM (
    SELECT DISTINCT TRIM(birth_country) AS name_country
    FROM ATHLETES
    WHERE birth_country IS NOT NULL
      AND TRIM(birth_country) IS NOT NULL

    UNION

    SELECT DISTINCT TRIM(residence_country) AS name_country
    FROM ATHLETES
    WHERE residence_country IS NOT NULL
      AND TRIM(residence_country) IS NOT NULL
);

-- =========================================
-- INSERT VENUE
-- =========================================

INSERT INTO VENUE (venue_code, venue, url, location_description)
SELECT s.venue_code,
       MIN(s.venue) AS venue,
       MIN(v.url) AS url,
       MIN(s.location_description) AS location_description
FROM SCHEDULES s
LEFT JOIN VENUES v
  ON UPPER(TRIM(s.venue)) = UPPER(TRIM(v.venue))
WHERE s.venue_code IS NOT NULL
  AND s.venue IS NOT NULL
GROUP BY s.venue_code;

-- =========================================
-- INSERT SPORT
-- =========================================

INSERT INTO SPORT (sport_code, sport, sport_url)
SELECT DISTINCT sport_code, sport, sport_url
FROM EVENTS
WHERE sport_code IS NOT NULL;

-- =========================================
-- INSERT NOC
-- =========================================

INSERT INTO NOC (code_noc, country, country_long, note)
SELECT code, country, country_long, note
FROM NOCS;

-- =========================================
-- INSERT ORGANISATION
-- =========================================

INSERT INTO ORGANISATION (organisation_code, organisation, organisation_long)
SELECT DISTINCT organisation_code, organisation, organisation_long
FROM TECHNICAL_OFFICIALS
WHERE organisation_code IS NOT NULL;

-- =========================================
-- INSERT LANGUAGES
-- =========================================

BEGIN
  FOR rec IN (
    SELECT DISTINCT lang
    FROM ATHLETES
    WHERE lang IS NOT NULL
  ) LOOP
    DECLARE
      v_str   VARCHAR2(1000) := rec.lang || ',';
      v_token VARCHAR2(100);
      v_pos   NUMBER;
      v_id    NUMBER;
    BEGIN
      WHILE INSTR(v_str, ',') > 0 LOOP
        v_pos := INSTR(v_str, ',');
        v_token := RTRIM(TRIM(SUBSTR(v_str, 1, v_pos - 1)), '.');

        IF v_token IS NOT NULL THEN
          SELECT COUNT(*) + 1
          INTO v_id
          FROM LANGUAGES;

          INSERT INTO LANGUAGES (language_code, language_name)
          SELECT TO_CHAR(v_id), v_token
          FROM DUAL
          WHERE NOT EXISTS (
            SELECT 1
            FROM LANGUAGES
            WHERE UPPER(language_name) = UPPER(v_token)
          );
        END IF;

        v_str := SUBSTR(v_str, v_pos + 1);
      END LOOP;
    END;
  END LOOP;
END;
/

-- =========================================
-- INSERT CITY
-- =========================================

INSERT INTO CITY (id_city, name_city, country)
SELECT ROW_NUMBER() OVER (ORDER BY name_city, id_country) AS id_city,
       name_city,
       id_country
FROM (
    SELECT DISTINCT
           TRIM(a.birth_place) AS name_city,
           c.id_country
    FROM ATHLETES a
    JOIN COUNTRY c
      ON UPPER(TRIM(a.birth_country)) = UPPER(TRIM(c.name_country))
    WHERE a.birth_place IS NOT NULL
      AND TRIM(a.birth_place) IS NOT NULL
      AND a.birth_country IS NOT NULL
      AND TRIM(a.birth_country) IS NOT NULL

    UNION

    SELECT DISTINCT
           TRIM(a.residence_place) AS name_city,
           c.id_country
    FROM ATHLETES a
    JOIN COUNTRY c
      ON UPPER(TRIM(a.residence_country)) = UPPER(TRIM(c.name_country))
    WHERE a.residence_place IS NOT NULL
      AND TRIM(a.residence_place) IS NOT NULL
      AND a.residence_country IS NOT NULL
      AND TRIM(a.residence_country) IS NOT NULL
);

-- =========================================
-- INSERT PERSON
-- =========================================

INSERT INTO PERSON (code, name, gender, birth_date, code_noc)
SELECT p.code, p.name, p.gender, p.birth_date, p.code_noc
FROM (
    SELECT a.code, a.name, a.gender, a.birth_date, a.country_code AS code_noc
    FROM ATHLETES a
    WHERE a.code IS NOT NULL
      AND a.name IS NOT NULL

    UNION ALL

    SELECT c.code, c.name, c.gender, c.birth_date, c.country_code AS code_noc
    FROM COACHES c
    WHERE c.code IS NOT NULL
      AND c.name IS NOT NULL

    UNION ALL

    SELECT t.code, t.name, t.gender, t.birth_date, NULL AS code_noc
    FROM TECHNICAL_OFFICIALS t
    WHERE t.code IS NOT NULL
      AND t.name IS NOT NULL
) p
LEFT JOIN NOC n
  ON p.code_noc = n.code_noc
WHERE (p.code_noc IS NULL OR n.code_noc IS NOT NULL)
  AND p.code NOT IN (
      SELECT code
      FROM PERSON
  );

-- =========================================
-- INSERT DISCIPLINE
-- =========================================

INSERT INTO DISCIPLINE (discipline_code, discipline, sport_code)
SELECT DISTINCT s.discipline_code,
       s.discipline,
       sp.sport_code
FROM SCHEDULES s
LEFT JOIN SPORT sp
  ON s.discipline_code = sp.sport_code
WHERE s.discipline_code IS NOT NULL
  AND s.discipline_code <> 'CER';

-- =========================================
-- INSERT TEAM
-- =========================================

INSERT INTO TEAM (code_team, team, team_gender, current_team, code_noc)
SELECT t.code,
       t.team,
       t.team_gender,
       TO_CHAR(t."current"),
       n.code_noc
FROM TEAMS t
JOIN NOC n
  ON t.country_code = n.code_noc
WHERE t.code IS NOT NULL
  AND t.team IS NOT NULL;

-- =========================================
-- INSERT TECHNICAL_OFFICIAL
-- =========================================

INSERT INTO TECHNICAL_OFFICIAL (
    code_technical,
    function_role,
    category,
    organisation_code
)
SELECT t.code,
       t.function,
       t.category,
       t.organisation_code
FROM TECHNICAL_OFFICIALS t
JOIN PERSON p
  ON p.code = t.code
LEFT JOIN ORGANISATION o
  ON o.organisation_code = t.organisation_code
WHERE t.code IS NOT NULL
  AND (t.organisation_code IS NULL OR o.organisation_code IS NOT NULL)
  AND t.code NOT IN (
      SELECT code_technical
      FROM TECHNICAL_OFFICIAL
  );

-- =========================================
-- INSERT COACH
-- =========================================

INSERT INTO COACH (
    code_coach,
    function_role,
    category,
    discipline_code
)
SELECT
    c.code,
    c.function,
    c.category,
    d.discipline_code
FROM COACHES c
JOIN PERSON p
  ON p.code = c.code
JOIN DISCIPLINE d
  ON UPPER(TRIM(c.disciplines)) = UPPER(TRIM(d.discipline))
WHERE c.code NOT IN (
    SELECT code_coach
    FROM COACH
);

-- =========================================
-- INSERT ATHLETE
-- =========================================

INSERT INTO ATHLETE (
    code_athlete,
    height,
    weight,
    occupation,
    function_role,
    birth_city,
    residence_city,
    nickname,
    hobbies,
    education,
    philosophy,
    hero,
    influence,
    family_info,
    sporting_relatives,
    ritual,
    reason_start_sport,
    other_sports
)
SELECT DISTINCT
       a.code,
       CASE WHEN a.height = 0 THEN NULL ELSE a.height END,
       CASE WHEN a.weight = 0 THEN NULL ELSE a.weight END,
       a.occupation,
       a.function,
       cb.id_city,
       cr.id_city,
       a.nickname,
       a.hobbies,
       a.education,
       a.philosophy,
       a.hero,
       a.influence,
       a.family,
       a.sporting_relatives,
       a.ritual,
       a.reason,
       a.other_sports
FROM ATHLETES a
JOIN PERSON p
  ON p.code = a.code
LEFT JOIN COUNTRY c1
  ON UPPER(TRIM(a.birth_country)) = UPPER(TRIM(c1.name_country))
LEFT JOIN CITY cb
  ON UPPER(TRIM(a.birth_place)) = UPPER(TRIM(cb.name_city))
 AND cb.country = c1.id_country
LEFT JOIN COUNTRY c2
  ON UPPER(TRIM(a.residence_country)) = UPPER(TRIM(c2.name_country))
LEFT JOIN CITY cr
  ON UPPER(TRIM(a.residence_place)) = UPPER(TRIM(cr.name_city))
 AND cr.country = c2.id_country
WHERE a.code IS NOT NULL
  AND a.code NOT IN (
      SELECT code_athlete
      FROM ATHLETE
  );

-- =========================================
-- INSERT SEATING_ZONE
-- =========================================

INSERT INTO SEATING_ZONE (seating_zone, zone_name, zone_type, venue_code)
SELECT DISTINCT s.seating_zone,
       s.zone_name,
       s.zone_type,
       s.venue_code
FROM SEATING_ZONES s
JOIN VENUE v
  ON s.venue_code = v.venue_code
WHERE s.seating_zone IS NOT NULL;

-- =========================================
-- INSERT PARLA
-- =========================================

BEGIN
  FOR rec IN (
    SELECT code, lang
    FROM ATHLETES
    WHERE lang IS NOT NULL
      AND code IS NOT NULL
  ) LOOP
    DECLARE
      v_str       VARCHAR2(1000) := rec.lang || ',';
      v_token     VARCHAR2(100);
      v_pos       NUMBER;
      v_lang_code VARCHAR2(20);
    BEGIN
      WHILE INSTR(v_str, ',') > 0 LOOP
        v_pos := INSTR(v_str, ',');
        v_token := RTRIM(TRIM(SUBSTR(v_str, 1, v_pos - 1)), '.');

        IF v_token IS NOT NULL THEN
          BEGIN
            SELECT language_code
            INTO v_lang_code
            FROM LANGUAGES
            WHERE UPPER(language_name) = UPPER(v_token);

            INSERT INTO PARLA (language_code, code_athlete)
            SELECT v_lang_code, rec.code
            FROM DUAL
            WHERE NOT EXISTS (
              SELECT 1
              FROM PARLA
              WHERE language_code = v_lang_code
                AND TO_CHAR(code_athlete) = TO_CHAR(rec.code)
            );

          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              NULL;
          END;
        END IF;

        v_str := SUBSTR(v_str, v_pos + 1);
      END LOOP;
    END;
  END LOOP;
END;
/

-- =========================================
-- INSERT DIRIGEIX
-- =========================================

BEGIN
  FOR rec IN (
    SELECT code, coaches_codes
    FROM TEAMS
    WHERE code IS NOT NULL
      AND coaches_codes IS NOT NULL
  ) LOOP
    DECLARE
      v_str   VARCHAR2(4000) := REPLACE(REPLACE(REPLACE(rec.coaches_codes, '[', ''), ']', ''), '''', '') || ',';
      v_token VARCHAR2(100);
      v_pos   NUMBER;
    BEGIN
      WHILE INSTR(v_str, ',') > 0 LOOP
        v_pos := INSTR(v_str, ',');
        v_token := TRIM(SUBSTR(v_str, 1, v_pos - 1));

        IF v_token IS NOT NULL THEN
          INSERT INTO DIRIGEIX (code_coach, code_team)
          SELECT c.code_coach, rec.code
          FROM COACH c
          WHERE TO_CHAR(c.code_coach) = v_token
            AND NOT EXISTS (
              SELECT 1
              FROM DIRIGEIX d
              WHERE d.code_coach = c.code_coach
                AND d.code_team = rec.code
            );
        END IF;

        v_str := SUBSTR(v_str, v_pos + 1);
      END LOOP;
    END;
  END LOOP;
END;
/

-- =========================================
-- INSERT PERTANY
-- =========================================

BEGIN
  FOR rec IN (
    SELECT code, athletes_codes
    FROM TEAMS
    WHERE code IS NOT NULL
      AND athletes_codes IS NOT NULL
  ) LOOP
    DECLARE
      v_str   VARCHAR2(4000) := REPLACE(REPLACE(REPLACE(rec.athletes_codes, '[', ''), ']', ''), '''', '') || ',';
      v_token VARCHAR2(100);
      v_pos   NUMBER;
    BEGIN
      WHILE INSTR(v_str, ',') > 0 LOOP
        v_pos := INSTR(v_str, ',');
        v_token := TRIM(SUBSTR(v_str, 1, v_pos - 1));

        IF v_token IS NOT NULL THEN
          INSERT INTO PERTANY (code_athlete, code_team)
          SELECT a.code_athlete, rec.code
          FROM ATHLETE a
          WHERE TO_CHAR(a.code_athlete) = v_token
            AND NOT EXISTS (
              SELECT 1
              FROM PERTANY p
              WHERE p.code_athlete = a.code_athlete
                AND p.code_team = rec.code
            );
        END IF;

        v_str := SUBSTR(v_str, v_pos + 1);
      END LOOP;
    END;
  END LOOP;
END;
/

-- =========================================
-- INSERT ENTRENAT
-- =========================================

INSERT INTO ENTRENAT (code_coach, code_athlete)
SELECT DISTINCT d.code_coach,
       p.code_athlete
FROM DIRIGEIX d
JOIN PERTANY p
  ON d.code_team = p.code_team
WHERE NOT EXISTS (
    SELECT 1
    FROM ENTRENAT e
    WHERE e.code_coach = d.code_coach
      AND e.code_athlete = p.code_athlete
);

-- =========================================
-- INSERT TECHNICAL_DISCIPLINE
-- =========================================

DELETE FROM TECHNICAL_DISCIPLINE;
COMMIT;

BEGIN
    FOR r IN (
        SELECT code, disciplines
        FROM TECHNICAL_OFFICIALS
        WHERE code IS NOT NULL
          AND disciplines IS NOT NULL
    ) LOOP

        FOR d IN (
            SELECT discipline_code, discipline
            FROM DISCIPLINE
            WHERE INSTR(
                UPPER(r.disciplines),
                '''' || UPPER(TRIM(discipline)) || ''''
            ) > 0
        ) LOOP

            INSERT INTO TECHNICAL_DISCIPLINE (
                code_technical,
                discipline_code
            )
            SELECT r.code, d.discipline_code
            FROM dual
            WHERE EXISTS (
                SELECT 1
                FROM TECHNICAL_OFFICIAL t
                WHERE t.code_technical = r.code
            )
            AND NOT EXISTS (
                SELECT 1
                FROM TECHNICAL_DISCIPLINE td
                WHERE td.code_technical = r.code
                  AND td.discipline_code = d.discipline_code
            );

        END LOOP;

    END LOOP;

    COMMIT;
END;
/

-- =========================================
-- INSERT EVENT
-- =========================================

INSERT INTO EVENT (event_code, name, tag, gender, url_event, discipline_code)
SELECT 'EV' || LPAD(ROW_NUMBER() OVER (ORDER BY discipline_code, name, gender), 4, '0') AS event_code,
       name,
       tag,
       gender,
       url_event,
       discipline_code
FROM (
    SELECT s.discipline_code,
           s.event AS name,
           MIN(e.tag) AS tag,
           s.gender,
           MIN(s.url) AS url_event
    FROM SCHEDULES s
    LEFT JOIN EVENTS e
      ON UPPER(TRIM(s.event)) = UPPER(TRIM(e.event))
     AND s.discipline_code = e.sport_code
    WHERE s.discipline_code IS NOT NULL
      AND s.discipline_code <> 'CER'
    GROUP BY s.discipline_code, s.event, s.gender
);

-- =========================================
-- INSERT PARTICIPA_TEAM
-- =========================================

INSERT INTO PARTICIPA_TEAM (event_code, code_team)
SELECT DISTINCT e.event_code,
       t.code
FROM TEAMS t
JOIN TEAM tf
  ON tf.code_team = t.code
JOIN EVENT e
  ON UPPER(TRIM(e.name)) = UPPER(TRIM(t.events))
 AND e.discipline_code = t.disciplines_code
WHERE t.code IS NOT NULL
  AND t.events IS NOT NULL;

-- =========================================
-- INSERT PARTICIPA_ATHLETE
-- =========================================

INSERT INTO PARTICIPA_ATHLETE (event_code, code_athlete)
SELECT DISTINCT e.event_code, a.code_athlete
FROM (
    SELECT code,
           TRIM(REPLACE(REPLACE(REPLACE(REGEXP_SUBSTR(events, '[^,]+', 1, LEVEL), '[', ''), ']', ''), '"', '')) AS event_name
    FROM ATHLETES
    WHERE events IS NOT NULL
      AND code IS NOT NULL
    CONNECT BY LEVEL <= REGEXP_COUNT(events, ',') + 1
      AND PRIOR code = code
      AND PRIOR SYS_GUID() IS NOT NULL
) x
JOIN EVENT e
  ON UPPER(TRIM(e.name)) = UPPER(TRIM(x.event_name))
JOIN ATHLETE a
  ON a.code_athlete = x.code
WHERE NOT EXISTS (
    SELECT 1
    FROM PARTICIPA_ATHLETE pa
    WHERE pa.event_code = e.event_code
      AND pa.code_athlete = a.code_athlete
);

-- =========================================
-- INSERT SCHEDULE
-- =========================================

INSERT INTO SCHEDULE (schedule_id, start_date, end_date, status, phase, url, event_code, venue_code)
SELECT ROW_NUMBER() OVER (ORDER BY s.ROWID) AS schedule_id,
       s.start_date,
       s.end_date,
       s.status,
       s.phase,
       s.url,
       e.event_code,
       s.venue_code
FROM SCHEDULES s
JOIN EVENT e
  ON UPPER(TRIM(e.name)) = UPPER(TRIM(s.event))
 AND e.discipline_code = s.discipline_code
 AND e.gender = s.gender
JOIN VENUE v
  ON v.venue_code = s.venue_code;

-- =========================================
-- INSERT TICKET
-- =========================================

INSERT INTO TICKET (ticket_id, ticket_type, price, purchase_date, schedule_id, seating_zone)
SELECT DISTINCT t.ticket_id,
       t.ticket_type,
       t.price,
       t.purchase_date,
       t.schedule_id,
       t.seating_zone
FROM TICKETS t
JOIN SCHEDULE s
  ON t.schedule_id = s.schedule_id
JOIN SEATING_ZONE z
  ON t.seating_zone = z.seating_zone
WHERE t.ticket_id IS NOT NULL;

-- =========================================
-- INSERT MEDAL
-- =========================================

INSERT INTO MEDAL (
    id_medal,
    medal_code,
    medal_type,
    code_athlete,
    code_team,
    event_code
)
SELECT ROW_NUMBER() OVER (
           ORDER BY m.discipline,
                    m.event,
                    m.medal_type,
                    m.code_athlete,
                    m.code_team
       ) AS id_medal,
       TO_CHAR(m.medal_code) AS medal_code,
       m.medal_type,
       m.code_athlete,
       m.code_team,
       e.event_code
FROM MEDALLISTS m
JOIN DISCIPLINE d
  ON UPPER(TRIM(d.discipline)) = UPPER(TRIM(m.discipline))
JOIN EVENT e
  ON UPPER(TRIM(e.name)) = UPPER(TRIM(m.event))
 AND e.discipline_code = d.discipline_code
LEFT JOIN ATHLETE a
  ON a.code_athlete = m.code_athlete
LEFT JOIN TEAM t
  ON t.code_team = m.code_team
WHERE m.medal_code IS NOT NULL
  AND (
        (m.code_athlete IS NOT NULL AND a.code_athlete IS NOT NULL)
        OR
        (m.code_team IS NOT NULL AND t.code_team IS NOT NULL)
      );

COMMIT;