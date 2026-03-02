SELECT COUNT(*) AS TeachersCount
FROM Teachers t
WHERE t.Id IN (
    SELECT l.TeacherId
    FROM Lectures l
    JOIN GroupsLectures gl ON l.Id = gl.LectureId
    JOIN Groups g ON gl.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
);

SELECT COUNT(*) AS LecturesCount
FROM Lectures l
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Dave' AND t.Surname = 'McQueen';

SELECT COUNT(*) AS ClassesCount
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Name = 'D201';

SELECT lr.Name AS LectureRoomName, COUNT(s.Id) AS LecturesCount
FROM LectureRooms lr
LEFT JOIN Schedules s ON lr.Id = s.LectureRoomId
GROUP BY lr.Id, lr.Name
ORDER BY LecturesCount DESC;

SELECT COUNT(DISTINCT gs.StudentId) AS StudentsCount
FROM GroupsStudents gs
WHERE gs.GroupId IN (
    SELECT DISTINCT gl.GroupId
    FROM GroupsLectures gl
    JOIN Lectures l ON gl.LectureId = l.Id
    JOIN Teachers t ON l.TeacherId = t.Id
    WHERE t.Name = 'Jack' AND t.Surname = 'Underhill'
);

SELECT AVG(t.Salary) AS AverageSalary
FROM Teachers t
WHERE t.Id IN (
    SELECT l.TeacherId
    FROM Lectures l
    JOIN GroupsLectures gl ON l.Id = gl.LectureId
    JOIN Groups g ON gl.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    JOIN Faculties f ON d.FacultyId = f.Id
    WHERE f.Name = 'Computer Science'
);

SELECT 
    MIN(StudentsCount) AS MinStudents,
    MAX(StudentsCount) AS MaxStudents
FROM (
    SELECT COUNT(gs.StudentId) AS StudentsCount
    FROM Groups g
    LEFT JOIN GroupsStudents gs ON g.Id = gs.GroupId
    GROUP BY g.Id
) AS GroupCounts;

SELECT AVG(d.Financing) AS AverageFinancing
FROM Departments d;

SELECT 
    t.Name + ' ' + t.Surname AS FullName,
    COUNT(DISTINCT l.SubjectId) AS SubjectsCount
FROM Teachers t
LEFT JOIN Lectures l ON t.Id = l.TeacherId
GROUP BY t.Id, t.Name, t.Surname;

SELECT 
    DayOfWeek,
    COUNT(*) AS LecturesCount
FROM Schedules
WHERE Week = 1
GROUP BY DayOfWeek
ORDER BY DayOfWeek;

SELECT 
    lr.Name AS LectureRoom,
    COUNT(DISTINCT d.Id) AS DepartmentsCount
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
JOIN Departments d ON g.DepartmentId = d.Id
GROUP BY lr.Id, lr.Name;

SELECT 
    f.Name AS FacultyName,
    COUNT(DISTINCT l.SubjectId) AS SubjectsCount
FROM Faculties f
JOIN Departments d ON f.Id = d.FacultyId
JOIN Groups g ON d.Id = g.DepartmentId
JOIN GroupsLectures gl ON g.Id = gl.GroupId
JOIN Lectures l ON gl.LectureId = l.Id
GROUP BY f.Id, f.Name;

SELECT 
    t.Name + ' ' + t.Surname AS TeacherFullName,
    lr.Name AS LectureRoom,
    COUNT(s.Id) AS LecturesCount
FROM Teachers t
CROSS JOIN LectureRooms lr
LEFT JOIN Lectures l ON t.Id = l.TeacherId
LEFT JOIN Schedules s ON l.Id = s.LectureId AND lr.Id = s.LectureRoomId
GROUP BY t.Id, t.Name, t.Surname, lr.Id, lr.Name
ORDER BY TeacherFullName, LectureRoom;

SELECT Building
FROM Departments
GROUP BY Building
HAVING SUM(Financing) > 100000;

