-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 21 سبتمبر 2026 الساعة 17:58
-- إصدار الخادم: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `smart_pharmacy`
--

-- --------------------------------------------------------

--
-- بنية الجدول `activity_logs`
--

CREATE TABLE `activity_logs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `dashboard_user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `pharmacy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `data` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `activity_logs`
--

INSERT INTO `activity_logs` (`id`, `user_id`, `dashboard_user_id`, `pharmacy_id`, `type`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 3, NULL, 1, 'order.requested', '{\"order_id\":1,\"message\":\"Customer requested a medicine.\"}', NULL, '2026-08-31 14:26:56', '2026-08-31 14:26:56'),
(2, 3, NULL, 1, 'order.cancelled', '{\"order_id\":1,\"status\":\"cancelled\"}', NULL, '2026-08-31 14:27:07', '2026-08-31 14:27:07'),
(3, 3, NULL, 1, 'order.requested', '{\"order_id\":2,\"message\":\"Customer requested a medicine.\"}', NULL, '2026-08-31 14:27:20', '2026-08-31 14:27:20'),
(4, 3, NULL, 1, 'order.status_updated', '{\"order_id\":2,\"old_status\":\"accepted\",\"new_status\":\"accepted\"}', NULL, '2026-08-31 14:32:38', '2026-08-31 14:32:38'),
(5, 3, NULL, 1, 'order.requested', '{\"order_id\":3,\"message\":\"Customer requested a medicine.\"}', NULL, '2026-09-01 15:00:53', '2026-09-01 15:00:53'),
(6, NULL, 6, 2, 'pharmacy.approved', '{\"message\":\"Pharmacy application approved.\"}', NULL, '2026-09-01 15:46:56', '2026-09-01 15:46:56'),
(7, 3, NULL, 1, 'order.requested', '{\"order_id\":4,\"message\":\"Customer requested a medicine.\"}', NULL, '2026-09-02 12:09:49', '2026-09-02 12:09:49'),
(8, 3, NULL, 2, 'order.created', '{\"order_id\":5,\"status\":\"pending\"}', NULL, '2026-09-02 14:11:01', '2026-09-02 14:11:01'),
(9, 3, NULL, 1, 'order.created', '{\"order_id\":6,\"status\":\"pending\"}', NULL, '2026-09-02 14:15:03', '2026-09-02 14:15:03'),
(10, 3, NULL, 1, 'order.cancelled', '{\"order_id\":3,\"status\":\"cancelled\"}', NULL, '2026-09-02 14:21:27', '2026-09-02 14:21:27'),
(11, 3, NULL, 1, 'order.requested', '{\"order_id\":7,\"message\":\"Customer requested a medicine.\"}', NULL, '2026-09-02 15:09:19', '2026-09-02 15:09:19'),
(12, 3, NULL, 1, 'order.requested', '{\"order_id\":8,\"message\":\"Customer requested an offer.\"}', NULL, '2026-09-04 14:09:17', '2026-09-04 14:09:17'),
(13, 3, NULL, 2, 'order.created', '{\"order_id\":9,\"status\":\"pending\"}', NULL, '2026-09-11 14:31:34', '2026-09-11 14:31:34'),
(14, 3, NULL, 2, 'order.cancelled', '{\"order_id\":9,\"status\":\"cancelled\"}', NULL, '2026-09-11 14:32:37', '2026-09-11 14:32:37'),
(15, 3, NULL, 1, 'order.status_updated', '{\"order_id\":8,\"old_status\":\"delivered\",\"new_status\":\"delivered\"}', NULL, '2026-09-11 14:36:55', '2026-09-11 14:36:55'),
(16, 3, NULL, 1, 'order.created', '{\"order_id\":10,\"status\":\"pending\"}', NULL, '2026-09-14 11:31:58', '2026-09-14 11:31:58'),
(17, 3, NULL, 2, 'order.cancelled', '{\"order_id\":5,\"status\":\"cancelled\"}', NULL, '2026-09-14 11:47:38', '2026-09-14 11:47:38'),
(18, 3, NULL, 1, 'order.cancelled', '{\"order_id\":6,\"status\":\"cancelled\"}', NULL, '2026-09-14 11:47:41', '2026-09-14 11:47:41'),
(19, 3, NULL, 1, 'order.cancelled', '{\"order_id\":4,\"status\":\"cancelled\"}', NULL, '2026-09-14 11:47:42', '2026-09-14 11:47:42'),
(20, 3, NULL, 2, 'order.created', '{\"order_id\":11,\"status\":\"pending\"}', NULL, '2026-09-14 12:07:21', '2026-09-14 12:07:21'),
(21, 3, NULL, 1, 'order.created', '{\"order_id\":12,\"status\":\"pending\"}', NULL, '2026-09-14 14:33:34', '2026-09-14 14:33:34'),
(22, 3, NULL, 1, 'order.cancelled', '{\"order_id\":10,\"status\":\"cancelled\"}', NULL, '2026-09-14 14:37:05', '2026-09-14 14:37:05'),
(23, 3, NULL, 1, 'order.created', '{\"order_id\":13,\"status\":\"pending\"}', NULL, '2026-09-14 15:38:22', '2026-09-14 15:38:22'),
(24, 3, NULL, 2, 'order.created', '{\"order_id\":14,\"status\":\"pending\"}', NULL, '2026-09-19 10:54:55', '2026-09-19 10:54:55'),
(25, 3, NULL, 1, 'order.status_updated', '{\"order_id\":12,\"old_status\":\"accepted\",\"new_status\":\"accepted\"}', NULL, '2026-09-19 10:55:37', '2026-09-19 10:55:37'),
(26, 3, NULL, 1, 'order.status_updated', '{\"order_id\":7,\"old_status\":\"accepted\",\"new_status\":\"accepted\"}', NULL, '2026-09-19 10:56:15', '2026-09-19 10:56:15'),
(27, 3, NULL, 1, 'order.status_updated', '{\"order_id\":13,\"old_status\":\"accepted\",\"new_status\":\"accepted\"}', NULL, '2026-09-19 10:58:38', '2026-09-19 10:58:38'),
(28, 3, NULL, 1, 'order.status_updated', '{\"order_id\":13,\"old_status\":\"preparing\",\"new_status\":\"preparing\"}', NULL, '2026-09-19 10:58:40', '2026-09-19 10:58:40'),
(29, 10, NULL, 2, 'order.created', '{\"order_id\":15,\"status\":\"pending\"}', NULL, '2026-09-19 11:08:29', '2026-09-19 11:08:29'),
(30, 10, NULL, 1, 'order.created', '{\"order_id\":16,\"status\":\"pending\"}', NULL, '2026-09-19 11:09:22', '2026-09-19 11:09:22'),
(31, 3, NULL, 2, 'order.created', '{\"order_id\":17,\"status\":\"pending\"}', NULL, '2026-09-19 12:02:40', '2026-09-19 12:02:40'),
(32, 10, NULL, 1, 'order.status_updated', '{\"order_id\":16,\"old_status\":\"rejected\",\"new_status\":\"rejected\"}', NULL, '2026-09-19 12:03:25', '2026-09-19 12:03:25'),
(33, 3, NULL, 1, 'order.created', '{\"order_id\":18,\"status\":\"pending\"}', NULL, '2026-09-20 13:38:33', '2026-09-20 13:38:33'),
(34, 3, NULL, 1, 'order.created', '{\"order_id\":19,\"status\":\"pending\"}', NULL, '2026-09-20 13:39:37', '2026-09-20 13:39:37'),
(35, 3, NULL, 1, 'order.created', '{\"order_id\":20,\"status\":\"pending\"}', NULL, '2026-09-20 13:58:25', '2026-09-20 13:58:25'),
(36, 3, NULL, 1, 'order.created', '{\"order_id\":21,\"status\":\"pending\"}', NULL, '2026-09-20 13:59:49', '2026-09-20 13:59:49'),
(37, 3, NULL, 1, 'order.status_updated', '{\"order_id\":21,\"old_status\":\"accepted\",\"new_status\":\"accepted\"}', NULL, '2026-09-20 14:00:09', '2026-09-20 14:00:09'),
(38, 3, NULL, 1, 'order.status_updated', '{\"order_id\":21,\"old_status\":\"preparing\",\"new_status\":\"preparing\"}', NULL, '2026-09-20 14:00:22', '2026-09-20 14:00:22'),
(39, 3, NULL, 1, 'order.status_updated', '{\"order_id\":21,\"old_status\":\"ready\",\"new_status\":\"ready\"}', NULL, '2026-09-20 14:00:24', '2026-09-20 14:00:24'),
(40, 3, NULL, 1, 'order.status_updated', '{\"order_id\":21,\"old_status\":\"delivered\",\"new_status\":\"delivered\"}', NULL, '2026-09-20 14:00:26', '2026-09-20 14:00:26');

-- --------------------------------------------------------

--
-- بنية الجدول `app_users`
--

CREATE TABLE `app_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `role` enum('customer','pharmacy_owner') NOT NULL,
  `avatar_path` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `trial_ends_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `app_users`
--

INSERT INTO `app_users` (`id`, `name`, `email`, `password`, `phone`, `role`, `avatar_path`, `is_active`, `trial_ends_at`, `created_at`, `updated_at`) VALUES
(1, 'John Pharmacy Owner', 'www@w.com', '$2y$12$KRy0H9OYKzXoDE038UaYF.79CLKo.MiTwGJC84Mgss9S..XBzkJM2', '776565278', 'pharmacy_owner', NULL, 1, '2026-09-29 19:26:39', '2026-08-30 16:26:39', '2026-09-20 15:32:29'),
(2, 'Jane Customer', 'customer@example.com', '$2y$12$d1FU0fqnJQcteF1cNPrOE.3UZMPXV4KXdrO0ufkrqTbOGJWwvXUy2', NULL, 'customer', NULL, 1, NULL, '2026-08-30 16:26:40', '2026-08-30 16:26:40'),
(3, 'علي احمد صالح نعامة', 'wa@w.com', '$2y$12$CrPiYqCT6tL9PDCtopixrObd1K7SXoTRrs6V83z.KjEeszdk9BvQy', '776565278', 'customer', '/storage/user_avatars/p62Qnl9rawApswWz9EZmJ5ZOz4MwqidHHgOmm04y.jpg', 1, NULL, '2026-08-30 16:26:40', '2026-09-20 15:26:40'),
(4, 'Test User 2', 'aw@gmail.com', '$2y$12$LMzyqsK.tIngwgNqzFo3Mu815PZA46Wdiv/U6Cc78X5P4R5/HtA/m', NULL, 'customer', NULL, 1, NULL, '2026-08-30 16:26:40', '2026-08-30 16:26:40'),
(8, 'ali', 'ww@ww.com', '$2y$12$LYhjCFYQ..CheeSLWHVEK.fSbxUEgzrcc7B5YLDfl1woR9ZbD2uz.', NULL, 'pharmacy_owner', NULL, 1, '2026-10-01 18:39:31', '2026-09-01 15:39:31', '2026-09-01 15:39:31'),
(9, 'وهيب', 'www@www.com', '$2y$12$YoS1Io.YLHfwYcedQImAbeor0JtCfoY7gGUtNxFjA5PBkB5CA8aMi', NULL, 'pharmacy_owner', NULL, 1, '2026-10-12 15:11:57', '2026-09-12 12:11:57', '2026-09-12 12:11:57'),
(10, 'waheeb ali', 'www@ww.com', '$2y$12$wgcAuMNtyU1/FfbrwQL6i.0xkx0RUs0sMah0NcANW7H.Xzx4.Auy2', '776565278', 'customer', NULL, 1, NULL, '2026-09-19 11:07:40', '2026-09-19 11:07:40'),
(11, 'وهيب', 'wwaw@www.com', '$2y$12$CFfIox/Yusj6wEqdx1GFEOtGX/NxuM5VcwKm8cYMG6ogPr9GbeSE2', '776565279', 'customer', NULL, 0, NULL, '2026-09-19 11:38:11', '2026-09-20 14:07:42'),
(12, 'وهيب', 'wwaw@wwaw.com', '$2y$12$7fYA6Suu0tM9Za69TQK3Uer6whLz.cE.9RJ/Duaiv7YsdfQASKYkC', '776565276', 'customer', NULL, 0, NULL, '2026-09-19 11:50:23', '2026-09-19 11:50:34');

-- --------------------------------------------------------

--
-- بنية الجدول `categories`
--

CREATE TABLE `categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Painkillers', 'Medications for pain relief and fever reduction.', '2026-08-30 16:26:39', '2026-08-30 16:26:39'),
(2, 'Antibiotics', 'Drugs used to treat bacterial infections.', '2026-08-30 16:26:39', '2026-08-30 16:26:39'),
(3, 'Cough & Cold', 'Remedies for cough, cold, and flu symptoms.', '2026-08-30 16:26:39', '2026-08-30 16:26:39'),
(4, 'Allergy', 'Antihistamines and allergy relief products.', '2026-08-30 16:26:39', '2026-08-30 16:26:39'),
(5, 'Vitamins & Supplements', 'Nutritional supplements and vitamins.', '2026-08-30 16:26:39', '2026-08-30 16:26:39'),
(6, 'waheeb', NULL, '2026-08-31 12:07:56', '2026-08-31 12:07:56');

