/* 
Step 1: Add a new test to check a new requirement

The tets are added first if adhering to Test Driven Development!
This is a very simple test to check that the Title has been added correctly 

*/

IF EXISTS ( SELECT	* FROM	sys.objects WHERE type = 'P' AND name = 'test Title in prcAddArticle' ) 
	DROP PROCEDURE [Unit Tests].[test Title in prcAddArticle]
GO

CREATE PROCEDURE [Unit Tests].[test Title in prcAddArticle]
AS
BEGIN
-- Create a fake table
EXEC tSQLt.FakeTable 'dbo.Articles';

-- Populate a record using the procedure I'm testing
EXEC [prcAddArticle]
@AuthorID = '6',
@Title = 'Why most SQL professionals are crazy about Red Gate tools';


-- Specify the actual results
DECLARE @ActualTitle CHAR(100);
SET @ActualTitle = (SELECT Title FROM dbo.Articles);

-- Verify that the actual results corresponds to the expected results
EXEC tSQLt.AssertEquals @Expected = 'Why most SQL professionals are crazy about Red Gate tools', @Actual = @ActualTitle;
END;

GO

/*
Step 2: Refresh SQL Test and run the tests again.
*/


/* 
Step 3: Adds a procedure to add an Article to the Articles table

True TDD would require small iterations where the minimum is implemented each time to satisfy the requirement of the test.
For the sake of speed we're shortcutting the iterations and implementing the finished procedure.

*/

IF EXISTS ( SELECT	* FROM	sys.objects WHERE	type = 'P' AND name = 'prcAddArticle' ) 
	DROP PROCEDURE [prcAddArticle]
GO

CREATE PROCEDURE [dbo].[prcAddArticle]
	@AuthorID INT ,
	@Title VARCHAR(142) = NULL ,
	@Description VARCHAR(MAX) = NULL ,
	@Date DATETIME = NULL ,
	@URL VARCHAR(100) = NULL
	WITH EXECUTE AS CALLER
AS 
	BEGIN
		INSERT	INTO dbo.Articles
				( AuthorID ,
				  Title ,
				  [Description] ,
				  [Date] ,
				  [ModifiedDate] ,
				  [URL] 
        		)
		VALUES	( @AuthorID ,
				  @Title ,
				  @Description ,
				  @Date , -- Publish date
				  GETDATE() , -- ModifiedDate
				  @URL
        		)
	END;

	/*
	-- Run the following to test the procedure

	DELETE FROM dbo.Articles WHERE AuthorID=6
	GO
	EXEC [prcAddArticle] '6',
	'Why all SQL Server professionals are crazy about Red Gate tools',
	'Once again we''re setting out to provide you with a learning experience that''s more than worth your time out of the office, and best of all we''re providing it to you for free, again. Here''s some of the things you can expect from the event:',
	'2013-06-15', 'http://sqlinthecity.red-gate.com/london-2013/'

	*/
	

/*
Step 4: Now we execute the the new procedure and refresh our Simple Talk web app to see see how it now looks 
*/

		

/* 
Step 5: Now run the test again using SQL Test to demonstrate 
that we now have an automated test that we can run each time 
we make database changes to prove that nothing has regressed.

*/

