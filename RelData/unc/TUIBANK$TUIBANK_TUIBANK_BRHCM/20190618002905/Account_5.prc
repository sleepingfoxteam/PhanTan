SET QUOTED_IDENTIFIER ON

go

-- these are subscriber side procs
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON


go

-- drop all the procedures first
if object_id('MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6','P') is not NULL
    drop procedure MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6
if object_id('MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6_batch','P') is not NULL
    drop procedure MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6_batch
if object_id('MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6','P') is not NULL
    drop procedure MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6
if object_id('MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6_batch','P') is not NULL
    drop procedure MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6_batch
if object_id('MSmerge_del_sp_5760AC0DEF4342F89DEE015E138843B6','P') is not NULL
    drop procedure MSmerge_del_sp_5760AC0DEF4342F89DEE015E138843B6
if object_id('MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6','P') is not NULL
    drop procedure MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6
if object_id('MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6_metadata','P') is not NULL
    drop procedure MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6_metadata
if object_id('MSmerge_cft_sp_5760AC0DEF4342F89DEE015E138843B6','P') is not NULL
    drop procedure MSmerge_cft_sp_5760AC0DEF4342F89DEE015E138843B6


go
create procedure dbo.[MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6] (@rowguid uniqueidentifier, 
            @generation bigint, @lineage varbinary(311),  @colv varbinary(1) 
, 
        @p1 nvarchar(50)
, 
        @p2 nvarchar(50)
, 
        @p3 date
, 
        @p4 date
, 
        @p5 float
, 
        @p6 int
, 
        @p7 int
, 
        @p8 nvarchar(50)
, 
        @p9 uniqueidentifier
,@metadata_type tinyint = NULL, @lineage_old varbinary(311) = NULL, @compatlevel int = 10 
) as
    declare @errcode    int
    declare @retcode    int
    declare @rowcount   int
    declare @error      int
    declare @tablenick  int
    declare @started_transaction bit
    declare @publication_number smallint
    
    set nocount on

    select @started_transaction = 0
    select @publication_number = 1

    set @errcode= 0
    select @tablenick= 26466000
    
    if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end



    declare @resend int

    set @resend = 0 

    if @@trancount = 0 
    begin
        begin transaction
        select @started_transaction = 1
    end
    if @metadata_type = 1 or @metadata_type = 5
    begin
        if @compatlevel < 90 and @lineage_old is not null
            set @lineage_old= {fn LINEAGE_80_TO_90(@lineage_old)}
        -- check meta consistency
        if not exists (select * from dbo.MSmerge_tombstone where tablenick = @tablenick and rowguid = @rowguid and
                        lineage = @lineage_old)
        begin
            set @errcode= 2
-- DEBUG            insert into MSmerge_debug 
-- DEBUG                (okay, artnick, rowguid, type, successcode, generation_new, lineage_old, lineage_new, twhen, comment)
-- DEBUG                values (1, @tablenick, @rowguid, @metadata_type, @errcode, @generation, @lineage_old, @lineage, getdate(), 'sp_ins')
            goto Failure
        end
    end
    -- set row meta data
    
        exec @retcode= sys.sp_MSsetrowmetadata 
            @tablenick, @rowguid, @generation, 
            @lineage, @colv, 2, @resend OUTPUT,
            @compatlevel, 1, '9DEE015E-1388-43B6-BDF0-8C2967FBB918'
        if @retcode<>0 or @@ERROR<>0
        begin
            set @errcode= 0
            goto Failure
        end 
    insert into [dbo].[Account] (
[AccountID]
, 
        [Customer]
, 
        [StartDate]
, 
        [EndDate]
, 
        [Interest]
, 
        [Period]
, 
        [Balance]
, 
        [Branch]
, 
        [rowguid]
) values (
@p1
, 
        @p2
, 
        @p3
, 
        @p4
, 
        @p5
, 
        @p6
, 
        @p7
, 
        @p8
, 
        @p9
)
        select @rowcount= @@rowcount, @error= @@error
        if (@rowcount <> 1)
        begin
            set @errcode= 3
            goto Failure
        end


    -- set row meta data
    if @resend > 0  
        update dbo.MSmerge_contents set generation = 0, partchangegen = 0 
            where rowguid = @rowguid and tablenick = @tablenick 

    if @started_transaction = 1
        commit tran
    

    delete from dbo.MSmerge_metadataaction_request
        where tablenick=@tablenick and rowguid=@rowguid

    -- DEBUG    insert into MSmerge_debug 
    -- DEBUG        (okay, artnick, rowguid, type, successcode, generation_new, lineage_old, lineage_new, twhen, comment) 
    -- DEBUG        values (0, @tablenick, @rowguid, @metadata_type, 1, @generation, @lineage_old, @lineage, getdate(), 'sp_ins, @resend=' + convert(nchar(1), @resend))

    return(1)

Failure:
    if @started_transaction = 1
        rollback tran
    -- DEBUG    insert into MSmerge_debug 
    -- DEBUG        (okay, artnick, rowguid, type, successcode, generation_new, lineage_old, lineage_new, twhen, comment) 
    -- DEBUG        values (1, @tablenick, @rowguid, @metadata_type, @errcode, @generation, @lineage_old, @lineage, getdate(), 'sp_ins, @resend=' + convert(nchar(1), @resend))

    


    declare @REPOLEExtErrorDupKey            int
    declare @REPOLEExtErrorDupUniqueIndex    int

    set @REPOLEExtErrorDupKey= 2627
    set @REPOLEExtErrorDupUniqueIndex= 2601
    
    if @error in (@REPOLEExtErrorDupUniqueIndex, @REPOLEExtErrorDupKey)
    begin
        update mc
            set mc.generation= 0
            from dbo.MSmerge_contents mc join [dbo].[Account] t on mc.rowguid=t.rowguidcol
            where
                mc.tablenick = 26466000 and
                (

                        (t.[AccountID]=@p1)

                        )
            end

    return(@errcode)
    

go
Create procedure dbo.[MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6] (@rowguid uniqueidentifier, @setbm varbinary(125) = NULL,
        @metadata_type tinyint, @lineage_old varbinary(311), @generation bigint,
        @lineage_new varbinary(311), @colv varbinary(1) 
,
        @p1 nvarchar(50) = NULL 
,
        @p2 nvarchar(50) = NULL 
,
        @p3 date = NULL 
,
        @p4 date = NULL 
,
        @p5 float = NULL 
,
        @p6 int = NULL 
,
        @p7 int = NULL 
,
        @p8 nvarchar(50) = NULL 
,
        @p9 uniqueidentifier = NULL 
, @compatlevel int = 10 
)
as
    declare @match int 

    declare @fset int
    declare @errcode int
    declare @retcode smallint
    declare @rowcount int
    declare @error int
    declare @hasperm bit
    declare @tablenick int
    declare @started_transaction bit
    declare @indexing_column_updated bit
    declare @publication_number smallint

    set nocount on

    if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end

    select @started_transaction = 0
    select @publication_number = 1
    select @tablenick = 26466000

    if is_member('db_owner') = 1
        select @hasperm = 1
    else
        select @hasperm = 0

    select @indexing_column_updated = 0

    declare @l1 nvarchar(50)

    declare @iscol1set bit

    declare @l2 nvarchar(50)

    if @@trancount = 0
    begin
        begin transaction sub
        select @started_transaction = 1
    end


    select 

        @l1 = [AccountID]
, 
        @l2 = [Customer]
        from [dbo].[Account] where rowguidcol = @rowguid
    set @match = NULL

       
    declare @firstUpdStmtCol bit
    declare @nUpdateCols int
    declare @updatestmt nvarchar(4000) 
    
    select @firstUpdStmtCol = 1
    select @nUpdateCols = 0
    select @updatestmt = 'update ' + '[dbo].[Account]' + ' set '
            

    if convert(varbinary(100), @p2)
            = convert(varbinary(100), @l2)
        set @fset = 0
    else if ( @l2 is null and @p2 is null) 
        set @fset = 0
    else if @p2 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 2
    if @fset <> 0
    begin

        if @match is NULL
        begin
            if @metadata_type = 3
            begin
                update [dbo].[Account] set [Customer] = @p2 
                from [dbo].[Account] t 
                where t.[rowguid] = @rowguid and
                   not exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                where c.rowguid = @rowguid and 
                                      c.tablenick = 26466000)
            end
            else if @metadata_type = 2
            begin
                update [dbo].[Account] set [Customer] = @p2 
                from [dbo].[Account] t 
                where t.[rowguid] = @rowguid and
                      exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                where c.rowguid = @rowguid and 
                                      c.tablenick = 26466000 and
                                      c.lineage = @lineage_old)
            end
            else
            begin
                set @errcode=2
                goto Failure
            end
        end
        else
        begin
            update [dbo].[Account] set [Customer] = @p2 
                where rowguidcol = @rowguid
        end
        select @rowcount= @@rowcount, @error= @@error
        if (@rowcount <> 1)
        begin
            set @errcode= 3
            goto Failure
        end
        select @match = 1
    end 

    if convert(varbinary(100), @p1)
            = convert(varbinary(100), @l1)
        set @fset = 0
    else if ( @l1 is null and @p1 is null) 
        set @fset = 0
    else if @p1 is not null
        set @fset = 1
    else if @setbm = 0x0
        set @fset = 0
    else
        exec @fset = sys.sp_MStestbit @setbm, 1
    if @fset <> 0
    begin

        select @indexing_column_updated = 1
        select @iscol1set = 1
        if @firstUpdStmtCol = 1
            select @firstUpdStmtCol = 0
        else
            select @updatestmt = @updatestmt + ','
        select @updatestmt = @updatestmt + '[AccountID] = @p1'
        select @nUpdateCols = @nUpdateCols + 1
    end
    else
    begin
        select @iscol1set = 0
    end

    if @indexing_column_updated = 1
    begin
        if @hasperm = 0
        begin
            update [dbo].[Account] set 

                [AccountID] = case @iscol1set when 1 then @p1 else t.[AccountID] end
 
             from [dbo].[Account] t 
                left outer join dbo.MSmerge_contents c with (rowlock)
                    on c.rowguid = t.[rowguid] and 
                       c.tablenick = 26466000 and
                       t.[rowguid] = @rowguid
             where t.[rowguid] = @rowguid and
             ((@match is not NULL and @match = 1) or 
              ((@metadata_type = 3 and c.rowguid is NULL) or
               (@metadata_type = 2 and c.rowguid is not NULL and c.lineage = @lineage_old)))

            select @rowcount= @@rowcount, @error= @@error

        end
        else -- we can do sp_executesql since the current user has permissions to update the table
        begin 
            if @match is NULL
            begin
                if @metadata_type = 3
                begin
                    select @updatestmt = @updatestmt + '
                       from [dbo].[Account] t 
                       where t.[rowguid] = @rowguid and
                             not exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                         where c.rowguid = @rowguid and 
                                               c.tablenick = 26466000)'
                end
                else if @metadata_type = 2
                begin
                    select @updatestmt = @updatestmt + '
                       from [dbo].[Account] t 
                       where t.[rowguid] = @rowguid and
                             exists (select 1 from dbo.MSmerge_contents c with (rowlock)
                                     where c.rowguid = @rowguid and 
                                           c.tablenick = 26466000 and
                                           c.lineage = @lineage_old)'
                end
            end
            else
            begin
                select @updatestmt = @updatestmt + '
                    where rowguidcol = @rowguid '
            end
            select @updatestmt = @updatestmt + '
                select @rowcount = @@rowcount, @error = @@error'
            exec sys.sp_executesql @stmt = @updatestmt, @parameters = N'

                    @p1 nvarchar(50)
, @rowguid uniqueidentifier = ''00000000-0000-0000-0000-000000000000'', @lineage_old varbinary(311), @rowcount int output, @error int output',

                    @p1 = @p1

                    , @rowguid = @rowguid, @lineage_old = @lineage_old, @rowcount = @rowcount OUTPUT, @error = @error OUTPUT 
        end  -- end if @hasperm
        if (@rowcount <> 1)
        begin
            set @errcode= 3
            goto Failure
        end    
        select @match = 1    
    end -- end if @indexing_column_updated 

    if @match is NULL
    begin
        update [dbo].[Account] set 

            [StartDate] = case when @p3 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 3) <> 0 then @p3 else t.[StartDate] end) else @p3 end 
,

            [EndDate] = case when @p4 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 4) <> 0 then @p4 else t.[EndDate] end) else @p4 end 
,

            [Interest] = case when @p5 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 5) <> 0 then @p5 else t.[Interest] end) else @p5 end 
,

            [Period] = case when @p6 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 6) <> 0 then @p6 else t.[Period] end) else @p6 end 
,

            [Balance] = case when @p7 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 7) <> 0 then @p7 else t.[Balance] end) else @p7 end 
,

            [Branch] = case when @p8 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 8) <> 0 then @p8 else t.[Branch] end) else @p8 end 
 
         from [dbo].[Account] t 
            left outer join dbo.MSmerge_contents c with (rowlock)
                on c.rowguid = t.[rowguid] and 
                   c.tablenick = 26466000 and
                   t.[rowguid] = @rowguid
         where t.[rowguid] = @rowguid and
         ((@match is not NULL and @match = 1) or 
          ((@metadata_type = 3 and c.rowguid is NULL) or
           (@metadata_type = 2 and c.rowguid is not NULL and c.lineage = @lineage_old)))

        select @rowcount= @@rowcount, @error= @@error
    end
    else
    begin
        update [dbo].[Account] set 

            [StartDate] = case when @p3 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 3) <> 0 then @p3 else t.[StartDate] end) else @p3 end 
,

            [EndDate] = case when @p4 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 4) <> 0 then @p4 else t.[EndDate] end) else @p4 end 
,

            [Interest] = case when @p5 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 5) <> 0 then @p5 else t.[Interest] end) else @p5 end 
,

            [Period] = case when @p6 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 6) <> 0 then @p6 else t.[Period] end) else @p6 end 
,

            [Balance] = case when @p7 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 7) <> 0 then @p7 else t.[Balance] end) else @p7 end 
,

            [Branch] = case when @p8 is NULL then (case when sys.fn_IsBitSetInBitmask(@setbm, 8) <> 0 then @p8 else t.[Branch] end) else @p8 end 
 
         from [dbo].[Account] t 
             where t.[rowguid] = @rowguid

        select @rowcount= @@rowcount, @error= @@error
    end

    if (@rowcount <> 1) or (@error <> 0)
    begin
        set @errcode= 3
        goto Failure
    end

    select @match = 1
 
    exec @retcode= sys.sp_MSsetrowmetadata 
        @tablenick, @rowguid, @generation, 
        @lineage_new, @colv, 2, NULL, 
        @compatlevel, 0, '9DEE015E-1388-43B6-BDF0-8C2967FBB918'
    if @retcode<>0 or @@ERROR<>0
    begin
        set @errcode= 3
        goto Failure
    end 

delete from dbo.MSmerge_metadataaction_request
    where tablenick=@tablenick and rowguid=@rowguid

    if @started_transaction = 1
        commit transaction

-- DEBUG    insert into MSmerge_debug 
-- DEBUG        (okay, artnick, rowguid, type, successcode, generation_new, lineage_old, lineage_new, twhen, comment)
-- DEBUG        values (0, @tablenick, @rowguid, @metadata_type, 1, @generation, @lineage_old, @lineage_new, getdate(), 'sp_upd')

    return(1)

Failure:
    --rollback transaction sub
    --commit transaction
    if @started_transaction = 1    
        rollback transaction
-- DEBUG    insert into MSmerge_debug 
-- DEBUG        (okay, artnick, rowguid, type, successcode, generation_new, lineage_old, lineage_new, twhen, comment)
-- DEBUG        values (1, @tablenick, @rowguid, @metadata_type, @errcode, @generation, @lineage_old, @lineage_new, getdate(), 'sp_upd')




    declare @REPOLEExtErrorDupKey            int
    declare @REPOLEExtErrorDupUniqueIndex    int

    set @REPOLEExtErrorDupKey= 2627
    set @REPOLEExtErrorDupUniqueIndex= 2601
    
    if @error in (@REPOLEExtErrorDupUniqueIndex, @REPOLEExtErrorDupKey)
    begin
        update mc
            set mc.generation= 0
            from dbo.MSmerge_contents mc join [dbo].[Account] t on mc.rowguid=t.rowguidcol
            where
                mc.tablenick = 26466000 and
                (

                        (t.[AccountID]=@p1)

                        )
            end

    return @errcode

go

