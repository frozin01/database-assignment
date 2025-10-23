/*
Acknowledgment of AI. 

We acknowledge that generative artificial intelligence was used to this assignment. 

- Tools used: Microsoft Copilot and ChatGPT (OpenAI GPT-5).
- URLs: https://chat. openai. https://copilot. com/. Microsoft. https://
- Usage: The tool was used to enhance constraints confirm alignment with the Entity-Relationship (ER) model and help create SQL Data Definition Language (DDL) statements. Additionally AI was used to create the dummy fictional data used in the INSERT statements in order to guarantee consistency and make testing easier for this assignment. The team carefully reviewed tested and made all necessary adjustments to the code to ensure that it was accurate and suitable for the task. We certify that our final submission fairly reflects our understanding and scholarly work. 

The following guidelines pertain to the use of artificial intelligence in academic tasks at the University of Sydney. 
https://www.sydney.edu.au/students/academic-integrity/artificial-intelligence.html 
*/ 


-- Sydney Music database

-- Drop if there are any existing objects

DROP TABLE IF EXISTS Contains CASCADE;
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Listens CASCADE;
DROP TABLE IF EXISTS Playlist CASCADE;
DROP TABLE IF EXISTS Contributes CASCADE;
DROP TABLE IF EXISTS Belongs CASCADE;
DROP TABLE IF EXISTS Genre CASCADE;
DROP TABLE IF EXISTS Track CASCADE;
DROP TABLE IF EXISTS Album CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Staff CASCADE;
DROP TABLE IF EXISTS Artist CASCADE;
DROP TABLE IF EXISTS MobileNumber CASCADE;
DROP TABLE IF EXISTS Person CASCADE;


-- Core entity: Person

CREATE TABLE Person (
    personId      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loginName     VARCHAR(64)  NOT NULL UNIQUE,
    email         VARCHAR(254) NOT NULL UNIQUE,
    password      VARCHAR(128) NOT NULL,
    fullName      VARCHAR(120) NOT NULL
);

-- Multiple mobile numbers per person.

CREATE TABLE MobileNumber (
    personId      BIGINT NOT NULL,
    mobileNumber  VARCHAR(20) NOT NULL, -- E.164 fits in 20
    PRIMARY KEY (personId, mobileNumber),
    CONSTRAINT uq_mobileNumber UNIQUE (mobileNumber),
    CONSTRAINT fk_mobile_person
      FOREIGN KEY (personId) REFERENCES Person(personId)
      ON DELETE CASCADE
);

-- Subtypes (ISA): Artist, Staff, Customer

CREATE TABLE Artist (
    personId  BIGINT PRIMARY KEY,
    CONSTRAINT fk_artist_person
      FOREIGN KEY (personId) REFERENCES Person(personId)
      ON DELETE CASCADE
);

CREATE TABLE Staff (
    personId     BIGINT PRIMARY KEY,
    compensation NUMERIC(12,2) NOT NULL CHECK (compensation > 0 AND compensation <= 200000),
    street       VARCHAR(120)  NOT NULL,
    city         VARCHAR(80)   NOT NULL,
    state        VARCHAR(80)   NOT NULL,
    zipCode      VARCHAR(16)   NOT NULL,
    CONSTRAINT fk_staff_person
      FOREIGN KEY (personId) REFERENCES Person(personId)
      ON DELETE CASCADE
);

CREATE TABLE Customer (
    personId     BIGINT PRIMARY KEY,
    dateOfBirth  DATE NOT NULL,
    CONSTRAINT fk_customer_person
      FOREIGN KEY (personId) REFERENCES Person(personId)
      ON DELETE CASCADE
);

-- Music catalog

CREATE TABLE Album (
    albumId    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    albumName  VARCHAR(160) NOT NULL,
    CONSTRAINT uq_album_name UNIQUE (albumName)
);

