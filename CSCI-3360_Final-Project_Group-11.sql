-- =============================================================
-- CSCI 3360 - Database Systems
-- Final Project - Group 11
-- Movie Database: Data Population & Queries
-- =============================================================

-- ============================================================
-- SQL*PLUS DISPLAY FORMATTING
-- ============================================================
SET LINESIZE 32767
SET PAGESIZE 50
SET WRAP ON

-- Trim column display widths to remove excess padding
COL Person_ID        FORMAT 9999
COL Fname            FORMAT A15
COL Mname            FORMAT A10
COL Lname            FORMAT A20
COL Age              FORMAT 999
COL Movie_ID         FORMAT 9999
COL Title            FORMAT A45
COL Description      FORMAT A40
COL Publishing_Studio FORMAT A25
COL Budget           FORMAT 9999999999
COL MPA              FORMAT A5
COL Rating_ID        FORMAT 9999
COL IMDB_Rating      FORMAT 99.9
COL Meta_Score       FORMAT 999
COL Popularity       FORMAT 9999.99
COL Release_ID       FORMAT 9999
COL Distribution_Locations FORMAT A30
COL Requirement_ID   FORMAT 9999
COL Department_ID    FORMAT 9999
COL Sound            FORMAT A20
COL Art              FORMAT A20
COL Writers          FORMAT A20
COL Editors          FORMAT A20
COL V_Effects        FORMAT A18
COL S_Effects        FORMAT A18
COL Members          FORMAT A25
COL History_of_projects  FORMAT A40
COL Respect_in_community FORMAT A25
COL Actor_ID         FORMAT 9999
COL Character_Name   FORMAT A25
COL Height           FORMAT 999.99

-- ============================================================
-- STEP 1: DROP ALL TABLES (reverse FK order)
-- ============================================================
DROP TABLE Actor                   CASCADE CONSTRAINTS;
DROP TABLE Director                CASCADE CONSTRAINTS;
DROP TABLE Production_Crew         CASCADE CONSTRAINTS;
DROP TABLE Department              CASCADE CONSTRAINTS;
DROP TABLE Production_Requirements CASCADE CONSTRAINTS;
DROP TABLE Production_Release      CASCADE CONSTRAINTS;
DROP TABLE Ratings                 CASCADE CONSTRAINTS;
DROP TABLE Movie                   CASCADE CONSTRAINTS;
DROP TABLE Person                  CASCADE CONSTRAINTS;

-- ============================================================
-- STEP 2: CREATE ALL TABLES
-- ============================================================

CREATE TABLE Person (
    Person_ID   NUMBER(10)    CONSTRAINT Person_ID_PK PRIMARY KEY,
    Fname       VARCHAR2(100) CONSTRAINT Person_Fname_NN NOT NULL,
    Mname       VARCHAR2(100),
    Lname       VARCHAR2(100) CONSTRAINT Person_Lname_NN NOT NULL,
    DOB         DATE,
    Age         NUMBER(3)     CONSTRAINT Person_Age_CHK
                    CHECK (Age >= 0 AND Age <= 120)
);

CREATE TABLE Movie (
    Movie_ID          NUMBER(10)    CONSTRAINT Movie_ID_PK PRIMARY KEY,
    Title             VARCHAR2(255) CONSTRAINT Movie_Title_NN NOT NULL,
    Description       VARCHAR2(1000),
    Publishing_Studio VARCHAR2(255) CONSTRAINT Movie_Studio_NN NOT NULL,
    Budget            NUMBER(15,2)  CONSTRAINT Movie_Budget_CHK
                          CHECK (Budget >= 0),
    MPA               VARCHAR2(10)  CONSTRAINT Movie_MPA_CHK
                          CHECK (MPA IN ('G','PG','PG-13','R','NC-17')),
    CONSTRAINT Movie_Title_UQ UNIQUE (Title)
);

CREATE TABLE Ratings (
    Rating_ID   NUMBER(10)   CONSTRAINT Ratings_ID_PK PRIMARY KEY,
    Movie_ID    NUMBER(10)   CONSTRAINT Ratings_MovieID_NN NOT NULL,
    IMDB_Rating NUMBER(3,1)  CONSTRAINT Ratings_IMDB_CHK
                    CHECK (IMDB_Rating >= 0 AND IMDB_Rating <= 10),
    Meta_Score  NUMBER(3)    CONSTRAINT Ratings_Meta_CHK
                    CHECK (Meta_Score >= 0 AND Meta_Score <= 100),
    Popularity  NUMBER(10,2) CONSTRAINT Ratings_Pop_CHK
                    CHECK (Popularity >= 0),
    CONSTRAINT Ratings_MovieID_FK FOREIGN KEY (Movie_ID)
        REFERENCES Movie(Movie_ID)
);

CREATE TABLE Production_Release (
    Release_ID             NUMBER(10)    CONSTRAINT Release_ID_PK PRIMARY KEY,
    Movie_ID               NUMBER(10)    CONSTRAINT Release_MovieID_NN NOT NULL,
    Release_Date           DATE          CONSTRAINT Release_Date_NN NOT NULL,
    Distribution_Locations VARCHAR2(500),
    CONSTRAINT Release_MovieID_FK FOREIGN KEY (Movie_ID)
        REFERENCES Movie(Movie_ID)
);

