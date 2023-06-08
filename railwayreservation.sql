-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 08, 2023 at 06:02 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `railwayreservation`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `CancelBook` (IN `T_ID` INT)   BEGIN
    DECLARE passID INT;
    DECLARE StatusReserve VARCHAR(255);
    DECLARE TrainNum INT;

    SELECT TicketID INTO passID FROM passenger WHERE TicketID = T_ID;
    SELECT TrainNumber INTO TrainNum FROM passenger WHERE TicketID = T_ID;
    SELECT Status_Reservation INTO StatusReserve FROM passenger WHERE TicketID = T_ID;

    IF StatusReserve = 'Confirmed' THEN
        DELETE FROM passenger WHERE TicketID = T_ID;
        UPDATE passenger SET Status_Reservation = 'Confirmed' WHERE Status_Reservation = 'Waiting' AND TrainNumber = TrainNum;
        SELECT 'Cancelled Successfully.' AS Message;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Passenger's Status Reservation not Confirmed";
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertPassenger` (IN `T_ID` INT, IN `T_Number` INT, IN `B_Date` DATE, IN `P_Name` VARCHAR(255), IN `P_Age` INT, IN `P_Sex` VARCHAR(255), IN `P_Address` VARCHAR(255), IN `S_Reservation` VARCHAR(255), IN `T_Category` VARCHAR(255))   BEGIN
    DECLARE ACSeat INT;
    DECLARE ACSeatBooked INT;
    DECLARE ACIncrement INT;
    
    DECLARE GENSeat INT;
    DECLARE GENSeatBooked INT;
    DECLARE GENIncrement INT;
    
    IF T_Category = 'AC' THEN
        SELECT AC_Seat INTO ACSeat FROM trainstatus WHERE TrainNumber = T_Number LIMIT 1;
        SELECT AC_Seat_Booked INTO ACSeatBooked FROM trainstatus WHERE TrainNumber = T_Number LIMIT 1;
        SET ACIncrement = ACSeatBooked + 1;
        
        IF ACSeat <= ACSeatBooked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'AC seats are fully booked.';
        ELSE
            INSERT INTO passenger (TicketID, TrainNumber, Booked_Date, Name, Age, Sex, Address, Status_Reservation, Ticket_Category)
            VALUES (T_ID, T_Number, B_Date, P_Name, P_Age, P_Sex, P_Address, S_Reservation, T_Category);
            UPDATE trainstatus SET AC_SEAT_BOOKED = ACIncrement WHERE TrainNumber = T_Number;
            SELECT 'Booking inserted successfully.' AS Message;
        END IF;
    ELSE
        SELECT Gen_Seat INTO GENSeat FROM trainstatus WHERE TrainNumber = T_Number LIMIT 1;
        SELECT Gen_Seat_Booked INTO GENSeatBooked FROM trainstatus WHERE TrainNumber = T_Number LIMIT 1;
        SET GENIncrement = GENSeatBooked + 1;
        
        IF GENSeat <= GENSeatBooked THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'GEN seats are fully booked.';
        ELSE
            INSERT INTO passenger (TicketID, TrainNumber, Booked_Date, Name, Age, Sex, Address, Status_Reservation, Ticket_Category)
            VALUES (T_ID, T_Number, B_Date, P_Name, P_Age, P_Sex, P_Address, S_Reservation, T_Category);
            UPDATE trainstatus SET GEN_SEAT_BOOKED = GENIncrement WHERE TrainNumber = T_Number;
            SELECT 'Booking inserted successfully.' AS Message;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReportAC` (IN `T_Num` INT, IN `T_Date` DATE)   BEGIN
	SELECT TrainNumber, TrainDate, AC_Seat_Booked AS `PASSENGERS ON AC SEATS` FROM trainstatus WHERE TrainNumber = T_Num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ReportGEN` (IN `T_Num` INT, IN `T_Date` DATE)   BEGIN
	SELECT TrainNumber, TrainDate, GEN_Seat_Booked AS `PASSENGERS ON GEN SEATS` FROM trainstatus WHERE TrainNumber = T_Num;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `audit_table`
--

CREATE TABLE `audit_table` (
  `TrainID` int(5) NOT NULL,
  `Category` varchar(10) NOT NULL,
  `UpdateDateTime` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_table`