create procedure dbo.[MSmerge_del_sp_5760AC0DEF4342F89DEE015E138843B6]
(
    @rowstobedeleted int, 
    @partition_id int = NULL 
,
    @rowguid1 uniqueidentifier = NULL,
    @metadata_type1 tinyint = NULL,
    @generation1 bigint = NULL,
    @lineage_old1 varbinary(311) = NULL,
    @lineage_new1 varbinary(311) = NULL,
    @rowguid2 uniqueidentifier = NULL,
    @metadata_type2 tinyint = NULL,
    @generation2 bigint = NULL,
    @lineage_old2 varbinary(311) = NULL,
    @lineage_new2 varbinary(311) = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @metadata_type3 tinyint = NULL,
    @generation3 bigint = NULL,
    @lineage_old3 varbinary(311) = NULL,
    @lineage_new3 varbinary(311) = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @metadata_type4 tinyint = NULL,
    @generation4 bigint = NULL,
    @lineage_old4 varbinary(311) = NULL,
    @lineage_new4 varbinary(311) = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @metadata_type5 tinyint = NULL,
    @generation5 bigint = NULL,
    @lineage_old5 varbinary(311) = NULL,
    @lineage_new5 varbinary(311) = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @metadata_type6 tinyint = NULL,
    @generation6 bigint = NULL,
    @lineage_old6 varbinary(311) = NULL,
    @lineage_new6 varbinary(311) = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @metadata_type7 tinyint = NULL,
    @generation7 bigint = NULL,
    @lineage_old7 varbinary(311) = NULL,
    @lineage_new7 varbinary(311) = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @metadata_type8 tinyint = NULL,
    @generation8 bigint = NULL,
    @lineage_old8 varbinary(311) = NULL,
    @lineage_new8 varbinary(311) = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @metadata_type9 tinyint = NULL,
    @generation9 bigint = NULL,
    @lineage_old9 varbinary(311) = NULL,
    @lineage_new9 varbinary(311) = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @metadata_type10 tinyint = NULL,
    @generation10 bigint = NULL,
    @lineage_old10 varbinary(311) = NULL,
    @lineage_new10 varbinary(311) = NULL
,
    @rowguid11 uniqueidentifier = NULL,
    @metadata_type11 tinyint = NULL,
    @generation11 bigint = NULL,
    @lineage_old11 varbinary(311) = NULL,
    @lineage_new11 varbinary(311) = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @metadata_type12 tinyint = NULL,
    @generation12 bigint = NULL,
    @lineage_old12 varbinary(311) = NULL,
    @lineage_new12 varbinary(311) = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @metadata_type13 tinyint = NULL,
    @generation13 bigint = NULL,
    @lineage_old13 varbinary(311) = NULL,
    @lineage_new13 varbinary(311) = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @metadata_type14 tinyint = NULL,
    @generation14 bigint = NULL,
    @lineage_old14 varbinary(311) = NULL,
    @lineage_new14 varbinary(311) = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @metadata_type15 tinyint = NULL,
    @generation15 bigint = NULL,
    @lineage_old15 varbinary(311) = NULL,
    @lineage_new15 varbinary(311) = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @metadata_type16 tinyint = NULL,
    @generation16 bigint = NULL,
    @lineage_old16 varbinary(311) = NULL,
    @lineage_new16 varbinary(311) = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @metadata_type17 tinyint = NULL,
    @generation17 bigint = NULL,
    @lineage_old17 varbinary(311) = NULL,
    @lineage_new17 varbinary(311) = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @metadata_type18 tinyint = NULL,
    @generation18 bigint = NULL,
    @lineage_old18 varbinary(311) = NULL,
    @lineage_new18 varbinary(311) = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @metadata_type19 tinyint = NULL,
    @generation19 bigint = NULL,
    @lineage_old19 varbinary(311) = NULL,
    @lineage_new19 varbinary(311) = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @metadata_type20 tinyint = NULL,
    @generation20 bigint = NULL,
    @lineage_old20 varbinary(311) = NULL,
    @lineage_new20 varbinary(311) = NULL
,
    @rowguid21 uniqueidentifier = NULL,
    @metadata_type21 tinyint = NULL,
    @generation21 bigint = NULL,
    @lineage_old21 varbinary(311) = NULL,
    @lineage_new21 varbinary(311) = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @metadata_type22 tinyint = NULL,
    @generation22 bigint = NULL,
    @lineage_old22 varbinary(311) = NULL,
    @lineage_new22 varbinary(311) = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @metadata_type23 tinyint = NULL,
    @generation23 bigint = NULL,
    @lineage_old23 varbinary(311) = NULL,
    @lineage_new23 varbinary(311) = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @metadata_type24 tinyint = NULL,
    @generation24 bigint = NULL,
    @lineage_old24 varbinary(311) = NULL,
    @lineage_new24 varbinary(311) = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @metadata_type25 tinyint = NULL,
    @generation25 bigint = NULL,
    @lineage_old25 varbinary(311) = NULL,
    @lineage_new25 varbinary(311) = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @metadata_type26 tinyint = NULL,
    @generation26 bigint = NULL,
    @lineage_old26 varbinary(311) = NULL,
    @lineage_new26 varbinary(311) = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @metadata_type27 tinyint = NULL,
    @generation27 bigint = NULL,
    @lineage_old27 varbinary(311) = NULL,
    @lineage_new27 varbinary(311) = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @metadata_type28 tinyint = NULL,
    @generation28 bigint = NULL,
    @lineage_old28 varbinary(311) = NULL,
    @lineage_new28 varbinary(311) = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @metadata_type29 tinyint = NULL,
    @generation29 bigint = NULL,
    @lineage_old29 varbinary(311) = NULL,
    @lineage_new29 varbinary(311) = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @metadata_type30 tinyint = NULL,
    @generation30 bigint = NULL,
    @lineage_old30 varbinary(311) = NULL,
    @lineage_new30 varbinary(311) = NULL
,
    @rowguid31 uniqueidentifier = NULL,
    @metadata_type31 tinyint = NULL,
    @generation31 bigint = NULL,
    @lineage_old31 varbinary(311) = NULL,
    @lineage_new31 varbinary(311) = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @metadata_type32 tinyint = NULL,
    @generation32 bigint = NULL,
    @lineage_old32 varbinary(311) = NULL,
    @lineage_new32 varbinary(311) = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @metadata_type33 tinyint = NULL,
    @generation33 bigint = NULL,
    @lineage_old33 varbinary(311) = NULL,
    @lineage_new33 varbinary(311) = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @metadata_type34 tinyint = NULL,
    @generation34 bigint = NULL,
    @lineage_old34 varbinary(311) = NULL,
    @lineage_new34 varbinary(311) = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @metadata_type35 tinyint = NULL,
    @generation35 bigint = NULL,
    @lineage_old35 varbinary(311) = NULL,
    @lineage_new35 varbinary(311) = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @metadata_type36 tinyint = NULL,
    @generation36 bigint = NULL,
    @lineage_old36 varbinary(311) = NULL,
    @lineage_new36 varbinary(311) = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @metadata_type37 tinyint = NULL,
    @generation37 bigint = NULL,
    @lineage_old37 varbinary(311) = NULL,
    @lineage_new37 varbinary(311) = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @metadata_type38 tinyint = NULL,
    @generation38 bigint = NULL,
    @lineage_old38 varbinary(311) = NULL,
    @lineage_new38 varbinary(311) = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @metadata_type39 tinyint = NULL,
    @generation39 bigint = NULL,
    @lineage_old39 varbinary(311) = NULL,
    @lineage_new39 varbinary(311) = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @metadata_type40 tinyint = NULL,
    @generation40 bigint = NULL,
    @lineage_old40 varbinary(311) = NULL,
    @lineage_new40 varbinary(311) = NULL
,
    @rowguid41 uniqueidentifier = NULL,
    @metadata_type41 tinyint = NULL,
    @generation41 bigint = NULL,
    @lineage_old41 varbinary(311) = NULL,
    @lineage_new41 varbinary(311) = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @metadata_type42 tinyint = NULL,
    @generation42 bigint = NULL,
    @lineage_old42 varbinary(311) = NULL,
    @lineage_new42 varbinary(311) = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @metadata_type43 tinyint = NULL,
    @generation43 bigint = NULL,
    @lineage_old43 varbinary(311) = NULL,
    @lineage_new43 varbinary(311) = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @metadata_type44 tinyint = NULL,
    @generation44 bigint = NULL,
    @lineage_old44 varbinary(311) = NULL,
    @lineage_new44 varbinary(311) = NULL,
    @rowguid45 uniqueidentifier = NULL,
    @metadata_type45 tinyint = NULL,
    @generation45 bigint = NULL,
    @lineage_old45 varbinary(311) = NULL,
    @lineage_new45 varbinary(311) = NULL,
    @rowguid46 uniqueidentifier = NULL,
    @metadata_type46 tinyint = NULL,
    @generation46 bigint = NULL,
    @lineage_old46 varbinary(311) = NULL,
    @lineage_new46 varbinary(311) = NULL,
    @rowguid47 uniqueidentifier = NULL,
    @metadata_type47 tinyint = NULL,
    @generation47 bigint = NULL,
    @lineage_old47 varbinary(311) = NULL,
    @lineage_new47 varbinary(311) = NULL,
    @rowguid48 uniqueidentifier = NULL,
    @metadata_type48 tinyint = NULL,
    @generation48 bigint = NULL,
    @lineage_old48 varbinary(311) = NULL,
    @lineage_new48 varbinary(311) = NULL,
    @rowguid49 uniqueidentifier = NULL,
    @metadata_type49 tinyint = NULL,
    @generation49 bigint = NULL,
    @lineage_old49 varbinary(311) = NULL,
    @lineage_new49 varbinary(311) = NULL,
    @rowguid50 uniqueidentifier = NULL,
    @metadata_type50 tinyint = NULL,
    @generation50 bigint = NULL,
    @lineage_old50 varbinary(311) = NULL,
    @lineage_new50 varbinary(311) = NULL
,
    @rowguid51 uniqueidentifier = NULL,
    @metadata_type51 tinyint = NULL,
    @generation51 bigint = NULL,
    @lineage_old51 varbinary(311) = NULL,
    @lineage_new51 varbinary(311) = NULL,
    @rowguid52 uniqueidentifier = NULL,
    @metadata_type52 tinyint = NULL,
    @generation52 bigint = NULL,
    @lineage_old52 varbinary(311) = NULL,
    @lineage_new52 varbinary(311) = NULL,
    @rowguid53 uniqueidentifier = NULL,
    @metadata_type53 tinyint = NULL,
    @generation53 bigint = NULL,
    @lineage_old53 varbinary(311) = NULL,
    @lineage_new53 varbinary(311) = NULL,
    @rowguid54 uniqueidentifier = NULL,
    @metadata_type54 tinyint = NULL,
    @generation54 bigint = NULL,
    @lineage_old54 varbinary(311) = NULL,
    @lineage_new54 varbinary(311) = NULL,
    @rowguid55 uniqueidentifier = NULL,
    @metadata_type55 tinyint = NULL,
    @generation55 bigint = NULL,
    @lineage_old55 varbinary(311) = NULL,
    @lineage_new55 varbinary(311) = NULL,
    @rowguid56 uniqueidentifier = NULL,
    @metadata_type56 tinyint = NULL,
    @generation56 bigint = NULL,
    @lineage_old56 varbinary(311) = NULL,
    @lineage_new56 varbinary(311) = NULL,
    @rowguid57 uniqueidentifier = NULL,
    @metadata_type57 tinyint = NULL,
    @generation57 bigint = NULL,
    @lineage_old57 varbinary(311) = NULL,
    @lineage_new57 varbinary(311) = NULL,
    @rowguid58 uniqueidentifier = NULL,
    @metadata_type58 tinyint = NULL,
    @generation58 bigint = NULL,
    @lineage_old58 varbinary(311) = NULL,
    @lineage_new58 varbinary(311) = NULL,
    @rowguid59 uniqueidentifier = NULL,
    @metadata_type59 tinyint = NULL,
    @generation59 bigint = NULL,
    @lineage_old59 varbinary(311) = NULL,
    @lineage_new59 varbinary(311) = NULL,
    @rowguid60 uniqueidentifier = NULL,
    @metadata_type60 tinyint = NULL,
    @generation60 bigint = NULL,
    @lineage_old60 varbinary(311) = NULL,
    @lineage_new60 varbinary(311) = NULL
,
    @rowguid61 uniqueidentifier = NULL,
    @metadata_type61 tinyint = NULL,
    @generation61 bigint = NULL,
    @lineage_old61 varbinary(311) = NULL,
    @lineage_new61 varbinary(311) = NULL,
    @rowguid62 uniqueidentifier = NULL,
    @metadata_type62 tinyint = NULL,
    @generation62 bigint = NULL,
    @lineage_old62 varbinary(311) = NULL,
    @lineage_new62 varbinary(311) = NULL,
    @rowguid63 uniqueidentifier = NULL,
    @metadata_type63 tinyint = NULL,
    @generation63 bigint = NULL,
    @lineage_old63 varbinary(311) = NULL,
    @lineage_new63 varbinary(311) = NULL,
    @rowguid64 uniqueidentifier = NULL,
    @metadata_type64 tinyint = NULL,
    @generation64 bigint = NULL,
    @lineage_old64 varbinary(311) = NULL,
    @lineage_new64 varbinary(311) = NULL,
    @rowguid65 uniqueidentifier = NULL,
    @metadata_type65 tinyint = NULL,
    @generation65 bigint = NULL,
    @lineage_old65 varbinary(311) = NULL,
    @lineage_new65 varbinary(311) = NULL,
    @rowguid66 uniqueidentifier = NULL,
    @metadata_type66 tinyint = NULL,
    @generation66 bigint = NULL,
    @lineage_old66 varbinary(311) = NULL,
    @lineage_new66 varbinary(311) = NULL,
    @rowguid67 uniqueidentifier = NULL,
    @metadata_type67 tinyint = NULL,
    @generation67 bigint = NULL,
    @lineage_old67 varbinary(311) = NULL,
    @lineage_new67 varbinary(311) = NULL,
    @rowguid68 uniqueidentifier = NULL,
    @metadata_type68 tinyint = NULL,
    @generation68 bigint = NULL,
    @lineage_old68 varbinary(311) = NULL,
    @lineage_new68 varbinary(311) = NULL,
    @rowguid69 uniqueidentifier = NULL,
    @metadata_type69 tinyint = NULL,
    @generation69 bigint = NULL,
    @lineage_old69 varbinary(311) = NULL,
    @lineage_new69 varbinary(311) = NULL,
    @rowguid70 uniqueidentifier = NULL,
    @metadata_type70 tinyint = NULL,
    @generation70 bigint = NULL,
    @lineage_old70 varbinary(311) = NULL,
    @lineage_new70 varbinary(311) = NULL
,
    @rowguid71 uniqueidentifier = NULL,
    @metadata_type71 tinyint = NULL,
    @generation71 bigint = NULL,
    @lineage_old71 varbinary(311) = NULL,
    @lineage_new71 varbinary(311) = NULL,
    @rowguid72 uniqueidentifier = NULL,
    @metadata_type72 tinyint = NULL,
    @generation72 bigint = NULL,
    @lineage_old72 varbinary(311) = NULL,
    @lineage_new72 varbinary(311) = NULL,
    @rowguid73 uniqueidentifier = NULL,
    @metadata_type73 tinyint = NULL,
    @generation73 bigint = NULL,
    @lineage_old73 varbinary(311) = NULL,
    @lineage_new73 varbinary(311) = NULL,
    @rowguid74 uniqueidentifier = NULL,
    @metadata_type74 tinyint = NULL,
    @generation74 bigint = NULL,
    @lineage_old74 varbinary(311) = NULL,
    @lineage_new74 varbinary(311) = NULL,
    @rowguid75 uniqueidentifier = NULL,
    @metadata_type75 tinyint = NULL,
    @generation75 bigint = NULL,
    @lineage_old75 varbinary(311) = NULL,
    @lineage_new75 varbinary(311) = NULL,
    @rowguid76 uniqueidentifier = NULL,
    @metadata_type76 tinyint = NULL,
    @generation76 bigint = NULL,
    @lineage_old76 varbinary(311) = NULL,
    @lineage_new76 varbinary(311) = NULL,
    @rowguid77 uniqueidentifier = NULL,
    @metadata_type77 tinyint = NULL,
    @generation77 bigint = NULL,
    @lineage_old77 varbinary(311) = NULL,
    @lineage_new77 varbinary(311) = NULL,
    @rowguid78 uniqueidentifier = NULL,
    @metadata_type78 tinyint = NULL,
    @generation78 bigint = NULL,
    @lineage_old78 varbinary(311) = NULL,
    @lineage_new78 varbinary(311) = NULL,
    @rowguid79 uniqueidentifier = NULL,
    @metadata_type79 tinyint = NULL,
    @generation79 bigint = NULL,
    @lineage_old79 varbinary(311) = NULL,
    @lineage_new79 varbinary(311) = NULL,
    @rowguid80 uniqueidentifier = NULL,
    @metadata_type80 tinyint = NULL,
    @generation80 bigint = NULL,
    @lineage_old80 varbinary(311) = NULL,
    @lineage_new80 varbinary(311) = NULL
,
    @rowguid81 uniqueidentifier = NULL,
    @metadata_type81 tinyint = NULL,
    @generation81 bigint = NULL,
    @lineage_old81 varbinary(311) = NULL,
    @lineage_new81 varbinary(311) = NULL,
    @rowguid82 uniqueidentifier = NULL,
    @metadata_type82 tinyint = NULL,
    @generation82 bigint = NULL,
    @lineage_old82 varbinary(311) = NULL,
    @lineage_new82 varbinary(311) = NULL,
    @rowguid83 uniqueidentifier = NULL,
    @metadata_type83 tinyint = NULL,
    @generation83 bigint = NULL,
    @lineage_old83 varbinary(311) = NULL,
    @lineage_new83 varbinary(311) = NULL,
    @rowguid84 uniqueidentifier = NULL,
    @metadata_type84 tinyint = NULL,
    @generation84 bigint = NULL,
    @lineage_old84 varbinary(311) = NULL,
    @lineage_new84 varbinary(311) = NULL,
    @rowguid85 uniqueidentifier = NULL,
    @metadata_type85 tinyint = NULL,
    @generation85 bigint = NULL,
    @lineage_old85 varbinary(311) = NULL,
    @lineage_new85 varbinary(311) = NULL,
    @rowguid86 uniqueidentifier = NULL,
    @metadata_type86 tinyint = NULL,
    @generation86 bigint = NULL,
    @lineage_old86 varbinary(311) = NULL,
    @lineage_new86 varbinary(311) = NULL,
    @rowguid87 uniqueidentifier = NULL,
    @metadata_type87 tinyint = NULL,
    @generation87 bigint = NULL,
    @lineage_old87 varbinary(311) = NULL,
    @lineage_new87 varbinary(311) = NULL,
    @rowguid88 uniqueidentifier = NULL,
    @metadata_type88 tinyint = NULL,
    @generation88 bigint = NULL,
    @lineage_old88 varbinary(311) = NULL,
    @lineage_new88 varbinary(311) = NULL,
    @rowguid89 uniqueidentifier = NULL,
    @metadata_type89 tinyint = NULL,
    @generation89 bigint = NULL,
    @lineage_old89 varbinary(311) = NULL,
    @lineage_new89 varbinary(311) = NULL,
    @rowguid90 uniqueidentifier = NULL,
    @metadata_type90 tinyint = NULL,
    @generation90 bigint = NULL,
    @lineage_old90 varbinary(311) = NULL,
    @lineage_new90 varbinary(311) = NULL
,
    @rowguid91 uniqueidentifier = NULL,
    @metadata_type91 tinyint = NULL,
    @generation91 bigint = NULL,
    @lineage_old91 varbinary(311) = NULL,
    @lineage_new91 varbinary(311) = NULL,
    @rowguid92 uniqueidentifier = NULL,
    @metadata_type92 tinyint = NULL,
    @generation92 bigint = NULL,
    @lineage_old92 varbinary(311) = NULL,
    @lineage_new92 varbinary(311) = NULL,
    @rowguid93 uniqueidentifier = NULL,
    @metadata_type93 tinyint = NULL,
    @generation93 bigint = NULL,
    @lineage_old93 varbinary(311) = NULL,
    @lineage_new93 varbinary(311) = NULL,
    @rowguid94 uniqueidentifier = NULL,
    @metadata_type94 tinyint = NULL,
    @generation94 bigint = NULL,
    @lineage_old94 varbinary(311) = NULL,
    @lineage_new94 varbinary(311) = NULL,
    @rowguid95 uniqueidentifier = NULL,
    @metadata_type95 tinyint = NULL,
    @generation95 bigint = NULL,
    @lineage_old95 varbinary(311) = NULL,
    @lineage_new95 varbinary(311) = NULL,
    @rowguid96 uniqueidentifier = NULL,
    @metadata_type96 tinyint = NULL,
    @generation96 bigint = NULL,
    @lineage_old96 varbinary(311) = NULL,
    @lineage_new96 varbinary(311) = NULL,
    @rowguid97 uniqueidentifier = NULL,
    @metadata_type97 tinyint = NULL,
    @generation97 bigint = NULL,
    @lineage_old97 varbinary(311) = NULL,
    @lineage_new97 varbinary(311) = NULL,
    @rowguid98 uniqueidentifier = NULL,
    @metadata_type98 tinyint = NULL,
    @generation98 bigint = NULL,
    @lineage_old98 varbinary(311) = NULL,
    @lineage_new98 varbinary(311) = NULL,
    @rowguid99 uniqueidentifier = NULL,
    @metadata_type99 tinyint = NULL,
    @generation99 bigint = NULL,
    @lineage_old99 varbinary(311) = NULL,
    @lineage_new99 varbinary(311) = NULL,
    @rowguid100 uniqueidentifier = NULL,
    @metadata_type100 tinyint = NULL,
    @generation100 bigint = NULL,
    @lineage_old100 varbinary(311) = NULL,
    @lineage_new100 varbinary(311) = NULL

)
as
begin


    -- this proc returns 0 to indicate error and 1 to indicate success
    declare @retcode    int
    set nocount on
    declare @rows_deleted int
    declare @rows_remaining int
    declare @error int
    declare @tomb_rows_updated int
    declare @publication_number smallint
    declare @rows_in_syncview int
        
    if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
    begin       
        RAISERROR (14126, 11, -1)
        return 0
    end
    
    select @publication_number = 1

    if @rowstobedeleted is NULL or @rowstobedeleted <= 0
        return 0

    begin tran
    save tran batchdeleteproc


    delete [dbo].[Account] with (rowlock)
    from 
    (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 
) as rows
    inner join [dbo].[Account] t with (rowlock) on rows.rowguid = t.[rowguid] and rows.rowguid is not NULL

    left outer join dbo.MSmerge_contents cont with (rowlock) 
    on rows.rowguid = cont.rowguid and cont.tablenick = 26466000 
    and rows.rowguid is not NULL
    where ((rows.metadata_type = 3 and cont.rowguid is NULL) or
           ((rows.metadata_type = 5 or  rows.metadata_type = 6) and (cont.rowguid is NULL or cont.lineage = rows.lineage_old)) or
           (cont.rowguid is not NULL and cont.lineage = rows.lineage_old))
           and rows.rowguid is not NULL 

    select @rows_deleted = @@rowcount, @error = @@error
    if @error<>0
        goto Failure
    if @rows_deleted > @rowstobedeleted
    begin
        -- this is just not possible
        raiserror(20684, 16, -1, '[dbo].[Account]')
        goto Failure
    end
    if @rows_deleted <> @rowstobedeleted
    begin

        -- we will now check if any of the rows we wanted to delete were not deleted. If the rows were not deleted
        -- by the previous delete because it was already deleted, we will still assume that this is a success
        select @rows_remaining = count(*) from 
        ( 

         select @rowguid1 as rowguid union all 
         select @rowguid2 as rowguid union all 
         select @rowguid3 as rowguid union all 
         select @rowguid4 as rowguid union all 
         select @rowguid5 as rowguid union all 
         select @rowguid6 as rowguid union all 
         select @rowguid7 as rowguid union all 
         select @rowguid8 as rowguid union all 
         select @rowguid9 as rowguid union all 
         select @rowguid10 as rowguid union all 
         select @rowguid11 as rowguid union all 
         select @rowguid12 as rowguid union all 
         select @rowguid13 as rowguid union all 
         select @rowguid14 as rowguid union all 
         select @rowguid15 as rowguid union all 
         select @rowguid16 as rowguid union all 
         select @rowguid17 as rowguid union all 
         select @rowguid18 as rowguid union all 
         select @rowguid19 as rowguid union all 
         select @rowguid20 as rowguid union all 
         select @rowguid21 as rowguid union all 
         select @rowguid22 as rowguid union all 
         select @rowguid23 as rowguid union all 
         select @rowguid24 as rowguid union all 
         select @rowguid25 as rowguid union all 
         select @rowguid26 as rowguid union all 
         select @rowguid27 as rowguid union all 
         select @rowguid28 as rowguid union all 
         select @rowguid29 as rowguid union all 
         select @rowguid30 as rowguid union all 
         select @rowguid31 as rowguid union all 
         select @rowguid32 as rowguid union all 
         select @rowguid33 as rowguid union all 
         select @rowguid34 as rowguid union all 
         select @rowguid35 as rowguid union all 
         select @rowguid36 as rowguid union all 
         select @rowguid37 as rowguid union all 
         select @rowguid38 as rowguid union all 
         select @rowguid39 as rowguid union all 
         select @rowguid40 as rowguid union all 
         select @rowguid41 as rowguid union all 
         select @rowguid42 as rowguid union all 
         select @rowguid43 as rowguid union all 
         select @rowguid44 as rowguid union all 
         select @rowguid45 as rowguid union all 
         select @rowguid46 as rowguid union all 
         select @rowguid47 as rowguid union all 
         select @rowguid48 as rowguid union all 
         select @rowguid49 as rowguid union all 
         select @rowguid50 as rowguid union all

         select @rowguid51 as rowguid union all 
         select @rowguid52 as rowguid union all 
         select @rowguid53 as rowguid union all 
         select @rowguid54 as rowguid union all 
         select @rowguid55 as rowguid union all 
         select @rowguid56 as rowguid union all 
         select @rowguid57 as rowguid union all 
         select @rowguid58 as rowguid union all 
         select @rowguid59 as rowguid union all 
         select @rowguid60 as rowguid union all 
         select @rowguid61 as rowguid union all 
         select @rowguid62 as rowguid union all 
         select @rowguid63 as rowguid union all 
         select @rowguid64 as rowguid union all 
         select @rowguid65 as rowguid union all 
         select @rowguid66 as rowguid union all 
         select @rowguid67 as rowguid union all 
         select @rowguid68 as rowguid union all 
         select @rowguid69 as rowguid union all 
         select @rowguid70 as rowguid union all 
         select @rowguid71 as rowguid union all 
         select @rowguid72 as rowguid union all 
         select @rowguid73 as rowguid union all 
         select @rowguid74 as rowguid union all 
         select @rowguid75 as rowguid union all 
         select @rowguid76 as rowguid union all 
         select @rowguid77 as rowguid union all 
         select @rowguid78 as rowguid union all 
         select @rowguid79 as rowguid union all 
         select @rowguid80 as rowguid union all 
         select @rowguid81 as rowguid union all 
         select @rowguid82 as rowguid union all 
         select @rowguid83 as rowguid union all 
         select @rowguid84 as rowguid union all 
         select @rowguid85 as rowguid union all 
         select @rowguid86 as rowguid union all 
         select @rowguid87 as rowguid union all 
         select @rowguid88 as rowguid union all 
         select @rowguid89 as rowguid union all 
         select @rowguid90 as rowguid union all 
         select @rowguid91 as rowguid union all 
         select @rowguid92 as rowguid union all 
         select @rowguid93 as rowguid union all 
         select @rowguid94 as rowguid union all 
         select @rowguid95 as rowguid union all 
         select @rowguid96 as rowguid union all 
         select @rowguid97 as rowguid union all 
         select @rowguid98 as rowguid union all 
         select @rowguid99 as rowguid union all 
         select @rowguid100 as rowguid

        ) as rows
        inner join [dbo].[Account] t with (rowlock) 
        on t.[rowguid] = rows.rowguid
        and rows.rowguid is not NULL
        
        if @@error <> 0
            goto Failure
        
        if @rows_remaining <> 0
        begin
            -- failed deleting one or more rows. Could be because of metadata mismatch
            --raiserror(20682, 10, -1, @rows_remaining, '[dbo].[Account]')
            goto Failure
        end        
    end

    -- if we get here it means that all the rows that we intend to delete were either deleted by us
    -- or they were already deleted by someone else and do not exist in the user table
    -- we insert a tombstone entry for the rows we have deleted and delete the contents rows if exists

    -- if the rows were previously deleted we still want to update the metadatatype, generation and lineage
    -- in MSmerge_tombstone. We could find rows in the following update also if the trigger got called by
    -- the user table delete and it inserted the rows into tombstone (it would have inserted with type 1)
    update dbo.MSmerge_tombstone with (rowlock)
        set type = case when (rows.metadata_type=5 or rows.metadata_type=6) then rows.metadata_type else 1 end,
            generation = rows.generation,
            lineage = rows.lineage_new
    from 
    (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 

    ) as rows
    inner join dbo.MSmerge_tombstone tomb with (rowlock) 
    on tomb.rowguid = rows.rowguid and tomb.tablenick = 26466000
    and rows.rowguid is not null
    and rows.lineage_new is not NULL
    option (force order, loop join)
    select @tomb_rows_updated = @@rowcount, @error = @@error
    if @error<>0
        goto Failure

        -- the trigger would have inserted a row in past partition mapping for the currently deleted
        -- row. We need to update that row with the current generation if it exists
        update dbo.MSmerge_past_partition_mappings with (rowlock)
        set generation = rows.generation
    from
    (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 

        ) as rows
        inner join dbo.MSmerge_past_partition_mappings ppm with (rowlock) 
        on ppm.rowguid = rows.rowguid and ppm.tablenick = 26466000 
        and ppm.generation = 0
        and rows.rowguid is not NULL
        and rows.lineage_new is not null
        option (force order, loop join)
        if @error<>0
                goto Failure

    if @tomb_rows_updated <> @rowstobedeleted
    begin
        -- now insert rows that are not in tombstone
        insert into dbo.MSmerge_tombstone with (rowlock)
            (rowguid, tablenick, type, generation, lineage)
        select rows.rowguid, 26466000, 
               case when (rows.metadata_type=5 or rows.metadata_type=6) then rows.metadata_type else 1 end, 
               rows.generation, rows.lineage_new
        from 
        (

    select @rowguid1 as rowguid, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @lineage_new1 as lineage_new, @generation1 as generation  union all 
    select @rowguid2 as rowguid, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @lineage_new2 as lineage_new, @generation2 as generation  union all 
    select @rowguid3 as rowguid, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @lineage_new3 as lineage_new, @generation3 as generation  union all 
    select @rowguid4 as rowguid, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @lineage_new4 as lineage_new, @generation4 as generation  union all 
    select @rowguid5 as rowguid, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @lineage_new5 as lineage_new, @generation5 as generation  union all 
    select @rowguid6 as rowguid, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @lineage_new6 as lineage_new, @generation6 as generation  union all 
    select @rowguid7 as rowguid, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @lineage_new7 as lineage_new, @generation7 as generation  union all 
    select @rowguid8 as rowguid, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @lineage_new8 as lineage_new, @generation8 as generation  union all 
    select @rowguid9 as rowguid, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @lineage_new9 as lineage_new, @generation9 as generation  union all 
    select @rowguid10 as rowguid, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @lineage_new10 as lineage_new, @generation10 as generation 
 union all 
    select @rowguid11 as rowguid, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @lineage_new11 as lineage_new, @generation11 as generation  union all 
    select @rowguid12 as rowguid, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @lineage_new12 as lineage_new, @generation12 as generation  union all 
    select @rowguid13 as rowguid, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @lineage_new13 as lineage_new, @generation13 as generation  union all 
    select @rowguid14 as rowguid, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @lineage_new14 as lineage_new, @generation14 as generation  union all 
    select @rowguid15 as rowguid, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @lineage_new15 as lineage_new, @generation15 as generation  union all 
    select @rowguid16 as rowguid, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @lineage_new16 as lineage_new, @generation16 as generation  union all 
    select @rowguid17 as rowguid, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @lineage_new17 as lineage_new, @generation17 as generation  union all 
    select @rowguid18 as rowguid, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @lineage_new18 as lineage_new, @generation18 as generation  union all 
    select @rowguid19 as rowguid, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @lineage_new19 as lineage_new, @generation19 as generation  union all 
    select @rowguid20 as rowguid, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @lineage_new20 as lineage_new, @generation20 as generation 
 union all 
    select @rowguid21 as rowguid, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @lineage_new21 as lineage_new, @generation21 as generation  union all 
    select @rowguid22 as rowguid, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @lineage_new22 as lineage_new, @generation22 as generation  union all 
    select @rowguid23 as rowguid, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @lineage_new23 as lineage_new, @generation23 as generation  union all 
    select @rowguid24 as rowguid, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @lineage_new24 as lineage_new, @generation24 as generation  union all 
    select @rowguid25 as rowguid, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @lineage_new25 as lineage_new, @generation25 as generation  union all 
    select @rowguid26 as rowguid, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @lineage_new26 as lineage_new, @generation26 as generation  union all 
    select @rowguid27 as rowguid, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @lineage_new27 as lineage_new, @generation27 as generation  union all 
    select @rowguid28 as rowguid, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @lineage_new28 as lineage_new, @generation28 as generation  union all 
    select @rowguid29 as rowguid, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @lineage_new29 as lineage_new, @generation29 as generation  union all 
    select @rowguid30 as rowguid, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @lineage_new30 as lineage_new, @generation30 as generation 
 union all 
    select @rowguid31 as rowguid, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @lineage_new31 as lineage_new, @generation31 as generation  union all 
    select @rowguid32 as rowguid, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @lineage_new32 as lineage_new, @generation32 as generation  union all 
    select @rowguid33 as rowguid, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @lineage_new33 as lineage_new, @generation33 as generation  union all 
    select @rowguid34 as rowguid, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @lineage_new34 as lineage_new, @generation34 as generation  union all 
    select @rowguid35 as rowguid, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @lineage_new35 as lineage_new, @generation35 as generation  union all 
    select @rowguid36 as rowguid, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @lineage_new36 as lineage_new, @generation36 as generation  union all 
    select @rowguid37 as rowguid, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @lineage_new37 as lineage_new, @generation37 as generation  union all 
    select @rowguid38 as rowguid, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @lineage_new38 as lineage_new, @generation38 as generation  union all 
    select @rowguid39 as rowguid, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @lineage_new39 as lineage_new, @generation39 as generation  union all 
    select @rowguid40 as rowguid, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @lineage_new40 as lineage_new, @generation40 as generation 
 union all 
    select @rowguid41 as rowguid, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @lineage_new41 as lineage_new, @generation41 as generation  union all 
    select @rowguid42 as rowguid, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @lineage_new42 as lineage_new, @generation42 as generation  union all 
    select @rowguid43 as rowguid, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @lineage_new43 as lineage_new, @generation43 as generation  union all 
    select @rowguid44 as rowguid, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @lineage_new44 as lineage_new, @generation44 as generation  union all 
    select @rowguid45 as rowguid, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @lineage_new45 as lineage_new, @generation45 as generation  union all 
    select @rowguid46 as rowguid, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @lineage_new46 as lineage_new, @generation46 as generation  union all 
    select @rowguid47 as rowguid, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @lineage_new47 as lineage_new, @generation47 as generation  union all 
    select @rowguid48 as rowguid, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @lineage_new48 as lineage_new, @generation48 as generation  union all 
    select @rowguid49 as rowguid, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @lineage_new49 as lineage_new, @generation49 as generation  union all 
    select @rowguid50 as rowguid, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @lineage_new50 as lineage_new, @generation50 as generation 
 union all 
    select @rowguid51 as rowguid, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @lineage_new51 as lineage_new, @generation51 as generation  union all 
    select @rowguid52 as rowguid, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @lineage_new52 as lineage_new, @generation52 as generation  union all 
    select @rowguid53 as rowguid, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @lineage_new53 as lineage_new, @generation53 as generation  union all 
    select @rowguid54 as rowguid, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @lineage_new54 as lineage_new, @generation54 as generation  union all 
    select @rowguid55 as rowguid, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @lineage_new55 as lineage_new, @generation55 as generation  union all 
    select @rowguid56 as rowguid, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @lineage_new56 as lineage_new, @generation56 as generation  union all 
    select @rowguid57 as rowguid, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @lineage_new57 as lineage_new, @generation57 as generation  union all 
    select @rowguid58 as rowguid, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @lineage_new58 as lineage_new, @generation58 as generation  union all 
    select @rowguid59 as rowguid, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @lineage_new59 as lineage_new, @generation59 as generation  union all 
    select @rowguid60 as rowguid, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @lineage_new60 as lineage_new, @generation60 as generation 
 union all 
    select @rowguid61 as rowguid, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @lineage_new61 as lineage_new, @generation61 as generation  union all 
    select @rowguid62 as rowguid, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @lineage_new62 as lineage_new, @generation62 as generation  union all 
    select @rowguid63 as rowguid, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @lineage_new63 as lineage_new, @generation63 as generation  union all 
    select @rowguid64 as rowguid, @metadata_type64 as metadata_type, @lineage_old64 as lineage_old, @lineage_new64 as lineage_new, @generation64 as generation  union all 
    select @rowguid65 as rowguid, @metadata_type65 as metadata_type, @lineage_old65 as lineage_old, @lineage_new65 as lineage_new, @generation65 as generation  union all 
    select @rowguid66 as rowguid, @metadata_type66 as metadata_type, @lineage_old66 as lineage_old, @lineage_new66 as lineage_new, @generation66 as generation  union all 
    select @rowguid67 as rowguid, @metadata_type67 as metadata_type, @lineage_old67 as lineage_old, @lineage_new67 as lineage_new, @generation67 as generation  union all 
    select @rowguid68 as rowguid, @metadata_type68 as metadata_type, @lineage_old68 as lineage_old, @lineage_new68 as lineage_new, @generation68 as generation  union all 
    select @rowguid69 as rowguid, @metadata_type69 as metadata_type, @lineage_old69 as lineage_old, @lineage_new69 as lineage_new, @generation69 as generation  union all 
    select @rowguid70 as rowguid, @metadata_type70 as metadata_type, @lineage_old70 as lineage_old, @lineage_new70 as lineage_new, @generation70 as generation 
 union all 
    select @rowguid71 as rowguid, @metadata_type71 as metadata_type, @lineage_old71 as lineage_old, @lineage_new71 as lineage_new, @generation71 as generation  union all 
    select @rowguid72 as rowguid, @metadata_type72 as metadata_type, @lineage_old72 as lineage_old, @lineage_new72 as lineage_new, @generation72 as generation  union all 
    select @rowguid73 as rowguid, @metadata_type73 as metadata_type, @lineage_old73 as lineage_old, @lineage_new73 as lineage_new, @generation73 as generation  union all 
    select @rowguid74 as rowguid, @metadata_type74 as metadata_type, @lineage_old74 as lineage_old, @lineage_new74 as lineage_new, @generation74 as generation  union all 
    select @rowguid75 as rowguid, @metadata_type75 as metadata_type, @lineage_old75 as lineage_old, @lineage_new75 as lineage_new, @generation75 as generation  union all 
    select @rowguid76 as rowguid, @metadata_type76 as metadata_type, @lineage_old76 as lineage_old, @lineage_new76 as lineage_new, @generation76 as generation  union all 
    select @rowguid77 as rowguid, @metadata_type77 as metadata_type, @lineage_old77 as lineage_old, @lineage_new77 as lineage_new, @generation77 as generation  union all 
    select @rowguid78 as rowguid, @metadata_type78 as metadata_type, @lineage_old78 as lineage_old, @lineage_new78 as lineage_new, @generation78 as generation  union all 
    select @rowguid79 as rowguid, @metadata_type79 as metadata_type, @lineage_old79 as lineage_old, @lineage_new79 as lineage_new, @generation79 as generation  union all 
    select @rowguid80 as rowguid, @metadata_type80 as metadata_type, @lineage_old80 as lineage_old, @lineage_new80 as lineage_new, @generation80 as generation 
 union all 
    select @rowguid81 as rowguid, @metadata_type81 as metadata_type, @lineage_old81 as lineage_old, @lineage_new81 as lineage_new, @generation81 as generation  union all 
    select @rowguid82 as rowguid, @metadata_type82 as metadata_type, @lineage_old82 as lineage_old, @lineage_new82 as lineage_new, @generation82 as generation  union all 
    select @rowguid83 as rowguid, @metadata_type83 as metadata_type, @lineage_old83 as lineage_old, @lineage_new83 as lineage_new, @generation83 as generation  union all 
    select @rowguid84 as rowguid, @metadata_type84 as metadata_type, @lineage_old84 as lineage_old, @lineage_new84 as lineage_new, @generation84 as generation  union all 
    select @rowguid85 as rowguid, @metadata_type85 as metadata_type, @lineage_old85 as lineage_old, @lineage_new85 as lineage_new, @generation85 as generation  union all 
    select @rowguid86 as rowguid, @metadata_type86 as metadata_type, @lineage_old86 as lineage_old, @lineage_new86 as lineage_new, @generation86 as generation  union all 
    select @rowguid87 as rowguid, @metadata_type87 as metadata_type, @lineage_old87 as lineage_old, @lineage_new87 as lineage_new, @generation87 as generation  union all 
    select @rowguid88 as rowguid, @metadata_type88 as metadata_type, @lineage_old88 as lineage_old, @lineage_new88 as lineage_new, @generation88 as generation  union all 
    select @rowguid89 as rowguid, @metadata_type89 as metadata_type, @lineage_old89 as lineage_old, @lineage_new89 as lineage_new, @generation89 as generation  union all 
    select @rowguid90 as rowguid, @metadata_type90 as metadata_type, @lineage_old90 as lineage_old, @lineage_new90 as lineage_new, @generation90 as generation 
 union all 
    select @rowguid91 as rowguid, @metadata_type91 as metadata_type, @lineage_old91 as lineage_old, @lineage_new91 as lineage_new, @generation91 as generation  union all 
    select @rowguid92 as rowguid, @metadata_type92 as metadata_type, @lineage_old92 as lineage_old, @lineage_new92 as lineage_new, @generation92 as generation  union all 
    select @rowguid93 as rowguid, @metadata_type93 as metadata_type, @lineage_old93 as lineage_old, @lineage_new93 as lineage_new, @generation93 as generation  union all 
    select @rowguid94 as rowguid, @metadata_type94 as metadata_type, @lineage_old94 as lineage_old, @lineage_new94 as lineage_new, @generation94 as generation  union all 
    select @rowguid95 as rowguid, @metadata_type95 as metadata_type, @lineage_old95 as lineage_old, @lineage_new95 as lineage_new, @generation95 as generation  union all 
    select @rowguid96 as rowguid, @metadata_type96 as metadata_type, @lineage_old96 as lineage_old, @lineage_new96 as lineage_new, @generation96 as generation  union all 
    select @rowguid97 as rowguid, @metadata_type97 as metadata_type, @lineage_old97 as lineage_old, @lineage_new97 as lineage_new, @generation97 as generation  union all 
    select @rowguid98 as rowguid, @metadata_type98 as metadata_type, @lineage_old98 as lineage_old, @lineage_new98 as lineage_new, @generation98 as generation  union all 
    select @rowguid99 as rowguid, @metadata_type99 as metadata_type, @lineage_old99 as lineage_old, @lineage_new99 as lineage_new, @generation99 as generation  union all 
    select @rowguid100 as rowguid, @metadata_type100 as metadata_type, @lineage_old100 as lineage_old, @lineage_new100 as lineage_new, @generation100 as generation 

        ) as rows
        left outer join dbo.MSmerge_tombstone tomb with (rowlock) 
        on tomb.rowguid = rows.rowguid 
        and tomb.tablenick = 26466000
        and rows.rowguid is not NULL and rows.lineage_new is not null
        where tomb.rowguid is NULL 
        and rows.rowguid is not NULL and rows.lineage_new is not null
        
        if @@error<>0
            goto Failure

        -- now delete the contents rows
        delete dbo.MSmerge_contents with (rowlock)
        from 
        (

         select @rowguid1 as rowguid union all 
         select @rowguid2 as rowguid union all 
         select @rowguid3 as rowguid union all 
         select @rowguid4 as rowguid union all 
         select @rowguid5 as rowguid union all 
         select @rowguid6 as rowguid union all 
         select @rowguid7 as rowguid union all 
         select @rowguid8 as rowguid union all 
         select @rowguid9 as rowguid union all 
         select @rowguid10 as rowguid union all 
         select @rowguid11 as rowguid union all 
         select @rowguid12 as rowguid union all 
         select @rowguid13 as rowguid union all 
         select @rowguid14 as rowguid union all 
         select @rowguid15 as rowguid union all 
         select @rowguid16 as rowguid union all 
         select @rowguid17 as rowguid union all 
         select @rowguid18 as rowguid union all 
         select @rowguid19 as rowguid union all 
         select @rowguid20 as rowguid union all 
         select @rowguid21 as rowguid union all 
         select @rowguid22 as rowguid union all 
         select @rowguid23 as rowguid union all 
         select @rowguid24 as rowguid union all 
         select @rowguid25 as rowguid union all 
         select @rowguid26 as rowguid union all 
         select @rowguid27 as rowguid union all 
         select @rowguid28 as rowguid union all 
         select @rowguid29 as rowguid union all 
         select @rowguid30 as rowguid union all 
         select @rowguid31 as rowguid union all 
         select @rowguid32 as rowguid union all 
         select @rowguid33 as rowguid union all 
         select @rowguid34 as rowguid union all 
         select @rowguid35 as rowguid union all 
         select @rowguid36 as rowguid union all 
         select @rowguid37 as rowguid union all 
         select @rowguid38 as rowguid union all 
         select @rowguid39 as rowguid union all 
         select @rowguid40 as rowguid union all 
         select @rowguid41 as rowguid union all 
         select @rowguid42 as rowguid union all 
         select @rowguid43 as rowguid union all 
         select @rowguid44 as rowguid union all 
         select @rowguid45 as rowguid union all 
         select @rowguid46 as rowguid union all 
         select @rowguid47 as rowguid union all 
         select @rowguid48 as rowguid union all 
         select @rowguid49 as rowguid union all 
         select @rowguid50 as rowguid union all

         select @rowguid51 as rowguid union all 
         select @rowguid52 as rowguid union all 
         select @rowguid53 as rowguid union all 
         select @rowguid54 as rowguid union all 
         select @rowguid55 as rowguid union all 
         select @rowguid56 as rowguid union all 
         select @rowguid57 as rowguid union all 
         select @rowguid58 as rowguid union all 
         select @rowguid59 as rowguid union all 
         select @rowguid60 as rowguid union all 
         select @rowguid61 as rowguid union all 
         select @rowguid62 as rowguid union all 
         select @rowguid63 as rowguid union all 
         select @rowguid64 as rowguid union all 
         select @rowguid65 as rowguid union all 
         select @rowguid66 as rowguid union all 
         select @rowguid67 as rowguid union all 
         select @rowguid68 as rowguid union all 
         select @rowguid69 as rowguid union all 
         select @rowguid70 as rowguid union all 
         select @rowguid71 as rowguid union all 
         select @rowguid72 as rowguid union all 
         select @rowguid73 as rowguid union all 
         select @rowguid74 as rowguid union all 
         select @rowguid75 as rowguid union all 
         select @rowguid76 as rowguid union all 
         select @rowguid77 as rowguid union all 
         select @rowguid78 as rowguid union all 
         select @rowguid79 as rowguid union all 
         select @rowguid80 as rowguid union all 
         select @rowguid81 as rowguid union all 
         select @rowguid82 as rowguid union all 
         select @rowguid83 as rowguid union all 
         select @rowguid84 as rowguid union all 
         select @rowguid85 as rowguid union all 
         select @rowguid86 as rowguid union all 
         select @rowguid87 as rowguid union all 
         select @rowguid88 as rowguid union all 
         select @rowguid89 as rowguid union all 
         select @rowguid90 as rowguid union all 
         select @rowguid91 as rowguid union all 
         select @rowguid92 as rowguid union all 
         select @rowguid93 as rowguid union all 
         select @rowguid94 as rowguid union all 
         select @rowguid95 as rowguid union all 
         select @rowguid96 as rowguid union all 
         select @rowguid97 as rowguid union all 
         select @rowguid98 as rowguid union all 
         select @rowguid99 as rowguid union all 
         select @rowguid100 as rowguid

        ) as rows, dbo.MSmerge_contents cont with (rowlock)
        where cont.rowguid = rows.rowguid and cont.tablenick = 26466000
            and rows.rowguid is not NULL
        option (force order, loop join)
        if @@error<>0 
            goto Failure
    end

    exec @retcode = sys.sp_MSdeletemetadataactionrequest '9DEE015E-1388-43B6-BDF0-8C2967FBB918', 26466000, 
        @rowguid1, 
        @rowguid2, 
        @rowguid3, 
        @rowguid4, 
        @rowguid5, 
        @rowguid6, 
        @rowguid7, 
        @rowguid8, 
        @rowguid9, 
        @rowguid10, 
        @rowguid11, 
        @rowguid12, 
        @rowguid13, 
        @rowguid14, 
        @rowguid15, 
        @rowguid16, 
        @rowguid17, 
        @rowguid18, 
        @rowguid19, 
        @rowguid20, 
        @rowguid21, 
        @rowguid22, 
        @rowguid23, 
        @rowguid24, 
        @rowguid25, 
        @rowguid26, 
        @rowguid27, 
        @rowguid28, 
        @rowguid29, 
        @rowguid30, 
        @rowguid31, 
        @rowguid32, 
        @rowguid33, 
        @rowguid34, 
        @rowguid35, 
        @rowguid36, 
        @rowguid37, 
        @rowguid38, 
        @rowguid39, 
        @rowguid40, 
        @rowguid41, 
        @rowguid42, 
        @rowguid43, 
        @rowguid44, 
        @rowguid45, 
        @rowguid46, 
        @rowguid47, 
        @rowguid48, 
        @rowguid49, 
        @rowguid50, 
        @rowguid51, 
        @rowguid52, 
        @rowguid53, 
        @rowguid54, 
        @rowguid55, 
        @rowguid56, 
        @rowguid57, 
        @rowguid58, 
        @rowguid59, 
        @rowguid60, 
        @rowguid61, 
        @rowguid62, 
        @rowguid63, 
        @rowguid64, 
        @rowguid65, 
        @rowguid66, 
        @rowguid67, 
        @rowguid68, 
        @rowguid69, 
        @rowguid70, 
        @rowguid71, 
        @rowguid72, 
        @rowguid73, 
        @rowguid74, 
        @rowguid75, 
        @rowguid76, 
        @rowguid77, 
        @rowguid78, 
        @rowguid79, 
        @rowguid80, 
        @rowguid81, 
        @rowguid82, 
        @rowguid83, 
        @rowguid84, 
        @rowguid85, 
        @rowguid86, 
        @rowguid87, 
        @rowguid88, 
        @rowguid89, 
        @rowguid90, 
        @rowguid91, 
        @rowguid92, 
        @rowguid93, 
        @rowguid94, 
        @rowguid95, 
        @rowguid96, 
        @rowguid97, 
        @rowguid98, 
        @rowguid99, 
        @rowguid100
    if @retcode<>0 or @@error<>0
        goto Failure


    commit tran
    return 1