CREATE TABLE Production_Requirements (
    Requirement_ID NUMBER(10)     CONSTRAINT Req_ID_PK PRIMARY KEY,
    Movie_ID       NUMBER(10)     CONSTRAINT Req_MovieID_NN NOT NULL,
    Description    VARCHAR2(1000) CONSTRAINT Req_Desc_NN NOT NULL,
    CONSTRAINT Req_MovieID_FK FOREIGN KEY (Movie_ID)
        REFERENCES Movie(Movie_ID)
);

CREATE TABLE Department (
    Department_ID NUMBER(10) CONSTRAINT Dept_ID_PK PRIMARY KEY,
    Sound         VARCHAR2(100),
    Art           VARCHAR2(100),
    Writers       VARCHAR2(100),
    Editors       VARCHAR2(100),
    V_Effects     VARCHAR2(100),
    S_Effects     VARCHAR2(100)
);

CREATE TABLE Production_Crew (
    Person_ID      NUMBER(10)   CONSTRAINT Crew_PersonID_NN NOT NULL,
    Department_ID  NUMBER(10)   CONSTRAINT Crew_DeptID_NN NOT NULL,
    Requirement_ID NUMBER(10),
    Members        VARCHAR2(255),
    CONSTRAINT Crew_PK PRIMARY KEY (Person_ID, Department_ID),
    CONSTRAINT Crew_PersonID_FK FOREIGN KEY (Person_ID)
        REFERENCES Person(Person_ID),
    CONSTRAINT Crew_DeptID_FK FOREIGN KEY (Department_ID)
        REFERENCES Department(Department_ID),
    CONSTRAINT Crew_ReqID_FK FOREIGN KEY (Requirement_ID)
        REFERENCES Production_Requirements(Requirement_ID)
);

CREATE TABLE Director (
    Person_ID            NUMBER(10) CONSTRAINT Dir_ID_PK PRIMARY KEY,
    Movie_ID             NUMBER(10) CONSTRAINT Dir_MovieID_NN NOT NULL,
    Age                  NUMBER(3)  CONSTRAINT Dir_Age_CHK
                             CHECK (Age >= 18 AND Age <= 120),
    History_of_projects  VARCHAR2(500),
    Respect_in_community VARCHAR2(250),
    CONSTRAINT Dir_PersonID_FK FOREIGN KEY (Person_ID)
        REFERENCES Person(Person_ID),
    CONSTRAINT Dir_MovieID_FK FOREIGN KEY (Movie_ID)
        REFERENCES Movie(Movie_ID)
);

CREATE TABLE Actor (
    Actor_ID       NUMBER(10)    CONSTRAINT Actor_ID_PK PRIMARY KEY,
    Person_ID      NUMBER(10)    CONSTRAINT Actor_PersonID_NN NOT NULL,
    Movie_ID       NUMBER(10)    CONSTRAINT Actor_MovieID_NN NOT NULL,
    Character_Name VARCHAR2(255) CONSTRAINT Actor_CharName_NN NOT NULL,
    Height         NUMBER(5,2)   CONSTRAINT Actor_Height_CHK CHECK (Height > 0),
    Age            NUMBER(3)     CONSTRAINT Actor_Age_CHK
                       CHECK (Age >= 0 AND Age <= 120),
    CONSTRAINT Actor_PersonID_FK FOREIGN KEY (Person_ID)
        REFERENCES Person(Person_ID),
    CONSTRAINT Actor_MovieID_FK FOREIGN KEY (Movie_ID)
        REFERENCES Movie(Movie_ID)
);


-- ============================================================
-- STEP 3: INSERT DATA
-- IMPORTANT: Person must be fully populated BEFORE any table
-- that has a FK pointing to Person (Director, Actor,
-- Production_Crew). All 60 Person rows are inserted here
-- in one block before any other inserts.
-- ============================================================

-- ------------------------------------------------------------
-- PERSON  (60 rows total)
--   IDs  1-10  : Directors
--   IDs 11-30  : Actors (2 per movie)
--   IDs 31-40  : Crew – Directors of Photography
--   IDs 41-50  : Crew – Film Editors
--   IDs 51-60  : Crew – Sound Designers
-- ------------------------------------------------------------

