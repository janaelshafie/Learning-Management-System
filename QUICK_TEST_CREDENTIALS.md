
### Admin

**Super Admin**
```
User ID: 1
Name: System Admin
Email: admin@lms.edu
Official Email: admin@uni.edu
Password: hash123
```

---

### Instructors

**Department Heads (5 Departments + 1 ASU Coordinator):**

**Dept 1 - Computer and Systems Engineering (CSE)**
```
User ID: 101
Name: Prof. Ahmed CSE
Email: ahmed.cse@uni.edu
Official Email: head.cse@uni.edu
Department ID: 1
Office Hours: Sun/Tue 10-12
Password: hash123
```

**Dept 2 - Architecture Engineering (ARC)**
```
User ID: 102
Name: Prof. Sarah ARC
Email: sarah.arc@uni.edu
Official Email: head.arc@uni.edu
Department ID: 2
Office Hours: Mon/Wed 10-12
Password: hash123
```

**Dept 3 - Mechanical Power Engineering (MEP)**
```
User ID: 103
Name: Prof. Mohamed MEP
Email: mohamed.mep@uni.edu
Official Email: head.mep@uni.edu
Department ID: 3
Office Hours: Sun/Thu 12-2
Password: hash123
```

**Dept 4 - Electronics and Communication Engineering (ECE)**
```
User ID: 104
Name: Prof. Laila ECE
Email: laila.ece@uni.edu
Official Email: head.ece@uni.edu
Department ID: 4
Office Hours: Tue/Thu 9-11
Password: hash123
```

**Dept 5 - Structural Engineering (CES)**
```
User ID: 105
Name: Prof. Omar CES
Email: omar.ces@uni.edu
Official Email: head.ces@uni.edu
Department ID: 5
Office Hours: Mon/Wed 1-3
Password: hash123
```

**ASU Courses Coordinator**
```
User ID: 106
Name: Dr. Amira ASU
Email: amira.asu@uni.edu
Official Email: coordinator.asu@uni.edu
Department ID: 6 (ASU Courses)
Office Hours: Tue/Thu 2-4
Password: hash123
```

---

### Students

**2 Students per Department (10 Total Students):**

**Department 1 - Computer and Systems Engineering (CSE)**
```
CSE Senior Student:
  User ID: 201
  Name: CSE Senior Student
  Student UID: S-201
  Email: cse.sen@mail.com
  Official Email: cse.sen@uni.edu
  GPA: 3.2
  Advisor ID: 101
  Password: hash

CSE Junior Student:
  User ID: 202
  Name: CSE Junior Student
  Student UID: S-202
  Email: cse.jun@mail.com
  Official Email: cse.jun@uni.edu
  GPA: 2.8
  Advisor ID: 101
  Password: hash
```

**Department 2 - Architecture Engineering (ARC)**
```
ARC Senior Student:
  User ID: 203
  Name: ARC Senior Student
  Student UID: S-203
  Email: arc.sen@mail.com
  Official Email: arc.sen@uni.edu
  GPA: 3.5
  Advisor ID: 102
  Password: hash

ARC Junior Student:
  User ID: 204
  Name: ARC Junior Student
  Student UID: S-204
  Email: arc.jun@mail.com
  Official Email: arc.jun@uni.edu
  GPA: 3.0
  Advisor ID: 102
  Password: hash
```

**Department 3 - Mechanical Power Engineering (MEP)**
```
MEP Senior Student:
  User ID: 205
  Name: MEP Senior Student
  Student UID: S-205
  Email: mep.sen@mail.com
  Official Email: mep.sen@uni.edu
  GPA: 2.9
  Advisor ID: 103
  Password: hash

MEP Junior Student:
  User ID: 206
  Name: MEP Junior Student
  Student UID: S-206
  Email: mep.jun@mail.com
  Official Email: mep.jun@uni.edu
  GPA: 3.1
  Advisor ID: 103
  Password: hash
```

**Department 4 - Electronics and Communication Engineering (ECE)**
```
ECE Senior Student:
  User ID: 207
  Name: ECE Senior Student
  Student UID: S-207
  Email: ece.sen@mail.com
  Official Email: ece.sen@uni.edu
  GPA: 3.8
  Advisor ID: 104
  Password: hash

ECE Junior Student:
  User ID: 208
  Name: ECE Junior Student
  Student UID: S-208
  Email: ece.jun@mail.com
  Official Email: ece.jun@uni.edu
  GPA: 3.4
  Advisor ID: 104
  Password: hash
```

**Department 5 - Structural Engineering (CES)**
```
CES Senior Student:
  User ID: 209
  Name: CES Senior Student
  Student UID: S-209
  Email: ces.sen@mail.com
  Official Email: ces.sen@uni.edu
  GPA: 2.5
  Advisor ID: 105
  Password: hash

CES Junior Student:
  User ID: 210
  Name: CES Junior Student
  Student UID: S-210
  Email: ces.jun@mail.com
  Official Email: ces.jun@uni.edu
  GPA: 2.7
  Advisor ID: 105
  Password: hash
```

---

1. **Admin Login:**
   - Email: `admin@lms.edu` or `admin@uni.edu`
   - Password: (Verify in Insertion.sql)

2. **Instructor Login (CSE Department Head):**
   - Email: `ahmed.cse@uni.edu` or `head.cse@uni.edu`
   - Password: (Verify in Insertion.sql)

3. **Student Login (CSE Senior Student):**
   - Email: `cse.sen@mail.com` or `cse.sen@uni.edu`
   - Password: (Verify in Insertion.sql)

**To verify passwords:** Check the Insertion.sql file for the BCrypt hashes, or test login attempts with common passwords to determine the actual plain text values.