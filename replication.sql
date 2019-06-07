/****** Scripting replication configuration. Script Date: 6/7/2019 2:51:31 PM ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Begin: Script to be run at Publisher ******/

/****** Installing the server as a Distributor. Script Date: 6/7/2019 2:51:31 PM ******/
use master
exec sp_adddistributor @distributor = N'DESKTOP-4AOI1UG', @password = N''
GO

-- Adding the agent profiles
-- Updating the agent profile defaults
exec sp_MSupdate_agenttype_default @profile_id = 1
GO
exec sp_MSupdate_agenttype_default @profile_id = 2
GO
exec sp_MSupdate_agenttype_default @profile_id = 4
GO
exec sp_MSupdate_agenttype_default @profile_id = 6
GO
exec sp_MSupdate_agenttype_default @profile_id = 11
GO

-- Adding the distribution databases
use master
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'C:\Program Files\Microsoft SQL Server\MSSQL14.HUNG\MSSQL\Data', @data_file = N'distribution.MDF', @data_file_size = 13, @log_folder = N'C:\Program Files\Microsoft SQL Server\MSSQL14.HUNG\MSSQL\Data', @log_file = N'distribution.LDF', @log_file_size = 9, @min_distretention = 0, @max_distretention = 72, @history_retention = 48, @deletebatchsize_xact = 5000, @deletebatchsize_cmd = 2000, @security_mode = 1
GO

-- Adding the distribution publishers
exec sp_adddistpublisher @publisher = N'DESKTOP-4AOI1UG', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\DESKTOP-4AOI1UG\RelData', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO


/****** End: Script to be run at Publisher ******/


-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'NganHang', @optname = N'merge publish', @value = N'true'
GO

-- Adding the merge publication
use [NganHang]
exec sp_addmergepublication @publication = N'CN1', @description = N'Merge publication of database ''NganHang'' from Publisher ''DESKTOP-4AOI1UG''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = N'true', @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'CN1', @frequency_type = 4, @frequency_interval = 14, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 1, @frequency_subday_interval = 5, @active_start_time_of_day = 500, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''
exec sp_grant_publication_access @publication = N'CN1', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'CN1', @login = N'DESKTOP-4AOI1UG\hu016'
GO
exec sp_grant_publication_access @publication = N'CN1', @login = N'NT SERVICE\Winmgmt'
GO
exec sp_grant_publication_access @publication = N'CN1', @login = N'NT SERVICE\SQLWriter'
GO
exec sp_grant_publication_access @publication = N'CN1', @login = N'NT SERVICE\SQLSERVERAGENT'
GO
exec sp_grant_publication_access @publication = N'CN1', @login = N'NT Service\MSSQLSERVER'
GO
exec sp_grant_publication_access @publication = N'CN1', @login = N'distributor_admin'
GO

-- Adding the merge articles
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'ChiNhanh', @source_owner = N'dbo', @source_object = N'ChiNhanh', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'KhachHang', @source_owner = N'dbo', @source_object = N'KhachHang', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] = ''CN1''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'NhanVien', @source_owner = N'dbo', @source_object = N'NhanVien', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] = ''CN1''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'InternetBanking', @source_owner = N'dbo', @source_object = N'InternetBanking', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'The', @source_owner = N'dbo', @source_object = N'The', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'TKTT', @source_owner = N'dbo', @source_object = N'TKTT', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'TKTK', @source_owner = N'dbo', @source_object = N'TKTK', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'IB_TaiKhoan', @source_owner = N'dbo', @source_object = N'IB_TaiKhoan', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'The_TaiKhoan', @source_owner = N'dbo', @source_object = N'The_TaiKhoan', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_creatediagram', @source_owner = N'dbo', @source_object = N'sp_creatediagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_creatediagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_internet_banking', @source_owner = N'dbo', @source_object = N'sp_delete_internet_banking', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_internet_banking', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_khachhang', @source_owner = N'dbo', @source_object = N'sp_delete_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_nhanvien', @source_owner = N'dbo', @source_object = N'sp_delete_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_the', @source_owner = N'dbo', @source_object = N'sp_delete_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_internet_banking', @source_owner = N'dbo', @source_object = N'sp_insert_internet_banking', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_internet_banking', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_khachhang', @source_owner = N'dbo', @source_object = N'sp_insert_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_nhanvien', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_the', @source_owner = N'dbo', @source_object = N'sp_insert_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_tktt', @source_owner = N'dbo', @source_object = N'sp_insert_tktt', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_tktt', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_select_nhanvien', @source_owner = N'dbo', @source_object = N'sp_select_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_select_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_internet_banking', @source_owner = N'dbo', @source_object = N'sp_update_internet_banking', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_internet_banking', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_khachhang', @source_owner = N'dbo', @source_object = N'sp_update_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_nhanvien_nhanvien', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_nhanvien_quanly', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_quanly', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_quanly', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_the', @source_owner = N'dbo', @source_object = N'sp_update_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_tktt', @source_owner = N'dbo', @source_object = N'sp_update_tktt', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_tktt', @force_reinit_subscription = 1
GO

-- Adding the merge article join filters
use [NganHang]
exec sp_addmergefilter @publication = N'CN1', @article = N'IB_TaiKhoan', @filtername = N'IB_TaiKhoan_InternetBanking', @join_articlename = N'InternetBanking', @join_filterclause = N'[InternetBanking].[Username] = [IB_TaiKhoan].[Username]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN1', @article = N'InternetBanking', @filtername = N'InternetBanking_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [InternetBanking].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN1', @article = N'The', @filtername = N'The_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [The].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN1', @article = N'TKTK', @filtername = N'TKTK_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [TKTK].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN1', @article = N'TKTT', @filtername = N'TKTT_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [TKTT].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN1', @article = N'The_TaiKhoan', @filtername = N'The_TaiKhoan_The', @join_articlename = N'The', @join_filterclause = N'[The].[ID] = [The_TaiKhoan].[The]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO

-- Adding the merge subscriptions
use [NganHang]
exec sp_addmergesubscription @publication = N'CN1', @subscriber = N'DESKTOP-4AOI1UG\CN1', @subscriber_db = N'NganHang', @subscription_type = N'Push', @sync_type = N'Automatic', @subscriber_type = N'Global', @subscription_priority = 75, @description = N'', @use_interactive_resolver = N'False'
exec sp_addmergepushsubscription_agent @publication = N'CN1', @subscriber = N'DESKTOP-4AOI1UG\CN1', @subscriber_db = N'NganHang', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'sa', @subscriber_password = null, @publisher_security_mode = 1, @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0
GO

-- Adding the merge publication
use [NganHang]
exec sp_addmergepublication @publication = N'CN2', @description = N'Merge publication of database ''NganHang'' from Publisher ''DESKTOP-4AOI1UG''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = N'true', @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'CN2', @frequency_type = 4, @frequency_interval = 14, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 1, @frequency_subday_interval = 5, @active_start_time_of_day = 500, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''
exec sp_grant_publication_access @publication = N'CN2', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'CN2', @login = N'DESKTOP-4AOI1UG\hu016'
GO
exec sp_grant_publication_access @publication = N'CN2', @login = N'NT SERVICE\Winmgmt'
GO
exec sp_grant_publication_access @publication = N'CN2', @login = N'NT SERVICE\SQLWriter'
GO
exec sp_grant_publication_access @publication = N'CN2', @login = N'NT SERVICE\SQLSERVERAGENT'
GO
exec sp_grant_publication_access @publication = N'CN2', @login = N'NT Service\MSSQLSERVER'
GO
exec sp_grant_publication_access @publication = N'CN2', @login = N'distributor_admin'
GO

-- Adding the merge articles
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'ChiNhanh', @source_owner = N'dbo', @source_object = N'ChiNhanh', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'KhachHang', @source_owner = N'dbo', @source_object = N'KhachHang', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] = ''CN2''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'NhanVien', @source_owner = N'dbo', @source_object = N'NhanVien', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] = ''CN2''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'InternetBanking', @source_owner = N'dbo', @source_object = N'InternetBanking', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'The', @source_owner = N'dbo', @source_object = N'The', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'TKTT', @source_owner = N'dbo', @source_object = N'TKTT', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'TKTK', @source_owner = N'dbo', @source_object = N'TKTK', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'IB_TaiKhoan', @source_owner = N'dbo', @source_object = N'IB_TaiKhoan', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'The_TaiKhoan', @source_owner = N'dbo', @source_object = N'The_TaiKhoan', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_internet_banking', @source_owner = N'dbo', @source_object = N'sp_delete_internet_banking', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_internet_banking', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_khachhang', @source_owner = N'dbo', @source_object = N'sp_delete_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_nhanvien', @source_owner = N'dbo', @source_object = N'sp_delete_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_the', @source_owner = N'dbo', @source_object = N'sp_delete_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_internet_banking', @source_owner = N'dbo', @source_object = N'sp_insert_internet_banking', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_internet_banking', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_khachhang', @source_owner = N'dbo', @source_object = N'sp_insert_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_nhanvien', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_the', @source_owner = N'dbo', @source_object = N'sp_insert_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_tktt', @source_owner = N'dbo', @source_object = N'sp_insert_tktt', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_tktt', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_select_nhanvien', @source_owner = N'dbo', @source_object = N'sp_select_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_select_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_internet_banking', @source_owner = N'dbo', @source_object = N'sp_update_internet_banking', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_internet_banking', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_khachhang', @source_owner = N'dbo', @source_object = N'sp_update_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_nhanvien_nhanvien', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_nhanvien_quanly', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_quanly', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_quanly', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_the', @source_owner = N'dbo', @source_object = N'sp_update_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_tktt', @source_owner = N'dbo', @source_object = N'sp_update_tktt', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_tktt', @force_reinit_subscription = 1
GO

-- Adding the merge article join filters
use [NganHang]
exec sp_addmergefilter @publication = N'CN2', @article = N'IB_TaiKhoan', @filtername = N'IB_TaiKhoan_InternetBanking', @join_articlename = N'InternetBanking', @join_filterclause = N'[InternetBanking].[Username] = [IB_TaiKhoan].[Username]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN2', @article = N'InternetBanking', @filtername = N'InternetBanking_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [InternetBanking].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN2', @article = N'The', @filtername = N'The_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [The].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN2', @article = N'TKTK', @filtername = N'TKTK_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [TKTK].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN2', @article = N'TKTT', @filtername = N'TKTT_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [TKTT].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergefilter @publication = N'CN2', @article = N'The_TaiKhoan', @filtername = N'The_TaiKhoan_The', @join_articlename = N'The', @join_filterclause = N'[The].[ID] = [The_TaiKhoan].[The]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO

-- Adding the merge subscriptions
use [NganHang]
exec sp_addmergesubscription @publication = N'CN2', @subscriber = N'DESKTOP-4AOI1UG\CN2', @subscriber_db = N'NganHang', @subscription_type = N'Push', @sync_type = N'Automatic', @subscriber_type = N'Global', @subscription_priority = 75, @description = N'', @use_interactive_resolver = N'False'
exec sp_addmergepushsubscription_agent @publication = N'CN2', @subscriber = N'DESKTOP-4AOI1UG\CN2', @subscriber_db = N'NganHang', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'sa', @subscriber_password = null, @publisher_security_mode = 1, @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0
GO