-- Directors
INSERT INTO Person VALUES (1,  'Christopher', NULL,      'Nolan',          TO_DATE('1970-07-30','YYYY-MM-DD'), 54);
INSERT INTO Person VALUES (2,  'Matt',        NULL,      'Reeves',         TO_DATE('1966-04-27','YYYY-MM-DD'), 58);
INSERT INTO Person VALUES (3,  'Francis',     'Ford',    'Coppola',        TO_DATE('1939-04-07','YYYY-MM-DD'), 85);
INSERT INTO Person VALUES (4,  'Peter',       NULL,      'Jackson',        TO_DATE('1961-10-31','YYYY-MM-DD'), 63);
INSERT INTO Person VALUES (5,  'Quentin',     NULL,      'Tarantino',      TO_DATE('1963-03-27','YYYY-MM-DD'), 61);
INSERT INTO Person VALUES (6,  'Robert',      NULL,      'Zemeckis',       TO_DATE('1952-05-14','YYYY-MM-DD'), 72);
INSERT INTO Person VALUES (7,  'Hayao',       NULL,      'Miyazaki',       TO_DATE('1941-01-05','YYYY-MM-DD'), 83);
INSERT INTO Person VALUES (8,  'Bong',        NULL,      'Joon-ho',        TO_DATE('1969-09-14','YYYY-MM-DD'), 55);
INSERT INTO Person VALUES (9,  'John',        NULL,      'Lasseter',       TO_DATE('1957-01-12','YYYY-MM-DD'), 67);
INSERT INTO Person VALUES (10, 'Steven',      NULL,      'Spielberg',      TO_DATE('1946-12-18','YYYY-MM-DD'), 77);

-- Actors (2 per movie)
INSERT INTO Person VALUES (11, 'John',        NULL,      'David Washington', TO_DATE('1984-07-28','YYYY-MM-DD'), 40);
INSERT INTO Person VALUES (12, 'Robert',      NULL,      'Pattinson',        TO_DATE('1986-05-13','YYYY-MM-DD'), 38);
INSERT INTO Person VALUES (13, 'Robert',      NULL,      'Pattinson',        TO_DATE('1986-05-13','YYYY-MM-DD'), 38);
INSERT INTO Person VALUES (14, 'Zoe',         NULL,      'Kravitz',          TO_DATE('1988-12-01','YYYY-MM-DD'), 36);
INSERT INTO Person VALUES (15, 'Marlon',      NULL,      'Brando',           TO_DATE('1924-04-03','YYYY-MM-DD'), 80);
INSERT INTO Person VALUES (16, 'Al',          NULL,      'Pacino',           TO_DATE('1940-04-25','YYYY-MM-DD'), 84);
INSERT INTO Person VALUES (17, 'Elijah',      NULL,      'Wood',             TO_DATE('1981-01-28','YYYY-MM-DD'), 43);
INSERT INTO Person VALUES (18, 'Viggo',       NULL,      'Mortensen',        TO_DATE('1958-10-20','YYYY-MM-DD'), 66);
INSERT INTO Person VALUES (19, 'John',        NULL,      'Travolta',         TO_DATE('1954-02-18','YYYY-MM-DD'), 70);
INSERT INTO Person VALUES (20, 'Samuel',      'L.',      'Jackson',          TO_DATE('1948-12-21','YYYY-MM-DD'), 76);
INSERT INTO Person VALUES (21, 'Tom',         NULL,      'Hanks',            TO_DATE('1956-07-09','YYYY-MM-DD'), 67);
INSERT INTO Person VALUES (22, 'Robin',       NULL,      'Wright',           TO_DATE('1966-04-08','YYYY-MM-DD'), 58);
INSERT INTO Person VALUES (23, 'Daveigh',     NULL,      'Chase',            TO_DATE('1990-07-24','YYYY-MM-DD'), 34);
INSERT INTO Person VALUES (24, 'Suzanne',     NULL,      'Pleshette',        TO_DATE('1937-01-31','YYYY-MM-DD'), 70);
INSERT INTO Person VALUES (25, 'Choi',        NULL,      'Woo-shik',         TO_DATE('1990-12-26','YYYY-MM-DD'), 34);
INSERT INTO Person VALUES (26, 'Park',        NULL,      'So-dam',           TO_DATE('1991-09-08','YYYY-MM-DD'), 33);
INSERT INTO Person VALUES (27, 'Tom',         NULL,      'Hanks',            TO_DATE('1956-07-09','YYYY-MM-DD'), 67);
INSERT INTO Person VALUES (28, 'Tim',         NULL,      'Allen',            TO_DATE('1953-06-13','YYYY-MM-DD'), 71);
INSERT INTO Person VALUES (29, 'Sam',         NULL,      'Neill',            TO_DATE('1947-09-14','YYYY-MM-DD'), 77);
INSERT INTO Person VALUES (30, 'Jeff',        NULL,      'Goldblum',         TO_DATE('1952-10-22','YYYY-MM-DD'), 72);