CREATE TABLE Track (
    trackId   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    title     VARCHAR(200) NOT NULL,
    duration  INTEGER NOT NULL CHECK (duration > 0),
    minAge    INT NOT NULL DEFAULT 0 CHECK (minAge >= 0) -- age restriction
);

-- Track can have multiple genres

CREATE TABLE Genre (
    trackId BIGINT NOT NULL,
    genre   VARCHAR(60) NOT NULL,
    PRIMARY KEY (trackId, genre),
    CONSTRAINT fk_genre_track
      FOREIGN KEY (trackId) REFERENCES Track(trackId)
      ON DELETE CASCADE
);

-- Track can belong to multiple albums; popularity per album

CREATE TABLE Belongs (
    trackId   BIGINT NOT NULL,
    albumId   BIGINT NOT NULL,
    isPopular BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (trackId, albumId),
    CONSTRAINT fk_belongs_track
      FOREIGN KEY (trackId) REFERENCES Track(trackId)
      ON DELETE CASCADE,
    CONSTRAINT fk_belongs_album
      FOREIGN KEY (albumId) REFERENCES Album(albumId)
      ON DELETE CASCADE
);

-- Artists can contribute to tracks with a role

CREATE TABLE Contributes (
    artistId BIGINT NOT NULL,   -- references Artist.personId
    trackId  BIGINT NOT NULL,
    role     VARCHAR(80) NOT NULL,
    PRIMARY KEY (artistId, trackId),
    CONSTRAINT fk_contrib_artist
      FOREIGN KEY (artistId) REFERENCES Artist(personId)
      ON DELETE CASCADE,
    CONSTRAINT fk_contrib_track
      FOREIGN KEY (trackId) REFERENCES Track(trackId)
      ON DELETE CASCADE
);

-- Customers can create playlists

CREATE TABLE Playlist (
    customerId   BIGINT NOT NULL,
    playlistName VARCHAR(120) NOT NULL,
    PRIMARY KEY (customerId, playlistName),
    CONSTRAINT fk_playlist_customer
      FOREIGN KEY (customerId) REFERENCES Customer(personId)
      ON DELETE CASCADE
);

-- A playlist contains tracks with an explicit order

CREATE TABLE Contains (
    playlistName VARCHAR(120) NOT NULL,
    customerId   BIGINT NOT NULL,
    trackId      BIGINT NOT NULL,
    orderNumber  INTEGER NOT NULL CHECK (orderNumber >= 1),
    PRIMARY KEY (playlistName, customerId, trackId),
    CONSTRAINT fk_contains_playlist
      FOREIGN KEY (customerId, playlistName)
      REFERENCES Playlist(customerId, playlistName)
      ON DELETE CASCADE,
    CONSTRAINT fk_contains_track
      FOREIGN KEY (trackId) REFERENCES Track(trackId)
      ON DELETE CASCADE
);

-- Listening counters per customer & track

CREATE TABLE Listens (
    customerId  BIGINT NOT NULL,
    trackId     BIGINT NOT NULL,
    dateListen  DATE   NOT NULL,
    countListen INTEGER NOT NULL DEFAULT 1 CHECK (countListen >= 1),
    PRIMARY KEY (customerId, trackId),
    CONSTRAINT fk_listens_customer
      FOREIGN KEY (customerId) REFERENCES Customer(personId)
      ON DELETE CASCADE,
    CONSTRAINT fk_listens_track
      FOREIGN KEY (trackId) REFERENCES Track(trackId)
      ON DELETE CASCADE
);

-- Reviews are removable by staff

