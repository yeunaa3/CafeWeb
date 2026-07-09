package model;

import java.util.ArrayList;
import java.util.List;

public class DashboardSummary {
    private int activeProductCount;
    private int todayOrderCount;
    private double todayRevenue;
    private double totalRevenue;
    private int customerCount;
    private List<RevenueStat> revenueStats = new ArrayList<RevenueStat>();
    private List<ProductSalesStat> topProducts = new ArrayList<ProductSalesStat>();
    private List<ManagerOrderSummary> recentOrders = new ArrayList<ManagerOrderSummary>();

    public int getActiveProductCount() { return activeProductCount; }
    public void setActiveProductCount(int activeProductCount) { this.activeProductCount = activeProductCount; }
    public int getTodayOrderCount() { return todayOrderCount; }
    public void setTodayOrderCount(int todayOrderCount) { this.todayOrderCount = todayOrderCount; }
    public double getTodayRevenue() { return todayRevenue; }
    public void setTodayRevenue(double todayRevenue) { this.todayRevenue = todayRevenue; }
    public double getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(double totalRevenue) { this.totalRevenue = totalRevenue; }
    public int getCustomerCount() { return customerCount; }
    public void setCustomerCount(int customerCount) { this.customerCount = customerCount; }
    public List<RevenueStat> getRevenueStats() { return revenueStats; }
    public void setRevenueStats(List<RevenueStat> revenueStats) { this.revenueStats = revenueStats; }
    public List<ProductSalesStat> getTopProducts() { return topProducts; }
    public void setTopProducts(List<ProductSalesStat> topProducts) { this.topProducts = topProducts; }
    public List<ManagerOrderSummary> getRecentOrders() { return recentOrders; }
    public void setRecentOrders(List<ManagerOrderSummary> recentOrders) { this.recentOrders = recentOrders; }
}