Failure:
    rollback tran batchdeleteproc
    commit tran
    return 0
end

go
create procedure dbo.[MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6_batch] (
        @rows_tobe_inserted int,
        @partition_id int = null 
,
    @rowguid1 uniqueidentifier = NULL,
    @generation1 bigint = NULL,
    @lineage1 varbinary(311) = NULL,
    @colv1 varbinary(1) = NULL,
    @p1 nvarchar(50) = NULL,
    @p2 nvarchar(50) = NULL,
    @p3 date = NULL,
    @p4 date = NULL,
    @p5 float = NULL,
    @p6 int = NULL,
    @p7 int = NULL,
    @p8 nvarchar(50) = NULL,
    @p9 uniqueidentifier = NULL,
    @rowguid2 uniqueidentifier = NULL,
    @generation2 bigint = NULL,
    @lineage2 varbinary(311) = NULL,
    @colv2 varbinary(1) = NULL,
    @p10 nvarchar(50) = NULL,
    @p11 nvarchar(50) = NULL,
    @p12 date = NULL,
    @p13 date = NULL,
    @p14 float = NULL,
    @p15 int = NULL,
    @p16 int = NULL,
    @p17 nvarchar(50) = NULL,
    @p18 uniqueidentifier = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @generation3 bigint = NULL,
    @lineage3 varbinary(311) = NULL,
    @colv3 varbinary(1) = NULL,
    @p19 nvarchar(50) = NULL,
    @p20 nvarchar(50) = NULL,
    @p21 date = NULL,
    @p22 date = NULL,
    @p23 float = NULL,
    @p24 int = NULL,
    @p25 int = NULL,
    @p26 nvarchar(50) = NULL,
    @p27 uniqueidentifier = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @generation4 bigint = NULL,
    @lineage4 varbinary(311) = NULL,
    @colv4 varbinary(1) = NULL,
    @p28 nvarchar(50) = NULL,
    @p29 nvarchar(50) = NULL,
    @p30 date = NULL,
    @p31 date = NULL,
    @p32 float = NULL,
    @p33 int = NULL,
    @p34 int = NULL,
    @p35 nvarchar(50) = NULL,
    @p36 uniqueidentifier = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @generation5 bigint = NULL,
    @lineage5 varbinary(311) = NULL,
    @colv5 varbinary(1) = NULL,
    @p37 nvarchar(50) = NULL,
    @p38 nvarchar(50) = NULL,
    @p39 date = NULL,
    @p40 date = NULL,
    @p41 float = NULL,
    @p42 int = NULL,
    @p43 int = NULL,
    @p44 nvarchar(50) = NULL,
    @p45 uniqueidentifier = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @generation6 bigint = NULL,
    @lineage6 varbinary(311) = NULL,
    @colv6 varbinary(1) = NULL,
    @p46 nvarchar(50) = NULL,
    @p47 nvarchar(50) = NULL,
    @p48 date = NULL,
    @p49 date = NULL,
    @p50 float = NULL,
    @p51 int = NULL,
    @p52 int = NULL,
    @p53 nvarchar(50) = NULL,
    @p54 uniqueidentifier = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @generation7 bigint = NULL,
    @lineage7 varbinary(311) = NULL,
    @colv7 varbinary(1) = NULL,
    @p55 nvarchar(50) = NULL,
    @p56 nvarchar(50) = NULL,
    @p57 date = NULL,
    @p58 date = NULL,
    @p59 float = NULL,
    @p60 int = NULL,
    @p61 int = NULL,
    @p62 nvarchar(50) = NULL,
    @p63 uniqueidentifier = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @generation8 bigint = NULL,
    @lineage8 varbinary(311) = NULL,
    @colv8 varbinary(1) = NULL,
    @p64 nvarchar(50) = NULL,
    @p65 nvarchar(50) = NULL,
    @p66 date = NULL,
    @p67 date = NULL,
    @p68 float = NULL,
    @p69 int = NULL,
    @p70 int = NULL,
    @p71 nvarchar(50) = NULL,
    @p72 uniqueidentifier = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @generation9 bigint = NULL,
    @lineage9 varbinary(311) = NULL,
    @colv9 varbinary(1) = NULL,
    @p73 nvarchar(50) = NULL,
    @p74 nvarchar(50) = NULL,
    @p75 date = NULL,
    @p76 date = NULL,
    @p77 float = NULL,
    @p78 int = NULL,
    @p79 int = NULL,
    @p80 nvarchar(50) = NULL,
    @p81 uniqueidentifier = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @generation10 bigint = NULL,
    @lineage10 varbinary(311) = NULL,
    @colv10 varbinary(1) = NULL,
    @p82 nvarchar(50) = NULL,
    @p83 nvarchar(50) = NULL,
    @p84 date = NULL,
    @p85 date = NULL,
    @p86 float = NULL,
    @p87 int = NULL
,
    @p88 int = NULL,
    @p89 nvarchar(50) = NULL,
    @p90 uniqueidentifier = NULL,
    @rowguid11 uniqueidentifier = NULL,
    @generation11 bigint = NULL,
    @lineage11 varbinary(311) = NULL,
    @colv11 varbinary(1) = NULL,
    @p91 nvarchar(50) = NULL,
    @p92 nvarchar(50) = NULL,
    @p93 date = NULL,
    @p94 date = NULL,
    @p95 float = NULL,
    @p96 int = NULL,
    @p97 int = NULL,
    @p98 nvarchar(50) = NULL,
    @p99 uniqueidentifier = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @generation12 bigint = NULL,
    @lineage12 varbinary(311) = NULL,
    @colv12 varbinary(1) = NULL,
    @p100 nvarchar(50) = NULL,
    @p101 nvarchar(50) = NULL,
    @p102 date = NULL,
    @p103 date = NULL,
    @p104 float = NULL,
    @p105 int = NULL,
    @p106 int = NULL,
    @p107 nvarchar(50) = NULL,
    @p108 uniqueidentifier = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @generation13 bigint = NULL,
    @lineage13 varbinary(311) = NULL,
    @colv13 varbinary(1) = NULL,
    @p109 nvarchar(50) = NULL,
    @p110 nvarchar(50) = NULL,
    @p111 date = NULL,
    @p112 date = NULL,
    @p113 float = NULL,
    @p114 int = NULL,
    @p115 int = NULL,
    @p116 nvarchar(50) = NULL,
    @p117 uniqueidentifier = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @generation14 bigint = NULL,
    @lineage14 varbinary(311) = NULL,
    @colv14 varbinary(1) = NULL,
    @p118 nvarchar(50) = NULL,
    @p119 nvarchar(50) = NULL,
    @p120 date = NULL,
    @p121 date = NULL,
    @p122 float = NULL,
    @p123 int = NULL,
    @p124 int = NULL,
    @p125 nvarchar(50) = NULL,
    @p126 uniqueidentifier = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @generation15 bigint = NULL,
    @lineage15 varbinary(311) = NULL,
    @colv15 varbinary(1) = NULL,
    @p127 nvarchar(50) = NULL,
    @p128 nvarchar(50) = NULL,
    @p129 date = NULL,
    @p130 date = NULL,
    @p131 float = NULL,
    @p132 int = NULL,
    @p133 int = NULL,
    @p134 nvarchar(50) = NULL,
    @p135 uniqueidentifier = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @generation16 bigint = NULL,
    @lineage16 varbinary(311) = NULL,
    @colv16 varbinary(1) = NULL,
    @p136 nvarchar(50) = NULL,
    @p137 nvarchar(50) = NULL,
    @p138 date = NULL,
    @p139 date = NULL,
    @p140 float = NULL,
    @p141 int = NULL,
    @p142 int = NULL,
    @p143 nvarchar(50) = NULL,
    @p144 uniqueidentifier = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @generation17 bigint = NULL,
    @lineage17 varbinary(311) = NULL,
    @colv17 varbinary(1) = NULL,
    @p145 nvarchar(50) = NULL,
    @p146 nvarchar(50) = NULL,
    @p147 date = NULL,
    @p148 date = NULL,
    @p149 float = NULL,
    @p150 int = NULL,
    @p151 int = NULL,
    @p152 nvarchar(50) = NULL,
    @p153 uniqueidentifier = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @generation18 bigint = NULL,
    @lineage18 varbinary(311) = NULL,
    @colv18 varbinary(1) = NULL,
    @p154 nvarchar(50) = NULL,
    @p155 nvarchar(50) = NULL,
    @p156 date = NULL,
    @p157 date = NULL,
    @p158 float = NULL,
    @p159 int = NULL,
    @p160 int = NULL,
    @p161 nvarchar(50) = NULL,
    @p162 uniqueidentifier = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @generation19 bigint = NULL,
    @lineage19 varbinary(311) = NULL,
    @colv19 varbinary(1) = NULL,
    @p163 nvarchar(50) = NULL,
    @p164 nvarchar(50) = NULL,
    @p165 date = NULL,
    @p166 date = NULL,
    @p167 float = NULL,
    @p168 int = NULL,
    @p169 int = NULL,
    @p170 nvarchar(50) = NULL,
    @p171 uniqueidentifier = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @generation20 bigint = NULL,
    @lineage20 varbinary(311) = NULL,
    @colv20 varbinary(1) = NULL,
    @p172 nvarchar(50) = NULL
,
    @p173 nvarchar(50) = NULL,
    @p174 date = NULL,
    @p175 date = NULL,
    @p176 float = NULL,
    @p177 int = NULL,
    @p178 int = NULL,
    @p179 nvarchar(50) = NULL,
    @p180 uniqueidentifier = NULL,
    @rowguid21 uniqueidentifier = NULL,
    @generation21 bigint = NULL,
    @lineage21 varbinary(311) = NULL,
    @colv21 varbinary(1) = NULL,
    @p181 nvarchar(50) = NULL,
    @p182 nvarchar(50) = NULL,
    @p183 date = NULL,
    @p184 date = NULL,
    @p185 float = NULL,
    @p186 int = NULL,
    @p187 int = NULL,
    @p188 nvarchar(50) = NULL,
    @p189 uniqueidentifier = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @generation22 bigint = NULL,
    @lineage22 varbinary(311) = NULL,
    @colv22 varbinary(1) = NULL,
    @p190 nvarchar(50) = NULL,
    @p191 nvarchar(50) = NULL,
    @p192 date = NULL,
    @p193 date = NULL,
    @p194 float = NULL,
    @p195 int = NULL,
    @p196 int = NULL,
    @p197 nvarchar(50) = NULL,
    @p198 uniqueidentifier = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @generation23 bigint = NULL,
    @lineage23 varbinary(311) = NULL,
    @colv23 varbinary(1) = NULL,
    @p199 nvarchar(50) = NULL,
    @p200 nvarchar(50) = NULL,
    @p201 date = NULL,
    @p202 date = NULL,
    @p203 float = NULL,
    @p204 int = NULL,
    @p205 int = NULL,
    @p206 nvarchar(50) = NULL,
    @p207 uniqueidentifier = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @generation24 bigint = NULL,
    @lineage24 varbinary(311) = NULL,
    @colv24 varbinary(1) = NULL,
    @p208 nvarchar(50) = NULL,
    @p209 nvarchar(50) = NULL,
    @p210 date = NULL,
    @p211 date = NULL,
    @p212 float = NULL,
    @p213 int = NULL,
    @p214 int = NULL,
    @p215 nvarchar(50) = NULL,
    @p216 uniqueidentifier = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @generation25 bigint = NULL,
    @lineage25 varbinary(311) = NULL,
    @colv25 varbinary(1) = NULL,
    @p217 nvarchar(50) = NULL,
    @p218 nvarchar(50) = NULL,
    @p219 date = NULL,
    @p220 date = NULL,
    @p221 float = NULL,
    @p222 int = NULL,
    @p223 int = NULL,
    @p224 nvarchar(50) = NULL,
    @p225 uniqueidentifier = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @generation26 bigint = NULL,
    @lineage26 varbinary(311) = NULL,
    @colv26 varbinary(1) = NULL,
    @p226 nvarchar(50) = NULL,
    @p227 nvarchar(50) = NULL,
    @p228 date = NULL,
    @p229 date = NULL,
    @p230 float = NULL,
    @p231 int = NULL,
    @p232 int = NULL,
    @p233 nvarchar(50) = NULL,
    @p234 uniqueidentifier = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @generation27 bigint = NULL,
    @lineage27 varbinary(311) = NULL,
    @colv27 varbinary(1) = NULL,
    @p235 nvarchar(50) = NULL,
    @p236 nvarchar(50) = NULL,
    @p237 date = NULL,
    @p238 date = NULL,
    @p239 float = NULL,
    @p240 int = NULL,
    @p241 int = NULL,
    @p242 nvarchar(50) = NULL,
    @p243 uniqueidentifier = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @generation28 bigint = NULL,
    @lineage28 varbinary(311) = NULL,
    @colv28 varbinary(1) = NULL,
    @p244 nvarchar(50) = NULL,
    @p245 nvarchar(50) = NULL,
    @p246 date = NULL,
    @p247 date = NULL,
    @p248 float = NULL,
    @p249 int = NULL,
    @p250 int = NULL,
    @p251 nvarchar(50) = NULL,
    @p252 uniqueidentifier = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @generation29 bigint = NULL,
    @lineage29 varbinary(311) = NULL,
    @colv29 varbinary(1) = NULL,
    @p253 nvarchar(50) = NULL,
    @p254 nvarchar(50) = NULL,
    @p255 date = NULL,
    @p256 date = NULL,
    @p257 float = NULL,
    @p258 int = NULL,
    @p259 int = NULL,
    @p260 nvarchar(50) = NULL
,
    @p261 uniqueidentifier = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @generation30 bigint = NULL,
    @lineage30 varbinary(311) = NULL,
    @colv30 varbinary(1) = NULL,
    @p262 nvarchar(50) = NULL,
    @p263 nvarchar(50) = NULL,
    @p264 date = NULL,
    @p265 date = NULL,
    @p266 float = NULL,
    @p267 int = NULL,
    @p268 int = NULL,
    @p269 nvarchar(50) = NULL,
    @p270 uniqueidentifier = NULL,
    @rowguid31 uniqueidentifier = NULL,
    @generation31 bigint = NULL,
    @lineage31 varbinary(311) = NULL,
    @colv31 varbinary(1) = NULL,
    @p271 nvarchar(50) = NULL,
    @p272 nvarchar(50) = NULL,
    @p273 date = NULL,
    @p274 date = NULL,
    @p275 float = NULL,
    @p276 int = NULL,
    @p277 int = NULL,
    @p278 nvarchar(50) = NULL,
    @p279 uniqueidentifier = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @generation32 bigint = NULL,
    @lineage32 varbinary(311) = NULL,
    @colv32 varbinary(1) = NULL,
    @p280 nvarchar(50) = NULL,
    @p281 nvarchar(50) = NULL,
    @p282 date = NULL,
    @p283 date = NULL,
    @p284 float = NULL,
    @p285 int = NULL,
    @p286 int = NULL,
    @p287 nvarchar(50) = NULL,
    @p288 uniqueidentifier = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @generation33 bigint = NULL,
    @lineage33 varbinary(311) = NULL,
    @colv33 varbinary(1) = NULL,
    @p289 nvarchar(50) = NULL,
    @p290 nvarchar(50) = NULL,
    @p291 date = NULL,
    @p292 date = NULL,
    @p293 float = NULL,
    @p294 int = NULL,
    @p295 int = NULL,
    @p296 nvarchar(50) = NULL,
    @p297 uniqueidentifier = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @generation34 bigint = NULL,
    @lineage34 varbinary(311) = NULL,
    @colv34 varbinary(1) = NULL,
    @p298 nvarchar(50) = NULL,
    @p299 nvarchar(50) = NULL,
    @p300 date = NULL,
    @p301 date = NULL,
    @p302 float = NULL,
    @p303 int = NULL,
    @p304 int = NULL,
    @p305 nvarchar(50) = NULL,
    @p306 uniqueidentifier = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @generation35 bigint = NULL,
    @lineage35 varbinary(311) = NULL,
    @colv35 varbinary(1) = NULL,
    @p307 nvarchar(50) = NULL,
    @p308 nvarchar(50) = NULL,
    @p309 date = NULL,
    @p310 date = NULL,
    @p311 float = NULL,
    @p312 int = NULL,
    @p313 int = NULL,
    @p314 nvarchar(50) = NULL,
    @p315 uniqueidentifier = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @generation36 bigint = NULL,
    @lineage36 varbinary(311) = NULL,
    @colv36 varbinary(1) = NULL,
    @p316 nvarchar(50) = NULL,
    @p317 nvarchar(50) = NULL,
    @p318 date = NULL,
    @p319 date = NULL,
    @p320 float = NULL,
    @p321 int = NULL,
    @p322 int = NULL,
    @p323 nvarchar(50) = NULL,
    @p324 uniqueidentifier = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @generation37 bigint = NULL,
    @lineage37 varbinary(311) = NULL,
    @colv37 varbinary(1) = NULL,
    @p325 nvarchar(50) = NULL,
    @p326 nvarchar(50) = NULL,
    @p327 date = NULL,
    @p328 date = NULL,
    @p329 float = NULL,
    @p330 int = NULL,
    @p331 int = NULL,
    @p332 nvarchar(50) = NULL,
    @p333 uniqueidentifier = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @generation38 bigint = NULL,
    @lineage38 varbinary(311) = NULL,
    @colv38 varbinary(1) = NULL,
    @p334 nvarchar(50) = NULL,
    @p335 nvarchar(50) = NULL,
    @p336 date = NULL,
    @p337 date = NULL,
    @p338 float = NULL,
    @p339 int = NULL,
    @p340 int = NULL,
    @p341 nvarchar(50) = NULL,
    @p342 uniqueidentifier = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @generation39 bigint = NULL,
    @lineage39 varbinary(311) = NULL,
    @colv39 varbinary(1) = NULL,
    @p343 nvarchar(50) = NULL
,
    @p344 nvarchar(50) = NULL,
    @p345 date = NULL,
    @p346 date = NULL,
    @p347 float = NULL,
    @p348 int = NULL,
    @p349 int = NULL,
    @p350 nvarchar(50) = NULL,
    @p351 uniqueidentifier = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @generation40 bigint = NULL,
    @lineage40 varbinary(311) = NULL,
    @colv40 varbinary(1) = NULL,
    @p352 nvarchar(50) = NULL,
    @p353 nvarchar(50) = NULL,
    @p354 date = NULL,
    @p355 date = NULL,
    @p356 float = NULL,
    @p357 int = NULL,
    @p358 int = NULL,
    @p359 nvarchar(50) = NULL,
    @p360 uniqueidentifier = NULL,
    @rowguid41 uniqueidentifier = NULL,
    @generation41 bigint = NULL,
    @lineage41 varbinary(311) = NULL,
    @colv41 varbinary(1) = NULL,
    @p361 nvarchar(50) = NULL,
    @p362 nvarchar(50) = NULL,
    @p363 date = NULL,
    @p364 date = NULL,
    @p365 float = NULL,
    @p366 int = NULL,
    @p367 int = NULL,
    @p368 nvarchar(50) = NULL,
    @p369 uniqueidentifier = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @generation42 bigint = NULL,
    @lineage42 varbinary(311) = NULL,
    @colv42 varbinary(1) = NULL,
    @p370 nvarchar(50) = NULL,
    @p371 nvarchar(50) = NULL,
    @p372 date = NULL,
    @p373 date = NULL,
    @p374 float = NULL,
    @p375 int = NULL,
    @p376 int = NULL,
    @p377 nvarchar(50) = NULL,
    @p378 uniqueidentifier = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @generation43 bigint = NULL,
    @lineage43 varbinary(311) = NULL,
    @colv43 varbinary(1) = NULL,
    @p379 nvarchar(50) = NULL,
    @p380 nvarchar(50) = NULL,
    @p381 date = NULL,
    @p382 date = NULL,
    @p383 float = NULL,
    @p384 int = NULL,
    @p385 int = NULL,
    @p386 nvarchar(50) = NULL,
    @p387 uniqueidentifier = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @generation44 bigint = NULL,
    @lineage44 varbinary(311) = NULL,
    @colv44 varbinary(1) = NULL,
    @p388 nvarchar(50) = NULL,
    @p389 nvarchar(50) = NULL,
    @p390 date = NULL,
    @p391 date = NULL,
    @p392 float = NULL,
    @p393 int = NULL,
    @p394 int = NULL,
    @p395 nvarchar(50) = NULL,
    @p396 uniqueidentifier = NULL,
    @rowguid45 uniqueidentifier = NULL,
    @generation45 bigint = NULL,
    @lineage45 varbinary(311) = NULL,
    @colv45 varbinary(1) = NULL,
    @p397 nvarchar(50) = NULL,
    @p398 nvarchar(50) = NULL,
    @p399 date = NULL,
    @p400 date = NULL,
    @p401 float = NULL,
    @p402 int = NULL,
    @p403 int = NULL,
    @p404 nvarchar(50) = NULL,
    @p405 uniqueidentifier = NULL,
    @rowguid46 uniqueidentifier = NULL,
    @generation46 bigint = NULL,
    @lineage46 varbinary(311) = NULL,
    @colv46 varbinary(1) = NULL,
    @p406 nvarchar(50) = NULL,
    @p407 nvarchar(50) = NULL,
    @p408 date = NULL,
    @p409 date = NULL,
    @p410 float = NULL,
    @p411 int = NULL,
    @p412 int = NULL,
    @p413 nvarchar(50) = NULL,
    @p414 uniqueidentifier = NULL,
    @rowguid47 uniqueidentifier = NULL,
    @generation47 bigint = NULL,
    @lineage47 varbinary(311) = NULL,
    @colv47 varbinary(1) = NULL,
    @p415 nvarchar(50) = NULL,
    @p416 nvarchar(50) = NULL,
    @p417 date = NULL,
    @p418 date = NULL,
    @p419 float = NULL,
    @p420 int = NULL,
    @p421 int = NULL,
    @p422 nvarchar(50) = NULL,
    @p423 uniqueidentifier = NULL,
    @rowguid48 uniqueidentifier = NULL,
    @generation48 bigint = NULL,
    @lineage48 varbinary(311) = NULL,
    @colv48 varbinary(1) = NULL,
    @p424 nvarchar(50) = NULL,
    @p425 nvarchar(50) = NULL,
    @p426 date = NULL,
    @p427 date = NULL,
    @p428 float = NULL,
    @p429 int = NULL,
    @p430 int = NULL,
    @p431 nvarchar(50) = NULL
,
    @p432 uniqueidentifier = NULL,
    @rowguid49 uniqueidentifier = NULL,
    @generation49 bigint = NULL,
    @lineage49 varbinary(311) = NULL,
    @colv49 varbinary(1) = NULL,
    @p433 nvarchar(50) = NULL,
    @p434 nvarchar(50) = NULL,
    @p435 date = NULL,
    @p436 date = NULL,
    @p437 float = NULL,
    @p438 int = NULL,
    @p439 int = NULL,
    @p440 nvarchar(50) = NULL,
    @p441 uniqueidentifier = NULL,
    @rowguid50 uniqueidentifier = NULL,
    @generation50 bigint = NULL,
    @lineage50 varbinary(311) = NULL,
    @colv50 varbinary(1) = NULL,
    @p442 nvarchar(50) = NULL,
    @p443 nvarchar(50) = NULL,
    @p444 date = NULL,
    @p445 date = NULL,
    @p446 float = NULL,
    @p447 int = NULL,
    @p448 int = NULL,
    @p449 nvarchar(50) = NULL,
    @p450 uniqueidentifier = NULL,
    @rowguid51 uniqueidentifier = NULL,
    @generation51 bigint = NULL,
    @lineage51 varbinary(311) = NULL,
    @colv51 varbinary(1) = NULL,
    @p451 nvarchar(50) = NULL,
    @p452 nvarchar(50) = NULL,
    @p453 date = NULL,
    @p454 date = NULL,
    @p455 float = NULL,
    @p456 int = NULL,
    @p457 int = NULL,
    @p458 nvarchar(50) = NULL,
    @p459 uniqueidentifier = NULL,
    @rowguid52 uniqueidentifier = NULL,
    @generation52 bigint = NULL,
    @lineage52 varbinary(311) = NULL,
    @colv52 varbinary(1) = NULL,
    @p460 nvarchar(50) = NULL,
    @p461 nvarchar(50) = NULL,
    @p462 date = NULL,
    @p463 date = NULL,
    @p464 float = NULL,
    @p465 int = NULL,
    @p466 int = NULL,
    @p467 nvarchar(50) = NULL,
    @p468 uniqueidentifier = NULL,
    @rowguid53 uniqueidentifier = NULL,
    @generation53 bigint = NULL,
    @lineage53 varbinary(311) = NULL,
    @colv53 varbinary(1) = NULL,
    @p469 nvarchar(50) = NULL,
    @p470 nvarchar(50) = NULL,
    @p471 date = NULL,
    @p472 date = NULL,
    @p473 float = NULL,
    @p474 int = NULL,
    @p475 int = NULL,
    @p476 nvarchar(50) = NULL,
    @p477 uniqueidentifier = NULL,
    @rowguid54 uniqueidentifier = NULL,
    @generation54 bigint = NULL,
    @lineage54 varbinary(311) = NULL,
    @colv54 varbinary(1) = NULL,
    @p478 nvarchar(50) = NULL,
    @p479 nvarchar(50) = NULL,
    @p480 date = NULL,
    @p481 date = NULL,
    @p482 float = NULL,
    @p483 int = NULL,
    @p484 int = NULL,
    @p485 nvarchar(50) = NULL,
    @p486 uniqueidentifier = NULL,
    @rowguid55 uniqueidentifier = NULL,
    @generation55 bigint = NULL,
    @lineage55 varbinary(311) = NULL,
    @colv55 varbinary(1) = NULL,
    @p487 nvarchar(50) = NULL,
    @p488 nvarchar(50) = NULL,
    @p489 date = NULL,
    @p490 date = NULL,
    @p491 float = NULL,
    @p492 int = NULL,
    @p493 int = NULL,
    @p494 nvarchar(50) = NULL,
    @p495 uniqueidentifier = NULL,
    @rowguid56 uniqueidentifier = NULL,
    @generation56 bigint = NULL,
    @lineage56 varbinary(311) = NULL,
    @colv56 varbinary(1) = NULL,
    @p496 nvarchar(50) = NULL,
    @p497 nvarchar(50) = NULL,
    @p498 date = NULL,
    @p499 date = NULL,
    @p500 float = NULL,
    @p501 int = NULL,
    @p502 int = NULL,
    @p503 nvarchar(50) = NULL,
    @p504 uniqueidentifier = NULL,
    @rowguid57 uniqueidentifier = NULL,
    @generation57 bigint = NULL,
    @lineage57 varbinary(311) = NULL,
    @colv57 varbinary(1) = NULL,
    @p505 nvarchar(50) = NULL,
    @p506 nvarchar(50) = NULL,
    @p507 date = NULL,
    @p508 date = NULL,
    @p509 float = NULL,
    @p510 int = NULL,
    @p511 int = NULL,
    @p512 nvarchar(50) = NULL,
    @p513 uniqueidentifier = NULL,
    @rowguid58 uniqueidentifier = NULL,
    @generation58 bigint = NULL,
    @lineage58 varbinary(311) = NULL,
    @colv58 varbinary(1) = NULL,
    @p514 nvarchar(50) = NULL
,
    @p515 nvarchar(50) = NULL,
    @p516 date = NULL,
    @p517 date = NULL,
    @p518 float = NULL,
    @p519 int = NULL,
    @p520 int = NULL,
    @p521 nvarchar(50) = NULL,
    @p522 uniqueidentifier = NULL,
    @rowguid59 uniqueidentifier = NULL,
    @generation59 bigint = NULL,
    @lineage59 varbinary(311) = NULL,
    @colv59 varbinary(1) = NULL,
    @p523 nvarchar(50) = NULL,
    @p524 nvarchar(50) = NULL,
    @p525 date = NULL,
    @p526 date = NULL,
    @p527 float = NULL,
    @p528 int = NULL,
    @p529 int = NULL,
    @p530 nvarchar(50) = NULL,
    @p531 uniqueidentifier = NULL,
    @rowguid60 uniqueidentifier = NULL,
    @generation60 bigint = NULL,
    @lineage60 varbinary(311) = NULL,
    @colv60 varbinary(1) = NULL,
    @p532 nvarchar(50) = NULL,
    @p533 nvarchar(50) = NULL,
    @p534 date = NULL,
    @p535 date = NULL,
    @p536 float = NULL,
    @p537 int = NULL,
    @p538 int = NULL,
    @p539 nvarchar(50) = NULL,
    @p540 uniqueidentifier = NULL,
    @rowguid61 uniqueidentifier = NULL,
    @generation61 bigint = NULL,
    @lineage61 varbinary(311) = NULL,
    @colv61 varbinary(1) = NULL,
    @p541 nvarchar(50) = NULL,
    @p542 nvarchar(50) = NULL,
    @p543 date = NULL,
    @p544 date = NULL,
    @p545 float = NULL,
    @p546 int = NULL,
    @p547 int = NULL,
    @p548 nvarchar(50) = NULL,
    @p549 uniqueidentifier = NULL,
    @rowguid62 uniqueidentifier = NULL,
    @generation62 bigint = NULL,
    @lineage62 varbinary(311) = NULL,
    @colv62 varbinary(1) = NULL,
    @p550 nvarchar(50) = NULL,
    @p551 nvarchar(50) = NULL,
    @p552 date = NULL,
    @p553 date = NULL,
    @p554 float = NULL,
    @p555 int = NULL,
    @p556 int = NULL,
    @p557 nvarchar(50) = NULL,
    @p558 uniqueidentifier = NULL,
    @rowguid63 uniqueidentifier = NULL,
    @generation63 bigint = NULL,
    @lineage63 varbinary(311) = NULL,
    @colv63 varbinary(1) = NULL,
    @p559 nvarchar(50) = NULL,
    @p560 nvarchar(50) = NULL,
    @p561 date = NULL,
    @p562 date = NULL,
    @p563 float = NULL,
    @p564 int = NULL,
    @p565 int = NULL,
    @p566 nvarchar(50) = NULL,
    @p567 uniqueidentifier = NULL,
    @rowguid64 uniqueidentifier = NULL,
    @generation64 bigint = NULL,
    @lineage64 varbinary(311) = NULL,
    @colv64 varbinary(1) = NULL,
    @p568 nvarchar(50) = NULL,
    @p569 nvarchar(50) = NULL,
    @p570 date = NULL,
    @p571 date = NULL,
    @p572 float = NULL,
    @p573 int = NULL,
    @p574 int = NULL,
    @p575 nvarchar(50) = NULL,
    @p576 uniqueidentifier = NULL,
    @rowguid65 uniqueidentifier = NULL,
    @generation65 bigint = NULL,
    @lineage65 varbinary(311) = NULL,
    @colv65 varbinary(1) = NULL,
    @p577 nvarchar(50) = NULL,
    @p578 nvarchar(50) = NULL,
    @p579 date = NULL,
    @p580 date = NULL,
    @p581 float = NULL,
    @p582 int = NULL,
    @p583 int = NULL,
    @p584 nvarchar(50) = NULL,
    @p585 uniqueidentifier = NULL,
    @rowguid66 uniqueidentifier = NULL,
    @generation66 bigint = NULL,
    @lineage66 varbinary(311) = NULL,
    @colv66 varbinary(1) = NULL,
    @p586 nvarchar(50) = NULL,
    @p587 nvarchar(50) = NULL,
    @p588 date = NULL,
    @p589 date = NULL,
    @p590 float = NULL,
    @p591 int = NULL,
    @p592 int = NULL,
    @p593 nvarchar(50) = NULL,
    @p594 uniqueidentifier = NULL,
    @rowguid67 uniqueidentifier = NULL,
    @generation67 bigint = NULL,
    @lineage67 varbinary(311) = NULL,
    @colv67 varbinary(1) = NULL,
    @p595 nvarchar(50) = NULL,
    @p596 nvarchar(50) = NULL,
    @p597 date = NULL,
    @p598 date = NULL,
    @p599 float = NULL,
    @p600 int = NULL,
    @p601 int = NULL,
    @p602 nvarchar(50) = NULL
,
    @p603 uniqueidentifier = NULL,
    @rowguid68 uniqueidentifier = NULL,
    @generation68 bigint = NULL,
    @lineage68 varbinary(311) = NULL,
    @colv68 varbinary(1) = NULL,
    @p604 nvarchar(50) = NULL,
    @p605 nvarchar(50) = NULL,
    @p606 date = NULL,
    @p607 date = NULL,
    @p608 float = NULL,
    @p609 int = NULL,
    @p610 int = NULL,
    @p611 nvarchar(50) = NULL,
    @p612 uniqueidentifier = NULL,
    @rowguid69 uniqueidentifier = NULL,
    @generation69 bigint = NULL,
    @lineage69 varbinary(311) = NULL,
    @colv69 varbinary(1) = NULL,
    @p613 nvarchar(50) = NULL,
    @p614 nvarchar(50) = NULL,
    @p615 date = NULL,
    @p616 date = NULL,
    @p617 float = NULL,
    @p618 int = NULL,
    @p619 int = NULL,
    @p620 nvarchar(50) = NULL,
    @p621 uniqueidentifier = NULL,
    @rowguid70 uniqueidentifier = NULL,
    @generation70 bigint = NULL,
    @lineage70 varbinary(311) = NULL,
    @colv70 varbinary(1) = NULL,
    @p622 nvarchar(50) = NULL,
    @p623 nvarchar(50) = NULL,
    @p624 date = NULL,
    @p625 date = NULL,
    @p626 float = NULL,
    @p627 int = NULL,
    @p628 int = NULL,
    @p629 nvarchar(50) = NULL,
    @p630 uniqueidentifier = NULL,
    @rowguid71 uniqueidentifier = NULL,
    @generation71 bigint = NULL,
    @lineage71 varbinary(311) = NULL,
    @colv71 varbinary(1) = NULL,
    @p631 nvarchar(50) = NULL,
    @p632 nvarchar(50) = NULL,
    @p633 date = NULL,
    @p634 date = NULL,
    @p635 float = NULL,
    @p636 int = NULL,
    @p637 int = NULL,
    @p638 nvarchar(50) = NULL,
    @p639 uniqueidentifier = NULL,
    @rowguid72 uniqueidentifier = NULL,
    @generation72 bigint = NULL,
    @lineage72 varbinary(311) = NULL,
    @colv72 varbinary(1) = NULL,
    @p640 nvarchar(50) = NULL,
    @p641 nvarchar(50) = NULL,
    @p642 date = NULL,
    @p643 date = NULL,
    @p644 float = NULL,
    @p645 int = NULL,
    @p646 int = NULL,
    @p647 nvarchar(50) = NULL,
    @p648 uniqueidentifier = NULL,
    @rowguid73 uniqueidentifier = NULL,
    @generation73 bigint = NULL,
    @lineage73 varbinary(311) = NULL,
    @colv73 varbinary(1) = NULL,
    @p649 nvarchar(50) = NULL,
    @p650 nvarchar(50) = NULL,
    @p651 date = NULL,
    @p652 date = NULL,
    @p653 float = NULL,
    @p654 int = NULL,
    @p655 int = NULL,
    @p656 nvarchar(50) = NULL,
    @p657 uniqueidentifier = NULL,
    @rowguid74 uniqueidentifier = NULL,
    @generation74 bigint = NULL,
    @lineage74 varbinary(311) = NULL,
    @colv74 varbinary(1) = NULL,
    @p658 nvarchar(50) = NULL,
    @p659 nvarchar(50) = NULL,
    @p660 date = NULL,
    @p661 date = NULL,
    @p662 float = NULL,
    @p663 int = NULL,
    @p664 int = NULL,
    @p665 nvarchar(50) = NULL,
    @p666 uniqueidentifier = NULL,
    @rowguid75 uniqueidentifier = NULL,
    @generation75 bigint = NULL,
    @lineage75 varbinary(311) = NULL,
    @colv75 varbinary(1) = NULL,
    @p667 nvarchar(50) = NULL,
    @p668 nvarchar(50) = NULL,
    @p669 date = NULL,
    @p670 date = NULL,
    @p671 float = NULL,
    @p672 int = NULL,
    @p673 int = NULL,
    @p674 nvarchar(50) = NULL,
    @p675 uniqueidentifier = NULL,
    @rowguid76 uniqueidentifier = NULL,
    @generation76 bigint = NULL,
    @lineage76 varbinary(311) = NULL,
    @colv76 varbinary(1) = NULL,
    @p676 nvarchar(50) = NULL,
    @p677 nvarchar(50) = NULL,
    @p678 date = NULL,
    @p679 date = NULL,
    @p680 float = NULL,
    @p681 int = NULL,
    @p682 int = NULL,
    @p683 nvarchar(50) = NULL,
    @p684 uniqueidentifier = NULL,
    @rowguid77 uniqueidentifier = NULL,
    @generation77 bigint = NULL,
    @lineage77 varbinary(311) = NULL,
    @colv77 varbinary(1) = NULL,
    @p685 nvarchar(50) = NULL
,
    @p686 nvarchar(50) = NULL,
    @p687 date = NULL,
    @p688 date = NULL,
    @p689 float = NULL,
    @p690 int = NULL,
    @p691 int = NULL,
    @p692 nvarchar(50) = NULL,
    @p693 uniqueidentifier = NULL,
    @rowguid78 uniqueidentifier = NULL,
    @generation78 bigint = NULL,
    @lineage78 varbinary(311) = NULL,
    @colv78 varbinary(1) = NULL,
    @p694 nvarchar(50) = NULL
,
    @p695 nvarchar(50) = NULL
,
    @p696 date = NULL
,
    @p697 date = NULL
,
    @p698 float = NULL
,
    @p699 int = NULL
,
    @p700 int = NULL
,
    @p701 nvarchar(50) = NULL
,
    @p702 uniqueidentifier = NULL

) as
begin
    declare @errcode    int
    declare @retcode    int
    declare @rowcount   int
    declare @error      int
    declare @rows_in_contents int
    declare @rows_inserted_into_contents int
    declare @publication_number smallint
    declare @gen_cur bigint
    declare @rows_in_tomb bit
    declare @rows_in_syncview int
    declare @marker uniqueidentifier
    
    set nocount on
    
    set @errcode= 0
    set @publication_number = 1
    
    if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end

    if @rows_tobe_inserted is NULL or @rows_tobe_inserted <=0
        return 0



    begin tran
    save tran batchinsertproc 

    exec @retcode = sys.sp_MSmerge_getgencur_public 26466000, @rows_tobe_inserted, @gen_cur output
    if @retcode<>0 or @@error<>0
        return 4



    select @rows_in_tomb = 0
    select @rows_in_tomb = 1 from (

         select @rowguid1 as rowguid
 union all 
         select @rowguid2 as rowguid
 union all 
         select @rowguid3 as rowguid
 union all 
         select @rowguid4 as rowguid
 union all 
         select @rowguid5 as rowguid
 union all 
         select @rowguid6 as rowguid
 union all 
         select @rowguid7 as rowguid
 union all 
         select @rowguid8 as rowguid
 union all 
         select @rowguid9 as rowguid
 union all 
         select @rowguid10 as rowguid
 union all 
         select @rowguid11 as rowguid
 union all 
         select @rowguid12 as rowguid
 union all 
         select @rowguid13 as rowguid
 union all 
         select @rowguid14 as rowguid
 union all 
         select @rowguid15 as rowguid
 union all 
         select @rowguid16 as rowguid
 union all 
         select @rowguid17 as rowguid
 union all 
         select @rowguid18 as rowguid
 union all 
         select @rowguid19 as rowguid
 union all 
         select @rowguid20 as rowguid
 union all 
         select @rowguid21 as rowguid
 union all 
         select @rowguid22 as rowguid
 union all 
         select @rowguid23 as rowguid
 union all 
         select @rowguid24 as rowguid
 union all 
         select @rowguid25 as rowguid
 union all 
         select @rowguid26 as rowguid
 union all 
         select @rowguid27 as rowguid
 union all 
         select @rowguid28 as rowguid
 union all 
         select @rowguid29 as rowguid
 union all 
         select @rowguid30 as rowguid
 union all 
         select @rowguid31 as rowguid
 union all 
         select @rowguid32 as rowguid
 union all 
         select @rowguid33 as rowguid
 union all 
         select @rowguid34 as rowguid
 union all 
         select @rowguid35 as rowguid
 union all 
         select @rowguid36 as rowguid
 union all 
         select @rowguid37 as rowguid
 union all 
         select @rowguid38 as rowguid
 union all 
         select @rowguid39 as rowguid
 union all 
         select @rowguid40 as rowguid
 union all 
         select @rowguid41 as rowguid
 union all 
         select @rowguid42 as rowguid
 union all 
         select @rowguid43 as rowguid
 union all 
         select @rowguid44 as rowguid
 union all 
         select @rowguid45 as rowguid
 union all 
         select @rowguid46 as rowguid
 union all 
         select @rowguid47 as rowguid
 union all 
         select @rowguid48 as rowguid
 union all 
         select @rowguid49 as rowguid
 union all 
         select @rowguid50 as rowguid
 union all 
         select @rowguid51 as rowguid
 union all 
         select @rowguid52 as rowguid
 union all 
         select @rowguid53 as rowguid
 union all 
         select @rowguid54 as rowguid
 union all 
         select @rowguid55 as rowguid
 union all 
         select @rowguid56 as rowguid
 union all 
         select @rowguid57 as rowguid
 union all 
         select @rowguid58 as rowguid
 union all 
         select @rowguid59 as rowguid
 union all 
         select @rowguid60 as rowguid
 union all 
         select @rowguid61 as rowguid
 union all 
         select @rowguid62 as rowguid
 union all 
         select @rowguid63 as rowguid
 union all 
         select @rowguid64 as rowguid
 union all 
         select @rowguid65 as rowguid
 union all 
         select @rowguid66 as rowguid
 union all 
         select @rowguid67 as rowguid
 union all 
         select @rowguid68 as rowguid
 union all 
         select @rowguid69 as rowguid
 union all 
         select @rowguid70 as rowguid
 union all 
         select @rowguid71 as rowguid
 union all 
         select @rowguid72 as rowguid
 union all 
         select @rowguid73 as rowguid
 union all 
         select @rowguid74 as rowguid
 union all 
         select @rowguid75 as rowguid
 union all 
         select @rowguid76 as rowguid
 union all 
         select @rowguid77 as rowguid
 union all 
         select @rowguid78 as rowguid

    ) as rows
    inner join dbo.MSmerge_tombstone tomb with (rowlock) 
    on tomb.rowguid = rows.rowguid
    and tomb.tablenick = 26466000
    and rows.rowguid is not NULL
        
    if @rows_in_tomb = 1
    begin
        raiserror(20692, 16, -1, 'Account')
        set @errcode=3
        goto Failure
    end

    
    select @marker = newid()
    insert into dbo.MSmerge_contents with (rowlock)
    (rowguid, tablenick, generation, partchangegen, lineage, colv1, marker)
    select rows.rowguid, 26466000, rows.generation, (-rows.generation), rows.lineage, rows.colv, @marker
    from (

    select @rowguid1 as rowguid, @generation1 as generation, @lineage1 as lineage, @colv1 as colv union all
    select @rowguid2 as rowguid, @generation2 as generation, @lineage2 as lineage, @colv2 as colv union all
    select @rowguid3 as rowguid, @generation3 as generation, @lineage3 as lineage, @colv3 as colv union all
    select @rowguid4 as rowguid, @generation4 as generation, @lineage4 as lineage, @colv4 as colv union all
    select @rowguid5 as rowguid, @generation5 as generation, @lineage5 as lineage, @colv5 as colv union all
    select @rowguid6 as rowguid, @generation6 as generation, @lineage6 as lineage, @colv6 as colv union all
    select @rowguid7 as rowguid, @generation7 as generation, @lineage7 as lineage, @colv7 as colv union all
    select @rowguid8 as rowguid, @generation8 as generation, @lineage8 as lineage, @colv8 as colv union all
    select @rowguid9 as rowguid, @generation9 as generation, @lineage9 as lineage, @colv9 as colv union all
    select @rowguid10 as rowguid, @generation10 as generation, @lineage10 as lineage, @colv10 as colv union all
    select @rowguid11 as rowguid, @generation11 as generation, @lineage11 as lineage, @colv11 as colv union all
    select @rowguid12 as rowguid, @generation12 as generation, @lineage12 as lineage, @colv12 as colv union all
    select @rowguid13 as rowguid, @generation13 as generation, @lineage13 as lineage, @colv13 as colv union all
    select @rowguid14 as rowguid, @generation14 as generation, @lineage14 as lineage, @colv14 as colv union all
    select @rowguid15 as rowguid, @generation15 as generation, @lineage15 as lineage, @colv15 as colv union all
    select @rowguid16 as rowguid, @generation16 as generation, @lineage16 as lineage, @colv16 as colv union all
    select @rowguid17 as rowguid, @generation17 as generation, @lineage17 as lineage, @colv17 as colv union all
    select @rowguid18 as rowguid, @generation18 as generation, @lineage18 as lineage, @colv18 as colv union all
    select @rowguid19 as rowguid, @generation19 as generation, @lineage19 as lineage, @colv19 as colv union all
    select @rowguid20 as rowguid, @generation20 as generation, @lineage20 as lineage, @colv20 as colv union all
    select @rowguid21 as rowguid, @generation21 as generation, @lineage21 as lineage, @colv21 as colv union all
    select @rowguid22 as rowguid, @generation22 as generation, @lineage22 as lineage, @colv22 as colv union all
    select @rowguid23 as rowguid, @generation23 as generation, @lineage23 as lineage, @colv23 as colv union all
    select @rowguid24 as rowguid, @generation24 as generation, @lineage24 as lineage, @colv24 as colv union all
    select @rowguid25 as rowguid, @generation25 as generation, @lineage25 as lineage, @colv25 as colv union all
    select @rowguid26 as rowguid, @generation26 as generation, @lineage26 as lineage, @colv26 as colv union all
    select @rowguid27 as rowguid, @generation27 as generation, @lineage27 as lineage, @colv27 as colv union all
    select @rowguid28 as rowguid, @generation28 as generation, @lineage28 as lineage, @colv28 as colv union all
    select @rowguid29 as rowguid, @generation29 as generation, @lineage29 as lineage, @colv29 as colv union all
    select @rowguid30 as rowguid, @generation30 as generation, @lineage30 as lineage, @colv30 as colv union all
    select @rowguid31 as rowguid, @generation31 as generation, @lineage31 as lineage, @colv31 as colv union all
    select @rowguid32 as rowguid, @generation32 as generation, @lineage32 as lineage, @colv32 as colv union all
    select @rowguid33 as rowguid, @generation33 as generation, @lineage33 as lineage, @colv33 as colv union all
    select @rowguid34 as rowguid, @generation34 as generation, @lineage34 as lineage, @colv34 as colv
 union all
    select @rowguid35 as rowguid, @generation35 as generation, @lineage35 as lineage, @colv35 as colv union all
    select @rowguid36 as rowguid, @generation36 as generation, @lineage36 as lineage, @colv36 as colv union all
    select @rowguid37 as rowguid, @generation37 as generation, @lineage37 as lineage, @colv37 as colv union all
    select @rowguid38 as rowguid, @generation38 as generation, @lineage38 as lineage, @colv38 as colv union all
    select @rowguid39 as rowguid, @generation39 as generation, @lineage39 as lineage, @colv39 as colv union all
    select @rowguid40 as rowguid, @generation40 as generation, @lineage40 as lineage, @colv40 as colv union all
    select @rowguid41 as rowguid, @generation41 as generation, @lineage41 as lineage, @colv41 as colv union all
    select @rowguid42 as rowguid, @generation42 as generation, @lineage42 as lineage, @colv42 as colv union all
    select @rowguid43 as rowguid, @generation43 as generation, @lineage43 as lineage, @colv43 as colv union all
    select @rowguid44 as rowguid, @generation44 as generation, @lineage44 as lineage, @colv44 as colv union all
    select @rowguid45 as rowguid, @generation45 as generation, @lineage45 as lineage, @colv45 as colv union all
    select @rowguid46 as rowguid, @generation46 as generation, @lineage46 as lineage, @colv46 as colv union all
    select @rowguid47 as rowguid, @generation47 as generation, @lineage47 as lineage, @colv47 as colv union all
    select @rowguid48 as rowguid, @generation48 as generation, @lineage48 as lineage, @colv48 as colv union all
    select @rowguid49 as rowguid, @generation49 as generation, @lineage49 as lineage, @colv49 as colv union all
    select @rowguid50 as rowguid, @generation50 as generation, @lineage50 as lineage, @colv50 as colv union all
    select @rowguid51 as rowguid, @generation51 as generation, @lineage51 as lineage, @colv51 as colv union all
    select @rowguid52 as rowguid, @generation52 as generation, @lineage52 as lineage, @colv52 as colv union all
    select @rowguid53 as rowguid, @generation53 as generation, @lineage53 as lineage, @colv53 as colv union all
    select @rowguid54 as rowguid, @generation54 as generation, @lineage54 as lineage, @colv54 as colv union all
    select @rowguid55 as rowguid, @generation55 as generation, @lineage55 as lineage, @colv55 as colv union all
    select @rowguid56 as rowguid, @generation56 as generation, @lineage56 as lineage, @colv56 as colv union all
    select @rowguid57 as rowguid, @generation57 as generation, @lineage57 as lineage, @colv57 as colv union all
    select @rowguid58 as rowguid, @generation58 as generation, @lineage58 as lineage, @colv58 as colv union all
    select @rowguid59 as rowguid, @generation59 as generation, @lineage59 as lineage, @colv59 as colv union all
    select @rowguid60 as rowguid, @generation60 as generation, @lineage60 as lineage, @colv60 as colv union all
    select @rowguid61 as rowguid, @generation61 as generation, @lineage61 as lineage, @colv61 as colv union all
    select @rowguid62 as rowguid, @generation62 as generation, @lineage62 as lineage, @colv62 as colv union all
    select @rowguid63 as rowguid, @generation63 as generation, @lineage63 as lineage, @colv63 as colv union all
    select @rowguid64 as rowguid, @generation64 as generation, @lineage64 as lineage, @colv64 as colv union all
    select @rowguid65 as rowguid, @generation65 as generation, @lineage65 as lineage, @colv65 as colv union all
    select @rowguid66 as rowguid, @generation66 as generation, @lineage66 as lineage, @colv66 as colv union all
    select @rowguid67 as rowguid, @generation67 as generation, @lineage67 as lineage, @colv67 as colv union all
    select @rowguid68 as rowguid, @generation68 as generation, @lineage68 as lineage, @colv68 as colv
 union all
    select @rowguid69 as rowguid, @generation69 as generation, @lineage69 as lineage, @colv69 as colv union all
    select @rowguid70 as rowguid, @generation70 as generation, @lineage70 as lineage, @colv70 as colv union all
    select @rowguid71 as rowguid, @generation71 as generation, @lineage71 as lineage, @colv71 as colv union all
    select @rowguid72 as rowguid, @generation72 as generation, @lineage72 as lineage, @colv72 as colv union all
    select @rowguid73 as rowguid, @generation73 as generation, @lineage73 as lineage, @colv73 as colv union all
    select @rowguid74 as rowguid, @generation74 as generation, @lineage74 as lineage, @colv74 as colv union all
    select @rowguid75 as rowguid, @generation75 as generation, @lineage75 as lineage, @colv75 as colv union all
    select @rowguid76 as rowguid, @generation76 as generation, @lineage76 as lineage, @colv76 as colv union all
    select @rowguid77 as rowguid, @generation77 as generation, @lineage77 as lineage, @colv77 as colv union all
    select @rowguid78 as rowguid, @generation78 as generation, @lineage78 as lineage, @colv78 as colv

    ) as rows
    where rows.rowguid is not NULL 

    select @rows_inserted_into_contents = @@rowcount, @error = @@error
    if @error<>0
    begin
        set @errcode=3
        goto Failure
    end

    if (@rows_inserted_into_contents <> @rows_tobe_inserted)
    begin
        raiserror(20693, 16, -1, 'Account')
        set @errcode=4
        goto Failure
    end

    insert into [dbo].[Account] with (rowlock) (
[AccountID]
, 
        [Customer]
, 
        [StartDate]
, 
        [EndDate]
, 
        [Interest]
, 
        [Period]
, 
        [Balance]
, 
        [Branch]
, 
        [rowguid]
)
    select 
