<%-- 
    Document   : login
    Created on : Jul 2, 2026, 10:42:02 AM
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
    <center><h1 style="color: red">Đăng Nhập</h1></center>
    <form action="check" method="POST">
        <center>
        <table>
            <tr>
                <td colspan="2" style="padding-bottom: 0;">
                    <div style="margin-bottom: 8px">Username of email</div>
                    <input type="text" name="num1" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Enter your user name or email">
                </td>
            </tr>
            <br>
            <tr>
                <td colspan="2" style="padding-bottom: 0;">
                    <div style="margin-bottom: 8px">Password</div>
                    <input type="text" name="num2" style="width: 100%; padding: 8px;border-radius: 5px; font-size: 16px; box-sizing: border-box" placeholder="Enter your password">
                </td>
            </tr>
            <tr>
                <td colspan="2">
                    <h3>Bạn chưa có tài khoản ? <a href="register.jsp"> Đăng kí tại đây</a></h3>
                    <h3>Quên mật khẩu ? <a href="register.jsp">Nhấn vào đây</a></h3>
                </td>
            </tr>
            <tr>
                <td colspan="2" style="text-align: center;">
                    <input type="submit" value="Submit" style="width: 100%; background-color: red;border-radius: 8px; border: none; padding: 10px; color: #ffffff">
                </td>
            </tr>
        </table>
        </center>
    </form>
    </body>
</html>
