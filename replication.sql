/****** Scripting replication configuration. Script Date: 6/6/2019 11:22:44 PM ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Begin: Script to be run at Publisher ******/

/****** Installing the server as a Distributor. Script Date: 6/6/2019 11:22:44 PM ******/
use master
exec sp_adddistributor @distributor = N'DESKTOP-4AOI1UG', @password = N'', @from_scripting = 1
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
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'C:\Program Files\Microsoft SQL Server\MSSQL14.HUNG\MSSQL\Data', @data_file = N'distribution.MDF', @data_file_size = 13, @log_folder = N'C:\Program Files\Microsoft SQL Server\MSSQL14.HUNG\MSSQL\Data', @log_file = N'distribution.LDF', @log_file_size = 9, @min_distretention = 0, @max_distretention = 72, @history_retention = 48, @deletebatchsize_xact = 5000, @deletebatchsize_cmd = 2000, @security_mode = 1, @from_scripting = 1
GO

------ Script Date: Replication agents checkup ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Checkup') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Checkup'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'Replication agents checkup')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'Replication agents checkup', @enabled = 1, @description = N'Detects replication agents that are not logging history actively.', @start_step_id = 1, @category_name = N'REPL-Checkup', @owner_login_name = N'MicrosoftAccount\hu01684875828hu@gmail.com', @notify_level_eventlog = 2, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Run agent.', @subsystem = N'TSQL', @command = N'sys.sp_replication_agent_checkup @heartbeat_interval = 10', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @database_name = N'master', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 4, @freq_interval = 1, @freq_subday_type = 4, @freq_subday_interval = 10, @freq_relative_interval = 1, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 0, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: Reinitialize subscriptions having data validation failures ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Alert Response') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Alert Response'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'Reinitialize subscriptions having data validation failures')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'Reinitialize subscriptions having data validation failures', @enabled = 1, @description = N'Reinitializes all subscriptions that have data validation failures.', @start_step_id = 1, @category_name = N'REPL-Alert Response', @owner_login_name = N'MicrosoftAccount\hu01684875828hu@gmail.com', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Run agent.', @subsystem = N'TSQL', @command = N'exec sys.sp_MSreinit_failed_subscriptions @failure_level = 1', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'master', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: Replication monitoring refresher for distribution. ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Alert Response') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Alert Response'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'Replication monitoring refresher for distribution.')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'Replication monitoring refresher for distribution.', @enabled = 0, @description = N'Replication monitoring refresher for distribution.', @start_step_id = 1, @category_name = N'REPL-Alert Response', @owner_login_name = N'MicrosoftAccount\hu01684875828hu@gmail.com', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Run agent.', @subsystem = N'TSQL', @command = N'exec dbo.sp_replmonitorrefreshjob  ', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 2147483647, @retry_interval = 1, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 64, @freq_interval = 0, @freq_subday_type = 0, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 0, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: Agent history clean up: distribution ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-History Cleanup') < 1 
  execute msdb.dbo.sp_add_category N'REPL-History Cleanup'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'Agent history clean up: distribution')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'Agent history clean up: distribution', @enabled = 1, @description = N'Removes replication agent history from the distribution database.', @start_step_id = 1, @category_name = N'REPL-History Cleanup', @owner_login_name = N'MicrosoftAccount\hu01684875828hu@gmail.com', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Run agent.', @subsystem = N'TSQL', @command = N'EXEC dbo.sp_MShistory_cleanup @history_retention = 48', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 4, @freq_interval = 1, @freq_subday_type = 4, @freq_subday_interval = 10, @freq_relative_interval = 1, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 0, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: Distribution clean up: distribution ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Distribution Cleanup') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Distribution Cleanup'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'Distribution clean up: distribution')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'Distribution clean up: distribution', @enabled = 0, @description = N'Removes replicated transactions from the distribution database.', @start_step_id = 1, @category_name = N'REPL-Distribution Cleanup', @owner_login_name = N'MicrosoftAccount\hu01684875828hu@gmail.com', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Run agent.', @subsystem = N'TSQL', @command = N'EXEC dbo.sp_MSdistribution_cleanup @min_distretention = 0, @max_distretention = 72', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 4, @freq_interval = 1, @freq_subday_type = 4, @freq_subday_interval = 10, @freq_relative_interval = 1, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 500, @active_end_time = 459
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

