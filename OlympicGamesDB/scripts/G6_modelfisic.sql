DROP TABLE medal CASCADE CONSTRAINTS;
DROP TABLE ticket CASCADE CONSTRAINTS;
DROP TABLE schedule CASCADE CONSTRAINTS;
DROP TABLE participa_athlete CASCADE CONSTRAINTS;
DROP TABLE participa_team CASCADE CONSTRAINTS;
DROP TABLE event CASCADE CONSTRAINTS;
DROP TABLE technical_discipline CASCADE CONSTRAINTS;
DROP TABLE pertany CASCADE CONSTRAINTS;
DROP TABLE dirigeix CASCADE CONSTRAINTS;
DROP TABLE entrenat CASCADE CONSTRAINTS;
DROP TABLE parla CASCADE CONSTRAINTS;
DROP TABLE seating_zone CASCADE CONSTRAINTS;
DROP TABLE athlete CASCADE CONSTRAINTS;
DROP TABLE coach CASCADE CONSTRAINTS;
DROP TABLE technical_official CASCADE CONSTRAINTS;
DROP TABLE team CASCADE CONSTRAINTS;
DROP TABLE person CASCADE CONSTRAINTS;
DROP TABLE city CASCADE CONSTRAINTS;
DROP TABLE discipline CASCADE CONSTRAINTS;
DROP TABLE organisation CASCADE CONSTRAINTS;
DROP TABLE noc CASCADE CONSTRAINTS;
DROP TABLE sport CASCADE CONSTRAINTS;
DROP TABLE venue CASCADE CONSTRAINTS;
DROP TABLE country CASCADE CONSTRAINTS;
DROP TABLE languages CASCADE CONSTRAINTS;

CREATE TABLE languages (
    language_code VARCHAR2(20) NOT NULL,
    language_name VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_languages PRIMARY KEY (language_code)
);

CREATE TABLE country (
    id_country NUMBER NOT NULL,
    name_country VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_country PRIMARY KEY (id_country),
    CONSTRAINT uq_country_name UNIQUE (name_country)
);

CREATE TABLE venue (
    venue_code VARCHAR2(20) NOT NULL,
    venue VARCHAR2(100) NOT NULL,
    url VARCHAR2(255),
    location_description VARCHAR2(255),
    CONSTRAINT pk_venue PRIMARY KEY (venue_code)
);

CREATE TABLE sport (
    sport_code VARCHAR2(20) NOT NULL,
    sport VARCHAR2(100) NOT NULL,
    sport_url VARCHAR2(255),
    CONSTRAINT pk_sport PRIMARY KEY (sport_code)
);

CREATE TABLE discipline (
    discipline_code VARCHAR2(20) NOT NULL,
    discipline VARCHAR2(100) NOT NULL,
    sport_code VARCHAR2(20),
    CONSTRAINT pk_discipline PRIMARY KEY (discipline_code),
    CONSTRAINT fk_discipline_sport FOREIGN KEY (sport_code)
        REFERENCES sport(sport_code)
);

CREATE TABLE noc (
    code_noc VARCHAR2(10) NOT NULL,
    country VARCHAR2(100),
    country_long VARCHAR2(150),
    note VARCHAR2(255),
    CONSTRAINT pk_noc PRIMARY KEY (code_noc)
);

CREATE TABLE organisation (
    organisation_code VARCHAR2(20) NOT NULL,
    organisation VARCHAR2(100) NOT NULL,
    organisation_long VARCHAR2(150),
    CONSTRAINT pk_organisation PRIMARY KEY (organisation_code)
);

CREATE TABLE city (
    id_city NUMBER NOT NULL,
    name_city VARCHAR2(100) NOT NULL,
    country NUMBER,
    CONSTRAINT pk_city PRIMARY KEY (id_city),
    CONSTRAINT fk_city_country FOREIGN KEY (country)
        REFERENCES country(id_country)
);

CREATE TABLE person (
    code NUMBER NOT NULL,
    name VARCHAR2(150) NOT NULL,
    gender VARCHAR2(20),
    birth_date VARCHAR2(50),
    code_noc VARCHAR2(10),
    CONSTRAINT pk_person PRIMARY KEY (code),
    CONSTRAINT fk_person_noc FOREIGN KEY (code_noc)
        REFERENCES noc(code_noc)
);