-- --------------------------------------------------------

--
-- بنية الجدول `countries`
--

CREATE TABLE `countries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `code` varchar(2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `countries`
--

INSERT INTO `countries` (`id`, `name_ar`, `name_en`, `code`, `created_at`, `updated_at`) VALUES
(1, 'اليمن', 'Yemn', 'YE', '2026-09-15 11:46:40', '2026-09-15 11:46:40'),
(2, 'السعودية', 'saud', 'SU', '2026-09-15 11:49:34', '2026-09-15 11:49:34');

-- --------------------------------------------------------

--
-- بنية الجدول `dashboard_users`
--

CREATE TABLE `dashboard_users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','manager') NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `dashboard_users`
--

INSERT INTO `dashboard_users` (`id`, `name`, `email`, `password`, `role`, `remember_token`, `created_at`, `updated_at`) VALUES
(5, 'System Administrator', 'admin@smartpharmacy.test', '$2y$12$trNOIb2OEtugjKVIX4WliezjWrzuUHJNVgeplZmQ6om8UiBE0P9PC', 'admin', NULL, '2026-08-30 16:26:40', '2026-08-30 16:26:40'),
(6, 'waheeb', 'www@ww.com', '$2y$12$bDie6YmYPvt.RbdZbQASHex4TPDKrD.iovQERAJyzYcy23s7H4sSC', 'admin', NULL, '2026-08-31 11:57:28', '2026-08-31 11:57:28');

