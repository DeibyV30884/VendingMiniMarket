/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/GUIForms/JFrame.java to edit this template
 */
package com.vendingminimarket.vista;

import com.vendingminimarket.conexion.ConexionDB;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.table.DefaultTableModel;

/**
 *
 * @author deiby
 */
public class GestionMaquinas extends javax.swing.JFrame {

    private static final java.util.logging.Logger logger = java.util.logging.Logger.getLogger(GestionMaquinas.class.getName());

    private String nombre;
    private String rol;
    private int idUsuario;

    /**
     * Creates new form GestionMaquinas
     */
    public GestionMaquinas(String nombre, String rol, int idUsuario) {
        this.nombre = nombre;
        this.rol = rol;
        this.idUsuario = idUsuario;
        initComponents();
        configurarTablaInventario();
        configurarPermisos();
        cargarMaquinas();
    }

    // Solo ADMIN puede crear máquinas y asignar productos
    private void configurarPermisos() {
        boolean esAdmin = rol.equalsIgnoreCase("Administrador");
        NuevaMaquina.setVisible(esAdmin);
        jbAsignarProducto.setVisible(esAdmin);
    }

    // Carga el combo con las máquinas activas
    private void cargarMaquinas() {
        try {
            CallableStatement cs = ConexionDB.getConexion()
                    .prepareCall("{? = CALL FN_LISTAR_MAQUINAS()}");
            cs.registerOutParameter(1, oracle.jdbc.OracleTypes.CURSOR);
            cs.execute();

            ResultSet rs = (ResultSet) cs.getObject(1);
            jcbSeleccionarMaquina.removeAllItems();
            while (rs.next()) {
                // Guardamos "ID - CODIGO" igual que hace NuevoPedido con proveedores
                jcbSeleccionarMaquina.addItem(
                        rs.getInt("ID_MAQUINA") + " - " + rs.getString("CODIGO_MAQUINA"));
            }
            rs.close();
            cs.close();

            // Cargar inventario de la primera máquina automáticamente
            cargarInventarioMaquina();

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Error cargando máquinas: " + e.getMessage());
        }
    }

    // Obtiene el ID de la máquina seleccionada en el combo
    private int getIdMaquinaSeleccionada() {
        String item = (String) jcbSeleccionarMaquina.getSelectedItem();
        if (item == null) {
            return -1;
        }
        return Integer.parseInt(item.split(" - ")[0]);
    }

    // Carga la tabla de inventario según la máquina del combo
    private void cargarInventarioMaquina() {
        int idMaquina = getIdMaquinaSeleccionada();
        if (idMaquina == -1) {
            return;
        }

        try {
            CallableStatement cs = ConexionDB.getConexion()
                    .prepareCall("{? = CALL FN_INVENTARIO_MAQUINA(?)}");
            cs.registerOutParameter(1, oracle.jdbc.OracleTypes.CURSOR);
            cs.setInt(2, idMaquina);
            cs.execute();

            ResultSet rs = (ResultSet) cs.getObject(1);
            DefaultTableModel modelo = (DefaultTableModel) jTableInventarioMaquina.getModel();
            modelo.setRowCount(0);

            DefaultTableModel modeloAlertas = (DefaultTableModel) jTableAlertas.getModel();
            modeloAlertas.setRowCount(0);

            while (rs.next()) {
                String estado = rs.getString("ESTADO");
                modelo.addRow(new Object[]{
                    rs.getString("NOMBRE"),
                    "₡" + rs.getDouble("PRECIO_VENTA"),
                    rs.getInt("STOCK_ACTUAL"),
                    rs.getInt("STOCK_MINIMO"),
                    estado,
                    false, // checkbox Seleccionar
                    rs.getInt("ID_PRODUCTO") // ID oculto en columna 6
                });

                // Si el stock está bajo o crítico, agregar a alertas
                if (!estado.equals("Bien")) {
                    modeloAlertas.addRow(new Object[]{
                        rs.getString("NOMBRE") + " — Stock: "
                        + rs.getInt("STOCK_ACTUAL")
                        + " (Mínimo: " + rs.getInt("STOCK_MINIMO") + ") — " + estado
                    });
                }
            }
            rs.close();
            cs.close();

        } catch (SQLException e) {
            JOptionPane.showMessageDialog(this,
                    "Error cargando inventario: " + e.getMessage());
        }
    }

