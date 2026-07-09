package model;

import java.sql.Date;

public class RevenueStat {
    private Date revenueDate;
    private int orderCount;
    private double revenue;
    private double percentage;

    public RevenueStat() {}

    public Date getRevenueDate() { return revenueDate; }
    public void setRevenueDate(Date revenueDate) { this.revenueDate = revenueDate; }
    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    public double getRevenue() { return revenue; }
    public void setRevenue(double revenue) { this.revenue = revenue; }
    public double getPercentage() { return percentage; }
    public void setPercentage(double percentage) { this.percentage = percentage; }
}