-- Crew: Directors of Photography
INSERT INTO Person VALUES (31, 'Hoyte',       NULL,      'van Hoytema',      TO_DATE('1971-10-04','YYYY-MM-DD'), 53);
INSERT INTO Person VALUES (32, 'Greig',       NULL,      'Fraser',           TO_DATE('1975-10-03','YYYY-MM-DD'), 49);
INSERT INTO Person VALUES (33, 'Gordon',      NULL,      'Willis',           TO_DATE('1931-05-28','YYYY-MM-DD'), 93);
INSERT INTO Person VALUES (34, 'Andrew',      NULL,      'Lesnie',           TO_DATE('1956-03-01','YYYY-MM-DD'), 68);
INSERT INTO Person VALUES (35, 'Andrzej',     NULL,      'Sekula',           TO_DATE('1954-07-18','YYYY-MM-DD'), 70);
INSERT INTO Person VALUES (36, 'Don',         NULL,      'Burgess',          TO_DATE('1956-01-01','YYYY-MM-DD'), 68);
INSERT INTO Person VALUES (37, 'Atsushi',     NULL,      'Okui',             TO_DATE('1959-01-01','YYYY-MM-DD'), 65);
INSERT INTO Person VALUES (38, 'Hong',        NULL,      'Kyung-pyo',        TO_DATE('1975-01-01','YYYY-MM-DD'), 49);
INSERT INTO Person VALUES (39, 'Sharon',      NULL,      'Calahan',          TO_DATE('1960-01-01','YYYY-MM-DD'), 64);
INSERT INTO Person VALUES (40, 'Janusz',      NULL,      'Kaminski',         TO_DATE('1959-06-27','YYYY-MM-DD'), 65);

-- Crew: Film Editors
INSERT INTO Person VALUES (41, 'Jennifer',    NULL,      'Lame',             TO_DATE('1980-01-01','YYYY-MM-DD'), 44);
INSERT INTO Person VALUES (42, 'William',     NULL,      'Hoy',              TO_DATE('1958-01-01','YYYY-MM-DD'), 66);
INSERT INTO Person VALUES (43, 'William',     NULL,      'Reynolds',         TO_DATE('1910-06-18','YYYY-MM-DD'), 93);
INSERT INTO Person VALUES (44, 'Jamie',       NULL,      'Selkirk',          TO_DATE('1952-01-01','YYYY-MM-DD'), 72);
INSERT INTO Person VALUES (45, 'Sally',       NULL,      'Menke',            TO_DATE('1953-12-17','YYYY-MM-DD'), 70);
INSERT INTO Person VALUES (46, 'Arthur',      NULL,      'Schmidt',          TO_DATE('1936-01-01','YYYY-MM-DD'), 88);
INSERT INTO Person VALUES (47, 'Takeshi',     NULL,      'Seyama',           TO_DATE('1958-01-01','YYYY-MM-DD'), 66);
INSERT INTO Person VALUES (48, 'Yang',        NULL,      'Jin-mo',           TO_DATE('1971-01-01','YYYY-MM-DD'), 53);
INSERT INTO Person VALUES (49, 'Robert',      NULL,      'Gordon',           TO_DATE('1955-01-01','YYYY-MM-DD'), 69);
INSERT INTO Person VALUES (50, 'Michael',     NULL,      'Kahn',             TO_DATE('1935-12-08','YYYY-MM-DD'), 89);

-- Crew: Sound Designers
INSERT INTO Person VALUES (51, 'Richard',     NULL,      'King',             TO_DATE('1962-01-01','YYYY-MM-DD'), 62);
INSERT INTO Person VALUES (52, 'David',       NULL,      'Chessel',          TO_DATE('1974-01-01','YYYY-MM-DD'), 50);
INSERT INTO Person VALUES (53, 'Walter',      NULL,      'Murch',            TO_DATE('1943-07-12','YYYY-MM-DD'), 81);
INSERT INTO Person VALUES (54, 'Christopher', NULL,      'Boyes',            TO_DATE('1959-01-01','YYYY-MM-DD'), 65);
INSERT INTO Person VALUES (55, 'Stephen',     NULL,      'Berger',           TO_DATE('1960-01-01','YYYY-MM-DD'), 64);
INSERT INTO Person VALUES (56, 'Randy',       NULL,      'Thom',             TO_DATE('1953-01-01','YYYY-MM-DD'), 71);
INSERT INTO Person VALUES (57, 'Kazuhiro',    NULL,      'Wakabayashi',      TO_DATE('1965-01-01','YYYY-MM-DD'), 59);
INSERT INTO Person VALUES (58, 'Moo-Hyun',    NULL,      'Choi',             TO_DATE('1972-01-01','YYYY-MM-DD'), 52);
INSERT INTO Person VALUES (59, 'Gary',        NULL,      'Rydstrom',         TO_DATE('1959-06-15','YYYY-MM-DD'), 65);
INSERT INTO Person VALUES (60, 'Gary',        NULL,      'Summers',          TO_DATE('1952-01-01','YYYY-MM-DD'), 72);

-- ------------------------------------------------------------
-- MOVIE  (10 rows)
-- ------------------------------------------------------------
INSERT INTO Movie VALUES (1,  'Tenet',
    'A secret agent embarks on a dangerous mission to prevent World War III using time inversion.',
    'Warner Bros. Pictures', 205000000, 'PG-13');
INSERT INTO Movie VALUES (2,  'The Batman',
    'Batman ventures into Gotham City''s underworld when a sadistic killer leaves behind a trail of cryptic clues.',
    'Warner Bros. Pictures', 185000000, 'PG-13');