c1
, 
        c2
, 
        c3
, 
        c4
, 
        c5
, 
        c6
, 
        c7
, 
        c8
, 
        rowguid

    from (

    select @p1 as c1, @p2 as c2, @p3 as c3, @p4 as c4, @p5 as c5, @p6 as c6, @p7 as c7, @p8 as c8, @p9 as rowguid union all
    select @p10 as c1, @p11 as c2, @p12 as c3, @p13 as c4, @p14 as c5, @p15 as c6, @p16 as c7, @p17 as c8, @p18 as rowguid union all
    select @p19 as c1, @p20 as c2, @p21 as c3, @p22 as c4, @p23 as c5, @p24 as c6, @p25 as c7, @p26 as c8, @p27 as rowguid union all
    select @p28 as c1, @p29 as c2, @p30 as c3, @p31 as c4, @p32 as c5, @p33 as c6, @p34 as c7, @p35 as c8, @p36 as rowguid union all
    select @p37 as c1, @p38 as c2, @p39 as c3, @p40 as c4, @p41 as c5, @p42 as c6, @p43 as c7, @p44 as c8, @p45 as rowguid union all
    select @p46 as c1, @p47 as c2, @p48 as c3, @p49 as c4, @p50 as c5, @p51 as c6, @p52 as c7, @p53 as c8, @p54 as rowguid union all
    select @p55 as c1, @p56 as c2, @p57 as c3, @p58 as c4, @p59 as c5, @p60 as c6, @p61 as c7, @p62 as c8, @p63 as rowguid union all
    select @p64 as c1, @p65 as c2, @p66 as c3, @p67 as c4, @p68 as c5, @p69 as c6, @p70 as c7, @p71 as c8, @p72 as rowguid union all
    select @p73 as c1, @p74 as c2, @p75 as c3, @p76 as c4, @p77 as c5, @p78 as c6, @p79 as c7, @p80 as c8, @p81 as rowguid union all
    select @p82 as c1, @p83 as c2, @p84 as c3, @p85 as c4, @p86 as c5, @p87 as c6, @p88 as c7, @p89 as c8, @p90 as rowguid union all
    select @p91 as c1, @p92 as c2, @p93 as c3, @p94 as c4, @p95 as c5, @p96 as c6, @p97 as c7, @p98 as c8, @p99 as rowguid union all
    select @p100 as c1, @p101 as c2, @p102 as c3, @p103 as c4, @p104 as c5, @p105 as c6, @p106 as c7, @p107 as c8, @p108 as rowguid union all
    select @p109 as c1, @p110 as c2, @p111 as c3, @p112 as c4, @p113 as c5, @p114 as c6, @p115 as c7, @p116 as c8, @p117 as rowguid union all
    select @p118 as c1, @p119 as c2, @p120 as c3, @p121 as c4, @p122 as c5, @p123 as c6, @p124 as c7, @p125 as c8, @p126 as rowguid union all
    select @p127 as c1, @p128 as c2, @p129 as c3, @p130 as c4, @p131 as c5, @p132 as c6, @p133 as c7, @p134 as c8, @p135 as rowguid union all
    select @p136 as c1, @p137 as c2, @p138 as c3, @p139 as c4, @p140 as c5, @p141 as c6, @p142 as c7, @p143 as c8, @p144 as rowguid union all
    select @p145 as c1, @p146 as c2, @p147 as c3, @p148 as c4, @p149 as c5, @p150 as c6, @p151 as c7, @p152 as c8, @p153 as rowguid union all
    select @p154 as c1, @p155 as c2, @p156 as c3, @p157 as c4, @p158 as c5, @p159 as c6, @p160 as c7, @p161 as c8, @p162 as rowguid union all
    select @p163 as c1, @p164 as c2, @p165 as c3, @p166 as c4, @p167 as c5, @p168 as c6, @p169 as c7, @p170 as c8, @p171 as rowguid union all
    select @p172 as c1, @p173 as c2, @p174 as c3, @p175 as c4, @p176 as c5, @p177 as c6, @p178 as c7, @p179 as c8, @p180 as rowguid union all
    select @p181 as c1, @p182 as c2, @p183 as c3, @p184 as c4, @p185 as c5, @p186 as c6, @p187 as c7, @p188 as c8, @p189 as rowguid union all
    select @p190 as c1, @p191 as c2, @p192 as c3, @p193 as c4, @p194 as c5, @p195 as c6, @p196 as c7, @p197 as c8, @p198 as rowguid union all
    select @p199 as c1, @p200 as c2, @p201 as c3, @p202 as c4, @p203 as c5, @p204 as c6, @p205 as c7, @p206 as c8, @p207 as rowguid union all
    select @p208 as c1, @p209 as c2, @p210 as c3, @p211 as c4, @p212 as c5, @p213 as c6, @p214 as c7, @p215 as c8, @p216 as rowguid union all
    select @p217 as c1, @p218 as c2, @p219 as c3, @p220 as c4, @p221 as c5, @p222 as c6, @p223 as c7, @p224 as c8, @p225 as rowguid union all
    select @p226 as c1, @p227 as c2, @p228 as c3, @p229 as c4, @p230 as c5, @p231 as c6, @p232 as c7, @p233 as c8, @p234 as rowguid union all
    select @p235 as c1, @p236 as c2, @p237 as c3, @p238 as c4, @p239 as c5, @p240 as c6, @p241 as c7, @p242 as c8, @p243 as rowguid union all
    select @p244 as c1
, @p245 as c2, @p246 as c3, @p247 as c4, @p248 as c5, @p249 as c6, @p250 as c7, @p251 as c8, @p252 as rowguid union all
    select @p253 as c1, @p254 as c2, @p255 as c3, @p256 as c4, @p257 as c5, @p258 as c6, @p259 as c7, @p260 as c8, @p261 as rowguid union all
    select @p262 as c1, @p263 as c2, @p264 as c3, @p265 as c4, @p266 as c5, @p267 as c6, @p268 as c7, @p269 as c8, @p270 as rowguid union all
    select @p271 as c1, @p272 as c2, @p273 as c3, @p274 as c4, @p275 as c5, @p276 as c6, @p277 as c7, @p278 as c8, @p279 as rowguid union all
    select @p280 as c1, @p281 as c2, @p282 as c3, @p283 as c4, @p284 as c5, @p285 as c6, @p286 as c7, @p287 as c8, @p288 as rowguid union all
    select @p289 as c1, @p290 as c2, @p291 as c3, @p292 as c4, @p293 as c5, @p294 as c6, @p295 as c7, @p296 as c8, @p297 as rowguid union all
    select @p298 as c1, @p299 as c2, @p300 as c3, @p301 as c4, @p302 as c5, @p303 as c6, @p304 as c7, @p305 as c8, @p306 as rowguid union all
    select @p307 as c1, @p308 as c2, @p309 as c3, @p310 as c4, @p311 as c5, @p312 as c6, @p313 as c7, @p314 as c8, @p315 as rowguid union all
    select @p316 as c1, @p317 as c2, @p318 as c3, @p319 as c4, @p320 as c5, @p321 as c6, @p322 as c7, @p323 as c8, @p324 as rowguid union all
    select @p325 as c1, @p326 as c2, @p327 as c3, @p328 as c4, @p329 as c5, @p330 as c6, @p331 as c7, @p332 as c8, @p333 as rowguid union all
    select @p334 as c1, @p335 as c2, @p336 as c3, @p337 as c4, @p338 as c5, @p339 as c6, @p340 as c7, @p341 as c8, @p342 as rowguid union all
    select @p343 as c1, @p344 as c2, @p345 as c3, @p346 as c4, @p347 as c5, @p348 as c6, @p349 as c7, @p350 as c8, @p351 as rowguid union all
    select @p352 as c1, @p353 as c2, @p354 as c3, @p355 as c4, @p356 as c5, @p357 as c6, @p358 as c7, @p359 as c8, @p360 as rowguid union all
    select @p361 as c1, @p362 as c2, @p363 as c3, @p364 as c4, @p365 as c5, @p366 as c6, @p367 as c7, @p368 as c8, @p369 as rowguid union all
    select @p370 as c1, @p371 as c2, @p372 as c3, @p373 as c4, @p374 as c5, @p375 as c6, @p376 as c7, @p377 as c8, @p378 as rowguid union all
    select @p379 as c1, @p380 as c2, @p381 as c3, @p382 as c4, @p383 as c5, @p384 as c6, @p385 as c7, @p386 as c8, @p387 as rowguid union all
    select @p388 as c1, @p389 as c2, @p390 as c3, @p391 as c4, @p392 as c5, @p393 as c6, @p394 as c7, @p395 as c8, @p396 as rowguid union all
    select @p397 as c1, @p398 as c2, @p399 as c3, @p400 as c4, @p401 as c5, @p402 as c6, @p403 as c7, @p404 as c8, @p405 as rowguid union all
    select @p406 as c1, @p407 as c2, @p408 as c3, @p409 as c4, @p410 as c5, @p411 as c6, @p412 as c7, @p413 as c8, @p414 as rowguid union all
    select @p415 as c1, @p416 as c2, @p417 as c3, @p418 as c4, @p419 as c5, @p420 as c6, @p421 as c7, @p422 as c8, @p423 as rowguid union all
    select @p424 as c1, @p425 as c2, @p426 as c3, @p427 as c4, @p428 as c5, @p429 as c6, @p430 as c7, @p431 as c8, @p432 as rowguid union all
    select @p433 as c1, @p434 as c2, @p435 as c3, @p436 as c4, @p437 as c5, @p438 as c6, @p439 as c7, @p440 as c8, @p441 as rowguid union all
    select @p442 as c1, @p443 as c2, @p444 as c3, @p445 as c4, @p446 as c5, @p447 as c6, @p448 as c7, @p449 as c8, @p450 as rowguid union all
    select @p451 as c1, @p452 as c2, @p453 as c3, @p454 as c4, @p455 as c5, @p456 as c6, @p457 as c7, @p458 as c8, @p459 as rowguid union all
    select @p460 as c1, @p461 as c2, @p462 as c3, @p463 as c4, @p464 as c5, @p465 as c6, @p466 as c7, @p467 as c8, @p468 as rowguid union all
    select @p469 as c1, @p470 as c2, @p471 as c3, @p472 as c4, @p473 as c5, @p474 as c6, @p475 as c7, @p476 as c8, @p477 as rowguid union all
    select @p478 as c1, @p479 as c2, @p480 as c3, @p481 as c4
, @p482 as c5, @p483 as c6, @p484 as c7, @p485 as c8, @p486 as rowguid union all
    select @p487 as c1, @p488 as c2, @p489 as c3, @p490 as c4, @p491 as c5, @p492 as c6, @p493 as c7, @p494 as c8, @p495 as rowguid union all
    select @p496 as c1, @p497 as c2, @p498 as c3, @p499 as c4, @p500 as c5, @p501 as c6, @p502 as c7, @p503 as c8, @p504 as rowguid union all
    select @p505 as c1, @p506 as c2, @p507 as c3, @p508 as c4, @p509 as c5, @p510 as c6, @p511 as c7, @p512 as c8, @p513 as rowguid union all
    select @p514 as c1, @p515 as c2, @p516 as c3, @p517 as c4, @p518 as c5, @p519 as c6, @p520 as c7, @p521 as c8, @p522 as rowguid union all
    select @p523 as c1, @p524 as c2, @p525 as c3, @p526 as c4, @p527 as c5, @p528 as c6, @p529 as c7, @p530 as c8, @p531 as rowguid union all
    select @p532 as c1, @p533 as c2, @p534 as c3, @p535 as c4, @p536 as c5, @p537 as c6, @p538 as c7, @p539 as c8, @p540 as rowguid union all
    select @p541 as c1, @p542 as c2, @p543 as c3, @p544 as c4, @p545 as c5, @p546 as c6, @p547 as c7, @p548 as c8, @p549 as rowguid union all
    select @p550 as c1, @p551 as c2, @p552 as c3, @p553 as c4, @p554 as c5, @p555 as c6, @p556 as c7, @p557 as c8, @p558 as rowguid union all
    select @p559 as c1, @p560 as c2, @p561 as c3, @p562 as c4, @p563 as c5, @p564 as c6, @p565 as c7, @p566 as c8, @p567 as rowguid union all
    select @p568 as c1, @p569 as c2, @p570 as c3, @p571 as c4, @p572 as c5, @p573 as c6, @p574 as c7, @p575 as c8, @p576 as rowguid union all
    select @p577 as c1, @p578 as c2, @p579 as c3, @p580 as c4, @p581 as c5, @p582 as c6, @p583 as c7, @p584 as c8, @p585 as rowguid union all
    select @p586 as c1, @p587 as c2, @p588 as c3, @p589 as c4, @p590 as c5, @p591 as c6, @p592 as c7, @p593 as c8, @p594 as rowguid union all
    select @p595 as c1, @p596 as c2, @p597 as c3, @p598 as c4, @p599 as c5, @p600 as c6, @p601 as c7, @p602 as c8, @p603 as rowguid union all
    select @p604 as c1, @p605 as c2, @p606 as c3, @p607 as c4, @p608 as c5, @p609 as c6, @p610 as c7, @p611 as c8, @p612 as rowguid union all
    select @p613 as c1, @p614 as c2, @p615 as c3, @p616 as c4, @p617 as c5, @p618 as c6, @p619 as c7, @p620 as c8, @p621 as rowguid union all
    select @p622 as c1, @p623 as c2, @p624 as c3, @p625 as c4, @p626 as c5, @p627 as c6, @p628 as c7, @p629 as c8, @p630 as rowguid union all
    select @p631 as c1, @p632 as c2, @p633 as c3, @p634 as c4, @p635 as c5, @p636 as c6, @p637 as c7, @p638 as c8, @p639 as rowguid union all
    select @p640 as c1, @p641 as c2, @p642 as c3, @p643 as c4, @p644 as c5, @p645 as c6, @p646 as c7, @p647 as c8, @p648 as rowguid union all
    select @p649 as c1, @p650 as c2, @p651 as c3, @p652 as c4, @p653 as c5, @p654 as c6, @p655 as c7, @p656 as c8, @p657 as rowguid union all
    select @p658 as c1, @p659 as c2, @p660 as c3, @p661 as c4, @p662 as c5, @p663 as c6, @p664 as c7, @p665 as c8, @p666 as rowguid union all
    select @p667 as c1, @p668 as c2, @p669 as c3, @p670 as c4, @p671 as c5, @p672 as c6, @p673 as c7, @p674 as c8, @p675 as rowguid union all
    select @p676 as c1, @p677 as c2, @p678 as c3, @p679 as c4, @p680 as c5, @p681 as c6, @p682 as c7, @p683 as c8, @p684 as rowguid union all
    select @p685 as c1, @p686 as c2, @p687 as c3, @p688 as c4, @p689 as c5, @p690 as c6, @p691 as c7, @p692 as c8, @p693 as rowguid union all
    select @p694 as c1
, @p695 as c2
, @p696 as c3
, @p697 as c4
, @p698 as c5
, @p699 as c6
, @p700 as c7
, @p701 as c8
, @p702 as rowguid

    ) as rows
    where rows.rowguid is not NULL
    select @rowcount = @@rowcount, @error = @@error

    if (@rowcount <> @rows_tobe_inserted) or (@error <> 0)
    begin
        set @errcode= 3
        goto Failure
    end


    exec @retcode = sys.sp_MSdeletemetadataactionrequest '9DEE015E-1388-43B6-BDF0-8C2967FBB918', 26466000, 
        @rowguid1, 
        @rowguid2, 
        @rowguid3, 
        @rowguid4, 
        @rowguid5, 
        @rowguid6, 
        @rowguid7, 
        @rowguid8, 
        @rowguid9, 
        @rowguid10, 
        @rowguid11, 
        @rowguid12, 
        @rowguid13, 
        @rowguid14, 
        @rowguid15, 
        @rowguid16, 
        @rowguid17, 
        @rowguid18, 
        @rowguid19, 
        @rowguid20, 
        @rowguid21, 
        @rowguid22, 
        @rowguid23, 
        @rowguid24, 
        @rowguid25, 
        @rowguid26, 
        @rowguid27, 
        @rowguid28, 
        @rowguid29, 
        @rowguid30, 
        @rowguid31, 
        @rowguid32, 
        @rowguid33, 
        @rowguid34, 
        @rowguid35, 
        @rowguid36, 
        @rowguid37, 
        @rowguid38, 
        @rowguid39, 
        @rowguid40, 
        @rowguid41, 
        @rowguid42, 
        @rowguid43, 
        @rowguid44, 
        @rowguid45, 
        @rowguid46, 
        @rowguid47, 
        @rowguid48, 
        @rowguid49, 
        @rowguid50, 
        @rowguid51, 
        @rowguid52, 
        @rowguid53, 
        @rowguid54, 
        @rowguid55, 
        @rowguid56, 
        @rowguid57, 
        @rowguid58, 
        @rowguid59, 
        @rowguid60, 
        @rowguid61, 
        @rowguid62, 
        @rowguid63, 
        @rowguid64, 
        @rowguid65, 
        @rowguid66, 
        @rowguid67, 
        @rowguid68, 
        @rowguid69, 
        @rowguid70, 
        @rowguid71, 
        @rowguid72, 
        @rowguid73, 
        @rowguid74, 
        @rowguid75, 
        @rowguid76, 
        @rowguid77, 
        @rowguid78
    if @retcode<>0 or @@error<>0
        goto Failure
    

    commit tran
    return 1

