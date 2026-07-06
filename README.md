# CafeWeb - Hướng dẫn cài đặt cho thành viên nhóm

## 1. Công nghệ thống nhất

Tất cả thành viên sử dụng cùng phiên bản:

- JDK 17
- NetBeans 17 hoặc mới hơn
- Apache Tomcat 10.1.x
- Microsoft SQL Server
- Database `CBMS`

Project sử dụng package `jakarta.servlet`, vì vậy phải chạy bằng Tomcat 10. Không dùng Tomcat 9 vì Tomcat 9 sử dụng package `javax.servlet`.

## 2. Thư viện của project

Bốn thư viện cần thiết đã nằm trong thư mục `lib/`:

- `jakarta.servlet.jsp.jstl-2.0.0.jar`
- `jakarta.servlet.jsp.jstl-api-2.0.0.jar`
- `jaxb-api-2.1.jar`
- `sqljdbc42.jar`

`nbproject/project.properties` tham chiếu bằng đường dẫn tương đối `lib/...`. Không dùng chức năng Add JAR để thêm lại thư viện từ `C:\Users\...`, vì NetBeans sẽ lưu đường dẫn riêng của máy và làm máy khác bị lỗi.

Servlet API không nằm trong bốn JAR trên. NetBeans lấy Servlet API từ Tomcat 10.1 đã gắn với project.

## 3. Mở project lần đầu

1. Clone hoặc pull project từ Git.
2. Mở NetBeans, chọn **File > Open Project** và chọn thư mục `CafeWeb`.
3. Vào **Tools > Java Platforms**, kiểm tra đã có JDK 17.
4. Nhấp phải project, chọn **Properties > Libraries** và chọn Java Platform là JDK 17.
5. Mở tab **Services > Servers**.
6. Nếu chưa có Tomcat, chọn **Add Server > Apache Tomcat or TomEE**, sau đó chọn thư mục Tomcat 10.1 trên máy.
7. Vào **Project Properties > Run**, chọn Tomcat 10.1 vừa thêm.
8. Stop Tomcat nếu server đang chạy, sau đó chọn **Clean and Build**.
9. Run project.

Mỗi máy chỉ cần cấu hình JDK và Tomcat một lần.

## 4. Cấu hình database

Project dùng duy nhất file:

`web/WEB-INF/ConnectDB.properties`

Nội dung mặc định:

```properties
url=jdbc:sqlserver://localhost:1433;databaseName=CBMS;trustServerCertificate=true
userID=sa
password=123456
```

Nếu tài khoản SQL Server trên máy khác, thành viên đó sửa `userID` và `password` cho phù hợp.

Có thể giữ nguyên file chung và đặt các biến môi trường riêng trên từng máy:

- `CBMS_DB_URL`
- `CBMS_DB_USER`
- `CBMS_DB_PASSWORD`

Giá trị từ biến môi trường sẽ được ưu tiên hơn giá trị trong file properties.

Nếu database đã được tạo từ phiên bản cũ, mở SSMS và chạy lần lượt:

1. `database/migrations/001_add_user_gender.sql`
2. `database/migrations/002_task7_manager.sql`

Database tạo mới bằng `CBMS.sql` đã có sẵn các cột này. Tài khoản Manager mẫu là `admin01` / `123456`.

`DBContext` đọc file bằng:

```java
getResourceAsStream("../ConnectDB.properties")
```

Khi chạy, classpath root là `WEB-INF/classes`; `../ConnectDB.properties` trỏ tới `WEB-INF/ConnectDB.properties`. Không tạo thêm file cùng tên trong `src/conf`.

## 5. Các thư mục được NetBeans tự sinh

- `build/`: chứa file `.class` và web đang được deploy tạm thời.
- `dist/`: chứa file `CafeWeb.war` sau khi build.
- `nbproject/private/`: chứa đường dẫn JDK, Tomcat và cấu hình riêng của từng máy.

Ba thư mục trên đã được `.gitignore`. Không dùng `git add -f` và không commit chúng.

Phân biệt `build/` với `build.xml`:

- `build/` là thư mục kết quả tạm, chỉ xuất hiện sau khi Build hoặc Run và có thể xóa.
- `build.xml` là file Ant đầu vào của project NetBeans. File này phải giữ trong Git; NetBeans dùng nó để gọi các tác vụ trong `nbproject/build-impl.xml`.

Nếu Windows báo không xóa được JAR khi Clean and Build, hãy Stop Tomcat trước vì server đang khóa file trong `build/web/WEB-INF/lib`.

## 6. Xử lý các lỗi thường gặp