INSERT INTO Movie VALUES (3,  'The Godfather',
    'The aging patriarch of an organized crime dynasty transfers control to his reluctant son.',
    'Paramount Pictures', 6000000, 'R');
INSERT INTO Movie VALUES (4,  'The Lord of the Rings: The Return of the King',
    'Gandalf and Aragorn lead the World of Men against Sauron''s army to draw the Dark Lord''s gaze from Frodo.',
    'New Line Cinema', 94000000, 'PG-13');
INSERT INTO Movie VALUES (5,  'Pulp Fiction',
    'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in tales of violence and redemption.',
    'Miramax Films', 8000000, 'R');
INSERT INTO Movie VALUES (6,  'Forrest Gump',
    'The presidencies of Kennedy and Johnson, Vietnam and more through the eyes of an Alabama man with an IQ of 75.',
    'Paramount Pictures', 55000000, 'PG-13');
INSERT INTO Movie VALUES (7,  'Spirited Away',
    'A sullen girl wanders into a world ruled by gods, witches, and spirits, where humans are transformed into animals.',
    'Toho', 19000000, 'PG');
INSERT INTO Movie VALUES (8,  'Parasite',
    'Greed and class discrimination threaten the newly formed symbiotic relationship between the wealthy Park family and the poor Kim family.',
    'CJ Entertainment', 11400000, 'R');
INSERT INTO Movie VALUES (9,  'Toy Story',
    'A cowboy doll is profoundly threatened and jealous when a new spaceman figure supplants him as top toy.',
    'Walt Disney Pictures', 30000000, 'G');
INSERT INTO Movie VALUES (10, 'Jurassic Park',
    'A pragmatic paleontologist visiting an almost complete theme park is tasked with protecting a couple of kids after a power failure.',
    'Universal Pictures', 63000000, 'PG-13');

-- ------------------------------------------------------------
-- RATINGS  (10 rows)
-- ------------------------------------------------------------
INSERT INTO Ratings VALUES (1,  1,  7.3,  69,  3.40);
INSERT INTO Ratings VALUES (2,  2,  7.8,  72,  5.20);
INSERT INTO Ratings VALUES (3,  3,  9.2,  100, 9.80);
INSERT INTO Ratings VALUES (4,  4,  9.0,  94,  9.50);
INSERT INTO Ratings VALUES (5,  5,  8.9,  94,  9.20);
INSERT INTO Ratings VALUES (6,  6,  8.8,  82,  8.60);
INSERT INTO Ratings VALUES (7,  7,  8.6,  96,  8.30);
INSERT INTO Ratings VALUES (8,  8,  8.5,  96,  8.40);
INSERT INTO Ratings VALUES (9,  9,  8.3,  95,  7.90);
INSERT INTO Ratings VALUES (10, 10, 8.2,  68,  7.70);

-- ------------------------------------------------------------
-- PRODUCTION_RELEASE  (10 rows)
-- ------------------------------------------------------------
INSERT INTO Production_Release VALUES (1,  1,  TO_DATE('2020-09-03','YYYY-MM-DD'), 'Worldwide');
INSERT INTO Production_Release VALUES (2,  2,  TO_DATE('2022-03-04','YYYY-MM-DD'), 'Worldwide');
INSERT INTO Production_Release VALUES (3,  3,  TO_DATE('1972-03-24','YYYY-MM-DD'), 'United States');
INSERT INTO Production_Release VALUES (4,  4,  TO_DATE('2003-12-17','YYYY-MM-DD'), 'Worldwide');
INSERT INTO Production_Release VALUES (5,  5,  TO_DATE('1994-10-14','YYYY-MM-DD'), 'United States');
INSERT INTO Production_Release VALUES (6,  6,  TO_DATE('1994-07-06','YYYY-MM-DD'), 'United States');
INSERT INTO Production_Release VALUES (7,  7,  TO_DATE('2001-07-20','YYYY-MM-DD'), 'Japan, Worldwide');
INSERT INTO Production_Release VALUES (8,  8,  TO_DATE('2019-05-30','YYYY-MM-DD'), 'South Korea, Worldwide');
INSERT INTO Production_Release VALUES (9,  9,  TO_DATE('1995-11-22','YYYY-MM-DD'), 'United States');
INSERT INTO Production_Release VALUES (10, 10, TO_DATE('1993-06-11','YYYY-MM-DD'), 'United States');

