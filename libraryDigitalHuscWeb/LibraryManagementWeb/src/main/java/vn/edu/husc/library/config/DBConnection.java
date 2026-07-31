package vn.edu.husc.library.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";

    private static final String URL =
            "jdbc:sqlserver://localhost:1433;"
            + "databaseName=ElectronicLibraryDB;"
            + "encrypt=true;"
            + "trustServerCertificate=true;";

    private static final String USERNAME = "sa";
    private static final String PASSWORD = "123456";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DRIVER);
            return DriverManager.getConnection(URL, USERNAME, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Không tìm thấy SQL Server JDBC Driver!", e);
        }
    }
}