    // Configura la tabla para que la columna ID_PRODUCTO quede oculta
    private void configurarTablaInventario() {
        jTableInventarioMaquina.setModel(new DefaultTableModel(
                new Object[][]{},
                new String[]{"Producto", "Precio", "Stock", "Minimo", "Estado", "Seleccionar", "ID_PRODUCTO"}
        ) {
            Class[] types = {String.class, String.class, Integer.class,
                Integer.class, String.class, Boolean.class, Integer.class};

            public Class getColumnClass(int col) {
                return types[col];
            }

            public boolean isCellEditable(int row, int col) {
                return col == 5;
            }
        });

        // Ocultar columna ID_PRODUCTO (índice 6)
        jTableInventarioMaquina.getColumnModel().getColumn(6).setMinWidth(0);
        jTableInventarioMaquina.getColumnModel().getColumn(6).setMaxWidth(0);
        jTableInventarioMaquina.getColumnModel().getColumn(6).setWidth(0);

        // Configurar tabla de alertas
        jTableAlertas.setModel(new DefaultTableModel(
                new Object[][]{},
                new String[]{"Alerta"}
        ) {
            public boolean isCellEditable(int row, int col) {
                return false;
            }
        });
    }

    private int getProductoSeleccionado() {
        DefaultTableModel modelo = (DefaultTableModel) jTableInventarioMaquina.getModel();
        for (int i = 0; i < modelo.getRowCount(); i++) {
            if (Boolean.TRUE.equals(modelo.getValueAt(i, 5))) {
                return (int) modelo.getValueAt(i, 6); // ID está en columna 6
            }
        }
        return -1;
    }

