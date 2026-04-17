/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.vendingminimarket.modelo;

/**
 *
 * @author deiby
 */
public class Usuario {

    private int idRol;
    private String nombre;
    private String rol;

    public Usuario(String nombre, String rol, int idRol) {
        this.nombre = nombre;
        this.rol = rol;
        this.idRol = idRol;
    }

    public String getNombre() {
        return nombre;
    }

    public String getRol() {
        return rol;
    }

    public int getIdRol() {
        return idRol;
    }
}