SELECT g.Name AS GroupName
FROM Groups g
JOIN Departments d ON g.DepartmentId = d.Id
WHERE g.Year = 5 
  AND d.Name = 'Software Development'
  AND (
    SELECT COUNT(*)
    FROM GroupsLectures gl
    JOIN Lectures l ON gl.LectureId = l.Id
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE gl.GroupId = g.Id AND s.Week = 1
  ) > 10;

SELECT g.Name AS GroupName
FROM Groups g
WHERE (
    SELECT AVG(s.Rating)
    FROM GroupsStudents gs
    JOIN Students s ON gs.StudentId = s.Id
    WHERE gs.GroupId = g.Id
) > (
    SELECT AVG(s.Rating)
    FROM Groups g2
    JOIN GroupsStudents gs ON g2.Id = gs.GroupId
    JOIN Students s ON gs.StudentId = s.Id
    WHERE g2.Name = 'D221'
);

SELECT Surname, Name
FROM Teachers
WHERE Salary > (
    SELECT AVG(Salary)
    FROM Teachers
    WHERE IsProfessor = 1
);

SELECT Name AS GroupName
FROM Groups g
WHERE (
    SELECT COUNT(*)
    FROM GroupsCurators gc
    WHERE gc.GroupId = g.Id
) > 1;

SELECT g.Name AS GroupName
FROM Groups g
WHERE (
    SELECT AVG(s.Rating)
    FROM GroupsStudents gs
    JOIN Students s ON gs.StudentId = s.Id
    WHERE gs.GroupId = g.Id
) < (
    SELECT MIN(AvgRating)
    FROM (
        SELECT AVG(s.Rating) AS AvgRating
        FROM Groups g5
        JOIN GroupsStudents gs ON g5.Id = gs.GroupId
        JOIN Students s ON gs.StudentId = s.Id
        WHERE g5.Year = 5
        GROUP BY g5.Id
    ) AS FifthYearGroups
);

SELECT f.Name AS FacultyName
FROM Faculties f
JOIN Departments d ON f.Id = d.FacultyId
GROUP BY f.Id, f.Name
HAVING SUM(d.Financing) > (
    SELECT SUM(d2.Financing)
    FROM Faculties f2
    JOIN Departments d2 ON f2.Id = d2.FacultyId
    WHERE f2.Name = 'Computer Science'
);

SELECT 
    sub.Name AS SubjectName,
    t.Name + ' ' + t.Surname AS TeacherFullName
FROM Subjects sub
JOIN Lectures l ON sub.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
GROUP BY sub.Id, sub.Name, t.Id, t.Name, t.Surname
HAVING COUNT(l.Id) = (
    SELECT MAX(LectureCount)
    FROM (
        SELECT COUNT(l2.Id) AS LectureCount
        FROM Lectures l2
        GROUP BY l2.SubjectId, l2.TeacherId
    ) AS Counts
);

SELECT sub.Name AS SubjectName
FROM Subjects sub
JOIN Lectures l ON sub.Id = l.SubjectId
GROUP BY sub.Id, sub.Name
HAVING COUNT(l.Id) = (
    SELECT MIN(LectureCount)
    FROM (
        SELECT COUNT(l2.Id) AS LectureCount
        FROM Lectures l2
        GROUP BY l2.SubjectId
    ) AS Counts
);

SELECT 
    (SELECT COUNT(DISTINCT gs.StudentId)
     FROM Groups g
     JOIN GroupsStudents gs ON g.Id = gs.GroupId
     WHERE g.DepartmentId = d.Id) AS StudentsCount,
    (SELECT COUNT(DISTINCT l.SubjectId)
     FROM Groups g
     JOIN GroupsLectures gl ON g.Id = gl.GroupId
     JOIN Lectures l ON gl.LectureId = l.Id
     WHERE g.DepartmentId = d.Id) AS SubjectsCount
FROM Departments d
WHERE d.Name = 'Software Development';