    /**
     * This method is called from within the constructor to initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is always
     * regenerated by the Form Editor.
     */
    @SuppressWarnings("unchecked")
    // <editor-fold defaultstate="collapsed" desc="Generated Code">//GEN-BEGIN:initComponents
    private void initComponents() {

        jScrollPane1 = new javax.swing.JScrollPane();
        jTable1 = new javax.swing.JTable();
        jPanel1 = new javax.swing.JPanel();
        jPanel2 = new javax.swing.JPanel();
        jLabel1 = new javax.swing.JLabel();
        btnVolver2 = new javax.swing.JButton();
        jLabel2 = new javax.swing.JLabel();
        jbAsignarProducto = new javax.swing.JButton();
        NuevaMaquina = new javax.swing.JButton();
        jLabel3 = new javax.swing.JLabel();
        jLabel4 = new javax.swing.JLabel();
        jcbSeleccionarMaquina = new javax.swing.JComboBox<>();
        jScrollPane3 = new javax.swing.JScrollPane();
        jTableAlertas = new javax.swing.JTable();
        jScrollPane4 = new javax.swing.JScrollPane();
        jTableInventarioMaquina = new javax.swing.JTable();
        jbRecargar = new javax.swing.JButton();

        jTable1.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null},
                {null, null, null, null},
                {null, null, null, null},
                {null, null, null, null}
            },
            new String [] {
                "Title 1", "Title 2", "Title 3", "Title 4"
            }
        ));
        jScrollPane1.setViewportView(jTable1);

        setDefaultCloseOperation(javax.swing.WindowConstants.DISPOSE_ON_CLOSE);

        jPanel1.setBackground(new java.awt.Color(200, 216, 168));

        jPanel2.setBackground(new java.awt.Color(61, 122, 107));

        jLabel1.setBackground(new java.awt.Color(61, 122, 107));
        jLabel1.setFont(new java.awt.Font("Arial", 1, 22)); // NOI18N
        jLabel1.setForeground(new java.awt.Color(255, 255, 255));
        jLabel1.setText("Gestion De Maquinas");
        jLabel1.setMaximumSize(new java.awt.Dimension(222, 26));
        jLabel1.setMinimumSize(new java.awt.Dimension(222, 26));
        jLabel1.setPreferredSize(new java.awt.Dimension(222, 26));

        btnVolver2.setBackground(new java.awt.Color(61, 122, 107));
        btnVolver2.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        btnVolver2.setForeground(new java.awt.Color(255, 255, 255));
        btnVolver2.setText("Volver");
        btnVolver2.setBorderPainted(false);
        btnVolver2.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                btnVolver2ActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel2Layout = new javax.swing.GroupLayout(jPanel2);
        jPanel2.setLayout(jPanel2Layout);
        jPanel2Layout.setHorizontalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addGap(36, 36, 36)
                .addComponent(jLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 295, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                .addComponent(btnVolver2)
                .addGap(21, 21, 21))
        );
        jPanel2Layout.setVerticalGroup(
            jPanel2Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(javax.swing.GroupLayout.Alignment.TRAILING, jPanel2Layout.createSequentialGroup()
                .addContainerGap(15, Short.MAX_VALUE)
                .addComponent(jLabel1, javax.swing.GroupLayout.PREFERRED_SIZE, 38, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap())
            .addGroup(jPanel2Layout.createSequentialGroup()
                .addContainerGap()
                .addComponent(btnVolver2, javax.swing.GroupLayout.PREFERRED_SIZE, 38, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
        );

        jLabel2.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        jLabel2.setForeground(new java.awt.Color(0, 51, 51));
        jLabel2.setText("Seleccionar maquina");

        jbAsignarProducto.setBackground(new java.awt.Color(255, 255, 255));
        jbAsignarProducto.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        jbAsignarProducto.setForeground(new java.awt.Color(51, 51, 51));
        jbAsignarProducto.setText("Asignar Producto");
        jbAsignarProducto.setBorder(new javax.swing.border.LineBorder(new java.awt.Color(61, 122, 107), 1, true));
        jbAsignarProducto.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jbAsignarProductoActionPerformed(evt);
            }
        });

        NuevaMaquina.setBackground(new java.awt.Color(255, 255, 255));
        NuevaMaquina.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        NuevaMaquina.setForeground(new java.awt.Color(51, 51, 51));
        NuevaMaquina.setText("Nueva Maquina ");
        NuevaMaquina.setBorder(new javax.swing.border.LineBorder(new java.awt.Color(61, 122, 107), 1, true));
        NuevaMaquina.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                NuevaMaquinaActionPerformed(evt);
            }
        });

        jLabel3.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        jLabel3.setForeground(new java.awt.Color(61, 122, 107));
        jLabel3.setText("Inventario de la maquina");

        jLabel4.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        jLabel4.setForeground(new java.awt.Color(61, 122, 107));
        jLabel4.setText("Alertas :");

        jcbSeleccionarMaquina.setModel(new javax.swing.DefaultComboBoxModel<>(new String[] { "Item 1", "Item 2", "Item 3", "Item 4" }));
        jcbSeleccionarMaquina.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jcbSeleccionarMaquinaActionPerformed(evt);
            }
        });

        jTableAlertas.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null},
                {null},
                {null},
                {null}
            },
            new String [] {
                "Title 1"
            }
        ));
        jScrollPane3.setViewportView(jTableAlertas);

        jTableInventarioMaquina.setBackground(new java.awt.Color(255, 255, 255));
        jTableInventarioMaquina.setForeground(new java.awt.Color(0, 0, 0));
        jTableInventarioMaquina.setModel(new javax.swing.table.DefaultTableModel(
            new Object [][] {
                {null, null, null, null, null, null},
                {null, null, null, null, null, null},
                {null, null, null, null, null, null},
                {null, null, null, null, null, null}
            },
            new String [] {
                "Producto", "Precio", "Stock", "Minimo", "Estado", "Seleccionar"
            }
        ) {
            Class[] types = new Class [] {
                java.lang.String.class, java.lang.String.class, java.lang.String.class, java.lang.Double.class, java.lang.String.class, java.lang.Boolean.class
            };
            boolean[] canEdit = new boolean [] {
                false, false, false, false, false, true
            };

            public Class getColumnClass(int columnIndex) {
                return types [columnIndex];
            }

            public boolean isCellEditable(int rowIndex, int columnIndex) {
                return canEdit [columnIndex];
            }
        });
        jTableInventarioMaquina.setSelectionBackground(new java.awt.Color(0, 0, 0));
        jScrollPane4.setViewportView(jTableInventarioMaquina);

        jbRecargar.setBackground(new java.awt.Color(255, 255, 255));
        jbRecargar.setFont(new java.awt.Font("Arial", 1, 18)); // NOI18N
        jbRecargar.setForeground(new java.awt.Color(51, 51, 51));
        jbRecargar.setText("Recargar");
        jbRecargar.setBorder(new javax.swing.border.LineBorder(new java.awt.Color(61, 122, 107), 1, true));
        jbRecargar.addActionListener(new java.awt.event.ActionListener() {
            public void actionPerformed(java.awt.event.ActionEvent evt) {
                jbRecargarActionPerformed(evt);
            }
        });

        javax.swing.GroupLayout jPanel1Layout = new javax.swing.GroupLayout(jPanel1);
        jPanel1.setLayout(jPanel1Layout);
        jPanel1Layout.setHorizontalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel2, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addGap(31, 31, 31)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addComponent(NuevaMaquina, javax.swing.GroupLayout.PREFERRED_SIZE, 178, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED, javax.swing.GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                        .addComponent(jbRecargar, javax.swing.GroupLayout.PREFERRED_SIZE, 178, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                        .addComponent(jbAsignarProducto, javax.swing.GroupLayout.PREFERRED_SIZE, 178, javax.swing.GroupLayout.PREFERRED_SIZE)
                        .addGap(57, 57, 57))
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addComponent(jScrollPane3)
                        .addContainerGap())
                    .addGroup(jPanel1Layout.createSequentialGroup()
                        .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
                            .addComponent(jLabel4)
                            .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 1064, javax.swing.GroupLayout.PREFERRED_SIZE)
                            .addGroup(jPanel1Layout.createSequentialGroup()
                                .addComponent(jLabel2)
                                .addGap(30, 30, 30)
                                .addComponent(jcbSeleccionarMaquina, javax.swing.GroupLayout.PREFERRED_SIZE, 287, javax.swing.GroupLayout.PREFERRED_SIZE))
                            .addComponent(jLabel3))
                        .addContainerGap(48, Short.MAX_VALUE))))
        );
        jPanel1Layout.setVerticalGroup(
            jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addGroup(jPanel1Layout.createSequentialGroup()
                .addComponent(jPanel2, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addGap(47, 47, 47)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jLabel2)
                    .addComponent(jcbSeleccionarMaquina, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(51, 51, 51)
                .addGroup(jPanel1Layout.createParallelGroup(javax.swing.GroupLayout.Alignment.BASELINE)
                    .addComponent(jbAsignarProducto, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(jbRecargar, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE)
                    .addComponent(NuevaMaquina, javax.swing.GroupLayout.PREFERRED_SIZE, 48, javax.swing.GroupLayout.PREFERRED_SIZE))
                .addGap(28, 28, 28)
                .addComponent(jLabel3)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane4, javax.swing.GroupLayout.PREFERRED_SIZE, 203, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.UNRELATED)
                .addComponent(jLabel4)
                .addPreferredGap(javax.swing.LayoutStyle.ComponentPlacement.RELATED)
                .addComponent(jScrollPane3, javax.swing.GroupLayout.PREFERRED_SIZE, 124, javax.swing.GroupLayout.PREFERRED_SIZE)
                .addContainerGap(26, Short.MAX_VALUE))
        );

        javax.swing.GroupLayout layout = new javax.swing.GroupLayout(getContentPane());
        getContentPane().setLayout(layout);
        layout.setHorizontalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
        );
        layout.setVerticalGroup(
            layout.createParallelGroup(javax.swing.GroupLayout.Alignment.LEADING)
            .addComponent(jPanel1, javax.swing.GroupLayout.PREFERRED_SIZE, javax.swing.GroupLayout.DEFAULT_SIZE, javax.swing.GroupLayout.PREFERRED_SIZE)
        );

        pack();
    }// </editor-fold>//GEN-END:initComponents

    private void btnVolver2ActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_btnVolver2ActionPerformed
        new MenuPrincipal(nombre, rol, idUsuario).setVisible(true);
        this.dispose();
    }//GEN-LAST:event_btnVolver2ActionPerformed

    private void jbAsignarProductoActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jbAsignarProductoActionPerformed
        int idMaquina = getIdMaquinaSeleccionada();
        if (idMaquina == -1) {
            JOptionPane.showMessageDialog(this,
                    "Seleccione una máquina primero.");
            return;
        }

        AsignarProductoMaquina dlg = new AsignarProductoMaquina(
                (java.awt.Frame) javax.swing.SwingUtilities.getWindowAncestor(this),
                true,
                idMaquina
        );
        dlg.setLocationRelativeTo(this);
        dlg.setVisible(true);
        cargarInventarioMaquina();
    }//GEN-LAST:event_jbAsignarProductoActionPerformed

    private void NuevaMaquinaActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_NuevaMaquinaActionPerformed
        com.vendingminimarket.vista.NuevaMaquina dlg
                = new com.vendingminimarket.vista.NuevaMaquina(this, true);
        dlg.setLocationRelativeTo(this);
        dlg.setVisible(true);
        cargarMaquinas();
    }//GEN-LAST:event_NuevaMaquinaActionPerformed

    private void jcbSeleccionarMaquinaActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jcbSeleccionarMaquinaActionPerformed
        cargarInventarioMaquina();
    }//GEN-LAST:event_jcbSeleccionarMaquinaActionPerformed

    private void jbRecargarActionPerformed(java.awt.event.ActionEvent evt) {//GEN-FIRST:event_jbRecargarActionPerformed
        int idProducto = getProductoSeleccionado();
        if (idProducto == -1) {
            JOptionPane.showMessageDialog(this,
                    "Seleccione un producto de la lista.", "Aviso",
                    JOptionPane.WARNING_MESSAGE);
            return;
        }

        int idMaquina = getIdMaquinaSeleccionada();

        RecargarProducto dlg = new RecargarProducto(
                (java.awt.Frame) SwingUtilities.getWindowAncestor(this),
                true,
                idMaquina,
                idProducto,
                idUsuario
        );
        dlg.setLocationRelativeTo(this);
        dlg.setVisible(true);
        cargarInventarioMaquina();
    }//GEN-LAST:event_jbRecargarActionPerformed

    /**
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        /* Set the Nimbus look and feel */
        //<editor-fold defaultstate="collapsed" desc=" Look and feel setting code (optional) ">
        /* If Nimbus (introduced in Java SE 6) is not available, stay with the default look and feel.
         * For details see http://download.oracle.com/javase/tutorial/uiswing/lookandfeel/plaf.html 
         */
        try {
            for (javax.swing.UIManager.LookAndFeelInfo info : javax.swing.UIManager.getInstalledLookAndFeels()) {
                if ("Nimbus".equals(info.getName())) {
                    javax.swing.UIManager.setLookAndFeel(info.getClassName());
                    break;
                }
            }
        } catch (ReflectiveOperationException | javax.swing.UnsupportedLookAndFeelException ex) {
            logger.log(java.util.logging.Level.SEVERE, null, ex);
        }
        //</editor-fold>

        /* Create and display the form */
        java.awt.EventQueue.invokeLater(() -> new GestionMaquinas("", "", 0).setVisible(true));
    }

    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JButton NuevaMaquina;
    private javax.swing.JButton btnVolver2;
    private javax.swing.JLabel jLabel1;
    private javax.swing.JLabel jLabel2;
    private javax.swing.JLabel jLabel3;
    private javax.swing.JLabel jLabel4;
    private javax.swing.JPanel jPanel1;
    private javax.swing.JPanel jPanel2;
    private javax.swing.JScrollPane jScrollPane1;
    private javax.swing.JScrollPane jScrollPane3;
    private javax.swing.JScrollPane jScrollPane4;
    private javax.swing.JTable jTable1;
    private javax.swing.JTable jTableAlertas;
    private javax.swing.JTable jTableInventarioMaquina;
    private javax.swing.JButton jbAsignarProducto;
    private javax.swing.JButton jbRecargar;
    private javax.swing.JComboBox<String> jcbSeleccionarMaquina;
    // End of variables declaration//GEN-END:variables
}
