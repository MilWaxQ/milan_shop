-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 25, 2025 at 07:07 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `devmta`
--

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `serial` varchar(32) NOT NULL,
  `shopID` int(11) NOT NULL,
  `itemName` varchar(255) NOT NULL,
  `count` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `shopID` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`shopID`, `name`, `price`) VALUES
(1, 'Cigaretta', 1000),
(1, 'Energiaital', 1000),
(1, 'Fanta', 1000),
(1, 'Hamburger', 1000),
(1, 'Hot-Dog', 1000),
(1, 'Kávé', 1000),
(1, 'Kés', 1000),
(1, 'Kóla', 1000),
(1, 'Öngyújtó', 1000),
(1, 'Papír', 1000),
(1, 'Pohár', 1000),
(1, 'Rádió', 1000),
(1, 'Szendvics', 1000),
(1, 'Szörp', 1000),
(1, 'Tea', 1000),
(1, 'Telefon', 1000),
(1, 'Víz', 500),
(2, 'Ásó', 2000),
(2, 'Csákány', 2000),
(2, 'Flex', 2000),
(2, 'HI-FI', 2000),
(2, 'Kalapács', 2000),
(2, 'Telefon', 1000);

-- --------------------------------------------------------

--
-- Table structure for table `shops`
--

CREATE TABLE `shops` (
  `ID` int(11) NOT NULL,
  `name` text NOT NULL,
  `posX` float NOT NULL,
  `posY` float NOT NULL,
  `posZ` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- Dumping data for table `shops`
--

INSERT INTO `shops` (`ID`, `name`, `posX`, `posY`, `posZ`) VALUES
(1, 'Bolt', 0, 0, 3),
(2, 'Bolt', 1, 0, 3);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`serial`,`shopID`,`itemName`),
  ADD KEY `shopID` (`shopID`),
  ADD KEY `itemName` (`itemName`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`shopID`,`name`),
  ADD KEY `name` (`name`);

--
-- Indexes for table `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `shops`
--
ALTER TABLE `shops`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shops` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `carts_ibfk_2` FOREIGN KEY (`itemName`) REFERENCES `items` (`name`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`shopID`) REFERENCES `shops` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