-- --------------------------------------------------------

--
-- بنية الجدول `governorates`
--

CREATE TABLE `governorates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `country_id` bigint(20) UNSIGNED NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `governorates`
--

INSERT INTO `governorates` (`id`, `country_id`, `name_ar`, `name_en`, `created_at`, `updated_at`) VALUES
(1, 1, 'صنعاء', 'Sana\'a', '2026-09-15 11:47:33', '2026-09-15 11:47:33'),
(2, 1, 'تعز', 'Taiz', '2026-09-15 11:48:30', '2026-09-15 11:48:30'),
(3, 2, 'جدة', 'jdea', '2026-09-15 11:50:14', '2026-09-15 11:50:14'),
(4, 2, 'الرياض', 'Ryed', '2026-09-15 11:50:39', '2026-09-15 11:50:39');

-- --------------------------------------------------------

--
-- بنية الجدول `medicines`
--

CREATE TABLE `medicines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `category_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `generic_name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `manufacturer` varchar(255) DEFAULT NULL,
  `dosage_form` varchar(255) DEFAULT NULL,
  `strength` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `discount_percentage` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `quantity` int(11) DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT 1,
  `requires_prescription` tinyint(1) NOT NULL DEFAULT 0,
  `expiration_date` date DEFAULT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `medicines`
--

INSERT INTO `medicines` (`id`, `category_id`, `name`, `generic_name`, `description`, `manufacturer`, `dosage_form`, `strength`, `price`, `discount_percentage`, `quantity`, `is_available`, `requires_prescription`, `expiration_date`, `barcode`, `image_path`, `created_at`, `updated_at`) VALUES
(6, 5, 'Vitamin C 1000mg', NULL, 'Immune system support.', NULL, NULL, NULL, 14.99, 15, 99, 1, 0, '2028-01-31', '1234567890128', '/storage/medicine_catalog/ULFXOzHL5wkAmobbfRyfoxbrsRsoBdxc5j2OFBWs.jpg', '2026-08-30 16:26:40', '2026-09-20 13:58:25'),
(7, 3, 'وهيب', NULL, NULL, 'ww', 'ww', '500m', NULL, 0, 109, 1, 0, NULL, NULL, '/storage/medicine_catalog/03KbvfekhuV1LHpxJ99LYKRLzmv9X2Fnc7t2netd.jpg', '2026-08-31 12:02:48', '2026-09-19 12:02:40'),
(8, 6, 'PortB', 'portA', NULL, NULL, 'ww', '500m', NULL, 0, 109, 1, 0, NULL, NULL, '/storage/medicine_catalog/yc002T7Aj65DW9hIVp07ZUM6Hl2nQavBndVtVPhw.jpg', '2026-08-31 12:26:07', '2026-09-19 10:54:55'),
(9, 4, 'بارسيتامول', NULL, 'يستخدم لتخفيف الالم', NULL, 'Tabel', '500m', NULL, 0, 0, 1, 0, NULL, '1111', '/storage/medicine_catalog/H2nu0rld7lr3nnxk86f5DGwaViQx6fOu08ft8QZy.jpg', '2026-09-14 14:58:35', '2026-09-20 13:59:49');

