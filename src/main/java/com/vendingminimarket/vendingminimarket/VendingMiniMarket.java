/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

package com.vendingminimarket.vendingminimarket;

import com.vendingminimarket.vista.Login;
import com.vendingminimarket.vista.GestionProductos;
import javax.swing.SwingUtilities;

public class VendingMiniMarket {
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> {
            new GestionProductos().setVisible(true);
        });
    }
}