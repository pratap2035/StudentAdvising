----------------------------------------------------------------------------------------
--AddSemesterCourse stored procedure
----------------------------------------------------------------------------------------
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AddSemesterCourse]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[AddSemesterCourse]
PRINT 'AddSemesterCourse stored procedure dropped';
GO

CREATE PROCEDURE AddSemesterCourse
(
	@CourseID int ,
	@FromYear int ,
	@ToYear int ,
	@Fall bit ,
	@Spring bit,
	@Summer bit
)
AS
BEGIN


	DECLARE @Semester TABLE(ID int IDENTITY(1,1) ,SemesterID int);
	
	DECLARE @currentSemester nvarchar(50);
	DECLARE @currentSemesterID int;
	
	WHILE(@ToYear >=@FromYear)
	BEGIN
		IF (@Fall =  1)
		
		BEGIN
			SELECT @currentSemesterID = ID FROM LuSemester WHERE Name  = 'Fall' AND [Year] = @FromYear;
			INSERT INTO @Semester(SemesterID) VALUES(@currentSemesterID) ;
		END
		
		IF (@Spring = 1)
		BEGIN
			SELECT @currentSemesterID = ID FROM LuSemester WHERE Name = 'Spring' AND [Year] = @FromYear;
			INSERT INTO @Semester(SemesterID) VALUES(@currentSemesterID) ;
		END
		
		IF (@Summer = 1 )
		BEGIN
			SELECT @currentSemesterID = ID FROM LuSemester WHERE Name = 'Summer' AND [Year] = @FromYear;
			INSERT INTO @Semester(SemesterID) VALUES(@currentSemesterID) ;
		END
		
		SET @FromYear = @FromYear + 1;
		
	END
	
	--SELECT * FROm @Semester;
	
	
	DECLARE @CoursePreRequiste TABLE (ID int IDENTITY(1,1), CourseID int);
	DECLARE @CoursePreRequisteID int;
	
	WHILE(SELECT TOP 1 ID FROM @Semester) IS NOT NULL
	BEGIN
		
		SELECT TOP 1 @currentSemesterID = SemesterID FROM @Semester
		INSERT INTO SemesterCourse(SemesterID,CourseID,IsActiveFL,CreationDate,LastUpdatedDate,CreatedBy,LastUpdatedBy)
		VALUES(@currentSemesterID,@CourseID,'true',GETDATE(),GETDATE(),0,0)
		
		INSERT INTO @CoursePreRequiste
		SELECT PreReqID FROM CoursePrerequisite WHERE  CourseID = @CourseID;
		
		WHILE( SELECT  TOP 1 CourseID FROM @CoursePreRequiste) IS NOT NULL
		BEGIN
			
			SELECT TOP 1 @CoursePreRequisteID = CourseID FROM @CoursePreRequiste;
			
			INSERT INTO SemesterCoursePrerequisite(SemesterID,SemesterCourseID,PreReqID,IsActiveFL,CreationDate,LastUpdatedDate,CreatedBy,LastUpdatedBy)
			VALUES(@currentSemesterID,@CourseID,@CoursePreRequisteID,'true',GETDATE(),GETDATE(),0,0)
			
			DELETE FROM @CoursePreRequiste  WHERE CourseID = @CoursePreRequisteID;
		END
		
		DELETE FROM @Semester WHERE SemesterID = @currentSemesterID;
		
	END

END

GO
PRINT 'AddSemesterCourse stored procedure updated';
GO