USE `ilabdb`;

--
-- Table structure for table `analysis_methods`
--

DROP TABLE IF EXISTS `analysis_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `analysis_methods` (
  `analysis_method_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `canonical_name` varchar(20) NOT NULL COMMENT 'unique machine-readable name',
  `display_name` varchar(100) DEFAULT NULL COMMENT 'human-readable name',
  PRIMARY KEY (`analysis_method_id`),
  UNIQUE KEY `uq_am_canonical_name` (`canonical_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='analysis method lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bioreactor_types`
--

DROP TABLE IF EXISTS `bioreactor_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bioreactor_types` (
  `bioreactor_type_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `bioreactor_type_name` varchar(100) NOT NULL COMMENT 'unique name',
  `number_of_rows` smallint(6) NOT NULL COMMENT 'for microwell plates: number of rows',
  `number_of_columns` smallint(6) NOT NULL COMMENT 'for microwell plates: number of columns',
  `capacity_per_container` decimal(18,6) DEFAULT NULL COMMENT 'capacity [ml]',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`bioreactor_type_id`),
  UNIQUE KEY `uq_bioreactor_type_name` (`bioreactor_type_name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='bioreactor type lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bioreactors`
--

DROP TABLE IF EXISTS `bioreactors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bioreactors` (
  `bioreactor_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `run_id` bigint(20) NOT NULL COMMENT 'references table runs',
  `bioreactor_number` smallint(6) NOT NULL COMMENT 'sequential number of bioreactor, starting with 1',
  `bioreactor_type_id` smallint(6) NOT NULL COMMENT 'references table bioreactor_types',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`bioreactor_id`),
  KEY `bioreactor_type_id` (`bioreactor_type_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=745 DEFAULT CHARSET=utf8 COMMENT='bioreactor configuration of a run';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `configuration`
--

DROP TABLE IF EXISTS `configuration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `configuration` (
  `parameter_name` varchar(50) NOT NULL COMMENT 'name of the parameter',
  `parameter_value` varchar(4000) DEFAULT NULL COMMENT 'value of the parameter',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`parameter_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='global configuration';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `device_properties`
--

DROP TABLE IF EXISTS `device_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `device_properties` (
  `device_id` smallint(6) NOT NULL COMMENT 'references table devices',
  `property_name` varchar(100) NOT NULL COMMENT 'property name',
  `property_value` varchar(200) NOT NULL COMMENT 'property value',
  PRIMARY KEY (`device_id`,`property_name`),
  KEY `device_id` (`device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='device properties';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `devices` (
  `device_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `canonical_name` varchar(20) NOT NULL COMMENT 'machine-readable name',
  `display_name` varchar(100) NOT NULL COMMENT 'human-readable name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`device_id`),
  UNIQUE KEY `uq_devices_canonical_name` (`canonical_name`),
  UNIQUE KEY `uq_device_name` (`display_name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='device lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dmp_device_properties`
--

DROP TABLE IF EXISTS `dmp_device_properties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dmp_device_properties` (
  `property_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'property name',
  `device_id` smallint(6) NOT NULL COMMENT 'references table devices',
  `property_type_id` smallint(6) NOT NULL,
  `property_value` varchar(400) NOT NULL COMMENT 'property value',
  PRIMARY KEY (`property_id`),
  KEY `device_id` (`device_id`),
  KEY `fk_dp_property_type_idx` (`property_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='device properties';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dmp_methode`
--

DROP TABLE IF EXISTS `dmp_methode`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dmp_methode` (
  `dmp_methode_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `dmp_methode_canonical_name` varchar(20) NOT NULL,
  `dmp_methode_display_name` varchar(100) NOT NULL,
  `dmp_methode_description` varchar(4000) DEFAULT NULL,
  `device_id` smallint(6) NOT NULL,
  `dmp_methode_duration` smallint(10) DEFAULT '0',
  `dmp_methode_file` varchar(1000) DEFAULT '""',
  `parent_id` smallint(6) DEFAULT NULL,
  `pause_after` smallint(10) DEFAULT '0',
  `methode_before` smallint(6) DEFAULT NULL,
  `parent_methode_order` smallint(4) DEFAULT NULL,
  PRIMARY KEY (`dmp_methode_id`),
  UNIQUE KEY `dmp_methode_canonical_name_UNIQUE` (`dmp_methode_canonical_name`),
  KEY `device_id_idx` (`device_id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dmp_tasks`
--

DROP TABLE IF EXISTS `dmp_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dmp_tasks` (
  `dmp_taks_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `dmp_methode_id` smallint(6) NOT NULL,
  `dmp_starttime` datetime NOT NULL,
  `dmp_started` tinyint(1) NOT NULL DEFAULT '0',
  `dmp_finished` tinyint(1) NOT NULL DEFAULT '0',
  `run_id` bigint(20) DEFAULT NULL,
  `dmp_task_before` smallint(6) DEFAULT NULL,
  PRIMARY KEY (`dmp_taks_id`),
  KEY `fk_dmpt_methode_id_idx` (`dmp_methode_id`),
  KEY `fk_dmpt_runi_id_idx` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=732 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doe_investigations`
--

DROP TABLE IF EXISTS `doe_investigations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doe_investigations` (
  `doe_investigation_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `run_id` bigint(20) NOT NULL COMMENT 'references table runs',
  `path` varchar(1000) NOT NULL COMMENT 'investigation file path',
  PRIMARY KEY (`doe_investigation_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doe_mappings`
--

DROP TABLE IF EXISTS `doe_mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `doe_mappings` (
  `doe_mapping_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `doe_investigation_id` int(10) unsigned NOT NULL COMMENT 'references table doe_investigations',
  `doe_type` char(1) NOT NULL COMMENT 'f: factor, r: response',
  `doe_abbreviation` varchar(20) NOT NULL COMMENT 'abbreviation of doe factor / response parameter',
  `variable_type_id` smallint(6) NOT NULL COMMENT 'references table variable_types',
  `conversion_factor` decimal(24,12) DEFAULT NULL COMMENT 'conversion factor if internal unit differs',
  PRIMARY KEY (`doe_mapping_id`),
  KEY `doe_investigation_id` (`doe_investigation_id`),
  KEY `variable_type_id` (`variable_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiments` (
  `experiment_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `bioreactor_id` bigint(20) NOT NULL COMMENT 'references table bioreactors',
  `container_number` smallint(6) NOT NULL COMMENT 'sequential number of container, starting with 1',
  `profile_id` bigint(20) DEFAULT NULL COMMENT 'references table profiles',
  `starter_culture_id` int(11) DEFAULT NULL COMMENT 'optional reference to table starter_cultures',
  `inactivation_method_id` smallint(6) DEFAULT NULL COMMENT 'references table inactivation_methods',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  `color` varchar(10) DEFAULT NULL COMMENT 'color in hexadecimal representation (#ARGB)',
  PRIMARY KEY (`experiment_id`),
  KEY `starter_culture_id` (`starter_culture_id`),
  KEY `bioreactor_id` (`bioreactor_id`),
  KEY `profile_id` (`profile_id`),
  KEY `inactivation_method_id` (`inactivation_method_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19661 DEFAULT CHARSET=utf8 COMMENT='experiments';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `folders`
--

DROP TABLE IF EXISTS `folders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `folders` (
  `folder_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `folder_name` varchar(100) NOT NULL COMMENT 'folder name, unique for folders with the same parent',
  `parent_id` int(11) DEFAULT NULL COMMENT 'optional reference to parent folder',
  `group_id` smallint(6) DEFAULT NULL COMMENT 'references table groups',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`folder_id`),
  UNIQUE KEY `uq_folder_name` (`folder_name`,`parent_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `functions`
--

DROP TABLE IF EXISTS `functions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `functions` (
  `function_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `function_name` varchar(100) DEFAULT NULL COMMENT 'unique function name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`function_id`),
  UNIQUE KEY `uq_function_name` (`function_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='iLAB functions (cannot be modified by application)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `group_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `group_name` varchar(100) NOT NULL COMMENT 'unique group name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `uq_group_name` (`group_name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='teams';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hilo_identities`
--

DROP TABLE IF EXISTS `hilo_identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hilo_identities` (
  `entity_name` varchar(100) NOT NULL COMMENT 'name of the nhibernate entity',
  `next_hi_value` bigint(20) DEFAULT NULL COMMENT 'next hi value',
  PRIMARY KEY (`entity_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='used for hilo primary key generation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inactivation_methods`
--

DROP TABLE IF EXISTS `inactivation_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inactivation_methods` (
  `inactivation_method_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `inactivation_method_name` varchar(100) NOT NULL COMMENT 'unique name',
  PRIMARY KEY (`inactivation_method_id`),
  UNIQUE KEY `uq_inactivation_method_name` (`inactivation_method_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='inactivation method lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_model`
--

DROP TABLE IF EXISTS `m_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_model` (
  `m_model_id` smallint(6) NOT NULL,
  `canonical_name` varchar(100) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `model_parent` smallint(6) DEFAULT NULL,
  `description` varchar(1000) DEFAULT NULL,
  PRIMARY KEY (`m_model_id`),
  UNIQUE KEY `m_model_name_UNIQUE` (`display_name`),
  KEY `m_model_parent_idx` (`model_parent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_parameter`
--

DROP TABLE IF EXISTS `m_parameter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_parameter` (
  `m_parameter_id` bigint(20) NOT NULL,
  `canonical_name` varchar(30) NOT NULL,
  `display_name` varchar(45) NOT NULL,
  `description` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`m_parameter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_parameter_est`
--

DROP TABLE IF EXISTS `m_parameter_est`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_parameter_est` (
  `m_parameter_est_id` bigint(20) NOT NULL,
  `user` smallint(6) NOT NULL,
  `time` datetime NOT NULL,
  `run_id` bigint(20) NOT NULL,
  `m_model_id` smallint(6) NOT NULL,
  PRIMARY KEY (`m_parameter_est_id`),
  KEY `m_parameter_est_run_id_idx` (`run_id`),
  KEY `m_parameter_est_m_model_id_idx` (`m_model_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_parameter_val`
--

DROP TABLE IF EXISTS `m_parameter_val`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_parameter_val` (
  `m_parameter_val_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `m_parameter_id` bigint(20) NOT NULL,
  `m_parameter_est_id` bigint(20) NOT NULL,
  `m_parameter_value` decimal(24,12) NOT NULL,
  PRIMARY KEY (`m_parameter_val_id`),
  KEY `m_parameter_id_idx` (`m_parameter_id`),
  KEY `m_parameter_est_id_idx` (`m_parameter_est_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_sensitivity`
--

DROP TABLE IF EXISTS `m_sensitivity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_sensitivity` (
  `m_sensitivity_id` bigint(20) NOT NULL,
  `m_simulation_type_id` smallint(6) NOT NULL,
  `m_parameter_id` bigint(20) NOT NULL,
  `value` decimal(24,12) NOT NULL,
  PRIMARY KEY (`m_sensitivity_id`),
  KEY `m_sensitivity_m_simulation_type_id_idx` (`m_simulation_type_id`),
  KEY `m_sensitivity_m_parameter_id_idx` (`m_parameter_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_simulation`
--

DROP TABLE IF EXISTS `m_simulation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_simulation` (
  `m_simulation_id` bigint(20) NOT NULL,
  `m_simulation_type_id` smallint(6) NOT NULL,
  `m_parameter_est_id` bigint(20) NOT NULL,
  `value` decimal(24,12) NOT NULL,
  PRIMARY KEY (`m_simulation_id`),
  KEY `m_simulatoin_m_simulation_type_id_idx` (`m_simulation_type_id`),
  KEY `m_simulation_m_parameter_est_id_idx` (`m_parameter_est_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `m_simulation_type`
--

DROP TABLE IF EXISTS `m_simulation_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `m_simulation_type` (
  `m_simulation_type_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `canonical_name` varchar(30) NOT NULL COMMENT 'machine-readable name, unique per scope',
  `display_name` varchar(100) NOT NULL COMMENT 'human-readable name',
  `unit` varchar(20) DEFAULT NULL COMMENT 'unit of variable',
  `lower_limit` decimal(24,12) DEFAULT NULL COMMENT 'minimal value',
  `upper_limit` decimal(24,12) DEFAULT NULL COMMENT 'maximum value',
  PRIMARY KEY (`m_simulation_type_id`),
  UNIQUE KEY `uq_vt_canonical_name` (`canonical_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='simulation type lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measurements_bioreactors`
--

DROP TABLE IF EXISTS `measurements_bioreactors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measurements_bioreactors` (
  `measurement_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `measuring_setup_id` bigint(20) NOT NULL COMMENT 'references table measurements',
  `bioreactor_id` bigint(20) NOT NULL COMMENT 'references table bioreactors',
  `measurement_time` datetime NOT NULL COMMENT 'timestamp',
  `valid` tinyint(4) NOT NULL COMMENT '1: valid, 0: invalid',
  `measured_value` decimal(24,12) DEFAULT NULL COMMENT 'measured value',
  `dilution_factor` int(11) DEFAULT NULL COMMENT 'dilution factor of sample, if applicable',
  `checksum` int(10) unsigned NOT NULL COMMENT 'checksum of the whole record',
  `label` varchar(100) DEFAULT NULL COMMENT 'optional label to identify matching measurements',
  PRIMARY KEY (`measurement_id`),
  KEY `bioreactor_id` (`bioreactor_id`),
  KEY `measuring_setup_id` (`measuring_setup_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1440009 DEFAULT CHARSET=utf8 COMMENT='bioreactor specific measured values';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measurements_experiments`
--

DROP TABLE IF EXISTS `measurements_experiments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measurements_experiments` (
  `measurement_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `measuring_setup_id` bigint(20) NOT NULL COMMENT 'references table measurements',
  `experiment_id` bigint(20) NOT NULL COMMENT 'references table experiments',
  `measurement_time` datetime NOT NULL COMMENT 'timestamp',
  `valid` tinyint(4) NOT NULL COMMENT '1: valid, 0: invalid',
  `measured_value` decimal(24,12) DEFAULT NULL COMMENT 'measured value',
  `dilution_factor` int(11) DEFAULT NULL COMMENT 'dilution factor of sample, if applicable',
  `sampling_id` bigint(20) DEFAULT NULL COMMENT 'references table samplings',
  `checksum` int(10) unsigned NOT NULL COMMENT 'checksum of the whole record',
  `label` varchar(100) DEFAULT NULL COMMENT 'optional label to identify matching measurements',
  PRIMARY KEY (`measurement_id`),
  KEY `experiment_id` (`experiment_id`),
  KEY `measuring_setup_id` (`measuring_setup_id`),
  KEY `sampling_id` (`sampling_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26587589 DEFAULT CHARSET=utf8 COMMENT='experiment specific measured values';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measurements_runs`
--

DROP TABLE IF EXISTS `measurements_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measurements_runs` (
  `measurement_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `measuring_setup_id` bigint(20) NOT NULL COMMENT 'references table measurements',
  `run_id` bigint(20) NOT NULL COMMENT 'references table runs',
  `measurement_time` datetime NOT NULL COMMENT 'timestamp',
  `valid` tinyint(4) NOT NULL COMMENT '1: valid, 0: invalid',
  `measured_value` decimal(24,12) DEFAULT NULL COMMENT 'measured value',
  `dilution_factor` int(11) DEFAULT NULL COMMENT 'dilution factor of sample, if applicable',
  `checksum` int(10) unsigned NOT NULL COMMENT 'checksum of the whole record',
  `label` varchar(100) DEFAULT NULL COMMENT 'optional label to identify matching measurements',
  PRIMARY KEY (`measurement_id`),
  KEY `measuring_setup_id` (`measuring_setup_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=444 DEFAULT CHARSET=utf8 COMMENT='run specific measured values';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `measuring_setup`
--

DROP TABLE IF EXISTS `measuring_setup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `measuring_setup` (
  `measuring_setup_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `run_id` bigint(20) NOT NULL COMMENT 'references table runs',
  `scope` char(1) NOT NULL COMMENT 'e: experiment, b: bioreactor, r: run',
  `variable_type_id` smallint(6) NOT NULL COMMENT 'references table variable_types',
  `device_id` smallint(6) DEFAULT NULL COMMENT 'references table devices',
  `analysis_method_id` smallint(6) DEFAULT NULL COMMENT 'references table analysis_methods',
  PRIMARY KEY (`measuring_setup_id`),
  UNIQUE KEY `uq_measuring_setup` (`run_id`,`scope`,`variable_type_id`),
  KEY `analysis_method_id` (`analysis_method_id`),
  KEY `device_id` (`device_id`),
  KEY `run_id` (`run_id`),
  KEY `variable_type_id` (`variable_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6216 DEFAULT CHARSET=utf8 COMMENT='kind of measurings';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `media`
--

DROP TABLE IF EXISTS `media`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `media` (
  `medium_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `medium_name` varchar(100) NOT NULL COMMENT 'unique name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`medium_id`),
  UNIQUE KEY `uq_medium_name` (`medium_name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COMMENT='medium lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opc_items`
--

DROP TABLE IF EXISTS `opc_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opc_items` (
  `opc_item_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `opc_server_id` smallint(6) NOT NULL COMMENT 'references table opc_servers',
  `server_path` varchar(1000) NOT NULL COMMENT 'A server path to OPC item',
  `client_path` varchar(1000) NOT NULL COMMENT 'A custom path',
  `variable_type_id` smallint(6) NOT NULL COMMENT 'references table variable_types',
  `active` tinyint(4) NOT NULL COMMENT '1: active, 0: inactive',
  `mode` varchar(2) NOT NULL COMMENT 'r: read, w: write, rw: read/write',
  `refresh_cycle` int(11) NOT NULL COMMENT 'time cylce in seconds for requesting the current value. if the value=0 the data changed event will be used.',
  `status` varchar(20) NOT NULL DEFAULT 'unavailable' COMMENT 'current status of the item. Possible values: available, unavailable',
  PRIMARY KEY (`opc_item_id`),
  KEY `opc_server_id` (`opc_server_id`),
  KEY `variable_type_id` (`variable_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='opc items';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opc_servers`
--

DROP TABLE IF EXISTS `opc_servers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opc_servers` (
  `opc_server_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `path` varchar(1000) NOT NULL COMMENT 'path to OPC server',
  `opc_specification_id` smallint(6) NOT NULL COMMENT 'references table opc_specifications',
  `active` tinyint(4) NOT NULL COMMENT '1: active, 0: inactive',
  `username` varchar(100) DEFAULT NULL COMMENT 'username for authentication',
  `password` varchar(100) DEFAULT NULL COMMENT 'password for authentication',
  `domain` varchar(100) DEFAULT NULL COMMENT 'domain for authentication',
  `pms_id` smallint(6) NOT NULL COMMENT 'references the table process_management_systems',
  `status_request_cycle` int(11) NOT NULL COMMENT 'time cycle in seconds for requesting the current status of the OPC server. If value=0 never ask for status',
  `status` varchar(20) NOT NULL DEFAULT 'disconnected' COMMENT 'current status of the server. Possible values: connected, warning, error, disconnected',
  PRIMARY KEY (`opc_server_id`),
  KEY `pms_id` (`pms_id`),
  KEY `opc_specification_id` (`opc_specification_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='opc servers';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `opc_specifications`
--

DROP TABLE IF EXISTS `opc_specifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opc_specifications` (
  `opc_specification_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `opc_id` varchar(60) NOT NULL COMMENT 'official OPC identification',
  `description` varchar(4000) NOT NULL COMMENT 'description',
  PRIMARY KEY (`opc_specification_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='opc specifications';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `organisms`
--

DROP TABLE IF EXISTS `organisms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organisms` (
  `organism_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `organism_name` varchar(100) NOT NULL COMMENT 'unique name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`organism_id`),
  UNIQUE KEY `uq_organism_name` (`organism_name`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8 COMMENT='organisms lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parameter_types`
--

DROP TABLE IF EXISTS `parameter_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameter_types` (
  `parameter_type_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `canonical_name` varchar(30) NOT NULL COMMENT 'machine-readable name',
  `display_name` varchar(100) NOT NULL COMMENT 'human-readable name',
  `datatype` varchar(20) DEFAULT NULL COMMENT 'numeric, string, bool, datetime',
  `unit` varchar(20) DEFAULT NULL COMMENT 'unit of parameter',
  PRIMARY KEY (`parameter_type_id`),
  UNIQUE KEY `uq_pt_canonical_name` (`canonical_name`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8 COMMENT='parameter type lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parameters`
--

DROP TABLE IF EXISTS `parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parameters` (
  `parameter_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `profile_id` bigint(20) NOT NULL COMMENT 'references table profiles',
  `parameter_type_id` smallint(6) NOT NULL COMMENT 'references table parameter_types',
  `scope` char(1) NOT NULL COMMENT 'e: experiment, b: bioreactor, r: run',
  `parameter_value` varchar(4000) DEFAULT NULL COMMENT 'value as string',
  `checksum` int(10) unsigned NOT NULL COMMENT 'checksum of the whole record',
  PRIMARY KEY (`parameter_id`,`profile_id`),
  KEY `profile_id` (`profile_id`),
  KEY `parameter_type_id` (`parameter_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=53580 DEFAULT CHARSET=utf8 COMMENT='process parameters belonging to profiles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `planned_samplings`
--

DROP TABLE IF EXISTS `planned_samplings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `planned_samplings` (
  `planned_sampling_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `profile_id` bigint(20) NOT NULL COMMENT 'references table profiles',
  `sampling_method_id` smallint(6) NOT NULL COMMENT 'references table sampling_methods',
  `cultivation_age` int(11) NOT NULL COMMENT 'time since cultivation start in [s]',
  `sample_volume` decimal(9,3) NOT NULL COMMENT 'volume of sample in [ml]',
  PRIMARY KEY (`planned_sampling_id`),
  KEY `profile_id` (`profile_id`),
  KEY `sampling_method_id` (`sampling_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='planned samplings';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plasmids`
--

DROP TABLE IF EXISTS `plasmids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plasmids` (
  `plasmid_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `plasmid_name` varchar(100) NOT NULL COMMENT 'unique name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`plasmid_id`),
  UNIQUE KEY `uq_plasmid_name` (`plasmid_name`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8 COMMENT='plasmid lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `presens_mb_calibration`
--

DROP TABLE IF EXISTS `presens_mb_calibration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `presens_mb_calibration` (
  `presens_calibration_id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(30) NOT NULL,
  `a_pressure` int(4) NOT NULL,
  `cal0` decimal(4,2) NOT NULL,
  `cal100` decimal(4,2) NOT NULL,
  `lmin` decimal(4,2) NOT NULL,
  `lmax` decimal(4,2) NOT NULL,
  `ph0` decimal(4,2) NOT NULL,
  `dph` decimal(4,2) NOT NULL,
  `temperature_ph` decimal(4,2) NOT NULL,
  `temperature_po2` decimal(4,2) NOT NULL,
  `bestbefor` date DEFAULT NULL,
  `input_date` date DEFAULT NULL,
  PRIMARY KEY (`presens_calibration_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `process_management_systems`
--

DROP TABLE IF EXISTS `process_management_systems`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `process_management_systems` (
  `pms_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `pms_name` varchar(100) NOT NULL COMMENT 'unique name',
  `single_concurrent_run` tinyint(4) NOT NULL COMMENT '1: pms can execute one run concurrently, 0: pms can execute multiple runs concurrently',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`pms_id`),
  UNIQUE KEY `uq_pms_name` (`pms_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='pms lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `profiles`
--

DROP TABLE IF EXISTS `profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `profiles` (
  `profile_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `profile_name` varchar(100) NOT NULL COMMENT 'unique name within top level folder',
  `folder_id` int(11) DEFAULT NULL COMMENT 'references table folders',
  `organism_id` smallint(6) DEFAULT NULL COMMENT 'references table organisms',
  `plasmid_id` smallint(6) DEFAULT NULL COMMENT 'references table plasmids',
  `medium_id` smallint(6) DEFAULT NULL COMMENT 'references table media',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  `run_id` bigint(20) DEFAULT NULL COMMENT 'references table runs',
  PRIMARY KEY (`profile_id`),
  KEY `folder_id` (`folder_id`),
  KEY `medium_id` (`medium_id`),
  KEY `organism_id` (`organism_id`),
  KEY `plasmid_id` (`plasmid_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13643 DEFAULT CHARSET=utf8 COMMENT='profiles, owned by folders';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `program_errors`
--

DROP TABLE IF EXISTS `program_errors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `program_errors` (
  `error_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `program_id` smallint(6) NOT NULL COMMENT 'references table programs',
  `error_message` varchar(4000) NOT NULL COMMENT 'error message',
  `error_time` datetime NOT NULL COMMENT 'time when error occurred',
  `resolved` tinyint(4) NOT NULL COMMENT '0: open, 1: resolved',
  PRIMARY KEY (`error_id`),
  KEY `program_id` (`program_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `programs`
--

DROP TABLE IF EXISTS `programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `programs` (
  `program_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `program_name` varchar(30) NOT NULL COMMENT 'unique name of the program',
  `alive_time` datetime NOT NULL COMMENT 'timestamp of least recent alive sign',
  PRIMARY KEY (`program_id`),
  UNIQUE KEY `uq_programs_program_name` (`program_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `properties_types`
--

DROP TABLE IF EXISTS `properties_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `properties_types` (
  `property_type_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `canonical_name` varchar(20) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` varchar(400) DEFAULT NULL,
  PRIMARY KEY (`property_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `role_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `role_name` varchar(100) NOT NULL COMMENT 'unique role name',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uq_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='roles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles_functions`
--

DROP TABLE IF EXISTS `roles_functions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles_functions` (
  `role_id` smallint(6) NOT NULL COMMENT 'references table roles',
  `function_id` smallint(6) NOT NULL COMMENT 'references table functions',
  PRIMARY KEY (`role_id`,`function_id`),
  KEY `role_id` (`role_id`),
  KEY `function_id` (`function_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='n:m mapping of roles and functions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `run_documents`
--

DROP TABLE IF EXISTS `run_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `run_documents` (
  `run_document_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `run_id` bigint(20) NOT NULL COMMENT 'references table runs',
  `document_name` varchar(100) NOT NULL COMMENT 'document name',
  `document_content` longblob NOT NULL COMMENT 'document content',
  PRIMARY KEY (`run_document_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='documents containing run-specific information';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `run_remarks`
--

DROP TABLE IF EXISTS `run_remarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `run_remarks` (
  `run_remark_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `run_id` bigint(20) NOT NULL COMMENT 'references table runs',
  `remark` varchar(4000) NOT NULL COMMENT 'textual description',
  `insert_user` varchar(100) NOT NULL COMMENT 'who',
  `insert_time` datetime NOT NULL COMMENT 'when',
  PRIMARY KEY (`run_remark_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=658 DEFAULT CHARSET=utf8 COMMENT='run specific comments and observations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `rundata`
--

DROP TABLE IF EXISTS `rundata`;
/*!50001 DROP VIEW IF EXISTS `rundata`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `rundata` AS SELECT 
 1 AS `Strain`,
 1 AS `experiment_id`,
 1 AS `variable_type_id`,
 1 AS `canonical_name`,
 1 AS `measurement_id`,
 1 AS `measurement_time`,
 1 AS `measured_value`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `runs`
--

DROP TABLE IF EXISTS `runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `runs` (
  `run_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `run_name` varchar(100) NOT NULL COMMENT 'run name, unique within folder',
  `folder_id` int(11) NOT NULL COMMENT 'references table folders',
  `pms_id` smallint(6) NOT NULL COMMENT 'references table process_management_systems',
  `status_id` smallint(6) NOT NULL COMMENT 'references table statuses',
  `start_time` datetime DEFAULT NULL COMMENT '(planned) start of run',
  `end_time` datetime DEFAULT NULL COMMENT '(planned) termination of run',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  `conclusion` varchar(4000) DEFAULT NULL COMMENT 'optional conclusion',
  `container_label` varchar(4000) DEFAULT NULL COMMENT 'label of the containers in bioreactor view',
  `is_template` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`run_id`),
  UNIQUE KEY `uq_run_name` (`run_name`),
  KEY `status_id` (`status_id`),
  KEY `pms_id` (`pms_id`),
  KEY `folder_id` (`folder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=634 DEFAULT CHARSET=utf8 COMMENT='runs, owned by folders';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_container`
--

DROP TABLE IF EXISTS `sample_container`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_container` (
  `sample_container_id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_container_type_id` smallint(6) NOT NULL,
  `sample_container_label` varchar(100) DEFAULT NULL,
  `sample_container_instance` int(11) DEFAULT NULL,
  PRIMARY KEY (`sample_container_id`),
  KEY `sample_container_type_id` (`sample_container_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_container_location`
--

DROP TABLE IF EXISTS `sample_container_location`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_container_location` (
  `sample_container_location_id` int(11) NOT NULL AUTO_INCREMENT,
  `sample_container_id` int(11) DEFAULT NULL,
  `storage_container_id` smallint(6) DEFAULT NULL,
  `storage_handover` datetime NOT NULL,
  PRIMARY KEY (`sample_container_location_id`),
  KEY `sample_container_id` (`sample_container_id`),
  KEY `storage_container_id` (`storage_container_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample_container_type`
--

DROP TABLE IF EXISTS `sample_container_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample_container_type` (
  `sample_container_type_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `sample_container_type_name` varchar(100) NOT NULL,
  `number_of_rows` smallint(6) NOT NULL,
  `number_of_columns` smallint(6) NOT NULL,
  `carries_sub_containers` tinyint(1) DEFAULT NULL,
  `capacity_per_container` decimal(18,6) DEFAULT NULL,
  `description` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`sample_container_type_id`),
  KEY `sample_container_type_name` (`sample_container_type_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sampling_methods`
--

DROP TABLE IF EXISTS `sampling_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sampling_methods` (
  `sampling_method_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `canonical_name` varchar(20) NOT NULL COMMENT 'unique machine-readable name',
  `display_name` varchar(100) NOT NULL COMMENT 'human-readable name',
  `manual` tinyint(4) NOT NULL COMMENT '1: manual sample, 0: automatic sample',
  PRIMARY KEY (`sampling_method_id`),
  UNIQUE KEY `uq_sm_canonical_name` (`canonical_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='sampling method lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `samplings`
--

DROP TABLE IF EXISTS `samplings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samplings` (
  `sampling_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `experiment_id` bigint(20) DEFAULT NULL COMMENT 'references table experiments',
  `sample_label` varchar(100) NOT NULL COMMENT 'label of the sample container',
  `sampling_method_id` smallint(6) NOT NULL COMMENT 'references table sampling_methods',
  `sample_time` datetime NOT NULL COMMENT 'time when sample was taken',
  `sample_volume` decimal(9,3) NOT NULL COMMENT 'volume of sample in [ml]',
  PRIMARY KEY (`sampling_id`),
  KEY `experiment_id` (`experiment_id`),
  KEY `sampling_method_id` (`sampling_method_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38020 DEFAULT CHARSET=utf8 COMMENT='experiment specific samplings ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `samplings_extension`
--

DROP TABLE IF EXISTS `samplings_extension`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `samplings_extension` (
  `sampling_id` bigint(20) NOT NULL,
  `sample_container_id` int(11) DEFAULT NULL,
  `container_number` int(11) DEFAULT NULL,
  PRIMARY KEY (`sampling_id`),
  KEY `sample_container_id` (`sample_container_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `samplings_neu`
--

DROP TABLE IF EXISTS `samplings_neu`;
/*!50001 DROP VIEW IF EXISTS `samplings_neu`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `samplings_neu` AS SELECT 
 1 AS `sampling_id`,
 1 AS `experiment_id`,
 1 AS `sample_label`,
 1 AS `sampling_method_id`,
 1 AS `sample_time`,
 1 AS `sample_volume`,
 1 AS `sample_container_id`,
 1 AS `container_number`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `setpoints`
--

DROP TABLE IF EXISTS `setpoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `setpoints` (
  `setpoint_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `profile_id` bigint(20) NOT NULL COMMENT 'references table profiles',
  `variable_type_id` smallint(6) NOT NULL COMMENT 'references table variable_type_id',
  `scope` char(1) NOT NULL COMMENT 'e: experiment, b: bioreactor, r: run',
  `cultivation_age` int(11) NOT NULL COMMENT 'time since cultivation start in [s], 0 means start value',
  `setpoint_value` decimal(24,12) DEFAULT NULL COMMENT 'setpoint value',
  `checksum` int(10) unsigned NOT NULL COMMENT 'checksum of the whole record',
  PRIMARY KEY (`setpoint_id`),
  KEY `profile_id` (`profile_id`),
  KEY `variable_type_id` (`variable_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1434121 DEFAULT CHARSET=utf8 COMMENT='setpoints and start values belonging to profiles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `starter_cultures`
--

DROP TABLE IF EXISTS `starter_cultures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `starter_cultures` (
  `starter_culture_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `starter_culture_name` varchar(100) NOT NULL COMMENT 'starter culture name, unique within folder',
  `folder_id` int(11) NOT NULL COMMENT 'references table folders',
  `bioreactor_type_id` smallint(6) DEFAULT NULL COMMENT 'references table bioreactor_types',
  `organism_id` smallint(6) DEFAULT NULL COMMENT 'references table organisms',
  `plasmid_id` smallint(6) DEFAULT NULL COMMENT 'references tables plasmids',
  `medium_id` smallint(6) DEFAULT NULL COMMENT 'references table media',
  `inactivation_method_id` smallint(6) DEFAULT NULL COMMENT 'references table inactivation_methods',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`starter_culture_id`),
  UNIQUE KEY `uq_starter_culture_name` (`starter_culture_name`,`folder_id`),
  KEY `folder_id` (`folder_id`),
  KEY `bioreactor_type_id` (`bioreactor_type_id`),
  KEY `organism_id` (`organism_id`),
  KEY `plasmid_id` (`plasmid_id`),
  KEY `medium_id` (`medium_id`),
  KEY `inactivation_method_id` (`inactivation_method_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='experiment specific starter cultures';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `statuses`
--

DROP TABLE IF EXISTS `statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `statuses` (
  `status_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `canonical_name` varchar(20) NOT NULL COMMENT 'machine-readable name, e.g. prepared, running, finished, interrupted',
  `display_name` varchar(20) NOT NULL COMMENT 'human-readable name',
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `uq_stat_canonical_name` (`canonical_name`),
  UNIQUE KEY `uq_stat_display_name` (`display_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='status lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `storage_container`
--

DROP TABLE IF EXISTS `storage_container`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `storage_container` (
  `storage_container_id` smallint(6) NOT NULL AUTO_INCREMENT,
  `storage_container_name` varchar(100) DEFAULT NULL,
  `storage_container_description` varchar(4000) DEFAULT NULL,
  PRIMARY KEY (`storage_container_id`),
  KEY `storage_container_name` (`storage_container_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `trace`
--

DROP TABLE IF EXISTS `trace`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trace` (
  `trace_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `trace_time` datetime NOT NULL COMMENT 'timestamp',
  `trace_level` varchar(10) NOT NULL COMMENT 'INFO, WARNING, ERROR, ...',
  `program` varchar(30) DEFAULT NULL,
  `category` varchar(100) NOT NULL COMMENT 'e.g. the classname',
  `message` varchar(4000) NOT NULL COMMENT 'the message text',
  PRIMARY KEY (`trace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_preferences`
--

DROP TABLE IF EXISTS `user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_preferences` (
  `user_id` smallint(6) NOT NULL COMMENT 'references table users',
  `preference_key` varchar(20) NOT NULL COMMENT 'key, e.g. Language',
  `preference_value` varchar(100) DEFAULT NULL COMMENT 'value, e.g. English',
  PRIMARY KEY (`user_id`,`preference_key`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='stores UI preferences like preferred language';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `user_name` varchar(100) NOT NULL COMMENT 'unique user name',
  `password` varbinary(50) DEFAULT NULL COMMENT 'password hash',
  `locked` tinyint(4) NOT NULL COMMENT '1: user is locked, 0: otherwise',
  `change_password` tinyint(4) NOT NULL COMMENT '1: user must change password on next login, 0: otherwise',
  `wrong_password_count` smallint(6) NOT NULL COMMENT 'login attempts using wrong password',
  `lock_count` smallint(6) NOT NULL COMMENT 'how often locked in the past',
  `description` varchar(4000) DEFAULT NULL COMMENT 'optional description',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_user_name` (`user_name`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8 COMMENT='users';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_groups`
--

DROP TABLE IF EXISTS `users_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_groups` (
  `user_id` smallint(6) NOT NULL COMMENT 'references table users',
  `group_id` smallint(6) NOT NULL COMMENT 'references table groups',
  PRIMARY KEY (`user_id`,`group_id`),
  KEY `group_id` (`group_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='n:m mapping of users and groups';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users_roles`
--

DROP TABLE IF EXISTS `users_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_roles` (
  `user_id` smallint(6) NOT NULL COMMENT 'references table users',
  `role_id` smallint(6) NOT NULL COMMENT 'references table roles',
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `role_id` (`role_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='n:m mapping of users and roles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `variable_types`
--

DROP TABLE IF EXISTS `variable_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `variable_types` (
  `variable_type_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'unique identifier',
  `canonical_name` varchar(30) NOT NULL COMMENT 'machine-readable name, unique per scope',
  `display_name` varchar(100) NOT NULL COMMENT 'human-readable name',
  `unit` varchar(20) DEFAULT NULL COMMENT 'unit of variable',
  `lower_limit` decimal(24,12) DEFAULT NULL COMMENT 'minimal value',
  `upper_limit` decimal(24,12) DEFAULT NULL COMMENT 'maximum value',
  PRIMARY KEY (`variable_type_id`),
  UNIQUE KEY `uq_vt_canonical_name` (`canonical_name`)
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8 COMMENT='variable type lookup table';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `weightmeasurement`
--

DROP TABLE IF EXISTS `weightmeasurement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weightmeasurement` (
  `weighing_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `run_id` bigint(20) NOT NULL,
  `w_step_id` bigint(20) NOT NULL,
  `weighing_device` varchar(100) DEFAULT NULL,
  `createtime` datetime DEFAULT NULL,
  `tip_no` bigint(20) NOT NULL,
  `liquidclass` varchar(100) DEFAULT NULL,
  `density` decimal(18,6) DEFAULT NULL,
  `density_Unit` varchar(20) DEFAULT NULL,
  `replicate_no` int(11) NOT NULL,
  `setpoint` decimal(18,6) DEFAULT NULL,
  `setpoint_unit` varchar(20) DEFAULT NULL,
  `weighing_1` decimal(18,6) DEFAULT NULL,
  `weighing_2` decimal(18,6) DEFAULT NULL,
  `weighing_1_unit` varchar(20) DEFAULT NULL,
  `weighing_2_unit` varchar(20) DEFAULT NULL,
  `weighing_1_stability` varchar(20) DEFAULT NULL,
  `weighing_2_stability` varchar(20) DEFAULT NULL,
  `weighing_diff` decimal(18,6) DEFAULT NULL,
  `weighing_time_1` datetime DEFAULT NULL,
  `weighing_time_2` datetime DEFAULT NULL,
  PRIMARY KEY (`weighing_id`),
  KEY `run_id` (`run_id`)
) ENGINE=InnoDB AUTO_INCREMENT=15809 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;


DROP TABLE IF EXISTS `env_test`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `env_test` (
  `id` int(6) NOT NULL AUTO_INCREMENT COMMENT 'unique id',
  `detail` varchar(20) NOT NULL COMMENT 'some detail',
  `extra_detail` varchar(100) DEFAULT NULL COMMENT 'some extra details',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='environment test table';

--
-- Foreign keys
--
ALTER TABLE `bioreactors`
  ADD CONSTRAINT `fk_bioreactors_brtypes` FOREIGN KEY (`bioreactor_type_id`) REFERENCES `bioreactor_types` (`bioreactor_type_id`);
ALTER TABLE `bioreactors`
  ADD CONSTRAINT `fk_bioreactors_exp` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `device_properties`
  ADD CONSTRAINT `fk_dp_devices` FOREIGN KEY (`device_id`) REFERENCES `devices` (`device_id`);
ALTER TABLE `dmp_device_properties`
  ADD CONSTRAINT `fk_dp_dmp_devices` FOREIGN KEY (`device_id`) REFERENCES `devices` (`device_id`);
ALTER TABLE `dmp_device_properties`
  ADD CONSTRAINT `fk_dp_dmp_property_types` FOREIGN KEY (`property_type_id`) REFERENCES `properties_types` (`property_type_id`);
ALTER TABLE `dmp_methode`
  ADD CONSTRAINT `fk_dmp_methode_devices` FOREIGN KEY (`device_id`) REFERENCES `devices` (`device_id`);
ALTER TABLE `dmp_tasks`
  ADD CONSTRAINT `fk_dmpt_methode_id` FOREIGN KEY (`dmp_methode_id`) REFERENCES `dmp_methode` (`dmp_methode_id`);
ALTER TABLE `dmp_tasks`
  ADD CONSTRAINT `fk_dmpt_runi_id` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `doe_investigations`
  ADD CONSTRAINT `fk_doe_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `doe_mappings`
  ADD CONSTRAINT `fk_doe_mappings_investigations` FOREIGN KEY (`doe_investigation_id`) REFERENCES `doe_investigations` (`doe_investigation_id`);
ALTER TABLE `doe_mappings`
  ADD CONSTRAINT `fk_doe_variable_types` FOREIGN KEY (`variable_type_id`) REFERENCES `variable_types` (`variable_type_id`);
ALTER TABLE `experiments`
  ADD CONSTRAINT `fk_exp_bioreactors` FOREIGN KEY (`bioreactor_id`) REFERENCES `bioreactors` (`bioreactor_id`);
ALTER TABLE `experiments`
  ADD CONSTRAINT `fk_exp_inactivation_methods` FOREIGN KEY (`inactivation_method_id`) REFERENCES `inactivation_methods` (`inactivation_method_id`);
ALTER TABLE `experiments`
  ADD CONSTRAINT `fk_exp_profiles` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`profile_id`);
ALTER TABLE `experiments`
  ADD CONSTRAINT `fk_exp_startercultures` FOREIGN KEY (`starter_culture_id`) REFERENCES `starter_cultures` (`starter_culture_id`);
ALTER TABLE `folders`
  ADD CONSTRAINT `fk_folders_groups` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`);
ALTER TABLE `m_model`
  ADD CONSTRAINT `m_model_parent` FOREIGN KEY (`model_parent`) REFERENCES `m_model` (`m_model_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_parameter_est`
  ADD CONSTRAINT `fk_m_parameter_est_m_model_id` FOREIGN KEY (`m_model_id`) REFERENCES `m_model` (`m_model_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_parameter_est`
  ADD CONSTRAINT `fk_m_parameter_est_run_id` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_parameter_val`
  ADD CONSTRAINT `fk_m_parameter_est_id` FOREIGN KEY (`m_parameter_est_id`) REFERENCES `m_parameter_est` (`m_parameter_est_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_parameter_val`
  ADD CONSTRAINT `fk_m_parameter_id` FOREIGN KEY (`m_parameter_id`) REFERENCES `m_parameter` (`m_parameter_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_sensitivity`
  ADD CONSTRAINT `fk_m_sensitivity_m_parameter_id` FOREIGN KEY (`m_parameter_id`) REFERENCES `m_parameter_est` (`m_parameter_est_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_sensitivity`
  ADD CONSTRAINT `fk_m_sensitivity_m_simulation_type_id` FOREIGN KEY (`m_simulation_type_id`) REFERENCES `m_simulation_type` (`m_simulation_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_simulation`
  ADD CONSTRAINT `fk_m_simulation_m_parameter_est_id` FOREIGN KEY (`m_parameter_est_id`) REFERENCES `m_parameter_est` (`m_parameter_est_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `m_simulation`
  ADD CONSTRAINT `fk_m_simulatoin_m_simulation_type_id` FOREIGN KEY (`m_simulation_type_id`) REFERENCES `m_simulation_type` (`m_simulation_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `measurements_bioreactors`
  ADD CONSTRAINT `fk_mb_bioreactors` FOREIGN KEY (`bioreactor_id`) REFERENCES `bioreactors` (`bioreactor_id`);
ALTER TABLE `measurements_bioreactors`
  ADD CONSTRAINT `fk_mb_measurements` FOREIGN KEY (`measuring_setup_id`) REFERENCES `measuring_setup` (`measuring_setup_id`);
ALTER TABLE `measurements_experiments`
  ADD CONSTRAINT `fk_me_experiments` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`experiment_id`);
ALTER TABLE `measurements_experiments`
  ADD CONSTRAINT `fk_me_measurements` FOREIGN KEY (`measuring_setup_id`) REFERENCES `measuring_setup` (`measuring_setup_id`);
ALTER TABLE `measurements_experiments`
  ADD CONSTRAINT `fk_me_samplings` FOREIGN KEY (`sampling_id`) REFERENCES `samplings` (`sampling_id`);
ALTER TABLE `measurements_runs`
  ADD CONSTRAINT `fk_mr_measurements` FOREIGN KEY (`measuring_setup_id`) REFERENCES `measuring_setup` (`measuring_setup_id`);
ALTER TABLE `measurements_runs`
  ADD CONSTRAINT `fk_mr_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `measuring_setup`
  ADD CONSTRAINT `fk_msetup_analysis_methods` FOREIGN KEY (`analysis_method_id`) REFERENCES `analysis_methods` (`analysis_method_id`);
ALTER TABLE `measuring_setup`
  ADD CONSTRAINT `fk_msetup_devices` FOREIGN KEY (`device_id`) REFERENCES `devices` (`device_id`);
ALTER TABLE `measuring_setup`
  ADD CONSTRAINT `fk_msetup_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `measuring_setup`
  ADD CONSTRAINT `fk_msetup_variable_types` FOREIGN KEY (`variable_type_id`) REFERENCES `variable_types` (`variable_type_id`);
ALTER TABLE `opc_items`
  ADD CONSTRAINT `fk_opc_items_servers` FOREIGN KEY (`opc_server_id`) REFERENCES `opc_servers` (`opc_server_id`);
ALTER TABLE `opc_items`
  ADD CONSTRAINT `fk_opc_items_variable_types` FOREIGN KEY (`variable_type_id`) REFERENCES `variable_types` (`variable_type_id`);
ALTER TABLE `opc_servers`
  ADD CONSTRAINT `fk_opc_servers_pms` FOREIGN KEY (`pms_id`) REFERENCES `process_management_systems` (`pms_id`);
ALTER TABLE `opc_servers`
  ADD CONSTRAINT `fk_opc_servers_specifications` FOREIGN KEY (`opc_specification_id`) REFERENCES `opc_specifications` (`opc_specification_id`);
ALTER TABLE `parameters`
  ADD CONSTRAINT `fk_param_parameter_types` FOREIGN KEY (`parameter_type_id`) REFERENCES `parameter_types` (`parameter_type_id`);
ALTER TABLE `parameters`
  ADD CONSTRAINT `fk_param_profiles` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`profile_id`);
ALTER TABLE `planned_samplings`
  ADD CONSTRAINT `fk_sp_profiles` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`profile_id`);
ALTER TABLE `planned_samplings`
  ADD CONSTRAINT `fk_sp_sampling_methods` FOREIGN KEY (`sampling_method_id`) REFERENCES `sampling_methods` (`sampling_method_id`);
ALTER TABLE `profiles`
  ADD CONSTRAINT `fk_profiles_folders` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`);
ALTER TABLE `profiles`
  ADD CONSTRAINT `fk_profiles_media` FOREIGN KEY (`medium_id`) REFERENCES `media` (`medium_id`);
ALTER TABLE `profiles`
  ADD CONSTRAINT `fk_profiles_organisms` FOREIGN KEY (`organism_id`) REFERENCES `organisms` (`organism_id`);
ALTER TABLE `profiles`
  ADD CONSTRAINT `fk_profiles_plasmids` FOREIGN KEY (`plasmid_id`) REFERENCES `plasmids` (`plasmid_id`);
ALTER TABLE `profiles`
  ADD CONSTRAINT `fk_profiles_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `program_errors`
  ADD CONSTRAINT `fk_pe_programs` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`);
ALTER TABLE `roles_functions`
  ADD CONSTRAINT `fk_roles_functions_functions` FOREIGN KEY (`function_id`) REFERENCES `functions` (`function_id`);
ALTER TABLE `roles_functions`
  ADD CONSTRAINT `fk_roles_functions_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);
ALTER TABLE `run_documents`
  ADD CONSTRAINT `fk_run_documents_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `run_remarks`
  ADD CONSTRAINT `fk_run_remarks_runs` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`);
ALTER TABLE `runs`
  ADD CONSTRAINT `fk_runs_folders` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`);
ALTER TABLE `runs`
  ADD CONSTRAINT `fk_runs_pms` FOREIGN KEY (`pms_id`) REFERENCES `process_management_systems` (`pms_id`);
ALTER TABLE `runs`
  ADD CONSTRAINT `fk_runs_statuses` FOREIGN KEY (`status_id`) REFERENCES `statuses` (`status_id`);
ALTER TABLE `sample_container`
  ADD CONSTRAINT `fk_sample_container_ibfk_1` FOREIGN KEY (`sample_container_type_id`) REFERENCES `sample_container_type` (`sample_container_type_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `sample_container_location`
  ADD CONSTRAINT `fk_sample_container_location_ibfk_1` FOREIGN KEY (`sample_container_id`) REFERENCES `sample_container` (`sample_container_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `sample_container_location`
  ADD CONSTRAINT `fk_sample_container_location_ibfk_2` FOREIGN KEY (`storage_container_id`) REFERENCES `storage_container` (`storage_container_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `samplings`
  ADD CONSTRAINT `fk_samplings_experiments` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`experiment_id`);
ALTER TABLE `samplings`
  ADD CONSTRAINT `fk_samplings_sampling_methods` FOREIGN KEY (`sampling_method_id`) REFERENCES `sampling_methods` (`sampling_method_id`);
ALTER TABLE `samplings_extension`
  ADD CONSTRAINT `fk_samplings_extension_ibfk_1` FOREIGN KEY (`sampling_id`) REFERENCES `samplings` (`sampling_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `samplings_extension`
  ADD CONSTRAINT `fk_samplings_extension_ibfk_2` FOREIGN KEY (`sample_container_id`) REFERENCES `sample_container` (`sample_container_id`) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE `setpoints`
  ADD CONSTRAINT `fk_setp_profiles` FOREIGN KEY (`profile_id`) REFERENCES `profiles` (`profile_id`);
ALTER TABLE `setpoints`
  ADD CONSTRAINT `fk_setp_variable_types` FOREIGN KEY (`variable_type_id`) REFERENCES `variable_types` (`variable_type_id`);
ALTER TABLE `starter_cultures`
  ADD CONSTRAINT `fk_sc_bioreactor_types` FOREIGN KEY (`bioreactor_type_id`) REFERENCES `bioreactor_types` (`bioreactor_type_id`);
ALTER TABLE `starter_cultures`
  ADD CONSTRAINT `fk_sc_folders` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`folder_id`);
ALTER TABLE `starter_cultures`
  ADD CONSTRAINT `fk_sc_inactivation_methods` FOREIGN KEY (`inactivation_method_id`) REFERENCES `inactivation_methods` (`inactivation_method_id`);
ALTER TABLE `starter_cultures`
  ADD CONSTRAINT `fk_sc_media` FOREIGN KEY (`medium_id`) REFERENCES `media` (`medium_id`);
ALTER TABLE `starter_cultures`
  ADD CONSTRAINT `fk_sc_organisms` FOREIGN KEY (`organism_id`) REFERENCES `organisms` (`organism_id`);
ALTER TABLE `starter_cultures`
  ADD CONSTRAINT `fk_sc_plasmids` FOREIGN KEY (`plasmid_id`) REFERENCES `plasmids` (`plasmid_id`);
ALTER TABLE `user_preferences`
  ADD CONSTRAINT `fk_prefs_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
ALTER TABLE `users_groups`
  ADD CONSTRAINT `fk_users_groups_groups` FOREIGN KEY (`group_id`) REFERENCES `groups` (`group_id`);
ALTER TABLE `users_groups`
  ADD CONSTRAINT `fk_users_groups_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
ALTER TABLE `users_roles`
  ADD CONSTRAINT `fk_users_roles_roles` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`);
ALTER TABLE `users_roles`
  ADD CONSTRAINT `fk_users_roles_users` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);
ALTER TABLE `weightmeasurement`
  ADD CONSTRAINT `fk_weightmeasurement_ibfk_1` FOREIGN KEY (`run_id`) REFERENCES `runs` (`run_id`) ON DELETE CASCADE ON UPDATE CASCADE;


--
-- Initialization of basic data
--
INSERT INTO ilabdb.statuses (status_id,canonical_name,display_name) VALUES
	 (1,'prepared','vorbereitet'),
	 (2,'running','laufend'),
	 (3,'finished','beendet'),
	 (4,'aborted','abgebrochen');

INSERT INTO ilabdb.process_management_systems (pms_id,pms_name,single_concurrent_run,description) VALUES
	 (1,'Hamilton',1,NULL),
	 (2,'2mag',1,NULL),
	 (3,'No Platform',0,NULL),
	 (4,'Tecan',0,NULL),
	 (5,'BioXplorer',0,''),
	 (10,'Tecan Track',0,''),
	 (11,'Tecan Nicky',0,NULL),
	 (12,'Hamilton Ersatz',0,NULL);

INSERT INTO ilabdb.`groups` (group_id,group_name,description) VALUES
	 (1,'High Throughput Lab',NULL);

INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (1,'Test area',NULL,1,NULL),
	 (2,'Demonstrator PNP',NULL,1,NULL),
	 (4,'Etablierung OD-Messung',1,NULL,NULL),
	 (5,'Etablierung NADH-Methode',1,NULL,NULL),
	 (6,'Diplomarbeit',1,NULL,NULL),
	 (7,'Method development 96-well plate cultures',NULL,1,NULL),
	 (8,'Test Deepwell Sensorplatten',7,NULL,NULL),
	 (9,'Test Slow OxoPlate',7,NULL,NULL),
	 (10,'Method development pHController',NULL,1,NULL),
	 (11,'pHController',10,NULL,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (12,'Method Development DSP',NULL,1,NULL),
	 (13,'Lysis Buffer Screening',12,NULL,NULL),
	 (15,'Demonstrator EPG',NULL,1,'Kooperationsprojekt mit der Organobalance GmbH zur Demonstration der konsistenten Bioprozessentwicklung am Beispiel einer Endo-Polygalacturonase, die von Saccharomyces cerevisiae sekretiert wird.'),
	 (16,'Method development 2mag-Minibioreactor',15,NULL,NULL),
	 (17,'A-Stat fermentations: validation of small scale cultures',15,NULL,NULL),
	 (18,'Determination of µ/qp in 24 well plates',15,NULL,NULL),
	 (19,'Expressionsstudien DgPNP Varianten',2,NULL,NULL),
	 (23,'Method development 2mag-MBR platform',NULL,1,NULL),
	 (24,'Meilenstein 3',23,NULL,'Automatisierte Kultivierungen mit den Demonstratoren'),
	 (25,'GFP-measurement',12,NULL,'set-up of method');
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (26,'Development of iLab-Interface',NULL,1,NULL),
	 (27,'Hamilton-Testruns',26,NULL,NULL),
	 (28,'Determination of glucose release rate',7,NULL,NULL),
	 (29,'2mag tests',1,NULL,NULL),
	 (30,'Biosilta_EnpressoBdefined',7,NULL,NULL),
	 (31,'Strain screening in 96 microwell plates',15,NULL,NULL),
	 (32,'Anbindung MACSQuant',7,NULL,NULL),
	 (33,'Testruns_Micha',1,NULL,'NICHT abbrechen/beenden!'),
	 (34,'CP-Buffer screening',7,NULL,'Verschiedene Konzentrationen von Citrat-Phosphat-Puffer werden getestet um den pH-Wert in den 96/24-Wellplatten stabil zu halten und somit die Übertragbarkeit der Ergebnisse für den Minibioreaktor bzw. die Fermentation zu gewährleisten.'),
	 (35,'Validation Experiments in 500 mL Shake Flasks',15,NULL,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (36,'96 MWP Screening',2,NULL,NULL),
	 (37,'Hochzelldichtekultivierung',10,NULL,NULL),
	 (38,'Demonstrator betaGal',NULL,1,NULL),
	 (39,'qp-Bestimmung',38,NULL,NULL),
	 (40,'HCDC',38,NULL,NULL),
	 (41,'LEANPROT',NULL,1,'ErASys Project LEANPROT'),
	 (42,'Test runs',41,NULL,NULL),
	 (44,'PreSens',1,NULL,NULL),
	 (45,'iLab COMInterface',1,NULL,'Runs to test the iLab COM Interface, created by BVT'),
	 (47,'Reporterpladmid Development',41,NULL,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (49,'2mag',15,NULL,NULL),
	 (50,'BIORAPID',NULL,1,'Study of scale-up effects in minibioreactors using pulse based fed-batch cultivations'),
	 (51,'Kla determination',50,NULL,'Kla determination in the minibioreactors'),
	 (52,'Ncbcaa_runs',50,NULL,NULL),
	 (53,'Hamilton_Methoden',1,NULL,NULL),
	 (54,'LeanProteomByMedia',41,NULL,NULL),
	 (55,'Keio Screening',41,NULL,'Screening of strains from the Keio collection'),
	 (56,'Matlab_iLab communication',50,NULL,NULL),
	 (57,'Wasserlauf',1,NULL,NULL),
	 (59,'SWORD',1,NULL,'Tests for the real SWORD');
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (61,'SWORD',41,NULL,NULL),
	 (64,'EPG_DataHow',NULL,1,NULL),
	 (65,'EPG_DataHow',64,NULL,''),
	 (66,'test_runs',50,NULL,NULL),
	 (67,'Transformation',41,NULL,NULL),
	 (68,'Test_runs',64,NULL,NULL),
	 (69,'Simulations',41,NULL,NULL),
	 (70,'Vibrio',NULL,1,NULL),
	 (71,'growth characterisation',70,NULL,NULL),
	 (73,'AirLift',1,NULL,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (74,'_MolBio',NULL,1,'AG Gimpel'),
	 (75,'sRNA Quenching',74,NULL,NULL),
	 (76,'Turbidostat',NULL,1,'All Turbidostat Runs with the Hamilton'),
	 (78,'Master_Thesis_FS',76,NULL,NULL),
	 (79,'2mag_Pulses_KO',NULL,1,'Pulse based experiments with KO strains'),
	 (80,'HEcoScale',79,NULL,NULL),
	 (81,'Schiller_strains',NULL,1,'Analysis of strains from the Schiller group.'),
	 (82,'eGFP',81,NULL,NULL),
	 (83,'AMADEUS',NULL,1,'PhD project of Annina Sawatzki'),
	 (84,'test_runs',83,NULL,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (86,'2mag_runs',83,NULL,NULL),
	 (87,'MicroBalance',NULL,1,NULL),
	 (88,'CoCultivation',87,NULL,NULL),
	 (91,'Evolution_Project',NULL,1,NULL),
	 (92,'aimii',NULL,1,NULL),
	 (93,'kla_Versuche',92,NULL,NULL),
	 (94,'Bachelor-Thesis-Isabel',91,NULL,NULL),
	 (95,'BioProBot',NULL,1,NULL),
	 (96,'Test_runs',95,NULL,NULL),
	 (97,'Plasmid_Evolution',NULL,1,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (98,'test',97,NULL,NULL),
	 (99,'EnPump',NULL,1,NULL),
	 (100,'2mag_run',99,NULL,NULL),
	 (101,'2mag_runs',95,NULL,'Runs performed on the 2mag system.'),
	 (102,'KIWI',NULL,1,'KIWI biolab'),
	 (103,'Testruns',102,NULL,'Testruns'),
	 (104,'Schiller_strain',102,NULL,NULL),
	 (105,'Enzyme_screening',NULL,1,NULL),
	 (106,'Testing',105,NULL,NULL),
	 (107,'Messina',NULL,1,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (109,'WP3_Scale_Down_Settings',107,NULL,NULL),
	 (110,'KST',NULL,1,NULL),
	 (111,'first attempts',110,NULL,NULL),
	 (112,'Calibration',110,NULL,NULL),
	 (113,'Cultivation',110,NULL,NULL),
	 (114,'Waterrun',110,NULL,NULL),
	 (117,'ELISA_Control_Observation',107,NULL,NULL),
	 (118,'WP_Optimization',107,NULL,NULL),
	 (120,'Gosset',102,NULL,NULL),
	 (121,'Tecan Track Testing',NULL,1,NULL);
INSERT INTO ilabdb.folders (folder_id,folder_name,parent_id,group_id,description) VALUES
	 (122,'Mocktesting',121,NULL,NULL),
	 (123,'Messina_into_HEL',107,NULL,NULL),
	 (124,'FoodLabs',NULL,1,NULL),
	 (125,'Runs',124,NULL,NULL);

INSERT INTO ilabdb.bioreactor_types (bioreactor_type_id,bioreactor_type_name,number_of_rows,number_of_columns,capacity_per_container,description) VALUES
	 (1,'MTP (96 Wells)',8,12,0.200000,NULL),
	 (2,'MTP (48 Wells)',8,6,0.500000,NULL),
	 (3,'MTP (24 Wells)',4,6,1.000000,NULL),
	 (4,'Rührkesselreaktor (10 Liter)',1,1,10000.000000,NULL),
	 (6,'2mag 48x',8,6,10.000000,NULL),
	 (7,'PreSens SFR 500 mL Sensor Flasks',3,3,100.000000,'Sensorkolben: 500 mL Gesmatvolumen, 100 mL Arbeitsvolumen'),
	 (8,'PreSens Vario 500 mL',1,2,500.000000,NULL),
	 (9,'HELPolyblock 8x',4,2,150.000000,NULL);

INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (1,'Escherichia coli RB 791',NULL),
	 (2,'Saccharomyces cerevisiae AH22',NULL),
	 (3,'Escherichia coli W3110',NULL),
	 (4,'Escherichia coli DH10ß',NULL),
	 (5,'Escherichia coli BL21 Gold',NULL),
	 (6,'Escherichia coli BL21',NULL),
	 (7,'Sterile Control',NULL),
	 (8,'Escherichia coli BW25113',NULL),
	 (9,'Escherichia coli BW25113 JW0718-KC','delta sucD'),
	 (10,'unvalid',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (11,'Escherichia coli BW25113 ΔsucD',NULL),
	 (12,'Escherichia coli BW25113 WT',NULL),
	 (13,'Escherichia coli BW25113 ΔsucC',NULL),
	 (14,'Escherichia coli BW25113 ΔfliA',NULL),
	 (15,'Escherichia coli BW25113 ΔendA',NULL),
	 (16,'Escherichia coli BW25113 pSW3_lacI',NULL),
	 (17,'Escherichia coli BW25113 ΔompA',NULL),
	 (18,'Escherichia coli BW25113 ΔgatC',NULL),
	 (19,'Escherichia coli BW25113 ΔmarA',NULL),
	 (20,'Escherichia coli BW25113 ΔomtA',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (21,'Escherichia coli BW25113 ΔompT',NULL),
	 (22,'Escherichia coli BW25113 ΔgatZ',NULL),
	 (23,'Escherichia coli BW25113 ?ahpc',NULL),
	 (24,'Vibrio natriegens DSM759',NULL),
	 (25,'pUTR7 K1',NULL),
	 (26,'pUTR7 K2',NULL),
	 (27,'pUTR7 K3',NULL),
	 (28,'pUTR8 K1',NULL),
	 (29,'pUTR8 K2',NULL),
	 (30,'pUTR8 K3',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (31,'pUT19 K4',NULL),
	 (32,'Escherichia coli BW25113 ?aceA',NULL),
	 (33,'Escherichia coli BW25113 ?thrA',NULL),
	 (34,'Escherichia coli BW25113 ?leuA',NULL),
	 (35,'Escherichia coli BW25113 ?ilvBN',NULL),
	 (36,'Escherichia coli BW25113 ?ilvA',NULL),
	 (37,'Escherichia coli BW25113 ?ilvC',NULL),
	 (38,'Escherichia coli BW25113 ?ilvIH',NULL),
	 (39,'Escherichia coli BW25113 ilvG+',NULL),
	 (40,'Escherichia coli BW25113 ilvG-',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (41,'Escherichia coli BL21(DE3)',NULL),
	 (42,'Escherichia coli TG1',NULL),
	 (43,'Escherichia coli B scFv','AMADEUS BI strain AP02'),
	 (44,'Escherichia coli B Fab','AMADEUS BI strain AP01'),
	 (46,'Escherichia coli BW25113 ?hupA',NULL),
	 (47,'Escherichia coli BW25113 ?manX',NULL),
	 (48,'Escherichia coli BW25113 ?dppA',NULL),
	 (49,'Escherichia coli BW25113 ?ilvJ',NULL),
	 (50,'Escherichia coli WG',NULL),
	 (51,'Escherichia coli WGX',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (52,'Escherichia coli WGB',NULL),
	 (53,'Escherichia coli WGE',NULL),
	 (54,'Escherichia coli WGM',NULL),
	 (55,'Escherichia coli WGMX',NULL),
	 (56,'Escherichia coli WGMB',NULL),
	 (57,'Escherichia coli WGME',NULL),
	 (58,'Escherichia coli WGP',NULL),
	 (59,'Escherichia coli WGMP',NULL),
	 (60,'Escherichia coli WGMC',NULL),
	 (61,'Escherichia coli WHI',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (62,'Escherichia coli WHIP',NULL),
	 (63,'Escherichia coli WHIC',NULL),
	 (64,'Messina_StrainB','Escherichia coli BW25113'),
	 (65,'Escherichia coli BL21(Iq)',NULL),
	 (66,'E. coli strain BQF8RH8','BL21-Gold [F–ompT hsdS(rB–mB–) dcm+ TetR gal endA Hte]'),
	 (67,'Escherichia coli MG1655 ATCC (WT)',NULL),
	 (68,'Escherichia coli MG1655 RP',NULL),
	 (69,'Escherichia coli MG1655 RP vgb',NULL),
	 (70,'Escherichia coli MG1655 RP pdhR',NULL),
	 (71,'Escherichia coli MG1655 RP pdhR vgb',NULL);
INSERT INTO ilabdb.organisms (organism_id,organism_name,description) VALUES
	 (72,'Escherichia coli MG1655 RP pdhR vgb pTrc FbFP',NULL),
	 (73,'Escherichia coli MG1655 RP pTrc FbFP',NULL),
	 (74,'Escherichia coli MG1655 RP pdhR pTrc FbFP',NULL),
	 (75,'Escherichia coli MG1655 pTrc FbFP',NULL),
	 (76,'Escherichia coli MG1655 RP pdhR vgb pSt-pT7 FbFP',NULL),
	 (77,'Messina_StrainA','Escherichia coli BW25113'),
	 (78,'Messina_StrainC','Escherichia coli BW25113'),
	 (79,'Messina_StrainD','Escherichia coli BW25113');

INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (1,'pEXP_CT7_His',NULL),
	 (2,'pEXP_CUlac_His',NULL),
	 (3,'pEXP_CTUVar_His',NULL),
	 (4,'pEXP_CUT7_GST',NULL),
	 (5,'pEXP_CTUlac_GST',NULL),
	 (6,'pEXP_CVar_MBP',NULL),
	 (7,'pEXP_CTUT7_MBP',NULL),
	 (8,'pEXP_Clac_Sumo',NULL),
	 (9,'pEXP_CT7_Trx',NULL),
	 (10,'pEXP_CUlac_Trx',NULL);
INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (11,'pPG6 M27 HRT6',NULL),
	 (12,'pPG6-6',NULL),
	 (15,'pPG6-6 YE 11-1',NULL),
	 (16,'YepOE1',NULL),
	 (17,'pPG 6-1',NULL),
	 (18,'pPG6 M27',NULL),
	 (19,'pAG006','RFP'),
	 (20,'pAG007','YFP'),
	 (21,'pAG008','CFP'),
	 (22,'pAG016',NULL);
INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (23,'pAG017',NULL),
	 (24,'pAG003',NULL),
	 (25,'pAG002',NULL),
	 (26,'pAG004',NULL),
	 (27,'pAG020','3-Reporter'),
	 (28,'pAG027',NULL),
	 (29,'pSW3_lacI','Insuline plasmid'),
	 (30,'pAG019',NULL),
	 (31,'SL1',NULL),
	 (32,'pAG032',NULL);
INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (33,'psW3_lacI+',NULL),
	 (34,'pACG_araBAD',NULL),
	 (35,'pACG_araBAD_thrA',NULL),
	 (36,'pACG_araBAD_leuA',NULL),
	 (37,'pACG_araBAD_ilvBN',NULL),
	 (38,'pACG_araBAD_ilvA',NULL),
	 (39,'pACG_araBAD_ilvC',NULL),
	 (40,'pACG_araBAD_ilvIH',NULL),
	 (41,'pACG_araBAD_ilvGM',NULL),
	 (42,'pSS_01_GFP',NULL);
INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (43,'pET28',NULL),
	 (44,'pGK16_Amp_Mut','Test Construct for Plasmid Evolution Experiment'),
	 (45,'pGK16_Amp_WT','Test Construct for Plasmid Evolution experiments'),
	 (46,'pGKR_leu1',NULL),
	 (47,'pGKR_leu2',NULL),
	 (48,'pGKR_leu3',NULL),
	 (49,'pGKR_leu4',NULL),
	 (50,'pGKR_leu5',NULL),
	 (51,'pGKS01_SpecR','Spec unmutated'),
	 (52,'pGKS02_Spec*',NULL);
INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (53,'pUCS01 SpecR','Plasmid with KM, Spec resistence'),
	 (54,'pUCS02 Spec*','Plasmid withKM resistence and mutated spec resistence'),
	 (55,'pZSS01','SpecR'),
	 (56,'pZSS02','Spec*'),
	 (57,'Messina_Plasmid#1','low copy, helper 1 + helper 2, Model protein: Fab'),
	 (58,'pET28-NMBL-eGFP-TEVrec-(V2Y1)15-His','Schiller ELP-GFP'),
	 (59,'pET28-NMBXL-His-eGFP-TEVrec-S40I30','Schiller plasmid#8'),
	 (60,'pKS2-ApMTAP','pKS2 ist ein Derivat des Plasmids pCTUT7'),
	 (61,'pBRS01 SpecR',NULL),
	 (62,'pBRS02 Spec*','mutated spec resistance');
INSERT INTO ilabdb.plasmids (plasmid_id,plasmid_name,description) VALUES
	 (63,'pCTS01','SpecR'),
	 (64,'pCTS02','Spec*'),
	 (65,'pET28-NMBL-StrepII-mCHR-TEVrec-(DSY)16-His','Schiller mCherry ELP'),
	 (66,'pQF18','pQF8 contains the genes encoding the RH structural
subunits under control of a Plac-
CTU promoter, while
the plasmid pQF18 harbors the native maturation genes
encoding the auxiliary proteins HypA1B1F1CDEX and
the nickel permease HoxN under the control of a Ptac
promoter'),
	 (67,'Messina_Plasmid#2','low copy, helper 1, Model protein: Fab'),
	 (68,'Messina_Plasmid#3','low copy, without helper, Model protein: Fab'),
	 (69,'Messina_Plasmid#4','high copy, without helper, Model protein: Nanobody');

INSERT INTO ilabdb.media (medium_id,medium_name,description) VALUES
	 (1,'LB',NULL),
	 (2,'TB',NULL),
	 (3,'EnBase Flo',NULL),
	 (4,'EnPresso (alt)',NULL),
	 (5,'MSM',NULL),
	 (11,'EnPresso B',NULL),
	 (12,'EnPresso B Defined',NULL),
	 (13,'WMVIII mod. S','Modifiziertes WMVIII (1.5 g/L Glutamat) + Saccharose'),
	 (14,'WMVIII mod. EnPump','Modifiziertes WMVIII (1.5 g/L Glutamat) + EnPump Substrat'),
	 (15,'WMVIII mod. G','Modifiziertes WMVIII (1.5 g/L Glutamat) + Glucose');
INSERT INTO ilabdb.media (medium_id,medium_name,description) VALUES
	 (16,'EnPresso Y Defined',NULL),
	 (17,'M9',NULL),
	 (18,'TY','TY Medium nach Mathias Gimpel'),
	 (19,'TY with KM25',NULL),
	 (20,'MSM BI1','AMADEUS BI mineral salt medium (for AP01)'),
	 (21,'Milk',NULL),
	 (22,'FM7','Specific MSM with Biospringer yeast extract');

INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (1,'Temperature','Temperature','°C',NULL,NULL),
	 (2,'pH','pH','-',5.500000000000,8.000000000000),
	 (3,'pO2','Dissolved Oxygen','%',0.000000000000,110.000000000000),
	 (4,'pCO2','Kohlendioxidkonzentration','%',NULL,NULL),
	 (5,'StirringSpeed','StirringSpeed','U/min',250.000000000000,3200.000000000000),
	 (6,'ShakingSpeed','Shaking Speed','U/min',NULL,NULL),
	 (7,'OD436','OD436',NULL,NULL,NULL),
	 (8,'OD600','OD600','-',NULL,NULL),
	 (9,'Excentricity','Excentricity','mm',NULL,NULL),
	 (10,'Aeration_Rate','Aeration_Rate','Ln/min',0.000000000000,20.000000000000);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (11,'InducerConcentration','InducerConcentration','mM',NULL,NULL),
	 (17,'Acetat','Acetat','g/L',NULL,NULL),
	 (18,'Glucose','Glucose','g/L',0.000000000000,NULL),
	 (20,'VolActivityEPG','Volumetric enzyme activity EPG','U/mL',NULL,NULL),
	 (22,'VolActivityßGal','Volumetric enzyme activity ß-Gal','U/mL',NULL,NULL),
	 (23,'VolActivityPNP','Volumetric enzyme activity PNP','U/mL',NULL,NULL),
	 (24,'OD','OD','-',NULL,NULL),
	 (25,'ReagentA','ReagentA','U/L',NULL,NULL),
	 (26,'Acid','Acid','uL',NULL,NULL),
	 (27,'Base','Base','uL',NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (28,'DOT','DOT','-',0.000000000000,270.000000000000),
	 (31,'AmylaseConcentration','AmylaseConcentration','U/L',NULL,NULL),
	 (32,'DurationInductionTime','DurationInductionTime','h',NULL,NULL),
	 (33,'InductionTime','InductionTime','h',NULL,NULL),
	 (34,'Volume','Volume','mL',NULL,NULL),
	 (35,'Weight','Weight','g',NULL,NULL),
	 (36,'VolumeInoculum','VolumeInoculum','mL',NULL,NULL),
	 (37,'Polysaccharidkonzentration','Polysaccharidkonzentration','g/L',0.000000000000,NULL),
	 (39,'Bufferconcentration','Bufferconcentration','mM',0.000000000000,1000.000000000000),
	 (40,'Acetate','Acetate','-',0.000000000000,1.000000000000);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (41,'EDTA','EDTA','mM',NULL,NULL),
	 (42,'Lysozyme','Lysozyme','U/mL',NULL,NULL),
	 (43,'Polymyxin B','Polymyxin B','µM',NULL,NULL),
	 (44,'Guanidine','Guanidine','mM',NULL,NULL),
	 (45,'Tween 20','Tween 20','%',NULL,NULL),
	 (46,'Time','Time','min',NULL,NULL),
	 (47,'V(EDTA)','V(EDTA)','µL',NULL,NULL),
	 (48,'V(Guanidine)','V(Guanidine)','µL',NULL,NULL),
	 (49,'V(Lysozyme)','V(Lysozyme)','µL',NULL,NULL),
	 (50,'V(Polymyxin B)','V(Polymyxin B)','µL',NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (51,'V(Tween 20)','V(Tween 20)','µL',NULL,NULL),
	 (52,'V(Buffer)','V(Puffer)','µL',NULL,NULL),
	 (53,'TritonX100','Triton X-100','%',NULL,NULL),
	 (54,'V(TritonX100)','V(Triton X-100)','µL',NULL,NULL),
	 (55,'DOT_SL','DOT_SL','-',NULL,NULL),
	 (56,'DOT_F','DOT_F','-',NULL,NULL),
	 (57,'Benzonase','Benzonase','U/mL',NULL,NULL),
	 (58,'V(Benzonase)','V(Benzonase)','µL',NULL,NULL),
	 (59,'Soluble Protein','Soluble Protein','-',NULL,NULL),
	 (60,'ßGal Activity','ßGal Activity','-',NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (62,'PumpSpeed','Pump Speed','U/min',0.000000000000,NULL),
	 (63,'Biomass','Biomass',NULL,NULL,NULL),
	 (64,'Fluo_RFP','Fluo_RFP','RFU',NULL,NULL),
	 (65,'Fluo_GFP','Fluo_GFP','RFU',NULL,NULL),
	 (66,'Fluo_YFP','Fluo_YFP','RFU',NULL,NULL),
	 (67,'Fluo_CFP','Fluo_CFP','RFU',NULL,NULL),
	 (68,'Volume_Balance','Volume_Balance','uL',1.000000000000,NULL),
	 (69,'Enzyme_addition','Enzyme_addition','uL',1.000000000000,NULL),
	 (70,'Two_mag_Feed','Feed Rate [var Units]','uL',NULL,NULL),
	 (71,'Aeration_Nitrogen','Aeration_Nitrogen','%',0.000000000000,100.000000000000);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (72,'Aeration_Air','Aeration_Air','%',0.000000000000,100.000000000000),
	 (73,'Aeration_O2','Aeration_O2','%',0.000000000000,100.000000000000),
	 (74,'Aeration_Volume','Aeration_Volume','Ln/min',0.000000000000,20.000000000000),
	 (75,'Flow_O2','Flow_O2','Ln/min',NULL,NULL),
	 (76,'Flow_Nitrogen','Flow_Nitrogen','Ln/min',NULL,NULL),
	 (77,'Flow_Air','Flow_Air','Ln/min',NULL,NULL),
	 (78,'Probe_Volume','Sampling Volume','uL',0.000000000000,3000.000000000000),
	 (79,'Evaporation_Volume','Evaporation_Volume','uL',1.000000000000,NULL),
	 (80,'feed_mu_set','feed_mu_set','1/h',0.000000000000,3.000000000000),
	 (81,'feed_f0','Feed rate initial','L/h',NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (82,'Cumulated_feed_volume_acetate','Cumulated_feed_volume_acetate','uL',0.000000000000,NULL),
	 (83,'Cumulated_feed_volume_medium','Cumulated_feed_volume_medium','uL',0.000000000000,NULL),
	 (84,'Cumulated_feed_volume_glucose','Cumulated_feed_volume_glucose','uL',0.000000000000,NULL),
	 (85,'Puls_AceticAcid','Puls_AceticAcid','µL',0.000000000000,NULL),
	 (86,'Puls_Medium','Puls_Medium','µL',0.000000000000,NULL),
	 (87,'Puls_Glucose','Puls_lucose','µL',0.000000000000,NULL),
	 (88,'Puls_Ethanol','Puls_Ethanol','µL',0.000000000000,NULL),
	 (89,'Cumulated_feed_volume_ethanol','Cumulated_feed_volume_ethanol','µL',0.000000000000,NULL),
	 (90,'Mu','Mu',NULL,0.000000000000,NULL),
	 (91,'Calculated_OD','Calculated_OD',NULL,NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (92,'Puls_Inducer','Puls_Inducer','µL',0.000000000000,NULL),
	 (93,'Inducer_addition','Inducer_addition','µL',1.000000000000,NULL),
	 (94,'IR','IR PreSens',NULL,0.000000000000,10.000000000000),
	 (97,'Sampling_atline','Sampling_atline','µL',0.000000000000,NULL),
	 (98,'Sampling_offline','Sampling_offline','µL',0.000000000000,NULL),
	 (99,'Feed_glc_cum_setpoints','Feed_glc_cum_setpoints','µL',0.000000000000,NULL),
	 (102,'Feed_glc_add_max','Feed_glc_add_max','µL',NULL,150.000000000000),
	 (103,'pH_offline','pH_offline','-',5.500000000000,8.000000000000),
	 (104,'pH_difference','pH_difference','-',NULL,NULL),
	 (105,'Glycerol','Glycerol','g/L',NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (106,'Ammonia','Ammonia','g/L',NULL,NULL),
	 (107,'Feed_pump_flow_rate','Feed_pump_flow_rate','mL/h',0.000000000000,4.000000000000),
	 (108,'Stirrer_power','Stirrer Power','V',0.000000000000,1.000000000000),
	 (109,'Turbidity','Turbidity',NULL,NULL,NULL),
	 (110,'antibody_concentration','antibody_concentration','ng/mL',0.000000000000,NULL),
	 (111,'Cumulated_feed_volume_dextrine','Cumulated_feed_volume_dextrine','µL',0.000000000000,NULL),
	 (112,'Feed_dextrine_cum_setpoints','Feed_dextrine_cum_setpoints','µL',0.000000000000,NULL),
	 (113,'Puls_Enzyme','Puls_Enzyme','µL',0.000000000000,NULL),
	 (114,'Magnesium','Magnesium','mg/L',0.000000000000,NULL),
	 (115,'Mg_Volume','Mg_Volume','µL',NULL,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (116,'Feed_start','Feed_start','-',NULL,NULL),
	 (117,'Formate','Formate','g/L',0.000000000000,1.000000000000),
	 (118,'AB_intracellular','AB_intracellular','g/L',0.000000000000,NULL),
	 (119,'AB_extracellular','AB_extracellular','g/L',0.000000000000,NULL),
	 (120,'Cumulated_feed_volume_Mg','Cumulated_feed_volume_Mg','uL',0.000000000000,NULL),
	 (121,'Puls_Phosphate','Puls_Phosphate','µL',0.000000000000,NULL),
	 (122,'Phosphate_addition','Phosphate_addition','µL',0.000000000000,NULL),
	 (123,'feed_glucose_concentration','feed_glucose_concentration','g/L',0.000000000000,NULL),
	 (124,'Positive_control_concentration','Positive_control_concentration','g/L',NULL,0.000000000000),
	 (125,'Offgas_CO2','Offgas_CO2','%',0.000000000000,5.000000000000);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (126,'Offgas_O2','Offgas_O2','%',15.000000000000,22.000000000000),
	 (127,'Offgas_Pressure','Offgas_Pressure','bar',NULL,NULL),
	 (128,'Offgas_Humidity','Offgas_Humidity','%',NULL,NULL),
	 (129,'Puls_Antifoam','Puls_Antifoam','µL',0.000000000000,NULL),
	 (130,'Antifoam_addition','Antifoam_addition','µL',1.000000000000,NULL),
	 (131,'Feed_enzyme_cum_setpoints','Feed_enzyme_cum_setpoints','µL',0.000000000000,NULL),
	 (132,'Volume_overflow_control','Volume_overflow_control','µL',0.000000000000,1000.000000000000),
	 (133,'Volume_evaporated','Volume_evaporated','µL',0.000000000000,NULL),
	 (134,'Phosphate','Phosphate','g/L',0.000000000000,NULL),
	 (135,'Total_Protein','Total_Protein','g/L',0.000000000000,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (136,'Glutamate','Glutamate','g/L',0.000000000000,NULL),
	 (137,'Induction_strength','Induction_strength','mM',0.000000000000,NULL),
	 (138,'Puls_YeastExtract','Puls_YeastExtract','µL',0.000000000000,NULL),
	 (139,'Puls_Iron','Puls_Iron','µL',0.000000000000,NULL),
	 (140,'Puls_Nickel','Puls_Nickel',NULL,NULL,NULL),
	 (141,'YeastExtract_addition','YeastExtract_addition','µL',0.000000000000,NULL),
	 (142,'Iron_addition','Iron_addition','µL',0.000000000000,NULL),
	 (143,'Nickel_addition','Nickel_addition','µL',0.000000000000,NULL),
	 (144,'Fluo_FbFP','Fluo_FbFP','RFU',NULL,NULL),
	 (145,'nanobody_total','nanobody_total','g/L',0.000000000000,NULL);
INSERT INTO ilabdb.variable_types (variable_type_id,canonical_name,display_name,unit,lower_limit,upper_limit) VALUES
	 (146,'nanobody_extracellular','nanobody_extracellular','g/L',0.000000000000,NULL);
