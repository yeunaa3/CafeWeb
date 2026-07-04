<%-- 
    Document   : register
    Created on : Jul 2, 2026, 6:06:04 PM
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
    <center><h1 style="color: red">Đăng Kí</h1></center>
    <form action="check" method="POST">
        <center>
            <table style="width: 400px">
            <tr>
                <td colspan="2" style="padding-bottom: 0;">
                    <div style="margin-bottom: 8px">Họ và Tên</div>
                    <input type="text" name="num3" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Nguyễn Văn A">
                </td>
            </tr>
            <tr>
                <td colspan="2" style="padding-bottom: 0;">
                    <div style="margin-bottom: 8px">Tên Đăng Nhập</div>
                    <input type="text" name="num3" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Nhập tên của bạn">
                </td>
            </tr>
            <tr>
                <td colspan="2" style="padding-bottom: 0;">
                    <div style="margin-bottom: 8px">Địa chỉ email</div>
                    <input type="text" name="num3" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Ngocdai0411@gmail.com">
                </td>
            </tr>
            <tr>
                <td colspan="2" style="padding-bottom: 0;">
                    <div style="margin-bottom: 8px">Số điện thoại</div>
                    <input type="text" name="num3" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Nhập số điện thoại của bạn">
                </td>
            </tr>
            <tr>
                <td colspan="2" style="padding-bottom: 15px;">
                    <div style="margin-bottom: 8px">Mật khẩu</div>
                    <input type="text" name="num3" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Nhập mật khẩu của bạn">
                </td>
            </tr>
            <tr>
                <td colspan="2" style="text-align: center;">
                    <input type="submit" value="Đăng kí" style="width: 100%; background-color: red;border-radius: 8px; border: none; padding: 10px; color: #ffffff">
                </td>
            </tr>
        </table>
        </center>
    </form>
    </body>
</html>