Failure:
    rollback tran batchinsertproc
    commit tran
    return 0
end


go
create procedure dbo.[MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6_batch] (
        @rows_tobe_updated int,
        @partition_id int = null 
,
    @rowguid1 uniqueidentifier = NULL,
    @setbm1 varbinary(125) = NULL,
    @metadata_type1 tinyint = NULL,
    @lineage_old1 varbinary(311) = NULL,
    @generation1 bigint = NULL,
    @lineage_new1 varbinary(311) = NULL,
    @colv1 varbinary(1) = NULL,
    @p1 nvarchar(50) = NULL,
    @p2 nvarchar(50) = NULL,
    @p3 date = NULL,
    @p4 date = NULL,
    @p5 float = NULL,
    @p6 int = NULL,
    @p7 int = NULL,
    @p8 nvarchar(50) = NULL,
    @p9 uniqueidentifier = NULL,
    @rowguid2 uniqueidentifier = NULL,
    @setbm2 varbinary(125) = NULL,
    @metadata_type2 tinyint = NULL,
    @lineage_old2 varbinary(311) = NULL,
    @generation2 bigint = NULL,
    @lineage_new2 varbinary(311) = NULL,
    @colv2 varbinary(1) = NULL,
    @p10 nvarchar(50) = NULL,
    @p11 nvarchar(50) = NULL,
    @p12 date = NULL,
    @p13 date = NULL,
    @p14 float = NULL,
    @p15 int = NULL,
    @p16 int = NULL,
    @p17 nvarchar(50) = NULL,
    @p18 uniqueidentifier = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @setbm3 varbinary(125) = NULL,
    @metadata_type3 tinyint = NULL,
    @lineage_old3 varbinary(311) = NULL,
    @generation3 bigint = NULL,
    @lineage_new3 varbinary(311) = NULL,
    @colv3 varbinary(1) = NULL,
    @p19 nvarchar(50) = NULL,
    @p20 nvarchar(50) = NULL,
    @p21 date = NULL,
    @p22 date = NULL,
    @p23 float = NULL,
    @p24 int = NULL,
    @p25 int = NULL,
    @p26 nvarchar(50) = NULL,
    @p27 uniqueidentifier = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @setbm4 varbinary(125) = NULL,
    @metadata_type4 tinyint = NULL,
    @lineage_old4 varbinary(311) = NULL,
    @generation4 bigint = NULL,
    @lineage_new4 varbinary(311) = NULL,
    @colv4 varbinary(1) = NULL,
    @p28 nvarchar(50) = NULL,
    @p29 nvarchar(50) = NULL,
    @p30 date = NULL,
    @p31 date = NULL,
    @p32 float = NULL,
    @p33 int = NULL,
    @p34 int = NULL,
    @p35 nvarchar(50) = NULL,
    @p36 uniqueidentifier = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @setbm5 varbinary(125) = NULL,
    @metadata_type5 tinyint = NULL,
    @lineage_old5 varbinary(311) = NULL,
    @generation5 bigint = NULL,
    @lineage_new5 varbinary(311) = NULL,
    @colv5 varbinary(1) = NULL,
    @p37 nvarchar(50) = NULL,
    @p38 nvarchar(50) = NULL,
    @p39 date = NULL,
    @p40 date = NULL,
    @p41 float = NULL,
    @p42 int = NULL,
    @p43 int = NULL,
    @p44 nvarchar(50) = NULL,
    @p45 uniqueidentifier = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @setbm6 varbinary(125) = NULL,
    @metadata_type6 tinyint = NULL,
    @lineage_old6 varbinary(311) = NULL,
    @generation6 bigint = NULL,
    @lineage_new6 varbinary(311) = NULL,
    @colv6 varbinary(1) = NULL,
    @p46 nvarchar(50) = NULL,
    @p47 nvarchar(50) = NULL,
    @p48 date = NULL,
    @p49 date = NULL,
    @p50 float = NULL,
    @p51 int = NULL,
    @p52 int = NULL,
    @p53 nvarchar(50) = NULL,
    @p54 uniqueidentifier = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @setbm7 varbinary(125) = NULL,
    @metadata_type7 tinyint = NULL,
    @lineage_old7 varbinary(311) = NULL,
    @generation7 bigint = NULL,
    @lineage_new7 varbinary(311) = NULL,
    @colv7 varbinary(1) = NULL,
    @p55 nvarchar(50) = NULL,
    @p56 nvarchar(50) = NULL,
    @p57 date = NULL,
    @p58 date = NULL,
    @p59 float = NULL,
    @p60 int = NULL,
    @p61 int = NULL,
    @p62 nvarchar(50) = NULL,
    @p63 uniqueidentifier = NULL
,
    @rowguid8 uniqueidentifier = NULL,
    @setbm8 varbinary(125) = NULL,
    @metadata_type8 tinyint = NULL,
    @lineage_old8 varbinary(311) = NULL,
    @generation8 bigint = NULL,
    @lineage_new8 varbinary(311) = NULL,
    @colv8 varbinary(1) = NULL,
    @p64 nvarchar(50) = NULL,
    @p65 nvarchar(50) = NULL,
    @p66 date = NULL,
    @p67 date = NULL,
    @p68 float = NULL,
    @p69 int = NULL,
    @p70 int = NULL,
    @p71 nvarchar(50) = NULL,
    @p72 uniqueidentifier = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @setbm9 varbinary(125) = NULL,
    @metadata_type9 tinyint = NULL,
    @lineage_old9 varbinary(311) = NULL,
    @generation9 bigint = NULL,
    @lineage_new9 varbinary(311) = NULL,
    @colv9 varbinary(1) = NULL,
    @p73 nvarchar(50) = NULL,
    @p74 nvarchar(50) = NULL,
    @p75 date = NULL,
    @p76 date = NULL,
    @p77 float = NULL,
    @p78 int = NULL,
    @p79 int = NULL,
    @p80 nvarchar(50) = NULL,
    @p81 uniqueidentifier = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @setbm10 varbinary(125) = NULL,
    @metadata_type10 tinyint = NULL,
    @lineage_old10 varbinary(311) = NULL,
    @generation10 bigint = NULL,
    @lineage_new10 varbinary(311) = NULL,
    @colv10 varbinary(1) = NULL,
    @p82 nvarchar(50) = NULL,
    @p83 nvarchar(50) = NULL,
    @p84 date = NULL,
    @p85 date = NULL,
    @p86 float = NULL,
    @p87 int = NULL,
    @p88 int = NULL,
    @p89 nvarchar(50) = NULL,
    @p90 uniqueidentifier = NULL,
    @rowguid11 uniqueidentifier = NULL,
    @setbm11 varbinary(125) = NULL,
    @metadata_type11 tinyint = NULL,
    @lineage_old11 varbinary(311) = NULL,
    @generation11 bigint = NULL,
    @lineage_new11 varbinary(311) = NULL,
    @colv11 varbinary(1) = NULL,
    @p91 nvarchar(50) = NULL,
    @p92 nvarchar(50) = NULL,
    @p93 date = NULL,
    @p94 date = NULL,
    @p95 float = NULL,
    @p96 int = NULL,
    @p97 int = NULL,
    @p98 nvarchar(50) = NULL,
    @p99 uniqueidentifier = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @setbm12 varbinary(125) = NULL,
    @metadata_type12 tinyint = NULL,
    @lineage_old12 varbinary(311) = NULL,
    @generation12 bigint = NULL,
    @lineage_new12 varbinary(311) = NULL,
    @colv12 varbinary(1) = NULL,
    @p100 nvarchar(50) = NULL,
    @p101 nvarchar(50) = NULL,
    @p102 date = NULL,
    @p103 date = NULL,
    @p104 float = NULL,
    @p105 int = NULL,
    @p106 int = NULL,
    @p107 nvarchar(50) = NULL,
    @p108 uniqueidentifier = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @setbm13 varbinary(125) = NULL,
    @metadata_type13 tinyint = NULL,
    @lineage_old13 varbinary(311) = NULL,
    @generation13 bigint = NULL,
    @lineage_new13 varbinary(311) = NULL,
    @colv13 varbinary(1) = NULL,
    @p109 nvarchar(50) = NULL,
    @p110 nvarchar(50) = NULL,
    @p111 date = NULL,
    @p112 date = NULL,
    @p113 float = NULL,
    @p114 int = NULL,
    @p115 int = NULL,
    @p116 nvarchar(50) = NULL,
    @p117 uniqueidentifier = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @setbm14 varbinary(125) = NULL,
    @metadata_type14 tinyint = NULL,
    @lineage_old14 varbinary(311) = NULL,
    @generation14 bigint = NULL,
    @lineage_new14 varbinary(311) = NULL,
    @colv14 varbinary(1) = NULL,
    @p118 nvarchar(50) = NULL,
    @p119 nvarchar(50) = NULL,
    @p120 date = NULL,
    @p121 date = NULL,
    @p122 float = NULL,
    @p123 int = NULL
,
    @p124 int = NULL,
    @p125 nvarchar(50) = NULL,
    @p126 uniqueidentifier = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @setbm15 varbinary(125) = NULL,
    @metadata_type15 tinyint = NULL,
    @lineage_old15 varbinary(311) = NULL,
    @generation15 bigint = NULL,
    @lineage_new15 varbinary(311) = NULL,
    @colv15 varbinary(1) = NULL,
    @p127 nvarchar(50) = NULL,
    @p128 nvarchar(50) = NULL,
    @p129 date = NULL,
    @p130 date = NULL,
    @p131 float = NULL,
    @p132 int = NULL,
    @p133 int = NULL,
    @p134 nvarchar(50) = NULL,
    @p135 uniqueidentifier = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @setbm16 varbinary(125) = NULL,
    @metadata_type16 tinyint = NULL,
    @lineage_old16 varbinary(311) = NULL,
    @generation16 bigint = NULL,
    @lineage_new16 varbinary(311) = NULL,
    @colv16 varbinary(1) = NULL,
    @p136 nvarchar(50) = NULL,
    @p137 nvarchar(50) = NULL,
    @p138 date = NULL,
    @p139 date = NULL,
    @p140 float = NULL,
    @p141 int = NULL,
    @p142 int = NULL,
    @p143 nvarchar(50) = NULL,
    @p144 uniqueidentifier = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @setbm17 varbinary(125) = NULL,
    @metadata_type17 tinyint = NULL,
    @lineage_old17 varbinary(311) = NULL,
    @generation17 bigint = NULL,
    @lineage_new17 varbinary(311) = NULL,
    @colv17 varbinary(1) = NULL,
    @p145 nvarchar(50) = NULL,
    @p146 nvarchar(50) = NULL,
    @p147 date = NULL,
    @p148 date = NULL,
    @p149 float = NULL,
    @p150 int = NULL,
    @p151 int = NULL,
    @p152 nvarchar(50) = NULL,
    @p153 uniqueidentifier = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @setbm18 varbinary(125) = NULL,
    @metadata_type18 tinyint = NULL,
    @lineage_old18 varbinary(311) = NULL,
    @generation18 bigint = NULL,
    @lineage_new18 varbinary(311) = NULL,
    @colv18 varbinary(1) = NULL,
    @p154 nvarchar(50) = NULL,
    @p155 nvarchar(50) = NULL,
    @p156 date = NULL,
    @p157 date = NULL,
    @p158 float = NULL,
    @p159 int = NULL,
    @p160 int = NULL,
    @p161 nvarchar(50) = NULL,
    @p162 uniqueidentifier = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @setbm19 varbinary(125) = NULL,
    @metadata_type19 tinyint = NULL,
    @lineage_old19 varbinary(311) = NULL,
    @generation19 bigint = NULL,
    @lineage_new19 varbinary(311) = NULL,
    @colv19 varbinary(1) = NULL,
    @p163 nvarchar(50) = NULL,
    @p164 nvarchar(50) = NULL,
    @p165 date = NULL,
    @p166 date = NULL,
    @p167 float = NULL,
    @p168 int = NULL,
    @p169 int = NULL,
    @p170 nvarchar(50) = NULL,
    @p171 uniqueidentifier = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @setbm20 varbinary(125) = NULL,
    @metadata_type20 tinyint = NULL,
    @lineage_old20 varbinary(311) = NULL,
    @generation20 bigint = NULL,
    @lineage_new20 varbinary(311) = NULL,
    @colv20 varbinary(1) = NULL,
    @p172 nvarchar(50) = NULL,
    @p173 nvarchar(50) = NULL,
    @p174 date = NULL,
    @p175 date = NULL,
    @p176 float = NULL,
    @p177 int = NULL,
    @p178 int = NULL,
    @p179 nvarchar(50) = NULL,
    @p180 uniqueidentifier = NULL,
    @rowguid21 uniqueidentifier = NULL,
    @setbm21 varbinary(125) = NULL,
    @metadata_type21 tinyint = NULL,
    @lineage_old21 varbinary(311) = NULL,
    @generation21 bigint = NULL,
    @lineage_new21 varbinary(311) = NULL,
    @colv21 varbinary(1) = NULL,
    @p181 nvarchar(50) = NULL
,
    @p182 nvarchar(50) = NULL,
    @p183 date = NULL,
    @p184 date = NULL,
    @p185 float = NULL,
    @p186 int = NULL,
    @p187 int = NULL,
    @p188 nvarchar(50) = NULL,
    @p189 uniqueidentifier = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @setbm22 varbinary(125) = NULL,
    @metadata_type22 tinyint = NULL,
    @lineage_old22 varbinary(311) = NULL,
    @generation22 bigint = NULL,
    @lineage_new22 varbinary(311) = NULL,
    @colv22 varbinary(1) = NULL,
    @p190 nvarchar(50) = NULL,
    @p191 nvarchar(50) = NULL,
    @p192 date = NULL,
    @p193 date = NULL,
    @p194 float = NULL,
    @p195 int = NULL,
    @p196 int = NULL,
    @p197 nvarchar(50) = NULL,
    @p198 uniqueidentifier = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @setbm23 varbinary(125) = NULL,
    @metadata_type23 tinyint = NULL,
    @lineage_old23 varbinary(311) = NULL,
    @generation23 bigint = NULL,
    @lineage_new23 varbinary(311) = NULL,
    @colv23 varbinary(1) = NULL,
    @p199 nvarchar(50) = NULL,
    @p200 nvarchar(50) = NULL,
    @p201 date = NULL,
    @p202 date = NULL,
    @p203 float = NULL,
    @p204 int = NULL,
    @p205 int = NULL,
    @p206 nvarchar(50) = NULL,
    @p207 uniqueidentifier = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @setbm24 varbinary(125) = NULL,
    @metadata_type24 tinyint = NULL,
    @lineage_old24 varbinary(311) = NULL,
    @generation24 bigint = NULL,
    @lineage_new24 varbinary(311) = NULL,
    @colv24 varbinary(1) = NULL,
    @p208 nvarchar(50) = NULL,
    @p209 nvarchar(50) = NULL,
    @p210 date = NULL,
    @p211 date = NULL,
    @p212 float = NULL,
    @p213 int = NULL,
    @p214 int = NULL,
    @p215 nvarchar(50) = NULL,
    @p216 uniqueidentifier = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @setbm25 varbinary(125) = NULL,
    @metadata_type25 tinyint = NULL,
    @lineage_old25 varbinary(311) = NULL,
    @generation25 bigint = NULL,
    @lineage_new25 varbinary(311) = NULL,
    @colv25 varbinary(1) = NULL,
    @p217 nvarchar(50) = NULL,
    @p218 nvarchar(50) = NULL,
    @p219 date = NULL,
    @p220 date = NULL,
    @p221 float = NULL,
    @p222 int = NULL,
    @p223 int = NULL,
    @p224 nvarchar(50) = NULL,
    @p225 uniqueidentifier = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @setbm26 varbinary(125) = NULL,
    @metadata_type26 tinyint = NULL,
    @lineage_old26 varbinary(311) = NULL,
    @generation26 bigint = NULL,
    @lineage_new26 varbinary(311) = NULL,
    @colv26 varbinary(1) = NULL,
    @p226 nvarchar(50) = NULL,
    @p227 nvarchar(50) = NULL,
    @p228 date = NULL,
    @p229 date = NULL,
    @p230 float = NULL,
    @p231 int = NULL,
    @p232 int = NULL,
    @p233 nvarchar(50) = NULL,
    @p234 uniqueidentifier = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @setbm27 varbinary(125) = NULL,
    @metadata_type27 tinyint = NULL,
    @lineage_old27 varbinary(311) = NULL,
    @generation27 bigint = NULL,
    @lineage_new27 varbinary(311) = NULL,
    @colv27 varbinary(1) = NULL,
    @p235 nvarchar(50) = NULL,
    @p236 nvarchar(50) = NULL,
    @p237 date = NULL,
    @p238 date = NULL,
    @p239 float = NULL,
    @p240 int = NULL,
    @p241 int = NULL,
    @p242 nvarchar(50) = NULL,
    @p243 uniqueidentifier = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @setbm28 varbinary(125) = NULL,
    @metadata_type28 tinyint = NULL,
    @lineage_old28 varbinary(311) = NULL,
    @generation28 bigint = NULL,
    @lineage_new28 varbinary(311) = NULL,
    @colv28 varbinary(1) = NULL,
    @p244 nvarchar(50) = NULL
,
    @p245 nvarchar(50) = NULL,
    @p246 date = NULL,
    @p247 date = NULL,
    @p248 float = NULL,
    @p249 int = NULL,
    @p250 int = NULL,
    @p251 nvarchar(50) = NULL,
    @p252 uniqueidentifier = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @setbm29 varbinary(125) = NULL,
    @metadata_type29 tinyint = NULL,
    @lineage_old29 varbinary(311) = NULL,
    @generation29 bigint = NULL,
    @lineage_new29 varbinary(311) = NULL,
    @colv29 varbinary(1) = NULL,
    @p253 nvarchar(50) = NULL,
    @p254 nvarchar(50) = NULL,
    @p255 date = NULL,
    @p256 date = NULL,
    @p257 float = NULL,
    @p258 int = NULL,
    @p259 int = NULL,
    @p260 nvarchar(50) = NULL,
    @p261 uniqueidentifier = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @setbm30 varbinary(125) = NULL,
    @metadata_type30 tinyint = NULL,
    @lineage_old30 varbinary(311) = NULL,
    @generation30 bigint = NULL,
    @lineage_new30 varbinary(311) = NULL,
    @colv30 varbinary(1) = NULL,
    @p262 nvarchar(50) = NULL,
    @p263 nvarchar(50) = NULL,
    @p264 date = NULL,
    @p265 date = NULL,
    @p266 float = NULL,
    @p267 int = NULL,
    @p268 int = NULL,
    @p269 nvarchar(50) = NULL,
    @p270 uniqueidentifier = NULL,
    @rowguid31 uniqueidentifier = NULL,
    @setbm31 varbinary(125) = NULL,
    @metadata_type31 tinyint = NULL,
    @lineage_old31 varbinary(311) = NULL,
    @generation31 bigint = NULL,
    @lineage_new31 varbinary(311) = NULL,
    @colv31 varbinary(1) = NULL,
    @p271 nvarchar(50) = NULL,
    @p272 nvarchar(50) = NULL,
    @p273 date = NULL,
    @p274 date = NULL,
    @p275 float = NULL,
    @p276 int = NULL,
    @p277 int = NULL,
    @p278 nvarchar(50) = NULL,
    @p279 uniqueidentifier = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @setbm32 varbinary(125) = NULL,
    @metadata_type32 tinyint = NULL,
    @lineage_old32 varbinary(311) = NULL,
    @generation32 bigint = NULL,
    @lineage_new32 varbinary(311) = NULL,
    @colv32 varbinary(1) = NULL,
    @p280 nvarchar(50) = NULL,
    @p281 nvarchar(50) = NULL,
    @p282 date = NULL,
    @p283 date = NULL,
    @p284 float = NULL,
    @p285 int = NULL,
    @p286 int = NULL,
    @p287 nvarchar(50) = NULL,
    @p288 uniqueidentifier = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @setbm33 varbinary(125) = NULL,
    @metadata_type33 tinyint = NULL,
    @lineage_old33 varbinary(311) = NULL,
    @generation33 bigint = NULL,
    @lineage_new33 varbinary(311) = NULL,
    @colv33 varbinary(1) = NULL,
    @p289 nvarchar(50) = NULL,
    @p290 nvarchar(50) = NULL,
    @p291 date = NULL,
    @p292 date = NULL,
    @p293 float = NULL,
    @p294 int = NULL,
    @p295 int = NULL,
    @p296 nvarchar(50) = NULL,
    @p297 uniqueidentifier = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @setbm34 varbinary(125) = NULL,
    @metadata_type34 tinyint = NULL,
    @lineage_old34 varbinary(311) = NULL,
    @generation34 bigint = NULL,
    @lineage_new34 varbinary(311) = NULL,
    @colv34 varbinary(1) = NULL,
    @p298 nvarchar(50) = NULL,
    @p299 nvarchar(50) = NULL,
    @p300 date = NULL,
    @p301 date = NULL,
    @p302 float = NULL,
    @p303 int = NULL,
    @p304 int = NULL,
    @p305 nvarchar(50) = NULL,
    @p306 uniqueidentifier = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @setbm35 varbinary(125) = NULL,
    @metadata_type35 tinyint = NULL,
    @lineage_old35 varbinary(311) = NULL,
    @generation35 bigint = NULL,
    @lineage_new35 varbinary(311) = NULL,
    @colv35 varbinary(1) = NULL,
    @p307 nvarchar(50) = NULL
,
    @p308 nvarchar(50) = NULL,
    @p309 date = NULL,
    @p310 date = NULL,
    @p311 float = NULL,
    @p312 int = NULL,
    @p313 int = NULL,
    @p314 nvarchar(50) = NULL,
    @p315 uniqueidentifier = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @setbm36 varbinary(125) = NULL,
    @metadata_type36 tinyint = NULL,
    @lineage_old36 varbinary(311) = NULL,
    @generation36 bigint = NULL,
    @lineage_new36 varbinary(311) = NULL,
    @colv36 varbinary(1) = NULL,
    @p316 nvarchar(50) = NULL,
    @p317 nvarchar(50) = NULL,
    @p318 date = NULL,
    @p319 date = NULL,
    @p320 float = NULL,
    @p321 int = NULL,
    @p322 int = NULL,
    @p323 nvarchar(50) = NULL,
    @p324 uniqueidentifier = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @setbm37 varbinary(125) = NULL,
    @metadata_type37 tinyint = NULL,
    @lineage_old37 varbinary(311) = NULL,
    @generation37 bigint = NULL,
    @lineage_new37 varbinary(311) = NULL,
    @colv37 varbinary(1) = NULL,
    @p325 nvarchar(50) = NULL,
    @p326 nvarchar(50) = NULL,
    @p327 date = NULL,
    @p328 date = NULL,
    @p329 float = NULL,
    @p330 int = NULL,
    @p331 int = NULL,
    @p332 nvarchar(50) = NULL,
    @p333 uniqueidentifier = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @setbm38 varbinary(125) = NULL,
    @metadata_type38 tinyint = NULL,
    @lineage_old38 varbinary(311) = NULL,
    @generation38 bigint = NULL,
    @lineage_new38 varbinary(311) = NULL,
    @colv38 varbinary(1) = NULL,
    @p334 nvarchar(50) = NULL,
    @p335 nvarchar(50) = NULL,
    @p336 date = NULL,
    @p337 date = NULL,
    @p338 float = NULL,
    @p339 int = NULL,
    @p340 int = NULL,
    @p341 nvarchar(50) = NULL,
    @p342 uniqueidentifier = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @setbm39 varbinary(125) = NULL,
    @metadata_type39 tinyint = NULL,
    @lineage_old39 varbinary(311) = NULL,
    @generation39 bigint = NULL,
    @lineage_new39 varbinary(311) = NULL,
    @colv39 varbinary(1) = NULL,
    @p343 nvarchar(50) = NULL,
    @p344 nvarchar(50) = NULL,
    @p345 date = NULL,
    @p346 date = NULL,
    @p347 float = NULL,
    @p348 int = NULL,
    @p349 int = NULL,
    @p350 nvarchar(50) = NULL,
    @p351 uniqueidentifier = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @setbm40 varbinary(125) = NULL,
    @metadata_type40 tinyint = NULL,
    @lineage_old40 varbinary(311) = NULL,
    @generation40 bigint = NULL,
    @lineage_new40 varbinary(311) = NULL,
    @colv40 varbinary(1) = NULL,
    @p352 nvarchar(50) = NULL,
    @p353 nvarchar(50) = NULL,
    @p354 date = NULL,
    @p355 date = NULL,
    @p356 float = NULL,
    @p357 int = NULL,
    @p358 int = NULL,
    @p359 nvarchar(50) = NULL,
    @p360 uniqueidentifier = NULL,
    @rowguid41 uniqueidentifier = NULL,
    @setbm41 varbinary(125) = NULL,
    @metadata_type41 tinyint = NULL,
    @lineage_old41 varbinary(311) = NULL,
    @generation41 bigint = NULL,
    @lineage_new41 varbinary(311) = NULL,
    @colv41 varbinary(1) = NULL,
    @p361 nvarchar(50) = NULL,
    @p362 nvarchar(50) = NULL,
    @p363 date = NULL,
    @p364 date = NULL,
    @p365 float = NULL,
    @p366 int = NULL,
    @p367 int = NULL,
    @p368 nvarchar(50) = NULL,
    @p369 uniqueidentifier = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @setbm42 varbinary(125) = NULL,
    @metadata_type42 tinyint = NULL,
    @lineage_old42 varbinary(311) = NULL,
    @generation42 bigint = NULL,
    @lineage_new42 varbinary(311) = NULL,
    @colv42 varbinary(1) = NULL,
    @p370 nvarchar(50) = NULL
,
    @p371 nvarchar(50) = NULL,
    @p372 date = NULL,
    @p373 date = NULL,
    @p374 float = NULL,
    @p375 int = NULL,
    @p376 int = NULL,
    @p377 nvarchar(50) = NULL,
    @p378 uniqueidentifier = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @setbm43 varbinary(125) = NULL,
    @metadata_type43 tinyint = NULL,
    @lineage_old43 varbinary(311) = NULL,
    @generation43 bigint = NULL,
    @lineage_new43 varbinary(311) = NULL,
    @colv43 varbinary(1) = NULL,
    @p379 nvarchar(50) = NULL,
    @p380 nvarchar(50) = NULL,
    @p381 date = NULL,
    @p382 date = NULL,
    @p383 float = NULL,
    @p384 int = NULL,
    @p385 int = NULL,
    @p386 nvarchar(50) = NULL,
    @p387 uniqueidentifier = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @setbm44 varbinary(125) = NULL,
    @metadata_type44 tinyint = NULL,
    @lineage_old44 varbinary(311) = NULL,
    @generation44 bigint = NULL,
    @lineage_new44 varbinary(311) = NULL,
    @colv44 varbinary(1) = NULL,
    @p388 nvarchar(50) = NULL,
    @p389 nvarchar(50) = NULL,
    @p390 date = NULL,
    @p391 date = NULL,
    @p392 float = NULL,
    @p393 int = NULL,
    @p394 int = NULL,
    @p395 nvarchar(50) = NULL,
    @p396 uniqueidentifier = NULL,
    @rowguid45 uniqueidentifier = NULL,
    @setbm45 varbinary(125) = NULL,
    @metadata_type45 tinyint = NULL,
    @lineage_old45 varbinary(311) = NULL,
    @generation45 bigint = NULL,
    @lineage_new45 varbinary(311) = NULL,
    @colv45 varbinary(1) = NULL,
    @p397 nvarchar(50) = NULL,
    @p398 nvarchar(50) = NULL,
    @p399 date = NULL,
    @p400 date = NULL,
    @p401 float = NULL,
    @p402 int = NULL,
    @p403 int = NULL,
    @p404 nvarchar(50) = NULL,
    @p405 uniqueidentifier = NULL,
    @rowguid46 uniqueidentifier = NULL,
    @setbm46 varbinary(125) = NULL,
    @metadata_type46 tinyint = NULL,
    @lineage_old46 varbinary(311) = NULL,
    @generation46 bigint = NULL,
    @lineage_new46 varbinary(311) = NULL,
    @colv46 varbinary(1) = NULL,
    @p406 nvarchar(50) = NULL,
    @p407 nvarchar(50) = NULL,
    @p408 date = NULL,
    @p409 date = NULL,
    @p410 float = NULL,
    @p411 int = NULL,
    @p412 int = NULL,
    @p413 nvarchar(50) = NULL,
    @p414 uniqueidentifier = NULL,
    @rowguid47 uniqueidentifier = NULL,
    @setbm47 varbinary(125) = NULL,
    @metadata_type47 tinyint = NULL,
    @lineage_old47 varbinary(311) = NULL,
    @generation47 bigint = NULL,
    @lineage_new47 varbinary(311) = NULL,
    @colv47 varbinary(1) = NULL,
    @p415 nvarchar(50) = NULL,
    @p416 nvarchar(50) = NULL,
    @p417 date = NULL,
    @p418 date = NULL,
    @p419 float = NULL,
    @p420 int = NULL,
    @p421 int = NULL,
    @p422 nvarchar(50) = NULL,
    @p423 uniqueidentifier = NULL,
    @rowguid48 uniqueidentifier = NULL,
    @setbm48 varbinary(125) = NULL,
    @metadata_type48 tinyint = NULL,
    @lineage_old48 varbinary(311) = NULL,
    @generation48 bigint = NULL,
    @lineage_new48 varbinary(311) = NULL,
    @colv48 varbinary(1) = NULL,
    @p424 nvarchar(50) = NULL,
    @p425 nvarchar(50) = NULL,
    @p426 date = NULL,
    @p427 date = NULL,
    @p428 float = NULL,
    @p429 int = NULL,
    @p430 int = NULL,
    @p431 nvarchar(50) = NULL,
    @p432 uniqueidentifier = NULL,
    @rowguid49 uniqueidentifier = NULL,
    @setbm49 varbinary(125) = NULL,
    @metadata_type49 tinyint = NULL,
    @lineage_old49 varbinary(311) = NULL,
    @generation49 bigint = NULL,
    @lineage_new49 varbinary(311) = NULL,
    @colv49 varbinary(1) = NULL,
    @p433 nvarchar(50) = NULL
,
    @p434 nvarchar(50) = NULL,
    @p435 date = NULL,
    @p436 date = NULL,
    @p437 float = NULL,
    @p438 int = NULL,
    @p439 int = NULL,
    @p440 nvarchar(50) = NULL,
    @p441 uniqueidentifier = NULL,
    @rowguid50 uniqueidentifier = NULL,
    @setbm50 varbinary(125) = NULL,
    @metadata_type50 tinyint = NULL,
    @lineage_old50 varbinary(311) = NULL,
    @generation50 bigint = NULL,
    @lineage_new50 varbinary(311) = NULL,
    @colv50 varbinary(1) = NULL,
    @p442 nvarchar(50) = NULL,
    @p443 nvarchar(50) = NULL,
    @p444 date = NULL,
    @p445 date = NULL,
    @p446 float = NULL,
    @p447 int = NULL,
    @p448 int = NULL,
    @p449 nvarchar(50) = NULL,
    @p450 uniqueidentifier = NULL,
    @rowguid51 uniqueidentifier = NULL,
    @setbm51 varbinary(125) = NULL,
    @metadata_type51 tinyint = NULL,
    @lineage_old51 varbinary(311) = NULL,
    @generation51 bigint = NULL,
    @lineage_new51 varbinary(311) = NULL,
    @colv51 varbinary(1) = NULL,
    @p451 nvarchar(50) = NULL,
    @p452 nvarchar(50) = NULL,
    @p453 date = NULL,
    @p454 date = NULL,
    @p455 float = NULL,
    @p456 int = NULL,
    @p457 int = NULL,
    @p458 nvarchar(50) = NULL,
    @p459 uniqueidentifier = NULL,
    @rowguid52 uniqueidentifier = NULL,
    @setbm52 varbinary(125) = NULL,
    @metadata_type52 tinyint = NULL,
    @lineage_old52 varbinary(311) = NULL,
    @generation52 bigint = NULL,
    @lineage_new52 varbinary(311) = NULL,
    @colv52 varbinary(1) = NULL,
    @p460 nvarchar(50) = NULL,
    @p461 nvarchar(50) = NULL,
    @p462 date = NULL,
    @p463 date = NULL,
    @p464 float = NULL,
    @p465 int = NULL,
    @p466 int = NULL,
    @p467 nvarchar(50) = NULL,
    @p468 uniqueidentifier = NULL,
    @rowguid53 uniqueidentifier = NULL,
    @setbm53 varbinary(125) = NULL,
    @metadata_type53 tinyint = NULL,
    @lineage_old53 varbinary(311) = NULL,
    @generation53 bigint = NULL,
    @lineage_new53 varbinary(311) = NULL,
    @colv53 varbinary(1) = NULL,
    @p469 nvarchar(50) = NULL,
    @p470 nvarchar(50) = NULL,
    @p471 date = NULL,
    @p472 date = NULL,
    @p473 float = NULL,
    @p474 int = NULL,
    @p475 int = NULL,
    @p476 nvarchar(50) = NULL,
    @p477 uniqueidentifier = NULL,
    @rowguid54 uniqueidentifier = NULL,
    @setbm54 varbinary(125) = NULL,
    @metadata_type54 tinyint = NULL,
    @lineage_old54 varbinary(311) = NULL,
    @generation54 bigint = NULL,
    @lineage_new54 varbinary(311) = NULL,
    @colv54 varbinary(1) = NULL,
    @p478 nvarchar(50) = NULL,
    @p479 nvarchar(50) = NULL,
    @p480 date = NULL,
    @p481 date = NULL,
    @p482 float = NULL,
    @p483 int = NULL,
    @p484 int = NULL,
    @p485 nvarchar(50) = NULL,
    @p486 uniqueidentifier = NULL,
    @rowguid55 uniqueidentifier = NULL,
    @setbm55 varbinary(125) = NULL,
    @metadata_type55 tinyint = NULL,
    @lineage_old55 varbinary(311) = NULL,
    @generation55 bigint = NULL,
    @lineage_new55 varbinary(311) = NULL,
    @colv55 varbinary(1) = NULL,
    @p487 nvarchar(50) = NULL,
    @p488 nvarchar(50) = NULL,
    @p489 date = NULL,
    @p490 date = NULL,
    @p491 float = NULL,
    @p492 int = NULL,
    @p493 int = NULL,
    @p494 nvarchar(50) = NULL,
    @p495 uniqueidentifier = NULL,
    @rowguid56 uniqueidentifier = NULL,
    @setbm56 varbinary(125) = NULL,
    @metadata_type56 tinyint = NULL,
    @lineage_old56 varbinary(311) = NULL,
    @generation56 bigint = NULL,
    @lineage_new56 varbinary(311) = NULL,
    @colv56 varbinary(1) = NULL,
    @p496 nvarchar(50) = NULL
,
    @p497 nvarchar(50) = NULL,
    @p498 date = NULL,
    @p499 date = NULL,
    @p500 float = NULL,
    @p501 int = NULL,
    @p502 int = NULL,
    @p503 nvarchar(50) = NULL,
    @p504 uniqueidentifier = NULL,
    @rowguid57 uniqueidentifier = NULL,
    @setbm57 varbinary(125) = NULL,
    @metadata_type57 tinyint = NULL,
    @lineage_old57 varbinary(311) = NULL,
    @generation57 bigint = NULL,
    @lineage_new57 varbinary(311) = NULL,
    @colv57 varbinary(1) = NULL,
    @p505 nvarchar(50) = NULL,
    @p506 nvarchar(50) = NULL,
    @p507 date = NULL,
    @p508 date = NULL,
    @p509 float = NULL,
    @p510 int = NULL,
    @p511 int = NULL,
    @p512 nvarchar(50) = NULL,
    @p513 uniqueidentifier = NULL,
    @rowguid58 uniqueidentifier = NULL,
    @setbm58 varbinary(125) = NULL,
    @metadata_type58 tinyint = NULL,
    @lineage_old58 varbinary(311) = NULL,
    @generation58 bigint = NULL,
    @lineage_new58 varbinary(311) = NULL,
    @colv58 varbinary(1) = NULL,
    @p514 nvarchar(50) = NULL,
    @p515 nvarchar(50) = NULL,
    @p516 date = NULL,
    @p517 date = NULL,
    @p518 float = NULL,
    @p519 int = NULL,
    @p520 int = NULL,
    @p521 nvarchar(50) = NULL,
    @p522 uniqueidentifier = NULL,
    @rowguid59 uniqueidentifier = NULL,
    @setbm59 varbinary(125) = NULL,
    @metadata_type59 tinyint = NULL,
    @lineage_old59 varbinary(311) = NULL,
    @generation59 bigint = NULL,
    @lineage_new59 varbinary(311) = NULL,
    @colv59 varbinary(1) = NULL,
    @p523 nvarchar(50) = NULL,
    @p524 nvarchar(50) = NULL,
    @p525 date = NULL,
    @p526 date = NULL,
    @p527 float = NULL,
    @p528 int = NULL,
    @p529 int = NULL,
    @p530 nvarchar(50) = NULL,
    @p531 uniqueidentifier = NULL,
    @rowguid60 uniqueidentifier = NULL,
    @setbm60 varbinary(125) = NULL,
    @metadata_type60 tinyint = NULL,
    @lineage_old60 varbinary(311) = NULL,
    @generation60 bigint = NULL,
    @lineage_new60 varbinary(311) = NULL,
    @colv60 varbinary(1) = NULL,
    @p532 nvarchar(50) = NULL,
    @p533 nvarchar(50) = NULL,
    @p534 date = NULL,
    @p535 date = NULL,
    @p536 float = NULL,
    @p537 int = NULL,
    @p538 int = NULL,
    @p539 nvarchar(50) = NULL,
    @p540 uniqueidentifier = NULL,
    @rowguid61 uniqueidentifier = NULL,
    @setbm61 varbinary(125) = NULL,
    @metadata_type61 tinyint = NULL,
    @lineage_old61 varbinary(311) = NULL,
    @generation61 bigint = NULL,
    @lineage_new61 varbinary(311) = NULL,
    @colv61 varbinary(1) = NULL,
    @p541 nvarchar(50) = NULL,
    @p542 nvarchar(50) = NULL,
    @p543 date = NULL,
    @p544 date = NULL,
    @p545 float = NULL,
    @p546 int = NULL,
    @p547 int = NULL,
    @p548 nvarchar(50) = NULL,
    @p549 uniqueidentifier = NULL,
    @rowguid62 uniqueidentifier = NULL,
    @setbm62 varbinary(125) = NULL,
    @metadata_type62 tinyint = NULL,
    @lineage_old62 varbinary(311) = NULL,
    @generation62 bigint = NULL,
    @lineage_new62 varbinary(311) = NULL,
    @colv62 varbinary(1) = NULL,
    @p550 nvarchar(50) = NULL,
    @p551 nvarchar(50) = NULL,
    @p552 date = NULL,
    @p553 date = NULL,
    @p554 float = NULL,
    @p555 int = NULL,
    @p556 int = NULL,
    @p557 nvarchar(50) = NULL,
    @p558 uniqueidentifier = NULL,
    @rowguid63 uniqueidentifier = NULL,
    @setbm63 varbinary(125) = NULL,
    @metadata_type63 tinyint = NULL,
    @lineage_old63 varbinary(311) = NULL,
    @generation63 bigint = NULL,
    @lineage_new63 varbinary(311) = NULL,
    @colv63 varbinary(1) = NULL,
    @p559 nvarchar(50) = NULL
,
    @p560 nvarchar(50) = NULL
,
    @p561 date = NULL
,
    @p562 date = NULL
,
    @p563 float = NULL
,
    @p564 int = NULL
,
    @p565 int = NULL
,
    @p566 nvarchar(50) = NULL
,
    @p567 uniqueidentifier = NULL

) as
begin
    declare @errcode    int
    declare @retcode    int
    declare @rowcount   int
    declare @error      int
    declare @publication_number smallint
    declare @filtering_column_updated bit
    declare @rows_updated int
    declare @cont_rows_updated int
    declare @rows_in_syncview int
    
    set nocount on
    
    set @errcode= 0
    set @publication_number = 1
    
    if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
    begin
        RAISERROR (14126, 11, -1)
        return 4
    end

    if @rows_tobe_updated is NULL or @rows_tobe_updated <=0
        return 0

    select @filtering_column_updated = 0
    select @rows_updated = 0
    select @cont_rows_updated = 0 

    begin tran
    save tran batchupdateproc 

    select @filtering_column_updated = 0

    -- case 1 of setting the filtering column where we are setting it to NULL and the table has a non NULL value for this column
    select @filtering_column_updated = 1 from 
        (

            select @rowguid1 as rowguid, @p2 as c2, @setbm1 as setbm
 union all
            select @rowguid2 as rowguid, @p11 as c2, @setbm2 as setbm
 union all
            select @rowguid3 as rowguid, @p20 as c2, @setbm3 as setbm
 union all
            select @rowguid4 as rowguid, @p29 as c2, @setbm4 as setbm
 union all
            select @rowguid5 as rowguid, @p38 as c2, @setbm5 as setbm
 union all
            select @rowguid6 as rowguid, @p47 as c2, @setbm6 as setbm
 union all
            select @rowguid7 as rowguid, @p56 as c2, @setbm7 as setbm
 union all
            select @rowguid8 as rowguid, @p65 as c2, @setbm8 as setbm
 union all
            select @rowguid9 as rowguid, @p74 as c2, @setbm9 as setbm
 union all
            select @rowguid10 as rowguid, @p83 as c2, @setbm10 as setbm
 union all
            select @rowguid11 as rowguid, @p92 as c2, @setbm11 as setbm
 union all
            select @rowguid12 as rowguid, @p101 as c2, @setbm12 as setbm
 union all
            select @rowguid13 as rowguid, @p110 as c2, @setbm13 as setbm
 union all
            select @rowguid14 as rowguid, @p119 as c2, @setbm14 as setbm
 union all
            select @rowguid15 as rowguid, @p128 as c2, @setbm15 as setbm
 union all
            select @rowguid16 as rowguid, @p137 as c2, @setbm16 as setbm
 union all
            select @rowguid17 as rowguid, @p146 as c2, @setbm17 as setbm
 union all
            select @rowguid18 as rowguid, @p155 as c2, @setbm18 as setbm
 union all
            select @rowguid19 as rowguid, @p164 as c2, @setbm19 as setbm
 union all
            select @rowguid20 as rowguid, @p173 as c2, @setbm20 as setbm
 union all
            select @rowguid21 as rowguid, @p182 as c2, @setbm21 as setbm
 union all
            select @rowguid22 as rowguid, @p191 as c2, @setbm22 as setbm
 union all
            select @rowguid23 as rowguid, @p200 as c2, @setbm23 as setbm
 union all
            select @rowguid24 as rowguid, @p209 as c2, @setbm24 as setbm
 union all
            select @rowguid25 as rowguid, @p218 as c2, @setbm25 as setbm
 union all
            select @rowguid26 as rowguid, @p227 as c2, @setbm26 as setbm
 union all
            select @rowguid27 as rowguid, @p236 as c2, @setbm27 as setbm
 union all
            select @rowguid28 as rowguid, @p245 as c2, @setbm28 as setbm
 union all
            select @rowguid29 as rowguid, @p254 as c2, @setbm29 as setbm
 union all
            select @rowguid30 as rowguid, @p263 as c2, @setbm30 as setbm
 union all
            select @rowguid31 as rowguid, @p272 as c2, @setbm31 as setbm
 union all
            select @rowguid32 as rowguid, @p281 as c2, @setbm32 as setbm
 union all
            select @rowguid33 as rowguid, @p290 as c2, @setbm33 as setbm
 union all
            select @rowguid34 as rowguid, @p299 as c2, @setbm34 as setbm
 union all
            select @rowguid35 as rowguid, @p308 as c2, @setbm35 as setbm
 union all
            select @rowguid36 as rowguid, @p317 as c2, @setbm36 as setbm
 union all
            select @rowguid37 as rowguid, @p326 as c2, @setbm37 as setbm
 union all
            select @rowguid38 as rowguid, @p335 as c2, @setbm38 as setbm
 union all
            select @rowguid39 as rowguid, @p344 as c2, @setbm39 as setbm
 union all
            select @rowguid40 as rowguid, @p353 as c2, @setbm40 as setbm
 union all
            select @rowguid41 as rowguid, @p362 as c2, @setbm41 as setbm
 union all
            select @rowguid42 as rowguid, @p371 as c2, @setbm42 as setbm
 union all
            select @rowguid43 as rowguid, @p380 as c2, @setbm43 as setbm
 union all
            select @rowguid44 as rowguid, @p389 as c2, @setbm44 as setbm
 union all
            select @rowguid45 as rowguid, @p398 as c2, @setbm45 as setbm
 union all
            select @rowguid46 as rowguid, @p407 as c2, @setbm46 as setbm
 union all
            select @rowguid47 as rowguid, @p416 as c2, @setbm47 as setbm
 union all
            select @rowguid48 as rowguid, @p425 as c2, @setbm48 as setbm
 union all
            select @rowguid49 as rowguid, @p434 as c2, @setbm49 as setbm
 union all
            select @rowguid50 as rowguid, @p443 as c2, @setbm50 as setbm
 union all
            select @rowguid51 as rowguid, @p452 as c2, @setbm51 as setbm
 union all
            select @rowguid52 as rowguid, @p461 as c2, @setbm52 as setbm
 union all
            select @rowguid53 as rowguid, @p470 as c2, @setbm53 as setbm
 union all
            select @rowguid54 as rowguid, @p479 as c2, @setbm54 as setbm
 union all
            select @rowguid55 as rowguid, @p488 as c2, @setbm55 as setbm
 union all
            select @rowguid56 as rowguid, @p497 as c2, @setbm56 as setbm
 union all
            select @rowguid57 as rowguid, @p506 as c2, @setbm57 as setbm
 union all
            select @rowguid58 as rowguid, @p515 as c2, @setbm58 as setbm
 union all
            select @rowguid59 as rowguid, @p524 as c2, @setbm59 as setbm
 union all
            select @rowguid60 as rowguid, @p533 as c2, @setbm60 as setbm
 union all
            select @rowguid61 as rowguid, @p542 as c2, @setbm61 as setbm
 union all
            select @rowguid62 as rowguid, @p551 as c2, @setbm62 as setbm
 union all
            select @rowguid63 as rowguid, @p560 as c2, @setbm63 as setbm

        ) as rows
        inner join [dbo].[Account] t with (rowlock) 
        on t.[rowguid] = rows.rowguid and rows.rowguid is not NULL
        where rows.c2 is NULL and sys.fn_IsBitSetInBitmask(rows.setbm, 2) <> 0 and t.[Customer] is not NULL
        
    if @filtering_column_updated = 1
    begin
        raiserror(20694, 16, -1, 'Account', '[Customer]')
        set @errcode=4
        goto Failure
    end

    -- case 2 of setting the filtering column where we are setting it to a not null value and the value is not equal to the value in the table
    select @filtering_column_updated = 1 from 
        (

            select @rowguid1 as rowguid, @p2 as c2
 union all
            select @rowguid2 as rowguid, @p11 as c2
 union all
            select @rowguid3 as rowguid, @p20 as c2
 union all
            select @rowguid4 as rowguid, @p29 as c2
 union all
            select @rowguid5 as rowguid, @p38 as c2
 union all
            select @rowguid6 as rowguid, @p47 as c2
 union all
            select @rowguid7 as rowguid, @p56 as c2
 union all
            select @rowguid8 as rowguid, @p65 as c2
 union all
            select @rowguid9 as rowguid, @p74 as c2
 union all
            select @rowguid10 as rowguid, @p83 as c2
 union all
            select @rowguid11 as rowguid, @p92 as c2
 union all
            select @rowguid12 as rowguid, @p101 as c2
 union all
            select @rowguid13 as rowguid, @p110 as c2
 union all
            select @rowguid14 as rowguid, @p119 as c2
 union all
            select @rowguid15 as rowguid, @p128 as c2
 union all
            select @rowguid16 as rowguid, @p137 as c2
 union all
            select @rowguid17 as rowguid, @p146 as c2
 union all
            select @rowguid18 as rowguid, @p155 as c2
 union all
            select @rowguid19 as rowguid, @p164 as c2
 union all
            select @rowguid20 as rowguid, @p173 as c2
 union all
            select @rowguid21 as rowguid, @p182 as c2
 union all
            select @rowguid22 as rowguid, @p191 as c2
 union all
            select @rowguid23 as rowguid, @p200 as c2
 union all
            select @rowguid24 as rowguid, @p209 as c2
 union all
            select @rowguid25 as rowguid, @p218 as c2
 union all
            select @rowguid26 as rowguid, @p227 as c2
 union all
            select @rowguid27 as rowguid, @p236 as c2
 union all
            select @rowguid28 as rowguid, @p245 as c2
 union all
            select @rowguid29 as rowguid, @p254 as c2
 union all
            select @rowguid30 as rowguid, @p263 as c2
 union all
            select @rowguid31 as rowguid, @p272 as c2
 union all
            select @rowguid32 as rowguid, @p281 as c2
 union all
            select @rowguid33 as rowguid, @p290 as c2
 union all
            select @rowguid34 as rowguid, @p299 as c2
 union all
            select @rowguid35 as rowguid, @p308 as c2
 union all
            select @rowguid36 as rowguid, @p317 as c2
 union all
            select @rowguid37 as rowguid, @p326 as c2
 union all
            select @rowguid38 as rowguid, @p335 as c2
 union all
            select @rowguid39 as rowguid, @p344 as c2
 union all
            select @rowguid40 as rowguid, @p353 as c2
 union all
            select @rowguid41 as rowguid, @p362 as c2
 union all
            select @rowguid42 as rowguid, @p371 as c2
 union all
            select @rowguid43 as rowguid, @p380 as c2
 union all
            select @rowguid44 as rowguid, @p389 as c2
 union all
            select @rowguid45 as rowguid, @p398 as c2
 union all
            select @rowguid46 as rowguid, @p407 as c2
 union all
            select @rowguid47 as rowguid, @p416 as c2
 union all
            select @rowguid48 as rowguid, @p425 as c2
 union all
            select @rowguid49 as rowguid, @p434 as c2
 union all
            select @rowguid50 as rowguid, @p443 as c2
 union all
            select @rowguid51 as rowguid, @p452 as c2
 union all
            select @rowguid52 as rowguid, @p461 as c2
 union all
            select @rowguid53 as rowguid, @p470 as c2
 union all
            select @rowguid54 as rowguid, @p479 as c2
 union all
            select @rowguid55 as rowguid, @p488 as c2
 union all
            select @rowguid56 as rowguid, @p497 as c2
 union all
            select @rowguid57 as rowguid, @p506 as c2
 union all
            select @rowguid58 as rowguid, @p515 as c2
 union all
            select @rowguid59 as rowguid, @p524 as c2
 union all
            select @rowguid60 as rowguid, @p533 as c2
 union all
            select @rowguid61 as rowguid, @p542 as c2
 union all
            select @rowguid62 as rowguid, @p551 as c2
 union all
            select @rowguid63 as rowguid, @p560 as c2

        ) as rows
        inner join [dbo].[Account] t with (rowlock) 
        on t.[rowguid] = rows.rowguid and rows.rowguid is not NULL
        where rows.c2 is not NULL and (t.[Customer] is NULL or t.[Customer] <> rows.c2 )   

    if @filtering_column_updated = 1
    begin
        raiserror(20694, 16, -1, 'Account', '[Customer]')
        set @errcode=4
        goto Failure
    end

    update [dbo].[Account] with (rowlock)
    set 

        [AccountID] = case when rows.c1 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 1) <> 0 then rows.c1 else t.[AccountID] end) else rows.c1 end 