### Toàn bộ `jakarta.servlet.*` bị đỏ

1. Kiểm tra đang dùng Tomcat 10.1, không phải Tomcat 9.
2. Vào **Project Properties > Run** và chọn lại Tomcat.
3. Vào **Project Properties > Libraries** và chọn JDK 17.
4. Close Project rồi Open Project lại.
5. Stop Tomcat và chạy Clean and Build.

### Libraries báo Broken Reference

Kiểm tra thư mục `lib/` có đủ bốn JAR. Không trỏ lại tới thư mục `allowedlib` trên Desktop. Sau khi pull, đóng và mở lại project để NetBeans reload `project.properties`.

### `ClassNotFoundException: com.microsoft.sqlserver.jdbc.SQLServerDriver`

Kiểm tra `lib/sqljdbc42.jar` tồn tại, sau đó Stop Tomcat và Clean and Build. Trong WAR phải có `WEB-INF/lib/sqljdbc42.jar`.

### Không tìm thấy `ConnectDB.properties`

Kiểm tra file nằm đúng tại `web/WEB-INF/ConnectDB.properties` và `DBContext` đang dùng đường dẫn `../ConnectDB.properties`.

### Không kết nối được SQL Server

Kiểm tra SQL Server đang chạy, TCP/IP đã bật, port `1433` mở, database `CBMS` đã được tạo và tài khoản trong `ConnectDB.properties` chính xác.

## 7. Quy tắc khi commit và pull

Trước khi commit, chạy:

```powershell
git status
```

Không commit:

- `build/`
- `dist/`
- `nbproject/private/`
- Các đường dẫn chứa `C:\Users\<tên-máy>`

Sau khi pull thay đổi liên quan đến thư viện hoặc cấu hình NetBeans:

1. Stop Tomcat.
2. Close và Open lại project.
3. Clean and Build.
4. Run project.

## 8. Build thành công

Sau khi Clean and Build, file deploy nằm tại:

`dist/CafeWeb.war`

URL mặc định:

`http://localhost:8080/CafeWeb/`

## 9. HTTP 500: `con is null` hoặc không kết nối được database

Lỗi này xảy ra khi SQL Server từ chối kết nối trước khi DAO chạy câu SQL. Không chỉ kiểm tra username/password; trên máy mới cần kiểm tra lần lượt:

1. Mở **SQL Server Configuration Manager**, bảo đảm service của instance đang ở trạng thái `Running`.
2. Trong **SQL Server Network Configuration**, bật `TCP/IP`, đặt TCP Port là `1433`, rồi restart SQL Server service.
3. Bật chế độ **SQL Server and Windows Authentication mode**; bảo đảm login `sa` được enable.
4. Dùng chính tài khoản trong `ConnectDB.properties` đăng nhập thử bằng SSMS với server `localhost,1433`.
5. Kiểm tra database `CBMS` đã tồn tại và đã chạy `CBMS.sql` hoặc các migration cần thiết.
6. Kiểm tra `web/WEB-INF/ConnectDB.properties` có đúng URL, user và password của máy đó.
7. Trong Command Prompt chạy `set CBMS_DB` hoặc PowerShell chạy `Get-ChildItem Env:CBMS_DB*`. Xóa/sửa biến cũ vì các biến này được ưu tiên hơn file properties.
8. Stop Tomcat, chạy **Clean and Build**, rồi Run lại để WAR mới chứa properties và JDBC driver.

URL chuẩn khi SQL Server chạy cổng cố định:

```properties
url=jdbc:sqlserver://localhost:1433;databaseName=CBMS;encrypt=true;trustServerCertificate=true
userID=sa
password=mat_khau_cua_may_do
```

Nếu dùng instance `SQLEXPRESS` với cổng động, nên cấu hình instance dùng cổng cố định `1433`. Chỉ sửa username/password trong khi SQL Server thực tế đang chạy ở instance hoặc port khác vẫn sẽ kết nối thất bại.

`DBContext` không trả về `null` khi kết nối lỗi. Hãy đọc dòng `Caused by:` trong Tomcat Output/log để biết nguyên nhân gốc:

- `Login failed for user`: sai tài khoản/mật khẩu, login bị khóa hoặc chưa bật SQL Authentication.
- `The TCP/IP connection ... has failed`: SQL Server chưa chạy, TCP/IP chưa bật, sai port hoặc firewall chặn.
- `Cannot open database "CBMS"`: database chưa được tạo hoặc login chưa có quyền.
- `ClassNotFoundException ... SQLServerDriver`: `sqljdbc42.jar` chưa được đóng vào WAR.