-- Adding the distribution publishers
exec sp_adddistpublisher @publisher = N'DESKTOP-4AOI1UG', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\DESKTOP-4AOI1UG\RelData', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO

------ Script Date: DESKTOP-4AOI1UG-NganHang-CN1-5 ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Snapshot') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Snapshot'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'DESKTOP-4AOI1UG-NganHang-CN1-5')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'DESKTOP-4AOI1UG-NganHang-CN1-5', @enabled = 1, @description = N'No description available.', @start_step_id = 1, @category_name = N'REPL-Snapshot', @owner_login_name = N'sa', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Snapshot Agent startup message.', @subsystem = N'TSQL', @command = N'sp_MSadd_snapshot_history @perfmon_increment = 0,  @agent_id = 5, @runstatus = 1,  
                    @comments = N''Starting agent.''', @cmdexec_success_code = 0, @on_success_action = 3, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Run agent.', @subsystem = N'Snapshot', @command = N'-Publisher [DESKTOP-4AOI1UG] -PublisherDB [NganHang] -Distributor [DESKTOP-4AOI1UG] -Publication [CN1] -ReplicationType 2 -DistributorSecurityMode 1 ', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 10, @retry_interval = 1, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Detect nonlogged agent shutdown.', @subsystem = N'TSQL', @command = N'sp_MSdetect_nonlogged_shutdown @subsystem = ''Snapshot'', @agent_id = 5', @cmdexec_success_code = 0, @on_success_action = 2, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 4, @freq_interval = 14, @freq_subday_type = 1, @freq_subday_interval = 5, @freq_relative_interval = 1, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 500, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: DESKTOP-4AOI1UG-NganHang-CN2-6 ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Snapshot') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Snapshot'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'DESKTOP-4AOI1UG-NganHang-CN2-6')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'DESKTOP-4AOI1UG-NganHang-CN2-6', @enabled = 1, @description = N'No description available.', @start_step_id = 1, @category_name = N'REPL-Snapshot', @owner_login_name = N'sa', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Snapshot Agent startup message.', @subsystem = N'TSQL', @command = N'sp_MSadd_snapshot_history @perfmon_increment = 0,  @agent_id = 6, @runstatus = 1,  
                    @comments = N''Starting agent.''', @cmdexec_success_code = 0, @on_success_action = 3, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Run agent.', @subsystem = N'Snapshot', @command = N'-Publisher [DESKTOP-4AOI1UG] -PublisherDB [NganHang] -Distributor [DESKTOP-4AOI1UG] -Publication [CN2] -ReplicationType 2 -DistributorSecurityMode 1 ', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 10, @retry_interval = 1, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Detect nonlogged agent shutdown.', @subsystem = N'TSQL', @command = N'sp_MSdetect_nonlogged_shutdown @subsystem = ''Snapshot'', @agent_id = 6', @cmdexec_success_code = 0, @on_success_action = 2, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 4, @freq_interval = 14, @freq_subday_type = 1, @freq_subday_interval = 5, @freq_relative_interval = 1, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 500, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: DESKTOP-4AOI1UG-NganHang-CN2-DESKTOP-4AOI1UG\CN2-6 ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Merge') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Merge'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'DESKTOP-4AOI1UG-NganHang-CN2-DESKTOP-4AOI1UG\CN2-6')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'DESKTOP-4AOI1UG-NganHang-CN2-DESKTOP-4AOI1UG\CN2-6', @enabled = 1, @description = N'No description available.', @start_step_id = 1, @category_name = N'REPL-Merge', @owner_login_name = N'sa', @notify_level_eventlog = 2, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Merge Agent startup message.', @subsystem = N'TSQL', @command = N'sp_MSadd_merge_history @perfmon_increment = 0, @agent_id = 6, @runstatus = 1,  
                    @comments = N''Starting agent.''', @cmdexec_success_code = 0, @on_success_action = 3, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Run agent.', @subsystem = N'Merge', @command = N'-Publisher [DESKTOP-4AOI1UG] -PublisherDB [NganHang] -Publication [CN2] -Subscriber [DESKTOP-4AOI1UG\CN2] -SubscriberDB [NganHang]   -Distributor [DESKTOP-4AOI1UG] -DistributorSecurityMode 1 ', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 10, @retry_interval = 1, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Detect nonlogged agent shutdown.', @subsystem = N'TSQL', @command = N'sp_MSdetect_nonlogged_shutdown @subsystem = ''Merge'', @agent_id = 6', @cmdexec_success_code = 0, @on_success_action = 2, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 0, @freq_type = 1, @freq_interval = 0, @freq_subday_type = 0, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_start_date = 19950101, @active_end_date = 19950101, @active_start_time = 0, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: DESKTOP-4AOI1UG-NganHang-CN1-DESKTOP-4AOI1UG\CN1-5 ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Merge') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Merge'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'DESKTOP-4AOI1UG-NganHang-CN1-DESKTOP-4AOI1UG\CN1-5')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'DESKTOP-4AOI1UG-NganHang-CN1-DESKTOP-4AOI1UG\CN1-5', @enabled = 1, @description = N'No description available.', @start_step_id = 1, @category_name = N'REPL-Merge', @owner_login_name = N'sa', @notify_level_eventlog = 2, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Merge Agent startup message.', @subsystem = N'TSQL', @command = N'sp_MSadd_merge_history @perfmon_increment = 0, @agent_id = 5, @runstatus = 1,  
                    @comments = N''Starting agent.''', @cmdexec_success_code = 0, @on_success_action = 3, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 2, @step_name = N'Run agent.', @subsystem = N'Merge', @command = N'-Publisher [DESKTOP-4AOI1UG] -PublisherDB [NganHang] -Publication [CN1] -Subscriber [DESKTOP-4AOI1UG\CN1] -SubscriberDB [NganHang]   -Distributor [DESKTOP-4AOI1UG] -DistributorSecurityMode 1 ', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 3, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 10, @retry_interval = 1, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 3, @step_name = N'Detect nonlogged agent shutdown.', @subsystem = N'TSQL', @command = N'sp_MSdetect_nonlogged_shutdown @subsystem = ''Merge'', @agent_id = 5', @cmdexec_success_code = 0, @on_success_action = 2, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'distribution', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 0, @freq_type = 1, @freq_interval = 0, @freq_subday_type = 0, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 0, @active_start_date = 19950101, @active_end_date = 19950101, @active_start_time = 0, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO

