/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Dumpling
 */
public class Topping {
    private int toppingId;
    private String toppingName;
    private double price;
    private boolean status;

    public Topping() {}

    public int getToppingId() { return toppingId; }
    public void setToppingId(int toppingId) { this.toppingId = toppingId; }

    public String getToppingName() { return toppingName; }
    public void setToppingName(String toppingName) { this.toppingName = toppingName; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public boolean isStatus() { return status; }
    public void setStatus(boolean status) { this.status = status; }
}