,
        [StartDate] = case when rows.c3 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 3) <> 0 then rows.c3 else t.[StartDate] end) else rows.c3 end 
,
        [EndDate] = case when rows.c4 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 4) <> 0 then rows.c4 else t.[EndDate] end) else rows.c4 end 
,
        [Interest] = case when rows.c5 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 5) <> 0 then rows.c5 else t.[Interest] end) else rows.c5 end 
,
        [Period] = case when rows.c6 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 6) <> 0 then rows.c6 else t.[Period] end) else rows.c6 end 
,
        [Balance] = case when rows.c7 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 7) <> 0 then rows.c7 else t.[Balance] end) else rows.c7 end 
,
        [Branch] = case when rows.c8 is NULL then (case when sys.fn_IsBitSetInBitmask(rows.setbm, 8) <> 0 then rows.c8 else t.[Branch] end) else rows.c8 end 

    from (

    select @rowguid1 as rowguid, @setbm1 as setbm, @metadata_type1 as metadata_type, @lineage_old1 as lineage_old, @p1 as c1, @p3 as c3, @p4 as c4, @p5 as c5, @p6 as c6, @p7 as c7, @p8 as c8 union all
    select @rowguid2 as rowguid, @setbm2 as setbm, @metadata_type2 as metadata_type, @lineage_old2 as lineage_old, @p10 as c1, @p12 as c3, @p13 as c4, @p14 as c5, @p15 as c6, @p16 as c7, @p17 as c8 union all
    select @rowguid3 as rowguid, @setbm3 as setbm, @metadata_type3 as metadata_type, @lineage_old3 as lineage_old, @p19 as c1, @p21 as c3, @p22 as c4, @p23 as c5, @p24 as c6, @p25 as c7, @p26 as c8 union all
    select @rowguid4 as rowguid, @setbm4 as setbm, @metadata_type4 as metadata_type, @lineage_old4 as lineage_old, @p28 as c1, @p30 as c3, @p31 as c4, @p32 as c5, @p33 as c6, @p34 as c7, @p35 as c8 union all
    select @rowguid5 as rowguid, @setbm5 as setbm, @metadata_type5 as metadata_type, @lineage_old5 as lineage_old, @p37 as c1, @p39 as c3, @p40 as c4, @p41 as c5, @p42 as c6, @p43 as c7, @p44 as c8 union all
    select @rowguid6 as rowguid, @setbm6 as setbm, @metadata_type6 as metadata_type, @lineage_old6 as lineage_old, @p46 as c1, @p48 as c3, @p49 as c4, @p50 as c5, @p51 as c6, @p52 as c7, @p53 as c8 union all
    select @rowguid7 as rowguid, @setbm7 as setbm, @metadata_type7 as metadata_type, @lineage_old7 as lineage_old, @p55 as c1, @p57 as c3, @p58 as c4, @p59 as c5, @p60 as c6, @p61 as c7, @p62 as c8 union all
    select @rowguid8 as rowguid, @setbm8 as setbm, @metadata_type8 as metadata_type, @lineage_old8 as lineage_old, @p64 as c1, @p66 as c3, @p67 as c4, @p68 as c5, @p69 as c6, @p70 as c7, @p71 as c8 union all
    select @rowguid9 as rowguid, @setbm9 as setbm, @metadata_type9 as metadata_type, @lineage_old9 as lineage_old, @p73 as c1, @p75 as c3, @p76 as c4, @p77 as c5, @p78 as c6, @p79 as c7, @p80 as c8 union all
    select @rowguid10 as rowguid, @setbm10 as setbm, @metadata_type10 as metadata_type, @lineage_old10 as lineage_old, @p82 as c1, @p84 as c3, @p85 as c4, @p86 as c5, @p87 as c6, @p88 as c7, @p89 as c8 union all
    select @rowguid11 as rowguid, @setbm11 as setbm, @metadata_type11 as metadata_type, @lineage_old11 as lineage_old, @p91 as c1, @p93 as c3, @p94 as c4, @p95 as c5, @p96 as c6, @p97 as c7, @p98 as c8 union all
    select @rowguid12 as rowguid, @setbm12 as setbm, @metadata_type12 as metadata_type, @lineage_old12 as lineage_old, @p100 as c1, @p102 as c3, @p103 as c4, @p104 as c5, @p105 as c6, @p106 as c7, @p107 as c8 union all
    select @rowguid13 as rowguid, @setbm13 as setbm, @metadata_type13 as metadata_type, @lineage_old13 as lineage_old, @p109 as c1, @p111 as c3, @p112 as c4, @p113 as c5, @p114 as c6, @p115 as c7, @p116 as c8 union all
    select @rowguid14 as rowguid, @setbm14 as setbm, @metadata_type14 as metadata_type, @lineage_old14 as lineage_old, @p118 as c1, @p120 as c3, @p121 as c4, @p122 as c5, @p123 as c6, @p124 as c7, @p125 as c8 union all
    select @rowguid15 as rowguid, @setbm15 as setbm, @metadata_type15 as metadata_type, @lineage_old15 as lineage_old, @p127 as c1, @p129 as c3, @p130 as c4, @p131 as c5, @p132 as c6, @p133 as c7, @p134 as c8 union all
    select @rowguid16 as rowguid, @setbm16 as setbm, @metadata_type16 as metadata_type, @lineage_old16 as lineage_old, @p136 as c1, @p138 as c3, @p139 as c4, @p140 as c5, @p141 as c6, @p142 as c7, @p143 as c8 union all
    select @rowguid17 as rowguid, @setbm17 as setbm, @metadata_type17 as metadata_type, @lineage_old17 as lineage_old, @p145 as c1, @p147 as c3, @p148 as c4, @p149 as c5, @p150 as c6, @p151 as c7, @p152 as c8 union all
    select @rowguid18 as rowguid, @setbm18 as setbm, @metadata_type18 as metadata_type, @lineage_old18 as lineage_old, @p154 as c1
, @p156 as c3, @p157 as c4, @p158 as c5, @p159 as c6, @p160 as c7, @p161 as c8 union all
    select @rowguid19 as rowguid, @setbm19 as setbm, @metadata_type19 as metadata_type, @lineage_old19 as lineage_old, @p163 as c1, @p165 as c3, @p166 as c4, @p167 as c5, @p168 as c6, @p169 as c7, @p170 as c8 union all
    select @rowguid20 as rowguid, @setbm20 as setbm, @metadata_type20 as metadata_type, @lineage_old20 as lineage_old, @p172 as c1, @p174 as c3, @p175 as c4, @p176 as c5, @p177 as c6, @p178 as c7, @p179 as c8 union all
    select @rowguid21 as rowguid, @setbm21 as setbm, @metadata_type21 as metadata_type, @lineage_old21 as lineage_old, @p181 as c1, @p183 as c3, @p184 as c4, @p185 as c5, @p186 as c6, @p187 as c7, @p188 as c8 union all
    select @rowguid22 as rowguid, @setbm22 as setbm, @metadata_type22 as metadata_type, @lineage_old22 as lineage_old, @p190 as c1, @p192 as c3, @p193 as c4, @p194 as c5, @p195 as c6, @p196 as c7, @p197 as c8 union all
    select @rowguid23 as rowguid, @setbm23 as setbm, @metadata_type23 as metadata_type, @lineage_old23 as lineage_old, @p199 as c1, @p201 as c3, @p202 as c4, @p203 as c5, @p204 as c6, @p205 as c7, @p206 as c8 union all
    select @rowguid24 as rowguid, @setbm24 as setbm, @metadata_type24 as metadata_type, @lineage_old24 as lineage_old, @p208 as c1, @p210 as c3, @p211 as c4, @p212 as c5, @p213 as c6, @p214 as c7, @p215 as c8 union all
    select @rowguid25 as rowguid, @setbm25 as setbm, @metadata_type25 as metadata_type, @lineage_old25 as lineage_old, @p217 as c1, @p219 as c3, @p220 as c4, @p221 as c5, @p222 as c6, @p223 as c7, @p224 as c8 union all
    select @rowguid26 as rowguid, @setbm26 as setbm, @metadata_type26 as metadata_type, @lineage_old26 as lineage_old, @p226 as c1, @p228 as c3, @p229 as c4, @p230 as c5, @p231 as c6, @p232 as c7, @p233 as c8 union all
    select @rowguid27 as rowguid, @setbm27 as setbm, @metadata_type27 as metadata_type, @lineage_old27 as lineage_old, @p235 as c1, @p237 as c3, @p238 as c4, @p239 as c5, @p240 as c6, @p241 as c7, @p242 as c8 union all
    select @rowguid28 as rowguid, @setbm28 as setbm, @metadata_type28 as metadata_type, @lineage_old28 as lineage_old, @p244 as c1, @p246 as c3, @p247 as c4, @p248 as c5, @p249 as c6, @p250 as c7, @p251 as c8 union all
    select @rowguid29 as rowguid, @setbm29 as setbm, @metadata_type29 as metadata_type, @lineage_old29 as lineage_old, @p253 as c1, @p255 as c3, @p256 as c4, @p257 as c5, @p258 as c6, @p259 as c7, @p260 as c8 union all
    select @rowguid30 as rowguid, @setbm30 as setbm, @metadata_type30 as metadata_type, @lineage_old30 as lineage_old, @p262 as c1, @p264 as c3, @p265 as c4, @p266 as c5, @p267 as c6, @p268 as c7, @p269 as c8 union all
    select @rowguid31 as rowguid, @setbm31 as setbm, @metadata_type31 as metadata_type, @lineage_old31 as lineage_old, @p271 as c1, @p273 as c3, @p274 as c4, @p275 as c5, @p276 as c6, @p277 as c7, @p278 as c8 union all
    select @rowguid32 as rowguid, @setbm32 as setbm, @metadata_type32 as metadata_type, @lineage_old32 as lineage_old, @p280 as c1, @p282 as c3, @p283 as c4, @p284 as c5, @p285 as c6, @p286 as c7, @p287 as c8 union all
    select @rowguid33 as rowguid, @setbm33 as setbm, @metadata_type33 as metadata_type, @lineage_old33 as lineage_old, @p289 as c1, @p291 as c3, @p292 as c4, @p293 as c5, @p294 as c6, @p295 as c7, @p296 as c8 union all
    select @rowguid34 as rowguid, @setbm34 as setbm, @metadata_type34 as metadata_type, @lineage_old34 as lineage_old, @p298 as c1, @p300 as c3, @p301 as c4, @p302 as c5, @p303 as c6, @p304 as c7, @p305 as c8 union all
    select @rowguid35 as rowguid, @setbm35 as setbm, @metadata_type35 as metadata_type, @lineage_old35 as lineage_old, @p307 as c1, @p309 as c3
, @p310 as c4, @p311 as c5, @p312 as c6, @p313 as c7, @p314 as c8 union all
    select @rowguid36 as rowguid, @setbm36 as setbm, @metadata_type36 as metadata_type, @lineage_old36 as lineage_old, @p316 as c1, @p318 as c3, @p319 as c4, @p320 as c5, @p321 as c6, @p322 as c7, @p323 as c8 union all
    select @rowguid37 as rowguid, @setbm37 as setbm, @metadata_type37 as metadata_type, @lineage_old37 as lineage_old, @p325 as c1, @p327 as c3, @p328 as c4, @p329 as c5, @p330 as c6, @p331 as c7, @p332 as c8 union all
    select @rowguid38 as rowguid, @setbm38 as setbm, @metadata_type38 as metadata_type, @lineage_old38 as lineage_old, @p334 as c1, @p336 as c3, @p337 as c4, @p338 as c5, @p339 as c6, @p340 as c7, @p341 as c8 union all
    select @rowguid39 as rowguid, @setbm39 as setbm, @metadata_type39 as metadata_type, @lineage_old39 as lineage_old, @p343 as c1, @p345 as c3, @p346 as c4, @p347 as c5, @p348 as c6, @p349 as c7, @p350 as c8 union all
    select @rowguid40 as rowguid, @setbm40 as setbm, @metadata_type40 as metadata_type, @lineage_old40 as lineage_old, @p352 as c1, @p354 as c3, @p355 as c4, @p356 as c5, @p357 as c6, @p358 as c7, @p359 as c8 union all
    select @rowguid41 as rowguid, @setbm41 as setbm, @metadata_type41 as metadata_type, @lineage_old41 as lineage_old, @p361 as c1, @p363 as c3, @p364 as c4, @p365 as c5, @p366 as c6, @p367 as c7, @p368 as c8 union all
    select @rowguid42 as rowguid, @setbm42 as setbm, @metadata_type42 as metadata_type, @lineage_old42 as lineage_old, @p370 as c1, @p372 as c3, @p373 as c4, @p374 as c5, @p375 as c6, @p376 as c7, @p377 as c8 union all
    select @rowguid43 as rowguid, @setbm43 as setbm, @metadata_type43 as metadata_type, @lineage_old43 as lineage_old, @p379 as c1, @p381 as c3, @p382 as c4, @p383 as c5, @p384 as c6, @p385 as c7, @p386 as c8 union all
    select @rowguid44 as rowguid, @setbm44 as setbm, @metadata_type44 as metadata_type, @lineage_old44 as lineage_old, @p388 as c1, @p390 as c3, @p391 as c4, @p392 as c5, @p393 as c6, @p394 as c7, @p395 as c8 union all
    select @rowguid45 as rowguid, @setbm45 as setbm, @metadata_type45 as metadata_type, @lineage_old45 as lineage_old, @p397 as c1, @p399 as c3, @p400 as c4, @p401 as c5, @p402 as c6, @p403 as c7, @p404 as c8 union all
    select @rowguid46 as rowguid, @setbm46 as setbm, @metadata_type46 as metadata_type, @lineage_old46 as lineage_old, @p406 as c1, @p408 as c3, @p409 as c4, @p410 as c5, @p411 as c6, @p412 as c7, @p413 as c8 union all
    select @rowguid47 as rowguid, @setbm47 as setbm, @metadata_type47 as metadata_type, @lineage_old47 as lineage_old, @p415 as c1, @p417 as c3, @p418 as c4, @p419 as c5, @p420 as c6, @p421 as c7, @p422 as c8 union all
    select @rowguid48 as rowguid, @setbm48 as setbm, @metadata_type48 as metadata_type, @lineage_old48 as lineage_old, @p424 as c1, @p426 as c3, @p427 as c4, @p428 as c5, @p429 as c6, @p430 as c7, @p431 as c8 union all
    select @rowguid49 as rowguid, @setbm49 as setbm, @metadata_type49 as metadata_type, @lineage_old49 as lineage_old, @p433 as c1, @p435 as c3, @p436 as c4, @p437 as c5, @p438 as c6, @p439 as c7, @p440 as c8 union all
    select @rowguid50 as rowguid, @setbm50 as setbm, @metadata_type50 as metadata_type, @lineage_old50 as lineage_old, @p442 as c1, @p444 as c3, @p445 as c4, @p446 as c5, @p447 as c6, @p448 as c7, @p449 as c8 union all
    select @rowguid51 as rowguid, @setbm51 as setbm, @metadata_type51 as metadata_type, @lineage_old51 as lineage_old, @p451 as c1, @p453 as c3, @p454 as c4, @p455 as c5, @p456 as c6, @p457 as c7, @p458 as c8 union all
    select @rowguid52 as rowguid, @setbm52 as setbm, @metadata_type52 as metadata_type, @lineage_old52 as lineage_old, @p460 as c1, @p462 as c3, @p463 as c4
, @p464 as c5, @p465 as c6, @p466 as c7, @p467 as c8 union all
    select @rowguid53 as rowguid, @setbm53 as setbm, @metadata_type53 as metadata_type, @lineage_old53 as lineage_old, @p469 as c1, @p471 as c3, @p472 as c4, @p473 as c5, @p474 as c6, @p475 as c7, @p476 as c8 union all
    select @rowguid54 as rowguid, @setbm54 as setbm, @metadata_type54 as metadata_type, @lineage_old54 as lineage_old, @p478 as c1, @p480 as c3, @p481 as c4, @p482 as c5, @p483 as c6, @p484 as c7, @p485 as c8 union all
    select @rowguid55 as rowguid, @setbm55 as setbm, @metadata_type55 as metadata_type, @lineage_old55 as lineage_old, @p487 as c1, @p489 as c3, @p490 as c4, @p491 as c5, @p492 as c6, @p493 as c7, @p494 as c8 union all
    select @rowguid56 as rowguid, @setbm56 as setbm, @metadata_type56 as metadata_type, @lineage_old56 as lineage_old, @p496 as c1, @p498 as c3, @p499 as c4, @p500 as c5, @p501 as c6, @p502 as c7, @p503 as c8 union all
    select @rowguid57 as rowguid, @setbm57 as setbm, @metadata_type57 as metadata_type, @lineage_old57 as lineage_old, @p505 as c1, @p507 as c3, @p508 as c4, @p509 as c5, @p510 as c6, @p511 as c7, @p512 as c8 union all
    select @rowguid58 as rowguid, @setbm58 as setbm, @metadata_type58 as metadata_type, @lineage_old58 as lineage_old, @p514 as c1, @p516 as c3, @p517 as c4, @p518 as c5, @p519 as c6, @p520 as c7, @p521 as c8 union all
    select @rowguid59 as rowguid, @setbm59 as setbm, @metadata_type59 as metadata_type, @lineage_old59 as lineage_old, @p523 as c1, @p525 as c3, @p526 as c4, @p527 as c5, @p528 as c6, @p529 as c7, @p530 as c8 union all
    select @rowguid60 as rowguid, @setbm60 as setbm, @metadata_type60 as metadata_type, @lineage_old60 as lineage_old, @p532 as c1, @p534 as c3, @p535 as c4, @p536 as c5, @p537 as c6, @p538 as c7, @p539 as c8 union all
    select @rowguid61 as rowguid, @setbm61 as setbm, @metadata_type61 as metadata_type, @lineage_old61 as lineage_old, @p541 as c1, @p543 as c3, @p544 as c4, @p545 as c5, @p546 as c6, @p547 as c7, @p548 as c8 union all
    select @rowguid62 as rowguid, @setbm62 as setbm, @metadata_type62 as metadata_type, @lineage_old62 as lineage_old, @p550 as c1, @p552 as c3, @p553 as c4, @p554 as c5, @p555 as c6, @p556 as c7, @p557 as c8 union all
    select @rowguid63 as rowguid, @setbm63 as setbm, @metadata_type63 as metadata_type, @lineage_old63 as lineage_old, @p559 as c1
, @p561 as c3
, @p562 as c4
, @p563 as c5
, @p564 as c6
, @p565 as c7
, @p566 as c8
) as rows
    inner join [dbo].[Account] t with (rowlock) on rows.rowguid = t.[rowguid]
        and rows.rowguid is not null
    left outer join dbo.MSmerge_contents cont with (rowlock) on rows.rowguid = cont.rowguid 
    and cont.tablenick = 26466000
    where  ((rows.metadata_type = 2 and cont.rowguid is not NULL and cont.lineage = rows.lineage_old) or
           (rows.metadata_type = 3 and cont.rowguid is NULL))
           and rows.rowguid is not null
    
    select @rowcount = @@rowcount, @error = @@error

    select @rows_updated = @rowcount
    if (@rows_updated <> @rows_tobe_updated) or (@error <> 0)
    begin
        raiserror(20695, 16, -1, @rows_updated, @rows_tobe_updated, 'Account')
        set @errcode= 3
        goto Failure
    end

    update dbo.MSmerge_contents with (rowlock)
    set generation = rows.generation,
        lineage = rows.lineage_new,
        colv1 = rows.colv
    from (

    select @rowguid1 as rowguid, @generation1 as generation, @lineage_new1 as lineage_new, @colv1 as colv union all
    select @rowguid2 as rowguid, @generation2 as generation, @lineage_new2 as lineage_new, @colv2 as colv union all
    select @rowguid3 as rowguid, @generation3 as generation, @lineage_new3 as lineage_new, @colv3 as colv union all
    select @rowguid4 as rowguid, @generation4 as generation, @lineage_new4 as lineage_new, @colv4 as colv union all
    select @rowguid5 as rowguid, @generation5 as generation, @lineage_new5 as lineage_new, @colv5 as colv union all
    select @rowguid6 as rowguid, @generation6 as generation, @lineage_new6 as lineage_new, @colv6 as colv union all
    select @rowguid7 as rowguid, @generation7 as generation, @lineage_new7 as lineage_new, @colv7 as colv union all
    select @rowguid8 as rowguid, @generation8 as generation, @lineage_new8 as lineage_new, @colv8 as colv union all
    select @rowguid9 as rowguid, @generation9 as generation, @lineage_new9 as lineage_new, @colv9 as colv union all
    select @rowguid10 as rowguid, @generation10 as generation, @lineage_new10 as lineage_new, @colv10 as colv union all
    select @rowguid11 as rowguid, @generation11 as generation, @lineage_new11 as lineage_new, @colv11 as colv union all
    select @rowguid12 as rowguid, @generation12 as generation, @lineage_new12 as lineage_new, @colv12 as colv union all
    select @rowguid13 as rowguid, @generation13 as generation, @lineage_new13 as lineage_new, @colv13 as colv union all
    select @rowguid14 as rowguid, @generation14 as generation, @lineage_new14 as lineage_new, @colv14 as colv union all
    select @rowguid15 as rowguid, @generation15 as generation, @lineage_new15 as lineage_new, @colv15 as colv union all
    select @rowguid16 as rowguid, @generation16 as generation, @lineage_new16 as lineage_new, @colv16 as colv union all
    select @rowguid17 as rowguid, @generation17 as generation, @lineage_new17 as lineage_new, @colv17 as colv union all
    select @rowguid18 as rowguid, @generation18 as generation, @lineage_new18 as lineage_new, @colv18 as colv union all
    select @rowguid19 as rowguid, @generation19 as generation, @lineage_new19 as lineage_new, @colv19 as colv union all
    select @rowguid20 as rowguid, @generation20 as generation, @lineage_new20 as lineage_new, @colv20 as colv union all
    select @rowguid21 as rowguid, @generation21 as generation, @lineage_new21 as lineage_new, @colv21 as colv union all
    select @rowguid22 as rowguid, @generation22 as generation, @lineage_new22 as lineage_new, @colv22 as colv union all
    select @rowguid23 as rowguid, @generation23 as generation, @lineage_new23 as lineage_new, @colv23 as colv union all
    select @rowguid24 as rowguid, @generation24 as generation, @lineage_new24 as lineage_new, @colv24 as colv union all
    select @rowguid25 as rowguid, @generation25 as generation, @lineage_new25 as lineage_new, @colv25 as colv union all
    select @rowguid26 as rowguid, @generation26 as generation, @lineage_new26 as lineage_new, @colv26 as colv union all
    select @rowguid27 as rowguid, @generation27 as generation, @lineage_new27 as lineage_new, @colv27 as colv union all
    select @rowguid28 as rowguid, @generation28 as generation, @lineage_new28 as lineage_new, @colv28 as colv union all
    select @rowguid29 as rowguid, @generation29 as generation, @lineage_new29 as lineage_new, @colv29 as colv union all
    select @rowguid30 as rowguid, @generation30 as generation, @lineage_new30 as lineage_new, @colv30 as colv union all
    select @rowguid31 as rowguid, @generation31 as generation, @lineage_new31 as lineage_new, @colv31 as colv union all
    select @rowguid32 as rowguid, @generation32 as generation, @lineage_new32 as lineage_new, @colv32 as colv
 union all
    select @rowguid33 as rowguid, @generation33 as generation, @lineage_new33 as lineage_new, @colv33 as colv union all
    select @rowguid34 as rowguid, @generation34 as generation, @lineage_new34 as lineage_new, @colv34 as colv union all
    select @rowguid35 as rowguid, @generation35 as generation, @lineage_new35 as lineage_new, @colv35 as colv union all
    select @rowguid36 as rowguid, @generation36 as generation, @lineage_new36 as lineage_new, @colv36 as colv union all
    select @rowguid37 as rowguid, @generation37 as generation, @lineage_new37 as lineage_new, @colv37 as colv union all
    select @rowguid38 as rowguid, @generation38 as generation, @lineage_new38 as lineage_new, @colv38 as colv union all
    select @rowguid39 as rowguid, @generation39 as generation, @lineage_new39 as lineage_new, @colv39 as colv union all
    select @rowguid40 as rowguid, @generation40 as generation, @lineage_new40 as lineage_new, @colv40 as colv union all
    select @rowguid41 as rowguid, @generation41 as generation, @lineage_new41 as lineage_new, @colv41 as colv union all
    select @rowguid42 as rowguid, @generation42 as generation, @lineage_new42 as lineage_new, @colv42 as colv union all
    select @rowguid43 as rowguid, @generation43 as generation, @lineage_new43 as lineage_new, @colv43 as colv union all
    select @rowguid44 as rowguid, @generation44 as generation, @lineage_new44 as lineage_new, @colv44 as colv union all
    select @rowguid45 as rowguid, @generation45 as generation, @lineage_new45 as lineage_new, @colv45 as colv union all
    select @rowguid46 as rowguid, @generation46 as generation, @lineage_new46 as lineage_new, @colv46 as colv union all
    select @rowguid47 as rowguid, @generation47 as generation, @lineage_new47 as lineage_new, @colv47 as colv union all
    select @rowguid48 as rowguid, @generation48 as generation, @lineage_new48 as lineage_new, @colv48 as colv union all
    select @rowguid49 as rowguid, @generation49 as generation, @lineage_new49 as lineage_new, @colv49 as colv union all
    select @rowguid50 as rowguid, @generation50 as generation, @lineage_new50 as lineage_new, @colv50 as colv union all
    select @rowguid51 as rowguid, @generation51 as generation, @lineage_new51 as lineage_new, @colv51 as colv union all
    select @rowguid52 as rowguid, @generation52 as generation, @lineage_new52 as lineage_new, @colv52 as colv union all
    select @rowguid53 as rowguid, @generation53 as generation, @lineage_new53 as lineage_new, @colv53 as colv union all
    select @rowguid54 as rowguid, @generation54 as generation, @lineage_new54 as lineage_new, @colv54 as colv union all
    select @rowguid55 as rowguid, @generation55 as generation, @lineage_new55 as lineage_new, @colv55 as colv union all
    select @rowguid56 as rowguid, @generation56 as generation, @lineage_new56 as lineage_new, @colv56 as colv union all
    select @rowguid57 as rowguid, @generation57 as generation, @lineage_new57 as lineage_new, @colv57 as colv union all
    select @rowguid58 as rowguid, @generation58 as generation, @lineage_new58 as lineage_new, @colv58 as colv union all
    select @rowguid59 as rowguid, @generation59 as generation, @lineage_new59 as lineage_new, @colv59 as colv union all
    select @rowguid60 as rowguid, @generation60 as generation, @lineage_new60 as lineage_new, @colv60 as colv union all
    select @rowguid61 as rowguid, @generation61 as generation, @lineage_new61 as lineage_new, @colv61 as colv union all
    select @rowguid62 as rowguid, @generation62 as generation, @lineage_new62 as lineage_new, @colv62 as colv union all
    select @rowguid63 as rowguid, @generation63 as generation, @lineage_new63 as lineage_new, @colv63 as colv

    ) as rows
    inner join dbo.MSmerge_contents cont with (rowlock) 
    on cont.rowguid = rows.rowguid and cont.tablenick = 26466000
    and rows.rowguid is not NULL 
    and rows.lineage_new is not NULL
    option (force order, loop join)
    select @cont_rows_updated = @@rowcount, @error = @@error
    if @error<>0
    begin
        set @errcode= 3
        goto Failure
    end

    if @cont_rows_updated <> @rows_tobe_updated
    begin

        insert into dbo.MSmerge_contents with (rowlock)
        (tablenick, rowguid, lineage, colv1, generation)
        select 26466000, rows.rowguid, rows.lineage_new, rows.colv, rows.generation
        from (

    select @rowguid1 as rowguid, @generation1 as generation, @lineage_new1 as lineage_new, @colv1 as colv union all
    select @rowguid2 as rowguid, @generation2 as generation, @lineage_new2 as lineage_new, @colv2 as colv union all
    select @rowguid3 as rowguid, @generation3 as generation, @lineage_new3 as lineage_new, @colv3 as colv union all
    select @rowguid4 as rowguid, @generation4 as generation, @lineage_new4 as lineage_new, @colv4 as colv union all
    select @rowguid5 as rowguid, @generation5 as generation, @lineage_new5 as lineage_new, @colv5 as colv union all
    select @rowguid6 as rowguid, @generation6 as generation, @lineage_new6 as lineage_new, @colv6 as colv union all
    select @rowguid7 as rowguid, @generation7 as generation, @lineage_new7 as lineage_new, @colv7 as colv union all
    select @rowguid8 as rowguid, @generation8 as generation, @lineage_new8 as lineage_new, @colv8 as colv union all
    select @rowguid9 as rowguid, @generation9 as generation, @lineage_new9 as lineage_new, @colv9 as colv union all
    select @rowguid10 as rowguid, @generation10 as generation, @lineage_new10 as lineage_new, @colv10 as colv union all
    select @rowguid11 as rowguid, @generation11 as generation, @lineage_new11 as lineage_new, @colv11 as colv union all
    select @rowguid12 as rowguid, @generation12 as generation, @lineage_new12 as lineage_new, @colv12 as colv union all
    select @rowguid13 as rowguid, @generation13 as generation, @lineage_new13 as lineage_new, @colv13 as colv union all
    select @rowguid14 as rowguid, @generation14 as generation, @lineage_new14 as lineage_new, @colv14 as colv union all
    select @rowguid15 as rowguid, @generation15 as generation, @lineage_new15 as lineage_new, @colv15 as colv union all
    select @rowguid16 as rowguid, @generation16 as generation, @lineage_new16 as lineage_new, @colv16 as colv union all
    select @rowguid17 as rowguid, @generation17 as generation, @lineage_new17 as lineage_new, @colv17 as colv union all
    select @rowguid18 as rowguid, @generation18 as generation, @lineage_new18 as lineage_new, @colv18 as colv union all
    select @rowguid19 as rowguid, @generation19 as generation, @lineage_new19 as lineage_new, @colv19 as colv union all
    select @rowguid20 as rowguid, @generation20 as generation, @lineage_new20 as lineage_new, @colv20 as colv union all
    select @rowguid21 as rowguid, @generation21 as generation, @lineage_new21 as lineage_new, @colv21 as colv union all
    select @rowguid22 as rowguid, @generation22 as generation, @lineage_new22 as lineage_new, @colv22 as colv union all
    select @rowguid23 as rowguid, @generation23 as generation, @lineage_new23 as lineage_new, @colv23 as colv union all
    select @rowguid24 as rowguid, @generation24 as generation, @lineage_new24 as lineage_new, @colv24 as colv union all
    select @rowguid25 as rowguid, @generation25 as generation, @lineage_new25 as lineage_new, @colv25 as colv union all
    select @rowguid26 as rowguid, @generation26 as generation, @lineage_new26 as lineage_new, @colv26 as colv union all
    select @rowguid27 as rowguid, @generation27 as generation, @lineage_new27 as lineage_new, @colv27 as colv union all
    select @rowguid28 as rowguid, @generation28 as generation, @lineage_new28 as lineage_new, @colv28 as colv union all
    select @rowguid29 as rowguid, @generation29 as generation, @lineage_new29 as lineage_new, @colv29 as colv union all
    select @rowguid30 as rowguid, @generation30 as generation, @lineage_new30 as lineage_new, @colv30 as colv union all
    select @rowguid31 as rowguid, @generation31 as generation, @lineage_new31 as lineage_new, @colv31 as colv union all
    select @rowguid32 as rowguid, @generation32 as generation, @lineage_new32 as lineage_new, @colv32 as colv
 union all
    select @rowguid33 as rowguid, @generation33 as generation, @lineage_new33 as lineage_new, @colv33 as colv union all
    select @rowguid34 as rowguid, @generation34 as generation, @lineage_new34 as lineage_new, @colv34 as colv union all
    select @rowguid35 as rowguid, @generation35 as generation, @lineage_new35 as lineage_new, @colv35 as colv union all
    select @rowguid36 as rowguid, @generation36 as generation, @lineage_new36 as lineage_new, @colv36 as colv union all
    select @rowguid37 as rowguid, @generation37 as generation, @lineage_new37 as lineage_new, @colv37 as colv union all
    select @rowguid38 as rowguid, @generation38 as generation, @lineage_new38 as lineage_new, @colv38 as colv union all
    select @rowguid39 as rowguid, @generation39 as generation, @lineage_new39 as lineage_new, @colv39 as colv union all
    select @rowguid40 as rowguid, @generation40 as generation, @lineage_new40 as lineage_new, @colv40 as colv union all
    select @rowguid41 as rowguid, @generation41 as generation, @lineage_new41 as lineage_new, @colv41 as colv union all
    select @rowguid42 as rowguid, @generation42 as generation, @lineage_new42 as lineage_new, @colv42 as colv union all
    select @rowguid43 as rowguid, @generation43 as generation, @lineage_new43 as lineage_new, @colv43 as colv union all
    select @rowguid44 as rowguid, @generation44 as generation, @lineage_new44 as lineage_new, @colv44 as colv union all
    select @rowguid45 as rowguid, @generation45 as generation, @lineage_new45 as lineage_new, @colv45 as colv union all
    select @rowguid46 as rowguid, @generation46 as generation, @lineage_new46 as lineage_new, @colv46 as colv union all
    select @rowguid47 as rowguid, @generation47 as generation, @lineage_new47 as lineage_new, @colv47 as colv union all
    select @rowguid48 as rowguid, @generation48 as generation, @lineage_new48 as lineage_new, @colv48 as colv union all
    select @rowguid49 as rowguid, @generation49 as generation, @lineage_new49 as lineage_new, @colv49 as colv union all
    select @rowguid50 as rowguid, @generation50 as generation, @lineage_new50 as lineage_new, @colv50 as colv union all
    select @rowguid51 as rowguid, @generation51 as generation, @lineage_new51 as lineage_new, @colv51 as colv union all
    select @rowguid52 as rowguid, @generation52 as generation, @lineage_new52 as lineage_new, @colv52 as colv union all
    select @rowguid53 as rowguid, @generation53 as generation, @lineage_new53 as lineage_new, @colv53 as colv union all
    select @rowguid54 as rowguid, @generation54 as generation, @lineage_new54 as lineage_new, @colv54 as colv union all
    select @rowguid55 as rowguid, @generation55 as generation, @lineage_new55 as lineage_new, @colv55 as colv union all
    select @rowguid56 as rowguid, @generation56 as generation, @lineage_new56 as lineage_new, @colv56 as colv union all
    select @rowguid57 as rowguid, @generation57 as generation, @lineage_new57 as lineage_new, @colv57 as colv union all
    select @rowguid58 as rowguid, @generation58 as generation, @lineage_new58 as lineage_new, @colv58 as colv union all
    select @rowguid59 as rowguid, @generation59 as generation, @lineage_new59 as lineage_new, @colv59 as colv union all
    select @rowguid60 as rowguid, @generation60 as generation, @lineage_new60 as lineage_new, @colv60 as colv union all
    select @rowguid61 as rowguid, @generation61 as generation, @lineage_new61 as lineage_new, @colv61 as colv union all
    select @rowguid62 as rowguid, @generation62 as generation, @lineage_new62 as lineage_new, @colv62 as colv union all
    select @rowguid63 as rowguid, @generation63 as generation, @lineage_new63 as lineage_new, @colv63 as colv

        ) as rows
        left outer join dbo.MSmerge_contents cont with (rowlock) 
        on cont.rowguid = rows.rowguid and cont.tablenick = 26466000
        and rows.rowguid is not NULL
        and rows.lineage_new is not NULL
        where cont.rowguid is NULL
        and rows.rowguid is not NULL
        and rows.lineage_new is not NULL
        
        if @@error<>0
        begin
            set @errcode= 3
            goto Failure
        end
    end

    exec @retcode = sys.sp_MSdeletemetadataactionrequest '9DEE015E-1388-43B6-BDF0-8C2967FBB918', 26466000, 
        @rowguid1, 
        @rowguid2, 
        @rowguid3, 
        @rowguid4, 
        @rowguid5, 
        @rowguid6, 
        @rowguid7, 
        @rowguid8, 
        @rowguid9, 
        @rowguid10, 
        @rowguid11, 
        @rowguid12, 
        @rowguid13, 
        @rowguid14, 
        @rowguid15, 
        @rowguid16, 
        @rowguid17, 
        @rowguid18, 
        @rowguid19, 
        @rowguid20, 
        @rowguid21, 
        @rowguid22, 
        @rowguid23, 
        @rowguid24, 
        @rowguid25, 
        @rowguid26, 
        @rowguid27, 
        @rowguid28, 
        @rowguid29, 
        @rowguid30, 
        @rowguid31, 
        @rowguid32, 
        @rowguid33, 
        @rowguid34, 
        @rowguid35, 
        @rowguid36, 
        @rowguid37, 
        @rowguid38, 
        @rowguid39, 
        @rowguid40, 
        @rowguid41, 
        @rowguid42, 
        @rowguid43, 
        @rowguid44, 
        @rowguid45, 
        @rowguid46, 
        @rowguid47, 
        @rowguid48, 
        @rowguid49, 
        @rowguid50, 
        @rowguid51, 
        @rowguid52, 
        @rowguid53, 
        @rowguid54, 
        @rowguid55, 
        @rowguid56, 
        @rowguid57, 
        @rowguid58, 
        @rowguid59, 
        @rowguid60, 
        @rowguid61, 
        @rowguid62, 
        @rowguid63
    if @retcode<>0 or @@error<>0
        goto Failure
    

    commit tran
    return 1

