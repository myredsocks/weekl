CREATE PROCEDURE [FEED].[ArticleList]
	@filter xml,
	@date datetime2(7),
	@offset int,
	@take int
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

	--declare @xmlPointer int;
	--exec sys.sp_xml_preparedocument @xmlPointer output, @filter;
 --   create table #filter (
	--	[SourceId] int);

	--insert into #filter ([SourceId])
 --   select 
 --       [SourceId]
 --   from openxml (@xmlPointer, '/FilterXml/Sources/Source')
 --   with (
	--	[SourceId] int '@SourceId')
	--where 1 = 1;

		
	declare @sourceUnique nvarchar(150);
	declare @sourceId int;

	declare @xmlPointer int;
	exec sys.sp_xml_preparedocument @xmlPointer output, @filter;

	set @sourceUnique = (
		select *
		from openxml (@xmlPointer, '/FilterXml')
		with ([SourceUnique] nvarchar(150) '@SourceUnique'))

	exec sys.sp_xml_removedocument @xmlPointer;

	if @sourceUnique is not null 
	begin
		set @sourceId = (select [Id] from [SourceView] where [Unique] = @sourceUnique);
	end

	declare @from datetime2(7);
	declare @to datetime2(7);
	set @from = @date;
	set @to = dateadd(day,-7, @date);

	with #articles ([Id], [Link], [Title], [Description], [Date], [ImageUrl], [Unique], [SourceId], [SourceName], [SourceLink], [SourceImageUrl], [SourceUnique])
	as
	(
		select 
			[Id],
			[Link],
			[Title],
			[Description],
			[Date],
			[ImageUrl],
			[Unique],
			[SourceId],
			[SourceName],
			[SourceLink],
			[SourceImageUrl],
			[SourceUnique]
		from [FEED].[ArticleView]
		where (@from >= [Date] and @to <= [Date]) and (@sourceId is null or [SourceId] = @sourceId)
	)
	select 
		[Id],
		[Link],
		[Title],
		[Description],
		[Date],
		[Unique],
		[ImageUrl],
		[SourceId],
		[SourceName],
		[SourceLink],
		[SourceImageUrl],
		[SourceUnique]
	from #articles
	--where (@sourceId is null or [SourceId] = @sourceId)
	order by [Date] desc
	offset @offset rows
	fetch next @take rows only

	return 0;
end
go
grant execute
    on object::[FEED].[ArticleList] TO [AppRole]
    AS [dbo];