CREATE TABLE team (
    code_team VARCHAR2(20) NOT NULL,
    team VARCHAR2(150) NOT NULL,
    team_gender VARCHAR2(5),
    current_team VARCHAR2(5),
    code_noc VARCHAR2(10),
    CONSTRAINT pk_team PRIMARY KEY (code_team),
    CONSTRAINT fk_team_noc FOREIGN KEY (code_noc)
        REFERENCES noc(code_noc)
);

CREATE TABLE technical_official (
    code_technical NUMBER NOT NULL,
    function_role VARCHAR2(100),
    category VARCHAR2(100),
    organisation_code VARCHAR2(20),
    CONSTRAINT pk_technical_official PRIMARY KEY (code_technical),
    CONSTRAINT fk_technical_official_person FOREIGN KEY (code_technical)
        REFERENCES person(code),
    CONSTRAINT fk_technical_official_org FOREIGN KEY (organisation_code)
        REFERENCES organisation(organisation_code)
);

CREATE TABLE coach (
    code_coach NUMBER NOT NULL,
    function_role VARCHAR2(100),
    category VARCHAR2(100),
    discipline_code VARCHAR2(20),
    CONSTRAINT pk_coach PRIMARY KEY (code_coach),
    CONSTRAINT fk_coach_person FOREIGN KEY (code_coach)
        REFERENCES person(code),
    CONSTRAINT fk_coach_discipline FOREIGN KEY (discipline_code)
        REFERENCES discipline(discipline_code)
);

CREATE TABLE athlete (
    code_athlete NUMBER NOT NULL,
    height NUMBER(5,2),
    weight NUMBER(5,2),
    occupation VARCHAR2(300),
    function_role VARCHAR2(100),
    birth_city NUMBER,
    residence_city NUMBER,
    nickname VARCHAR2(1000),
    hobbies VARCHAR2(1000),
    education VARCHAR2(1000),
    philosophy VARCHAR2(1000),
    hero VARCHAR2(1000),
    influence VARCHAR2(1000),
    family_info VARCHAR2(1000),
    sporting_relatives VARCHAR2(1000),
    ritual VARCHAR2(1000),
    reason_start_sport VARCHAR2(1000),
    other_sports VARCHAR2(1000),
    CONSTRAINT pk_athlete PRIMARY KEY (code_athlete),
    CONSTRAINT fk_athlete_person FOREIGN KEY (code_athlete)
        REFERENCES person(code),
    CONSTRAINT fk_athlete_birth_city FOREIGN KEY (birth_city)
        REFERENCES city(id_city),
    CONSTRAINT fk_athlete_residence_city FOREIGN KEY (residence_city)
        REFERENCES city(id_city)
);

CREATE TABLE seating_zone (
    seating_zone VARCHAR2(30) NOT NULL,
    zone_name VARCHAR2(100),
    zone_type VARCHAR2(50),
    venue_code VARCHAR2(20),
    CONSTRAINT pk_seating_zone PRIMARY KEY (seating_zone),
    CONSTRAINT fk_seating_zone_venue FOREIGN KEY (venue_code)
        REFERENCES venue(venue_code)
);

CREATE TABLE parla (
    language_code VARCHAR2(20) NOT NULL,
    code_athlete NUMBER NOT NULL,
    CONSTRAINT pk_parla PRIMARY KEY (language_code, code_athlete),
    CONSTRAINT fk_parla_language FOREIGN KEY (language_code)
        REFERENCES languages(language_code),
    CONSTRAINT fk_parla_athlete FOREIGN KEY (code_athlete)
        REFERENCES athlete(code_athlete)
);

CREATE TABLE entrenat (
    code_coach NUMBER NOT NULL,
    code_athlete NUMBER NOT NULL,
    CONSTRAINT pk_entrenat PRIMARY KEY (code_coach, code_athlete),
    CONSTRAINT fk_entrenat_coach FOREIGN KEY (code_coach)
        REFERENCES coach(code_coach),
    CONSTRAINT fk_entrenat_athlete FOREIGN KEY (code_athlete)
        REFERENCES athlete(code_athlete)
);

CREATE TABLE dirigeix (
    code_coach NUMBER NOT NULL,
    code_team VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_dirigeix PRIMARY KEY (code_coach, code_team),
    CONSTRAINT fk_dirigeix_coach FOREIGN KEY (code_coach)
        REFERENCES coach(code_coach),
    CONSTRAINT fk_dirigeix_team FOREIGN KEY (code_team)
        REFERENCES team(code_team)
);