------ Script Date: Expired subscription clean up ------
begin transaction 
  DECLARE @JobID BINARY(16)
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0
if (select count(*) from msdb.dbo.syscategories where name = N'REPL-Subscription Cleanup') < 1 
  execute msdb.dbo.sp_add_category N'REPL-Subscription Cleanup'

select @JobID = job_id from msdb.dbo.sysjobs where (name = N'Expired subscription clean up')
if (@JobID is NULL)
BEGIN
  execute @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT, @job_name = N'Expired subscription clean up', @enabled = 1, @description = N'Detects and removes expired subscriptions from published databases or distribution databases.', @start_step_id = 1, @category_name = N'REPL-Subscription Cleanup', @owner_login_name = N'sa', @notify_level_eventlog = 0, @notify_level_email = 0, @notify_level_netsend = 0, @notify_level_page = 0, @delete_level = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'Run agent.', @subsystem = N'TSQL', @command = N'EXEC sys.sp_expired_subscription_cleanup', @cmdexec_success_code = 0, @on_success_action = 1, @on_success_step_id = 0, @on_fail_action = 2, @on_fail_step_id = 0, @server = N'DESKTOP-4AOI1UG', @database_name = N'master', @retry_attempts = 0, @retry_interval = 0, @os_run_priority = 0, @flags = 0
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'Replication agent schedule.', @enabled = 1, @freq_type = 4, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 1, @freq_relative_interval = 1, @freq_recurrence_factor = 0, @active_start_date = 20190606, @active_end_date = 99991231, @active_start_time = 10000, @active_end_time = 235959
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

  execute @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'DESKTOP-4AOI1UG'
  if (@@ERROR <> 0 OR @ReturnCode <> 0) goto QuitWithRollback

