# University Learning Management System (LMS)

A comprehensive, full-stack Learning Management System designed for universities to manage academic operations including course management, student enrollment, instructor assignments, room reservations, and parent-student communication.

[![Java](https://img.shields.io/badge/Java-25-orange)](https://www.oracle.com/java/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.5.6-brightgreen)](https://spring.io/projects/spring-boot)
[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Project Structure](#project-structure)
- [API Endpoints](#api-endpoints)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Overview

The University LMS is a modern, scalable solution for managing academic operations in educational institutions. Built with Spring Boot and Flutter, it provides a seamless experience across web, desktop, and mobile platforms. The system supports multiple departments and implements role-based access control for administrators, instructors, students, and parents.

### Key Highlights

- **Multi-platform Support**: Web, Windows, Android, and iOS
- **Role-Based Access Control**: Four distinct user roles with granular permissions
- **Flexible Data Model**: Entity-Attribute-Value (EAV) architecture for extensibility
- **Real-time Updates**: Modern, responsive interface with hot reload support
- **Comprehensive Academic Tools**: Course materials, assignments, quizzes, and grading

## Features

### Admin Features

- **User Management**: Complete CRUD operations for all user types
- **Department Management**: Create and manage seven academic departments
- **Course Management**: Add, edit, and assign courses to departments
- **Semester Management**: Create and manage academic terms
- **Room Management**: Advanced room system with 37+ flexible attributes
- **Approval Workflows**: Account approvals, room reservations, profile changes
- **System Announcements**: Create and distribute announcements
- **Dashboard Analytics**: System-wide statistics and overview

### Instructor Features

- **Course Material Management**
  - Upload files (PDFs, PowerPoint, documents, images)
  - Add video links and websites
  - Auto-extract metadata (page count, slide count, video format)
  - Multi-language support
- **Assignment System**
  - Flexible configuration (late submissions, attempts, file restrictions)
  - Multiple question types (MCQ, Short Text, True/False)
  - Plagiarism checking options
  - Automated grading support
- **Quiz Management**
  - Timed quizzes with customizable settings
  - Question/option randomization
  - Immediate or delayed result visibility
  - Detailed feedback controls
- **Student Management**: View enrolled students and manage grades
- **Room Booking**: Reserve rooms with schedule viewing
- **Office Hours**: Manage availability and appointments

### Student Features

- **Course Registration**: Enroll in courses during registration periods
- **Course Materials**: Access and download all course resources
- **Assignments & Quizzes**: Submit work and view grades
- **Academic Progress**: Detailed grade breakdown by components
- **Schedule Management**: View class schedules and rooms
- **Announcements**: Access course-specific and system-wide updates

### Parent Features

- **Student Monitoring**: View linked student's academic information
- **Grade Tracking**: Access detailed grade reports
- **Progress Reports**: Monitor student performance over time
- **Communication**: Message instructors and administration
- **Schedule Access**: View student's class schedule

## Technology Stack

### Backend

- **Framework**: Spring Boot 3.5.6
- **Language**: Java 25
- **Build Tool**: Maven
- **Database**: MySQL 8.0+
- **ORM**: Spring Data JPA / Hibernate
- **Security**: Spring Security with BCrypt
- **Server**: Embedded Tomcat (Port 8080)

### Frontend

- **Framework**: Flutter 3.8.1+
- **Language**: Dart 3.8.1
- **Platforms**: Web, Windows, Android, iOS
- **State Management**: App State Management
- **HTTP Client**: http package
- **PDF Viewer**: Syncfusion, Advance PDF Viewer
- **UI Components**: Material Design

### Database

- **DBMS**: MySQL
- **Database Name**: university_lms_db
- **Connection**: JDBC
- **Driver**: MySQL Connector/J

## System Architecture

### Architecture Pattern

The system follows a modern, layered architecture:

- **Backend**: RESTful API with Spring Boot
- **Frontend**: Cross-platform Flutter application
- **Database**: MySQL relational database
- **Communication**: HTTP/REST API

### Entity-Attribute-Value (EAV) Model

The system implements an advanced EAV design pattern for maximum flexibility:

**Nine EAV Models Implemented**:

1. **CourseMaterial EAV**: Supports multiple material types with auto-metadata extraction
2. **Assignment EAV**: Flexible submission policies and file restrictions
3. **Quiz EAV**: Customizable timing, attempts, and feedback settings
4. **Grade EAV**: Flexible grading schemes with custom components
5. **Question EAV**: Multiple question types with type-specific attributes
6. **StudentAnswer EAV**: Stores answers in various formats
7. **Enrollment EAV**: Tracks enrollment metadata and status
8. **RoomAttributes EAV**: 37+ flexible room attributes for different room types
9. **AnnouncementAttributes EAV**: Flexible announcement targeting and features

**Benefits**:
- Add new attributes without schema changes
- Support varying requirements across departments
- Future-proof extensibility
- Easy feature additions without migrations

### Backend Architecture Layers

1. **Controller Layer**: REST API endpoints
2. **Service Layer**: Business logic and validation
3. **Repository Layer**: Database operations
4. **Model/Entity Layer**: Domain entities and DTOs

### Frontend Architecture

1. **UI Layer**: Flutter widgets and screens
2. **Service Layer**: API communication services
3. **State Management**: Application state handling
4. **Common Components**: Reusable UI elements

## Prerequisites

### Required Software

- **Java Development Kit (JDK)**: Version 25 or compatible
  - Verify: `java -version`
- **Maven**: 3.6+ (or use included Maven Wrapper)
  - Verify: `mvn -version`
- **MySQL**: Version 8.0+ recommended
  - Verify: `mysql --version`
- **Flutter SDK**: Version 3.8.1 or higher
  - Verify: `flutter --version`
- **Git**: For version control

### Recommended IDEs

- **Backend**: IntelliJ IDEA, Eclipse, or VS Code
- **Frontend**: Android Studio, VS Code, or IntelliJ IDEA

## Installation

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd FullProject
```

### Step 2: Database Setup

1. Start MySQL server

2. Create the database:
```sql
mysql -u root -p
CREATE DATABASE university_lms_db;
exit;
```

3. Run SQL scripts in order:
```bash
# Navigate to the directory containing SQL files
cd front/

# Create all tables (including EAV model tables)
mysql -u root -p university_lms_db < TableCreation.sql

# Insert course data
mysql -u root -p university_lms_db < CourseInsertion.sql

# Insert room data and attributes
mysql -u root -p university_lms_db < RoomInsertion.sql

# Insert users, enrollments, and grades
mysql -u root -p university_lms_db < Insertion.sql
```

**Note**: The backend will automatically initialize EAV attributes for CourseMaterial, Assignment, Quiz, Questions, and StudentAnswers on first startup.

### Step 3: Backend Setup

1. Navigate to backend directory:
```bash
cd back/
```

2. Configure database connection:
   - Edit `src/main/resources/application.properties`
   - Update credentials if needed (see Configuration section)

3. Build the project:
```bash
./mvnw clean install
# Windows: mvnw.cmd clean install
```

4. Run the backend:
```bash
./mvnw spring-boot:run
# Windows: mvnw.cmd spring-boot:run
```

5. Verify backend is running at `http://localhost:8080`

### Step 4: Frontend Setup

1. Navigate to frontend directory:
```bash
cd front/
```

2. Install dependencies:
```bash
flutter pub get
```

3. Update API base URL (if needed):
   - Edit `lib/services/api_services.dart`
   - Default: `http://localhost:8080`

4. Run the application:
```bash
# Select platform
flutter run

# Or specify platform
flutter run -d chrome        # Web
flutter run -d windows       # Windows
flutter run -d android       # Android
```

## Configuration

### Backend Configuration

**File**: `back/src/main/resources/application.properties`

```properties
# Database Configuration
spring.datasource.url=jdbc:mysql://localhost:3306/university_lms_db
spring.datasource.username=root
spring.datasource.password=000123
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver

# JPA/Hibernate Configuration
spring.jpa.hibernate.naming.physical-strategy=org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQLDialect

# Server Configuration
server.port=8080
```

**⚠️ Production Recommendations**:
- Change default database credentials
- Use environment variables for sensitive data
- Set `spring.jpa.show-sql=false`
- Enable SSL for database connections
- Implement connection pooling

### Frontend Configuration

**File**: `front/lib/services/api_services.dart`

Update the API base URL to match your backend server:
- **Development**: `http://localhost:8080`
- **Production**: Update to production server URL
- **Mobile Testing**: Use IP address instead of localhost

## Running the Application

### Development Mode

**Backend**:
```bash
cd back/
./mvnw spring-boot:run
```
Backend runs on `http://localhost:8080` with hot reload enabled.

**Frontend**:
```bash
cd front/
flutter run
```
Hot reload: Press `r` | Hot restart: Press `R`

### Production Mode

**Backend**:
```bash
# Build JAR
./mvnw clean package

# Run JAR
java -jar target/lms-0.0.1-SNAPSHOT.jar
```

**Frontend**:
```bash
# Web
flutter build web

# Windows
flutter build windows

# Android
flutter build apk

# iOS
flutter build ios
```

**Build Outputs**:
- Backend JAR: `back/target/lms-0.0.1-SNAPSHOT.jar`
- Frontend Web: `front/build/web/`
- Frontend Windows: `front/build/windows/`
- Frontend Android: `front/build/app/outputs/flutter-apk/`

## Project Structure

```
FullProject/
├── back/                          # Spring Boot Backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/asu_lms/lms/
│   │   │   │   ├── controllers/   # REST API controllers
│   │   │   │   ├── services/      # Business logic
│   │   │   │   ├── repositories/  # Data access layer
│   │   │   │   ├── models/        # Entity classes
│   │   │   │   ├── dto/           # Data Transfer Objects
│   │   │   │   └── config/        # Configuration classes
│   │   │   └── resources/
│   │   │       └── application.properties
│   │   └── test/                  # Test files
│   ├── pom.xml                    # Maven dependencies
│   └── mvnw / mvnw.cmd           # Maven wrapper
│
├── front/                         # Flutter Frontend
│   ├── lib/
│   │   ├── main.dart              # Entry point
│   │   ├── common/                # Shared components
│   │   ├── screens/               # UI screens
│   │   │   ├── auth/              # Authentication
│   │   │   ├── admin/             # Admin screens
│   │   │   ├── instructor/        # Instructor screens
│   │   │   ├── student/           # Student screens
│   │   │   └── parent/            # Parent screens
│   │   └── services/
│   │       └── api_services.dart  # API communication
│   ├── assets/                    # Images and PDFs
│   ├── pubspec.yaml               # Flutter dependencies
│
│  
│
│
└── README.md                      # This file
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration
- `POST /api/auth/logout` - User logout

### User Management
- `GET /api/users` - List all users
- `GET /api/users/{id}` - Get user by ID
- `POST /api/users` - Create new user
- `PUT /api/users/{id}` - Update user
- `DELETE /api/users/{id}` - Delete user

### Course Management
- `GET /api/courses` - List all courses
- `GET /api/courses/{id}` - Get course details
- `POST /api/courses` - Create course
- `PUT /api/courses/{id}` - Update course
- `DELETE /api/courses/{id}` - Delete course

### Course Materials
- `GET /api/course/materials/{offeredCourseId}` - Get course materials
- `POST /api/course/materials/upload` - Upload material file
- `POST /api/course/materials/create` - Create material
- `GET /api/course/materials/download/{materialId}` - Download material
- `DELETE /api/course/materials/{materialId}` - Delete material

### Assignments
- `GET /api/assignments/{offeredCourseId}` - List assignments
- `POST /api/assignments` - Create assignment
- `GET /api/assignments/{assignmentId}` - Get assignment details
- `PUT /api/assignments/{assignmentId}` - Update assignment
- `DELETE /api/assignments/{assignmentId}` - Delete assignment
- `POST /api/assignments/{assignmentId}/submit` - Submit assignment

### Quizzes
- `GET /api/quizzes/{offeredCourseId}` - List quizzes
- `POST /api/quizzes` - Create quiz
- `GET /api/quizzes/{quizId}` - Get quiz details
- `PUT /api/quizzes/{quizId}` - Update quiz
- `DELETE /api/quizzes/{quizId}` - Delete quiz
- `POST /api/quizzes/{quizId}/submit` - Submit quiz

### Room Management
- `GET /api/rooms/list` - List all rooms
- `GET /api/rooms/{roomId}` - Get room details
- `POST /api/rooms` - Create room
- `PUT /api/rooms/{roomId}` - Update room
- `DELETE /api/rooms/{roomId}` - Delete room
- `GET /api/rooms/attributes` - Get room attribute definitions
- `POST /api/rooms/{roomId}/attributes` - Set room attributes
- `POST /api/rooms/reserve` - Reserve room
- `GET /api/rooms/reservations` - List reservations

**Note**: All EAV-enabled endpoints include attributes in request/response JSON bodies.

## Testing

### Backend Testing

```bash
cd back/
./mvnw test
```

Test files location: `back/src/test/`

### Frontend Testing

```bash
cd front/
flutter test
```

### Manual Testing Checklist

- [ ] Login functionality for all roles
- [ ] User management (CRUD operations)
- [ ] Course registration workflow
- [ ] Assignment submission and grading
- [ ] Quiz creation and taking
- [ ] Room booking and approval
- [ ] Material upload and download
- [ ] Grade viewing with components
- [ ] Parent-student linking
- [ ] Announcement system
- [ ] Responsive design on different devices

## Troubleshooting

### Database Connection Error

**Problem**: Cannot connect to MySQL database

**Solutions**:
- Verify MySQL is running
- Check credentials in `application.properties`
- Ensure database `university_lms_db` exists
- Verify MySQL is running on port 3306

### Backend Won't Start

**Problem**: Spring Boot application fails to start

**Solutions**:
- Check Java version: `java -version` (requires JDK 25)
- Run: `./mvnw clean install`
- Verify port 8080 is available
- Review console error messages

### Frontend Build Errors

**Problem**: Flutter build fails

**Solutions**:
- Run: `flutter pub get`
- Check Flutter version: `flutter --version`
- Clear cache: `flutter clean`
- Verify Dart SDK installation

### API Connection Issues

**Problem**: Frontend cannot connect to backend

**Solutions**:
- Verify backend is running on port 8080
- Check API base URL in `api_services.dart`
- For mobile: Use IP address instead of `localhost`
- Check CORS configuration

### Login Not Working

**Problem**: Cannot login with test credentials

**Solutions**:
- Verify password is `123456`
- Check `Insertion.sql` was executed
- Verify `account_status` is `active` in database
- Check BCrypt password hashing

## Future Enhancements

### Planned Features

- [ ] Email and SMS notifications
- [ ] Native mobile apps (iOS/Android)
- [ ] Advanced analytics and reporting
- [ ] Automatic grade calculation
- [ ] Attendance tracking with EAV
- [ ] Online exam proctoring
- [ ] Video conferencing integration
- [ ] Multi-language support
- [ ] Dark mode theme
- [ ] Calendar integration
- [ ] Discussion forums
- [ ] Peer review system

### Technical Improvements

- [ ] API documentation (Swagger/OpenAPI)
- [ ] Increased test coverage
- [ ] Performance optimization
- [ ] Caching implementation
- [ ] Docker containerization
- [ ] CI/CD pipeline
- [ ] Automated backups
- [ ] Microservices architecture

## Contributing

We welcome contributions! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/AmazingFeature`
3. Commit your changes: `git commit -m 'Add some AmazingFeature'`
4. Push to the branch: `git push origin feature/AmazingFeature`
5. Open a Pull Request

### Code Style

- Follow Java coding conventions for backend
- Follow Dart/Flutter style guide for frontend
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

## License

This project is proprietary and confidential. All rights reserved.

*For open-source licensing options, please contact the project maintainers.*

## Contact

**Project Maintainers / Team Members**:

| Name | Student ID |
|------|------------|
| Ahmed Mohamed Al Amin | 22P0137 |
| Jana Hany Elshafie | 22P0235 |
| Omar Saher | 22P0161 |
| Seif Elhusseiny | 22P0215 |
| Youssef Tarek Kamal | 22P0236 |


## Acknowledgments

- Spring Boot team for the excellent framework
- Flutter team for cross-platform capabilities
- MySQL team for robust database system
- All contributors and testers

---


**Built with ❤️ for modern education**

