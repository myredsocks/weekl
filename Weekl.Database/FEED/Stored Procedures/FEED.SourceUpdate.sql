﻿CREATE PROCEDURE [FEED].[SourceUpdate]
	@sourceId int,
	@description nvarchar(max),
	@imageUrl nvarchar(250)
as
    set nocount on
    set xact_abort on
    set ansi_nulls on
    set ansi_warnings on
    set ansi_padding on
    set ansi_null_dflt_on on
    set arithabort on
    set quoted_identifier on
    set concat_null_yields_null on
    set implicit_transactions off
    set cursor_close_on_commit off
begin	

	declare @error nvarchar(200);
	set @error = 
	case
	    when @sourceId is null then N'sourceId'
        else null
    end;

    if @error is not null
    begin
        raiserror(N'Поле [%s] не может быть NULL', 16, 1, @error);
        return 1;
    end
			
	update [FEED].[Source]
	set
		[Description] = @description,
		[ImageUrl] = @imageUrl
	where [Id] = @sourceId

	select * 
	from [FEED].[Source]
	where [Id] = @sourceId
	
	return 0;
end
go
grant execute
    on object::[FEED].[SourceUpdate] TO [AppRole]
    AS [dbo];