Failure:
    rollback tran batchupdateproc
    commit tran
    return 0
end


go

update dbo.sysmergepartitioninfo 
    set column_list = N't.*', 
        column_list_blob = N't.*'
    where artid = '5760AC0D-EF43-42F8-8C02-BC61E110C745' and pubid = '9DEE015E-1388-43B6-BDF0-8C2967FBB918'

go
SET ANSI_NULLS ON SET QUOTED_IDENTIFIER ON

go

    create procedure dbo.[MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6] (
        @maxschemaguidforarticle uniqueidentifier,
        @type int output, 
        @rowguid uniqueidentifier=NULL,
        @enumentirerowmetadata bit= 1,
        @blob_cols_at_the_end bit=0,
        @logical_record_parent_rowguid uniqueidentifier = '00000000-0000-0000-0000-000000000000',
        @metadata_type tinyint = 0,
        @lineage_old varbinary(311) = NULL,
        @rowcount int = NULL output
        ) 
    as
    begin
        declare @retcode    int
        
        set nocount on
            
        if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
        begin       
            RAISERROR (14126, 11, -1)
            return (1)
        end 

    if @type = 1
        begin
            select 
t.*
          from [dbo].[Account] t where rowguidcol = @rowguid
        if @@ERROR<>0 return(1)
    end 
    else if @type < 4 
        begin
            -- case one: no blob gen optimization
            if @blob_cols_at_the_end=0
            begin
                select 
                c.tablenick, 
                c.rowguid, 
                c.generation,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.lineage
                end as lineage,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.colv1
                end as colv1,
                
