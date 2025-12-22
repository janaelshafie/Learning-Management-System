# Quick Test Credentials

This document provides login credentials for testing the LMS system. All passwords are plain text (not hashed).

**Note:** These credentials are based on the data inserted by `Insertion.sql`. Make sure to run `CourseInsertion.sql` first, then `Insertion.sql` before using these credentials.

---

## Admin

### Super Admin
```
User ID: 1
Name: System Admin
Email: admin@lms.edu
Official Email: admin@uni.edu
Password: 123456
```

**Login Instructions:**
- Use email: `admin@lms.edu` or `admin@uni.edu`
- Password: `123456`

---

## Instructors

**7 Unit Heads (one for each department: PHM, ASU, MCT, ARC, ECE, CSE, EPM):**

### Dept 1 - Computer and Systems Engineering (CSE)
```
User ID: 101
Name: Prof. Ahmed CSE
Email: ahmed.cse@uni.edu
Official Email: head.cse@uni.edu
Department Code: CSE
Office Hours: Sun/Tue 10-12
Password: 123456
```

### Dept 2 - Architecture Engineering (ARC)
```
User ID: 102
Name: Prof. Sarah ARC
Email: sarah.arc@uni.edu
Official Email: head.arc@uni.edu
Department Code: ARC
Office Hours: Mon/Wed 10-12
Password: 123456
```

### Dept 3 - Electrical Power and Machines Engineering (EPM)
```
User ID: 103
Name: Prof. Mohamed EPM
Email: mohamed.epm@uni.edu
Official Email: head.epm@uni.edu
Department Code: EPM
Office Hours: Sun/Thu 12-2
Password: 123456
```

### Dept 4 - Electronics and Communication Engineering (ECE)
```
User ID: 104
Name: Prof. Laila ECE
Email: laila.ece@uni.edu
Official Email: head.ece@uni.edu
Department Code: ECE
Office Hours: Tue/Thu 9-11
Password: 123456
```

### Dept 5 - Mechatronics Engineering (MCT)
```
User ID: 105
Name: Prof. Omar MCT
Email: omar.mct@uni.edu
Official Email: head.mct@uni.edu
Department Code: MCT
Office Hours: Mon/Wed 1-3
Password: 123456
```

### ASU Courses Coordinator
```
User ID: 106
Name: Dr. Amira ASU
Email: amira.asu@uni.edu
Official Email: coordinator.asu@uni.edu
Department Code: ASU
Office Hours: Tue/Thu 2-4
Password: 123456
```

### Engineering Physics and Mathematics Department (PHM)
```
User ID: 107
Name: Prof. Khaled PHM
Email: khaled.phm@uni.edu
Official Email: head.phm@uni.edu
Department Code: PHM
Office Hours: Mon/Fri 11-1
Password: 123456
```

**Login Instructions for Instructors:**
- Use any instructor's email (e.g., `ahmed.cse@uni.edu`)
- Password: `123456`

---

## Students

**2 Students per Department (10 Total Students):**

**Note:** ASU and PHM departments have NO students (they are service departments for courses only).

### Department 1 - Computer and Systems Engineering (CSE)
```
CSE Senior Student:
  User ID: 201
  Name: CSE Senior Student
  Student UID: S-201
  National ID: 3000000201
  Email: cse.sen@mail.com
  Official Email: cse.sen@uni.edu
  GPA: 3.2
  Advisor ID: 101 (Prof. Ahmed CSE)
  Password: 123456

CSE Junior Student:
  User ID: 202
  Name: CSE Junior Student
  Student UID: S-202
  National ID: 3000000202
  Email: cse.jun@mail.com
  Official Email: cse.jun@uni.edu
  GPA: 2.8
  Advisor ID: 101 (Prof. Ahmed CSE)
  Password: 123456
```

