-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'NganHang', @optname = N'merge publish', @value = N'true'
GO

-- Adding the merge publication
use [NganHang]
exec sp_addmergepublication @publication = N'CN2', @description = N'Merge publication of database ''NganHang'' from Publisher ''DESKTOP-4AOI1UG''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = null, @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'CN2', @frequency_type = 4, @frequency_interval = 14, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 1, @frequency_subday_interval = 5, @active_start_time_of_day = 500, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'ChiNhanh', @source_owner = N'dbo', @source_object = N'ChiNhanh', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'IB_TaiKhoan', @source_owner = N'dbo', @source_object = N'IB_TaiKhoan', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'InternetBanking', @source_owner = N'dbo', @source_object = N'InternetBanking', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'KhachHang', @source_owner = N'dbo', @source_object = N'KhachHang', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] = ''CN2''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'NhanVien', @source_owner = N'dbo', @source_object = N'NhanVien', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] =  ''CN2''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sysdiagrams', @source_owner = N'dbo', @source_object = N'sysdiagrams', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'auto', @pub_identity_range = 10000, @identity_range = 1000, @threshold = 80, @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'The', @source_owner = N'dbo', @source_object = N'The', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'The_TaiKhoan', @source_owner = N'dbo', @source_object = N'The_TaiKhoan', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'TKTK', @source_owner = N'dbo', @source_object = N'TKTK', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'TKTT', @source_owner = N'dbo', @source_object = N'TKTT', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_alterdiagram', @source_owner = N'dbo', @source_object = N'sp_alterdiagram', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_alterdiagram', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_creatediagram', @source_owner = N'dbo', @source_object = N'sp_creatediagram', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_creatediagram', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_ib', @source_owner = N'dbo', @source_object = N'sp_delete_ib', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_ib', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_ib_taikhoan', @source_owner = N'dbo', @source_object = N'sp_delete_ib_taikhoan', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_ib_taikhoan', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_khachhang', @source_owner = N'dbo', @source_object = N'sp_delete_khachhang', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_khachhang', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_nhanvien', @source_owner = N'dbo', @source_object = N'sp_delete_nhanvien', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_nhanvien', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_the', @source_owner = N'dbo', @source_object = N'sp_delete_the', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_the', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_the_taikhoan', @source_owner = N'dbo', @source_object = N'sp_delete_the_taikhoan', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_the_taikhoan', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_dropdiagram', @source_owner = N'dbo', @source_object = N'sp_dropdiagram', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_dropdiagram', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_helpdiagramdefinition', @source_owner = N'dbo', @source_object = N'sp_helpdiagramdefinition', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_helpdiagramdefinition', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_helpdiagrams', @source_owner = N'dbo', @source_object = N'sp_helpdiagrams', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_helpdiagrams', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_ib', @source_owner = N'dbo', @source_object = N'sp_insert_ib', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_ib', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_ib_taikhoan', @source_owner = N'dbo', @source_object = N'sp_insert_ib_taikhoan', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_ib_taikhoan', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_nhanvien', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_nhanvien_quanly', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien_quanly', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien_quanly', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_the', @source_owner = N'dbo', @source_object = N'sp_insert_the', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_the_taikhoan', @source_owner = N'dbo', @source_object = N'sp_insert_the_taikhoan', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the_taikhoan', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_renamediagram', @source_owner = N'dbo', @source_object = N'sp_renamediagram', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_renamediagram', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_khachhang', @source_owner = N'dbo', @source_object = N'sp_update_khachhang', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_khachhang', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_nhanvien_nhanvien', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_nhanvien', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_nhanvien', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_nhanvien_qlcn', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_qlcn', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_qlcn', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_pass_ib', @source_owner = N'dbo', @source_object = N'sp_update_pass_ib', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_pass_ib', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_pass_the', @source_owner = N'dbo', @source_object = N'sp_update_pass_the', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_pass_the', @force_reinit_subscription = 1
GO


use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_upgraddiagrams', @source_owner = N'dbo', @source_object = N'sp_upgraddiagrams', @type = N'proc schema only', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_upgraddiagrams', @force_reinit_subscription = 1
GO


exec sp_addmergefilter @publication = N'CN2', @article = N'IB_TaiKhoan', @filtername = N'IB_TaiKhoan_InternetBanking', @join_articlename = N'InternetBanking', @join_filterclause = N'[InternetBanking].[Username] = [IB_TaiKhoan].[Username]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_addmergefilter @publication = N'CN2', @article = N'InternetBanking', @filtername = N'InternetBanking_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [InternetBanking].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_addmergefilter @publication = N'CN2', @article = N'The', @filtername = N'The_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [The].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_addmergefilter @publication = N'CN2', @article = N'TKTK', @filtername = N'TKTK_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [TKTK].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_addmergefilter @publication = N'CN2', @article = N'TKTT', @filtername = N'TKTT_KhachHang', @join_articlename = N'KhachHang', @join_filterclause = N'[KhachHang].[ID] = [TKTT].[KhachHang]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
exec sp_addmergefilter @publication = N'CN2', @article = N'The_TaiKhoan', @filtername = N'The_TaiKhoan_The', @join_articlename = N'The', @join_filterclause = N'[The].[ID] = [The_TaiKhoan].[The]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1
GO
