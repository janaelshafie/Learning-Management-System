// package com.asu_lms.lms.Controllers;

// import org.junit.jupiter.api.Assertions;
// import org.junit.jupiter.api.Test;

// import java.util.Arrays;
// import java.util.HashMap;
// import java.util.List;
// import java.util.Map;
// import static org.mockito.Mockito.*;
// import com.asu_lms.lms.Services.AuthService;
// import com.asu_lms.lms.Repositories.UserRepository;
// import com.asu_lms.lms.Entities.User;
// import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
// import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
// import org.springframework.test.web.servlet.MockMvc;
// import org.mockito.InjectMocks;
// import org.mockito.Mock;
// import org.mockito.junit.jupiter.MockitoExtension;
// import org.junit.jupiter.api.extension.ExtendWith;
// import com.fasterxml.jackson.databind.ObjectMapper;


// import static org.junit.jupiter.api.Assertions.*;

// @ExtendWith(MockitoExtension.class)
// class LoginControllerTest {
//     @Mock
//     private UserRepository userRepository;

//     @InjectMocks
//     private LoginController userController;

//     @Test
//     void getAllUsers() {
//         User user1 = new User();
//         user1.setUserId(215);
//         user1.setName("Seif");
//         user1.setEmail("Seif@gmail.com");
//         user1.setOfficialMail("22p0215@eng.asu.edu.eg");
//         user1.setRole("student");
//         user1.setAccountStatus("active");

//         User user2 = new User();
//         user2.setUserId(235);
//         user2.setName("User2");
//         user2.setEmail("User2@gmail.com");
//         user2.setOfficialMail("22p0235@eng.asu.edu.eg");
//         user2.setRole("student");
//         user2.setAccountStatus("active");

//         User user3 = new User();
//         user3.setUserId(2004);
//         user3.setName("Ahmed");
//         user3.setEmail("ahmed@gmail.com");
//         user3.setOfficialMail("22p0217@admin.asu.edu.eg");
//         user3.setRole("admin");
//         user3.setAccountStatus("active");

//         User user4 = new User();
//         user4.setUserId(236);
//         user4.setName("Youssef");
//         user4.setEmail("youssef@gmail.com");
//         user4.setOfficialMail("22p0236@prof.edu.eg");
//         user4.setRole("instructor");
//         user4.setAccountStatus("active");

//         List<User> users = Arrays.asList(user1, user2, user3, user4);
//         when(userRepository.findAll()).thenReturn(users);

//         Map<String, Object> response = userController.getAllUsers();

//         assertEquals("success", response.get("status"));
//         assertEquals(4, response.get("totalUsers"));
//         assertEquals(user1, response.get("user"));
//         assertEquals("admin", users.get(2).getRole());//check role of user 3
//         assertEquals("22p0236@prof.asu.edu.eg", users.get(3).getOfficialMail());
//     }

//     @Test
//     public void testGetAllUsers_Error() {
//         when(userRepository.findAll()).thenThrow(new RuntimeException("Database failure"));

//         Map<String, Object> response = userController.getAllUsers();

//         assertEquals("error", response.get("status"));
//         assertEquals("Database failure", response.get("message"));
//     }

//     @Test

//     public void testEmptyEmail_ReturnsErrorMessage() {
//         LoginController controller = new LoginController();
//         Map<String, String> request = new HashMap<>();
//         request.put("email", "");
//         request.put("password", "somePassword");
//         Map<String, String> response = controller.login(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Email is required", response.get("message"));
//     }

//     @Test
//     public void testEmptyPassword_ReturnsErrorMessage() {
//         LoginController controller = new LoginController();
//         Map<String, String> request = new HashMap<>();
//         request.put("email", "user@eng.asu.edu.eg");
//         request.put("password", "");
//         Map<String, String> response = controller.login(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Password is required", response.get("message"));
//     }

//     @Test
//     public void testCorrectEntry(){
//         LoginController controller = new LoginController();
//         Map<String, String> request = new HashMap<>();
//         request.put("email", "22p0215@eng.asu.edu.eg");//correct email
//         request.put("password", "Huss2004!!");//correct password
//         Map<String, String> response = controller.login(request);
//         assertEquals("success", response.get("status"));
//         assertEquals("student", response.get("role"));
//     }

//     @Mock
//     private AuthService authService;

//     @InjectMocks
//     private LoginController signupController; // Or LoginController if the signup method is there

//     @Test
//     public void testStudentSignup_NotAllowed() {
//         Map<String, String> request = new HashMap<>();
//         request.put("role", "student");
//         Map<String, String> response = signupController.signup(request);
//         assertEquals("error", response.get("status"));
//         assertEquals("Students cannot create accounts. Please contact administration.", response.get("message"));
//     }

//     @Test
//     public void testSignup_Success() {
//         Map<String, String> request = new HashMap<>();
//         request.put("role", "instructor");
//         request.put("name", "Dr. Ahmed");
//         request.put("nationalId", "12345678901234");
//         request.put("email", "ahmed@gmail.com");
//         request.put("officialMail", "22p0215@prof.asu.edu.eg");
//         request.put("phone", "01001234567");
//         request.put("location", "Cairo");
//         request.put("password", "Test1234!");
//         request.put("studentNationalId", "");

//         when(authService.signup(anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString())).thenReturn("success");

//         Map<String, String> response = signupController.signup(request);

//         assertEquals("success", response.get("status"));
//         assertEquals("Account created successfully", response.get("message"));
//     }

//     @Test
//     public void testSignup_ErrorFromService() {
//         Map<String, String> request = new HashMap<>();
//         request.put("role", "instructor");
//         request.put("name", "Dr. Error");
//         // ... (fill other fields as needed) fill with existing account

//         when(authService.signup(anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString(), anyString()))
//                 .thenReturn("Email already exists");

//         Map<String, String> response = signupController.signup(request);

//         assertEquals("error", response.get("status"));
//         assertEquals("Email already exists", response.get("message"));
//     }



// }