### Department 2 - Architecture Engineering (ARC)
```
ARC Senior Student:
  User ID: 203
  Name: ARC Senior Student
  Student UID: S-203
  National ID: 3000000203
  Email: arc.sen@mail.com
  Official Email: arc.sen@uni.edu
  GPA: 3.5
  Advisor ID: 102 (Prof. Sarah ARC)
  Password: 123456

ARC Junior Student:
  User ID: 204
  Name: ARC Junior Student
  Student UID: S-204
  National ID: 3000000204
  Email: arc.jun@mail.com
  Official Email: arc.jun@uni.edu
  GPA: 3.0
  Advisor ID: 102 (Prof. Sarah ARC)
  Password: 123456
```

### Department 3 - Electronics and Communication Engineering (ECE)
```
ECE Senior Student:
  User ID: 205
  Name: ECE Senior Student
  Student UID: S-205
  National ID: 3000000205
  Email: ece.sen@mail.com
  Official Email: ece.sen@uni.edu
  GPA: 2.9
  Advisor ID: 104 (Prof. Laila ECE)
  Password: 123456

ECE Junior Student:
  User ID: 206
  Name: ECE Junior Student
  Student UID: S-206
  National ID: 3000000206
  Email: ece.jun@mail.com
  Official Email: ece.jun@uni.edu
  GPA: 3.1
  Advisor ID: 104 (Prof. Laila ECE)
  Password: 123456
```

### Department 4 - Mechatronics Engineering (MCT)
```
MCT Senior Student:
  User ID: 207
  Name: MCT Senior Student
  Student UID: S-207
  National ID: 3000000207
  Email: mct.sen@mail.com
  Official Email: mct.sen@uni.edu
  GPA: 3.8
  Advisor ID: 105 (Prof. Omar MCT)
  Password: 123456

MCT Junior Student:
  User ID: 208
  Name: MCT Junior Student
  Student UID: S-208
  National ID: 3000000208
  Email: mct.jun@mail.com
  Official Email: mct.jun@uni.edu
  GPA: 3.4
  Advisor ID: 105 (Prof. Omar MCT)
  Password: 123456
```

### Department 5 - Electrical Power and Machines Engineering (EPM)
```
EPM Senior Student:
  User ID: 209
  Name: EPM Senior Student
  Student UID: S-209
  National ID: 3000000209
  Email: epm.sen@mail.com
  Official Email: epm.sen@uni.edu
  GPA: 2.5
  Advisor ID: 103 (Prof. Mohamed EPM)
  Password: 123456

EPM Junior Student:
  User ID: 210
  Name: EPM Junior Student
  Student UID: S-210
  National ID: 3000000210
  Email: epm.jun@mail.com
  Official Email: epm.jun@uni.edu
  GPA: 2.7
  Advisor ID: 103 (Prof. Mohamed EPM)
  Password: 123456
```

**Login Instructions for Students:**
- Use any student's email (e.g., `cse.sen@mail.com` or `cse.sen@uni.edu`)
- Password: `123456`

---

## Parents

**10 Parents (one for each student):**

### Parent of CSE Senior Student
```
User ID: 301
Name: Parent of CSE Senior
National ID: PN-201
Email: parent201@mail.com
Official Email: parent201@mail.com
Linked Student: CSE Senior Student (User ID: 201, National ID: 3000000201)
Password: 123456
```

### Parent of CSE Junior Student
```
User ID: 302
Name: Parent of CSE Junior
National ID: PN-202
Email: parent202@mail.com
Official Email: parent202@mail.com
Linked Student: CSE Junior Student (User ID: 202, National ID: 3000000202)
Password: 123456
```

### Parent of ARC Senior Student
```
User ID: 303
Name: Parent of ARC Senior
National ID: PN-203
Email: parent203@mail.com
Official Email: parent203@mail.com
Linked Student: ARC Senior Student (User ID: 203, National ID: 3000000203)
Password: 123456
```

### Parent of ARC Junior Student
```
User ID: 304
Name: Parent of ARC Junior
National ID: PN-204
Email: parent204@mail.com
Official Email: parent204@mail.com
Linked Student: ARC Junior Student (User ID: 204, National ID: 3000000204)
Password: 123456
```