SELECT DISTINCT lr.Name AS LectureRoom
FROM LectureRooms lr
JOIN Schedules s ON lr.Id = s.LectureRoomId
JOIN Lectures l ON s.LectureId = l.Id
JOIN Teachers t ON l.TeacherId = t.Id
WHERE t.Name = 'Edward' AND t.Surname = 'Hopper';

SELECT t.Surname
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
WHERE t.Id IN (
    SELECT DISTINCT l.TeacherId
    FROM Lectures l
    JOIN GroupsLectures gl ON l.Id = gl.LectureId
    JOIN Groups g ON gl.GroupId = g.Id
    WHERE g.Name = 'F505'
);

SELECT DISTINCT sub.Name AS SubjectName
FROM Subjects sub
JOIN Lectures l ON sub.Id = l.SubjectId
JOIN Teachers t ON l.TeacherId = t.Id
JOIN GroupsLectures gl ON l.Id = gl.LectureId
JOIN Groups g ON gl.GroupId = g.Id
WHERE t.Name = 'Alex' AND t.Surname = 'Carmack' AND g.Year = 5;

SELECT DISTINCT t.Surname
FROM Teachers t
WHERE t.Id NOT IN (
    SELECT DISTINCT l.TeacherId
    FROM Lectures l
    JOIN Schedules s ON l.Id = s.LectureId
    WHERE s.DayOfWeek = 1
);

SELECT lr.Name AS LectureRoom, lr.Building
FROM LectureRooms lr
WHERE lr.Id NOT IN (
    SELECT DISTINCT s.LectureRoomId
    FROM Schedules s
    WHERE s.DayOfWeek = 3
      AND s.Week = 2
      AND s.Class = 3
);

SELECT t.Name + ' ' + t.Surname AS FullName
FROM Teachers t
WHERE t.Id IN (
    SELECT DISTINCT l.TeacherId
    FROM Lectures l
    JOIN GroupsLectures gl ON l.Id = gl.LectureId
    JOIN Groups g ON gl.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    JOIN Faculties f ON d.FacultyId = f.Id
    WHERE f.Name = 'Computer Science'
)
AND t.Id NOT IN (
    SELECT DISTINCT c.TeacherId
    FROM Curators c
    JOIN GroupsCurators gc ON c.Id = gc.CuratorId
    JOIN Groups g ON gc.GroupId = g.Id
    JOIN Departments d ON g.DepartmentId = d.Id
    WHERE d.Name = 'Software Development'
);

SELECT Building FROM Faculties
UNION
SELECT Building FROM Departments
UNION
SELECT Building FROM LectureRooms
ORDER BY Building;

SELECT DISTINCT t.Name + ' ' + t.Surname AS FullName, 1 AS OrderPriority
FROM Teachers t
JOIN Deans d ON t.Id = d.TeacherId
UNION ALL
SELECT DISTINCT t.Name + ' ' + t.Surname, 2
FROM Teachers t
JOIN Heads h ON t.Id = h.TeacherId
UNION ALL
SELECT DISTINCT t.Name + ' ' + t.Surname, 3
FROM Teachers t
LEFT JOIN Deans d ON t.Id = d.TeacherId
LEFT JOIN Heads h ON t.Id = h.TeacherId
WHERE d.Id IS NULL AND h.Id IS NULL
UNION ALL
SELECT DISTINCT t.Name + ' ' + t.Surname, 4
FROM Teachers t
JOIN Curators c ON t.Id = c.TeacherId
UNION ALL
SELECT DISTINCT t.Name + ' ' + t.Surname, 5
FROM Teachers t
JOIN Assistants a ON t.Id = a.TeacherId
ORDER BY OrderPriority, FullName;

SELECT DISTINCT s.DayOfWeek
FROM Schedules s
JOIN LectureRooms lr ON s.LectureRoomId = lr.Id
WHERE lr.Name IN ('A311', 'A104') AND lr.Building = 6
ORDER BY s.DayOfWeek;