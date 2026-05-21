DROP DATABASE IF EXISTS final_db;

CREATE DATABASE final_db;
USE final_db;

-- PHẦN 1: DDL - THIẾT KẾ CSDL
CREATE TABLE courses (
course_id INT PRIMARY KEY AUTO_INCREMENT,
course_name VARCHAR(50) NOT NULL,
course_code VARCHAR(10) NOT NULL UNIQUE,
department VARCHAR(50) NOT NULL,
creation_date DATE NOT NULL
);

CREATE TABLE students (
student_id INT PRIMARY KEY AUTO_INCREMENT,
full_name VARCHAR(50) NOT NULL,
major VARCHAR(100) NOT NULL,
phone_number VARCHAR(15) NOT NULL UNIQUE,
gpa DECIMAL(2,1)
CONSTRAINT CHECK ( gpa >= 0.0 AND gpa <= 4.0) DEFAULT 4.0
);

CREATE TABLE enrollments (
enrollment_id INT PRIMARY KEY ,
course_id INT,
FOREIGN KEY (course_id) REFERENCES courses(course_id),
student_id INT,
FOREIGN KEY (student_id) REFERENCES students(student_id),
enroll_time TIMESTAMP NOT NULL,
credits INT CHECK(credits>0),
status VARCHAR(15) NOT NULl
);

