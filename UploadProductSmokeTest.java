import java.io.IOException;
import java.net.CookieManager;
import java.net.CookiePolicy;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class UploadProductSmokeTest {
    private static final String BASE = "http://localhost:8080/CafeWeb";
    private static final String DB_URL = "jdbc:sqlserver://localhost:1433;databaseName=CBMS;encrypt=false;trustServerCertificate=true";

    public static void main(String[] args) throws Exception {
        CookieManager cookies = new CookieManager(null, CookiePolicy.ACCEPT_ALL);
        HttpClient client = HttpClient.newBuilder().cookieHandler(cookies).followRedirects(HttpClient.Redirect.NORMAL).build();

        HttpRequest login = HttpRequest.newBuilder(URI.create(BASE + "/login"))
                .header("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8")
                .POST(HttpRequest.BodyPublishers.ofString("usernameOrEmail=admin01&password=123456"))
                .build();
        client.send(login, HttpResponse.BodyHandlers.ofString());

        String productName = "Smoke Upload " + System.currentTimeMillis();
        HttpRequest upload = multipartRequest(productName);
        HttpResponse<String> response = client.send(upload, HttpResponse.BodyHandlers.ofString());
        if (response.statusCode() >= 400) {
            throw new IllegalStateException("Upload failed: HTTP " + response.statusCode());
        }

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        try (Connection connection = DriverManager.getConnection(DB_URL, "sa", "123456");
             PreparedStatement select = connection.prepareStatement(
                     "SELECT product_id, image_url FROM Products WHERE product_name = ?")) {
            select.setString(1, productName);
            try (ResultSet rs = select.executeQuery()) {
                if (!rs.next()) {
                    throw new IllegalStateException("Product was not created.");
                }
                int productId = rs.getInt("product_id");
                String imageUrl = rs.getString("image_url");
                System.out.println("productId=" + productId);
                System.out.println("imageUrl=" + imageUrl);
                if (imageUrl == null || !imageUrl.startsWith("uploads/products/product-")) {
                    throw new IllegalStateException("Uploaded image URL was not saved.");
                }
                cleanup(connection, productId, imageUrl);
            }
        }
    }

    private static HttpRequest multipartRequest(String productName) throws IOException {
        String boundary = "----CodexBoundary" + UUID.randomUUID();
        List<byte[]> parts = new ArrayList<byte[]>();
        addField(parts, boundary, "action", "create");
        addField(parts, boundary, "id", "");
        addField(parts, boundary, "currentImageUrl", "");
        addField(parts, boundary, "productName", productName);
        addField(parts, boundary, "categoryId", "1");
        addField(parts, boundary, "price", "1000");
        addField(parts, boundary, "description", "smoke test");
        addField(parts, boundary, "status", "on");
        addFile(parts, boundary, "productImage", "payment-qr.jpg", Files.readAllBytes(Path.of("web/assets/images/payment-qr.jpg")));
        parts.add(("--" + boundary + "--\r\n").getBytes(StandardCharsets.UTF_8));

        return HttpRequest.newBuilder(URI.create(BASE + "/manager/products"))
                .header("Content-Type", "multipart/form-data; boundary=" + boundary)
                .POST(HttpRequest.BodyPublishers.ofByteArrays(parts))
                .build();
    }

    private static void addField(List<byte[]> parts, String boundary, String name, String value) {
        parts.add(("--" + boundary + "\r\nContent-Disposition: form-data; name=\"" + name + "\"\r\n\r\n"
                + value + "\r\n").getBytes(StandardCharsets.UTF_8));
    }

    private static void addFile(List<byte[]> parts, String boundary, String name, String fileName, byte[] content) {
        parts.add(("--" + boundary + "\r\nContent-Disposition: form-data; name=\"" + name
                + "\"; filename=\"" + fileName + "\"\r\nContent-Type: image/jpeg\r\n\r\n").getBytes(StandardCharsets.UTF_8));
        parts.add(content);
        parts.add("\r\n".getBytes(StandardCharsets.UTF_8));
    }

    private static void cleanup(Connection connection, int productId, String imageUrl) throws Exception {
        try (PreparedStatement delete = connection.prepareStatement("DELETE FROM Products WHERE product_id = ?")) {
            delete.setInt(1, productId);
            delete.executeUpdate();
        }
        Files.deleteIfExists(Path.of("build/web", imageUrl));
    }
}