END

commit transaction 
goto EndSave 
QuitWithRollback: 
  if (@@TRANCOUNT > 0) rollback transaction 
EndSave:
GO


/****** End: Script to be run at Publisher ******/


-- Enabling the replication database
use master
exec sp_replicationdboption @dbname = N'NganHang', @optname = N'merge publish', @value = N'true'
GO

-- Adding the merge publication
use [NganHang]
exec sp_addmergepublication @publication = N'CN1', @description = N'Merge publication of database ''NganHang'' from Publisher ''DESKTOP-4AOI1UG''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'true', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = N'true', @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'CN1', @snapshot_job_name = N'DESKTOP-4AOI1UG-NganHang-CN1-5', @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''
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
exec sp_addmergearticle @publication = N'CN1', @article = N'sysdiagrams', @source_owner = N'dbo', @source_object = N'sysdiagrams', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'auto', @pub_identity_range = 10000, @identity_range = 1000, @threshold = 80, @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
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
exec sp_addmergearticle @publication = N'CN1', @article = N'fn_diagramobjects', @source_owner = N'dbo', @source_object = N'fn_diagramobjects', @type = N'func schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'fn_diagramobjects', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_alterdiagram', @source_owner = N'dbo', @source_object = N'sp_alterdiagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_alterdiagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_creatediagram', @source_owner = N'dbo', @source_object = N'sp_creatediagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_creatediagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_ib', @source_owner = N'dbo', @source_object = N'sp_delete_ib', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_ib', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_ib_taikhoan', @source_owner = N'dbo', @source_object = N'sp_delete_ib_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_ib_taikhoan', @force_reinit_subscription = 1
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
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_delete_the_taikhoan', @source_owner = N'dbo', @source_object = N'sp_delete_the_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_the_taikhoan', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_dropdiagram', @source_owner = N'dbo', @source_object = N'sp_dropdiagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_dropdiagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_helpdiagramdefinition', @source_owner = N'dbo', @source_object = N'sp_helpdiagramdefinition', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_helpdiagramdefinition', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_helpdiagrams', @source_owner = N'dbo', @source_object = N'sp_helpdiagrams', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_helpdiagrams', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_ib', @source_owner = N'dbo', @source_object = N'sp_insert_ib', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_ib', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_ib_taikhoan', @source_owner = N'dbo', @source_object = N'sp_insert_ib_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_ib_taikhoan', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_nhanvien', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_nhanvien_quanly', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien_quanly', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien_quanly', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_the', @source_owner = N'dbo', @source_object = N'sp_insert_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_insert_the_taikhoan', @source_owner = N'dbo', @source_object = N'sp_insert_the_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the_taikhoan', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_renamediagram', @source_owner = N'dbo', @source_object = N'sp_renamediagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_renamediagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_khachhang', @source_owner = N'dbo', @source_object = N'sp_update_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_nhanvien_nhanvien', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_nhanvien_qlcn', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_qlcn', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_qlcn', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_pass_ib', @source_owner = N'dbo', @source_object = N'sp_update_pass_ib', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_pass_ib', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_update_pass_the', @source_owner = N'dbo', @source_object = N'sp_update_pass_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_pass_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN1', @article = N'sp_upgraddiagrams', @source_owner = N'dbo', @source_object = N'sp_upgraddiagrams', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_upgraddiagrams', @force_reinit_subscription = 1
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
exec sp_addmergepushsubscription_agent @publication = N'CN1', @subscriber = N'DESKTOP-4AOI1UG\CN1', @subscriber_db = N'NganHang', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'sa', @subscriber_password = null, @publisher_security_mode = 1, @job_name = N'DESKTOP-4AOI1UG-NganHang-CN1-DESKTOP-4AOI1UG\CN1-5'
GO

-- Adding the merge publication
use [NganHang]
exec sp_addmergepublication @publication = N'CN2', @description = N'Merge publication of database ''NganHang'' from Publisher ''DESKTOP-4AOI1UG''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = N'true', @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
GO