CREATE TABLE enrollment_details (
detail_id INT PRIMARY KEY,
enrollment_id INT ,
FOREIGN KEY (enrollment_id) REFERENCES enrollments(enrollment_id),
attendance_check VARCHAR(50) NOT NULL,
detail_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE academic_logs (
log_id INT PRIMARY KEY AUTO_INCREMENT,
detail_id INT,
FOREIGN KEY (detail_id) REFERENCES enrollment_details(detail_id),
student_id INT,
FOREIGN KEY (student_id) REFERENCES students(student_id),
log_time DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
note TEXT
);

-- PHẦN 2 DML - INSERT, UPDATE, DELETE 

-- Câu 1: Insert
INSERT INTO courses(course_name,course_code,department,creation_date)
VALUES 
('Lập trình Java','JAVA01','CNTT','2023-12-03'),
('Cấu trúc dữ liệu','DSA02','Khoa học máy tính','1996-11-25'),
('Cơ sở dữ liệu','SQL03','CNTT','2001-07-08'),
('Mạng máy tính','NET04','Truyền thông','1998-01-19'),
('Trí tuệ nhân tạo','AI05','Khoa học máy tính','2000-09-30');

INSERT INTO students(full_name, major, phone_number, gpa)
VALUES
('Nguyễn Văn Hải','Hệ thống TT','0931112223',3.8),
('Trần Thu Hà','Kỹ thuật PM','0932223334',4.0),
('Lê Quốc Tuấn','An toàn TT','0933334445',3.6),
('Phạm Minh Châu','Dữ liệu lớn','0934445556',3.9),
('Hoàng Gia Bảo','Kỹ thuật PM','0935556667',3.7);

INSERT INTO enrollments(enrollment_id, course_id, student_id, enroll_time, credits, status)
VALUES
(7001,1,1,'2024-05-20 08:00',3,'Pending'),
(7002,2,2,'2024-05-20 09:30',4,'Completed'),
(7003,3,3,'2024-05-20 10:15',3,'Pending'),
(7004,4,4,'2024-05-21 07:00',3,'Completed'),
(7005,5,5,'2024-05-21 08:45',4,'Dropped');

INSERT INTO enrollment_details(detail_id, enrollment_id, attendance_check, detail_date)
VALUES
(8001,7002,'Đủ điều kiện thi', '2024-05-20 10:00'),
(8002,7004,'Vắng 1 buổi', '2024-05-21 08:00'),
(8003,7001,'Đang học', '2024-05-20 09:00'),
(8004,7003,'Nghỉ phép', '2024-05-20 11:00'),
(8005,7005,'Không đi học', '2024-05-21 09:00');


INSERT INTO academic_logs(detail_id, student_id, log_time, note)
VALUES 
(8003,1,'2024-05-20 09:05','Bắt đầu lớp học'),
(8001,2,'2024-05-20 10:05','Hoàn tất môn học'),
(8004,3,'2024-05-20 11:10','Đang sắp xếp lịch bù'),
(8002,5,'2024-05-21 08:10','Chờ phê duyệt điểm'),
(8005,4,'2024-05-21 09:05','Hủy do vắng quá số buổi');

-- Câu 2: Update & Delete

-- 2.1 Viết câu lệnh tăng thêm 1 tín chỉ (credits) cho các bản ghi đăng ký học 
--     thỏa mãn đồng thời trạng thái completed và thuộc môn học có năm tạo creation_date nhỏ hơn 2000
UPDATE courses c 
JOIN enrollments e ON e.course_id=c.course_id
SET credits=credits+1
WHERE status='Completed' AND YEAR(creation_date) < '2000';

-- 2.2 Viết câu lệnh xóa các bản ghi trong academic_logs 
--     thỏa mãn có log_time trước ngày 20/05/2024
DELETE FROM academic_logs WHERE DATE(log_time) < '2024-05-20';

-- PHẦN 3: TRUY VẤN CƠ BẢN

-- Câu 1: Liệt kê các thông tin sinh viên gồm full_name, major và gpa 
-- của những sinh viên có điểm gpa lớn hơn 3.8 hoặc thuộc chuyên nghành 'Kỹ thuật PM'
SELECT full_name, major, gpa 
FROM students 
WHERE gpa > 3.8 OR major = 'Kỹ thuật PM';

-- Câu 2: Liệt kê các thông tin môn học gồm course_name và course_code Của những môn học 
-- có ngày tạo trong khoảng từ 1998-01-01 đến 2001-12-31 và mã học phần bắt đầu bằng 'A'
SELECT course_name, course_code 
FROM courses WHERE creation_date 
BETWEEN '1998-01-01' AND '2001-12-31' AND course_code LIKE 'A%' ;

-- Câu 3: Liệt kê các bản ghi đăng ký học gồm enrollment_id,enroll_time và credits,
-- trong đó danh sách được sắp xếp theo số tín chỉ giảm dần và chỉ hiển thị 2 bản ghi ở trang thứ hai
SELECT enrollment_id, enroll_time, credits 
FROM enrollments 
ORDER BY credits DESC 
LIMIT 2 OFFSET 2;

-- PHẦN 4: TRUY VẤN NÂNG CAO
-- Câu 1: Liệt kê các thông tin xử lý học vụ gồm tên môn học, họ tên sinh viên, chuyên nghành, 
-- số tín chỉ và thời gian đăng ký, với dữ liệu được lấy từ các bảng liên quan trong hệ thống 
SELECT c.course_name, s.full_name, s.major, e.credits, e.enroll_time
FROM enrollments e
INNER JOIN courses c ON e.course_id=c.course_id
JOIN students s ON e.student_id=s.student_id
;

-- Câu 2 Liệt kê các thông tin sinh viên gồm họ tên sinh viên và tổng số tín chỉ mà sinh viên đó đã 
-- tích lũy ( chỉ tính các đăng ký trạng thái Completed), chỉ hiển thị những sinh viên có tổng số tín chỉ lơn hơn 120
SELECT s.full_name ,SUM(e.credits) AS total_credits 
FROM enrollments e 
INNER JOIN students s ON e.student_id=s.student_id
HAVING (SELECT SUM(credits) FROM enrollments WHERE status = 'Completed' GROUP BY student_id)
;

SELECT SUM(credits) FROM enrollments WHERE status = 'Completed' GROUP BY student_id;

-- Câu 3: Liệt kê các thông tin sinh viên gồm student_id, full_name và gpa của những sinh viên có điểm trung bình GPA cao nhất

SELECT student_id, full_name, gpa FROM students WHERE gpa IN (SELECT MAX(gpa) FROM students);

-- PHẦN 5: INDEX & VIEW
-- Câu 1: Tạo một chỉ mục trên bảng enrollments dựa trên hai thông tin là trạng thái học và số tín chỉ nhằm phục cụ việc tối ưu truy vấn
CREATE INDEX idx_enrollments ON enrollments(status,credits);

-- Câu 2: Tạo một khung nhìn dữ liệu hiển thị họ tên sinh viên, tổng số môn học đã đăng ký và tổng số tín chỉ mà sinh viên đó đã tích lũy trong đó không tính các môn bị hủy
DROP VIEW IF EXISTS vw_info_course_of_student;
CREATE VIEW vw_info_course_of_student AS
SELECT s.full_name,COUNT(e.student_id) AS total_course,SUM(credits) AS total_credits
FROM enrollments e
JOIN students s ON e.student_id = s.student_id 
GROUP BY e.student_id;

SELECT * FROM vw_info_course_of_student;

-- PHẦN 6: TRIGGER
-- Câu 1: Viết một trigger sao cho khi trạng thái của một bản ghi đăng ký enrollments 
-- được cập nhật sang giá trị Completed thì hệ thống tự động thêm 1 bản ghi mới vào academic_log với các thông tin sau

DELIMITER //
CREATE TRIGGER trg_add_row 
AFTER UPDATE ON enrollments
FOR EACH ROW

BEGIN 
IF status = 'Completed' THEN 
INSERT VALUES 
END;
DELIMITER ;

-- PHẦN 7: STORED PROCEDURE 