t.*

                from #cont c , [dbo].[Account] t with (rowlock)
                where t.rowguidcol = c.rowguid
                order by t.rowguidcol 
                
            if @@ERROR<>0 return(1)
            end
  
            -- case two: blob gen optimization
            else 
            begin
                select 
                c.tablenick, 
                c.rowguid, 
                c.generation,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.lineage
                end as lineage,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.colv1
                end as colv1,
t.*

                from #cont c,[dbo].[Account] t with (rowlock)
              where t.rowguidcol = c.rowguid
                 order by t.rowguidcol 
                 
            if @@ERROR<>0 return(1)
            end
        end
   else if @type = 4
    begin
        set @type = 0
        if exists (select * from [dbo].[Account] where rowguidcol = @rowguid)
            set @type = 3
        if @@ERROR<>0 return(1)
    end

    else if @type = 5
    begin
         
        delete [dbo].[Account] where rowguidcol = @rowguid
        if @@ERROR<>0 return(1)

        delete from dbo.MSmerge_metadataaction_request
            where tablenick=26466000 and rowguid=@rowguid
    end 

    else if @type = 6 -- sp_MSenumcolumns
    begin
        select 
t.*
         from [dbo].[Account] t where 1=2
        if @@ERROR<>0 return(1)
    end

    else if @type = 7 -- sp_MSlocktable
    begin
        select 1 from [dbo].[Account] with (tablock holdlock) where 1 = 2
        if @@ERROR<>0 return(1)
    end

    else if @type = 8 -- put update lock
    begin
        if not exists (select * from [dbo].[Account] with (UPDLOCK HOLDLOCK) where rowguidcol = @rowguid)
        begin
            RAISERROR(20031 , 16, -1)
            return(1)
        end
    end
    else if @type = 9
    begin
        declare @oldmaxversion int, @replnick binary(6)
                , @cur_article_rowcount int, @column_tracking int
                        
        select @replnick = 0x13889dee015e

        select top 1 @oldmaxversion = maxversion_at_cleanup,
                     @column_tracking = column_tracking
        from dbo.sysmergearticles 
        where nickname = 26466000
        
        select @cur_article_rowcount = count(*) from #rows 
        where tablenick = 26466000
            
        update dbo.MSmerge_contents 
        set lineage = { fn UPDATELINEAGE(lineage, @replnick, @oldmaxversion+1) }
        where tablenick = 26466000
        and rowguid in (select rowguid from #rows where tablenick = 26466000) 

        if @@rowcount <> @cur_article_rowcount
        begin
            declare @lineage varbinary(311), @colv1 varbinary(1)
                    , @cur_rowguid uniqueidentifier, @prev_rowguid uniqueidentifier
            set @lineage = { fn UPDATELINEAGE(0x0, @replnick, @oldmaxversion+1) }
            if @column_tracking <> 0
                set @colv1 = 0xFF
            else
                set @colv1 = NULL
                
            select top 1 @cur_rowguid = rowguid from #rows
            where tablenick = 26466000
            order by rowguid
            
            while @cur_rowguid is not null
            begin
                if not exists (select * from dbo.MSmerge_contents 
                                where tablenick = 26466000
                                and rowguid = @cur_rowguid)
                begin
                    begin tran 
                    save tran insert_contents_row 

                    if exists (select * from [dbo].[Account]with (holdlock) where rowguidcol = @cur_rowguid)
                    begin
                        exec @retcode = sys.sp_MSevaluate_change_membership_for_row @tablenick = 26466000, @rowguid = @cur_rowguid
                        if @retcode <> 0 or @@error <> 0
                        begin
                            rollback tran insert_contents_row
                            return 1
                        end
                        insert into dbo.MSmerge_contents (rowguid, tablenick, generation, lineage, colv1, logical_record_parent_rowguid)
                            values (@cur_rowguid, 26466000, 0, @lineage, @colv1, @logical_record_parent_rowguid)
                    end
                    commit tran
                end
                
                select @prev_rowguid = @cur_rowguid
                select @cur_rowguid = NULL
                
                select top 1 @cur_rowguid = rowguid from #rows
                where tablenick = 26466000
                and rowguid > @prev_rowguid
                order by rowguid
            end
        end 

        select 
            r.tablenick, 
            r.rowguid, 
            mc.generation,
            case @enumentirerowmetadata
                when 0 then null
                else mc.lineage
            end,
            case @enumentirerowmetadata
                when 0 then null
                else mc.colv1
            end,
            
t.*
         from #rows r left outer join [dbo].[Account] t on r.rowguid = t.rowguidcol and r.tablenick = 26466000
                 left outer join dbo.MSmerge_contents mc on
                 mc.tablenick = 26466000 and mc.rowguid = t.rowguidcol
                 where r.tablenick = 26466000
         order by r.idx
         
        if @@ERROR<>0 return(1)
    end 

        else if @type = 10  
        begin
            select 
                c.tablenick, 
                c.rowguid, 
                c.generation,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.lineage
                end,
                case @enumentirerowmetadata
                    when 0 then null
                    else c.colv1
                end,
                null,
                
t.*
         from #cont c,[dbo].[Account] t with (rowlock) where
                      t.rowguidcol = c.rowguid
             order by t.rowguidcol 
                        
            if @@ERROR<>0 return(1)
        end

    else if @type = 11
    begin
         
        -- we will do a delete with metadata match
        if @metadata_type = 0
        begin
            delete from [dbo].[Account] where [rowguid] = @rowguid
            select @rowcount = @@rowcount
            if @rowcount <> 1
            begin
                RAISERROR(20031 , 16, -1)
                return(1)
            end
        end
        else
        begin
            if @metadata_type = 3
                delete [dbo].[Account] from [dbo].[Account] t
                    where t.[rowguid] = @rowguid and 
                        not exists (select 1 from dbo.MSmerge_contents c with (rowlock) where
                                                c.rowguid = @rowguid and
                                                c.tablenick = 26466000)
            else if @metadata_type = 5 or @metadata_type = 6
                delete [dbo].[Account] from [dbo].[Account] t
                    where t.[rowguid] = @rowguid and 
                         not exists (select 1 from dbo.MSmerge_contents c with (rowlock) where
                                                c.rowguid = @rowguid and
                                                c.tablenick = 26466000 and
                                                c.lineage <> @lineage_old)
                                                
            else
                delete [dbo].[Account] from [dbo].[Account] t
                    where t.[rowguid] = @rowguid and 
                         exists (select 1 from dbo.MSmerge_contents c with (rowlock) where
                                                c.rowguid = @rowguid and
                                                c.tablenick = 26466000 and
                                                c.lineage = @lineage_old)
            select @rowcount = @@rowcount
            if @rowcount <> 1 
            begin
                if not exists (select * from [dbo].[Account] where [rowguid] = @rowguid)
                begin
                    RAISERROR(20031 , 16, -1)
                    return(1)
                end
            end
        end
        if @@ERROR<>0 
        begin
            delete from dbo.MSmerge_metadataaction_request
                where tablenick=26466000 and rowguid=@rowguid

            return(1)
        end        
    end

    else if @type = 12
    begin 
        -- this type indicates metadata type selection
        declare @maxversion int
        declare @error int
        
        select @maxversion= maxversion_at_cleanup from dbo.sysmergearticles 
            where nickname = 26466000 and pubid = '9DEE015E-1388-43B6-BDF0-8C2967FBB918'
        if @error <> 0 
            return 1
        select case when (cont.generation is NULL and tomb.generation is null) 
                    then 0 
                    else isnull(cont.generation, tomb.generation) 
               end as generation, 
               case when t.[rowguid] is null 
                    then (case when tomb.rowguid is NULL then 0 else tomb.type end) 
                    else (case when cont.rowguid is null then 3 else 2 end) 
               end as type,
               case when tomb.rowguid is null 
                    then cont.lineage 
                    else tomb.lineage
               end as lineage, 
               cont.colv1 as colv, 
               @maxversion as maxversion
        from
        (select @rowguid as rowguid) as rows 
        left outer join [dbo].[Account] t with (rowlock) 
        on t.[rowguid] = rows.rowguid
        and rows.rowguid is not null
        left outer join dbo.MSmerge_contents cont with (rowlock) 
        on cont.rowguid = rows.rowguid and cont.tablenick = 26466000
        left outer join dbo.MSmerge_tombstone tomb with (rowlock) 
        on tomb.rowguid = rows.rowguid and tomb.tablenick = 26466000
        where rows.rowguid is not null
        
        select @error = @@error
        if @error <> 0 
        begin
            --raiserror(@error, 16, -1)
            return 1
        end
    end

    return(0)
end


go

create procedure dbo.[MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6_metadata]
( 
    @rowguid1 uniqueidentifier,
    @rowguid2 uniqueidentifier = NULL,
    @rowguid3 uniqueidentifier = NULL,
    @rowguid4 uniqueidentifier = NULL,
    @rowguid5 uniqueidentifier = NULL,
    @rowguid6 uniqueidentifier = NULL,
    @rowguid7 uniqueidentifier = NULL,
    @rowguid8 uniqueidentifier = NULL,
    @rowguid9 uniqueidentifier = NULL,
    @rowguid10 uniqueidentifier = NULL,
    @rowguid11 uniqueidentifier = NULL,
    @rowguid12 uniqueidentifier = NULL,
    @rowguid13 uniqueidentifier = NULL,
    @rowguid14 uniqueidentifier = NULL,
    @rowguid15 uniqueidentifier = NULL,
    @rowguid16 uniqueidentifier = NULL,
    @rowguid17 uniqueidentifier = NULL,
    @rowguid18 uniqueidentifier = NULL,
    @rowguid19 uniqueidentifier = NULL,
    @rowguid20 uniqueidentifier = NULL,
    @rowguid21 uniqueidentifier = NULL,
    @rowguid22 uniqueidentifier = NULL,
    @rowguid23 uniqueidentifier = NULL,
    @rowguid24 uniqueidentifier = NULL,
    @rowguid25 uniqueidentifier = NULL,
    @rowguid26 uniqueidentifier = NULL,
    @rowguid27 uniqueidentifier = NULL,
    @rowguid28 uniqueidentifier = NULL,
    @rowguid29 uniqueidentifier = NULL,
    @rowguid30 uniqueidentifier = NULL,
    @rowguid31 uniqueidentifier = NULL,
    @rowguid32 uniqueidentifier = NULL,
    @rowguid33 uniqueidentifier = NULL,
    @rowguid34 uniqueidentifier = NULL,
    @rowguid35 uniqueidentifier = NULL,
    @rowguid36 uniqueidentifier = NULL,
    @rowguid37 uniqueidentifier = NULL,
    @rowguid38 uniqueidentifier = NULL,
    @rowguid39 uniqueidentifier = NULL,
    @rowguid40 uniqueidentifier = NULL,
    @rowguid41 uniqueidentifier = NULL,
    @rowguid42 uniqueidentifier = NULL,
    @rowguid43 uniqueidentifier = NULL,
    @rowguid44 uniqueidentifier = NULL,
    @rowguid45 uniqueidentifier = NULL,
    @rowguid46 uniqueidentifier = NULL,
    @rowguid47 uniqueidentifier = NULL,
    @rowguid48 uniqueidentifier = NULL,
    @rowguid49 uniqueidentifier = NULL,
    @rowguid50 uniqueidentifier = NULL,

    @rowguid51 uniqueidentifier = NULL,
    @rowguid52 uniqueidentifier = NULL,
    @rowguid53 uniqueidentifier = NULL,
    @rowguid54 uniqueidentifier = NULL,
    @rowguid55 uniqueidentifier = NULL,
    @rowguid56 uniqueidentifier = NULL,
    @rowguid57 uniqueidentifier = NULL,
    @rowguid58 uniqueidentifier = NULL,
    @rowguid59 uniqueidentifier = NULL,
    @rowguid60 uniqueidentifier = NULL,
    @rowguid61 uniqueidentifier = NULL,
    @rowguid62 uniqueidentifier = NULL,
    @rowguid63 uniqueidentifier = NULL,
    @rowguid64 uniqueidentifier = NULL,
    @rowguid65 uniqueidentifier = NULL,
    @rowguid66 uniqueidentifier = NULL,
    @rowguid67 uniqueidentifier = NULL,
    @rowguid68 uniqueidentifier = NULL,
    @rowguid69 uniqueidentifier = NULL,
    @rowguid70 uniqueidentifier = NULL,
    @rowguid71 uniqueidentifier = NULL,
    @rowguid72 uniqueidentifier = NULL,
    @rowguid73 uniqueidentifier = NULL,
    @rowguid74 uniqueidentifier = NULL,
    @rowguid75 uniqueidentifier = NULL,
    @rowguid76 uniqueidentifier = NULL,
    @rowguid77 uniqueidentifier = NULL,
    @rowguid78 uniqueidentifier = NULL,
    @rowguid79 uniqueidentifier = NULL,
    @rowguid80 uniqueidentifier = NULL,
    @rowguid81 uniqueidentifier = NULL,
    @rowguid82 uniqueidentifier = NULL,
    @rowguid83 uniqueidentifier = NULL,
    @rowguid84 uniqueidentifier = NULL,
    @rowguid85 uniqueidentifier = NULL,
    @rowguid86 uniqueidentifier = NULL,
    @rowguid87 uniqueidentifier = NULL,
    @rowguid88 uniqueidentifier = NULL,
    @rowguid89 uniqueidentifier = NULL,
    @rowguid90 uniqueidentifier = NULL,
    @rowguid91 uniqueidentifier = NULL,
    @rowguid92 uniqueidentifier = NULL,
    @rowguid93 uniqueidentifier = NULL,
    @rowguid94 uniqueidentifier = NULL,
    @rowguid95 uniqueidentifier = NULL,
    @rowguid96 uniqueidentifier = NULL,
    @rowguid97 uniqueidentifier = NULL,
    @rowguid98 uniqueidentifier = NULL,
    @rowguid99 uniqueidentifier = NULL,
    @rowguid100 uniqueidentifier = NULL
) 

as
begin
    declare @retcode    int
    declare @maxversion int
    set nocount on
        
    if ({ fn ISPALUSER('9DEE015E-1388-43B6-BDF0-8C2967FBB918') } <> 1)
    begin       
        RAISERROR (14126, 11, -1)
        return (1)
    end
    
    select @maxversion= maxversion_at_cleanup from dbo.sysmergearticles 
        where nickname = 26466000 and pubid = '9DEE015E-1388-43B6-BDF0-8C2967FBB918'


        select case when (cont.generation is NULL and tomb.generation is null) then 0 else isnull(cont.generation, tomb.generation) end as generation, 
               case when t.[rowguid] is null then (case when tomb.rowguid is NULL then 0 else tomb.type end) else (case when cont.rowguid is null then 3 else 2 end) end as type,
               case when tomb.rowguid is null then cont.lineage else tomb.lineage end as lineage,  
               cont.colv1 as colv,
               @maxversion as maxversion,
               rows.rowguid as rowguid
    

        from
        ( 
        select @rowguid1 as rowguid, 1 as sortcol union all
        select @rowguid2 as rowguid, 2 as sortcol union all
        select @rowguid3 as rowguid, 3 as sortcol union all
        select @rowguid4 as rowguid, 4 as sortcol union all
        select @rowguid5 as rowguid, 5 as sortcol union all
        select @rowguid6 as rowguid, 6 as sortcol union all
        select @rowguid7 as rowguid, 7 as sortcol union all
        select @rowguid8 as rowguid, 8 as sortcol union all
        select @rowguid9 as rowguid, 9 as sortcol union all
        select @rowguid10 as rowguid, 10 as sortcol union all
        select @rowguid11 as rowguid, 11 as sortcol union all
        select @rowguid12 as rowguid, 12 as sortcol union all
        select @rowguid13 as rowguid, 13 as sortcol union all
        select @rowguid14 as rowguid, 14 as sortcol union all
        select @rowguid15 as rowguid, 15 as sortcol union all
        select @rowguid16 as rowguid, 16 as sortcol union all
        select @rowguid17 as rowguid, 17 as sortcol union all
        select @rowguid18 as rowguid, 18 as sortcol union all
        select @rowguid19 as rowguid, 19 as sortcol union all
        select @rowguid20 as rowguid, 20 as sortcol union all
        select @rowguid21 as rowguid, 21 as sortcol union all
        select @rowguid22 as rowguid, 22 as sortcol union all
        select @rowguid23 as rowguid, 23 as sortcol union all
        select @rowguid24 as rowguid, 24 as sortcol union all
        select @rowguid25 as rowguid, 25 as sortcol union all
        select @rowguid26 as rowguid, 26 as sortcol union all
        select @rowguid27 as rowguid, 27 as sortcol union all
        select @rowguid28 as rowguid, 28 as sortcol union all
        select @rowguid29 as rowguid, 29 as sortcol union all
        select @rowguid30 as rowguid, 30 as sortcol union all
        select @rowguid31 as rowguid, 31 as sortcol union all

        select @rowguid32 as rowguid, 32 as sortcol union all
        select @rowguid33 as rowguid, 33 as sortcol union all
        select @rowguid34 as rowguid, 34 as sortcol union all
        select @rowguid35 as rowguid, 35 as sortcol union all
        select @rowguid36 as rowguid, 36 as sortcol union all
        select @rowguid37 as rowguid, 37 as sortcol union all
        select @rowguid38 as rowguid, 38 as sortcol union all
        select @rowguid39 as rowguid, 39 as sortcol union all
        select @rowguid40 as rowguid, 40 as sortcol union all
        select @rowguid41 as rowguid, 41 as sortcol union all
        select @rowguid42 as rowguid, 42 as sortcol union all
        select @rowguid43 as rowguid, 43 as sortcol union all
        select @rowguid44 as rowguid, 44 as sortcol union all
        select @rowguid45 as rowguid, 45 as sortcol union all
        select @rowguid46 as rowguid, 46 as sortcol union all
        select @rowguid47 as rowguid, 47 as sortcol union all
        select @rowguid48 as rowguid, 48 as sortcol union all
        select @rowguid49 as rowguid, 49 as sortcol union all
        select @rowguid50 as rowguid, 50 as sortcol union all
        select @rowguid51 as rowguid, 51 as sortcol union all
        select @rowguid52 as rowguid, 52 as sortcol union all
        select @rowguid53 as rowguid, 53 as sortcol union all
        select @rowguid54 as rowguid, 54 as sortcol union all
        select @rowguid55 as rowguid, 55 as sortcol union all
        select @rowguid56 as rowguid, 56 as sortcol union all
        select @rowguid57 as rowguid, 57 as sortcol union all
        select @rowguid58 as rowguid, 58 as sortcol union all
        select @rowguid59 as rowguid, 59 as sortcol union all
        select @rowguid60 as rowguid, 60 as sortcol union all
        select @rowguid61 as rowguid, 61 as sortcol union all
        select @rowguid62 as rowguid, 62 as sortcol union all
 
        select @rowguid63 as rowguid, 63 as sortcol union all
        select @rowguid64 as rowguid, 64 as sortcol union all
        select @rowguid65 as rowguid, 65 as sortcol union all
        select @rowguid66 as rowguid, 66 as sortcol union all
        select @rowguid67 as rowguid, 67 as sortcol union all
        select @rowguid68 as rowguid, 68 as sortcol union all
        select @rowguid69 as rowguid, 69 as sortcol union all
        select @rowguid70 as rowguid, 70 as sortcol union all
        select @rowguid71 as rowguid, 71 as sortcol union all
        select @rowguid72 as rowguid, 72 as sortcol union all
        select @rowguid73 as rowguid, 73 as sortcol union all
        select @rowguid74 as rowguid, 74 as sortcol union all
        select @rowguid75 as rowguid, 75 as sortcol union all
        select @rowguid76 as rowguid, 76 as sortcol union all
        select @rowguid77 as rowguid, 77 as sortcol union all
        select @rowguid78 as rowguid, 78 as sortcol union all
        select @rowguid79 as rowguid, 79 as sortcol union all
        select @rowguid80 as rowguid, 80 as sortcol union all
        select @rowguid81 as rowguid, 81 as sortcol union all
        select @rowguid82 as rowguid, 82 as sortcol union all
        select @rowguid83 as rowguid, 83 as sortcol union all
        select @rowguid84 as rowguid, 84 as sortcol union all
        select @rowguid85 as rowguid, 85 as sortcol union all
        select @rowguid86 as rowguid, 86 as sortcol union all
        select @rowguid87 as rowguid, 87 as sortcol union all
        select @rowguid88 as rowguid, 88 as sortcol union all
        select @rowguid89 as rowguid, 89 as sortcol union all
        select @rowguid90 as rowguid, 90 as sortcol union all
        select @rowguid91 as rowguid, 91 as sortcol union all
        select @rowguid92 as rowguid, 92 as sortcol union all
        select @rowguid93 as rowguid, 93 as sortcol union all
 
        select @rowguid94 as rowguid, 94 as sortcol union all
        select @rowguid95 as rowguid, 95 as sortcol union all
        select @rowguid96 as rowguid, 96 as sortcol union all
        select @rowguid97 as rowguid, 97 as sortcol union all
        select @rowguid98 as rowguid, 98 as sortcol union all
        select @rowguid99 as rowguid, 99 as sortcol union all
        select @rowguid100 as rowguid, 100 as sortcol
        ) as rows 

        left outer join [dbo].[Account] t with (rowlock) 
        on t.[rowguid] = rows.rowguid
        and rows.rowguid is not null
        left outer join dbo.MSmerge_contents cont with (rowlock) 
        on cont.rowguid = rows.rowguid and cont.tablenick = 26466000
        left outer join dbo.MSmerge_tombstone tomb with (rowlock) 
        on tomb.rowguid = rows.rowguid and tomb.tablenick = 26466000
        where rows.rowguid is not null
        order by rows.sortcol
                
        if @@error <> 0 
            return 1
    end
    

go
Create procedure dbo.[MSmerge_cft_sp_5760AC0DEF4342F89DEE015E138843B6] ( 
@p1 nvarchar(50), 
        @p2 nvarchar(50), 
        @p3 date, 
        @p4 date, 
        @p5 float, 
        @p6 int, 
        @p7 int, 
        @p8 nvarchar(50), 
        @p9 uniqueidentifier, 
        @p10  nvarchar(255) 
, @conflict_type int,  @reason_code int,  @reason_text nvarchar(720)
, @pubid uniqueidentifier, @create_time datetime = NULL
, @tablenick int = 0, @source_id uniqueidentifier = NULL, @check_conflicttable_existence bit = 0 
) as
declare @retcode int
-- security check
exec @retcode = sys.sp_MSrepl_PAL_rolecheck @objid = 498816839, @pubid = '9DEE015E-1388-43B6-BDF0-8C2967FBB918'
if @@error <> 0 or @retcode <> 0 return 1 

if 1 = @check_conflicttable_existence
begin
    if 498816839 is null return 0
end


    if @source_id is NULL 
        select @source_id = subid from dbo.sysmergesubscriptions 
            where lower(@p10) = LOWER(subscriber_server) + '.' + LOWER(db_name) 

    if @source_id is NULL select @source_id = newid() 
  
    set @create_time=getdate()

  if exists (select * from MSmerge_conflicts_info info inner join [dbo].[MSmerge_conflict_BRHCM_Account] ct 
    on ct.rowguidcol=info.rowguid and 
       ct.origin_datasource_id = info.origin_datasource_id
     where info.rowguid = @p9 and info.origin_datasource = @p10 and info.tablenick = @tablenick)
    begin
        update [dbo].[MSmerge_conflict_BRHCM_Account] with (rowlock) set 
[AccountID] = @p1
,
        [Customer] = @p2
,
        [StartDate] = @p3
,
        [EndDate] = @p4
,
        [Interest] = @p5
,
        [Period] = @p6
,
        [Balance] = @p7
,
        [Branch] = @p8
 from [dbo].[MSmerge_conflict_BRHCM_Account] ct inner join MSmerge_conflicts_info info 
        on ct.rowguidcol=info.rowguid and 
           ct.origin_datasource_id = info.origin_datasource_id
 where info.rowguid = @p9 and info.origin_datasource = @p10 and info.tablenick = @tablenick


    end
    else
    begin
        insert into [dbo].[MSmerge_conflict_BRHCM_Account] (
[AccountID]
,
        [Customer]
,
        [StartDate]
,
        [EndDate]
,
        [Interest]
,
        [Period]
,
        [Balance]
,
        [Branch]
,
        [rowguid]
,
        [origin_datasource_id]
) values (

@p1
,
        @p2
,
        @p3
,
        @p4
,
        @p5
,
        @p6
,
        @p7
,
        @p8
,
        @p9
,
         @source_id 
)

    end

    
    if exists (select * from MSmerge_conflicts_info info where tablenick=@tablenick and rowguid=@p9 and info.origin_datasource= @p10 and info.conflict_type not in (4,7,8,12))
    begin
        update MSmerge_conflicts_info with (rowlock) 
            set conflict_type=@conflict_type, 
                reason_code=@reason_code,
                reason_text=@reason_text,
                pubid=@pubid,
                MSrepl_create_time=@create_time
            where tablenick=@tablenick and rowguid=@p9 and origin_datasource= @p10
            and conflict_type not in (4,7,8,12)
    end
    else    
    begin
    
        insert MSmerge_conflicts_info with (rowlock) 
            values(@tablenick, @p9, @p10, @conflict_type, @reason_code, @reason_text,  @pubid, @create_time, @source_id)
    end

        declare @error    int
        set @error= @reason_code

    declare @REPOLEExtErrorDupKey            int
    declare @REPOLEExtErrorDupUniqueIndex    int

    set @REPOLEExtErrorDupKey= 2627
    set @REPOLEExtErrorDupUniqueIndex= 2601
    
    if @error in (@REPOLEExtErrorDupUniqueIndex, @REPOLEExtErrorDupKey)
    begin
        update mc
            set mc.generation= 0
            from dbo.MSmerge_contents mc join [dbo].[Account] t on mc.rowguid=t.rowguidcol
            where
                mc.tablenick = 26466000 and
                (

                        (t.[AccountID]=@p1)

                        )
            end

go

update dbo.sysmergearticles 
    set insert_proc = 'MSmerge_ins_sp_5760AC0DEF4342F89DEE015E138843B6',
        select_proc = 'MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6',
        metadata_select_proc = 'MSmerge_sel_sp_5760AC0DEF4342F89DEE015E138843B6_metadata',
        update_proc = 'MSmerge_upd_sp_5760AC0DEF4342F89DEE015E138843B6',
        ins_conflict_proc = 'MSmerge_cft_sp_5760AC0DEF4342F89DEE015E138843B6',
        delete_proc = 'MSmerge_del_sp_5760AC0DEF4342F89DEE015E138843B6'
    where artid = '5760AC0D-EF43-42F8-8C02-BC61E110C745' and pubid = '9DEE015E-1388-43B6-BDF0-8C2967FBB918'

go

	if object_id('sp_MSpostapplyscript_forsubscriberprocs','P') is not NULL
		exec sys.sp_MSpostapplyscript_forsubscriberprocs @procsuffix = '5760AC0DEF4342F89DEE015E138843B6'

go