CREATE TABLE pertany (
    code_athlete NUMBER NOT NULL,
    code_team VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_pertany PRIMARY KEY (code_athlete, code_team),
    CONSTRAINT fk_pertany_athlete FOREIGN KEY (code_athlete)
        REFERENCES athlete(code_athlete),
    CONSTRAINT fk_pertany_team FOREIGN KEY (code_team)
        REFERENCES team(code_team)
);

CREATE TABLE technical_discipline (
    code_technical NUMBER NOT NULL,
    discipline_code VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_technical_discipline PRIMARY KEY (code_technical, discipline_code),
    CONSTRAINT fk_td_technical FOREIGN KEY (code_technical)
        REFERENCES technical_official(code_technical),
    CONSTRAINT fk_td_discipline FOREIGN KEY (discipline_code)
        REFERENCES discipline(discipline_code)
);

CREATE TABLE event (
    event_code VARCHAR2(20) NOT NULL,
    name VARCHAR2(150) NOT NULL,
    tag VARCHAR2(100),
    gender VARCHAR2(5),
    url_event VARCHAR2(255),
    discipline_code VARCHAR2(20),
    CONSTRAINT pk_event PRIMARY KEY (event_code),
    CONSTRAINT fk_event_discipline FOREIGN KEY (discipline_code)
        REFERENCES discipline(discipline_code)
);

CREATE TABLE participa_team (
    event_code VARCHAR2(20) NOT NULL,
    code_team VARCHAR2(20) NOT NULL,
    CONSTRAINT pk_participa_team PRIMARY KEY (event_code, code_team),
    CONSTRAINT fk_participa_team_event FOREIGN KEY (event_code)
        REFERENCES event(event_code),
    CONSTRAINT fk_participa_team_team FOREIGN KEY (code_team)
        REFERENCES team(code_team)
);

CREATE TABLE participa_athlete (
    event_code VARCHAR2(20) NOT NULL,
    code_athlete NUMBER NOT NULL,
    CONSTRAINT pk_participa_athlete PRIMARY KEY (event_code, code_athlete),
    CONSTRAINT fk_participa_athlete_event FOREIGN KEY (event_code)
        REFERENCES event(event_code),
    CONSTRAINT fk_participa_athlete_athlete FOREIGN KEY (code_athlete)
        REFERENCES athlete(code_athlete)
);

CREATE TABLE schedule (
    schedule_id NUMBER NOT NULL,
    start_date VARCHAR2(50),
    end_date VARCHAR2(50),
    status VARCHAR2(50),
    phase VARCHAR2(100),
    url VARCHAR2(255),
    event_code VARCHAR2(20),
    venue_code VARCHAR2(20),
    CONSTRAINT pk_schedule PRIMARY KEY (schedule_id),
    CONSTRAINT fk_schedule_event FOREIGN KEY (event_code)
        REFERENCES event(event_code),
    CONSTRAINT fk_schedule_venue FOREIGN KEY (venue_code)
        REFERENCES venue(venue_code)
);

CREATE TABLE ticket (
    ticket_id NUMBER NOT NULL,
    ticket_type VARCHAR2(50),
    price NUMBER(10,2),
    purchase_date VARCHAR2(50),
    schedule_id NUMBER,
    seating_zone VARCHAR2(30),
    CONSTRAINT pk_tickets PRIMARY KEY (ticket_id),
    CONSTRAINT fk_tickets_schedule FOREIGN KEY (schedule_id)
        REFERENCES schedule(schedule_id),
    CONSTRAINT fk_tickets_seating_zone FOREIGN KEY (seating_zone)
        REFERENCES seating_zone(seating_zone)
);

CREATE TABLE medal (
    id_medal NUMBER NOT NULL,
    medal_code VARCHAR2(20) NOT NULL,
    medal_type VARCHAR2(20),
    code_athlete NUMBER,
    code_team VARCHAR2(20),
    event_code VARCHAR2(20),
    CONSTRAINT pk_medal PRIMARY KEY (id_medal),
    CONSTRAINT fk_medal_athlete FOREIGN KEY (code_athlete)
        REFERENCES athlete(code_athlete),
    CONSTRAINT fk_medal_team FOREIGN KEY (code_team)
        REFERENCES team(code_team),
    CONSTRAINT fk_medal_event FOREIGN KEY (event_code)
        REFERENCES event(event_code)
);
