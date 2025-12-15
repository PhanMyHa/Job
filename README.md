# Ứng Dụng Tìm Việc Làm (Job Finder App)

**Job Finder App** là ứng dụng hỗ trợ người tìm việc dễ dàng tìm kiếm và ứng tuyển các công việc phù hợp, đồng thời cho phép nhà tuyển dụng / admin quản lý tin tuyển dụng.
Hệ thống được xây dựng với **Flutter** cho ứng dụng mobile và **Node.js (Express)** cho backend API.

---

## Chức năng chính

### Người dùng (Ứng viên)

* Đăng ký, đăng nhập tài khoản
* Xem danh sách việc làm
* Tìm kiếm và lọc việc làm theo tên công việc, địa điểm, công ty
* Xem chi tiết việc làm
* Ứng tuyển việc làm
* Quản lý thông tin cá nhân

### Admin / Nhà tuyển dụng

* Đăng nhập admin
* Thêm, sửa, xóa tin tuyển dụng
* Quản lý danh mục việc làm
* Xem danh sách ứng viên ứng tuyển

---

## Công nghệ sử dụng

### Frontend (Ứng dụng Mobile)

* **Flutter**
* Dart
* Kết nối REST API

### Backend (Server)

* **Node.js**
* **Express.js**
* RESTful API
* Xác thực bằng JWT

### Cơ sở dữ liệu

* **MongoDB** *

### Công cụ khác

* Postman 
* Git & GitHub



## Cài đặt & Chạy dự án

### 1. Clone repository


git clone
cd job-app


### 2. Chạy Backend

cd backend
npm install
npm run dev


Tạo file `.env` trong thư mục `backend`:

PORT=5000
MONGO_URI=your_database_url
JWT_SECRET=your_secret_key


### 3. Chạy Frontend

cd frontend
flutter pub get
flutter run



## Tổng quan API

| Method | Endpoint           | Mô tả                     |
| ------ | ------------------ | ------------------------- |
| POST   | /api/auth/register | Đăng ký tài khoản         |
| POST   | /api/auth/login    | Đăng nhập                 |
| GET    | /api/jobs          | Lấy danh sách việc làm    |
| GET    | /api/jobs/:id      | Xem chi tiết việc làm     |
| POST   | /api/jobs          | Tạo việc làm (Admin)      |
| PUT    | /api/jobs/:id      | Cập nhật việc làm (Admin) |
| DELETE | /api/jobs/:id      | Xóa việc làm (Admin)      |