-- ------------------------------------------------------------
-- PRODUCTION_REQUIREMENTS  (10 rows)
-- ------------------------------------------------------------
INSERT INTO Production_Requirements VALUES (1,  1,  'Time inversion rigs, practical effects, IMAX cameras, large-scale practical stunts');
INSERT INTO Production_Requirements VALUES (2,  2,  'Gotham City sets, rain/weather rigs, stunt coordinators, custom Batsuit fabrication');
INSERT INTO Production_Requirements VALUES (3,  3,  'Period-accurate 1940s props, location shoots in New York, large mob ensemble cast');
INSERT INTO Production_Requirements VALUES (4,  4,  'New Zealand location shoots, large-scale battle sequences, motion capture for Gollum');
INSERT INTO Production_Requirements VALUES (5,  5,  'LA location permits, ensemble coordination, vintage 1990s props and vehicles');
INSERT INTO Production_Requirements VALUES (6,  6,  'Visual effects for historical footage integration, feather VFX, period costumes 1950s-1980s');
INSERT INTO Production_Requirements VALUES (7,  7,  'Hand-drawn 2D animation, traditional cel production, original score recording');
INSERT INTO Production_Requirements VALUES (8,  8,  'Seoul location permits, dual-family set construction, Korean production crew');
INSERT INTO Production_Requirements VALUES (9,  9,  'RenderMan CGI pipeline, voice recording studio, early PIXAR animation tools');
INSERT INTO Production_Requirements VALUES (10, 10, 'Animatronic dinosaurs, Stan Winston practical effects, jungle location shoots in Hawaii');

-- ------------------------------------------------------------
-- DEPARTMENT  (10 rows)
-- NULL used where a department role did not apply to that film.
-- ------------------------------------------------------------
INSERT INTO Department VALUES (1,  'Richard King',         'Nathan Crowley',   'Christopher Nolan', 'Jennifer Lame',    'Andrew Jackson',  'Scott Fisher');
INSERT INTO Department VALUES (2,  'David Chessel',        'James Chinlund',   'Matt Reeves',       'William Hoy',      'Dan Lemmon',      'Dominic Tuohy');
INSERT INTO Department VALUES (3,  'Walter Murch',         'Dean Tavoularis',  'Mario Puzo',        'William Reynolds', NULL,              NULL);
INSERT INTO Department VALUES (4,  'Christopher Boyes',    'Grant Major',      'Fran Walsh',        'Jamie Selkirk',    'Richard Taylor',  'Chris Corbould');
INSERT INTO Department VALUES (5,  'Stephen Berger',       'David Wasco',      'Quentin Tarantino', 'Sally Menke',      NULL,              NULL);
INSERT INTO Department VALUES (6,  'Randy Thom',           'Rick Carter',      'Eric Roth',         'Arthur Schmidt',   'Ken Ralston',     NULL);
INSERT INTO Department VALUES (7,  'Kazuhiro Wakabayashi', 'Noboru Yoshida',   'Hayao Miyazaki',    'Takeshi Seyama',   NULL,              NULL);
INSERT INTO Department VALUES (8,  'Moo-Hyun Choi',        'Lee Ha-jun',       'Bong Joon-ho',      'Yang Jin-mo',      NULL,              NULL);
INSERT INTO Department VALUES (9,  'Gary Rydstrom',        'Ralph Eggleston',  'John Lasseter',     'Robert Gordon',    NULL,              NULL);
INSERT INTO Department VALUES (10, 'Gary Summers',         'Rick Carter',      'Michael Crichton',  'Michael Kahn',     'Dennis Muren',    'Stan Winston');

-- ------------------------------------------------------------
-- PRODUCTION_CREW  (30 rows — 3 roles per movie)
-- All Person_IDs 31-60 now exist in Person before this runs.
-- ------------------------------------------------------------

-- Movie 1: Tenet
INSERT INTO Production_Crew VALUES (31, 1, 1, 'Director of Photography');
INSERT INTO Production_Crew VALUES (41, 1, 1, 'Film Editor');
INSERT INTO Production_Crew VALUES (51, 1, 1, 'Sound Designer');
-- Movie 2: The Batman
INSERT INTO Production_Crew VALUES (32, 2, 2, 'Director of Photography');
INSERT INTO Production_Crew VALUES (42, 2, 2, 'Film Editor');
INSERT INTO Production_Crew VALUES (52, 2, 2, 'Sound Designer');
-- Movie 3: The Godfather
INSERT INTO Production_Crew VALUES (33, 3, 3, 'Director of Photography');
INSERT INTO Production_Crew VALUES (43, 3, 3, 'Film Editor');
INSERT INTO Production_Crew VALUES (53, 3, 3, 'Sound Designer');
-- Movie 4: The Lord of the Rings: The Return of the King
INSERT INTO Production_Crew VALUES (34, 4, 4, 'Director of Photography');
INSERT INTO Production_Crew VALUES (44, 4, 4, 'Film Editor');
INSERT INTO Production_Crew VALUES (54, 4, 4, 'Sound Designer');
-- Movie 5: Pulp Fiction
INSERT INTO Production_Crew VALUES (35, 5, 5, 'Director of Photography');
INSERT INTO Production_Crew VALUES (45, 5, 5, 'Film Editor');
INSERT INTO Production_Crew VALUES (55, 5, 5, 'Sound Designer');
-- Movie 6: Forrest Gump
INSERT INTO Production_Crew VALUES (36, 6, 6, 'Director of Photography');
INSERT INTO Production_Crew VALUES (46, 6, 6, 'Film Editor');
INSERT INTO Production_Crew VALUES (56, 6, 6, 'Sound Designer');
-- Movie 7: Spirited Away
INSERT INTO Production_Crew VALUES (37, 7, 7, 'Director of Photography');
INSERT INTO Production_Crew VALUES (47, 7, 7, 'Film Editor');
INSERT INTO Production_Crew VALUES (57, 7, 7, 'Sound Designer');
-- Movie 8: Parasite
INSERT INTO Production_Crew VALUES (38, 8, 8, 'Director of Photography');
INSERT INTO Production_Crew VALUES (48, 8, 8, 'Film Editor');
INSERT INTO Production_Crew VALUES (58, 8, 8, 'Sound Designer');
-- Movie 9: Toy Story
INSERT INTO Production_Crew VALUES (39, 9, 9, 'Director of Photography');
INSERT INTO Production_Crew VALUES (49, 9, 9, 'Film Editor');
INSERT INTO Production_Crew VALUES (59, 9, 9, 'Sound Designer');
-- Movie 10: Jurassic Park
INSERT INTO Production_Crew VALUES (40, 10, 10, 'Director of Photography');
INSERT INTO Production_Crew VALUES (50, 10, 10, 'Film Editor');
INSERT INTO Production_Crew VALUES (60, 10, 10, 'Sound Designer');

