/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author Dumpling
 */
public class OrderDetailTopping {
    private int orderDetailId;
    private int toppingId;
    private double toppingPrice;

    public OrderDetailTopping() {}

    public int getOrderDetailId() { return orderDetailId; }
    public void setOrderDetailId(int orderDetailId) { this.orderDetailId = orderDetailId; }

    public int getToppingId() { return toppingId; }
    public void setToppingId(int toppingId) { this.toppingId = toppingId; }

    public double getToppingPrice() { return toppingPrice; }
    public void setToppingPrice(double toppingPrice) { this.toppingPrice = toppingPrice; }
}
