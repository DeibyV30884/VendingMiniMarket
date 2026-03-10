package com.vendingminimarket.conexion;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionDB {
    
// En Mac con Docker:
    private static final String URL = "jdbc:oracle:thin:@//localhost:1531/XEPDB1";

// En Windows con Oracle instalado directo:
    //private static final String URL = "jdbc:oracle:thin:@localhost:1521:ORCL";

    private static final String USUARIO = "VENDING_USER";
    private static final String PASSWORD = "Vending2026$";

    private static Connection conexion = null;

    public static Connection getConexion() {
        try {
            if (conexion == null || conexion.isClosed()) {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                conexion = DriverManager.getConnection(URL, USUARIO, PASSWORD);
                System.out.println("Conexion exitosa a Oracle");
            }
        } catch (Exception e) {
            System.err.println("Error de conexion: " + e.getMessage());
        }
        return conexion;
    }
}