### Parent of ECE Senior Student
```
User ID: 305
Name: Parent of ECE Senior
National ID: PN-205
Email: parent205@mail.com
Official Email: parent205@mail.com
Linked Student: ECE Senior Student (User ID: 205, National ID: 3000000205)
Password: 123456
```

### Parent of ECE Junior Student
```
User ID: 306
Name: Parent of ECE Junior
National ID: PN-206
Email: parent206@mail.com
Official Email: parent206@mail.com
Linked Student: ECE Junior Student (User ID: 206, National ID: 3000000206)
Password: 123456
```

### Parent of MCT Senior Student
```
User ID: 307
Name: Parent of MCT Senior
National ID: PN-207
Email: parent207@mail.com
Official Email: parent207@mail.com
Linked Student: MCT Senior Student (User ID: 207, National ID: 3000000207)
Password: 123456
```

### Parent of MCT Junior Student
```
User ID: 308
Name: Parent of MCT Junior
National ID: PN-208
Email: parent208@mail.com
Official Email: parent208@mail.com
Linked Student: MCT Junior Student (User ID: 208, National ID: 3000000208)
Password: 123456
```

### Parent of EPM Senior Student
```
User ID: 309
Name: Parent of EPM Senior
National ID: PN-209
Email: parent209@mail.com
Official Email: parent209@mail.com
Linked Student: EPM Senior Student (User ID: 209, National ID: 3000000209)
Password: 123456
```

### Parent of EPM Junior Student
```
User ID: 310
Name: Parent of EPM Junior
National ID: PN-210
Email: parent210@mail.com
Official Email: parent210@mail.com
Linked Student: EPM Junior Student (User ID: 210, National ID: 3000000210)
Password: 123456
```

**Login Instructions for Parents:**
- Use any parent's email (e.g., `parent201@mail.com`)
- Password: `123456`

---

## Quick Login Reference

### Admin
- **Email:** `admin@lms.edu` or `admin@uni.edu`
- **Password:** `123456`

### Instructor (Example: CSE Department Head)
- **Email:** `ahmed.cse@uni.edu` or `head.cse@uni.edu`
- **Password:** `123456`

### Student (Example: CSE Senior Student)
- **Email:** `cse.sen@mail.com` or `cse.sen@uni.edu`
- **Password:** `123456`

### Parent (Example: Parent of CSE Senior Student)
- **Email:** `parent201@mail.com`
- **Password:** `123456`

---

## Password Information

**All users in the test database use the same password:** `123456`

The password hash stored in the database for all users (admin, instructors, students, and parents) is:
- **All Users:** `$2a$10$6ccfmPKMJBX0fxgOt9efqunlSwIdEL7qFVbUnl3y0b.3Y2jO6mnye`

**Note:** This is a BCrypt hash for the password `123456`. All users (admin, instructors, students, and parents) use this same password for testing purposes.

---

## Enrollment Information

### Seniors (User IDs: 201, 203, 205, 207, 209)
- Enrolled in all 5 semesters:
  - Fall 2023 (Semester 1)
  - Spring 2024 (Semester 2)
  - Fall 2024 (Semester 3)
  - Spring 2025 (Semester 4)
  - Fall 2025 (Semester 5 - Current)

### Juniors (User IDs: 202, 204, 206, 208, 210)
- Enrolled in semesters 3, 4, and 5:
  - Fall 2024 (Semester 3)
  - Spring 2025 (Semester 4)
  - Fall 2025 (Semester 5 - Current)

---

## Current Semester

**Fall 2025** (Semester ID: 5) is the current semester with registration open.

---

## Department Codes Reference

- **CSE** - Computer and Systems Engineering Department
- **ARC** - Architecture Engineering Department
- **ECE** - Electronics and Communication Engineering Department
- **MCT** - Mechatronics Engineering Department
- **EPM** - Electrical Power and Machines Engineering Department
- **ASU** - ASU Courses (General / University Requirements) - Service department, no students
- **PHM** - Engineering Physics and Mathematics Department - Service department, no students