exec sp_addpublication_snapshot @publication = N'CN2', @snapshot_job_name = N'DESKTOP-4AOI1UG-NganHang-CN2-6', @job_login = null, @job_password = null, @publisher_security_mode = 0, @publisher_login = N'sa', @publisher_password = N''
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
exec sp_addmergearticle @publication = N'CN2', @article = N'sysdiagrams', @source_owner = N'dbo', @source_object = N'sysdiagrams', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'auto', @pub_identity_range = 10000, @identity_range = 1000, @threshold = 80, @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'KhachHang', @source_owner = N'dbo', @source_object = N'KhachHang', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] = ''CN2''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'NhanVien', @source_owner = N'dbo', @source_object = N'NhanVien', @type = N'table', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'none', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[ChiNhanh] =  ''CN2''', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'true', @partition_options = 0
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
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_alterdiagram', @source_owner = N'dbo', @source_object = N'sp_alterdiagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_alterdiagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_creatediagram', @source_owner = N'dbo', @source_object = N'sp_creatediagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_creatediagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_ib', @source_owner = N'dbo', @source_object = N'sp_delete_ib', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_ib', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_ib_taikhoan', @source_owner = N'dbo', @source_object = N'sp_delete_ib_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_ib_taikhoan', @force_reinit_subscription = 1
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
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_delete_the_taikhoan', @source_owner = N'dbo', @source_object = N'sp_delete_the_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_delete_the_taikhoan', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_dropdiagram', @source_owner = N'dbo', @source_object = N'sp_dropdiagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_dropdiagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_helpdiagramdefinition', @source_owner = N'dbo', @source_object = N'sp_helpdiagramdefinition', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_helpdiagramdefinition', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_helpdiagrams', @source_owner = N'dbo', @source_object = N'sp_helpdiagrams', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_helpdiagrams', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_ib', @source_owner = N'dbo', @source_object = N'sp_insert_ib', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_ib', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_ib_taikhoan', @source_owner = N'dbo', @source_object = N'sp_insert_ib_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_ib_taikhoan', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_nhanvien', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_nhanvien_quanly', @source_owner = N'dbo', @source_object = N'sp_insert_nhanvien_quanly', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_nhanvien_quanly', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_the', @source_owner = N'dbo', @source_object = N'sp_insert_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_insert_the_taikhoan', @source_owner = N'dbo', @source_object = N'sp_insert_the_taikhoan', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_insert_the_taikhoan', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_renamediagram', @source_owner = N'dbo', @source_object = N'sp_renamediagram', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_renamediagram', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_khachhang', @source_owner = N'dbo', @source_object = N'sp_update_khachhang', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_khachhang', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_nhanvien_nhanvien', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_nhanvien', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_nhanvien', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_nhanvien_qlcn', @source_owner = N'dbo', @source_object = N'sp_update_nhanvien_qlcn', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_nhanvien_qlcn', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_pass_ib', @source_owner = N'dbo', @source_object = N'sp_update_pass_ib', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_pass_ib', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_update_pass_the', @source_owner = N'dbo', @source_object = N'sp_update_pass_the', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_update_pass_the', @force_reinit_subscription = 1
GO
use [NganHang]
exec sp_addmergearticle @publication = N'CN2', @article = N'sp_upgraddiagrams', @source_owner = N'dbo', @source_object = N'sp_upgraddiagrams', @type = N'proc schema only', @description = N'', @creation_script = N'', @pre_creation_cmd = N'drop', @schema_option = 0x0000000008000001, @destination_owner = N'dbo', @destination_object = N'sp_upgraddiagrams', @force_reinit_subscription = 1
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
exec sp_addmergepushsubscription_agent @publication = N'CN2', @subscriber = N'DESKTOP-4AOI1UG\CN2', @subscriber_db = N'NganHang', @job_login = null, @job_password = null, @subscriber_security_mode = 0, @subscriber_login = N'sa', @subscriber_password = null, @publisher_security_mode = 1, @job_name = N'DESKTOP-4AOI1UG-NganHang-CN2-DESKTOP-4AOI1UG\CN2-6'
GO



