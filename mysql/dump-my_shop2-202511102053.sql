


-- MySQL dump 10.13  Distrib 8.0.39, for Win64 (x86_64)
--
-- Host: localhost    Database: my_shop2
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `colors`
--

DROP TABLE IF EXISTS `colors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colors` (
  `color` varchar(20) NOT NULL,
  PRIMARY KEY (`color`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `colors`
--

LOCK TABLES `colors` WRITE;
/*!40000 ALTER TABLE `colors` DISABLE KEYS */;
INSERT INTO `colors` VALUES ('Black'),('Blue'),('Red');
/*!40000 ALTER TABLE `colors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employee_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `manager_id` bigint DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `manager_id` (`manager_id`),
  CONSTRAINT `employees_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `employees` (`employee_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'김회장',NULL),(2,'박사장',1),(3,'이부장',2),(4,'최과장',3),(5,'정대리',4),(6,'홍사원',4);
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materials`
--

DROP TABLE IF EXISTS `materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `materials` (
  `material` varchar(20) NOT NULL,
  PRIMARY KEY (`material`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materials`
--

LOCK TABLES `materials` WRITE;
/*!40000 ALTER TABLE `materials` DISABLE KEYS */;
INSERT INTO `materials` VALUES ('Cotton'),('Silk');
/*!40000 ALTER TABLE `materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `order_id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `product_id` bigint NOT NULL,
  `order_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `quantity` int NOT NULL,
  `status` varchar(50) DEFAULT 'PENDING',
  PRIMARY KEY (`order_id`),
  KEY `fk_orders_users` (`user_id`),
  KEY `fk_orders_products` (`product_id`),
  CONSTRAINT `fk_orders_products` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  CONSTRAINT `fk_orders_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,1,1,'2025-06-10 10:00:00',1,'COMPLETED'),(2,1,4,'2025-06-10 10:05:00',2,'COMPLETED'),(3,2,2,'2025-06-11 14:20:00',1,'SHIPPED'),(4,3,4,'2025-06-12 09:00:00',1,'COMPLETED'),(5,4,3,'2025-06-15 11:30:00',1,'PENDING'),(6,5,1,'2025-06-16 18:00:00',1,'COMPLETED'),(7,2,1,'2025-06-17 12:00:00',2,'SHIPPED');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_options`
--

DROP TABLE IF EXISTS `product_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_options` (
  `option_id` bigint NOT NULL AUTO_INCREMENT,
  `product_name` varchar(255) NOT NULL,
  `size` varchar(10) NOT NULL,
  `color` varchar(20) NOT NULL,
  PRIMARY KEY (`option_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_options`
--

LOCK TABLES `product_options` WRITE;
/*!40000 ALTER TABLE `product_options` DISABLE KEYS */;
INSERT INTO `product_options` VALUES (1,'기본티셔츠-Red-L','L','Red'),(2,'기본티셔츠-Blue-L','L','Blue'),(3,'기본티셔츠-Black-L','L','Black'),(4,'기본티셔츠-Red-M','M','Red'),(5,'기본티셔츠-Blue-M','M','Blue'),(6,'기본티셔츠-Black-M','M','Black'),(7,'기본티셔츠-Red-S','S','Red'),(8,'기본티셔츠-Blue-S','S','Blue'),(9,'기본티셔츠-Black-S','S','Black'),(10,'기본티셔츠-Red-XL','XL','Red'),(11,'기본티셔츠-Blue-XL','XL','Blue'),(12,'기본티셔츠-Black-XL','XL','Black');
/*!40000 ALTER TABLE `product_options` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `category` varchar(100) DEFAULT NULL,
  `price` int NOT NULL,
  `stock_quantity` int NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'프리미엄 게이밍 마우스','전자기기',75000,50),(2,'기계식 키보드','전자기기',120000,30),(3,'4K UHD 모니터','전자기기',350000,20),(4,'관계형 데이터베이스 입문','도서',28000,100),(5,'고급 가죽 지갑','패션',150000,15),(6,'스마트 워치','전자기기',280000,40);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sizes`
--

DROP TABLE IF EXISTS `sizes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sizes` (
  `size` varchar(10) NOT NULL,
  PRIMARY KEY (`size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sizes`
--

LOCK TABLES `sizes` WRITE;
/*!40000 ALTER TABLE `sizes` DISABLE KEYS */;
INSERT INTO `sizes` VALUES ('L'),('M'),('S'),('XL');
/*!40000 ALTER TABLE `sizes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `address` varchar(255) DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'션','sean@example.com','서울시 강남구','1990-01-15','2025-10-14 18:27:27'),(2,'네이트','nate@example.com','경기도 성남시','1988-05-22','2025-10-14 18:27:27'),(3,'세종대왕','sejong@example.com','서울시 종로구','1397-05-15','2025-10-14 18:27:27'),(4,'이순신','sunsin@example.com','전라남도 여수시','1545-04-28','2025-10-14 18:27:27'),(5,'마리 퀴리','marie@example.com','서울시 강남구','1867-11-07','2025-10-14 18:27:27'),(6,'레오나르도 다빈치','vinci@example.com','이탈리아 피렌체','1452-04-15','2025-10-14 18:27:27');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'my_shop2'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-10 20:53:49