-- ------------------------------------------------------------
-- DIRECTOR  (10 rows)
-- ------------------------------------------------------------
INSERT INTO Director VALUES (1,  1,  54, 'Memento, Inception, Interstellar, Dunkirk',                    'Highly respected auteur');
INSERT INTO Director VALUES (2,  2,  58, 'Cloverfield, Dawn of the Planet of the Apes',                  'Acclaimed genre filmmaker');
INSERT INTO Director VALUES (3,  3,  85, 'The Godfather I-III, Apocalypse Now, Bram Stoker''s Dracula',  'Hollywood legend');
INSERT INTO Director VALUES (4,  4,  63, 'Heavenly Creatures, Lord of the Rings Trilogy, The Hobbit',    'Pioneered digital filmmaking');
INSERT INTO Director VALUES (5,  5,  61, 'Reservoir Dogs, Jackie Brown, Kill Bill, Django Unchained',    'Cult cinema icon');
INSERT INTO Director VALUES (6,  6,  72, 'Back to the Future trilogy, Cast Away, The Polar Express',     'Box office visionary');
INSERT INTO Director VALUES (7,  7,  83, 'My Neighbor Totoro, Princess Mononoke, Howl''s Moving Castle', 'Legendary animator');
INSERT INTO Director VALUES (8,  8,  55, 'Memories of Murder, The Host, Snowpiercer',                    'Academy Award winner');
INSERT INTO Director VALUES (9,  9,  67, 'A Bug''s Life, Cars, Toy Story 1-2',                          'Pioneer of CGI animation');
INSERT INTO Director VALUES (10, 10, 77, 'Jaws, E.T., Schindler''s List, Saving Private Ryan',          'Greatest living director');

-- ------------------------------------------------------------
-- ACTOR  (20 rows — 2 per movie)
-- ------------------------------------------------------------
-- Movie 1: Tenet
INSERT INTO Actor VALUES (1,  11, 1,  'The Protagonist',        182.88, 40);
INSERT INTO Actor VALUES (2,  12, 1,  'Neil',                   185.42, 38);
-- Movie 2: The Batman
INSERT INTO Actor VALUES (3,  13, 2,  'Bruce Wayne / Batman',   185.42, 38);
INSERT INTO Actor VALUES (4,  14, 2,  'Selina Kyle / Catwoman', 168.00, 36);
-- Movie 3: The Godfather
INSERT INTO Actor VALUES (5,  15, 3,  'Vito Corleone',          175.00, 80);
INSERT INTO Actor VALUES (6,  16, 3,  'Michael Corleone',       177.00, 84);
-- Movie 4: The Lord of the Rings: The Return of the King
INSERT INTO Actor VALUES (7,  17, 4,  'Frodo Baggins',          163.00, 43);
INSERT INTO Actor VALUES (8,  18, 4,  'Aragorn',                180.00, 66);
-- Movie 5: Pulp Fiction
INSERT INTO Actor VALUES (9,  19, 5,  'Vincent Vega',           188.00, 70);
INSERT INTO Actor VALUES (10, 20, 5,  'Jules Winnfield',        188.00, 76);
-- Movie 6: Forrest Gump
INSERT INTO Actor VALUES (11, 21, 6,  'Forrest Gump',           183.00, 67);
INSERT INTO Actor VALUES (12, 22, 6,  'Jenny Curran',           165.00, 58);
-- Movie 7: Spirited Away
INSERT INTO Actor VALUES (13, 23, 7,  'Chihiro Ogino (voice)',  NULL,   34);
INSERT INTO Actor VALUES (14, 24, 7,  'Yubaba (voice)',         NULL,   70);
-- Movie 8: Parasite
INSERT INTO Actor VALUES (15, 25, 8,  'Ki-woo Kim',             175.26, 34);
INSERT INTO Actor VALUES (16, 26, 8,  'Ki-jung Kim',            163.00, 33);
-- Movie 9: Toy Story
INSERT INTO Actor VALUES (17, 27, 9,  'Woody (voice)',          NULL,   67);
INSERT INTO Actor VALUES (18, 28, 9,  'Buzz Lightyear (voice)', NULL,   71);
-- Movie 10: Jurassic Park
INSERT INTO Actor VALUES (19, 29, 10, 'Dr. Alan Grant',         182.00, 77);
INSERT INTO Actor VALUES (20, 30, 10, 'Dr. Ian Malcolm',        196.00, 72);


