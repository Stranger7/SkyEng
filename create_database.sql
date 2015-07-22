--
-- Initialization.
--
-- ----------------------------------------------------------------------------------
--
-- Create database `skyeng_01234` and user `skyeng_01234` with password '1234'
--
CREATE DATABASE skyeng_01234 CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'skyeng_01234'@'localhost' IDENTIFIED BY '1234';
GRANT ALL ON skyeng_01234.* TO 'skyeng_01234'@'localhost';

--
-- Create tables
--
-- ----------------------------------------------------------------------------------
--
-- Table for students
--
CREATE TABLE IF NOT EXISTS student (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  `surname` VARCHAR(20) DEFAULT '' NOT NULL,
  `gender` ENUM('male', 'female', 'unknown') DEFAULT 'unknown',
  INDEX `gender` (`gender`)
);

--
-- Table for student statutes
--
CREATE TABLE IF NOT EXISTS student_status (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `student_id` INT NOT NULL,
  `status` ENUM('new', 'studying', 'vacation', 'testing', 'lost') DEFAULT 'new' NOT NULL,
  `datetime` DATETIME NOT NULL,
  INDEX `student_id` (`student_id`),
  INDEX `datetime` (`datetime`)
);

--
-- Table for payments
--
CREATE TABLE payments (
  `id` INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
  `student_id` INT NOT NULL,
  `datetime` DATETIME NOT NULL,
  `amount` FLOAT DEFAULT 0,
  INDEX `student_id` (`student_id`)
);