--

INSERT INTO `audit_table` (`TrainID`, `Category`, `UpdateDateTime`) VALUES
(34567, 'Gen', '2023-06-08 23:43:55');

-- --------------------------------------------------------

--
-- Table structure for table `passenger`
--

CREATE TABLE `passenger` (
  `TicketID` int(5) NOT NULL,
  `TrainNumber` int(5) NOT NULL,
  `Booked_Date` date NOT NULL,
  `Name` varchar(20) NOT NULL,
  `Age` int(5) NOT NULL,
  `Sex` varchar(10) NOT NULL,
  `Address` varchar(50) NOT NULL,
  `Status_Reservation` varchar(20) NOT NULL,
  `Ticket_Category` varchar(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `passenger`
--

INSERT INTO `passenger` (`TicketID`, `TrainNumber`, `Booked_Date`, `Name`, `Age`, `Sex`, `Address`, `Status_Reservation`, `Ticket_Category`) VALUES
(1, 12345, '2023-06-01', 'Jacky Ala', 20, 'Female', 'Opol', 'Confirmed', 'AC'),
(2, 10234, '2023-06-02', 'Ricky Boy', 33, 'Male', 'Molugan', 'Waiting', 'Gen'),
(3, 90123, '2023-06-03', 'Mel Carlo', 15, 'Male', 'Alubijid', 'Confirmed', 'AC'),
(4, 34567, '2023-06-04', 'Earnest Vince', 30, 'Male', 'Igpit', 'Waiting', 'Gen'),
(5, 78901, '2023-06-05', 'Joanna Shine', 42, 'Female', 'Bulua', 'Confirmed', 'Gen'),
(6, 23456, '2023-06-06', 'Karen Yesamis', 21, 'Female', 'Kauswagan', 'Waiting', 'AC'),
(7, 67890, '2023-06-07', 'Vivian Anne', 18, 'Female', 'Barra', 'Confirmed', 'Gen'),
(8, 10234, '2023-06-03', 'Aurora Hoyohoy', 16, 'Female', 'Igpit', 'Waiting', 'Gen'),
(9, 45670, '2023-06-05', 'Jared Rara', 48, 'Male', 'Molugan', 'Waiting', 'AC'),
(10, 89012, '2023-06-01', 'Stephie Marie', 31, 'Female', 'Bulua', 'Confirmed', 'Gen');

--
-- Triggers `passenger`
--
DELIMITER $$
CREATE TRIGGER `PassengerStatusUpdate` AFTER UPDATE ON `passenger` FOR EACH ROW BEGIN
    IF NEW.Status_Reservation = 'Confirmed' AND OLD.Status_Reservation = 'Waiting' THEN
        INSERT INTO audit_table (TrainID, Category, UpdateDateTime)
        VALUES (NEW.TrainNumber, NEW.Ticket_Category, NOW());
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `trainlist`
--

CREATE TABLE `trainlist` (
  `TrainNumber` int(5) NOT NULL,
  `TrainName` varchar(50) NOT NULL,
  `Source` varchar(50) NOT NULL,
  `Destination` varchar(50) NOT NULL,
  `AC_Ticket_Fair` int(20) NOT NULL,
  `Gen_Ticket_Fair` int(20) NOT NULL,
  `M_Available` varchar(3) NOT NULL,
  `T_Available` varchar(3) NOT NULL,
  `W_Available` varchar(3) NOT NULL,
  `Th_Available` varchar(3) NOT NULL,
  `F_Available` varchar(3) NOT NULL,
  `Sa_Available` varchar(3) NOT NULL,
  `Su_Available` varchar(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trainlist`
--

INSERT INTO `trainlist` (`TrainNumber`, `TrainName`, `Source`, `Destination`, `AC_Ticket_Fair`, `Gen_Ticket_Fair`, `M_Available`, `T_Available`, `W_Available`, `Th_Available`, `F_Available`, `Sa_Available`, `Su_Available`) VALUES
(10234, 'MRT Line 1', 'Davao City Station', 'Quezon', 50, 45, 'No', 'No', 'Yes', 'Yes', 'No', 'No', 'No'),
(12345, 'LRT Line 1', 'Cagayan De Oro', 'Malaybalay City', 20, 15, 'Yes', 'No', 'Yes', 'Yes', 'No', 'Yes', 'Yes'),
(23456, 'PNOR 1', 'Cagayan De Oro', 'Mintal', 70, 65, 'Yes', 'No', 'Yes', 'Yes', 'No', 'Yes', 'Yes'),
(34567, 'LRT Line 2', 'Cagayan De Oro', 'Quezon', 40, 35, 'Yes', 'Yes', 'No', 'Yes', 'No', 'Yes', 'No'),
(45670, 'LRT Line 4', 'Cagayan De Oro', 'Davao City Station', 80, 75, 'Yes', 'No', 'Yes', 'No', 'Yes', 'Yes', 'Yes'),
(56789, 'MRT Line 3', 'Davao City Station', 'Cagayan De Oro', 80, 85, 'No', 'Yes', 'Yes', 'No', 'No', 'Yes', 'No'),
(67890, 'LRT Line 3', 'Davao City Station', 'Buda', 30, 25, 'No', 'Yes', 'Yes', 'No', 'Yes', 'Yes', 'No'),
(78901, 'MRT Line 4', 'Davao City Station', 'Lorega', 40, 35, 'Yes', 'No', 'No', 'Yes', 'Yes', 'Yes', 'No'),
(89012, 'MRT Line 2', 'Cagayan De Oro', 'Lorega', 50, 45, 'Yes', 'Yes', 'No', 'Yes', 'Yes', 'Yes', 'No'),
(90123, 'PNOR 2', 'Davao City Station', 'Valencia City', 60, 55, 'No', 'Yes', 'No', 'No', 'Yes', 'No', 'Yes');

-- --------------------------------------------------------

--
-- Table structure for table `trainstatus`
--

CREATE TABLE `trainstatus` (
  `TrainNumber` int(5) NOT NULL,
  `TrainDate` date NOT NULL,
  `AC_Seat` int(10) NOT NULL,
  `Gen_Seat` int(10) NOT NULL,
  `AC_Seat_Booked` int(10) NOT NULL,
  `Gen_Seat_Booked` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trainstatus`
--

INSERT INTO `trainstatus` (`TrainNumber`, `TrainDate`, `AC_Seat`, `Gen_Seat`, `AC_Seat_Booked`, `Gen_Seat_Booked`) VALUES
(12345, '2023-06-05', 10, 20, 10, 9),
(56789, '2023-06-06', 10, 20, 9, 2),
(10234, '2023-06-07', 10, 20, 5, 7),
(34567, '2023-06-08', 10, 20, 7, 2),
(78901, '2023-06-09', 10, 20, 10, 5),
(23456, '2023-06-10', 10, 20, 2, 3),
(67890, '2023-06-11', 10, 20, 6, 9),
(90123, '2023-06-07', 10, 20, 5, 2),
(45670, '2023-06-10', 10, 20, 2, 9),
(89012, '2023-06-05', 10, 20, 8, 7);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `passenger`
--
ALTER TABLE `passenger`
  ADD PRIMARY KEY (`TicketID`),
  ADD KEY `TrainNumber` (`TrainNumber`);

--
-- Indexes for table `trainlist`
--
ALTER TABLE `trainlist`
  ADD PRIMARY KEY (`TrainNumber`);

--
-- Indexes for table `trainstatus`
--
ALTER TABLE `trainstatus`
  ADD KEY `TrainNumber` (`TrainNumber`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `passenger`
--
ALTER TABLE `passenger`
  ADD CONSTRAINT `passenger_ibfk_1` FOREIGN KEY (`TrainNumber`) REFERENCES `trainlist` (`TrainNumber`);

--
-- Constraints for table `trainstatus`
--
ALTER TABLE `trainstatus`
  ADD CONSTRAINT `trainstatus_ibfk_1` FOREIGN KEY (`TrainNumber`) REFERENCES `trainlist` (`TrainNumber`),
  ADD CONSTRAINT `trainstatus_ibfk_2` FOREIGN KEY (`TrainNumber`) REFERENCES `trainlist` (`TrainNumber`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
