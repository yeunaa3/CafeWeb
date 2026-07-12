/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author Dumpling
 */
public class MenuSection {
    private Category category;
    private List<Product> products;

    public MenuSection() {
        this.products = new ArrayList<Product>();
    }

    public MenuSection(Category category) {
        this.category = category;
        this.products = new ArrayList<Product>();
    }

    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }

    public List<Product> getProducts() { return products; }
    public void setProducts(List<Product> products) { this.products = products; }
}
