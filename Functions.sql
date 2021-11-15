--1. Müəyyən Publisher tərəfindən çap olunmuş minimum səhifəli kitabların siyahısını çıxaran funksiya yazın

CREATE FUNCTION MinPageBook(@PublisherName NVARCHAR(30))
RETURNS  Table
RETURN 
(
  SELECT Books.Pages,Books.[Name] AS [Book Name],Press.[Name] AS [Press Name]
  FROM Books  
  JOIN Press ON Books.Id_Press=Press.Id
  WHERE Press.[Name]=@PublisherName
)

SELECT * FROM MinPageBook('BHV')
ORDER BY Pages


--2. Orta səhifə sayı N-dən çox səhifəli kitab çap edən Publisherlərin adını qaytaran funksiya yazın. 
--N parameter olaraq göndərilir.

CREATE FUNCTION AvgOfPublisherBooksPages(@number int)
RETURNS TABLE
RETURN
(
   SELECT AVG(Pages) AS [Average of Pages],Press.[Name]AS [Press Name] 
   FROM Books  
   JOIN Press ON Books.Id_Press=Press.Id
   GROUP BY Press.[Name]
   HAVING @number<AVG(Pages)
)

SELECT * FROM AvgOfPublisherBooksPages(235)

--3. Müəyyən Publisher tərəfindən çap edilmiş bütün kitab səhifələrinin cəmini tapan və qaytaran funksiya yazın.


CREATE FUNCTION SumBooksPages(@PublisherName NVARCHAR(30))
RETURNS Table
RETURN 
(
  SELECT SUM(Pages) AS [Summary All Books],Press.[Name] AS [Press Name]
  FROM Books JOIN Press ON Books.Id_Press=Press.Id
  WHERE Press.[Name]=@PublisherName
  GROUP BY Press.[Name] 
)

SELECT * FROM SumBooksPages('BHV')

--4. Müəyyən iki tarix aralığında kitab götürmüş Studentlərin ad və soyadını list şəklində qaytaran funksiya yazın.

CREATE FUNCTION StudentTakedBooksInBetweenDateTimes(@Temp1 datetime,@Temp2 datetime)
RETURNS TABLE
RETURN
(
  SELECT CONCAT(Students.FirstName,Students.LastName)AS [Student Name]
  FROM Students JOIN S_Cards ON Students.Id=S_Cards.Id_Student
  WHERE  S_Cards.DateOut<@Temp2 AND S_Cards.DateOut>@Temp1
)

SELECT * FROM StudentTakedBooksInBetweenDateTimes('2001.05.07','2001.06.03')

--5. Müəyyən kitabla hal hazırda işləyən bütün tələbələrin siyahısını qaytaran funksiya yazın.

CREATE FUNCTION AllReadyWorkingWithBooksStudents(@BookName NVARCHAR(MAX))
RETURNS TABLE
RETURN
(
  SELECT CONCAT(Students.FirstName,Students.LastName) AS [Student Name],Books.[Name] AS [Book Name]
  FROM Students  
  JOIN S_Cards ON Students.Id=S_Cards.Id_Student  
  JOIN Books ON Books.Id=S_Cards.Id_Book
  WHERE Books.[Name]=@BookName
)

SELECT * FROM AllReadyWorkingWithBooksStudents('3D Studio Max 3')

SELECT* FROM Books

--6. Çap etdiyi bütün səhifə cəmi N-dən böyük olan Publisherlər haqqında informasiya qaytaran funksiya yazın.

CREATE FUNCTION TASK(@number int)
RETURNS TABLE
RETURN
(
   SELECT Press.[Name] AS [Press Name],SUM(Pages) AS [Summary Pages] 
   FROM Books JOIN Press ON Books.Id_Press=Press.Id
   GROUP BY Press.[Name]
   HAVING @number<SUM(Pages)
)

SELECT * FROM TASK(330)

--7.Studentlər arasında Ən popular yazici və onun götürülmüş kitablarının 
--sayı haqqında informasiya verən funksiya yazın

CREATE FUNCTION Task3()
RETURNS TABLE
RETURN
(
  SELECT  Authors.FirstName+' '+Authors.LastName AS [Authors Name],COUNT(S_Cards.Id_Book)AS [Number Of Books]  
  FROM S_Cards JOIN Books ON S_Cards.Id_Book=Books.Id
  JOIN Authors ON Books.Id_Author=Authors.Id
  Group BY Authors.FirstName+' '+Authors.LastName
)
SELECT TOP(1) WITH TIES * FROM Task3()
ORDER BY [Number Of Books] DESC


--8.Studentlər və Teacherlər (hər ikisi) tərəfindən götürülmüş 
--(ortaq - həm onlar həm bunlar) kitabların listini qaytaran funksiya yazın.


CREATE FUNCTION Task4()
RETURNS TABLE
RETURN
(
SELECT Books.[Name] AS [Book Name] 
FROM Books JOIN S_Cards 
ON S_Cards.Id_Book = Books.Id
INTERSECT
SELECT Books.[Name] AS [Book Name] 
FROM Books 
JOIN T_Cards ON T_Cards.Id_Book = Books.Id
)

SELECT * FROM Task4()



--9. Kitab götürməyən tələbələrin sayını qaytaran funksiya yazın.

CREATE FUNCTION Task5()
RETURNS INT
AS
BEGIN

  DECLARE @temp int=0;
  SELECT @temp=COUNT(Students.Id) 
  FROM S_Cards 
  Right JOIN Students ON Students.Id=S_Cards.Id_Student
  WHERE Id_Book IS NULL
  
RETURN @temp;
END


DECLARE @Temp2 int

EXEC @Temp2 = Task5 

SELECT @Temp2

--10. Kitabxanaçılar və onların verdiyi kitabların sayını qaytaran funksiya yazın.

CREATE FUNCTION LibsTotalBooks()
RETURNS TABLE
RETURN
(
With Tab1 AS(SELECT CONCAT(FirstName, LastName) AS [Libary Person], COUNT(*) AS [Count Of Books] 
FROM Libs 
JOIN S_Cards ON S_Cards.Id_Lib = Libs.Id 
JOIN Books ON Books.Id = S_Cards.Id_Book 
GROUP BY CONCAT(FirstName, LastName)
UNION ALL
SELECT CONCAT(FirstName, LastName) [Libary Person], COUNT(*) AS [Count Of Books] 
FROM Libs 
JOIN T_Cards ON T_Cards.Id_Lib = Libs.Id 
JOIN Books ON Books.Id = T_Cards.Id_Book 
GROUP BY CONCAT(FirstName, LastName))

SELECT [Libary Person], SUM([Count Of Books]) AS [Count Of Books]
FROM Tab1 
GROUP BY [Libary Person]
)

SELECT * FROM LibsTotalBooks()