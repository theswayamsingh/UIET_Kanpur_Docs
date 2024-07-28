library globals;

import 'package:flutter/material.dart';

// HomeScreen
var navigationIndex = 0;

// SemesterScreen
var branchIndex = -1;
var semesterIndex = -1;
var yearIndex = -1;
var examIndex = -1;
var count = 8;
var semesters = ['1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'];
var years = ['2024-2025', '2023-2024', '2022-2023', '2021-2022'];
var exams = ['Mid Semester', 'End Semester'];
var semScreenHeading = 'SEMESTERS';

// User
var email = TextEditingController();
var password = TextEditingController();
var confirmPassword = TextEditingController();
var userName = TextEditingController();
var userBranch = 'CSE';
var userBatch = '2021-2025';
Widget? userPhoto;
bool signUpPressed = false;

bool isSignedIn = false;
bool isEmailVerified = false;
bool emailSent = false;
bool isSignedInRun = false;

// Doc Item
var ItemsListTitle = 'PYQs';
var itemIndex;
var filesRef;
var folder = 'pyqs';

bool isContriScreenOpen = false;
bool isFilesRefEmpty=false;