-- =============================================================
-- PART 2 – 10 SQL QUERIES
-- =============================================================

-- ------------------------------------------------------------
-- Query 1: One-table query
-- List all movies that are rated PG-13 or R.
-- ------------------------------------------------------------
SELECT Title, MPA, Budget
FROM Movie
WHERE MPA IN ('PG-13', 'R')
ORDER BY Title;

-- ------------------------------------------------------------
-- Query 2: Two-table join
-- Show each movie with its IMDB rating.
-- ------------------------------------------------------------
SELECT m.Title, r.IMDB_Rating
FROM Movie m
JOIN Ratings r ON m.Movie_ID = r.Movie_ID
ORDER BY r.IMDB_Rating DESC;

-- ------------------------------------------------------------
-- Query 3: Two-table join
-- Show each movie with its release date.
-- ------------------------------------------------------------
SELECT m.Title, pr.Release_Date
FROM Movie m
JOIN Production_Release pr ON m.Movie_ID = pr.Movie_ID
ORDER BY pr.Release_Date ASC;

-- ------------------------------------------------------------
-- Query 4: Three-table join
-- Show each movie with its director's name.
-- ------------------------------------------------------------
SELECT m.Title, p.Fname, p.Lname
FROM Movie m
JOIN Director d ON m.Movie_ID = d.Movie_ID
JOIN Person p ON d.Person_ID = p.Person_ID
ORDER BY m.Title;

-- ------------------------------------------------------------
-- Query 5: Three-table join
-- Show each actor's name and the movie they appeared in.
-- ------------------------------------------------------------
SELECT p.Fname, p.Lname, a.Character_Name, m.Title
FROM Actor a
JOIN Person p ON a.Person_ID = p.Person_ID
JOIN Movie m ON a.Movie_ID = m.Movie_ID
ORDER BY m.Title;

-- ------------------------------------------------------------
-- Query 6: Four-table join
-- Show each actor, their character, their movie, and the
-- movie's IMDB rating.
-- ------------------------------------------------------------
SELECT p.Fname, p.Lname, a.Character_Name, m.Title, r.IMDB_Rating
FROM Actor a
JOIN Person p ON a.Person_ID = p.Person_ID
JOIN Movie m ON a.Movie_ID = m.Movie_ID
JOIN Ratings r ON m.Movie_ID = r.Movie_ID
ORDER BY r.IMDB_Rating DESC;

-- ------------------------------------------------------------
-- Query 7: Set operation - UNION
-- List all directors and all actors in one result set.
-- ------------------------------------------------------------
SELECT p.Fname, p.Lname, 'Director' AS Role
FROM Person p
JOIN Director d ON p.Person_ID = d.Person_ID
UNION
SELECT p.Fname, p.Lname, 'Actor' AS Role
FROM Person p
JOIN Actor a ON p.Person_ID = a.Person_ID
ORDER BY Role, Lname;

-- ------------------------------------------------------------
-- Query 8: Set operation - MINUS
-- Show all movies except ones rated G.
-- ------------------------------------------------------------
SELECT Title, MPA
FROM Movie
MINUS
SELECT Title, MPA
FROM Movie
WHERE MPA = 'G'
ORDER BY Title;

-- ------------------------------------------------------------
-- Query 9: Aggregate
-- Count how many movies each studio has and their average
-- IMDB rating.
-- ------------------------------------------------------------
SELECT m.Publishing_Studio, COUNT(*) AS Num_Movies, ROUND(AVG(r.IMDB_Rating), 1) AS Avg_IMDB
FROM Movie m
JOIN Ratings r ON m.Movie_ID = r.Movie_ID
GROUP BY m.Publishing_Studio
ORDER BY Avg_IMDB DESC;

-- ------------------------------------------------------------
-- Query 10: Aggregate
-- Show the total and average budget grouped by MPA rating.
-- ------------------------------------------------------------
SELECT MPA, COUNT(*) AS Num_Movies, SUM(Budget) AS Total_Budget, ROUND(AVG(Budget), 2) AS Avg_Budget
FROM Movie
GROUP BY MPA
ORDER BY Avg_Budget DESC;


-- =============================================================
-- VERIFICATION SELECTS (run each and screenshot for report)
-- =============================================================
SELECT * FROM Person;
SELECT * FROM Movie;
SELECT * FROM Ratings;
SELECT * FROM Production_Release;
SELECT * FROM Production_Requirements;
SELECT * FROM Department;
SELECT * FROM Production_Crew;
SELECT * FROM Director;
SELECT * FROM Actor;
