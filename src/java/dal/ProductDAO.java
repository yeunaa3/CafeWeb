package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.Category;
import model.MenuSection;
import model.Product;
import model.Topping;

public class ProductDAO extends DBContext {

    public List<Product> getRecommendedProducts(int limit) {
        List<Product> products = new ArrayList<Product>();
        String sql = "SELECT TOP (?) product_id, product_name, category_id, price, image_url, description, status, created_at "
                + "FROM Products WHERE status = 1 ORDER BY product_id";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                products.add(mapProduct(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return products;
    }

    public List<MenuSection> getMenuSections(String keyword) {
        Map<Integer, MenuSection> sections = new LinkedHashMap<Integer, MenuSection>();
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sql = "SELECT c.category_id, c.category_name, c.description AS category_description, c.status AS category_status, "
                + "p.product_id, p.product_name, p.price, p.image_url, p.description AS product_description, "
                + "p.status AS product_status, p.created_at "
                + "FROM Categories c "
                + "LEFT JOIN Products p ON c.category_id = p.category_id AND p.status = 1 "
                + "WHERE c.status = 1 "
                + (keyword != null && !keyword.trim().isEmpty() ? "AND p.product_name LIKE ? " : "")
                + "ORDER BY c.category_id, p.product_id";
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(1, "%" + keyword.trim() + "%");
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                int categoryId = rs.getInt("category_id");
                MenuSection section = sections.get(categoryId);
                if (section == null) {
                    Category category = new Category();
                    category.setCategoryId(categoryId);
                    category.setCategoryName(rs.getString("category_name"));
                    category.setDescription(rs.getString("category_description"));
                    category.setStatus(rs.getBoolean("category_status"));
                    section = new MenuSection(category);
                    sections.put(categoryId, section);
                }
                int productId = rs.getInt("product_id");
                if (!rs.wasNull()) {
                    Product product = new Product();
                    product.setProductId(productId);
                    product.setProductName(rs.getString("product_name"));
                    product.setCategoryId(categoryId);
                    product.setPrice(rs.getDouble("price"));
                    product.setImageUrl(rs.getString("image_url"));
                    product.setDescription(rs.getString("product_description"));
                    product.setStatus(rs.getBoolean("product_status"));
                    product.setCreatedAt(rs.getTimestamp("created_at"));
                    section.getProducts().add(product);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return new ArrayList<MenuSection>(sections.values());
    }

    public Product getProductById(int productId) {
        String sql = "SELECT product_id, product_name, category_id, price, image_url, description, status, created_at "
                + "FROM Products WHERE product_id = ? AND status = 1";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapProduct(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return null;
    }

    public List<Topping> getActiveToppings() {
        List<Topping> toppings = new ArrayList<Topping>();
        String sql = "SELECT topping_id, topping_name, price, status FROM Toppings WHERE status = 1 ORDER BY topping_id";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                toppings.add(mapTopping(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return toppings;
    }

    public List<Topping> getToppingsByIds(String[] toppingIds) {
        List<Topping> selected = new ArrayList<Topping>();
        if (toppingIds == null || toppingIds.length == 0) {
            return selected;
        }
        for (String toppingId : toppingIds) {
            Topping topping = getToppingById(parseInt(toppingId));
            if (topping != null) {
                selected.add(topping);
            }
        }
        return selected;
    }

    private Topping getToppingById(int toppingId) {
        String sql = "SELECT topping_id, topping_name, price, status FROM Toppings WHERE topping_id = ? AND status = 1";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, toppingId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapTopping(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return null;
    }

    private Product mapProduct(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setProductName(rs.getString("product_name"));
        product.setCategoryId(rs.getInt("category_id"));
        product.setPrice(rs.getDouble("price"));
        product.setImageUrl(rs.getString("image_url"));
        product.setDescription(rs.getString("description"));
        product.setStatus(rs.getBoolean("status"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        return product;
    }

    private Topping mapTopping(ResultSet rs) throws SQLException {
        Topping topping = new Topping();
        topping.setToppingId(rs.getInt("topping_id"));
        topping.setToppingName(rs.getString("topping_name"));
        topping.setPrice(rs.getDouble("price"));
        topping.setStatus(rs.getBoolean("status"));
        return topping;
    }

    private int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return -1;
        }
    }

    public List<Category> getAllCategories() {
        List<Category> categories = new ArrayList<Category>();
        String sql = "SELECT category_id, category_name, description, status FROM Categories ORDER BY category_name";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                Category category = new Category();
                category.setCategoryId(rs.getInt("category_id"));
                category.setCategoryName(rs.getString("category_name"));
                category.setDescription(rs.getString("description"));
                category.setStatus(rs.getBoolean("status"));
                categories.add(category);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return categories;
    }

    public List<Product> getAdminProducts(String keyword) {
        List<Product> products = new ArrayList<Product>();
        String search = keyword == null ? "" : keyword.trim();
        String sql = "SELECT p.product_id,p.product_name,p.category_id,c.category_name,p.price,p.image_url,"
                + "p.description,p.status,p.created_at FROM Products p JOIN Categories c ON c.category_id=p.category_id "
                + "WHERE (?='' OR p.product_name LIKE ? OR c.category_name LIKE ?) ORDER BY p.product_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, search);
            ps.setString(2, "%" + search + "%");
            ps.setString(3, "%" + search + "%");
            rs = ps.executeQuery();
            while (rs.next()) products.add(mapAdminProduct(rs));
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return products;
    }

    public Product getProductForAdmin(int productId) {
        String sql = "SELECT p.product_id,p.product_name,p.category_id,c.category_name,p.price,p.image_url,"
                + "p.description,p.status,p.created_at FROM Products p JOIN Categories c ON c.category_id=p.category_id "
                + "WHERE p.product_id=?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            return rs.next() ? mapAdminProduct(rs) : null;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return null;
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    public boolean createProduct(Product product) {
        String sql = "INSERT INTO Products(product_name,category_id,price,image_url,description,status) VALUES(?,?,?,?,?,?)";
        return saveProduct(sql, product, false);
    }

    public boolean updateProduct(Product product) {
        String sql = "UPDATE Products SET product_name=?,category_id=?,price=?,image_url=?,description=?,status=?,updated_at=SYSDATETIME() WHERE product_id=?";
        return saveProduct(sql, product, true);
    }

    private boolean saveProduct(String sql, Product product, boolean editing) {
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, product.getProductName());
            ps.setInt(2, product.getCategoryId());
            ps.setDouble(3, product.getPrice());
            ps.setString(4, product.getImageUrl());
            ps.setString(5, product.getDescription());
            ps.setBoolean(6, product.isStatus());
            if (editing) ps.setInt(7, product.getProductId());
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public boolean setProductStatus(int productId, boolean active) {
        String sql = "UPDATE Products SET status=?,updated_at=SYSDATETIME() WHERE product_id=?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setInt(2, productId);
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM Products WHERE product_id=? "
                + "AND NOT EXISTS(SELECT 1 FROM OrderDetails WHERE product_id=?) "
                + "AND NOT EXISTS(SELECT 1 FROM ComboItems WHERE product_id=?)";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            ps.setInt(2, productId);
            ps.setInt(3, productId);
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    private Product mapAdminProduct(ResultSet rs) throws SQLException {
        Product product = mapProduct(rs);
        product.setCategoryName(rs.getString("category_name"));
        return product;
    }
}
