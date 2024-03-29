-- MySQL Script generated by MySQL Workbench
-- Sat 09 Nov 2019 04:37:19 PM IST
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`person`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`person` ;

CREATE TABLE IF NOT EXISTS `mydb`.`person` (
  `MIS` VARCHAR(9) NOT NULL,
  `first_name` VARCHAR(20) NULL,
  `last_name` VARCHAR(20) NULL,
  `mobileno` CHAR(10) NULL,
  `email` VARCHAR(20) NULL,
  PRIMARY KEY (`MIS`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = ascii;


-- -----------------------------------------------------
-- Table `mydb`.`place`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`place` ;

CREATE TABLE IF NOT EXISTS `mydb`.`place` (
  `pid` INT NOT NULL,
  `name` VARCHAR(20) NULL,
  PRIMARY KEY (`pid`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`key`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`key` ;

CREATE TABLE IF NOT EXISTS `mydb`.`key` (
  `kid` INT NOT NULL,
  `place_pid` INT NOT NULL,
  `person_MIS` VARCHAR(9) NOT NULL,
  `place_pid_store` INT NOT NULL,
  PRIMARY KEY (`kid`, `place_pid`),
  INDEX `fk_key_place1_idx` (`place_pid` ASC) VISIBLE,
  INDEX `fk_key_person1_idx` (`person_MIS` ASC) VISIBLE,
  INDEX `fk_key_place2_idx` (`place_pid_store` ASC) VISIBLE,
  CONSTRAINT `fk_key_place1`
    FOREIGN KEY (`place_pid`)
    REFERENCES `mydb`.`place` (`pid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_key_person1`
    FOREIGN KEY (`person_MIS`)
    REFERENCES `mydb`.`person` (`MIS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_key_place2`
    FOREIGN KEY (`place_pid_store`)
    REFERENCES `mydb`.`place` (`pid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`club`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`club` ;

CREATE TABLE IF NOT EXISTS `mydb`.`club` (
  `cid` INT NOT NULL,
  `clubname` VARCHAR(45) NULL,
  `managed_by` VARCHAR(9) NOT NULL,
  PRIMARY KEY (`cid`),
  INDEX `fk_club_person1_idx` (`managed_by` ASC) VISIBLE,
  CONSTRAINT `fk_club_person1`
    FOREIGN KEY (`managed_by`)
    REFERENCES `mydb`.`person` (`MIS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`request_key`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`request_key` ;

CREATE TABLE IF NOT EXISTS `mydb`.`request_key` (
  `destination` VARCHAR(9) NOT NULL,
  `key_id` INT NOT NULL,
  `place_pid` INT NOT NULL,
  PRIMARY KEY (`destination`, `key_id`, `place_pid`),
  INDEX `requested_by_idx` (`destination` ASC) VISIBLE,
  INDEX `key_requested_idx` (`key_id` ASC, `place_pid` ASC) VISIBLE,
  CONSTRAINT `requested_by`
    FOREIGN KEY (`destination`)
    REFERENCES `mydb`.`person` (`MIS`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `key_requested`
    FOREIGN KEY (`key_id` , `place_pid`)
    REFERENCES `mydb`.`key` (`kid` , `kid`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`log`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`log` ;

CREATE TABLE IF NOT EXISTS `mydb`.`log` (
  `log_id` INT NOT NULL,
  `source_person` VARCHAR(9) NULL,
  `source_place` INT NULL,
  `destination_person` VARCHAR(9) NULL,
  `destination_place` INT NULL,
  `time` DATETIME NOT NULL,
  PRIMARY KEY (`log_id`),
  INDEX `source_person_idx` (`source_person` ASC) VISIBLE,
  INDEX `destination_person_idx` (`destination_person` ASC) VISIBLE,
  INDEX `source_place_idx` (`source_place` ASC) VISIBLE,
  INDEX `destination_place_idx` (`destination_place` ASC) VISIBLE,
  CONSTRAINT `source_person`
    FOREIGN KEY (`source_person`)
    REFERENCES `mydb`.`person` (`MIS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `destination_person`
    FOREIGN KEY (`destination_person`)
    REFERENCES `mydb`.`person` (`MIS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `source_place`
    FOREIGN KEY (`source_place`)
    REFERENCES `mydb`.`place` (`pid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `destination_place`
    FOREIGN KEY (`destination_place`)
    REFERENCES `mydb`.`place` (`pid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`club_canuse_key`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`club_canuse_key` ;

CREATE TABLE IF NOT EXISTS `mydb`.`club_canuse_key` (
  `club_cid` INT NOT NULL,
  `key_kid` INT NOT NULL,
  `key_place_pid` INT NOT NULL,
  PRIMARY KEY (`club_cid`, `key_kid`, `key_place_pid`),
  INDEX `fk_club_has_key_key1_idx` (`key_kid` ASC, `key_place_pid` ASC) VISIBLE,
  INDEX `fk_club_has_key_club1_idx` (`club_cid` ASC) VISIBLE,
  CONSTRAINT `fk_club_has_key_club1`
    FOREIGN KEY (`club_cid`)
    REFERENCES `mydb`.`club` (`cid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_club_has_key_key1`
    FOREIGN KEY (`key_kid` , `key_place_pid`)
    REFERENCES `mydb`.`key` (`kid` , `place_pid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`person_belongsto_club`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`person_belongsto_club` ;

CREATE TABLE IF NOT EXISTS `mydb`.`person_belongsto_club` (
  `person_MIS` VARCHAR(9) NOT NULL,
  `club_cid` INT NOT NULL,
  PRIMARY KEY (`person_MIS`, `club_cid`),
  INDEX `fk_person_has_club_club1_idx` (`club_cid` ASC) VISIBLE,
  INDEX `fk_person_has_club_person1_idx` (`person_MIS` ASC) VISIBLE,
  CONSTRAINT `fk_person_has_club_person1`
    FOREIGN KEY (`person_MIS`)
    REFERENCES `mydb`.`person` (`MIS`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_person_has_club_club1`
    FOREIGN KEY (`club_cid`)
    REFERENCES `mydb`.`club` (`cid`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = ascii;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