CREATE TABLE Review (
    reviewId        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trackId         BIGINT NOT NULL,
    dateTimeCreated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    rating          INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    shortReview     VARCHAR(1000),
    customerId      BIGINT NOT NULL,
    dateTimeRemoved TIMESTAMPTZ,
    reason          VARCHAR(500),
    staffId         BIGINT,
    CONSTRAINT fk_review_track
      FOREIGN KEY (trackId) REFERENCES Track(trackId)
      ON DELETE CASCADE,
    CONSTRAINT fk_review_customer
      FOREIGN KEY (customerId) REFERENCES Customer(personId)
      ON DELETE CASCADE,
    CONSTRAINT fk_review_staff
      FOREIGN KEY (staffId) REFERENCES Staff(personId)
      ON DELETE SET NULL,
    CONSTRAINT uq_review_unique_once UNIQUE (customerId, trackId)
);


-- Sample Data


-- People

INSERT INTO Person (loginName, email, password, fullName) VALUES
  ('alice',  'alice@example.com',  'hashed_pw_1', 'Alice Nguyen'),
  ('bob',    'bob@example.com',    'hashed_pw_2', 'Bob Rivera'),
  ('sam',    'sam@example.com',    'hashed_pw_3', 'Samantha Lee'),
  ('diana',  'diana@example.com',  'hashed_pw_4', 'Diana Singh'),
  ('marco',  'marco@example.com',  'hashed_pw_5', 'Marco Chen');

-- Mobile numbers

INSERT INTO MobileNumber (personId, mobileNumber)
SELECT personId, num FROM (
  VALUES
    ((SELECT personId FROM Person WHERE loginName='alice'), '+61-400-000-001'),
    ((SELECT personId FROM Person WHERE loginName='bob'),   '+61-400-000-002'),
    ((SELECT personId FROM Person WHERE loginName='sam'),   '+61-400-000-003'),
    ((SELECT personId FROM Person WHERE loginName='diana'), '+61-400-000-004'),
    ((SELECT personId FROM Person WHERE loginName='marco'), '+61-400-000-005')
) AS t(personId, num);

-- Roles

INSERT INTO Customer (personId, dateOfBirth) VALUES
  ((SELECT personId FROM Person WHERE loginName='alice'), DATE '1999-05-20'),
  ((SELECT personId FROM Person WHERE loginName='diana'), DATE '2002-11-03');

INSERT INTO Artist (personId) VALUES
  ((SELECT personId FROM Person WHERE loginName='bob')),
  ((SELECT personId FROM Person WHERE loginName='marco'));

INSERT INTO Staff (personId, compensation, street, city, state, zipCode) VALUES
  ((SELECT personId FROM Person WHERE loginName='sam'), 85000.00, '12 High St', 'Sydney', 'NSW', '2000');

-- Catalogs

INSERT INTO Album (albumName) VALUES
  ('Blue Sky'),
  ('Evening Haze'),
  ('Neon Nights');

INSERT INTO Track (title, duration, minAge) VALUES
  ('Shine On',        210, 0),   -- all ages
  ('Harbor Lights',   185, 0),   -- all ages
  ('City Pulse',      242, 18),  -- adult only
  ('Midnight Echoes', 199, 16);  -- 16+

-- Track genres

INSERT INTO Genre (trackId, genre) VALUES
  ((SELECT trackId FROM Track WHERE title='Shine On'),        'Pop'),
  ((SELECT trackId FROM Track WHERE title='Harbor Lights'),   'Indie'),
  ((SELECT trackId FROM Track WHERE title='City Pulse'),      'Electronic'),
  ((SELECT trackId FROM Track WHERE title='Midnight Echoes'), 'Synthwave'),
  ((SELECT trackId FROM Track WHERE title='Midnight Echoes'), 'Electronic');

-- Track belongs to album

INSERT INTO Belongs (trackId, albumId, isPopular) VALUES
  ((SELECT trackId FROM Track WHERE title='Shine On'),
   (SELECT albumId FROM Album WHERE albumName='Blue Sky'),
   TRUE),
  ((SELECT trackId FROM Track WHERE title='Harbor Lights'),
   (SELECT albumId FROM Album WHERE albumName='Evening Haze'),
   FALSE),
  ((SELECT trackId FROM Track WHERE title='City Pulse'),
   (SELECT albumId FROM Album WHERE albumName='Neon Nights'),
   TRUE),
  ((SELECT trackId FROM Track WHERE title='Midnight Echoes'),
   (SELECT albumId FROM Album WHERE albumName='Neon Nights'),
   FALSE);