-- --------------------------------------------------------

--
-- بنية الجدول `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2026_08_05_000001_create_users_table', 1),
(2, '2026_08_05_000002_create_pharmacies_table', 1),
(3, '2026_08_05_000003_create_categories_table', 1),
(4, '2026_08_05_000004_create_medicines_table', 1),
(5, '2026_08_05_000005_create_pharmacy_medicines_table', 1),
(6, '2026_08_05_000006_create_offers_table', 1),
(7, '2026_08_05_000007_create_orders_table', 1),
(8, '2026_08_05_000008_create_order_items_table', 1),
(9, '2026_08_05_000009_create_notifications_table', 1),
(10, '2026_08_05_000010_create_activity_logs_table', 1),
(11, '2026_08_05_000011_create_settings_table', 1),
(12, '2026_08_05_000012_add_inventory_and_pharmacy_images', 1),
(13, '2026_08_08_000001_update_orders_status_enum_add_preparing', 1),
(14, '2026_08_10_000001_add_license_number_to_pharmacies_table', 1),
(15, '2026_08_10_000002_add_pending_pharmacy_status', 1),
(16, '2026_08_11_000001_prepare_admin_dashboard', 1),
(17, '2026_08_11_000002_add_contact_details_to_settings_table', 1),
(18, '2026_08_24_000001_add_catalog_fields_to_medicines_table', 1),
(19, '2026_08_24_000002_add_owner_fields_to_pharmacy_medicines_table', 1),
(20, '2026_08_24_000003_backfill_pharmacy_medicine_availability', 1),
(21, '2026_08_24_000004_add_unique_pharmacy_medicine_link', 1),
(22, '2026_09_02_000001_add_avatar_path_to_users_table', 2),
(23, '2026_09_03_000001_add_donation_flags_to_pharmacy_medicines_table', 3),
(24, '2026_09_09_000001_create_app_users_table', 4),
(25, '2026_09_09_000002_create_dashboard_users_table', 4),
(26, '2026_09_09_000003_migrate_existing_users_to_separate_tables', 4),
(27, '2026_09_09_000004_remove_legacy_users_table', 5),
(28, '2026_09_09_000005_add_active_status_to_app_users_table', 6),
(29, '2026_09_09_000006_add_trial_to_app_users_table', 7),
(30, '2026_09_09_000007_backfill_pharmacy_owner_trials', 8),
(31, '2026_09_09_000008_create_packages_table', 9),
(32, '2026_09_09_000009_make_offer_pharmacy_optional', 9),
(33, '2026_09_11_000001_create_password_reset_tokens_table', 10),
(34, '2026_09_12_000001_add_manual_close_to_pharmacies_table', 11),
(35, '2026_09_12_000002_add_manual_status_to_pharmacies_table', 12),
(36, '2026_09_12_000003_set_pharmacy_open_defaults', 13),
(37, '2026_09_15_000001_create_countries_table', 14),
(38, '2026_09_15_000002_create_governorates_table', 14);

-- --------------------------------------------------------

--
-- بنية الجدول `notifications`
--

CREATE TABLE `notifications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `pharmacy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `data` text NOT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `pharmacy_id`, `type`, `data`, `read_at`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 'order.requested', '{\"order_id\":1,\"message\":\"A customer requested a medicine.\"}', NULL, '2026-08-31 14:26:56', '2026-08-31 14:26:56'),
(2, 1, 1, 'order.cancelled', '{\"order_id\":1,\"message\":\"Customer cancelled the order\"}', NULL, '2026-08-31 14:27:07', '2026-08-31 14:27:07'),
(3, 1, 1, 'order.requested', '{\"order_id\":2,\"message\":\"A customer requested a medicine.\"}', NULL, '2026-08-31 14:27:20', '2026-08-31 14:27:20'),
(4, 3, 1, 'order.status_updated', '{\"order_id\":2,\"status\":\"accepted\",\"message\":\"Order status updated\"}', NULL, '2026-08-31 14:32:38', '2026-08-31 14:32:38'),
(5, 1, 1, 'order.requested', '{\"order_id\":3,\"message\":\"A customer requested a medicine.\"}', NULL, '2026-09-01 15:00:53', '2026-09-01 15:00:53'),
(6, 1, 1, 'order.requested', '{\"order_id\":4,\"message\":\"A customer requested a medicine.\"}', NULL, '2026-09-02 12:09:49', '2026-09-02 12:09:49'),
(7, 8, 2, 'order.created', '{\"order_id\":5,\"message\":\"New pickup order placed\"}', NULL, '2026-09-02 14:11:01', '2026-09-02 14:11:01'),
(8, 1, 1, 'order.created', '{\"order_id\":6,\"message\":\"New pickup order placed\"}', NULL, '2026-09-02 14:15:03', '2026-09-02 14:15:03'),
(9, 1, 1, 'order.cancelled', '{\"order_id\":3,\"message\":\"Customer cancelled the order\"}', NULL, '2026-09-02 14:21:27', '2026-09-02 14:21:27'),
(10, 1, 1, 'order.requested', '{\"order_id\":7,\"message\":\"A customer requested a medicine.\"}', NULL, '2026-09-02 15:09:19', '2026-09-02 15:09:19'),
(11, 1, 1, 'order.requested', '{\"order_id\":8,\"message\":\"A customer requested an offer.\"}', NULL, '2026-09-04 14:09:17', '2026-09-04 14:09:17'),
(12, 8, 2, 'order.created', '{\"order_id\":9,\"message\":\"New pickup order placed\"}', NULL, '2026-09-11 14:31:34', '2026-09-11 14:31:34'),
(13, 8, 2, 'order.cancelled', '{\"order_id\":9,\"message\":\"Customer cancelled the order\"}', NULL, '2026-09-11 14:32:37', '2026-09-11 14:32:37'),
(14, 3, 1, 'order.status_updated', '{\"order_id\":8,\"status\":\"delivered\",\"message\":\"Order status updated\"}', NULL, '2026-09-11 14:36:55', '2026-09-11 14:36:55'),
(15, 1, 1, 'order.created', '{\"order_id\":10,\"message\":\"New pickup order placed\"}', NULL, '2026-09-14 11:31:58', '2026-09-14 11:31:58'),
(16, 8, 2, 'order.cancelled', '{\"order_id\":5,\"message\":\"Customer cancelled the order\"}', NULL, '2026-09-14 11:47:38', '2026-09-14 11:47:38'),
(17, 1, 1, 'order.cancelled', '{\"order_id\":6,\"message\":\"Customer cancelled the order\"}', NULL, '2026-09-14 11:47:41', '2026-09-14 11:47:41'),
(18, 1, 1, 'order.cancelled', '{\"order_id\":4,\"message\":\"Customer cancelled the order\"}', NULL, '2026-09-14 11:47:42', '2026-09-14 11:47:42'),
(19, 8, 2, 'order.created', '{\"order_id\":11,\"message\":\"New pickup order placed\"}', NULL, '2026-09-14 12:07:21', '2026-09-14 12:07:21'),
(20, 1, 1, 'order.created', '{\"order_id\":12,\"message\":\"New pickup order placed\"}', NULL, '2026-09-14 14:33:34', '2026-09-14 14:33:34'),
(21, 1, 1, 'order.cancelled', '{\"order_id\":10,\"message\":\"Customer cancelled the order\"}', NULL, '2026-09-14 14:37:05', '2026-09-14 14:37:05'),
(22, 1, 1, 'order.created', '{\"order_id\":13,\"message\":\"New pickup order placed\"}', NULL, '2026-09-14 15:38:22', '2026-09-14 15:38:22'),
(23, 8, 2, 'order.created', '{\"order_id\":14,\"message\":\"New pickup order placed\"}', NULL, '2026-09-19 10:54:55', '2026-09-19 10:54:55'),
(24, 3, 1, 'order.status_updated', '{\"order_id\":12,\"status\":\"accepted\",\"message\":\"Order status updated\"}', NULL, '2026-09-19 10:55:37', '2026-09-19 10:55:37'),
(25, 3, 1, 'order.status_updated', '{\"order_id\":7,\"status\":\"accepted\",\"message\":\"Order status updated\"}', NULL, '2026-09-19 10:56:15', '2026-09-19 10:56:15'),
(26, 3, 1, 'order.status_updated', '{\"order_id\":13,\"status\":\"accepted\",\"message\":\"Order status updated\"}', NULL, '2026-09-19 10:58:38', '2026-09-19 10:58:38'),
(27, 3, 1, 'order.status_updated', '{\"order_id\":13,\"status\":\"preparing\",\"message\":\"Order status updated\"}', NULL, '2026-09-19 10:58:40', '2026-09-19 10:58:40'),
(28, 8, 2, 'order.created', '{\"order_id\":15,\"message\":\"New pickup order placed\"}', NULL, '2026-09-19 11:08:29', '2026-09-19 11:08:29'),
(29, 1, 1, 'order.created', '{\"order_id\":16,\"message\":\"New pickup order placed\"}', NULL, '2026-09-19 11:09:22', '2026-09-19 11:09:22'),
(30, 8, 2, 'order.created', '{\"order_id\":17,\"message\":\"New pickup order placed\"}', NULL, '2026-09-19 12:02:40', '2026-09-19 12:02:40'),
(31, 10, 1, 'order.status_updated', '{\"order_id\":16,\"status\":\"rejected\",\"message\":\"Order status updated\"}', NULL, '2026-09-19 12:03:25', '2026-09-19 12:03:25'),
(32, 1, 1, 'order.created', '{\"order_id\":18,\"message\":\"New pickup order placed\"}', NULL, '2026-09-20 13:38:33', '2026-09-20 13:38:33'),
(33, 1, 1, 'order.created', '{\"order_id\":19,\"message\":\"New pickup order placed\"}', NULL, '2026-09-20 13:39:37', '2026-09-20 13:39:37'),
(34, 1, 1, 'order.created', '{\"order_id\":20,\"message\":\"New pickup order placed\"}', NULL, '2026-09-20 13:58:25', '2026-09-20 13:58:25'),
(35, 1, 1, 'order.created', '{\"order_id\":21,\"message\":\"New pickup order placed\"}', NULL, '2026-09-20 13:59:49', '2026-09-20 13:59:49'),
(36, 3, 1, 'order.status_updated', '{\"order_id\":21,\"status\":\"accepted\",\"message\":\"Order status updated\"}', NULL, '2026-09-20 14:00:09', '2026-09-20 14:00:09'),
(37, 3, 1, 'order.status_updated', '{\"order_id\":21,\"status\":\"preparing\",\"message\":\"Order status updated\"}', NULL, '2026-09-20 14:00:22', '2026-09-20 14:00:22'),
(38, 3, 1, 'order.status_updated', '{\"order_id\":21,\"status\":\"ready\",\"message\":\"Order status updated\"}', NULL, '2026-09-20 14:00:24', '2026-09-20 14:00:24'),
(39, 3, 1, 'order.status_updated', '{\"order_id\":21,\"status\":\"delivered\",\"message\":\"Order status updated\"}', NULL, '2026-09-20 14:00:26', '2026-09-20 14:00:26');

-- --------------------------------------------------------

--
-- بنية الجدول `offers`
--

CREATE TABLE `offers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pharmacy_id` bigint(20) UNSIGNED DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `discount_percentage` smallint(5) UNSIGNED NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `offers`
--

INSERT INTO `offers` (`id`, `pharmacy_id`, `title`, `description`, `discount_percentage`, `start_date`, `end_date`, `image_path`, `created_at`, `updated_at`) VALUES
(1, 1, 'Winter Wellness Sale', '20% off all vitamins and supplements.', 20, '2026-08-30', '2026-09-30', NULL, '2026-08-30 16:26:40', '2026-08-30 16:26:40'),
(2, 1, 'Buy One Get One Free', 'BOGO on selected painkillers.', 50, '2026-08-30', '2026-09-06', NULL, '2026-08-30 16:26:40', '2026-08-30 16:26:40'),
(4, 1, 'wooow', NULL, 30, '2026-09-02', '2026-10-02', '/storage/offer_images/ecJgldHa57rsia6RahExyWTFqEDgwgeCWVpDw7hk.jpg', '2026-09-02 15:25:36', '2026-09-02 15:25:36'),
(5, 1, 'mooom', NULL, 50, '2026-09-02', '2026-10-02', '/storage/offer_images/eDCKUbsfmLcqVvncAWM9QP7M38BpKZndRc8dDMqm.jpg', '2026-09-02 15:28:25', '2026-09-02 15:28:25');

-- --------------------------------------------------------

--
-- بنية الجدول `orders`
--

CREATE TABLE `orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `pharmacy_id` bigint(20) UNSIGNED NOT NULL,
  `status` enum('pending','accepted','rejected','preparing','ready','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `total_price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `pharmacy_id`, `status`, `total_price`, `created_at`, `updated_at`) VALUES
(2, 3, 1, 'accepted', 0.00, '2026-08-31 14:27:20', '2026-08-31 14:32:38'),
(4, 3, 1, 'cancelled', 0.00, '2026-09-02 12:09:49', '2026-09-14 11:47:42'),
(5, 3, 2, 'cancelled', 0.00, '2026-09-02 14:11:01', '2026-09-14 11:47:38'),
(6, 3, 1, 'cancelled', 12.74, '2026-09-02 14:15:03', '2026-09-14 11:47:41'),
(7, 3, 1, 'accepted', 0.00, '2026-09-02 15:09:19', '2026-09-19 10:56:15'),
(8, 3, 1, 'delivered', 0.00, '2026-09-04 14:09:17', '2026-09-11 14:36:55'),
(9, 3, 2, 'cancelled', 0.00, '2026-09-11 14:31:34', '2026-09-11 14:32:37'),
(10, 3, 1, 'cancelled', 12.74, '2026-09-14 11:31:58', '2026-09-14 14:37:05'),
(11, 3, 2, 'pending', 12.74, '2026-09-14 12:07:21', '2026-09-14 12:07:21'),
(12, 3, 1, 'accepted', 12.74, '2026-09-14 14:33:34', '2026-09-19 10:55:37'),
(13, 3, 1, 'preparing', 0.00, '2026-09-14 15:38:22', '2026-09-19 10:58:40'),
(14, 3, 2, 'pending', 0.00, '2026-09-19 10:54:55', '2026-09-19 10:54:55'),
(15, 10, 2, 'pending', 0.00, '2026-09-19 11:08:29', '2026-09-19 11:08:29'),
(16, 10, 1, 'rejected', 12.74, '2026-09-19 11:09:22', '2026-09-19 12:03:25'),
(17, 3, 2, 'pending', 0.00, '2026-09-19 12:02:40', '2026-09-19 12:02:40'),
(18, 3, 1, 'pending', 0.00, '2026-09-20 13:38:33', '2026-09-20 13:38:33'),
(19, 3, 1, 'pending', 0.00, '2026-09-20 13:39:37', '2026-09-20 13:39:37'),
(20, 3, 1, 'pending', 340.00, '2026-09-20 13:58:25', '2026-09-20 13:58:25'),
(21, 3, 1, 'delivered', 500.00, '2026-09-20 13:59:49', '2026-09-20 14:00:26');

-- --------------------------------------------------------

--
-- بنية الجدول `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `medicine_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `medicine_id`, `quantity`, `price`, `created_at`, `updated_at`) VALUES
(2, 2, 8, 1, 0.00, '2026-08-31 14:27:20', '2026-08-31 14:27:20'),
(4, 4, 7, 1, 0.00, '2026-09-02 12:09:49', '2026-09-02 12:09:49'),
(5, 5, 8, 1, 0.00, '2026-09-02 14:11:01', '2026-09-02 14:11:01'),
(6, 6, 6, 1, 12.74, '2026-09-02 14:15:03', '2026-09-02 14:15:03'),
(7, 7, 8, 1, 0.00, '2026-09-02 15:09:19', '2026-09-02 15:09:19'),
(8, 9, 8, 1, 0.00, '2026-09-11 14:31:34', '2026-09-11 14:31:34'),
(9, 10, 6, 1, 12.74, '2026-09-14 11:31:58', '2026-09-14 11:31:58'),
(10, 11, 6, 1, 12.74, '2026-09-14 12:07:21', '2026-09-14 12:07:21'),
(11, 12, 7, 1, 0.00, '2026-09-14 14:33:34', '2026-09-14 14:33:34'),
(12, 12, 6, 1, 12.74, '2026-09-14 14:33:34', '2026-09-14 14:33:34'),
(13, 13, 9, 1, 0.00, '2026-09-14 15:38:22', '2026-09-14 15:38:22'),
(14, 14, 8, 1, 0.00, '2026-09-19 10:54:55', '2026-09-19 10:54:55'),
(15, 15, 7, 1, 0.00, '2026-09-19 11:08:29', '2026-09-19 11:08:29'),
(16, 16, 6, 1, 12.74, '2026-09-19 11:09:22', '2026-09-19 11:09:22'),
(17, 17, 7, 1, 0.00, '2026-09-19 12:02:40', '2026-09-19 12:02:40'),
(18, 18, 9, 1, 0.00, '2026-09-20 13:38:33', '2026-09-20 13:38:33'),
(19, 19, 9, 2, 0.00, '2026-09-20 13:39:37', '2026-09-20 13:39:37'),
(20, 20, 6, 1, 340.00, '2026-09-20 13:58:25', '2026-09-20 13:58:25'),
(21, 21, 9, 1, 500.00, '2026-09-20 13:59:49', '2026-09-20 13:59:49');

