USE [CepReportDB]
GO

CREATE PROC [dbo].[ExeSyncTable]
(
	@lk NVARCHAR(100),
	@schema NVARCHAR(100),
	@table NVARCHAR(100),
	@syncfield NVARCHAR(100)=NULL,
	@keyfield NVARCHAR(100)='Id'
)
AS
BEGIN
	
	IF NOT EXISTS(SELECT SCHEMA_NAME(t.schema_id) SchemaName,t.name TableName FROM sys.tables t where SCHEMA_NAME(t.schema_id)=@schema AND t.name=@table)
	BEGIN
		DECLARE @init NVARCHAR(max)
		SET @init='SELECT * INTO ['+@schema+'].['+@table+'] FROM OPENQUERY(['+@lk+'],''select * from ['+@schema+'].['+@table+']'')'
		EXEC SP_EXECUTESQL @init
		PRINT('sync init success')
	END

	IF(@syncfield IS NOT NULL AND LEN(@syncfield)>0)
	BEGIN
		declare @columns varchar(max)
		set @columns=stuff((select ',' +
			sc.name FROM sysobjects so,syscolumns sc
			where so.id =sc.id AND so.id=(select [object_id] from sys.all_objects 
					where [schema_id]=SCHEMA_ID(@schema) and [name]=@table)
		 for xml path('')),1,1,'')

		DECLARE @update NVARCHAR(MAX)

		set @update='
		declare @maxdate varchar(30)
		select @maxdate=max('+@syncfield+') from ['+@schema+'].['+@table+']
		exec(''SELECT * INTO #'+@table+' FROM OPENQUERY('+@lk+',
				''''select * from '+@schema+'.'+@table+' where '+@syncfield+'>''''''''''+@maxdate+'''''''''''''')
			DELETE FROM ['+@schema+'].['+@table+'] WHERE '+@keyfield+' in(select '+@keyfield+' from #'+@table+')
			insert into ['+@schema+'].['+@table+']('+@columns+') 
			select '+@columns+' from #'+@table+'
			drop table #'+@table+'
		'')'

		--print @update

		EXEC SP_EXECUTESQL @update

		PRINT(CHAR(10)+'sync update success')
	END
END
