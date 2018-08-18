﻿CREATE PROCEDURE [FEED].[SourceList]
	@sources xml
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

	declare @xmlPointer int;
	exec sys.sp_xml_preparedocument @xmlPointer output, @sources;
    create table #sources ([SourceId] int);

	insert into #sources ([SourceId])
    select [SourceId]
    from openxml (@xmlPointer, '/Array/Item')
    with ([SourceId] int '@Value')
	where 1 = 1;

	if exists(select * from #sources) 
	begin

		select * 
		from [FEED].[Source]
		where [Id] in (select [SourceId] from #sources)
		order by [Name] asc
	end
	else
	begin
		select * 
		from [FEED].[Source]
		order by [Name] asc
	end

	return 0;
end
go
grant execute
    on object::[FEED].[SourceList] TO [AppRole]
    AS [dbo];