-- --------------------------------------------------------

--
-- بنية الجدول `packages`
--

CREATE TABLE `packages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration_in_days` int(10) UNSIGNED NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `packages`
--

INSERT INTO `packages` (`id`, `name`, `price`, `duration_in_days`, `description`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Monthly', 5.00, 30, 'دعم مجاني على مدار الساعة طوال أيام الأسبوع\r\nتنزيل قاعدة البيانات\r\nبريد إلكتروني للصيانة\r\nحركة مرور غير محدودة', 1, '2026-09-09 14:24:56', '2026-09-10 14:34:01'),
(2, 'Yearly', 100.00, 365, 'Yearly access with better value.', 1, '2026-09-09 14:24:56', '2026-09-10 14:24:28'),
(3, 'VIP', 300.00, 365, 'Premium access for high-volume pharmacies.', 1, '2026-09-09 14:24:56', '2026-09-09 14:24:56');

-- --------------------------------------------------------

--
-- بنية الجدول `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `password_reset_tokens`
--

INSERT INTO `password_reset_tokens` (`email`, `token`, `created_at`) VALUES
('wa@w.com', '$2y$12$wsuiVAH1lUPquSkRznSmcuf/a9P1LPevJhslolug3nk5Q1FkDHTwK', '2026-09-20 14:19:32'),
('www@w.com', '$2y$12$8NxbwM8czuUEKYhMSKftB.t5Knd/2WmuBVNt/pVwiqLq9w8vbGgPG', '2026-09-11 12:15:33');

-- --------------------------------------------------------

--
-- بنية الجدول `pharmacies`
--

CREATE TABLE `pharmacies` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` text DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `license_number` varchar(255) DEFAULT NULL,
  `latitude` double DEFAULT NULL,
  `longitude` double DEFAULT NULL,
  `opening_time` time NOT NULL DEFAULT '08:00:00',
  `closing_time` time NOT NULL DEFAULT '22:00:00',
  `is_manually_closed` tinyint(1) NOT NULL DEFAULT 0,
  `manual_status` varchar(255) DEFAULT 'open',
  `status` enum('open','closed') NOT NULL DEFAULT 'open',
  `images` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`images`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `pharmacies`
--

INSERT INTO `pharmacies` (`id`, `user_id`, `name`, `address`, `phone`, `license_number`, `latitude`, `longitude`, `opening_time`, `closing_time`, `is_manually_closed`, `manual_status`, `status`, `images`, `created_at`, `updated_at`) VALUES
(1, 1, 'HealthPlus Ph', 'صنعا', '776565278', NULL, 15.303025599482, 44.156790599227, '08:40:00', '11:30:00', 0, 'open', 'open', '[\"\\/storage\\/pharmacy_images\\/0TN8nTMmLu4i3vi6mIflD1AUivvQXHh6VuiNImCp.jpg\",\"\\/storage\\/pharmacy_images\\/EkqeSSWbI0thbBYQoNnJfd2w3ciUfLz7ZqHafdH9.jpg\"]', '2026-08-30 16:26:40', '2026-09-14 14:54:20'),
(2, 8, 'live', 'sanaa', '7756562878', '12121', 15.302741340883, 44.159270972013, '08:00:00', '22:00:00', 0, 'open', 'open', '[\"\\/storage\\/pharmacy_images\\/rm7goPtTAll4zLAv95JoisdnvfJBMYjoislMlsvU.jpg\"]', '2026-09-01 15:39:31', '2026-09-14 14:24:42'),
(3, 9, 'live2', 'العشاش', '77777777', '123221', 15.299831791258, 44.161719493568, '08:00:00', '22:00:00', 0, 'open', 'open', '[\"\\/storage\\/pharmacy_images\\/sJThccDqUYTNq7OC9S4Ksoeg1wDC4ebt8KwjofVl.jpg\",\"\\/storage\\/pharmacy_images\\/KE3m81AetUuzHajT7kwPPmS0hOugN1IJEJsT2jy8.jpg\",\"\\/storage\\/pharmacy_images\\/Vq9BNf0su5OChSDkZZpSJdNSrf1rApcPaglXIN25.jpg\"]', '2026-09-12 12:11:57', '2026-09-14 14:29:38');

-- --------------------------------------------------------

--
-- بنية الجدول `pharmacy_medicines`
--

CREATE TABLE `pharmacy_medicines` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `pharmacy_id` bigint(20) UNSIGNED NOT NULL,
  `medicine_id` bigint(20) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `discount_percentage` smallint(5) UNSIGNED NOT NULL DEFAULT 0,
  `expiration_date` date DEFAULT NULL,
  `barcode` varchar(255) DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT 0,
  `is_donation` tinyint(1) NOT NULL DEFAULT 0,
  `is_near_expiry` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `pharmacy_medicines`
--

INSERT INTO `pharmacy_medicines` (`id`, `pharmacy_id`, `medicine_id`, `quantity`, `price`, `discount_percentage`, `expiration_date`, `barcode`, `is_available`, `is_donation`, `is_near_expiry`, `created_at`, `updated_at`) VALUES
(1, 1, 6, 100, 400.00, 15, '2028-01-31', '1234567890128', 1, 0, 0, '2026-08-31 12:01:47', '2026-09-20 13:58:25'),
(2, 1, 7, 111, 400.00, 0, NULL, NULL, 1, 0, 0, '2026-08-31 12:02:48', '2026-09-14 14:33:34'),
(3, 1, 8, 333, 400.00, 0, '2026-08-18', NULL, 1, 0, 0, '2026-08-31 12:27:51', '2026-09-01 15:46:10'),
(4, 2, 8, 109, 300.00, 0, '2026-09-23', NULL, 1, 0, 0, '2026-09-01 15:40:11', '2026-09-19 10:54:55'),
(5, 2, 6, 100, 300.00, 0, '2028-01-31', '1234567890128', 1, 0, 0, '2026-09-01 15:40:57', '2026-09-14 12:07:21'),
(6, 2, 7, 109, 300.00, 0, NULL, NULL, 1, 0, 0, '2026-09-01 15:41:23', '2026-09-19 12:02:40'),
(7, 3, 6, 55, 500.00, 15, '2028-01-31', '1234567890128', 1, 0, 0, '2026-09-12 14:22:41', '2026-09-13 15:50:12'),
(8, 3, 7, 111, 500.00, 50, '2026-09-21', NULL, 1, 0, 0, '2026-09-12 14:23:34', '2026-09-13 15:50:22'),
(9, 3, 8, 109, 500.00, 10, '2026-09-29', NULL, 1, 0, 0, '2026-09-12 14:24:46', '2026-09-13 15:50:33'),
(10, 1, 9, 0, 500.00, 0, NULL, '1111', 1, 0, 0, '2026-09-14 15:11:57', '2026-09-20 13:59:49');

-- --------------------------------------------------------

--
-- بنية الجدول `settings`
--

CREATE TABLE `settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `app_name` varchar(255) NOT NULL DEFAULT 'Smart Pharmacy System',
  `logo_path` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `contact_phone` varchar(255) DEFAULT NULL,
  `contact_address` text DEFAULT NULL,
  `privacy_policy` text DEFAULT NULL,
  `terms_conditions` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `settings`
--

INSERT INTO `settings` (`id`, `app_name`, `logo_path`, `contact_email`, `contact_phone`, `contact_address`, `privacy_policy`, `terms_conditions`, `created_at`, `updated_at`) VALUES
(1, 'Smart Pharmacy System', NULL, NULL, NULL, NULL, NULL, NULL, '2026-09-09 11:03:01', '2026-09-09 11:03:01');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `activity_logs_pharmacy_id_foreign` (`pharmacy_id`),
  ADD KEY `activity_logs_user_id_foreign` (`user_id`),
  ADD KEY `activity_logs_dashboard_user_id_foreign` (`dashboard_user_id`);

--
-- Indexes for table `app_users`
--
ALTER TABLE `app_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `app_users_email_unique` (`email`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `categories_name_unique` (`name`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `countries_code_unique` (`code`);

--
-- Indexes for table `dashboard_users`
--
ALTER TABLE `dashboard_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dashboard_users_email_unique` (`email`);

--
-- Indexes for table `governorates`
--
ALTER TABLE `governorates`
  ADD PRIMARY KEY (`id`),
  ADD KEY `governorates_country_id_foreign` (`country_id`);

--
-- Indexes for table `medicines`
--
ALTER TABLE `medicines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `medicines_category_id_foreign` (`category_id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifications_pharmacy_id_foreign` (`pharmacy_id`),
  ADD KEY `notifications_user_id_foreign` (`user_id`);

--
-- Indexes for table `offers`
--
ALTER TABLE `offers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `offers_pharmacy_id_foreign` (`pharmacy_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `orders_pharmacy_id_foreign` (`pharmacy_id`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_medicine_id_foreign` (`medicine_id`);

--
-- Indexes for table `packages`
--
ALTER TABLE `packages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `pharmacies`
--
ALTER TABLE `pharmacies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pharmacies_user_id_foreign` (`user_id`);

--
-- Indexes for table `pharmacy_medicines`
--
ALTER TABLE `pharmacy_medicines`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pharmacy_medicines_pharmacy_medicine_unique` (`pharmacy_id`,`medicine_id`),
  ADD KEY `pharmacy_medicines_medicine_id_foreign` (`medicine_id`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `activity_logs`
--
ALTER TABLE `activity_logs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `app_users`
--
ALTER TABLE `app_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `dashboard_users`
--
ALTER TABLE `dashboard_users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `governorates`
--
ALTER TABLE `governorates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `medicines`
--
ALTER TABLE `medicines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `offers`
--
ALTER TABLE `offers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `packages`
--
ALTER TABLE `packages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pharmacies`
--
ALTER TABLE `pharmacies`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `pharmacy_medicines`
--
ALTER TABLE `pharmacy_medicines`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `activity_logs`
--
ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_dashboard_user_id_foreign` FOREIGN KEY (`dashboard_user_id`) REFERENCES `dashboard_users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `activity_logs_pharmacy_id_foreign` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `activity_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `app_users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `governorates`
--
ALTER TABLE `governorates`
  ADD CONSTRAINT `governorates_country_id_foreign` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `medicines`
--
ALTER TABLE `medicines`
  ADD CONSTRAINT `medicines_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_pharmacy_id_foreign` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `app_users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `offers`
--
ALTER TABLE `offers`
  ADD CONSTRAINT `offers_pharmacy_id_foreign` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_pharmacy_id_foreign` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `app_users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_medicine_id_foreign` FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `pharmacies`
--
ALTER TABLE `pharmacies`
  ADD CONSTRAINT `pharmacies_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `app_users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `pharmacy_medicines`
--
ALTER TABLE `pharmacy_medicines`
  ADD CONSTRAINT `pharmacy_medicines_medicine_id_foreign` FOREIGN KEY (`medicine_id`) REFERENCES `medicines` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `pharmacy_medicines_pharmacy_id_foreign` FOREIGN KEY (`pharmacy_id`) REFERENCES `pharmacies` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
