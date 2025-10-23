CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Studentmail VARCHAR(100) NOT NULL UNIQUE CHECK (Studentmail LIKE '%@eng.asu.edu.eg'),
    StudentGpa DECIMAL(3, 2) CHECK (StudentGpa >= 0.00 AND StudentGpa <= 4.00),
    HighestGpa DECIMAL(3, 2) CHECK (HighestGpa >= 0.00 AND HighestGpa <= 4.00),
    LowestGpa DECIMAL(3, 2) CHECK (LowestGpa >= 0.00 AND LowestGpa <= 4.00),
    CourseGpa DECIMAL(3, 2) CHECK (CourseGpa >= 0.00 AND CourseGpa <= 4.00),                
    StudentPassword VARCHAR(100) NOT NULL CHECK (
    LENGTH(StudentPassword) >= 8 AND
    StudentPassword REGEXP '[0-9]' AND
    StudentPassword REGEXP '[a-zA-Z]' AND  
    StudentPassword REGEXP '[^a-zA-Z0-9]')
);
CREATE TABLE Instructor (
    InstructorID INT PRIMARY KEY,
    InstructorName VARCHAR(100) NOT NULL,
    InstructorMail VARCHAR(100) NOT NULL UNIQUE
        CHECK (InstructorMail LIKE '%@prof.asu.edu.eg'),
    InstructorPassword VARCHAR(100) NOT NULL
        CHECK (
    LENGTH(InstructorPassword) >= 8 AND
    InstructorPassword REGEXP '[0-9]' AND
    InstructorPassword REGEXP '[a-zA-Z]' AND  
    InstructorPassword REGEXP '[^a-zA-Z0-9]')
);

CREATE TABLE Admin (
	AdminID INT PRIMARY KEY,
    AdminName VARCHAR(100),
    AdminMail VARCHAR(100) NOT NULL UNIQUE CHECK (AdminMail LIKE '%@adm.asu.edu.eg'),
    AdminPassword VARCHAR(100) NOT NULL CHECK (
        LENGTH(AdminPassword) >= 8 AND
    AdminPassword REGEXP '[0-9]' AND
    AdminPassword REGEXP '[a-zA-Z]' AND  
    AdminPassword REGEXP '[^a-zA-Z0-9]')
);

CREATE TABLE Course (
    CourseID VARCHAR(100) PRIMARY KEY, -- Should be VARCHAR for your LIKE checks
    CourseName VARCHAR(100) NOT NULL,
    CourseDescription TEXT,
    CourseCredits DECIMAL(3,2) NOT NULL
        CHECK (CourseCredits > 0.0 AND CourseCredits <= 4.0)
    CHECK (
        CourseID LIKE 'eng%' OR
        CourseID LIKE 'ASU%'
    )
);

CREATE TABLE InstructorCourse (
    InstructorID INT,
    CourseID VARCHAR(100),
    PRIMARY KEY (InstructorID, CourseID),
    FOREIGN KEY (InstructorID) REFERENCES Instructor(InstructorID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

CREATE TABLE StudentCourse (
    StudentID INT,
    CourseID VARCHAR(100),
    PRIMARY KEY (StudentID, CourseID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

CREATE TABLE Assignment (
    AssignmentID INT PRIMARY KEY,
    CourseID VARCHAR(100),
    AssignmentTitle VARCHAR(100) NOT NULL,
    AssignmentDescription TEXT,
    DueDate TIMESTAMP NOT NULL,
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

CREATE TABLE Submission (
    SubmissionID INT PRIMARY KEY,
    AssignmentID INT,
    StudentID INT,
    SubmissionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Grade DECIMAL(3, 2)
        CHECK (Grade >= 0.00 AND Grade <= 100.00),
    FOREIGN KEY (AssignmentID) REFERENCES Assignment(AssignmentID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID)
);

CREATE TABLE Training (
    TrainingID INT PRIMARY KEY,
    TrainingName VARCHAR(255) NOT NULL,
    TrainingDescription TEXT,
    DurationWeeks INT NOT NULL
        CHECK (DurationWeeks >= 0 AND DurationWeeks <= 12),
    CreditHours INT NOT NULL
        CHECK (CreditHours >= 2 AND CreditHours <= 4)
);

CREATE TABLE StudentTraining (
    StudentID INT,
    TrainingID INT,
    TrainingStatus VARCHAR(50) NOT NULL
    CHECK (TrainingStatus IN ('pending', 'complete', 'refused')),
    TrainingCompletionDate TIMESTAMP,
    TrainingCertificate VARCHAR(255),
    TrainingCredits Int NOT NULL
    CHECK (TrainingCredits >= 2 AND TrainingCredits <= 4),
    PRIMARY KEY (StudentID, TrainingID),
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (TrainingID) REFERENCES Training(TrainingID)
);