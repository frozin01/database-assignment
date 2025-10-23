-- DROP SCHEMA IF EXISTS sydneymusic CASCADE;
-- CREATE SCHEMA sydneymusic;
-- SET SCHEMA 'sydneymusic';
-- SET datestyle = 'ISO, DMY';

CREATE TABLE
    Account (
        login VARCHAR(30) PRIMARY KEY,
        firstname VARCHAR(100) NOT NULL,
        lastname VARCHAR(100) NOT NULL,
        email VARCHAR(50),
        PASSWORD VARCHAR(20) NOT NULL,
        ROLE VARCHAR(20) NOT NULL CHECK (ROLE IN ('Customer', 'Staff', 'Artist'))
    );

CREATE TABLE
    Customer (login VARCHAR(30) PRIMARY KEY REFERENCES Account (login) ON DELETE CASCADE);

CREATE TABLE
    Artist (login VARCHAR(30) PRIMARY KEY REFERENCES Account (login) ON DELETE CASCADE);

CREATE TABLE
    Track (
        id SERIAL PRIMARY KEY,
        title VARCHAR(100) NOT NULL,
        duration NUMERIC(5, 2) NOT NULL,
        age_restriction BOOLEAN DEFAULT TRUE NOT NULL,
        composer VARCHAR(30) REFERENCES Artist (login),
        singer VARCHAR(30) REFERENCES Artist (login)
    );

CREATE TABLE
    Review (
        reviewID serial PRIMARY KEY,
        trackID INTEGER,
        CONTENT TEXT,
        rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
        customerID VARCHAR(30) NOT NULL,
        reviewDate Date NOT NULL,
        FOREIGN KEY (trackID) REFERENCES Track (id),
        FOREIGN KEY (customerID) REFERENCES Customer (login)
    );

-- Accounts
INSERT INTO
    Account (login, firstname, lastname, email, PASSWORD, ROLE)
VALUES
-- Customers
('jdoe', 'John', 'Doe', 'jd@email.com', 'Pass123', 'Customer'),
('fan_maria', 'Maria', 'Garcia', 'maria@email.com', 'pass123', 'Customer'),
('pop', 'Chris', 'Johnson', 'chris.johnson@email.com', 'pop123', 'Customer'),
('music_critic', 'Emma', 'Wilson', 'emma.wilson@email.com', 'critic456', 'Customer'),
-- Staff
('jwilson', 'James', 'Wilson', 'james.wilson@sydneymusic.com', 'pass!', 'Staff'),
('admin_lisa', 'Lisa', 'Chen', 'lisa.chen@sydneymusic.com', 'admin456', 'Staff'),
-- Artists
('mina', 'Mina', 'Miller', 'mmm@artist.com', 'music123', 'Artist'),
('david', 'David', 'Brown', 'brown@artist.com', 'hit123', 'Artist'),
('vocal_queen', 'Sarah', 'Davis', NULL, 'vocal123', 'Artist'),
('beat_master', 'Kevin', 'Martinez', 'kevin123@email.com', 'beat123', 'Artist'),
('melody_king', 'Daniel', 'Anderson', 'anderson@email.com', 'melody123', 'Artist'),
('rhythm_pro', 'Emily', 'Taylor', 'taylor@email.com', 'rhythm123', 'Artist'),
('dream_girls', 'Dream', 'Girls', 'dream.girls@artist.com', 'girlgroup123', 'Artist');

-- Insert Customers
INSERT INTO
    Customer (login)
VALUES
    ('jdoe'),
    ('fan_maria'),
    ('pop'),
    ('music_critic');

-- Insert Artists 
INSERT INTO
    Artist (login)
VALUES
    ('mina'),
    ('david'),
    ('vocal_queen'),
    ('beat_master'),
    ('melody_king'),
    ('rhythm_pro'),
	('dream_girls');

-- Insert Tracks
INSERT INTO
    Track (title, duration, age_restriction, composer, singer)
VALUES
    ('Blinding Lights', 3.20, TRUE, 'beat_master', 'vocal_queen'),
    ('Shake It Off', 3.39, FALSE, 'david', 'mina'),
    ('Shape of You', 3.53, FALSE, 'david', 'vocal_queen'),
    ('Thank U, Next', 3.27, TRUE, 'vocal_queen', 'vocal_queen'),
    ('Hotline Bling', 4.27, TRUE, NULL, 'melody_king'), -- No composer
    ('Halo', 4.21, FALSE, NULL, 'rhythm_pro'), -- No composer
    ('Bohemian Rhapsody', 5.55, TRUE, 'beat_master', NULL), -- No singer
    ('Dance Monkey', 3.45, FALSE, NULL, NULL), -- No composer or singer
    ('God''s Plan', 3.19, TRUE, 'melody_king', 'melody_king'),
    ('Blank Space', 3.51, FALSE, 'mina', 'rhythm_pro'),
    ('Takedown', 3.45, FALSE, 'dream_girls', 'dream_girls');

-- Insert Reviews
INSERT INTO
    Review (trackID, CONTENT, rating, customerID, reviewDate)
VALUES
    (1, 'Really disappointed with this release. The lyrics are repetitive and the melody is uninspired compared to their previous work.t.', 1,'jdoe','2025-01-15'),
    (1, 'Overrated and repetitive. The synth loop becomes annoying after the first minute.', 2, 'music_critic', '2024-03-18'),
    (3, 'The rhythm is so catchy, I find myself humming it all day.', 5, 'jdoe', '2025-02-01'),
    (3, 'Gets repetitive quickly. The same four chords throughout the entire song with no variation.', 2, 'pop', '2024-12-16'),
    (4, 'Love the emotional depth in this song, really connects with me.', 4, 'fan_maria', '2023-02-10'),
    (4, 'Production feels cheap and the vocal processing is excessive. Hard to connect with the emotion.', 2, 'music_critic', '2025-03-01'),
    (5, NULL, 3, 'music_critic', '2024-02-15'), -- No content
    (6, 'The vocal performance in this track is absolutely breathtaking.', 5, 'fan_maria', '2025-02-20'),
    (7, 'An epic musical journey that showcases incredible talent.', 4, 'jdoe', '2025-12-01'),
    (7, 'Without vocals, this classic loses its magic. The instrumental version feels empty and incomplete.', 1, 'fan_maria', '2024-12-08'),
    (7, 'Bold attempt but fails to capture the original''s energy. The instruments alone can''t carry the weight.', 2, 'music_critic', '2025-03-09'),
    (8, NULL, 5, 'pop', '2024-03-05'), -- No content
    (8, 'This song represents everything wrong with modern pop music - repetitive and lacking substance.', 1, 'music_critic', '2025-03-13'),
    (9, 'The production quality on this track is top-notch.', 5, 'pop', '2025-03-10'),
    (10, 'Clever lyrics combined with a memorable melody make this a standout.', 4, 'pop', '2025-03-15'),
    (11,'Absolutely addictive track! The harmonies are incredible and the beat drops at perfect moments.',5,'jdoe', '2025-09-20'),
    (11,'This song has been on repeat all day! Dream Girls really delivered a masterpiece here.',5, 'pop', '2025-07-21'),
    (11,'Best release of the year! The production quality is outstanding and the vocals are flawless.',5, 'fan_maria', '2025-07-22');
