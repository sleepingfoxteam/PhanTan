-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'TUIBANK', @optname = N'merge publish', @value = N'true'
GO

-- Adding the merge publication
use [TUIBANK]
exec sp_addmergepublication @publication = N'BRHNO', @description = N'Merge publication of database ''TUIBANK'' from Publisher ''DESKTOP-4AOI1UG''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = N'true', @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'BRHNO', @frequency_type = 4, @frequency_interval = 14, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 1, @frequency_subday_interval = 5, @active_start_time_of_day = 500, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'sa'
GO
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'DESKTOP-4AOI1UG\hu016'
GO
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'NT SERVICE\Winmgmt'
GO
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'NT SERVICE\SQLWriter'
GO
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'NT SERVICE\SQLSERVERAGENT'
GO
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'NT Service\MSSQLSERVER'
GO
exec sp_grant_publication_access @publication = N'BRHNO', @login = N'distributor_admin'
GO

-- Adding the merge articles
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'Branch', @source_owner = N'dbo', @source_object = N'Branch', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'Customer', @source_owner = N'dbo', @source_object = N'Customer', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[Branch] = ''BRHNO''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'Staff', @source_owner = N'dbo', @source_object = N'Staff', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[Branch] = ''BRHNO''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'Account', @source_owner = N'dbo', @source_object = N'Account', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_add_Account', @source_owner = N'dbo', @source_object = N'sp_add_Account', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_add_Account', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_add_Customer', @source_owner = N'dbo', @source_object = N'sp_add_Customer', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_add_Customer', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_add_Staff', @source_owner = N'dbo', @source_object = N'sp_add_Staff', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_add_Staff', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_delete_Account', @source_owner = N'dbo', @source_object = N'sp_delete_Account', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_Account', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_delete_Customer', @source_owner = N'dbo', @source_object = N'sp_delete_Customer', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_Customer', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_delete_staff', @source_owner = N'dbo', @source_object = N'sp_delete_staff', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_staff', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_find_account', @source_owner = N'dbo', @source_object = N'sp_find_account', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_find_account', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_find_account_info', @source_owner = N'dbo', @source_object = N'sp_find_account_info', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_find_account_info', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_get_balance', @source_owner = N'dbo', @source_object = N'sp_get_balance', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_get_balance', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_send_money', @source_owner = N'dbo', @source_object = N'sp_send_money', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_send_money', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_update_Account', @source_owner = N'dbo', @source_object = N'sp_update_Account', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_Account', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_update_Account_balance', @source_owner = N'dbo', @source_object = N'sp_update_Account_balance', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_Account_balance', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_update_Customer', @source_owner = N'dbo', @source_object = N'sp_update_Customer', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_Customer', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'sp_update_Staff', @source_owner = N'dbo', @source_object = N'sp_update_Staff', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_Staff', @force_reinit_subscription = 1
GO
use [TUIBANK]
exec sp_addmergearticle @publication = N'BRHNO', @article = N'View_Customer_Account', @source_owner = N'dbo', @source_object = N'View_Customer_Account', @type = N'view schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'View_Customer_Account', @force_reinit_subscription = 1
GO

-- Adding the merge article join filters
use [TUIBANK]
exec sp_addmergefilter @publication = N'BRHNO', @article = N'Account', @filtername = N'Account_Customer', @join_articlename = N'Customer', @join_filterclause = N'[Customer].[CustomerID] = [Account].[Customer]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO

-- Adding the merge subscriptions
use [TUIBANK]
exec sp_addmergesubscription @publication = N'BRHNO', @subscriber = N'DESKTOP-4AOI1UG\CN2', @subscriber_db = N'TUIBANK', @subscription_type = N'Push', @sync_type = N'Automatic', @subscriber_type = N'Global', @subscription_priority = 75, @description = N'', @use_interactive_resolver = N'False'
exec sp_addmergepushsubscription_agent @publication = N'BRHNO', @subscriber = N'DESKTOP-4AOI1UG\CN2', @subscriber_db = N'TUIBANK', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'sa', @subscriber_password = null, @publisher_security_mode = 1, @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0
GO