-- Artist contributions

INSERT INTO Contributes (artistId, trackId, role) VALUES
  ((SELECT personId FROM Person WHERE loginName='bob'),
   (SELECT trackId FROM Track WHERE title='Shine On'),
   'Vocalist'),
  ((SELECT personId FROM Person WHERE loginName='marco'),
   (SELECT trackId FROM Track WHERE title='City Pulse'),
   'Producer'),
  ((SELECT personId FROM Person WHERE loginName='bob'),
   (SELECT trackId FROM Track WHERE title='City Pulse'),
   'Featuring Artist'),
  ((SELECT personId FROM Person WHERE loginName='marco'),
   (SELECT trackId FROM Track WHERE title='Midnight Echoes'),
   'Composer');

-- Listening

INSERT INTO Listens (customerId, trackId, dateListen, countListen) VALUES
  ((SELECT personId FROM Person WHERE loginName='alice'),
   (SELECT trackId FROM Track WHERE title='Shine On'),
   CURRENT_DATE - INTERVAL '1 day',
   3),
  ((SELECT personId FROM Person WHERE loginName='alice'),
   (SELECT trackId FROM Track WHERE title='City Pulse'),
   CURRENT_DATE,
   1),
  ((SELECT personId FROM Person WHERE loginName='diana'),
   (SELECT trackId FROM Track WHERE title='Harbor Lights'),
   CURRENT_DATE - INTERVAL '2 days',
   2);

-- Playlists

INSERT INTO Playlist (customerId, playlistName) VALUES
  ((SELECT personId FROM Person WHERE loginName='alice'), 'Morning Mix'),
  ((SELECT personId FROM Person WHERE loginName='alice'), 'Workout Boost'),
  ((SELECT personId FROM Person WHERE loginName='diana'), 'Chill Vibes');

INSERT INTO Contains (playlistName, customerId, trackId, orderNumber) VALUES
  ('Morning Mix',
   (SELECT personId FROM Person WHERE loginName='alice'),
   (SELECT trackId FROM Track WHERE title='Shine On'),
   1),
  ('Morning Mix',
   (SELECT personId FROM Person WHERE loginName='alice'),
   (SELECT trackId FROM Track WHERE title='Harbor Lights'),
   2),
  ('Workout Boost',
   (SELECT personId FROM Person WHERE loginName='alice'),
   (SELECT trackId FROM Track WHERE title='City Pulse'),
   1),
  ('Chill Vibes',
   (SELECT personId FROM Person WHERE loginName='diana'),
   (SELECT trackId FROM Track WHERE title='Midnight Echoes'),
   1);

-- Reviews

INSERT INTO Review (trackId, rating, shortReview, customerId)
VALUES (
   (SELECT trackId FROM Track WHERE title='Shine On'),
   5,
   'Love the chorus and the energy!',
   (SELECT personId FROM Person WHERE loginName='alice')
);

INSERT INTO Review (trackId, rating, shortReview, customerId)
VALUES (
   (SELECT trackId FROM Track WHERE title='Harbor Lights'),
   3,
   'Nice melody but a bit slow for me.',
   (SELECT personId FROM Person WHERE loginName='diana')
);

-- Example of removal of Diana's review by Staff 'sam'

UPDATE Review
SET dateTimeRemoved = NOW(),
    reason = 'Contains off-topic content',
    staffId = (SELECT personId FROM Person WHERE loginName='sam')
WHERE customerId = (SELECT personId FROM Person WHERE loginName='diana')
  AND trackId    = (SELECT trackId FROM Track WHERE title='Harbor Lights');
